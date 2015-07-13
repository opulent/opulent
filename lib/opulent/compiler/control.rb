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
      index = node[@value].index do |value|
        value.empty? || context.evaluate(value)
      end

      # If we have a branch that meets the condition, generate code for the
      # children related to that specific branch
      if index
        node[@children][index].each do |child|
          root child, indent, context
        end
      end
    end

    # Generate the code for a unless-else control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def unless_node(node, indent, context)
      # Check if we have any condition met, or an else branch
      index = node[@value].index do |value|
        value.empty? || !context.evaluate(value)
      end

      # If we have a branch that meets the condition, generate code for the
      # children related to that specific branch
      if index
        node[@children][index].each do |child|
          root child, indent, context
        end
      end
    end

    # Generate the code for a case-when-else control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def case_node(node, indent, context)
      # Evaluate the switching condition
      switch_case = context.evaluate node[@options][:condition]

      # Check if we have any condition met, or an else branch
      index = node[@value].index do |value|
        value.empty? || switch_case == context.evaluate(value)
      end

      # If we have a branch that meets the condition, generate code for the
      # children related to that specific branch
      if index
        node[@children][index].each do |child|
          root child, indent, context
        end
      end
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
      while context.evaluate node[@value]
        node[@children].each do |child|
          root child, indent, context
        end
      end
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
      until context.evaluate node[@value]
        node[@children].each do |child|
          root child, indent, context
        end
      end
    end

    # Generate the code for a while control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def each_node(node, indent, context)
      result = []

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

      # Evaluate in current context and add to results
      evaluate_children = Proc.new do |key, value, context|
        # Update the local variables in the each context with the values from the
        # current loop iteration
        locals = {
          variables[0] => key,
          variables[1] => value
        }
        context.extend_locals locals

        # Add the mapped child elements
        node[@children].each do |child|
          root child, indent, context
        end
      end

      # Create a new context based on the parent context and progressively update
      # variables in the new context
      block = context.block.clone if context.block
      each_context = Context.new Hash.new, &block
      each_context.parent = context

      # Evaluate the iterable object
      enumerable = context.evaluate(node[@value][1])

      # Check if input can be iterated
      self.error :enumerable, node[@value][1] unless enumerable.respond_to? :each

      # Selectively iterate through the input and add the result using the previously
      # defined proc object
      case enumerable
      when Hash
        enumerable.each do |key, value|
          evaluate_children[key, value, context]
        end
      else
        enumerable.each_with_index do |value, key|
          evaluate_children[key, value, context]
        end
      end
    end
  end
end
