# @Opulent
module Opulent
  # @Parser
  module Filters
    # @Singleton
    class << self
      # Add a new Opulent filter to the filters knowledgebase
      #
      # @param class [Class] Class to be used for filter instance
      # @param name [Symbol] Identifier in the filters hash
      # @param options [Hash] Filter engine instance options
      #
      def register_filter(klass, name, options)
        @filters[name] = klass.new name, options
      end

      # Check if the chosen filter name is registed within our knowledgebase
      #
      def has_filter?(name)
        @filters.has_key? name
      end
    end
  end
end
