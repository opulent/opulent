# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Filter
    #
    # Node class used to run a value interpretation
    #
    class Filter
      # Allow direct access to node variables
      attr_accessor :name, :attributes, :value, :parent, :indent

      # Initialize node instance variables
      #
      # @param name [String] name of the html node
      # @param indentation [Fixnum] node indentation for restructuring
      # @param attributes [Hash] stores key="value" attributes
      # @param value [String] Contents to be interpreted
      #
      def initialize(name = '', attributes = {}, parent = nil, indent = 0, value = '')
        @name = name
        @parent = parent
        @indent = indent
        @attributes = attributes
        @value = value
      end

      # Update attributes with values from current evaluation context
      #
      def get_attributes(context)
        Hash[@attributes.map{ |key, val|
          unless val.nil?
            value = val.evaluate(context)
            value.flatten! if value.is_a?(Array)
          end
          [key, value]
        }]
      end

      # Node evaluation method which goes through all the child nodes and evaluates
      # them using their own eval method
      #
      def evaluate(context)
        # Set attributes for current context
        attributes = Runtime.attributes @attributes, nil, context

        # Check if filter is registered
        Runtime.error :filter_registered, name unless Engine.filter? name

        # Load the required filter
        Engine.filters[name].load_filter

        # Render output using the chosen engine
        output = Engine.filters[name].render @value

        # Main output node which contains filter rendered value
        text_node = Text.new output, false, @parent, @indent

        # If we have a provided filter tag, wrap the text node in the wrapper
        # node tag and further indent
        if (wrapper_tag = Engine.filters[name].options[:tag])
          text_node.indent = @indent + Engine[:indent]
          return Node.new wrapper_tag, Engine.filters[name].options[:attributes], @parent, @indent, [text_node]
        else
          return text_node
        end
      end
    end
  end
end
