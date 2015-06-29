module Opulent
  module Parser
    Tokens = {
      # Indentation
      indent: /\A */,

      # Node
      node: /\A\w+(\-\w+)*/,
      node_theme: /\A\w+(\-\w+)*\:\:/,

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
