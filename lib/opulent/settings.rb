# @Opulent
module Opulent
  # @Settings
  module Settings
    # Default Opulent allowed file extensions
    Extensions = %w(op opl opulent)

    # Default yield target which is used for child block replacements
    DefaultYield = :children

    # Default yield target which is used for child block replacements
    DefaultEachKey = :key

    # Default yield target which is used for child block replacements
    DefaultEachValue = :value

    # List of self enclosing node elements
    SelfEnclosing = %i(img link input meta br hr area base col command embed keygen param source track wbr)

    # List of inline node parents which can be either inline or have complex
    # structures inside of them, such as anchor tags
    MultiNode = %i(a)

    # List of inline node names
    InlineNode = %i(text a span strong em br i b small label sub sup abbr var code kbd)

    # Check whether text should or shouldn't be evaluated
    InterpolationCheck = /(?<!\\)\#\{.*\}/

    # Check if the attribute value is a bare string
    EvaluationCheck = /\A(("((?:[^"\\]|\\.)*?)")|('(?:[^'\\]|\\.)*?')|true|false|nil)\Z/

    # Shorthand attribute associations
    Shorthand = {
      :'.' => :class,
      :'#' => :id,
      :'&' => :name
    }

    # @Singleton
    class << self
      # Opulent runtime options
      Defaults = {
        pretty: true,
        indent: 2,
        dependency_manager: true
      }

      # Set defaults as initial options
      @@options = Defaults

      # Get an option at runtime
      #
      # @param name [Symbol] Identifier for the option
      #
      def [](name)
        @@options[name]
      end

      # Set a new option at runtime
      #
      # @param name [Symbol] Identifier for the option
      # @param value Option value to be set
      #
      def []=(name, value)
        @@options[name] = value
      end

      # Update the engine options with the required option changes
      #
      # @param opts [Hash] Option extension hash
      #
      def update_settings(opts)
        @@options = Defaults

        opts.each do |key, value|
          @@options[key] = value
        end
      end
    end
  end
end
