# @Opulent
module Opulent
  # @Parser
  class Parser
    # Match an if-else control structure
    #
    def control(parent, indent)
      # Accept eval or multiline eval syntax and return a new node,
      return unless (structure = accept(:control))
      structure = structure.to_sym

      # Handle each and the other control structures
      condition = accept(:line_feed).strip

      # Process each control structure condition
      if structure == :each
        # Check if arguments provided correctly
        unless condition.match Tokens[:each_pattern]
          Logger.error :parse, @code, @i, @j, :each_arguments
        end

        # Conditions for each iterator
        condition = [
          Regexp.last_match[1].split(' '),
          Regexp.last_match[2].split(/,(.+)$/).map(&:strip).map(&:to_sym)
        ]

        # Array loop as default
        condition[0].unshift '{}' if condition[0].length == 1
      end

      # Else and default structures are not allowed to have any condition
      # set and the other control structures require a condition
      if structure == :else
        unless condition.empty?
          Logger.error :parse, @code, @i, @j, :condition_exists
        end
      else
        if condition.empty?
          Logger.error :parse, @code, @i, @j, :condition_missing
        end
      end

      # Add the condition and create a new child to the control parent.
      # The control parent keeps condition -> children matches for our
      # document's content
      # add_options = proc do |control_parent|
      #   control_parent.value << condition
      #   control_parent.children << []
      #
      #   root control_parent
      # end

      # If the current control structure is a parent which allows multiple
      # branches, such as an if or case, we create an array of conditions
      # which can be matched and an array of children belonging to each
      # conditional branch
      if [:if, :unless].include? structure
        # Create the control structure and get its child nodes
        control_structure = [structure, [condition], {}, [], indent]
        root control_structure, indent

        # Turn children into an array because we allow multiple branches
        control_structure[@children] = [control_structure[@children]]

        # Add it to the parent node
        parent[@children] << control_structure

      elsif structure == :case
        # Create the control structure and get its child nodes
        control_structure = [
          structure,
          [],
          { condition: condition },
          [],
          indent
        ]

        # Add it to the parent node
        parent[@children] << control_structure

      # If the control structure is a child structure, we need to find the
      # node it belongs to amont the current parent. Search from end to
      # beginning until we find the node parent
      elsif control_child structure
        # During the search, we try to find the matching parent type
        unless control_parent(structure).include? parent[@children][-1][@type]
          Logger.error :parse,
                       @code,
                       @i,
                       @j,
                       :control_child,
                       control_parent(structure)
        end

        # Gather child elements for current structure
        control_structure = [structure, [condition], {}, [], indent]
        root control_structure, indent

        # Add the new condition and children to our parent structure
        parent[@children][-1][@value] << condition
        parent[@children][-1][@children] << control_structure[@children]

      # When our control structure isn't a complex composite, we create
      # it the same way as a normal node
      else
        control_structure = [structure, condition, {}, [], indent]
        root control_structure, indent

        parent[@children] << control_structure
      end
    end

    # Check if the current control structure requires a parent node and
    # return the parent's node type
    #
    def control_child(structure)
      [:else, :elsif, :when].include? structure
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
