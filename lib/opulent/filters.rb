# @Opulent
module Opulent
  # @Filters
  module Filters
    # @Singleton
    class << self
      attr_accessor :filters

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
        @filters.key? name
      end
    end

    # @Filter
    class Filter
      attr_accessor :name, :options, :loaded

      # Set tag and attribute options for filter
      #
      def initialize(name, options)
        @name = name
        @options = options
        @loaded = false
      end

      # Error output in case the filter does not exist
      #
      def load_filter
        return unless gem_name.nil? || @loaded

        # Try to load the library associated to the chosen filter
        begin
          require gem_name
          @loaded = true
        rescue LoadError
          # Error output with filter name and installation instructions
          Compiler.error :filter_load, @name, install_error
        end
      end

      # Error message to be shown in order to provide installation instructions
      # for the developer
      #
      def install_error
        "gem install #{gem_name}"
      end

      # Process input code using this filter and return the output to the
      # evaluation method from the Filter Node
      #
      def render(_code, _options = {})
        fail NoMethodError
      end

      # RubyGems name for explicit library require
      #
      def gem_name
        fail NoMethodError
        # "gem_name"
      end

      # After defining how to render the code,
      #
      # Filters.register self, :filter, tag: :tag,
      #   attributes: { type: 'text/css' }
    end

    # Add the  default registered rendering filters for Opulent

    # @CoffeeScript
    class CoffeeScript < Filter
      def render(code, options = {})
        ::CoffeeScript.compile code, options
      end

      def gem_name
        'coffee-script'
      end

      Filters.register self,
                       :coffeescript,
                       tag: :script,
                       attributes: { type: 'javascript' }
    end

    # @JavaScript
    class JavaScript < Filter
      def render(code, _options = {})
        code
      end

      def gem_name
        nil
      end

      Filters.register self,
                       :javascript,
                       tag: :script,
                       attributes: { type: 'javascript' }
    end

    # @Scss
    class Scss < Filter
      def render(code, options = {})
        options[:style] ||= :expanded

        ::Sass.compile code, options
      end

      def gem_name
        'sass'
      end

      Filters.register self,
                       :scss,
                       tag: :style,
                       attributes: { type: 'text/css' }
    end

    # @Sass
    class Sass < Filter
      def render(code, options = {})
        options[:syntax] = :sass
        options[:style] ||= :expanded

        ::Sass.compile code, options
      end

      def gem_name
        'sass'
      end

      Filters.register self,
                       :scss,
                       tag: :style,
                       attributes: { type: 'text/css' }
    end

    # @Css
    class Css < Filter
      def render(code, options = {})
        if options[:cdata]
          "<![CDATA[\n" + code + ']]>'
        else
          code
        end
      end

      def gem_name
        nil
      end

      Filters.register self, :css, tag: :style, attributes: { type: 'text/css' }
    end

    # @CData
    class CData < Filter
      def render(code, _options = {})
        "<![CDATA[\n" + code + ']]>'
      end

      def gem_name
        nil
      end

      Filters.register self, :cdata, tag: nil, attributes: {}
    end

    # @Escaped
    class Escaped < Filter
      def render(code, _options = {})
        Compiler.escape code
      end

      def gem_name
        nil
      end

      Filters.register self, :escaped, tag: nil, attributes: {}
    end

    # @Markdown
    class Markdown < Filter
      def render(code, options = {})
        ::Kramdown::Document.new(code, options).to_html
      end

      def gem_name
        'kramdown'
      end

      Filters.register self, :markdown, tag: nil, attributes: {}
    end

    # @Maruku
    class Maruku < Filter
      def render(code, options = {})
        ::Maruku.new(code, options).to_html
      end

      def gem_name
        'maruku'
      end

      Filters.register self, :maruku, tag: nil, attributes: {}
    end

    # @RedCloth
    class RedCloth < Filter
      def render(code, options = {})
        ::RedCloth.new(code, options).to_html
      end

      def gem_name
        'RedCloth'
      end

      Filters.register self, :textile, tag: nil, attributes: {}
    end
  end
end
