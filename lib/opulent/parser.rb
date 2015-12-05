# require_relative 'parser/comment.rb'
# require_relative 'parser/control.rb'
# require_relative 'parser/define.rb'
# require_relative 'parser/doctype.rb'
# require_relative 'parser/eval.rb'
require_relative 'parser/expression.rb'
# require_relative 'parser/filter.rb'
require_relative 'parser/node.rb'
# require_relative 'parser/include.rb'
require_relative 'parser/root.rb'
require_relative 'parser/text.rb'
# require_relative 'parser/yield.rb'

# @Opulent
module Opulent
  # @Parser
  class Parser
    attr_reader :type, :value, :options, :children, :indent, :definitions

    # All node Objects (Array) must follow the next convention in order
    # to make parsing faster
    #
    # [:node_type, :value, :attributes, :children, :indent]
    #
    def initialize(settings = {})
      # Convention accessors
      @type = 0
      @value = 1
      @options = 2
      @children = 3
      @indent = 4

      # Inherit settings from Engine
      @settings = settings

      # Set current compiled file as the first in the file stack together with
      # its base indentation. The stack is used to allow include directives to
      # be used with the last parent path found
      @file = [[@settings.delete(:file), -1]]

      # Create a definition stack to disallow recursive calls. When inside a
      # definition and a named node is called, we render it as a plain node
      @definition_stack = []

      # Initialize definitions for the parser
      @definitions = @settings.delete(:def) || {}
    end

    # Initialize the parsing process by splitting the code into lines and
    # instantiationg parser variables with their default values
    #
    # @param code [String] Opulent code that needs to be analyzed
    #
    # @return Nodes array
    #
    def parse(code)
      # Split the code into lines and parse them one by one
      @code = code.lines

      # Current line index
      @i = -1

      # Current character index
      @j = 0

      # Initialize root node
      @root = [:root, nil, {}, [], -1]

      # Get all nodes starting from the root element and return output
      # nodes and definitions
      root @root

      [@root, @definitions]
    end

    # Check and accept or reject a given token as long as we have tokens
    # remaining. Shift the code with the match length plus any extra character
    # count around the capture group
    #
    # @param token [RegEx] Token to be accepted by the parser
    # @param required [Boolean] Expect the given token syntax
    # @param strip [Boolean] Left strip the current code to remove whitespace
    #
    def accept(token, required = false, strip = false)
      # Consume leading whitespace if we want to ignore it
      accept :whitespace if strip

      # We reached the end of the parsing process and there are no more lines
      # left to parse
      return nil unless @line

      # Match the token to the current line. If we find it, return the match.
      # If it is required, signal an :expected error
      if (match = @line[@offset..-1].match(Tokens[token]))
        # Advance current offset with match length
        @offset += match[0].size
        @j += match[0].size

        return match[0]
      elsif required
        Logger.error :parse, @code, @i, @j, :expected, token
      end
    end

    # Helper method which automatically sets the stripped options to true,
    # so that we do not have to explicitly specify it
    #
    # @param token [RegEx] Token to be accepted by the parser
    # @param required [Boolean] Expect the given token syntax
    #
    def accept_stripped(token, required = false)
      accept(token, required, true)
    end

    # Check if the lookahead matches the chosen regular expression
    #
    # @param token [RegEx] Token to be checked by the parser
    #
    def lookahead(token)
      return nil unless @line

      # Check if we match the token to the current line.
      @line[@offset..-1].match Tokens[token]
    end

    # Check if the lookahead matches the chosen regular expression on the
    # following line which needs to be parsed
    #
    # @param token [RegEx] Token to be checked by the parser
    #
    def lookahead_next_line(token)
      return nil unless @code[@i + 1]

      # Check if we match the token to the current line.
      @code[@i + 1].match Tokens[token]
    end

    # Undo a found match by removing the token from the consumed code and
    # adding it back to the code chunk
    #
    # @param match [String] Matched string to be undone
    #
    def undo(match)
      return if match.empty?
      @offset -= match.size
      nil
    end

    # Allow expressions to continue on a new line in certain conditions
    #
    def accept_newline
      return unless @line[@offset..-1].strip.empty?
      @line = @code[(@i += 1)]
      @j = 0
      @offset = 0
    end

    # Indent all lines of the input text using give indentation
    #
    # @param text [String] Input text to be indented
    # @param indent [String] Indentation string to be appended
    #
    def indent_lines(text, indent)
      text ||= ''
      text.lines.map { |line| indent + line }.join
    end
  end
end
