# @Opulent
module Opulent
  # @Compiler
  module Compiler
    # @Singleton
    class << self
      # Generate the code for a standard node element, with closing tags or
      # self enclosing elements
      #
      # @param node [Array] Node code generation data
      # @param indent [Fixnum] Size of the indentation to be added
      # @param context [Context] Processing environment data
      #
      def node(node, indent, context)
        indentation = " " * indent

        tag_open = "#{indentation}<#{node[@value]}"
        @code += tag_open

        # Evaluate node extension
        if node[@options][:extension]
          extension = context.evaluate node[@options][:extension][@value]
        else
          extension = {}
        end

        # Evaluate and generate node attributes, then process each one to
        # by generating the required attribute code
        attributes = {}
        node[@options][:attributes].each do |key, attribute|
          attributes[key] = map_attribute key, attribute, context
        end

        # Go through each extension attribute and use the value where applicable
        extend_attributes attributes, extension

        # Join arrays, create new attributes by hash and set the
        # value otherwise
        attributes.each do |key, value|
          @code += attribute_code key, value
        end

        # If the tag is self enclosing, it cannot have any child elements.
        # Otherwise, for each child node, generate code recursively and
        # increase indentation each time
        if node[@options][:self_enclosing]
          tag_close = "/>\n"
          @code += tag_close
        else
          tag_end = ">\n"
          tag_close = "#{indentation}</#{node[@value]}>\n"

          @code += tag_end
          node[@children].each do |child|
            generate child, indent + Settings[:indent], context
          end
          @code += tag_close
        end
      end

      # Map attributes by evaluating them in the current working context
      #
      # @param key [Symbol] Name of the attribute being processed
      # @param attribute [Array] Attribute instance data
      # @param context [Context] Processing environment data
      #
      def map_attribute(key, attribute, context)
        if key == :class
          attribute.map do |attrib|
            context.evaluate attrib[@value]
          end
        else
          context.evaluate attribute[@value]
        end
      end

      # Extend attributes using the extension directive where applicable.
      # Concatenate arrays, merge hashes and replace otherwise
      #
      # @param attributes [Hash] Evaluated node attributes
      # @param extension [Hash] Node extension input
      #
      def extend_attributes(attributes, extension)
        extension.each do |key, value|
          case attributes[key]
          when Array
            if key == :class
              attributes[key] << value
              attributes[key].flatten!
            else
              attributes[key] = value
            end
          when Hash
            if value.is_a? Hash
              attributes[key].merge! value
            else
              attributes[key] = value
            end
          else
            attributes[key] = value
          end
        end
      end

      # Generate attribute code for the current key value pair. For string
      # values, generate a key value pair. For false values, remove the
      # attribute. For true values, generate a standalone attribute key
      #
      # @param key [Symbol] Name of the attribute being generated
      # @param value [Object] Value of the attribute
      #
      def attribute_code(key, value)
        attribute_code = ""

        case value
        when Array
          if key == :class
            attribute_value = value.join ' '
          else
            attribute_value = value.join '_'
          end

          attribute_code += " #{key}"
          attribute_code += "=\"#{attribute_value}\"" unless attribute_value.empty?
        when Hash
          value.each do |k,v|
            if v
              attribute_code += " #{key}-#{k}"
              attribute_code += "=\"#{v.to_s}\"" unless v == true
            end
          end
        else
          if value
            attribute_code += " #{key}"
            attribute_code += "=\"#{value.to_s}\"" unless value == true
          end
        end

        return attribute_code
      end
    end
  end
end
