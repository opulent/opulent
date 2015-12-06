# @Opulent
module Opulent
  # @Parser
  class Parser
    # Match one line or multiline, escaped or unescaped text
    #
    def evaluate(parent, indent)
      # Accept eval or multiline eval syntax and return a new node,
      return unless accept :eval

      multiline = accept(:text)

      if multiline
        # Get first evaluation line
        evaluate_code = accept(:line_feed) || ''

        # Get all the lines which are more indented than the current one
        eval_node = [:evaluate, evaluate_code.strip, {}, nil, indent]
        eval_node[@value] += accept(:newline) || ''
        eval_node[@value] += get_indented_lines(indent)
      else
        evaluate_code = accept(:line_feed) || ''
        eval_node = [:evaluate, evaluate_code.strip, {}, [], indent]

        root eval_node, indent
      end

      parent[@children] << eval_node
    end
  end
end
