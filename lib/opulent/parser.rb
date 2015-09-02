require_relative 'parser/block.rb'
require_relative 'parser/comment.rb'
require_relative 'parser/control.rb'
require_relative 'parser/define.rb'
require_relative 'parser/doctype.rb'
require_relative 'parser/eval.rb'
require_relative 'parser/expression.rb'
require_relative 'parser/filter.rb'
require_relative 'parser/node.rb'
require_relative 'parser/include.rb'
require_relative 'parser/root.rb'
require_relative 'parser/text.rb'

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
    def initialize(file, definitions)
      # Convention accessors
      @type = 0
      @value = 1
      @options = 2
      @children = 3
      @indent = 4

      # Set current compiled file as the first in the file stack together with
      # its base indentation. The stack is used to allow include directives to
      # be used with the last parent path found
      @file = [[file, -1]]

      # Initialize definitions for the parser
      @definitions = definitions
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

      # Initialize root node
      @root = [:root, nil, {}, [], -1]

      # Get all nodes starting from the root element and return output
      # nodes and definitions
      root @root

      return @root, @definitions
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
    # @param message [Symbol] Error message to display to the user
    #
    def error(error, *data)
      message = case error
      when :unknown_node_type
        "An unknown node type has been encountered at:\n\n#{Logger.red @line}"
      when :expected
        data[0] = "#{Tokens.bracket data[0]}" if [:'(', :'{', :'[', :'<'].include? data[0]
        "Expected to find a :#{data[0]} token on line #{@i+1} of input at: \n\n#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :root
        "Unknown node type encountered on line #{@i+1} of input at:\n\n" +
        "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :assignments_colon
        "Unexpected end of element attributes reached on line #{@i+1} of input.\n\n" +
        "Expected to find an attribute at:\n\n" +
        "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :assignments_comma
        "Unexpected end of element attributes reached on line #{@i+1} of input.\n\n" +
        "Expected to find an attribute value at:\n\n" +
        "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :expression
        "Unexpected end of expression reached on line #{@i+1} of input.\n\n" +
        "Expected to find another expression term at:\n\n" +
        "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :control_child
        "Unexpected control structure child found on line #{@i+1} of input.\n\n" +
        "Expected to find a parent #{data[0]} structure at:\n\n" +
        "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :case_children
        "Unexpected control structure child found on line #{@i+1} of input.\n\n" +
        "Case structure cannot have any child elements at:\n\n" +
        "#{@code[@i-1][0..@offset-1]}#{Logger.red @code[@i][@offset..-1].rstrip}"
      when :whitespace_expression
        "Unexpected end of expression reached on line #{@i+1} of input.\n\n" +
        "Please use paranthesis for method parameters at:\n\n" +
        "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :definition
        "Unexpected start of definition on line #{@i+1} of input.\n\n" +
        "Found a definition inside another definition or element at:\n\n" +
        "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :self_enclosing
        "Unexpected content found after self enclosing node on line #{@i+1} of input at:\n\n" +
        "#{@line[0..@offset-1]}#{Logger.red @line[@offset..-1].rstrip}"
      when :self_enclosing_children
        "Unexpected child elements found for self enclosing node on line #{data[0]+1} of input at:\n\n" +
        "#{@code[data[0]]}#{Logger.red @code[data[0] + 1]}"
      when :include
        "The included file #{data[0]} does not exist or an incorrect path has been specified."
      when :include_dir
        "The included file path #{data[0]} is a directory."
      when :include_end
        "Missing argument for include on line #{@i+1} of input at:\n\n" +
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
