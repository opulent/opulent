# @Opulent
module Opulent
  # @Settings
  class Settings
    # Set buffer variable name
    BUFFER = :@_opulent_buffer

    # Default Opulent file extension
    FILE_EXTENSION = '.op'

    # Default yield target which is used for child block replacements
    DEFAULT_EACH_KEY = :key

    # Default yield target which is used for child block replacements
    DEFAULT_EACH_VALUE = :value

    # List of self enclosing node elements
    SELF_ENCLOSING = %i(
      img link input meta br hr area base col command embed keygen param source
      track wbr
    )

    # List of inline node parents which can be either inline or have complex
    # structures inside of them, such as anchor tags
    MULTI_NODE = %i(a)

    # List of inline node names
    INLINE_NODE = %i(
      text a span strong em br i b small label sub sup abbr var code kbd
    )

    # Check whether text should or shouldn't be evaluated
    INTERPOLATION_CHECK = /(?<!\\)\#\{.*\}/

    # Check if the attribute value is a bare string
    EVALUATION_CHECK = %r{
      \A(
        ("((?:[^"\\]|\\.)*?)")|
        ('(?:[^'\\]|\\.)*?')|
        true|
        false|
        nil
      )\Z
    }

    # Shorthand attribute associations
    SHORTHAND = {
      '.': :class,
      '#': :id,
      '&': :name
    }

    # Opulent runtime settings
    DEFAULTS = {
      # dependency_manager: true, # Soon to be implemented
      indent: 2,
      layouts: false,
      pretty: false,
      default_layout: :'views/layouts/application'
    }

    # Set defaults as initial settings
    #
    def initialize
      @settings = DEFAULTS
    end

    # Get an option at runtime
    #
    # @param name [Symbol] Identifier for the option
    #
    def [](name)
      @settings[name]
    end

    # Set a new option at runtime
    #
    # @param name [Symbol] Identifier for the option
    # @param value Option value to be set
    #
    def []=(name, value)
      @settings[name] = value
    end

    # Remove an option at runtime
    #
    # @param name [Symbol] Identifier for the option
    # @param value Option value to be set
    #
    def delete(name)
      @settings.delete name
    end

    # Update the engine settings with the required option changes
    #
    # @param opts [Hash] Option extension hash
    #
    def update_settings(opts)
      @settings = DEFAULTS

      opts.each do |key, value|
        @settings[key] = value
      end
    end
  end
end
