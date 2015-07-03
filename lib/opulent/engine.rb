# @Opulent
module Opulent
  # Module method wrapper for creating a new engine instance
  #
  def Opulent.new(settings = nil)
    return Engine.new settings
  end

  # @Engine
  class Engine
    attr_reader :nodes, :preamble, :buffer

    def initialize(settings = nil)
      # Update render settings
      Settings.update_settings settings if settings
    end

    # Analyze the input code and check for matching tokens. In case no match was
    # found, throw an exception. In special cases, modify the token hash.
    #
    # @param file [String] The file that needs to be analyzed
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def render_file(file, locals = {}, &block)
      # Render the file
      render File.read(file), locals, &block
    end

    # Analyze the input code and check for matching tokens. In case no match was
    # found, throw an exception. In special cases, modify the token hash.
    #
    # @param file [String] The file that needs to be analyzed
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def render(code, locals = {}, &block)
      # Get the nodes tree
      @nodes = Parser.parse code

      # @TODO
      # Implement precompiled template handling
      @preamble = @nodes.inspect.inspect

      # Create a new context based on our rendering environment
      @context = Context.new locals, (block.binding if block)

      return @nodes
    end
  end
end
