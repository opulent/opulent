# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Text
    #
    # The text class will output raw or escaped HTML text
    #
    class Comment
      # Allow direct access to literal value and type
      attr_accessor :value, :visible, :parent, :indent, :name

      # Initialize literal instance variables
      #
      # @param value stores the literal's explicit value
      #
      def initialize(value = nil, parent = nil, indent = 0)
        @value = value
        @parent = parent
        @indent = indent
        @name = :comment
      end

      # Value evaluation method which returns the processed value of the
      # literal
      #
      def evaluate(context)
        comment = self.dup
        comment.value = context.evaluate "\"#{@value}\""
        
        return comment
      end
    end
  end
end
