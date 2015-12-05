# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Evaluate the embedded ruby code using the current context
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    #
    def evaluate(node, indent)
      buffer_eval node[@value]
    end
  end
end
