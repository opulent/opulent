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
        # Setup convention accessors
        @type = 0
        @value = 1
        @options = 2
        @children = 3
        @indent = 4

        # Create the HTML Entities encoder/decoder
        @entities = HTMLEntities.new

        # Get special node types from the settings
        @multi_node = Settings::MultiNode
        @inline_node = Settings::InlineNode

        # The node stack is needed to keep track of all the visited nodes
        # from the current branch level
        @node_stack = []

        # The sibling stack keeps track of the sibling count from the current
        # branch level being generated
        @sibling_stack = []
      end

      # Compile input nodes, replace them with their definitions and
      #
      # @param root [Array] Root node containing all document nodes
      # @param context [Context] Context holding environment variables
      #
      def compile(root, context)
        # Compiler generated code
        @code = ""
        @generator = ""

        # Set initial parent, from which we start generating code
        @sibling_stack << root[@children].size

        # Start building up the code from the root node
        root[@children].each do |node|
          generate node, 0, context
        end

        return @code
      end

      private
      # Generate code for all nodes by calling the method with their type name
      #
      # @param current [Array] Current node data with options
      # @param indent [Fixnum] Indentation size for current node
      # @param context [Context] Context holding environment variables
      #
      def generate(current, indent, context)
        send current[@type], current, indent, context
      end

      # Escape a given input value using htmlentities
      #
      # @param value [String] String to be escaped
      #
      def escape(value)
        @entities.encode value
      end

      # Remove the last newline from the current code buffer
      #
      def remove_trailing_newline
        @code.chop! if @code[-1] == "\n"
      end

      # Indent all lines of the input text using give indentation
      #
      # @param text [String] Input text to be indented
      # @param indent [String] Indentation string to be appended
      #
      def indent_lines text, indent
        text.lines.inject("") do |result, line|
          result += indent + line
        end
      end

      # def push(string)
      #   "#{Buffer} << #{string.inspect}"
      # end
    end
  end
end
