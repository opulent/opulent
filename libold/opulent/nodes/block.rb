# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Yield
    #
    class Yield < Node
      # Node evaluation method which goes through all the child nodes and evaluates
      # them using their own eval method
      #
      def evaluate(context)
        self
      end
    end

    # @Block
    #
    class Block < Node
      # Node evaluation method which goes through all the child nodes and evaluates
      # them using their own eval method
      #
      def evaluate(context)
        @children.map do |child|
          child.evaluate context
        end.flatten.compact
      end
    end
  end
end
