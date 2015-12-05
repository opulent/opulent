# @Opulent
module Opulent
  # @Parser
  class Parser
    # Match a yield with a explicit or implicit target
    #
    # yield target
    #
    # @param parent [Node] Parent node to which we append the definition
    #
    def block_yield(parent, indent)
      return unless accept :yield

      # Consume the newline from the end of the element
      error :yield unless accept(:line_feed).strip.empty?

      # Create a new node
      yield_node = [:yield, nil, {}, [], indent]

      parent[@children] << yield_node
    end
  end
end
