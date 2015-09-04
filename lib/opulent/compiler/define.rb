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
      @current_definition += 1
      identifier = "_opulent_definition#{@current_definition}"

      # Create a new definition context
      #
      # @update: Added &context.block to make sure yield can be called from
      # within a definition (it might be a nice feature)
      #
      buffer_eval "#{identifier} = Proc.new do"
      
      buffer_eval "end[]"

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
      #
      # # Add call children to the block stack, depending on whether they're
      # # block elements or child elements
      # @block_stack << { @default_yield => [] }
      #
      # # If we have a direct child, add it to the default yield (children)
      # # block and allow same block multiple times by appending nodes
      # call_node[@children].each do |child|
      #   if child[@type] == :block
      #     @block_stack[-1][child[@value]] ||= []
      #     @block_stack[-1][child[@value]] += child[@children]
      #   else
      #     @block_stack[-1][@default_yield] << child
      #   end
      # end
      #
      # # Set variable to determine available blocks
      # arguments[:blocks] = Hash[@block_stack[-1].keys.map{|key| [key, true]}]
      #
      # # Create local variables from argument variables
      # definition_context.extend_locals arguments
      #
      # # Evaluate the model using the new context
      # node[@children].each do |child|
      #   root child, indent, definition_context
      # end
      #
      # # Remove last set of blocks from the block stack
      # @block_stack.pop
    end
  end
end
