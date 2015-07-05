require_relative 'compiler/node.rb'
require_relative 'compiler/text.rb'
require_relative 'compiler/comment.rb'

# @Opulent
module Opulent
  # @Compiler
  module Compiler
    Buffer = :_buffer

    # @Singleton
    class << self
      # All node Objects (Array) must follow the next convention in order
      # to make parsing faster
      #
      # [:node_type, :value, :attributes, :children, :indent]
      #
      def setup
        @type = 0
        @value = 1
        @options = 2
        @children = 3
        @indent = 4

        @multi_node = Settings::MultiNode
        @inline_node = Settings::InlineNode

        @node_stack = []
      end

      # Compile input nodes, replace them with their definitions and
      #
      def compile(root, context)
        # Compiler generated code
        @code = ""
        @generator = ""

        # Start building up the code from the root node
        root[@children].each do |node|
          generate node, 0, context
        end

        return @code
      end

      private

      def generate(current, indent, context)
        case current[@type]
        # Generate code for static nodes, by appending their name and
        # evaluating the node's attributes
        when :node
          node(current, indent, context)
        when :text, :print
          text(current, indent, context)
        when :comment
          comment(current, indent, context)
        end
      end

      def remove_trailing_newline
        @code = @code[0..-2] if @code[-1] == "\n"
      end

      def indent_lines text, indent
        text.lines.inject("") do |result, line|
          result += indent + line
        end
      end

      def push(string)
        "#{Buffer} << #{string.inspect}"
      end
    end
  end
end
