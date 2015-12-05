# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Write out definition node using ruby def
    #
    # @param node [Node] Current node data with options
    #
    def define(node)
      # Write out def method_name
      definition = "def _opulent_definition_#{node[@value].to_s.tr '-', '_'}"

      # Node attributes
      parameters = []
      node[@options][:parameters].each do |key, value|
        parameters << "#{key} = #{value[@value]}"
      end
      parameters << 'attributes = {}'
      parameters << '&block'
      definition += '(' + parameters.join(', ') + ')'

      buffer_eval 'instance_eval do'
      buffer_eval definition

      node[@children].each do |child|
        root child, 0
      end

      buffer_eval 'end'
      buffer_eval 'end'
    end

    # Generate code for all nodes by calling the method with their type name
    #
    # @param current [Array] Current node data with options
    # @param indent [Fixnum] Indentation size for current node
    #
    def def_node(node, indent)
      # Set a namespace for the current node definition and make it a valid ruby
      # method name
      key = "_opulent_definition_#{node[@value].to_s.tr '-', '_'}"

      # Set call variable
      call_node = node[@options][:call]

      # If we have attributes set for our defined node, we will need to create
      # an extension parameter which will be o
      if call_node[@options][:attributes].empty?
        # Call method without any extension
        call = "#{key}"

        # Call arguments set to true, in correct order
        arguments = []
        @definitions[call_node[@value]][@options][:parameters].keys.each do
          arguments << 'true'
        end
        arguments << '{}'

        call += '(' + arguments.join(', ') + ')'
        call += ' do'

        buffer_eval call
      else
        call_attributes_code = buffer_attributes_to_hash call_node[@options][:attributes]

        # Set call node parameters
        call_attributes = buffer_set_variable :call_attributes, call_attributes_code

        # If the call node is extended as well, merge the call attributes hash with
        # the extension hash
        if call_node[@options][:extension]
          extension_attributes = buffer_set_variable :extension, call_node[@options][:extension][@value]
          buffer_eval "#{call_attributes}.merge!(#{extension_attributes}) do |#{OPULENT_KEY}, #{OPULENT_VALUE}1, #{OPULENT_VALUE}2|"
          buffer_eval "#{OPULENT_KEY} == :class ? (#{OPULENT_VALUE}1 += #{OPULENT_VALUE}2) : (#{OPULENT_VALUE}2)"
          buffer_eval 'end'
        end

        buffer_eval "#{key}(#{call_attributes}) do"
      end

      # Set call node children as block evaluation. Very useful for
      # performance and evaluating them in the parent context
      call_node[@children].each do |child|
        root child, indent + @settings[:indent]
      end

      # End block
      buffer_eval "end"
    end
  end
end
