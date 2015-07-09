# @Opulent
module Opulent
  # @Parser
  class Parser
    # Check if we match a new node definition to use within our page.
    #
    # Definitions will not be recursive because, by the time we parse
    # the definition children, the definition itself is not in the
    # knowledgebase yet.
    #
    # However, we may use previously defined nodes inside new definitions,
    # due to the fact that they are known at parse time.
    #
    # @param nodes [Array] Parent node to which we append to
    #
    def define(parent, indent)
      if(match = accept :def)
        # Process data
        name = accept(:node, :*).to_sym

        # Create node
        definition = [:def, name, {parameters: attributes}, [], indent]
        root(definition, indent)

        # Add to parent
        @definitions[name] = definition
      end
    end
  end
end
