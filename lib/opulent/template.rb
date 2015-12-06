# @Opulent
module Opulent
  # @OpulentTemplate
  class OpulentTemplate < ::Tilt::Template
    # Allow accessing engine definitions
    attr_reader :def

    # Set default mime type
    self.default_mime_type = 'text/html'

    # Do whatever preparation is necessary to setup the underlying template
    # engine. Called immediately after template data is loaded. Instance
    # variables set in this method are available when #evaluate is called.
    #
    # Subclasses must provide an implementation of this method.
    #
    def prepare
      # Set up the rendering engine
      @engine = ::Opulent.new eval_file.to_sym, @options

      # Set reusable template definitions
      @def = @engine.def
    end

    # Execute the compiled template and return the result string. Template
    # evaluation is guaranteed to be performed in the scope object with the
    # locals specified and with support for yielding to the block.
    #
    # This method is only used by source generating templates. Subclasses that
    # override render() may not support all features.
    #
    def evaluate(scope, locals, &block)
      fail ArgumentError, 'Invalid scope: must not be frozen.' if scope.frozen?
      super
    end

    # A string containing the (Ruby) source code for the template. The
    # default Template#evaluate implementation requires either this
    # method or the #precompiled method be overridden. When defined,
    # the base Template guarantees correct file/line handling, locals
    # support, custom scopes, proper encoding, and support for template
    # compilation.
    #
    def precompiled_template(_locals = {})
      @engine.template
    end
  end

  # Register Opulent to Tilt
  ::Tilt.register OpulentTemplate, 'opulent', 'op'
end

# @Sinatra
module Sinatra
  # @Templates
  module Templates
    def opulent(template, options = {}, locals = {}, &block)
      render :op, template, options, locals, &block
    end

    def compile_template(engine, data, options, views)
      eat_errors = options.delete :eat_errors
      template_cache.fetch engine, data, options, views do
        template = Tilt[engine]
        raise "Template engine not found: #{engine}" if template.nil?

        case data
        when Symbol
          body, path, line = settings.templates[data]
          if body
            body = body.call if body.respond_to?(:call)
            template.new(path, line.to_i, options) { body }
          else
            found = false
            @preferred_extension = engine.to_s
            find_template(views, data, template) do |file|
              path ||= file # keep the initial path rather than the last one
              if found = File.exist?(file)
                path = file
                break
              end
            end
            throw :layout_missing if eat_errors and not found
            template.new(path, 1, options)
          end
        when Proc, String
          body = data.is_a?(String) ? Proc.new { data } : data
          path, line = settings.caller_locations.first
          template.new(path, line.to_i, options, &body)
        else
          raise ArgumentError, "Sorry, don't know how to render #{data.inspect}."
        end
      end
    end
  end
end
