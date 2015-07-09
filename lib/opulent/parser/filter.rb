# @Opulent
module Opulent
  # @Parser
  class Parser
    # Check if we match an compile time filter
    #
    # :filter
    #
    # @param parent [Node] Parent node to which we append the element
    #
    def filter(parent, indent)
      if (filter_name = accept :filter)
        # Get element attributes
        atts = attributes(shorthand_attributes) || {}

        # Accept inline text or multiline text feed as first child
        error :fiter unless accept(:line_feed).strip.empty?

        # Get everything under the filter and set it as the node value
        # and create a new node and set its extension
        parent[@children] << [:filter, filter_name[1..-1].to_sym, atts, get_indented_lines(indent), indent]
      end
    end
  end
end
