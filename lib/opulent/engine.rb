# @Opulent
module Opulent
  # Debug enable
  #
  DEBUG = false

  # Module method wrapper for creating a new engine instance
  #
  def Opulent.new(settings = {})
    return Engine.new settings
  end

  # @Engine
  class Engine
    attr_reader :nodes, :definitions, :parser, :file, :template, :buffer

    # Update render settings
    #
    # @param settings [Hash] Opulent settings override
    # @param definitions [Hash] Definitions from previously parsed files
    # @param overwrite [Boolean] Write changes directly to the parent binding
    #
    def initialize(settings = {})
      @definitions = {}

      Settings.update_settings settings unless settings.empty?
    end

    # Avoid code duplication when layouting is set. When we have a layout, look
    # in layouts/application by default.
    #
    # @param file [String] The file that needs to be analyzed
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def render(input, locals = {}, &block)
      # If a layout is set, get the specific layout, otherwise, set the default
      # one. If a layout is set to false, the page will be render as it is.
      if Settings[:layouts]
        layout = locals.has_key?(:layout) ? locals.delete(:layout) : Settings[:default_layout]

        # Process with the built in layout system
        process layout, locals, block do
          process input, locals, block, &block
        end
      else
        # We pass the same block as content block, in case we're using a
        # different yielding system from within a web framework using Tilt
        process input, locals, block, &block
      end
    end

    # Analyze the input code and check for matching tokens. In case no match was
    # found, throw an exception. In special cases, modify the token hash.
    #
    # @param file [String] The file that needs to be analyzed
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def process(input, locals, block, &content)
      # Read input parameter based on opening mode. If we have a file mode, we
      # get its path and read the code. We need to reset the mode in case the next
      # render call is on code, not on a file.
      @code = case input
      when Symbol
        @file = File.expand_path "#{input}#{Settings::FileExtension}"
        File.read @file
      else
        @file = File.expand_path __FILE__
        input
      end

      # Get the nodes tree
      @nodes, @definitions = Parser.new(@file, @definitions).parse @code

      # Create a new context based on our rendering environment
      @context = Context.new locals, block, &content

      # Compile our syntax tree using input context
      @template = Compiler.new.compile @nodes, @context

      if DEBUG
        #puts "Nodes\n---\n"
        #pp @nodes

        # puts "\n\nCode\n---\n"
        # pp @output
      end

      return @context.evaluate @template
    end

    def evaluate(scope, locals, &block)
      #@context.extend_locals locals
      @precompiled.inject("") do |output, chunk|
        if chunk[0] == :eval
          @context.evaluate chunk[1]
        elsif chunk[0] == :buffer
          output += @context.evaluate chunk[1]
        else
          output += chunk[1]
        end
      end
    end
  end
end
