# @Opulent
module Opulent
  # @Compiler
  module Compiler
    # @Singleton
    class << self
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
        node[@options][:attributes].each do |key, attribute|
          attributes[key] = map_attribute key, attribute, context
        end

        # Check if filter is registered
        error :filter_registered, name unless Engine.filter? name

        # Load the required filter
        Filters.filters[name].load_filter

        # Render output using the chosen engine
        output = Filters.filters[name].render @value

        # Main output node which contains filter rendered value
        text_node = [:plain, :text, {value: output}, [], nil]

        # If we have a provided filter tag, wrap the text node in the wrapper
        # node tag and further indent
        if (wrapper_tag = Filters.filters[name].options[:tag])
          text_node.indent = @indent + Engine[:indent]
          return Node.new wrapper_tag, Engine.filters[name].options[:attributes], @parent, @indent, [text_node]
        else
          return text_node
        end

      end
    end
  end
end
