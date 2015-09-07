# @Opulent
module Opulent
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

    # Set a local variable through buffer eval an object stream into the template
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
    # @param n [Fixnum] Number of characters to be removed
    #
    def buffer_remove_last_character(type = :freeze, n = 1)
      @template[-1][1] = @template[-1][1][0..-1-n] if @template[-1][0] == type
    end

    # Go through the node attributes and apply extension where needed
    #
    # @param attributes [Array] Array of node attributes, from parser
    # @param extension [String] Extension identifier
    #
    def buffer_attributes(attributes, extension)
      # Proc for setting class attribute extension, used as DRY closure
      #
      buffer_class_attribute_type_check = Proc.new do |escape = true|
        class_variable = buffer_set_variable :local, "#{extension}.delete(:class)"
        buffer_eval "if #{class_variable}.is_a? Array"
        escape ? buffer_escape("#{class_variable}.join ' '") : buffer("#{class_variable}.join ' '")
        buffer_eval "elsif #{class_variable}.is_a? Hash"
        escape ? buffer_escape("#{class_variable}.to_a.join ' '") : buffer("#{class_variable}.to_a.join ' '")
        buffer_eval "elsif [TrueClass, NilClass, FalseClass].include? #{class_variable}.class"
        buffer_eval "else"
        escape ? buffer_escape("#{class_variable}") : buffer("#{class_variable}")
        buffer_eval "end"
      end

      # Handle class attributes by checking if they're simple, noninterpolated
      # strings and extend them if needed
      #
      buffer_class_attribute = Proc.new do |attribute|
        if attribute[@value] =~ Tokens[:exp_string]
          attribute[@value] = attribute[@value][1..-2]
          if attribute[@options][:escaped] && attribute[@value] =~ Utils::EscapeHTMLPattern
            buffer_escape attribute[@value]
          else
            buffer_freeze attribute[@value]
          end
        else
          buffer_class_attribute_type_check[attribute[@options][:escaped]]
        end
      end

      # If we have class attributes, process each one and check if we have an
      # extension for them
      if attributes[:class]
        buffer_freeze " class=\""

        # Process every class attribute
        attributes[:class].each do |node_class|
          buffer_class_attribute[node_class]
          buffer_freeze " "
        end

        # Remove trailing whitespace from the buffer
        buffer_remove_last_character

        # Check for extension with :class key
        if extension
          buffer_eval "if #{extension}.has_key? :class"
          buffer_freeze " "
          buffer_class_attribute_type_check[]
          buffer_eval "end"
        end

        buffer_freeze '"'
      elsif extension
        # If we do not have class attributes but we do have an extension, try to
        # see if the extension contains a class attribute
        buffer_eval "if #{extension}.has_key? :class"
        buffer_freeze " class=\""
        buffer_class_attribute_extension[]
        buffer_freeze '"'
        buffer_eval "end"
      end

      # Process the remaining, non-class related attributes
      attributes.each do |key, attribute|
        next if key == :class

      end
    end

    # Transform buffer array into a reusable template
    #
    def templatize
      separator = "\n" # Readablity during development
      @template.inject("") do |buffer, input|
        buffer += case input[0]
        when :preamble
          "#{Buffer} = []#{separator}"
        when :buffer
          "#{Buffer} << (#{input[1]})#{separator}"
        when :escape
          "#{Buffer} << (::Opulent::Utils::escape(#{input[1]}))#{separator}"
        when :freeze
          "#{Buffer} << (#{input[1].inspect}.freeze)#{separator}"
        when :eval
          "#{input[1]}#{separator}"
        when :postamble
          "#{Buffer}.join"
        end
      end
    end

    # Split a string by its interpolation, then check if it really needs to be
    # escaped or not. Huge performance boost!
    #
    # @param string [String] Input string
    # @param escape [Boolean] Escape string
    #
    def buffer_split_by_interpolation(string, escape = true)
      string.split(Utils::InterpolationPattern).each_with_index do |input, index|
        if index % 2 == 0
          escape ? (input =~ Utils::EscapeHTMLPattern ? buffer_escape(input) : buffer_freeze(input)) : buffer_freeze(input)
        else
          escape ? buffer_escape(input) : buffer(input)
        end
      end
    end
  end
end
