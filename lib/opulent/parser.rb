require_relative 'parser/root.rb'
require_relative 'parser/define.rb'
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
        @type = 0
        @value = 1
        @attributes = 2
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
        # puts "Nodes:\n---"
        # pp @nodes
        # puts "\nDefinitions:\n---"
        # pp @definitions
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

      # Check if the lookahead matches the chosen regular expression
      #
      # @param token [RegEx] Token to be checked by the parser
      #
      def lookahead(token)
        # Check if we match the token to the current line.
        @line[@offset..-1].match Tokens[token]
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
          data[0] = "#{Tokens[data[0]]}"[11..-3] if [:'(', :'{', :'[', :'<'].include? data[0]

          "Expected to find a :#{data[0]} token at: \n\n#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
        end
        # Reconstruct lines to display where errors occur
        fail "\n\nOpulent " + Logger.red("[Parser Error]") +
        "\n---\n" +
        "#{message}\n\n\n"
      end
    end
  end
end
