module Opulent
  module Parser
    # Opulent Keywords
    Keywords = %w(def theme block yield if else elsif unless case when each while until)

    # Opulent Tokens
    Tokens = {
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

      # Definition
      def: /\Adef +/,

      # Node Attributes
      attributes_bracket: /\A\(\[\{/,

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
    }

  end
end
