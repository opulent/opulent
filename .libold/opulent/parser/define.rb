# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Define
    module Define
      # Match a definition node with its parameters and body
      #
      # def node_name[ parameters ]
      #   body nodes
      #
      # @param parent [Node] Parent node to which we append the definition
      #
      def define(parent)
        if lookahead :def_lookahead
          # Get current line's indentation
          indent = accept_unstripped(:indent) || ""

          if accept :def
            # Get definition name
            def_name = accept :identifier, :*

            # Get element attributes
            atts = attributes({}) || {}

            # Create a new node
            node = @create.definition def_name.to_sym, atts, parent, indent.size

            # Consume the newline from the end of the element
            error :define unless accept_unstripped(:line_feed).strip.empty?
            accept_unstripped :newline

            return node
          end
        end
      end
    end
  end
end
