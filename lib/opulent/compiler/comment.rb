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
      buffer_freeze indentation if Settings[:pretty]

      # Escaping double quotes is required in order to avoid any conflicts with the eval quotes.
      #comment_tag = "#{}#{indentation}<!-- #{value.strip} -->\n"
      buffer_freeze "\n" if node[@options][:newline]
      buffer_freeze "<!-- "
      format_string node[@value].strip, true
      buffer_freeze " -->"

      @node_stack << :comment
    end
  end
end
