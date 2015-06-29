require_relative 'parser/root.rb'
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
      @@type = 0
      @@value = 1
      @@attributes = 2
      @@children = 3
      @@indent = 4

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

        # Node definitions encountered up to the current point
        @definitions = {}

        # Current line index
        @i = 0

        # Initialize root node
        @root = [:root, nil, nil, [], -1]

        puts "Nodes:\n---"
        pp root @root
        puts "\nDefinitions:\n---"
        pp @definitions
      end

      # Accept and consume or reject a given token as long as we have tokens
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



      # Parse the current line of code, by matching each regular expression
      # from the tokens list
      #
      # All nodes follow the create convention
      # [:node_type, :value, :attributes, :children, :indent]
      #
      #
      def parse_line(parent, min_indent = nil)
        # Add current indentation to the indent stack
        indent = consume(:indent).size

        # Advance to the next line, unless this has already been done due to
        # node specific processing
        advance = true

        # Stop processing for current parent if we have a min_indent variable
        return nil if min_indent && indent <= min_indent

        # Try the main Opulent node types and process each one of them using
        # their matching evaluation procedure

        # Definition
        #
        if(match = consume :def)
          # Process data
          name = consume(:node, :*).to_sym
          advance = false; @i += 1

          # Create node
          definition = [:def, name, attributes, [], indent]
          parse_lines(definition, indent)

          # Add to parent
          @definitions[name] = definition

        # Node
        #
        elsif(match = consume :node)
          # Process data
          match = match.to_sym

          # Create node
          node = [:node, match, attributes, [], indent]
          parse_lines(node, indent)

          parent[@@children] << node

        # Text
        #
        elsif(match = consume :text)
          parent[@@children] << [:text, indent, match]
        else
          error :unknown_node_type
        end

        # Increment current line pointer
        @i += 1 if advance

        return true
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
