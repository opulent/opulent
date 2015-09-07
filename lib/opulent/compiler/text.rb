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

      # Evaluate text node if it's marked as such and print nodes in the
      # current context
      if node[@value] == :text
        split_by_interpolation value, node[@options][:escaped]
      else
        node[@options][:escaped] ? buffer_escape(value) : buffer(value)
      end
    end

    # Split a string by its interpolation, then check if it really needs to be
    # escaped or not. Huge performance boost!
    #
    # @param string [String] Input string
    # @param escape [Boolean] Escape string
    #
    def split_by_interpolation(string, escape = true)
      until string.empty?
        case string
        # Process interpolation part of the string
        when /^\#\{([^}])\}/
          result = $1
          if escape
            buffer_escape result
          else
            buffer_buffer result
          end
          string = string[result.length + 3..-1]

        # Process string up to interpolation part and check if it's HTML safe.
        # If it is, then we render it as buffer text, otherwise we escape it.
        when /^((.|\s)+)(?<!\\)\#\{[^}]\}/
          result = $1
          if escape
            result =~ Utils::EscapeHTMLPattern ? buffer_escape(result) : buffer_freeze(result)
          else
            buffer_freeze result
          end
          string = string[result.length..-1]

        # No more interpolations, simple set the result as the remaining string
        else
          result = string
          if escape
            result =~ Utils::EscapeHTMLPattern ? buffer_escape(result) : buffer_freeze(result)
          else
            buffer_freeze result
          end
          string = ""
        end
      end
    end
  end
end
