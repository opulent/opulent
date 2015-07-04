# @SugarCube
module Opulent
  # @Parser
  module Parser
    # @Singleton
    class << self
      # Match one line or multiline comments
      #
      def comment(parent, indent)
        if (accept :comment)
          buffer = accept(:line_feed)
          buffer += accept(:newline) || ""
          buffer += get_indented_lines indent

          # If we have a comment which is visible in the output, we will
          # create a new comment element. Otherwise, we ignore the current
          # gathered text and we simply begin the root parsing again
          if buffer[0] == '!'
            parent << [:comment, buffer[1..-1].strip, {}, nil, indent]
          end

          return parent
        end
      end
    end
  end
end
