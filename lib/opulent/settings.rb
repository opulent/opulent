# @Opulent
module Opulent
  # @Settings
  module Settings
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
      \A(("((?:[^"\\]|\\.)*?)")|('(?:[^'\\]|\\.)*?')|true|false|nil)\Z
    }

    # Shorthand attribute associations
    SHORTHAND = {
      '.': :class,
      '#': :id,
      '&': :name
    }

    # @Singleton
    class << self
      # Opulent runtime options
      DEFAULTS = {
        # pretty: true, # At the moment, code cannot be uglified
        # dependency_manager: true, # Soon to be implemented
        indent: 2,
        layouts: false,
        pretty: false, # Under work
        default_layout: :'views/layouts/application'
      }

      # Set defaults as initial options
      @options = DEFAULTS

      # Get an option at runtime
      #
      # @param name [Symbol] Identifier for the option
      #
      def [](name)
        @options[name]
      end

      # Set a new option at runtime
      #
      # @param name [Symbol] Identifier for the option
      # @param value Option value to be set
      #
      def []=(name, value)
        @options[name] = value
      end

      # Update the engine options with the required option changes
      #
      # @param opts [Hash] Option extension hash
      #
      def update_settings(opts)
        @options = DEFAULTS

        opts.each do |key, value|
          @options[key] = value
        end
      end
    end
  end
end
