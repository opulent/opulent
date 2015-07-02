require_relative 'parser/root.rb'
require_relative 'parser/define.rb'
require_relative 'parser/expression.rb'
require_relative 'parser/node.rb'

# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Singleton
    class << self
      # All node Objects (Array) must follow the next convention in order
      # to make parsing faster
      #
      # [:node_type, :value, :attributes, :children, :indent]
      #
      # Initialize the parsing process by splitting the code into lines and
      # instantiationg parser variables with their default values
      #
      # @param code [String] Opulent code that needs to be analyzed
      #
      # @return Nodes array
      #
      def parse(code)
        # Convention
        # [:node_type, :value, :options, :children, :indent, :options]
        @type = 0
        @value = 1
        @options = 2
        @children = 3
        @indent = 4

        # Split the code into lines and parse them one by one
        @code = code.lines

        # Node definitions encountered up to the current point
        @definitions = {}

        # Current line index
        @i = 0

        # Initialize root node
        @root = [:root, nil, nil, [], -1]

        @nodes = root @root
        puts "Nodes:\n---"
        pp @nodes
        puts "\nDefinitions:\n---"
        pp @definitions
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

          return match[0]
        elsif required
          error :expected, token
        end
      end

      # Helper method which automatically sets the stripped options to true, so that we
      # do not have to explicitly specify it
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
        # Check if we match the token to the current line.
        @line[@offset..-1].match Tokens[token]
      end

      # Undo a found match by removing the token from the consumed code and
      # adding it back to the code chunk
      #
      # @param match [String] Matched string to be undone
      #
      def undo(match)
        unless match.empty?
          @offset -= match.size
          return nil
        end
      end

      # Allow expressions to continue on a new line in certain conditions
      #
      def accept_newline
        if @line[@offset..-1].strip.empty?
          @line = @code[(@i += 1)]
          @offset = 0
        end
      end

      # Give an explicit error report where an unexpected sequence of tokens
      # appears and give indications on how to solve it
      #
      # @param message [Symbol] Error message to display to the user
      #
      def error(error, *data)
        message = case error
        when :unknown_node_type
          "An unknown node type has been encountered at:\n\n#{Logger.red @line}"
        when :expected
          data[0] = "#{Tokens.bracket data[0]}" if [:'(', :'{', :'[', :'<'].include? data[0]
          "Expected to find a :#{data[0]} token at: \n\n#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        when :root
          "Unknown node type encountered on line #{@current_line} of input at:\n\n" +
          "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        when :assignments_colon
          "Unexpected end of element attributes reached on line #{@current_line} of input.\n\n" +
          "Expected to find an attribute at:\n\n" +
          "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        when :assignments_comma
          "Unexpected end of element attributes reached on line #{@current_line} of input.\n\n" +
          "Expected to find an attribute value at:\n\n" +
          "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        when :expression
          "Unexpected end of expression reached on line #{@current_line} of input.\n\n" +
          "Expected to find another expression term at:\n\n" +
          "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        when :whitespace_expression
          "Unexpected end of expression reached on line #{@current_line} of input.\n\n" +
          "Please use paranthesis for method parameters at:\n\n" +
          "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        when :definition
          "Unexpected start of definition on line #{@current_line - 1} of input.\n\n" +
          "Found a definition inside another definition or element at:\n\n" +
          "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        else
          "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        end

        # Reconstruct lines to display where errors occur
        fail "\n\nOpulent " + Logger.red("[Parser Error]") +
        "\n---\n" +
        "#{message}\n\n\n"
      end
    end
  end
end
