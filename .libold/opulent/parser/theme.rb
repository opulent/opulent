# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Define
    module Theme
      # Match a theme namespace node with its parameters and body
      #
      # theme node_name[ parameters ]
      #   body nodes
      #
      # @param parent [Node] Parent node to which we append the definition
      #
      def theme(parent)
        if lookahead :theme_lookahead
          # Get current line's indentation
          indent = accept_unstripped(:indent) || ""

          if accept :theme
            # Get definition name
            theme_name = accept :theme_identifier, :*

            # Create a new node
            node = @create.theme theme_name.to_sym, parent, indent.size

            # Consume the newline from the end of the element
            error :theme unless accept_unstripped(:line_feed).strip.empty?
            accept_unstripped :newline

            return node
          end
        end
      end
    end
  end
end
