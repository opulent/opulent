# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Singleton
    class << self
      # Analyze the input code and check for matching tokens.
      # In case no match was found, throw an exception.
      # In special cases, modify the token hash.
      #
      # @param nodes [Array] Parent node to which we append to
      #
      def define(parent, indent)
        if(match = accept :def)
          # Process data
          name = accept(:node, :*).to_sym
          advance = false; @i += 1

          # Create node
          definition = [:def, name, attributes, [], indent]
          root(definition, indent)

          # Add to parent
          @definitions[name] = definition
        end
      end
    end
  end
end
