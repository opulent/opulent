# @Opulent
module Opulent
  # @Filter
  module Filter
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
        unless @loaded
          # Try to load the library associated to the chosen filter
          begin
            require gem_name
            @loaded = true
          rescue LoadError => error
            # Error output with filter name and installation instructions
            Runtime.error :filter_load, @name, install_error
          end
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
      def render(code, options = {})
        raise NoMethodError
      end

      # RubyGems name for explicit library require
      #
      def gem_name
        raise NoMethodError
        # "gem_name"
      end

      # After defining how to render the code,
      #
      # Engine.register self, :filter, tag: :tag, attributes: { type: 'text/css' }
    end


    # Add the  default registered rendering filters for Opulent

    # @CoffeeScript
    class CoffeeScript < Filter
      def render(code, options = {})
        ::CoffeeScript.compile code, options
      end

      def gem_name
        "coffee-script"
      end

      Engine.register self, :coffeescript, tag: :script, attributes: { type: 'javascript' }
    end

    # @Scss
    class Scss < Filter
      def render(code, options = {})
        ::Sass.compile code, options
      end

      def gem_name
        "sass"
      end

      Engine.register self, :scss, tag: :style, attributes: { type: 'text/css' }
    end

    # @Sass
    class Sass < Filter
      def render(code, options = {})
        options[:syntax] = :sass
        ::Sass.compile code, options
      end

      def gem_name
        "sass"
      end

      Engine.register self, :sass, tag: :style, attributes: { type: 'text/css' }
    end
  end
end
