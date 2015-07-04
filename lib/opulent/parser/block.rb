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
        if accept :yield
          # Get definition name
          if(yield_name = accept_stripped(:yield_identifier))
            yield_name = yield_name.strip.to_sym
          else
            yield_name = Engine::DefaultYield
          end

          # Create a new node
          yield_node = [:yield, yield_name, {}, nil, indent]

          # Consume the newline from the end of the element
          error :yield unless accept(:line_feed).strip.empty?

          parent[@children] << yield_node
        end
      end

      # Match a block with a explicit target
      #
      # block target
      #
      # @param parent [Node] Parent node to which we append the definition
      #
      def block(parent)
        if accept :block
          # Get definition name
          if(block_name = accept_stripped(:yield_identifier))
            block_name = block_name.strip.to_sym
          else
            block_name = Engine::DefaultYield
          end

          # Create a new node
          block_node = [:block, block_name, {}, [], indent]
          root block_node, indent

          # Consume the newline from the end of the element
          error :block unless accept_unstripped(:line_feed).strip.empty?

          parent[@children] << block_node
        end
      end
    end
  end
end
