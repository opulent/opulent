# @SugarCube
module Opulent
  # @Engine
  module Engine
    # Default (root) theme name which can be accesed using the root definitions
    DEFAULT_THEME = :default

    # Default yield target which is used for child block replacements
    DEFAULT_YIELD = :children

    # List of self enclosing node elements
    SELF_ENCLOSING = %w(img link input meta br hr area base col command embed keygen param source track wbr)

    # @Singleton
    class << self
      attr_accessor :filters, :options

      # Opulent runtime options
      @@defaults = {
        pretty: true,
        indent: 2,
        dependency_manager: true,
        shorthand: {
          class: /\./,
          id: /\#/,
          name: /\&/
        },
        each: {
          :default_key => :key,
          :default_value => :value
        }
      }

      # Set defaults as initial options
      @@options = @@defaults.clone

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

      # Add a new Opulent filter to the filters knowledgebase
      #
      # @param class [Class] Class to be used for filter instance
      # @param name [Symbol] Identifier in the filters hash
      # @param options [Hash] Filter engine instance options
      #
      def register(klass, name, options)
        @filters ||= {}
        @filters[name] = klass.new name, options
      end

      # Check if the chosen filter name is registed within our knowledgebase
      #
      def filter?(name)
        @filters.has_key? name
      end

      # Update the engine options with the required option changes
      #
      # @param opts [Hash] Option extension
      #
      def update_options(opts)
        @@options = @@defaults.clone

        opts.each do |key, value|
          if @@options[key]
            @@options[key] = value
          else
            error :options_key, key
          end
        end
      end
    end
  end
end
