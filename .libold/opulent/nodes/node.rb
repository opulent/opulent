# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Node
    #
    # Node class used to describe a HTML Element used for building a
    # page model during the parsing process
    #
    class Node
      # Allow direct access to node variables
      attr_accessor :name, :attributes, :children, :whitespace, :parent, :indent, :extension, :theme, :blocks, :yields, :self_enclosing

      # Initialize node instance variables
      #
      # @param name [String] name of the html node
      # @param indentation [Fixnum] node indentation for restructuring
      # @param attributes [Hash] stores key="value" attributes
      # @param children [Array] collection of the node's child elements
      #
      def initialize(name = '', attributes = {}, parent = nil, indent = 0, children = [])
        @name = name
        @parent = parent
        @indent = indent
        @attributes = attributes
        @children = children
        @extension = nil
        @theme = Engine::DEFAULT_THEME
        @self_enclosing = Engine::SELF_ENCLOSING.include? name
        @whitespace = [nil, nil]
        @blocks = {
          Engine::DEFAULT_YIELD => @children
        }
        @yields = []
      end

      # Add a new node to the nodes array
      #
      def push(node)
        @children << node
        self
      end

      # Return extended attributes if an extension was set using the [extend]
      # identifier of the node
      #
      def extend_attributes(attributes, extension)
        return attributes if extension.nil?

        extension.each do |key, value|
          case attributes[key]
          when Array
            attributes[key] = (attributes[key] << value).flatten
          when Hash
            attributes[key] = value.merge attributes[key]
          when nil
            attributes[key] = value
          end
        end

        attributes
      end

      # Node evaluation method which goes through all the child nodes and evaluates
      # them using their own eval method
      #
      def evaluate(context)
        # Set attributes for current context
        attributes = Runtime.attributes @attributes, @extension, context

        # Evaluate all provided blocks
        blocks = Hash[@blocks.map{ |key, value|
          children = value.map do |child|
            child.evaluate context
          end.flatten.compact

          [key, children]
        }]

        # Map self to a different node and set evaluated children nodes and
        # evaluated attributes and add a pointer to the children block
        mapped_node = self.dup
        mapped_node.attributes = attributes
        mapped_node.blocks = blocks
        mapped_node.children = mapped_node.blocks[Engine::DEFAULT_YIELD]

        # Replace node with its definition if it has one
        if Runtime[@theme]
          if Runtime[@theme][@name] && @name != context.name
            return Runtime.define mapped_node, attributes, context
          else
            return mapped_node
          end
        else
          # Theme does not exist
          Runtime.error :theme, @theme
        end
      end
    end
  end
end
