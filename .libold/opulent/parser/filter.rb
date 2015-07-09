# @SugarCube
module Opulent
  # @Parser
  module Parser
    # @Text
    module Filter
      # Check if we match an compile time filter
      #
      # :filter
      #
      # @param parent [Node] Parent node to which we append the element
      #
      def filter_element(parent)
        if lookahead :filter_lookahead
          # Get current line's indentation
          indent = accept_unstripped(:indent) || ""

          if (filter_name = accept :filter)
            # Get element attributes
            atts = attributes({}) || {}

            # Create a new node and set its extension
            filter_node = @create.filter filter_name.to_sym, atts, parent, indent.size

            # Accept inline text or multiline text feed as first child
            if(text_node = text filter_node, indent, true)
              #filter_node.atts = accept_unstripped(:line_feed)
              error :fiter unless accept_line(:line_feed).strip.empty?
            end
            accept_unstripped(:newline)

            # Get everything under the filter and set it as the node value
            filter_node.value += get_indented_lines(indent.size)

            return filter_node
          end
        end
      end
    end
  end
end
