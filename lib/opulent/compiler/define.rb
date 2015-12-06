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
        method_call = "#{key}"

        # Call arguments set to true, in correct order
        arguments = []
        @definitions[call_node[@value]][@options][:parameters].keys.each do
          arguments << 'true'
        end
        arguments << '{}'

        method_call += '(' + arguments.join(', ') + ')'
        method_call += ' do' unless call_node[@children].empty?

        buffer_eval method_call
      else
        arguments = []

        # Extract node definition arguments in the correct order. If the given
        # key does not exist, set the value to default or true
        @definitions[
          call_node[@value]
        ][@options][:parameters].keys.each do |k|
          if call_node[@options][:attributes].keys.include? k
            arguments << call_node[@options][:attributes].delete(k)[@value]
          else
            arguments << @definitions[
              call_node[@value]
            ][@options][:parameters][k][@value]
          end
        end

        call_attributes = buffer_attributes_to_hash(
          call_node[@options][:attributes]
        )

        # If the call node is extended as well, merge the call attributes hash
        # with the extension hash
        if call_node[@options][:extension]
          # .merge!(var_name)
          call_attributes += '.merge!(' \
                             "#{call_node[@options][:extension][@value]}" \
                             ')'

          # { |key, value1, value2|
          call_attributes += " { |#{OPULENT_KEY}, " \
                             "#{OPULENT_VALUE}1, #{OPULENT_VALUE}2|"

          # class ? value1 + value2 : value2
          call_attributes += "#{OPULENT_KEY} == :class ? (" \
                             "#{OPULENT_VALUE}1 += " \
                             "#{OPULENT_VALUE}2) : (#{OPULENT_VALUE}2" \
                             ')'

          # }
          call_attributes += '}'
        end

        arguments << call_attributes

        call = "#{key}(#{arguments.join ', '})"
        call += ' do' unless call_node[@children].empty?

        buffer_eval call
      end

      # Set call node children as block evaluation. Very useful for
      # performance and evaluating them in the parent context
      call_node[@children].each do |child|
        root child, indent + @settings[:indent]
      end

      # End block
      buffer_eval 'end' unless call_node[@children].empty?
    end
  end
end
