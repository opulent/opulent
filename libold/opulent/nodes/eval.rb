# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Evaluate
    #
    # The eval node evaluates ruby code in the given context without printing
    # any output in the page
    #
    class Evaluate
      attr_accessor :value, :parent, :indent, :children, :name

      # Ruby code evaluation node
      #
      # @param name [String] name of the html node
      # @param parent [Node] parent of the element
      # @param indent [Fixnum] node indentation for restructuring
      # @param children [Array] contents to be interpreted
      #
      def initialize(value = '', parent = nil, indent = 0, children = [])
        @name = :eval
        @value = value
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

      def evaluate(context)
        context.evaluate @value
        return nil
      end
    end
  end
end
