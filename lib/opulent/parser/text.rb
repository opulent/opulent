# @SugarCube
module Opulent
  # @Parser
  module Parser
    # @Singleton
    class << self
      # Match one line or multiline, escaped or unescaped text
      #
      # @param parent [Array] Parent node element
      # @param indent [Fixnum] Size of the current indentation
      # @param multiline_or_print [Boolean] Allow only multiline text or print
      #
      def text(parent, indent = nil, multiline_or_print = true)
        # Try to see if we can match a multiline operator. If we can accept_stripped only
        # multiline, which is the case for filters, undo the operation.
        if accept_stripped :multiline
          multiline = true
        elsif multiline_or_print
          return undo indent unless lookahead :print_lookahead
        end

        # Unescaped Print Eval
        if (text_feed = accept_stripped :unescaped_print)
          text_node = [:print, text_feed[1..-1].strip, {escaped: false}, nil, indent]
        # Escaped Print Eval
        elsif (text_feed = accept_stripped :escaped_print)
          text_node = [:print, text_feed[2..-1].strip, {escaped: true}, nil, indent]
        # Unescaped Text
        elsif (text_feed = accept_stripped :unescaped_text)
          text_node = [:text, text_feed.strip, {escaped: false}, nil, indent]
        # Escaped Text
        elsif (text_feed = accept_stripped :escaped_text)
          text_node = [:text, text_feed[1..-1].strip, {escaped: true}, nil, indent]
        else
          return nil
        end


        if text_node
          if multiline
            text_node[@value] = text_node[@value][1..-1]
            text_node[@value] += accept(:newline) || ""
            text_node[@value] += get_indented_lines(indent)

            text_node
          else
            accept :newline

            text_node[@value].strip!
            text_node[@value] = text_node[@value][1..-1] if text_node[@value][0] == '\\'
            text_node[@value].size > 0 ? text_node : nil
          end

          parent[@children] << text_node
        else
          return nil
        end
      end

      # Match one line or multiline, escaped or unescaped text
      #
      def html_text(parent, indent)
        indent = accept_stripped(:indent) || ""
        indent_size = indent.size

        if (text_feed = accept_stripped :html_text)
          text_node = [:text, text_feed[1..-1].strip, {escaped: false}, nil, indent]
          accept_stripped :newline
          pp text_feed
          return text_node
        else
          return undo indent
        end
      end

      # Match a whitespace by preventing code trimming
      #
      def whitespace(required = false)
        accept :whitespace, required
      end

      # Gather all the lines which have higher indentation than the one given as
      # parameter and put them into the buffer
      #
      # @param indentation [Fixnum] parent node strating indentation
      #
      def get_indented_lines(indent)
        buffer = ''

        # Get the next indentation after the parent line
        # and set it as primary indent
        first_indent = (lookahead_next_line(:indent).to_s || "").size
        next_indent = first_indent

        # While the indentation is smaller, add the line feed  to our buffer
        while next_indent > indent
          # Advance current line and reset offset
          @line = @code[(@i += 1)]
          @offset = 0

          # Get leading whitespace trimmed with first_indent's size
          next_line_indent = accept(:indent)[first_indent..-1] || ""
          next_line_indent = next_line_indent.size

          # Add next line feed, prepend the indent and append the newline
          buffer += " " * next_line_indent if next_line_indent > 0
          buffer += accept_stripped(:line_feed) || ""
          buffer += accept_stripped(:newline) || ""

          # Get next indentation and repeat
          if (next_indent = lookahead_next_line :indent)
            next_indent = next_indent[0].size
          end
        end

        return buffer
      end
    end
  end
end
