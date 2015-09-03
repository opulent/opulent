require_relative 'compiler/block.rb'
require_relative 'compiler/comment.rb'
require_relative 'compiler/control.rb'
require_relative 'compiler/define.rb'
require_relative 'compiler/doctype.rb'
require_relative 'compiler/eval.rb'
require_relative 'compiler/filter.rb'
require_relative 'compiler/node.rb'
require_relative 'compiler/root.rb'
require_relative 'compiler/text.rb'

# @Opulent
module Opulent
  # @Compiler
  class Compiler
    Buffer = :_buf

    # All node Objects (Array) must follow the next convention in order
    # to make parsing faster
    #
    # [:node_type, :value, :attributes, :children, :indent]
    #
    # @param path [String] Current file path needed for include nodes
    #
    def initialize
      # Setup convention accessors
      @type = 0
      @value = 1
      @options = 2
      @children = 3
      @indent = 4

      # Get special node types from the settings
      @multi_node = Settings::MultiNode
      @inline_node = Settings::InlineNode

      # Quick accessor for default yield constant
      @default_yield = Settings::DefaultYield

      # Initialize amble object
      @template = [[:preamble]]

      # Incrmental attribute count
      @current_attribute = 0

      # Incrmental extension count
      @current_extension = 0

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
    # @param root_node [Array] Root node containing all document nodes
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

      @template << [:postamble]

      return templatize
    end





    def format_string(string, buffer_escape)
      until string.empty?
        case string
        # Process interpolation part of the string
        when /^\#\{(.*)\}/
          result = $1
          if buffer_escape
            buffer_escape result
          else
            buffer_buffer result
          end
          string = string[result.length + 3..-1]

        # Process string up to interpolation part and check if it's HTML safe.
        # If it is, then we render it as buffer text, otherwise we escape it.
        when /^((.|\s)*)(?<!\\)\#\{.*\}/
          result = $1
          if buffer_escape
            result =~ Utils::EscapeHTMLPattern ? buffer_escape(result) : buffer_freeze(result)
          else
            buffer_freeze result
          end
          string = string[result.length..-1]

        else
          result = string
          if buffer_escape
            result =~ Utils::EscapeHTMLPattern ? buffer_escape(result) : buffer_freeze(result)
          else
            buffer_freeze result
          end
          string = ""
        end
      end
    end

    def buffer(string)
      @template << [:buffer, string]
    end

    def buffer_escape(string)
      @template << [:escape, string]
    end

    def buffer_freeze(string)
      if @template[-1][0] == :freeze
        @template[-1][1] += string
      else
        @template << [:freeze, string]
      end
    end

    def buffer_eval(string)
      @template << [:eval, string]
    end


    def templatize
      @template.inject("") do |buffer, input|
        buffer += case input[0]
        when :preamble
          "#{Buffer} = []\n"
        when :buffer
          "#{Buffer} << (#{input[1]})\n"
        when :escape
          "#{Buffer} << (::Opulent::Utils::escape(#{input[1]}))\n"
        when :freeze
          "#{Buffer} << (#{input[1].inspect}.freeze)\n"
        when :eval
          "#{input[1]}\n"
        when :postamble
          "#{Buffer}.join"
        end
      end
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
    def indent_lines(text, indent)
      text ||= ""
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
    def self.error(context, *data)
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
