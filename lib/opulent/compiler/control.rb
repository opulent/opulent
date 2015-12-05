# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a if-elsif-else control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def if_node(node, indent, context)
      # Check if we have any condition met, or an else branch
      node[@value].each_with_index do |value, index|
        # If we have a branch that meets the condition, generate code for the
        # children related to that specific branch
        case value
        when node[@value].first then buffer_eval "if #{value}"
        when node[@value].last then buffer_eval "else"
        else buffer_eval "elsif #{value}"
        end

        # Evaluate child nodes
        node[@children][index].each do |child|
          root child, indent, context
        end
      end

      # End
      buffer_eval "end"
    end

    # Generate the code for a unless-else control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def unless_node(node, indent, context)
      # Check if we have any condition met, or an else branch
      node[@value].each_with_index do |value, index|
        # If we have a branch that meets the condition, generate code for the
        # children related to that specific branch
        case value
        when node[@value].first then buffer_eval "unless #{value}"
        else buffer_eval "else"
        end

        # Evaluate child nodes
        node[@children][index].each do |child|
          root child, indent, context
        end
      end

      # End
      buffer_eval "end"
    end

    # Generate the code for a case-when-else control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def case_node(node, indent, context)
      # Evaluate the switching condition
      buffer_eval "case #{node[@options][:condition]}"

      # Check if we have any condition met, or an else branch
      node[@value].each_with_index do |value, index|
        # If we have a branch that meets the condition, generate code for the
        # children related to that specific branch
        case value
        when node[@value].last then buffer_eval "else"
        else buffer_eval "when #{value}"
        end

        # Evaluate child nodes
        node[@children][index].each do |child|
          root child, indent, context
        end
      end

      # End
      buffer_eval "end"
    end

    # Generate the code for a while control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def while_node(node, indent, context)
      # While we have a branch that meets the condition, generate code for the
      # children related to that specific branch
      buffer_eval "while #{node[@value]}"

      # Evaluate child nodes
      node[@children].each do |child|
        root child, indent, context
      end

      #End
      buffer_eval "end"
    end

    # Generate the code for a while control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def until_node(node, indent, context)
      # Until we have a branch that doesn't meet the condition, generate code for the
      # children related to that specific branch
      buffer_eval "until #{node[@value]}"

      # Evaluate child nodes
      node[@children].each do |child|
        root child, indent, context
      end

      # End
      buffer_eval "end"
    end

    # Generate the code for a while control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def each_node(node, indent, context)
      # Process named variables for each structure
      variables = node[@value][1].clone

      # The each structure accept missing arguments as well, therefore we need to
      # substitute them with our defaults
      #
      # each in iterable
      # each value in iterable
      # each key, value in iterable

      # Value argument name provided only
      if variables.length == 1
        variables.unshift Settings::DEFAULT_EACH_KEY

      # Missing key and value arguments
      elsif variables.empty?
        variables[0] = Settings::DEFAULT_EACH_KEY
        variables[1] = Settings::DEFAULT_EACH_VALUE
      end

      # Choose whether to apply each with index (Arrays) or each (Hashes) methods
      #buffer_eval "_opulent_send_method = (#{node[@value][1]}.is_a?(Array) ? :each_with_index : :each)"
      case node[@value][0][0]
      when '[]'
        buffer_eval "#{node[@value][0][1]}.each_with_index do |#{variables.reverse.join ', '}|"
      else
        buffer_eval "#{node[@value][0][1]}.each do |#{variables.join ', '}|"
      end

      # Evaluate child nodes
      node[@children].each do |child|
        root child, indent, context
      end

      # End
      buffer_eval "end"
    end
  end
end
