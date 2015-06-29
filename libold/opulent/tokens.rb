# @Opulent
module Opulent
  # @Tokens
  module Tokens
    # @Token
    #
    # Structure holding matching data for each Opulent token
    #
    # @param regex [RegEx] Regular expression for matching the token
    # @param extra [FixNum] Extra characters around the first capture group
    #
    Token = Struct.new :regex, :extra

    # @Singleton
    class << self
      # Token knowledgebase
      @@tokens = {}

      # Opulent Keywords
      KEYWORDS = %w(def theme block yield if else elsif unless case when each while until)

      def keyword(word)
        KEYWORDS.include? word
      end

      # Shorthand Attributes
      @@shorthand_lookahead = []
      Opulent::Engine[:shorthand].each do |key, value|
        @@tokens["shorthand@#{key}".to_sym] = Token.new /\A(#{value})/
        @@shorthand_lookahead << "#{value}[a-zA-Z\"(]"
      end

      # Node identifier
      @@tokens[:identifier] = Token.new /\A([a-zA-Z]([\-\_]?[a-zA-Z0-9]+)*)/
      @@tokens[:identifier_lookahead] = Token.new /\A([a-zA-Z]\w*\:\:)?(?<capture>([a-zA-Z]([\-\_]?[a-zA-Z0-9]+)*|#{@@shorthand_lookahead.join '|'}))/

      # Attribute lookahead
      @@tokens[:attribute_lookahead] = Token.new /\A([a-zA-Z]([\-\_]?[a-zA-Z0-9]+)*)/

      # Self enclosing nodes
      @@tokens[:self_enclosing] = Token.new /\A\/(.*)/, 1

      # Node assignments
      @@tokens[:assignment] = Token.new /\A(\:|\=)/
      @@tokens[:assignment_unescaped] = Token.new /\A(\~)/
      @@tokens[:assignment_terminator] = Token.new /\A((\,|\;)\s*)/
      @@tokens[:assignment_lookahead] = Token.new /\A *(?<capture>[a-zA-Z]([\-\_]?[a-zA-Z0-9]+)* *[\:\=])/

      # Node extension
      @@tokens[:extend_attributes] = Token.new /\A(\+)/

      # Node inline child
      @@tokens[:inline_child] = Token.new /\A(\>)/

      # Node output whitespace
      @@tokens[:leading_whitespace] = Token.new /\A(\<\-)/
      @@tokens[:leading_trailing_whitespace] = Token.new /\A(\>)/
      @@tokens[:trailing_whitespace] = Token.new /\A(\-\>)/

      # Comments
      @@tokens[:comment] = Token.new /\A\/(.*)/, 1
      @@tokens[:comment_lookahead] = Token.new /\A *(?<capture>\/)/

      # Intepreted filters
      @@tokens[:filter] = Token.new /\A\:([a-zA-Z]([\-\_]?[a-zA-Z0-9]+)*)/, 1
      @@tokens[:filter_lookahead] = Token.new /\A *\:(?<capture>[a-zA-Z]([\-\_]?[a-zA-Z0-9]+)*)/

      # Text
      @@tokens[:escaped_text] = Token.new /\A(.*)/
      @@tokens[:unescaped_text] = Token.new /\A\~(.*)/, 1

      # Print
      @@tokens[:escaped_print] = Token.new /\A\=(.*)/, 1
      @@tokens[:unescaped_print] = Token.new /\A\=\~(.*)/, 2
      @@tokens[:print_lookahead] = Token.new /\A *(?<capture>\=)/

      # Multiline Text
      @@tokens[:multiline] = Token.new /\A(\|)/

      # HTML Text
      @@tokens[:html_text] = Token.new /\A(\<.+\>.*)/

      # Definitions
      @@tokens[:def] = Token.new /\A(def +)/
      @@tokens[:def_lookahead] = Token.new /\A *(?<capture>def )/

      # Yield
      @@tokens[:yield] = Token.new /\A(yield)/
      @@tokens[:yield_lookahead] = Token.new /\A *(?<capture>yield)/
      @@tokens[:yield_identifier] = Token.new  /\A( +[a-zA-Z]([\_]?[a-zA-Z0-9]+)*)/

      # Yield
      @@tokens[:block] = Token.new /\A(block)/
      @@tokens[:block_lookahead] = Token.new /\A *(?<capture>block)/

      # Theme
      @@tokens[:theme] = Token.new /\A(theme +)/
      @@tokens[:theme_lookahead] = Token.new /\A *(?<capture>theme )/
      @@tokens[:theme_identifier] = Token.new /\A([a-zA-Z]\w*)/
      @@tokens[:theme_node] = Token.new /\A([a-zA-Z]\w*)\:\:/, 2

      # Conditional Structures
      @@tokens[:control] = Token.new /\A(if|elsif|else|unless|case|when|each|while|until)/
      @@tokens[:control_lookahead] = Token.new /\A *(?<capture>if|elsif|else|unless|case|when|each|while|until)/
      @@tokens[:each_pattern] = Token.new /\A(\w+( *, *\w+)? +)?in +.+/

      # Brackets
      @@tokens[:round_bracket_open] = Token.new /\A(\()/
      @@tokens[:round_bracket_close] = Token.new /\A(\))/
      @@tokens[:square_bracket_open] = Token.new /\A(\[)/
      @@tokens[:square_bracket_close] = Token.new /\A(\])/
      @@tokens[:curly_bracket_open] = Token.new /\A(\{)/
      @@tokens[:curly_bracket_close] = Token.new /\A(\})/
      @@tokens[:angular_bracket_open] = Token.new /\A(\<)/
      @@tokens[:angular_bracket_close] = Token.new /\A(\>)/

      # Receive matching brackets for allowing multiple bracket types for
      # element attributes
      @@tokens[:brackets] = Token.new /\A([\(\[\{])/
      @@tokens[:'('] = @@tokens[:round_bracket_close]
      @@tokens[:'['] = @@tokens[:square_bracket_close]
      @@tokens[:'{'] = @@tokens[:curly_bracket_close]
      @@tokens[:'<'] = @@tokens[:angular_bracket_close]

      # Terminators
      @@tokens[:comma] = Token.new /\A(\s*\,\s*)/
      @@tokens[:colon] = Token.new /\A(\s*\:\s*)/
      @@tokens[:semicolon] = Token.new /\A(\s*\;\s*)/

      # Array
      @@tokens[:array_open] = @@tokens[:square_bracket_open]
      @@tokens[:array_terminator] = @@tokens[:comma]
      @@tokens[:array_close] = @@tokens[:square_bracket_close]

      # Hash
      @@tokens[:hash_open] = @@tokens[:curly_bracket_open]
      @@tokens[:hash_terminator] = Token.new /\A(\s*(\,)\s*)/
      @@tokens[:hash_assignment] = Token.new /\A(\s*(\=\>)\s*)/
      @@tokens[:hash_symbol] = Token.new /\A([a-zA-Z\_][a-zA-Z0-9\_]*\:(?!\:))/
      @@tokens[:hash_close] = @@tokens[:curly_bracket_close]

      # Expressions
      @@tokens[:exp_context] = Token.new /\A(\$(.|\-.)?|\@|\@\@)/
      @@tokens[:exp_method_call] = Token.new /\A(\.[a-zA-Z\_][a-zA-Z0-9\_]*[\!\?]?)/
      @@tokens[:exp_module] = Token.new /\A(\:\:)/
      @@tokens[:exp_identifier] = Token.new /\A([a-zA-Z\_][a-zA-Z0-9\_]*[\!\?]?)/
      @@tokens[:exp_assignment] = Token.new /\A(\=)/
      @@tokens[:exp_operation] = Token.new /\A( *(\+|\-|\*\*|\*|\/|\<\<|\>\>|\.\.|\%|\<\=\>|\<\=|\^|\<|\>\=|\>|\=\~|\!\~|\=\=\=|\=\=|\=~|\!|not|\&\&|\&|and|\|\||\||or) *)/
      @@tokens[:exp_regex] = Token.new /\A(\/((?:[^\/\\]|\\.)*?)\/)/
      @@tokens[:exp_string] = Token.new /\A(("((?:[^"\\]|\\.)*?)")|('(?:[^'\\]|\\.)*?'))/
      @@tokens[:exp_percent] = Token.new /\A(\%[wWqQrxsiI]?.)/
      @@tokens[:exp_double] = Token.new /\A([0-9]+\.[0-9]+([eE][-+]?[0-9]+)?)/
      @@tokens[:exp_fixnum] = Token.new /\A([0-9]+)/
      @@tokens[:exp_nil] = Token.new /\A(nil)/
      @@tokens[:exp_boolean] = Token.new /\A(true|false)/
      @@tokens[:exp_ternary] = Token.new /\A( *\? *)/
      @@tokens[:exp_ternary_else] = Token.new /\A( *\: *)/

      # Expression identifier lookahead
      @@tokens[:exp_identifier_lookahead] = Token.new /\A(?<capture>[a-zA-Z\_][a-zA-Z0-9\_]*[\!\?]?)/

      # Evaluation
      @@tokens[:eval] = Token.new /\A\-(.*)/, 1
      @@tokens[:eval_multiline] = Token.new /\A\+(.*)/, 1

      # Whitespace
      @@tokens[:newline] = Token.new /\A(\n+)/
      @@tokens[:whitespace] = Token.new /\A( +)/
      @@tokens[:whitespace_lookahead] = Token.new /\A(?<capture> +)/

      # Indentation
      @@tokens[:indent] = Token.new /\A( *)/
      @@tokens[:indent_lookahead] = Token.new /\A\n?(?<capture> *)/

      # Feed
      @@tokens[:line_feed] = Token.new /\A(.*)/

      # Return the matching closing bracket
      #
      # @param bracket [String] Opening bracket for the capture group
      #
      def bracket(bracket)
        case bracket
        when '(' then return ')'
        when '[' then return ']'
        when '{' then return '}'
        when '<' then return '>'
        end
      end

      # Return the requested token to the parser
      #
      # @param name [Symbol] Token requested by the parser accept method
      #
      def [](name)
        @@tokens[name]
      end

      # Set a new token at runtime
      #
      # @param name [Symboidentifierl] Identifier for the token
      # @param token [Token] Token data to be set
      #
      def []=(name, token)
        @@tokens[name] = token
      end

      #
      # # Control structures
      # T_IF = /\A(if)/
      # T_ELSIF = /\A(elsif)/
      # T_ELSE = /\A(else)/
      # T_EACH = /\A(each)/
      # T_IN = /\A(in)/
      #
      # # Punctuation
      # T_COLON = /\A(\:)/
      # T_SEMICOLON = /\A(\;)/
      #
      # # Assignments terminator
      # T_TERMINATOR = /\A(\,|\;)/
      #
      # # Assignments identifier
      # T_ASSIGNMENT = /\A(\:|=)/
      #
      # # Paranthesis
      # T_SQUARE_BRACKET_OPEN = /\A(\[)/
      # T_SQUARE_BRACKET_CLOSE = /\A(\])/
      # T_CURLY_BRACKET_OPEN = /\A(\{)/
      # T_CURLY_BRACKET_CLOSE = /\A(\})/
      # T_PARANTHESIS_OPEN = /\A(\()/
      # T_PARANTHESIS_CLOSE = /\A(\))/
      #
      # # Embedded Ruby
      # T_RUBY_CONTEXT = /\A(\$[0-9]*?|\@|\@\@)/
      # T_RUBY_CONSTANT = /\A([a-zA-Z\_][a-zA-Z0-9\_]*)/
      # T_RUBY_INDEX = /\A(\[\s*\:?(([0-9]+)|([a-zA-Z\_][a-zA-Z0-9\-\_]*)|("((?:[^"\\]|\\.)*?)")|('(?:[^'\\]|\\.)*?')|(.+\.\..+))\s*\])/
      # T_RUBY_MODULES = /\A(\:\:[a-zA-Z\_][a-zA-Z0-9\_]*)/
      # T_RUBY_METHOD = /\A(\.[a-zA-Z\_][a-zA-Z0-9\_]*[\!\?]?)/
      #
      # # Literals
      # T_STRING = /\A(("((?:[^"\\]|\\.)*?)")|('(?:[^'\\]|\\.)*?'))/
      # T_DOUBLE = /\A([0-9]+\.[0-9]+([eE][-+]?[0-9]+)?)/
      # T_INTEGER = /\A([0-9]+)/
      # T_UNDEFINED = /\A(nil)/
      # T_BOOLEAN_TRUE = /\A(true)/
      # T_BOOLEAN_FALSE = /\A(false)/
      #
      # # Operation Signs
      # T_MULTIPLICATIVE = /\A(\*\*|\*|\/)/
      # T_ADDITIVE = /\A(\<\<|\+|\-)/
      # T_EQUALITY = /\A(\<\=|\<|\>\=|\>|\=\=)/
      # T_BOOLEAN_NOT = /\A(\!|not)/
      # T_BOOLEAN_AND = /\A(\&\&|and)/
      # T_BOOLEAN_OR = /\A(\|\||or)/
      #
      # # Operation Signs Lookahead
      # T_SIGN_LOOKAHEAD = /\A\*\*|\*|\/|\+|\-|\<\<|\<\=|\<|\>\=|\>|\=\=|\=|\!|not|\&\&|and|\|\||or/
      #
      # # Whitespace
      # T_WHITESPACE = /\A( +)/
      # T_NEWLINE = /\A(\n*)/
      # T_INDENT = /\A( *)/
      #
      # # Whitespace Lookahead
      # T_INDENT_LOOKAHEAD = /\A\n?( *)/
      #
      # # Line and char feeds
      # T_LINE_FEED = /\A(.*)/
      # T_CHAR_FEED = /\A([\s\S])/
      # T_UNESCAPED_TEXT = /\A\!(.*)/
      # T_UNESCAPED_MULTILINE_TEXT = /\A(\!\=)/
      # T_ESCAPED_MULTILINE_TEXT = /\A(\=)/
    end
  end
end
