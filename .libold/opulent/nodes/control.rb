# @Opulent
module Opulent
  # @Nodes
  module Nodes
    # @CnditionalControl
    #
    # Control structure for if-elsif-else and unless
    #
    class CnditionalControl
      attr_accessor :name, :value, :parent, :indent, :children

      # Ruby code evaluation node
      #
      # @param name [String] name of the html node
      # @param value [String] condition to be met
      # @param parent [Node] parent of the element
      # @param indent [Fixnum] node indentation for restructuring
      # @param children [Array] contents to be interpreted
      #
      def initialize(name = '', value = '', parent = nil, indent = 0, children = [[]])
        @name = name
        @value = [value]
        @parent = parent
        @indent = indent
        @children = children
      end

      # Add a new node to the nodes array
      #
      def push(node)
        @children[-1] << node
        self
      end

      # Node evaluation method which goes through all the child nodes and evaluates
      # them using their own eval method
      #
      def evaluate(context)
        index = @value.index do |value|
          value.empty? || context.evaluate(value)
        end

        if index
          @children[index].map do |child|
            child.evaluate context
          end
        end
      end
    end

    # @IfControl
    #
    # Control structure for if-elsif-else directive
    #
    class CaseControl
      attr_accessor :name, :case, :value, :parent, :indent, :children

      # Ruby code evaluation node
      #
      # @param name [String] name of the html node
      # @param value [String] condition to be met
      # @param parent [Node] parent of the element
      # @param indent [Fixnum] node indentation for restructuring
      # @param children [Array] contents to be interpreted
      #
      def initialize(name = '', switch_case = '', parent = nil, indent = 0, children = [[]])
        @name = name
        @case = switch_case
        @value = []
        @parent = parent
        @indent = indent
        @children = children
      end

      # Add a new node to the nodes array
      #
      def push(node)
        @children[-1] << node
        self
      end

      # Node evaluation method which goes through all the child nodes and evaluates
      # them using their own eval method
      #
      def evaluate(context)
        switch_case = context.evaluate @case
        index = @value.index do |value|
          value.empty? || switch_case == context.evaluate(value)
        end

        if index
          @children[index].map do |child|
            child.evaluate context
          end.flatten.compact
        end
      end
    end

    # @LoopControl
    #
    # Control structure for while and until directives
    #
    class LoopControl
      attr_accessor :name, :value, :parent, :indent, :children

      # Ruby code evaluation node
      #
      # @param name [String] name of the html node
      # @param value [String] condition to be met
      # @param parent [Node] parent of the element
      # @param indent [Fixnum] node indentation for restructuring
      # @param children [Array] contents to be interpreted
      #
      def initialize(name = '', value = '', parent = nil, indent = 0, children = [])
        @name = name
        @value = value
        @parent = parent
        @indent = indent
        @children = children
      end

      # Add a new node to the nodes array
      #
      def push(node)
        @children << node
        self
      end

      # Node evaluation method which goes through all the child nodes and evaluates
      # them using their own eval method
      #
      def evaluate(context)
        result = []

        evaluate_children = Proc.new do |context|
          result << @children.map do |child|
            child.evaluate context
          end.flatten
        end

        case @name
        when :while
          while context.evaluate @value
            evaluate_children[context]
          end
        when :until
          until context.evaluate @value
            evaluate_children[context]
          end
        end

        return result.flatten.compact
      end
    end

    # @EachControl
    #
    # Control structure for while and until directives
    #
    class EachControl < LoopControl
      # Node evaluation method which goes through all the child nodes and evaluates
      # them using their own eval method
      #
      def evaluate(context)
        result = []

        # Process named variables for each structure
        variables = @value[0].clone

        # The each structure accept missing arguments as well, therefore we need to
        # substitute them with our defaults
        #
        # each in iterable
        # each value in iterable
        # each key, value in iterable

        # Value argument name provided only
        if variables.length == 1
          variables.unshift Engine[:each][:default_key]

        # Missing key and value arguments
        elsif variables.empty?
          variables[0] = Engine[:each][:default_key]
          variables[1] = Engine[:each][:default_value]
        end

        # Evaluate in current context and add to results
        evaluate_children = Proc.new do |key, value, context|
          # Update the local variables in the each context with the values from the
          # current loop iteration
          locals = {
            variables[0] => key,
            variables[1] => value
          }
          context.extend_context locals

          # Add the mapped child elements
          result << @children.map do |child|
            child.evaluate context
          end.flatten
        end

        # Create a new context based on the parent context and progressively update
        # variables in the new context
        each_context = Context.new({}, context.binding.clone)

        # Evaluate the iterable object
        enumerable = each_context.evaluate(@value[1])

        # Check if input can be iterated
        Runtime.error :enumerable, @value[1] unless enumerable.respond_to? :each

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

        return result.flatten.compact
      end
    end
  end
end
