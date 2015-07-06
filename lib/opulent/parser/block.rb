# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Singleton
    class << self
      # Match a yield with a explicit or implicit target
      #
      # yield target
      #
      # @param parent [Node] Parent node to which we append the definition
      #
      def block_yield(parent, indent)
        if accept :yield
          # Get definition name
          if(yield_name = accept_stripped(:yield_identifier))
            yield_name = yield_name.strip.to_sym
          else
            yield_name = Settings::DefaultYield
          end

          # Consume the newline from the end of the element
          error :yield unless accept(:line_feed).strip.empty?

          # Create a new node
          yield_node = [:yield, yield_name, {}, [], indent]

          parent[@children] << yield_node
        end
      end

      # Match a block with a explicit target
      #
      # block target
      #
      # @param parent [Node] Parent node to which we append the definition
      #
      def block(parent, indent)
        if accept :block
          # Get definition name
          if(block_name = accept_stripped(:yield_identifier))
            block_name = block_name.strip.to_sym
          else
            block_name = Settings::DefaultYield
          end

          # Consume the newline from the end of the element
          error :block unless accept(:line_feed).strip.empty?

          # Create a new node
          block_node = [:block, block_name, {}, [], indent]
          root block_node, indent

          parent[@children] << block_node
        end
      end
    end
  end
end
