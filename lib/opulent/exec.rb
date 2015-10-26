require 'json'
require 'yaml'
require 'opulent/version'

# @Opulent
module Opulent
  # @CLI
  class CLI
    EXTENSION = /\.(op|opl|opulent)\Z/

    KEYWORDS = %w(context layout locals version help)

    def initialize(arguments)
      i = 0

      layout_error = 'Missing input or incorrect file extension for ' \
        'layout [-l] argument. '
      layout_error += "Found #{arguments[i + 1]} instead." if arguments[i + 1]

      while arguments[i]
        case arguments[i]

        # opulent input.op output.op
        when EXTENSION
          @input = arguments[i]
          is_keyword = KEYWORDS.include? arguments[i + 1]
          unless arguments[i + 1] =~ /\A\-/ || is_keyword
            @output = arguments[(i += 1)]
          end

        # opulent -v
        when '-l', 'layout'
          if arguments[i + 1] =~ EXTENSION
            @layout = arguments[(i += 1)]
          else
            error layout_error
          end

        # opulent -v
        when '-v', 'version'
          write "Version #{Opulent::VERSION} is currently installed."
          return

        # opulent -c
        when '-c', 'context', '-lc', 'locals'
          @locals_file = arguments[(i += 1)]
          unless File.file? @locals_file
            error "Given context file #{@locals_file.inspect} does not exist" \
            ' or an incorrect path has been specified.'
          end

          if File.extname(@locals_file) == '.json'
            @locals = JSON.parse File.read(@locals_file), symbolize_keys: true
          elsif File.extname(@locals_file) == '.yml'
            @locals = YAML.load_file @locals_file
          else
            error "Unknown file extension #{@locals_file.inspect} given as" \
            ' locals file. Please use JSON or YAML as input.'
          end

        # opulent -h
        when '-h', 'help'
          write help
          return
        else
          error "Unknown input argument [#{arguments[i]}] has been encountered."
        end

        i += 1
      end

      if @input
        @locals ||= {}

        unless File.file? @input
          error "Given input file #{@input.inspect} does not exist or " \
          'an incorrect path has been specified.'
        end

        message = ''
        opulent = Opulent.new
        if @layout
          output = proc do
            opulent.render_file(@layout, @locals) do
              opulent.render_file(@input, @locals) {}
            end
          end[]
        else
          output = proc do
            opulent.render_file(@input, @locals)
          end[]
        end

        if @output
          File.open(@output, 'w') { |file| file.write output }
          message += "Successfully rendered #{@input.inspect} " \
          "to #{@output.inspect}."
        else
          message += "Successfully rendered #{@input.inspect}.\n\n"
          message += 'No output file specified. Writing result to ' \
          "terminal.\n\n#{output}"
        end

        write message
      else
        error "You haven't specified an input file."
      end
    end

    def help(_extra = '')
      <<-HELP #{_extra} You can use the following commands with the Opulent
       Command  Line Interface: \n\n
opulent input.op output.op      Render an input file and write the result to
the output file.\n
opulent layout [-l] layout.op   Render an input file using given input
layout file.\n
opulent help [-h]               Show available command line options.\n
opulent version [-v]            Show installed version.\n"
      HELP
    end

    # Give an explicit response for the given input arguments
    #
    # @param message [String] Response message to display to the user
    #
    def write(message)
      # Reconstruct lines to display where errors occur
      puts "\nOpulent " + Logger.green('[Engine]') +
        "\n---\n#{message}\n\n\n"
    end

    # Give an explicit error report where an unexpected sequence of tokens
    # appears and give indications on how to solve it
    #
    # @param message [String] Error message to display to the user
    #
    def error(message)
      # Reconstruct lines to display where errors occur
      fail "\nOpulent " + Logger.red('[Engine]') +
        "\n---\n#{message}\n\n#{help}\n\n\n"
    end
  end
end
