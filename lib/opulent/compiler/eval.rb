# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Evaluate the embedded ruby code using the current context
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    #
    def evaluate(node, indent)
      # Check if this is a substructure of a control block and remove the last
      # end evaluation if it is
      if node[@value] =~ Settings::END_REMOVAL
        @template.pop if @template[-1] == [:eval, 'end']
      end

      # Check for explicit end node
      if node[@value] =~ Settings::END_EXPLICIT
        Logger.error :compile, @template, :explicit_end, node
      end

      # Evaluate the current expression
      buffer_eval node[@value]

      # If the node has children, evaluate each one of them
      if node[@children]
        node[@children].each do |child|
          root child, indent + @settings[:indent]
        end
      end

      # Check if the node is actually a block expression
      buffer_eval 'end' if node[@value] =~ Settings::END_INSERTION
    end
  end
end
