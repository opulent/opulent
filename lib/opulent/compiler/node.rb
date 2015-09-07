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

      # Add the tag opening, with leading whitespace to the code buffer
      buffer_freeze " " if node[@options][:leading_whitespace]
      buffer_freeze "<#{node[@value]}"

      # Evaluate node extension in the current context
      extension = if node[@options][:extension]
        buffer_set_variable :extension, node[@options][:extension][@value]
      end

      # Evaluate and generate node attributes, then process each one to
      # by generating the required attribute code
      attributes = {}
      buffer_attributes node[@options][:attributes], extension

      # # if extension
      # #   buffer_eval "#{extension}.each do |_extk#{@current_extension}, _extv#{@current_extension}|"
      # #   dynamic_buffer_attribute_type_check "_extk#{@current_extension}", "_extv#{@current_extension}"
      # #   buffer_eval "end"
      # # end
      #
      # # # Set the current node as a parent for the node elements to follow
      # #@node_stack << (multi ? :multi : node[@value])
      #
      # # Check if the current node is self enclosing. Self enclosing nodes
      # # do not have any child elements
      # if node[@options][:self_enclosing]
      #   # If the tag is self enclosing, it cannot have any child elements.
      #   buffer_freeze ">"
      #   buffer_freeze "\n" if Settings[:pretty]
      # else
      #   # Set tag ending code
      #   buffer_freeze ">"
      #
      #   # If the node is an inline node and doesn't have any child elements,
      #   # we close it on the same line, without adding indentation
      #   if Settings[:pretty]
      #     buffer_freeze "\n" unless inline_current || node[@children].empty?
      #   end
      #
      #   # Get number of siblings
      #   @sibling_stack << node[@children].size
      #
      #   # Process each child element recursively, increasing indentation
      #   node[@children].each do |child|
      #     root child, indent + Settings[:indent], context
      #   end
      #
      #   # Remove the current node children count from the sibling stack
      #   @sibling_stack.pop
      #
      #   # Remove all child nodes of the current node from the node stack
      #   @node_stack.pop(node[@children].size)
      #
      #   if Settings[:pretty]
      #     # If we have an inline node, we remove the trailing newline from
      #     # our buffer, otherwise add indentation
      #     if inline_current
      #       remove_trailing_newline
      #
      #     # If the node doesn't have any child elements, we close it on the same
      #     # line, without adding indentation
      #     elsif node[@children].any?
      #       buffer_freeze indentation
      #     end
      #   end
      #
      #   # Set tag closing code
      #   buffer_freeze "</#{node[@value]}>"
      #   buffer_freeze " " if node[@options][:trailing_whitespace]
      #   buffer_freeze "\n" if Settings[:pretty]
      #end
    end

    # Process input value depending on its type. When array or hash, iterate
    # and escape each string value.
    #
    def buffer_attribute_type_check(identifier, attribute, key)
      join = (key == :class ? ' ' : '_')

      # Array class
      buffer_eval "if #{identifier}.is_a? Array"

      buffer_freeze " #{key}=\"" unless key == :class
      value = "#{identifier}.join '#{join}'"
      attribute[@options][:escaped] ? buffer_escape(value) : buffer(value)
      buffer_freeze '"'  unless key == :class

      # Hash class
      buffer_eval "elsif #{identifier}.is_a? Hash"

      buffer_eval "#{identifier}.each do |_k, _v|"
      buffer_freeze(" #{key}-")
      buffer "\"\#{_k}\""
      buffer_freeze "=\""
      attribute[@options][:escaped] ? buffer_escape("_v") : buffer("_v")
      buffer_freeze '"'
      buffer_eval "end"

      # True class
      buffer_eval "elsif #{identifier}.is_a? TrueClass"
      buffer_freeze(" #{key}")

      # False class
      buffer_eval "elsif #{identifier}.is_a?(NilClass) || #{identifier}.is_a?(FalseClass)"

      # Other classes
      buffer_eval "else"
      buffer_freeze " #{key}=\"" unless key == :class
      attribute[@options][:escaped] ? buffer_escape(identifier) : buffer(identifier)
      buffer_freeze "\"" unless key == :class

      buffer_eval "end"
    end

    # Process input value depending on its type. When array or hash, iterate
    # and escape each string value.
    #
    def dynamic_buffer_attribute_type_check(key, value)
      escape = false
      # Array class
      buffer_eval "if #{value}.is_a? Array"

      buffer "\" \#{#{key}}=\\\"\""
      buffer_eval "_join#{@current_extension} = (#{key} == :class ? ' ' : '_')"

      array_value = "#{value}.join \"\#{_join#{@current_extension}}\""
      escape ? buffer_escape(array_value) : buffer(array_value)
      buffer_freeze '"'

      # Hash class
      buffer_eval "elsif #{value}.is_a? Hash"

      buffer_eval "#{value}.each do |_k#{key}, _v#{value}|"
      buffer "\" \#{#{key}}-\""
      buffer "\"\#{_k#{key}}\""
      buffer_freeze "=\""
      escape ? buffer_escape("_v#{value}") : buffer("_v#{value}")
      buffer_freeze '"'
      buffer_eval "end"

      # True class
      buffer_eval "elsif #{value}.is_a? TrueClass"
      buffer("\" \#{#{key}}\"")

      # False class
      buffer_eval "elsif #{value}.is_a?(NilClass) || #{value}.is_a?(FalseClass)"

      # Other classes
      buffer_eval "else"
      buffer "\" \#{#{key}}=\\\"\"" unless key == :class
      escape ? buffer_escape(value) : buffer(value)
      buffer_freeze "\"" unless key == :class

      buffer_eval "end"
    end

    # Generate attribute code for the current key value pair. For string
    # values, generate a key value pair. For false values, remove the
    # attribute. For true values, generate a standalone attribute key
    #
    def buffer_attribute_extend(attribute, key, extension)
      # Set evaluation value to the current identifier
      identifier = "_opulent_attribute_#{@current_attribute += 1}"

      # If the extension has the key we're processing, take the value from
      # the extension
      if extension
        # Class extension will actually add more classes to the existing array
        # of classes instead of overriding it
        if key == :class
          buffer_eval "if #{extension}[#{key.inspect}]"
          buffer_eval "#{identifier} = [#{attribute[@value]}, #{extension}.delete(#{key.inspect})].flatten"
          buffer_eval "else"
          buffer_eval "#{identifier} = #{attribute[@value]}"
          buffer_eval "end"
        else
          buffer_eval "if #{extension}[#{key.inspect}]"
          buffer_eval "#{identifier} = #{extension}.delete #{key.inspect}"
          buffer_eval "else"
          buffer_eval "#{identifier} = #{attribute[@value]}"
          buffer_eval "end"
        end
      else
        buffer_eval "#{identifier} = #{attribute[@value]}"
      end

      buffer_attribute_type_check identifier, attribute, key
    end

    # Map attributes by evaluating them in the current working context
    #
    # @param key [Symbol] Name of the attribute being processed
    # @param attribute [Array] Attribute instance data
    # @param context [Context] Processing environment data
    #
    def buffer_attribute_set(key, attribute, extension)
      if attribute[@value] =~ Tokens[:exp_string]
        # If we have a simple string, freeze it and set the attribute value
        buffer_freeze " #{key}=\""

        attribute = attribute[0] if key == :class

        # When we have an extension, remove the data from the extension
        # and set it as the new value
        if extension
          buffer_eval "if #{extension}[#{key.inspect}]"
          buffer "#{extension}.delete #{key.inspect}"
          buffer_eval "else"
          format_string attribute[@value][1..-2], attribute[@options][:escaped]
          buffer_eval "end"
        else
          format_string attribute[@value][1..-2], attribute[@options][:escaped]
        end
        buffer_freeze '"'
      else
        # Process each attribute of a class or standalone attributes
        if key == :class
          buffer_freeze " #{key}=\""

          simple_classes = []
          advanced_classes = []
          attribute.each do |attrib|
            if attrib[@value] =~ Tokens[:exp_string]
              simple_classes << attrib[@value][1..-2]
            else
              advanced_classes << attrib
            end
          end

          unless simple_classes.empty?
            buffer_freeze simple_classes.join ' '
            buffer_freeze ' '
          end

          advanced_classes.each do |attrib|
            buffer_attribute_extend attrib, key, extension
            buffer_freeze " "
          end
          @template[-1][1].rstrip!
          buffer_freeze '"'
        else
          buffer_attribute_extend attribute, key, extension
        end
      end
    end
  end
end
