# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Block
    module Block
      # Match a yield with a explicit or implicit target
      #
      # yield target
      #
      # @param parent [Node] Parent node to which we append the definition
      #
      def block_yield(parent)
        if lookahead :yield_lookahead
          # Get current line's indentation
          indent = accept(:indent, false, false) || ""

          if accept :yield
            # Get definition name
            yield_name = if(yield_name = accept(:yield_identifier, false, false))
              yield_name.strip.to_sym
            else
              Engine::DEFAULT_YIELD
            end

            # Create a new node
            node = @create.block_yield yield_name, parent, indent.size

            # Consume the newline from the end of the element
            error :yield unless accept(:line_feed, false, false).strip.empty?
            accept :newline, false, false

            return node
          end
        end
      end

      # Match a block with a explicit target
      #
      # block target
      #
      # @param parent [Node] Parent node to which we append the definition
      #
      def block(parent)
        if lookahead :block_lookahead
          # Get current line's indentation
          indent = accept_unstripped(:indent) || ""

          if accept :block
            # Get definition name
            block_name = if(block_name = accept_unstripped(:yield_identifier))
              block_name.strip.to_sym
            else
              Engine::DEFAULT_YIELD
            end

            # Create a new node
            node = @create.block block_name, parent, indent.size

            # Consume the newline from the end of the element
            error :block unless accept_unstripped(:line_feed).strip.empty?
            accept_unstripped :newline

            return node
          end
        end
      end
    end
  end
end
