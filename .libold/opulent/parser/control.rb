# @SugarCube
module Opulent
  # @Parser
  module Parser
    # @Control
    module Control
      # Match an if-else control structure
      #
      def control(parent)
        if lookahead :control_lookahead
          indent = indent || accept_unstripped(:indent) || ""

          # Accept eval or multiline eval syntax and return a new node,
          if (structure = accept_unstripped(:control))
            structure = structure.to_sym

            # Handle each and the other control structures
            condition = accept_unstripped(:line_feed).strip
            accept_unstripped :newline

            # Process each control structure condition
            if structure == :each
              # Check if arguments provided correctly
              error :each_arguments unless condition.match Tokens[:each_pattern][:regex]

              # Split provided arguments for the each structure
              condition = condition.split('in').map(&:strip)
              condition[0] = condition[0].split(',').map(&:strip).map(&:to_sym)
            end

            # Else and default structures are not allowed to have any condition
            # set and the other control structures require a condition
            if structure == :else
              error :condition_exists unless condition.empty?
            else
              error :condition_missing if condition.empty?
            end

            # Add the condition and create a new child to the control parent.
            # The control parent keeps condition -> children matches for our
            # document's content
            add_options = Proc.new do |control_parent|
              control_parent.value << condition
              control_parent.children << []

              root control_parent
            end

            # If the current control structure has a matching parent, we search
            # for that type of element in the siblings with the same indentation
            # otherwise we return a new control structure parent
            if (parent_type = control_parent structure)
              begin
                last = -1
                until parent_type.include? parent.children[last].name
                  last -= 1
                end
                add_options[parent.children[last]]
              rescue NoMethodError
                error :control_parent
              end
            else
              control_node = @create.control(structure, condition, parent, indent.size)
            end

            control_node
          end
        end
      end

      # Check if the current control structure requires a parent node and
      # return the parent's node type
      #
      def control_parent(structure)
        case structure
        when :else then [:if, :unless, :case]
        when :elsif then [:if]
        when :when then [:case]
        end
      end
    end
  end
end
