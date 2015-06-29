require_relative 'parser/root'
require_relative 'parser/node'
require_relative 'parser/eval'
require_relative 'parser/expression'
require_relative 'parser/define'
require_relative 'parser/text'
require_relative 'parser/filter'
require_relative 'parser/control'
require_relative 'parser/theme'
require_relative 'parser/block'
require_relative 'parser/comment'

# @Opulent
module Opulent
  # @Lexer
  module Parser
    # @Singleton
    class << self
      # Include Opulent tokens regular expressions to be checked using the
      # accept (or expect) method together with lookahead expressions
      include Root
      include Node
      include Expression
      include Evaluate
      include Define
      include Text
      include Filter
      include Control
      include Theme
      include Block
      include Comment

      # Analyze the input code and check for matching tokens.
      # In case no match was found, throw an exception.
      # In special cases, modify the token hash.
      #
      # @param code [String] Opulent code that needs to be analyzed
      # @return Nodes array
      #
      def parse(code)
        # Code to be parsed
        @code = code

        # Keeps track of consumed code
        @consumed = ""

        # Current line being parsed, used for error reporting
        @current_line = 1

        # Node creation wrapper for comprehensible node creation
        @create = Nodes::Helper.new

        # Create root node, our wrapper for all the HTML elements we use
        # which knows how to evaluate each of them to output the final code
        # The root also stores custom node definitions collection from which we
        # replace the nodes which use them
        @root = @create.root

        # Loop until we have no tokens left to parse or we find an error
        root @root

        # We still have code left to parse
        error :root unless @code.strip.empty?

        return @root
      end

      # Accept and consume or reject a given token as long as we have tokens
      # remaining. Shift the code with the match length plus any extra character
      # count around the capture group
      #
      # @param identifier [RegEx] Token syntax to be accepted by the parser
      # @param required [Boolean] Expect the given token syntax
      # @param strip [Boolean] Left strip the current code to remove whitespace
      #
      def accept(identifier, required = false, strip = true)
        # Get token from tokens knowledgebase
        token = Tokens[identifier]

        # If the token's capture group is smaller than the whole match,
        # advance the code chunk with more spaces
        extra = token[:extra] || 0

        # Remove leading whitespace between expressions
        if @code && strip
          if (stripped = @code[/\A +/]) then @consumed += stripped end
          @code.lstrip!
        end

        # Check to see if
        if @code =~ token[:regex]
          @current_line += 1 if identifier == :newline

          shift = $1.size + extra

          @consumed += @code[0..shift - 1] if shift > 0
          @code = @code[shift..-1]

          return $1
        elsif required
          error :expect, identifier
        else
          return nil
        end
      end

      # Accept and consume or reject a given token as long as we have tokens
      # remaining on the current line only. Shift the code with the match length
      # plus any extra character count around the capture group
      #
      # @param identifier [RegEx] Token syntax to be accepted by the parser
      # @param required [Boolean] Expect the given token syntax
      # @param strip [Boolean] Left strip the current code to remove whitespace
      #
      def accept_line(identifier, required = false, strip = true)
        # Get token from tokens knowledgebase
        token = Tokens[identifier]

        # If the token's capture group is smaller than the whole match,
        # advance the code chunk with more spaces
        extra = token[:extra] || 0

        # Remove leading whitespace between expressions
        if @code.lines.first && strip
          if (stripped = @code.lines.first[/\A +/]) then @consumed += stripped end
          @code.gsub! /\A +/, ''
        end

        # Check to see if
        if @code.lines.first =~ token[:regex]
          @current_line += 1 if identifier == :newline

          shift = $1.size + extra

          @consumed += @code[0..shift - 1] if shift > 0
          @code = @code[shift..-1]

          return $1
        elsif required
          error :expect, identifier
        else
          return nil
        end
      end

      # Wrapper method for accepting unstripped tokens such as whitespace or a
      # certain required sequence directly
      #
      # @param identifier [RegEx] Token syntax to be accepted by the parser
      # @param required [Boolean] Expect the given token syntax
      #
      def accept_unstripped(identifier, required = false)
        accept(identifier, required, false)
      end

      # Wrapper method for accepting unstripped tokens such as whitespace or a
      # certain required sequence directly on the current line only
      #
      # @param identifier [RegEx] Token syntax to be accepted by the parser
      # @param required [Boolean] Expect the given token syntax
      #
      def accept_line_unstripped(identifier, required = false)
        accept_line(identifier, required, false)
      end

      # Look ahead in the current code to see if we can match an input token.
      # No modifications will be done to the code.
      #
      # @param token [RegEx] Token syntax to be accepted by the parser
      # @param strip [Boolean] Left strip the current code to remove whitespace
      #
      def lookahead(token, strip = true)
        # Get token from tokens knowledgebase
        token = Tokens[token]

        # We don't want to modify anything in the code directly, so we use a
        # local code variable
        code = @code

        # Remove leading whitespace between expressions
        code = code.lstrip if code && strip

        # Check to see if
        if code =~ token[:regex]
          return $~[:capture]
        else
          return nil
        end
      end

      # Undo a found match by removing the token from the consumed code and
      # adding it back to the code chunk
      #
      # @param match [String] Matched string to be undone
      #
      def undo(match)
        unless match.empty?
          @consumed = @consumed[0..-match.length]
          @code = match + @code
          return nil
        end
      end

      # Give an explicit error report where an unexpected sequence of tokens
      # appears and give indications on how to solve it
      #
      # @param context [Symbol] Context name in which the error happens
      # @param data [Array] Additional error information
      #
      def error(context, *data)
        consumed = @consumed.lines.last.strip if @consumed.lines.last
        code = @code.empty? ? ' END' : @code.lines.first.strip

        message = case context
        when :root
          "Unknown node type encountered on line #{@current_line} of input at:\n\n" +
          "#{consumed}" + Logger.red(code)
        when :expect
          "Expected to find token :#{data[0]} on line #{@current_line} of input at:\n\n" +
          "#{consumed}" + Logger.red(code)
        when :assignments_colon
          "Unexpected end of element attributes reached on line #{@current_line} of input.\n\n" +
          "Expected to find an attribute at:\n\n" +
          "#{consumed}" + Logger.red(code)
        when :assignments_comma
          "Unexpected end of element attributes reached on line #{@current_line} of input.\n\n" +
          "Expected to find an attribute value at:\n\n" +
          "#{consumed}" + Logger.red(code)
        when :expression
          "Unexpected end of expression reached on line #{@current_line} of input.\n\n" +
          "Expected to find another expression term at:\n\n" +
          "#{consumed}" + Logger.red(code)
        when :whitespace_expression
          "Unexpected end of expression reached on line #{@current_line} of input.\n\n" +
          "Please use paranthesis for method parameters at:\n\n" +
          "#{consumed}" + Logger.red(code)
        when :definition
          "Unexpected start of definition on line #{@current_line - 1} of input.\n\n" +
          "Found a definition inside another definition or element at:\n\n" +
          (@consumed.lines[-2] || "") + Logger.red(consumed + "\n  " + code)
        else
          "#{consumed}" + Logger.red(code)
        end

        # Reconstruct lines to display where errors occur
        fail "\n\nOpulent " + Logger.red("[Parser Error]") + "\n---\n" +
        "A parsing error has been encountered in the \"#{context}\" context.\n" +
        "#{message}\n\n\n"
      end
    end
  end
end
