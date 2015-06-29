# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Root
    #
    # HTML Root from which the construction of the final page starts. The root
    # stores all the node definitions that will be replaced in the components.
    #
    class Root
      # Allow direct access to node variables
      attr_accessor :themes, :children, :indent, :blocks, :yields

      # Initialize node instance variables
      #
      # @param definitions [Hash] node definitions to be replaced in children
      # @param children [Array] collection of the node's child elements
      #
      def initialize
        @themes = {
          Engine::DEFAULT_THEME => {}
        }
        @children = []
        @blocks = {}
        @yields = {}
        @indent = -1
      end

      # Add a new node to the nodes array
      #
      # @param node [Node] Node to be added to the parent
      #
      def push(node)
        @children << node
        self
      end

      # Shorthand theme access for root definitions
      #
      # @param key [Symbol] definition or theme name
      #
      def [](key)
        if @themes.has_key? key
          @themes[key]
        else
          @themes[Engine::DEFAULT_THEME][key]
        end
      end

      # Evaluate all child nodes using the given context and the
      # node definitions from the root knowledgebase
      #
      # @param context [Context] Call environment binding object
      #
      def evaluate(context)
        @children.map do |node|
          node.evaluate(context)
        end.flatten.compact
      end
    end
  end
end
