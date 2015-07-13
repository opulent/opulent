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

      # Escaping double quotes is required in order to avoid any conflicts with the eval quotes.
      value = indent_lines context.evaluate('"' + node[@value].gsub('"', '\\"') + '"'), " " * indent

      comment_tag = "#{"\n" if node[@options][:newline]}#{indentation}<!-- #{value.strip} -->\n"

      @node_stack << :comment
      @code += comment_tag
    end
  end
end
