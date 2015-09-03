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
        if index == 0
          buffer_eval "if #{value}"
        elsif value.empty?
          buffer_eval "else"
        else
          buffer_eval "elsif #{value}"
        end

        node[@children][index].each do |child|
          root child, indent, context
        end
      end
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
        if index == 0
          buffer_eval "unless #{value}"
        elsif value.empty?
          buffer_eval "else"
        end

        node[@children][index].each do |child|
          root child, indent, context
        end
      end
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
        if value.empty?
          buffer_eval "else"
        else
          buffer_eval "when #{value}"
        end

        node[@children][index].each do |child|
          root child, indent, context
        end
      end
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
        node[@children].each do |child|
          root child, indent, context
        end
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
        node[@children].each do |child|
          root child, indent, context
        end
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
      variables = node[@value][0].clone

      # The each structure accept missing arguments as well, therefore we need to
      # substitute them with our defaults
      #
      # each in iterable
      # each value in iterable
      # each key, value in iterable

      # Value argument name provided only
      if variables.length == 1
        variables.unshift Settings::DefaultEachKey

      # Missing key and value arguments
      elsif variables.empty?
        variables[0] = Settings::DefaultEachKey
        variables[1] = Settings::DefaultEachValue
      end

      # Selectively iterate through the input and add the result using the previously
      # defined proc object
      buffer_eval "_send_method = (#{node[@value][1]}.is_a?(Array) ? :each_with_index : :each)"
      buffer_eval "#{node[@value][1]}.send _send_method do |#{variables[0]}, #{variables[1]}|"
      node[@children].each do |child|
        root child, indent, context
      end
      buffer_eval "end"
    end
  end
end
