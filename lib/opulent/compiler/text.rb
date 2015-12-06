# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a standard text node
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    #
    def plain(node, indent)
      value = node[@options][:value]

      # Leading whitespace
      buffer_freeze ' ' if node[@options][:leading_whitespace]

      # Evaluate text node if it's marked as such and print nodes in the
      # current context
      if node[@value] == :text
        buffer_split_by_interpolation value, node[@options][:escaped]
      else
        node[@options][:escaped] ? buffer_escape(value) : buffer(value)
      end

      # Trailing whitespace
      buffer_freeze ' ' if node[@options][:trailing_whitespace]
    end
  end
end
