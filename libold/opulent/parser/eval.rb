# @SugarCube
module Opulent
  # @Parser
  module Parser
    # @Text
    module Evaluate
      # Match one line or multiline, escaped or unescaped text
      #
      def evaluate(parent)
        indent = indent || accept_unstripped(:indent) || ""

        # Accept eval or multiline eval syntax and return a new node,
        if (evaluate = accept_unstripped(:eval))
          eval_node = @create.evaluate(evaluate.strip, parent, indent.size)
          accept_unstripped :newline
        elsif (evaluate = accept_unstripped(:eval_multiline))
          # Get all the lines which are more indented than the current one
          eval_node = @create.evaluate(evaluate.strip, parent, indent.size)
          eval_node.value += accept_unstripped(:newline) || ""
          eval_node.value += get_indented_lines(indent.size)
        end

        if eval_node
          # Return the found eval node
          return eval_node
        else
          # Undo by adding the found intentation back
          return undo indent
        end
      end
    end
  end
end
