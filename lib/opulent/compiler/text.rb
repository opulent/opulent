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
      # Text value
      value = node[@options][:value]

      # Pretty print
      if @settings[:pretty]
        indentation = ' ' * indent

        inline = @sibling_stack[-1][-1] && @sibling_stack[-1][-1][0] == :node &&
                 Settings::INLINE_NODE.include?(@sibling_stack[-1][-1][1])

        # Add current node to the siblings stack
        @sibling_stack[-1] << [node[@type], node[@value]]

        # If we have a text on multiple lines and the text isn't supposed to be
        # inline, indent all the lines of the text
        if node[@value] == :text
          if !inline
            value.gsub!(/^(?!$)/, indentation)
          else
            value.strip!
          end
        else
          buffer_freeze indentation
        end
      end

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

      # Pretty print
      if @settings[:pretty]
        buffer_freeze "\n" unless inline
      end
    end
  end
end
