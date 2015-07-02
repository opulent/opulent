module Opulent
  module Parser
    # Opulent Keywords
    Keywords = %w(def theme block yield if else elsif unless case when each while until)

    # Opulent Tokens
    class Tokens
      # All tokens available within Opulent
      #
      @@tokens = {
        # Indentation
        indent: /\A */,

        # Node
        node: /\A\w+(\-\w+)*/,
        node_lookahead: /\A(\w+(\-\w+)*)/,

        # Shorthand attributes
        shorthand: /\A[\.\#\&]/,
        shorthand_lookahead: /\A[\.\#\&][a-zA-Z\_\(\"]/,

        # Leading and trailing whitespace
        leading_whitespace: /\A(\<\-)/,
        leading_trailing_whitespace: /\A(\>)/,
        trailing_whitespace: /\A(\-\>)/,

        # Self enclosing node
        self_enclosing: /\A\/(.*)/,

        # Definition
        def: /\Adef +/,

        # Node Attributes
        attributes_bracket: /\A\(\[\{/,
        extend_attributes: /\A(\+)/,

        # Attribute assignments
        assignment: /\A(\:|\=)/,
        assignment_unescaped: /\A(\~)/,
        assignment_terminator: /\A((\,|\;)\s*)/,
        assignment_lookahead: /\A *([a-zA-Z]([\-\_]?[a-zA-Z0-9]+)* *[\:\=])/,

        # Node inline child
        inline_child: /\A(\>)/,

        # Comments
        comment: /\A\/(.*)/,
        comment_lookahead: /\A *\//,

        # Intepreted filters
        filter: /\A\:([a-zA-Z]([\-\_]?[a-zA-Z0-9]+)*)/,
        filter_lookahead: /\A *\:[a-zA-Z]([\-\_]?[a-zA-Z0-9]+)*/,

        # Text
        escaped_text: /\A(.*)/,
        unescaped_text: /\A\~(.*)/,

        # Print
        escaped_print: /\A\=(.*)/,
        unescaped_print: /\A\=\~(.*)/,
        print_lookahead: /\A *=/,

        # Multiline Text
        multiline: /\A(\|)/,

        # HTML Text
        html_text: /\A(\<.+\>.*)/,

        # Yield
        yield: /\A(yield)/,
        yield_identifier: /\A( +[a-zA-Z]([\_]?[a-zA-Z0-9]+)*)/,

        # Yield
        block: /\A(block)/,

        # Conditional Structures
        control: /\A(if|elsif|else|unless|case|when|each|while|until)/,
        control_lookahead: /\A *(if|elsif|else|unless|case|when|each|while|until)/,
        each_pattern: /\A(\w+( *, *\w+)? +)?in +.+/,

        # Text
        text: /\A\|/,

        # Brackets
        round_bracket: /\A(\()/,
        square_bracket: /\A(\[)/,
        curly_bracket: /\A(\{)/,
        angular_bracket: /\A(\<)/,

        # Receive matching brackets for allowing multiple bracket types for
        # element attributes
        :brackets => /\A([\(\[\{])/,
        :'(' => /\A(\))/,
        :'[' => /\A(\])/,
        :'{' => /\A(\})/,
        :'<' => /\A(\>)/,

        # Terminators
        comma: /\A(\s*\,\s*)/,
        colon: /\A(\s*\:\s*)/,
        semicolon: /\A(\s*\;\s*)/,

        # Expression
        exp_context: /\A(\$(.|\-.)?|\@|\@\@)/,
        exp_method_call: /\A(\.[a-zA-Z\_][a-zA-Z0-9\_]*[\!\?]?)/,
        exp_module: /\A(\:\:)/,
        exp_identifier: /\A([a-zA-Z\_][a-zA-Z0-9\_]*[\!\?]?)/,
        exp_assignment: /\A(\=)/,
        exp_operation: /\A( *(\+|\-|\*\*|\*|\/|\<\<|\>\>|\.\.|\%|\<\=\>|\<\=|\^|\<|\>\=|\>|\=\~|\!\~|\=\=\=|\=\=|\!|not|\&\&|\&|and|\|\||\||or) *)/,
        exp_regex: /\A(\/((?:[^\/\\]|\\.)*?)\/)/,
        exp_string: /\A(("((?:[^"\\]|\\.)*?)")|('(?:[^'\\]|\\.)*?'))/,
        exp_percent: /\A(\%[wWqQrxsiI]?.)/,
        exp_double: /\A([0-9]+\.[0-9]+([eE][-+]?[0-9]+)?)/,
        exp_fixnum: /\A([0-9]+)/,
        exp_nil: /\A(nil)/,
        exp_boolean: /\A(true|false)/,
        exp_ternary: /\A( *\? *)/,
        exp_ternary_else: /\A( *\: *)/,

        exp_identifier_lookahead: /\A[a-zA-Z\_][a-zA-Z0-9\_]*[\!\?]?/,

        # Hash
        hash_terminator: /\A(\s*(\,)\s*)/,
        hash_assignment: /\A(\s*(\=\>)\s*)/,
        hash_symbol: /\A([a-zA-Z\_][a-zA-Z0-9\_]*\:(?!\:))/,

        # Whitespace
        whitespace: /\A +/,

        # Evaluation
        eval: /\A\-(.*)/,
        eval_multiline: /\A\+(.*)/,

        # Whitespace
        newline: /\A(\n+)/,

        # Indentation
        indent: /\A( *)/,
        indent_lookahead: /\A\n?(?<capture> *)/,

        # Feed
        line_feed: /\A(.*)/,
      }

      # Return the matching closing bracket
      #
      # @param bracket [String] Opening bracket for the capture group
      #
      def self.bracket(bracket)
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
      def self.[](name)
        @@tokens[name]
      end

      # Set a new token at runtime
      #
      # @param name [Symboidentifierl] Identifier for the token
      # @param token [Token] Token data to be set
      #
      def self.[]=(name, token)
        @@tokens[name] = token
      end
    end
  end
end
