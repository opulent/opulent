# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a standard node element, with closing tags or
    # self enclosing elements
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def node(node, indent, context)
      indentation = " " * indent

      # Check if the current node and last node should be displayed inline
      inline_current = @inline_node.include? node[@value]
      inline_last = @inline_node.include? @node_stack.last

      # Check if the node is a special node which can be either inline or
      # block structure. Write the special node as inline if its children
      # are all inline nodes
      if @multi_node.include?(node[@value])
        # First condition should be removed to ignore preceding node and make
        # it be inline no matter what. Using the first check, we write it
        # inline only if the element before it was inline
        unless @sibling_stack.last > 1 && node[@children].all? do |child|
          @inline_node.include?(child[@value])
        end
          inline_current = false
          multi = true
        end
      end

      # If we have an inline node, we remove the trailing newline character
      # and write the tag code directly. Otherwise we add the tag code with
      # normal indentation
      if inline_last && inline_current
        remove_trailing_newline
      else
        @code += indentation
      end

      # Add the tag opening, with leading whitespace to the code buffer
      tag_open = "<#{node[@value]}"
      @code += " " if node[@options][:leading_whitespace]
      @code += tag_open

      # Evaluate node extension in the current context
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

      # Set the current node as a parent for the node elements to follow
      @node_stack << (multi ? :multi : node[@value])

      # Check if the current node is self enclosing. Self enclosing nodes
      # do not have any child elements
      if node[@options][:self_enclosing]
        # If the tag is self enclosing, it cannot have any child elements.
        tag_close = ">"
        tag_close += "\n"

        @code += tag_close
      else
        # Set tag ending code
        tag_end = ">"

        # If the node is an inline node and doesn't have any child elements,
        # we close it on the same line, without adding indentation
        tag_end += "\n" unless inline_current || node[@children].empty?

        # Set tag closing code
        tag_close = "</#{node[@value]}>"
        tag_close += " " if node[@options][:trailing_whitespace]
        tag_close += "\n"

        # Add tag ending to the buffer
        @code += tag_end

        # Get number of siblings
        @sibling_stack << node[@children].size

        # Process each child element recursively, increasing indentation
        node[@children].each do |child|
          root child, indent + Settings[:indent], context
        end

        # Remove the current node children count from the sibling stack
        @sibling_stack.pop

        # Remove all child nodes of the current node from the node stack
        @node_stack.pop(node[@children].size)

        # If we have an inline node, we remove the trailing newline from
        # our buffer, otherwise add indentation
        if inline_current
          remove_trailing_newline

        # If the node doesn't have any child elements, we close it on the same
        # line, without adding indentation
        elsif node[@children].any?
          @code += indentation
        end

        # Close the current tag
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
      # Process input value depending on its type. When array or hash, iterate
      # and escape each string value.
      process = Proc.new do |value|
        case value
        when Array
          value.map do |v|
            v.is_a?(String) ? escape(v) : v
          end
        when Hash
          value.each do |k,v|
            value[k] = value[k].is_a?(String) ? escape(v) : v
          end
        when String
          escape value
        else
          value
        end
      end

      # Process each attribute depending on whether it's an array of values,
      # exclusive to the class attribute, or an individual attribute value
      if key == :class
        attribute.map do |attrib|
          value = context.evaluate attrib[@value]
          attrib[@options][:escaped] ? process[value] : value
        end
      else
        value = context.evaluate attribute[@value]
        attribute[@options][:escaped] ? process[value] : value
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

        unless attribute_value.empty?
          attribute_code += " #{key}"
          attribute_code += "=\"#{attribute_value.strip}\""
        end
      when Hash
        value.each do |k,v|
          if v
            attribute_code += " #{key}-#{k}"
            attribute_code += "=\"#{v.to_s.strip}\"" unless v == true
          end
        end
      else
        if value
          attribute_code += " #{key}"
          attribute_code += "=\"#{value.to_s.strip}\"" unless value == true
        end
      end

      return attribute_code
    end
  end
end
