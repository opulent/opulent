# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a while control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def yield_node(node, indent, context)
      buffer_eval "yield if block_given?"
    end
  end
end
