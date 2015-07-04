# @Opulent
module Opulent
  # @Runtime
  module Runtime
    # @Singleton
    class << self
      # All node Objects (Array) must follow the next convention in order
      # to make parsing faster
      #
      # [:node_type, :value, :attributes, :children, :indent]
      #
      def setup
        @type = 0
        @value = 1
        @options = 2
        @children = 3
        @indent = 4
      end

      # Apply given context to node attributes through evaluation
      #
      # @param attributes [Hash] Node attributes
      # @param extension [String] Inline attributes extension code
      # @param context [Context] Context holding environment variables
      #
      def attributes(attributes, extension, context)
        return attributes unless extension

        extension = eval

        extension.each do |key, value|
          pp value
          case attributes[key]
          when Array
            attributes[key] = (attributes[key] << value).flatten
          when Hash
            attributes[key] = value.merge attributes[key]
          else
            attributes[key] = value
          end
        end

        attributes
      end
    end
  end
end
