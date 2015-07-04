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
      def root(parent = @root, min_indent = -1)
        while(@line = @code[(@i += 1)])
          # Skip to next iteration if we have a blank line
          if @line =~ /\A\s*\Z/ then next end

          # Reset the line offset
          @offset = 0

          # Parse the current line by trying to match each node type towards it
          # Add current indentation to the indent stack
          indent = accept(:indent).size

          # Stop using the current parent as root if it does not match the
          # minimum indentation requirements
          unless min_indent < indent
            @i -= 1; break
          end

          # Try the main Opulent node types and process each one of them using
          # their matching evaluation procedure
          current_node =  node(parent, indent)        ||
                          text(parent, indent)        ||
                          comment(parent, indent)     ||
                          define(parent, indent)      ||
                          control(parent, indent)     ||
                          evaluate(parent, indent)    ||
                          filter(parent, indent)      ||
                          block_yield(parent, indent) ||
                          block(parent, indent)

          # Throw an error if we couldn't find a valid node
          error :unknown_node_type unless current_node
        end

        return parent
      end
    end
  end
end
