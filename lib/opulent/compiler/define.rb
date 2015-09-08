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
      # Set a namespace for the current node definition and make it a valid ruby
      # method name
      key = "_opulent_definition_#{node[@value]}_#{@current_definition += 1}".gsub '-', '_'

      # Set call variable
      call_node = node[@options][:call]

      # Create the definition
      buffer_eval "def #{key}(attributes = {}, &block)"

      # Set each parameter as a local variable
      node[@options][:parameters].each do |parameter, value|
        buffer_eval "#{parameter} = attributes.delete(:#{parameter}) || #{value[@value]}"
      end

      # Evaluate definition child elements
      node[@children].each do |child|
        root child, indent + Settings[:indent], context
      end

      # End
      buffer_eval "end"

      # If we have attributes set for our defined node, we will need to create
      # an extension parameter which will be o
      if call_node[@options][:attributes].empty?
        # Call method without any extension
        buffer_eval "#{key}() do"
      else
        call_attributes_code = buffer_attributes_to_hash call_node[@options][:attributes]

        # Set call node parameters
        call_attributes = buffer_set_variable :call_attributes, call_attributes_code

        # If the call node is extended as well, merge the call attributes hash with
        # the extension hash
        if call_node[@options][:extension]
          extension_attributes = buffer_set_variable :extension, call_node[@options][:extension][@value]
          buffer_eval "#{call_attributes}.merge!(#{extension_attributes}) do |#{OpulentKey}, #{OpulentValue}1, #{OpulentValue}2|"
          buffer_eval "#{OpulentKey} == :class ? (#{OpulentValue}1 += #{OpulentValue}2) : (#{OpulentValue}2)"
          buffer_eval "end"
        end

        buffer_eval "#{key}(#{call_attributes}) do"
      end

      # Set call node children as block evaluation. Very useful for
      # performance and evaluating them in the parent context
      call_node[@children].each do |child|
        root child, indent + Settings[:indent], context
      end

      # End block
      buffer_eval "end"



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
  end
end
