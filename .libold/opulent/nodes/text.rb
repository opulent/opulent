# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Text
    #
    # The text class will output raw or escaped HTML text
    #
    class Text
      # Allow direct access to literal value and type
      attr_accessor :value, :escaped, :parent, :indent, :name

      # Initialize literal instance variables
      #
      # @param value stores the literal's explicit value
      #
      def initialize(value = nil, escaped = true, parent = nil, indent = 0)
        @value = value
        @escaped = escaped
        @parent = parent
        @indent = indent
        @name = :text
      end

      # Value evaluation method which returns the processed value of the
      # literal
      #
      def evaluate(context)
        value = context.evaluate "\"#{@value}\""

        evaluated_text = self.dup
        evaluated_text.value = @escaped ? Runtime.escape(value) : value
        return evaluated_text
      end
    end

    # @Print
    #
    # The print class will evaluate the ruby code and return a new text
    # node containing the escaped or unescaped eval sequence
    #
    class Print < Text
      # Value evaluation method which returns the processed value of the literal
      #
      def evaluate(context)
        value = context.evaluate @value

        evaluated_text = self.dup
        evaluated_text.value = @escaped ? Runtime.escape(value) : value
        return evaluated_text
      end
    end
  end
end
