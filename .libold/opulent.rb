require 'htmlentities'
require 'tilt'
require_relative 'opulent/engine'
require_relative 'opulent/logger'
require_relative 'opulent/preprocessor'
require_relative 'opulent/tokens'
require_relative 'opulent/nodes'
require_relative 'opulent/parser'
require_relative 'opulent/context'
require_relative 'opulent/runtime'
require_relative 'opulent/template'
require_relative 'opulent/filter'
require 'pp'

# @Opulent
module Opulent
  # Wrapper method for creating a new Opulent instance
  #
  def Opulent.new
    return Opulent.new
  end

  # @Opulent
  class Opulent
    # Analyze the input code and check for matching tokens. In case no match was
    # found, throw an exception. In special cases, modify the token hash.
    #
    # @param file [String] The file that needs to be analyzed
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def render_file(file, locals = {}, &block)
      # Temporarily set file render mode for using it in the Preprocessor
      @mode = :file

      # Render the file
      render file, locals, &block
    end

    # Analyze the input code and check for matching tokens. In case no match was
    # found, throw an exception. In special cases, modify the token hash.
    #
    # @param file [String] The file that needs to be analyzed
    # @param locals [Hash] Render call local variables
    # @param block [Proc] Processing environment data
    #
    def render(code, locals = {}, &block)
      # Get the code from the input file
      @code = PreProcessor.process code, @mode, &block

      # Reset rendering mode to code. The mode variable is used to specify
      # whether we're using render file or render code. When using render code,
      # the preprocessor can be used only when a block is also passed
      @mode = :code

      # Instantiate required language components
      @syntax = Parser.parse @code

      # Create a new context based on our rendering environment
      #bind = block.binding if block
      #@context = Context.new locals, bind

      # Instantiate required language components
      #@model = Runtime.remodel @syntax, @context

      #puts "\n\nModel\n---"
      #Logger.pretty_print @model
    end

    # Update the engine options with the required option changes
    #
    def update_options(opts)
      Engine.update_options(opts)
    end

    private

    # Give an explicit error report where an unexpected sequence of tokens
    # appears and give indications on how to solve it
    #
    # @param context [Symbol] Context name in which the error happens
    # @param data [Array] Additional error information
    #
    def error(context, *data)
      message = case context
      when :options_key
        "The input \"#{data[0]}\" is not a valid option name."
      end

      # Reconstruct lines to display where errors occur
      fail "\n\nOpulent " + Logger.red("[Engine Error]") + "\n---\n" +
      "An error has been encountered when updating the engine options.\n" +
      "#{message}"
    end
  end
end
