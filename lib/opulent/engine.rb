# @Opulent
module Opulent
  # Module method wrapper for creating a new engine instance
  #
  def Opulent.new(settings = {})
    return Engine.new settings
  end

  # @Engine
  class Engine
    attr_reader :nodes, :definitions, :parser, :file, :preamble, :buffer

    # Update render settings
    #
    # @param settings [Hash] Opulent settings override
    # @param definitions [Hash] Definitions from previously parsed files
    # @param overwrite [Boolean] Write changes directly to the parent binding
    #
    def initialize(settings = {})
      @definitions = settings[:definitions] || {}
      @overwrite = settings.delete :overwrite

      Settings.update_settings settings unless settings.empty?
    end

    # Analyze the input code and check for matching tokens. In case no match was
    # found, throw an exception. In special cases, modify the token hash.
    #
    # @param file [String] The file that needs to be analyzed
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def render_file(file, locals = {}, &block)
      @mode = :file

      render file, locals, &block
    end

    # Analyze the input code and check for matching tokens. In case no match was
    # found, throw an exception. In special cases, modify the token hash.
    #
    # @param file [String] The file that needs to be analyzed
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def render(input, locals = {}, &block)
      # Get input code
      @code = read input

      # Get the nodes tree
      @nodes = Parser.new(@file).parse @code

      # @TODO
      # Implement precompiled template handling
      @preamble = @nodes.inspect.inspect

      # Create a new context based on our rendering environment
      @context = Context.new locals, &block

      # Compile our syntax tree using input context
      @output = Compiler.new.compile @nodes, @context

      # puts "Nodes\n---\n"
      # pp @nodes
      #
      # puts "\n\nCode\n---\n"
      # puts @output

      return @output
    end

    # Read input parameter based on opening mode. If we have a file mode, we
    # get its path and read the code. We need to reset the mode in case the next
    # render call is on code, not on a file.
    #
    # @param input [String] Input file or code
    #
    def read(input)
      if @mode == :file
        @file = File.expand_path input; @mode = nil
        return File.read @file
      else
        @file = File.expand_path __FILE__
        return input
      end
    end
  end
end
