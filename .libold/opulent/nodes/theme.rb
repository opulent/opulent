# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Theme
    #
    # Node class used to describe a HTML Element used for building a
    # page model during the parsing process
    #
    class Theme
      # Allow direct access to node variables
      attr_accessor :name, :indent, :parent, :children

      # Initialize node instance variables
      #
      # @param name [String] name of the html node
      # @param indentation [Fixnum] node indentation for restructuring
      # @param attributes [Hash] stores key="value" attributes
      # @param children [Array] collection of the node's child elements
      #
      def initialize(name = '', parent = nil, indent = 0, children = [])
        @name = name
        @parent = parent
        @indent = indent
        @children = children
      end

      # Add a new node to the nodes array
      #
      def push(node)
        @children << node
        self
      end
    end
  end
end
