# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a standard text node
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def plain(node, indent, context)

      value = node[@options][:value]

      indentation = " " * indent
      indent_lines value, indentation if Settings[:pretty]

      # Evaluate text node if it's marked as such and print nodes in the
      # current context
      if node[@value] == :text
        format_string value, node[@options][:escaped]
      else
        node[@options][:escaped] ? buffer_escape(value) : buffer(value)
      end
    end
  end
end
