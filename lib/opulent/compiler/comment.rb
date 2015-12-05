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
    def comment(node, indent, context)
      buffer_freeze "\n" if node[@options][:newline]
      buffer_freeze '<!-- '
      buffer_split_by_interpolation node[@value].strip, false
      buffer_freeze ' -->'
    end
  end
end
