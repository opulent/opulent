# @Opulent
module Opulent
  # @Parser
  class Parser
    # Match one line or multiline, escaped or unescaped text
    #
    def evaluate(parent, indent)
      # Accept eval or multiline eval syntax and return a new node,
      if (evaluate = accept(:eval))
        eval_node = [:evaluate, evaluate[1..-1].strip, {}, nil, indent]
      elsif (evaluate = accept(:eval_multiline))
        # Get all the lines which are more indented than the current one
        eval_node = [:evaluate, evaluate[1..-1].strip, {}, nil, indent]
        eval_node[@value] += accept(:newline) || ""
        eval_node[@value] += get_indented_lines(indent)
      end

      parent[@children] << eval_node if eval_node
    end
  end
end
