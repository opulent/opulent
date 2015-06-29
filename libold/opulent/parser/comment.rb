# @SugarCube
module Opulent
  # @Parser
  module Parser
    # @Text
    module Comment
      # Match one line or multiline comments
      #
      def comment(parent)
        if lookahead(:comment_lookahead)
          indent = accept_unstripped(:indent) || ""
          indent = indent.size

          if (comment_feed = accept_unstripped :comment)
            comment_feed += accept_unstripped(:newline) || ""
            comment_feed += get_indented_lines indent

            # If we have a comment which is visible in the output, we will
            # create a new comment element. Otherwise, we ignore the current
            # gathered text and we simply begin the root parsing again
            if comment_feed[0] == '!'
              return @create.comment comment_feed[1..-1].strip, parent, indent
            else
              root parent
              return nil
            end
          end
        end
      end
    end
  end
end
