# @Opulent
module Opulent
  # @Parser
  class Parser
    # Match one line or multiline comments
    #
    # @param parent [Node] Parent node of comment
    # @param indent [Fixnum] Number of indentation characters
    #
    def comment(parent, indent)
      return unless accept :comment

      # Get first comment line
      buffer = accept(:line_feed)
      buffer += accept(:newline) || ''

      # Get indented comment lines
      buffer += get_indented_lines indent

      # If we have a comment which is visible in the output, we will
      # create a new comment element. Otherwise, we ignore the current
      # gathered text and we simply begin the root parsing again
      if buffer[0] == '!'
        offset = 1
        options = {}

        # Allow leading comment newline
        if buffer[1] == '^'
          offset = 2
          options[:newline] = true
        end

        parent[@children] << [
          :comment,
          buffer[offset..-1].strip,
          options,
          nil,
          indent
        ]
      end

      parent
    end
  end
end
