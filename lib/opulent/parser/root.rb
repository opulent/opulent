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
      def root(parent = @root, min_indent = nil)
        while(@line = @code[@i])
          # Skip to next iteration if we have a blank line
          if @line =~ /\A\s*\Z/ then @i += 1; next; end

          # Reset the line offset
          @offset = 0

          # Parse the current line by trying to match each node type towards it
          # Add current indentation to the indent stack
          indent = accept(:indent).size

          # Advance to the next line, unless this has already been done due to
          # node specific processing
          @advance = true

          # Stop processing for current parent if we have a min_indent variable
          break if min_indent && indent <= min_indent

          # Try the main Opulent node types and process each one of them using
          # their matching evaluation procedure
          current_node =  node(parent, indent)      ||
                          text(parent, indent)      ||
                          define(parent, indent)

          # Throw an error if we couldn't find a valid node
          error :unknown_node_type unless current_node

          # Increment current line pointer
          @i += 1 if @advance
        end

        return parent
      end
    end
  end
end
