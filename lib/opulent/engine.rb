# @Opulent
module Opulent
  # Debug enable
  #
  DEBUG = false

  # Module method wrapper for creating a new engine instance
  #
  def self.new(input, settings = {})
    Engine.new input, settings
  end

  # @Engine
  class Engine
    attr_reader :nodes, :parser, :def, :file, :template, :buffer

    # Update render settings
    #
    # @param settings [Hash] Opulent settings override
    # @param def [Hash] def from previously parsed files
    # @param overwrite [Boolean] Write changes directly to the parent binding
    #
    def initialize(input, settings = {})
      # Set def from other Opulent instances
      @def = settings.delete(:def) || {}

      # Update default settings with user settings
      Settings.update_settings settings unless settings.empty?

      # Read input parameter based on opening mode. If we have a file mode, we
      # get its path and read the code. We need to reset the mode in case the
      # next render call is on code, not on a file.
      @code = read input

      # Get the nodes tree
      @nodes, @def = Parser.new(@file, @def).parse @code

      # Compile our syntax tree using input context
      @template = Compiler.new.compile @nodes
    end

    # Read input as file or string input
    #
    # @param input [Object]
    #
    def read(input)
      if input.is_a? Symbol
        @file = File.expand_path get_eval_file input
        File.read @file
      else
        @file = File.expand_path __FILE__
        input
      end
    end

    # Avoid code duplication when layouting is set. When we have a layout, look
    # in layouts/application by default.
    #
    # @param scope [Object] Template evaluation context
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def render(scope = Object.new, locals = {}, &block)
      # Get opulent buffer value
      if scope.instance_variable_defined?(:@_opulent_buffer)
        initial_buffer = scope.instance_variable_get(:@_opulent_buffer)
      else
        initial_buffer = []
      end

      # If a layout is set, get the specific layout, otherwise, set the default
      # one. If a layout is set to false, the page will be render as it is.
      if scope.is_a? binding.class
        scope_object = eval 'self', scope
        scope = scope_object.instance_eval { binding } if block_given?
      else
        scope_object = scope
        scope = scope_object.instance_eval { binding }
      end

      # Set input local variables in current scope
      locals.each do |key, value|
        scope.local_variable_set key, value
      end

      # Evaluate the template in the given scope (context)
      begin
        p "HELLO", @template
        eval @template, scope
      rescue ::SyntaxError => e
        raise SyntaxError, e.message
      ensure
        # Get rid of the current buffer
        scope_object.instance_variable_set :@_opulent_buffer, initial_buffer
      end
    end

    private

    # Add .op extension to input file if it isn't already set.
    #
    # @param input [Symbol] Input file
    #
    def get_eval_file(input)
      input = input.to_s
      unless File.extname(input) == Settings::FILE_EXTENSION
        input += Settings::FILE_EXTENSION
      end
      input
    end
  end
end
