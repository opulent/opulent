# @Opulent
module Opulent
  # @Parser
  class Parser
    # Match one line or multiline, escaped or unescaped text
    #
    # @param parent [Array] Parent node element
    # @param indent [Fixnum] Size of the current indentation
    # @param multiline_or_print [Boolean] Allow only multiline text or print
    #
    def text(parent, indent = nil, multiline_or_print = true)
      # Try to see if we can match a multiline operator. If we can accept_stripped only
      # multiline, which is the case for filters, undo the operation.
      if accept :multiline
        multiline = true
      elsif multiline_or_print
        return nil unless lookahead :print_lookahead
      end

      # Get text node type
      type = accept(:print) ? :print : :text

      # Get leading whitespace
      leading_whitespace = accept(:leading_whitespace)

      # Get trailing whitespace
      trailing_whitespace = accept(:trailing_whitespace)

      # Check if the text or print node is escaped or unescaped
      escaped = accept(:unescaped_value) ? false : true

      # Get text value
      value = accept :line_feed
      value = value[1..-1] if value[0] == '\\'

      # Create the text node using input data
      text_node = [
        :plain,
        type,
        {
          value: value.strip,
          escaped: escaped,
          leading_whitespace: leading_whitespace,
          trailing_whitespace: trailing_whitespace
        },
        nil,
        indent
      ]

      # If we have a multiline node, get all the text which has higher
      # indentation than our indentation node.
      if multiline
        text_node[@options][:value] += accept(:newline) || ''
        text_node[@options][:value] += get_indented_lines(indent)
        text_node[@options][:value].strip!
      elsif value.empty?
        # If our value is empty and we're not going to add any more lines to
        # our buffer, skip the node
        return nil
      end

      # Increase indentation if this is an inline text node
      text_node[@indent] += @settings[:indent] unless multiline_or_print

      # Add text node to the parent element
      parent[@children] << text_node
    end

    # Match one line or multiline, escaped or unescaped text
    #
    def html_text(parent, indent)
      return unless (text_feed = accept :html_text)

      text_node = [
        :plain,
        :text,
        {
          value: text_feed.strip,
          escaped: false
        },
        nil,
        indent
      ]

      parent[@children] << text_node
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

      # Gather multiple blank lines between lines of text
      blank_lines = proc do
        while lookahead_next_line :line_whitespace
          @line = @code[(@i += 1)]
          @offset = 0

          buffer += accept :line_whitespace
        end
      end

      # Get blank lines until we match something
      blank_lines[]

      # Get the next indentation after the parent line
      # and set it as primary indent
      first_indent = (lookahead_next_line(:indent).to_s || '').size
      next_indent = first_indent

      # While the indentation is smaller, add the line feed  to our buffer
      while next_indent > indent
        # Advance current line and reset offset
        @line = @code[(@i += 1)]
        @offset = 0

        # Get leading whitespace trimmed with first_indent's size
        next_line_indent = accept(:indent)[first_indent..-1] || ''
        next_line_indent = next_line_indent.size

        # Add next line feed, prepend the indent and append the newline
        buffer += ' ' * next_line_indent if next_line_indent > 0
        buffer += accept_stripped(:line_feed) || ''
        buffer += accept(:newline) || ''

        # Get blank lines until we match something
        blank_lines[]

        # Check the indentation on the following line. When we reach EOF,
        # set the indentation to 0 and cause the loop to stop
        if (next_indent = lookahead_next_line :indent)
          next_indent = next_indent[0].size
        else
          next_indent = 0
        end
      end

      buffer
    end
  end
end
