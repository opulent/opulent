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
      indentation = " " * indent

      value = context.evaluate "\"#{node[@value]}\""

      comment_tag = "#{indentation}<!-- #{value} -->\n"

      @node_stack << :comment
      @code += comment_tag
    end
  end
end
