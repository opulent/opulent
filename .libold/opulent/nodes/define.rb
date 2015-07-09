# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @Define
    #
    # Define a custom HTML element
    #
    class Define < Node
      # Node evaluation method which goes through all the child nodes and
      # evaluates them using their own eval method
      #
      def evaluate(context, blocks = {})
        yields = @yields.clone

        @children.map do |child|
          evaluated_child = child.evaluate context

          # Check to see if the child element being mapped is one of the yield
          # node parent pointers
          if yields.include? child
            yields.delete child

            # We need to replace the yield nodes with the matching named block
            # in order to map the yield node correctly
            evaluated_child.children.map! do |subchild|
              if subchild.is_a?(Yield) && blocks[subchild.name]
                blocks[subchild.name]
              else
                subchild
              end
            end
            evaluated_child.children.compact!
            evaluated_child.children.flatten!
          end

          evaluated_child
        end
      end
    end
  end
end
