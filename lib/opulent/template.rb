# @Opulent
module Opulent
  # @OpulentTemplate
  class OpulentTemplate < ::Tilt::Template
    self.default_mime_type = 'text/html'

    # Do whatever preparation is necessary to setup the underlying template
    # engine. Called immediately after template data is loaded. Instance
    # variables set in this method are available when #evaluate is called.
    #
    # Subclasses must provide an implementation of this method.
    #
    def prepare
      # Set the file which is being evaluated
      @options[:file] = eval_file

      # Enable caching for the current rendered file
      @options[:cache] = true

      # Set up the rendering engine
      @engine = ::Opulent.new @options
      #@engine.update_options @options
    end

    # Execute the compiled template and return the result string. Template
    # evaluation is guaranteed to be performed in the scope object with the
    # locals specified and with support for yielding to the block.
    #
    # This method is only used by source generating templates. Subclasses that
    # override render() may not support all features.
    #
    def evaluate(scope, locals, &block)
      # if @engine.respond_to?(:precompiled_method_return_value, true)
      #   super
      # else
      #   @engine.render(data, locals, &block)
      # end
      if @engine.preamble
        super
      else
        locals[:scope] = scope
        @engine.render(data, locals, &block)
      end
    end

    # A string containing the (Ruby) source code for the template. The
    # default Template#evaluate implementation requires either this
    # method or the #precompiled method be overridden. When defined,
    # the base Template guarantees correct file/line handling, locals
    # support, custom scopes, proper encoding, and support for template
    # compilation.
    #
    def precompiled_template(locals)
      # This here should be evaluated in order to return the precompiled code
      # as text to the user.
      # For example:
      # _buff = [] # This should be in preamble
      # _buff << "<html>",
      # _buff << compile('a * b')
      # _buff << "</html>"
      @engine.preamble
    end
  end

  # Register Opulent to Tilt
  ::Tilt.register OpulentTemplate, 'op', 'opl', 'opulent'
end
