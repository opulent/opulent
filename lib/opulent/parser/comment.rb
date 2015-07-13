# @Opulent
module Opulent
  # @Parser
  class Parser
    # Match one line or multiline comments
    #
    def comment(parent, indent)
      if (accept :comment)
        multiline = true if (accept :comment)

        buffer = accept(:line_feed)
        buffer += accept(:newline) || ""
        buffer += get_indented_lines indent if multiline


        # If we have a comment which is visible in the output, we will
        # create a new comment element. Otherwise, we ignore the current
        # gathered text and we simply begin the root parsing again
        if buffer[0] == '!'
          offset = 1; options = {}

          # Allow leading comment newline
          if buffer[1] == '^'
            offset = 2; options[:newline] = true
          end

          parent[@children] << [:comment, buffer[offset..-1].strip, options, nil, indent]
        end

        return parent
      end
    end
  end
end
