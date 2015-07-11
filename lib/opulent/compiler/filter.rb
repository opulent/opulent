# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a while control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def filter(node, indent, context)
      # Evaluate and generate node attributes, then process each one to
      # by generating the required attribute code
      attributes = {}
      node[@options].each do |key, attribute|
        attributes[key] = map_attribute key, attribute, context
      end

      # Get registered filter name
      name = node[@value]

      # Check if filter is registered
      self.error :filter_registered, name unless Filters.filters.has_key? name

      # Load the required filter
      Filters.filters[name].load_filter

      # Render output using the chosen engine
      output = Filters.filters[name].render node[@children]

      # Main output node which contains filter rendered value
      text_node = [:plain, :text, {value: output.rstrip, escaped: false, evaluate: false}, [], nil]

      # If we have a provided filter tag, wrap the text node in the wrapper
      # node tag and further indent
      if (wrapper_tag = Filters.filters[name].options[:tag])
        # Set wrapper tag attributes as evaluable expressions
        atts = {}
        Filters.filters[name].options[:attributes].each do |key, value|
          atts[key] = [:expression, value.inspect, {evaluate: false, escaped: false}]
        end

        # Create the wrapper node containing the output text node as a child
        wrapper_node = [:node, wrapper_tag, {attributes: atts}, [text_node], indent]

        # Begin code generation from the wrapper node
        root wrapper_node, indent, context
      else
        # Generate code for output text node
        root text_node, indent, context
      end
    end
  end
end
