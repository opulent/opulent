# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Expression
    #
    # Literals are static values that have a Ruby representation, eg.: a string, a number,
    # true, false, nil, etc.
    #
    class Expression
      attr_accessor :value, :escaped

      def initialize(value = '')
        @value = value
        @escaped = true
      end

      def to_s
        @value
      end

      def evaluate(context)
        evaluated = context.evaluate @value
        @escaped ? Runtime.escape(evaluated) : evaluated
      end
    end
  end
end
