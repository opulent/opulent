require_relative 'compiler/block.rb'
require_relative 'compiler/comment.rb'
require_relative 'compiler/control.rb'
require_relative 'compiler/define.rb'
require_relative 'compiler/eval.rb'
require_relative 'compiler/filter.rb'
require_relative 'compiler/node.rb'
require_relative 'compiler/root.rb'
require_relative 'compiler/text.rb'

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

        # Quick accessor for default yield constant
        @default_yield = Settings::DefaultYield

        # The node stack is needed to keep track of all the visited nodes
        # from the current branch level
        @node_stack = []

        # The sibling stack keeps track of the sibling count from the current
        # branch level being generated
        @sibling_stack = []

        # Whenever we enter a definition compilation, add the provided blocks to
        # the current block stack. When exiting a definition, remove blocks.
        @block_stack = []
      end

      # Compile input nodes, replace them with their definitions and
      #
      # @param root [Array] Root node containing all document nodes
      # @param context [Context] Context holding environment variables
      #
      def compile(root_node, context)
        # Compiler generated code
        @code = ""
        @generator = ""

        # Set initial parent, from which we start generating code
        @sibling_stack << root_node[@children].size

        # Start building up the code from the root node
        root_node[@children].each do |child|
          root child, 0, context
        end

        return @code
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

      # Give an explicit error report where an unexpected sequence of tokens
      # appears and give indications on how to solve it
      #
      # @param context [Symbol] Context name in which the error happens
      # @param data [Array] Additional error information
      #
      def error(context, *data)
        message = case context
        when :enumerable
          "The provided each structure iteration input \"#{data[0]}\" is not Enumerable."
        when :binding
          data[0] = data[0].to_s.match(/\`(.*)\'/)
          data[0] = data[0][1] if data[0]
          "Found an undefined local variable or method \"#{data[0]}\" at \"#{data[1]}\"."
        when :variable_name
          data[0] = data[0].to_s.match(/\`(.*)\'/)[1]
          "Found an undefined local variable or method \"#{data[0]}\" in locals."
        when :extension
          "The extension sequence \"#{data[0]}\" is not a valid attributes extension. " +
          "Please use a Hash to extend attributes."
        when :filter_registered
          "The \"#{data[0]}\" filter could not be recognized by Opulent."
        when :filter_load
          "The gem required for the \"#{data[0]}\" filter is not installed. You can install it by running:\n\n#{data[1]}"
        end

        # Reconstruct lines to display where errors occur
        fail "\n\nOpulent " + Logger.red("[Runtime Error]") + "\n---\n" +
        "A runtime error has been encountered when building the compiled node tree.\n" +
        "#{message}\n\n\n"
      end
    end
  end
end