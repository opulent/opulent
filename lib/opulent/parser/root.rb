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
          node = parse_line parent, min_indent

          # If the indentation is smaller or equal to the minimum, we break
          # the current operation
          break unless node
        end

        return parent
      end
    end
  end
end
