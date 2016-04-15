# @Opulent
module Opulent
  # @OpulentTemplate
  class Template < ::Tilt::Template
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
      @options[:file] = eval_file
      @engine = ::Opulent.new @data, @options
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
      @engine.src
    end
  end

  # Register Opulent to Tilt
  ::Tilt.register Template, 'opulent', 'op'
end
