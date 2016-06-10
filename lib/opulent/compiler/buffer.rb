# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Output an object stream into the template
    #
    # @param string [String] Buffer input string
    #
    def buffer(string)
      @template << [:buffer, string]
    end

    # Output and escape an object stream into the template
    #
    # @param string [String] Buffer input string
    #
    def buffer_escape(string)
      @template << [:escape, string]
    end

    # Output and freeze a String stream into the template
    #
    # @param string [String] Buffer input string
    #
    def buffer_freeze(string)
      if @template[-1][0] == :freeze
        @template[-1][1] += string
      else
        @template << [:freeze, string]
      end
    end

    # Evaluate a stream into the template
    #
    # @param string [String] Buffer input string
    #
    def buffer_eval(string)
      @template << [:eval, string]
    end

    # Set a local variable through buffer eval an object stream into
    # the template
    #
    # @param name [String] Variable identifier to be set
    # @param name [String] Variable value to be set
    #
    def buffer_set_variable(name, value)
      local_variable = "_opulent_#{name}_#{@current_variable_count += 1}"
      buffer_eval "#{local_variable} = #{value}"
      local_variable
    end

    # Remove last n characters from the most recent template item
    #
    # @param type [Symbol] Remove only if last buffer part is of this type
    # @param n [Fixnum] Number of characters to be removed
    #
    def buffer_remove_last_character(type = :freeze, n = 1)
      @template[-1][1] = @template[-1][1][0..-1 - n] if @template[-1][0] == type
    end

    # Remove last n characters from the most recent template item
    #
    # @param type [Symbol] Remove only if last buffer part is of this type
    # @param n [Fixnum] Number of characters to be removed
    #
    def buffer_remove_trailing_whitespace(type = :freeze)
      if @template[-1][0] == type
        n = @template[-1][1][/\s$/]
        return if n.nil?

        @template[-1][1] = @template[-1][1][0..-1 - n.size]
      end
    end

    # Turn call node attributes into a hash string
    #
    # @param attributes [Array] Array of node attributes
    #
    def buffer_attributes_to_hash(attributes)
      '{' + attributes.inject([]) do |extend_map, (key, attribute)|
        extend_map << (
          ":\"#{key}\" => " + if key == :class
                                '[' + attribute.map do |exp|
                                  exp[@value]
                                end.join(', ') + ']'
                              else
                                attribute[@value]
                              end
        )
      end.join(', ') + '}'
    end

    # Go through the node attributes and apply extension where needed
    #
    # @param attributes [Array] Array of node attributes, from parser
    # @param extension [String] Extension identifier
    #
    def buffer_attributes(attributes, extension)
      # Proc for setting class attribute extension, used as DRY closure
      #
      buffer_class_attribute_type_check = proc do |variable, escape = true|
        class_variable = buffer_set_variable :local, variable

        # Check if we need to add the class attribute
        buffer_eval "unless #{class_variable} and true === #{class_variable}"

        # Check if class attribute has array value
        buffer_eval "if Array === #{class_variable}"
        ruby_code = "#{class_variable}.join ' '"
        if escape
          buffer_escape ruby_code
        else
          buffer ruby_code
        end

        # Check if class attribute has hash value
        buffer_eval "elsif Hash === #{class_variable}"
        ruby_code = "#{class_variable}.to_a.join ' '"
        if escape
          buffer_escape ruby_code
        else
          buffer ruby_code
        end

        # Other values
        buffer_eval 'else'
        ruby_code = "#{class_variable}"
        if escape
          buffer_escape ruby_code
        else
          buffer ruby_code
        end

        # End cases
        buffer_eval 'end'

        # End
        buffer_eval 'end'
      end

      # Handle class attributes by checking if they're simple, noninterpolated
      # strings or not and extend them if needed
      #
      buffer_class_attribute = proc do |attribute|
        if attribute[@value] =~ Tokens[:exp_string_match]
          buffer_split_by_interpolation attribute[@value][1..-2],
                                        attribute[@options][:escaped]
        else
          buffer_class_attribute_type_check[
            attribute[@value],
            attribute[@options][:escaped]
          ]
        end
      end

      # If we have class attributes, process each one and check if we have an
      # extension for them
      if attributes[:class]
        buffer_freeze " class=\""

        # Process every class attribute
        attributes[:class].each do |node_class|
          buffer_class_attribute[node_class]
          buffer_freeze ' '
        end

        # Remove trailing whitespace from the buffer
        buffer_remove_last_character

        # Check for extension with :class key
        if extension
          buffer_eval "if #{extension[:name]}.has_key? :class"
          buffer_freeze ' '
          buffer_class_attribute_type_check[
            "#{extension[:name]}.delete(:class)"
          ]
          buffer_eval 'end'
        end

        buffer_freeze '"'
      elsif extension
        # If we do not have class attributes but we do have an extension, try to
        # see if the extension contains a class attribute
        buffer_eval "if #{extension[:name]}.has_key? :class"
        buffer_freeze " class=\""
        buffer_class_attribute_type_check["#{extension[:name]}.delete(:class)"]
        buffer_freeze '"'
        buffer_eval 'end'
      end

      # Proc for setting class attribute extension, used as DRY closure
      #
      buffer_data_attribute_type_check = proc do |key, variable, escape = true, dynamic = false|
        # Check if variable is set
        buffer_eval "if #{variable}"

        # @Array
        buffer_eval "if Array === #{variable}"
        dynamic ? buffer("\" #{key}=\\\"\"") : buffer_freeze(" #{key}=\"")

        ruby_code = "#{variable}.join '_'"
        if escape
          buffer_escape ruby_code
        else
          buffer ruby_code
        end

        buffer_freeze '"'

        # @Hash
        buffer_eval "elsif Hash === #{variable}"
        buffer_eval "#{variable}.each do |#{OPULENT_KEY}, #{OPULENT_VALUE}|"
        # key-hashkey
        dynamic ? buffer("\" #{key}-\"") : buffer_freeze(" #{key}-")
        buffer "#{OPULENT_KEY}.to_s"
        #="value"
        buffer_freeze "=\""
        escape ? buffer_escape(OPULENT_VALUE) : buffer(OPULENT_VALUE)
        buffer_freeze '"'
        buffer_eval 'end'

        # @TrueClass
        buffer_eval "elsif true === #{variable}"
        dynamic ? buffer("\" #{key}\"") : buffer_freeze(" #{key}")

        # @Object
        buffer_eval 'else'
        dynamic ? buffer("\" #{key}=\\\"\"") : buffer_freeze(" #{key}=\"")
        escape ? buffer_escape("#{variable}") : buffer("#{variable}")
        buffer_freeze '"'

        # End Cases
        buffer_eval 'end'

        # End
        buffer_eval 'end'
      end

      # Handle data (normal) attributes by checking if they're simple, noninterpolated
      # strings and extend them if needed
      #
      buffer_data_attribute = proc do |key, attribute|
        # When we have an extension for our attributes, check current key.
        # If it exists, check it's type and generate everything dynamically
        if extension
          buffer_eval "if #{extension[:name]}.has_key? :\"#{key}\""
          variable = buffer_set_variable :local,
                                         "#{extension[:name]}" \
                                         ".delete(:\"#{key}\")"
          buffer_data_attribute_type_check[
            key,
            variable,
            attribute[@options][:escaped]
          ]
          buffer_eval 'else'
        end

        # Check if the set attribute is a simple string. If it is, freeze it or
        # escape it. Otherwise, evaluate and initialize the type check.
        if attribute[@value] =~ Tokens[:exp_string_match]
          buffer_freeze " #{key}=\""
          buffer_split_by_interpolation attribute[@value][1..-2],
                                        attribute[@options][:escaped]
          buffer_freeze "\""
        else
          # Evaluate and type check
          variable = buffer_set_variable :local, attribute[@value]
          buffer_data_attribute_type_check[
            key,
            variable,
            attribute[@options][:escaped]
          ]
        end

        # Extension end
        buffer_eval 'end' if extension
      end

      # Process the remaining, non-class related attributes
      attributes.each do |key, attribute|
        next if key == :class
        buffer_data_attribute[key, attribute]
      end

      # Process remaining extension keys if there are any
      return unless extension

      buffer_eval "#{extension[:name]}.each do " \
                  "|ext#{OPULENT_KEY}, ext#{OPULENT_VALUE}|"

      buffer_data_attribute_type_check[
        "\#{ext#{OPULENT_KEY}}",
        "ext#{OPULENT_VALUE}",
        extension[:escaped],
        true
      ]
      buffer_eval 'end'
    end

    # Transform buffer array into a reusable template
    #
    def templatize
      separator = DEBUG ? "\n" : '; ' # Readablity during development
      @template.map do |input|
        case input[0]
        when :preamble
          "#{BUFFER} = []#{separator}"
        when :buffer
          "#{BUFFER} << (#{input[1]})#{separator}"
        when :escape
          "#{BUFFER} << (::Opulent::Utils::escape(#{input[1]}))#{separator}"
        when :freeze
          "#{BUFFER} << (#{input[1].inspect}.freeze)#{separator}"
        when :eval
          "#{input[1]}#{separator}"
        when :postamble
          "#{BUFFER}.join"
        end
      end.join
    end

    # Split a string by its interpolation, then check if it really needs to be
    # escaped or not. Huge performance boost!
    #
    # @param string [String] Input string
    # @param escape [Boolean] Escape string
    #
    # @ref slim-lang Thank you for the interpolation code
    #
    def buffer_split_by_interpolation(string, escape = true)
      # Interpolate variables in text (#{variable}).
      # Split the text into multiple dynamic and static parts.
      begin
        case string
        when /\A\\\#\{/
          # Escaped interpolation
          buffer_freeze '#{'
          string = $'
        when /\A#\{((?>[^{}]|(\{(?>[^{}]|\g<1>)*\}))*)\}/
          # Interpolation
          string = $'
          code = $1

          # escape = code !~ /\A\{.*\}\Z/
          if escape
            buffer_escape code
          else
            buffer code
          end
        when /\A([\\#]?[^#\\]*([#\\][^\\#\{][^#\\]*)*)/
          string_remaining = $'
          string_current = $&

          # Static text
          if escape && string_current =~ Utils::ESCAPE_HTML_PATTERN
            buffer_escape string_current.inspect
          else
            buffer_freeze string_current
          end

          string = string_remaining
        end
      end until string.empty?
    end
  end
end
