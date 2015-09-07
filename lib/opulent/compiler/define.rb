# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate code for all nodes by calling the method with their type name
    #
    # @param current [Array] Current node data with options
    # @param indent [Fixnum] Indentation size for current node
    # @param context [Context] Context holding environment variables
    #
    def def_node(node, indent, context)
      key = "_opulent_#{node[@value]}_#{@current_definition += 1}".gsub '-', '_'

      # Create a new definition context
      #
      # @update: Added &context.block to make sure yield can be called from
      # within a definition (it might be a nice feature)
      #
      # Create a new closure without any local variables
      call_node = node[@options][:call]

      buffer_eval "def #{key}(attributes = {})"

      # Set each parameter as a local variable
      node[@options][:parameters].each do |parameter, value|
        if call_node[@options][:attributes][parameter]
          buffer_eval "#{parameter} = attributes.delete :#{parameter}"
        else
          buffer_eval "#{parameter} = #{value[@value]}"
        end
      end

      # Add call children to the block stack, depending on whether they're
      # block elements or child elements
      @block_stack << { @default_yield => [] }

      # If we have a direct child, add it to the default yield (children)
      # block and allow same block multiple times by appending nodes
      call_node[@children].each do |child|
        if child[@type] == :block
          @block_stack[-1][child[@value]] ||= []
          @block_stack[-1][child[@value]] += child[@children]
        else
          @block_stack[-1][@default_yield] << child
        end
      end

      # Evaluate definition child elements
      node[@children].each do |child|
        root child, indent + Settings[:indent], context
      end

      buffer_eval "end"

      # If we have attributes set for our defined node, we will need to create
      # an extension parameter which will be o
      if call_node[@options][:attributes].empty?
        # Call method without any extension
        buffer_eval "#{key}"
      else
        # Set node extension parameters
        extension = "_opulent_extension_#{@current_extension}"
        extend_code = "#{extension} = {"
        call_node[@options][:attributes].each do |key, attribute|
          extend_code += buffer_definition_attributes key, attribute
        end
        extend_code = extend_code[0..-2]
        extend_code += "}"
        buffer_eval extend_code
        buffer_eval "#{key} #{extension}"
      end



      # definition_context.parent = context
      #
      # # # Set call node
      # # call_node = node[@options][:call]
      # #
      # # # Get call node attributes
      # # attributes = call_node[@options][:attributes]
      # #
      # # Evaluate node extension in the current context
      # if call_node[@options][:extension]
      #   extension = context.evaluate call_node[@options][:extension][@value]
      # else
      #   extension = {}
      # end
      #
      # # Evaluate and generate node attributes, then process each one to
      # # by generating the required attribute code
      # attributes = {}
      # call_node[@options][:attributes].each do |key, attribute|
      #   unless node[@options][:parameters].has_key? key
      #     attributes[key] = map_attribute key, attribute, context
      #   end
      # end
      #
      # # Go through each extension attribute and use the value where applicable
      # extend_attributes attributes, extension
      #
      # # Definition call arguments
      # arguments = {}
      #
      # # Extract values which appear as definition parameters. If we have the
      # # key passed as argument, get its value. Otherwise, set the default
      # # parameter value.
      # #
      # # Definition arguments (parameters which are set in definition header)
      # # will be passed unescaped, to allow node definition to handle escaping
      # # properly
      # node[@options][:parameters].each do |key, value|
      #   if call_node[@options][:attributes].has_key? key
      #     arguments[key] = context.evaluate call_node[@options][:attributes][key][@value]
      #   else
      #     arguments[key] = definition_context.evaluate value[@value]
      #   end
      # end
      #
      # # Set the remaining attributes as a value in the arguments
      # arguments[:attributes] = attributes


      # Remove last set of blocks from the block stack
      @block_stack.pop
    end

    def buffer_attribute_extract(key, value)
      buffer_eval "#{key} = #{value.delete(key)[@value]}"
    end


    def buffer_definition_attributes(key, value)
      if key == :class
        evaluate = "#{key}: ["
        if value.length > 1
          value.inject(evaluate) do |buffer, exp|
            buffer += "#{exp}, "
          end
          evaluate = evaluate[0..-2]
        else
          evaluate += value[0][@value]
        end
        evaluate += "]"
      else
        evaluate = "#{key}: #{value[@value]}"
      end
      evaluate += ","

      return evaluate
    end
  end
end
