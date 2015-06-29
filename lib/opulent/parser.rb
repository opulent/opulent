require_relative 'parser/node.rb'

# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Singleton
    class << self
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

        # Initial definition theme (namespace)
        @theme = DefaultTheme

        # Node definitions encountered up to the current point
        @definitions = {
          @theme => {}
        }

        # Current line index
        @i = 0

        # Set initial

        puts "Nodes:\n---"
        pp parse_lines
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
      def consume(token, required = false, strip = false)
        # Consume leading whitespace if we want to ignore it
        consume :whitespace if strip

        # Match the token to the current line. If we find it, return the match.
        # If it is required, signal an :expected error
        if (match = @line[@offset..-1].match(Tokens[token]))
          # Advance current offset with match length
          @offset += match[0].size

          return match[0]
        end
      end

      # Analyze the input code and check for matching tokens.
      # In case no match was found, throw an exception.
      # In special cases, modify the token hash.
      #
      # @param nodes [Array] Parent node to which we append to
      #
      def parse_lines(min_indent = nil)
        # Array containing parsed nodes
        nodes = []

        # Matching indentation for each parsed node
        indents = []

        while(@line = @code[@i])
          # Skip to next iteration if we have a blank line
          if @line =~ /\A\s*\Z/ then @i += 1; next; end

          # Reset the line offset
          @offset = 0

          # Parse the current line by trying to match each node type towards it
          node = parse_line nodes, min_indent

          # If the indentation is smaller or equal to the minimum, we break
          # the current operation
          break unless node
        end

        return nodes
      end

      # Parse the current line of code, by matching each regular expression
      # from the tokens list
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
        if(match = consume :def)
          name = consume(:node, :*).to_sym
          advance = false

          @i += 1
          @definition = name
          @definitions[@theme][name] = [name, attributes, parse_lines(indent)]
        elsif(match = consume :theme)
          name = consume(:node, :*).to_sym
          advance = false

          @i += 1
          @theme = name
          @definitions[@theme] = {}
        elsif(match = consume :node)
          parent << [:node, match.to_sym, attributes, indent]
        elsif(match = consume :text)
          parent << [:text, match, indent]
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
