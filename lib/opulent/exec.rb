require 'json'
require 'yaml'
require 'opulent/version'

# @Opulent
module Opulent
  # @CLI
  class CLI
    Extension = /\.(op|opl|opulent)\Z/

    Keywords = %w(context layout locals version help)

    def initialize(arguments)
      i = 0

      while arguments[i]
        case arguments[i]

        # opulent input.op output.op
        when Extension
          @input = arguments[i]
          unless arguments[i + 1] =~ /\A\-/ || Keywords.include?(arguments[i+1])
            @output = arguments[(i += 1)]
          end

        # opulent -v
        when '-l', 'layout'
          if arguments[i + 1] =~ Extension
            @layout = arguments[(i += 1)]
          else
            error "Missing input or incorrect file extension for layout [-l] argument. " +
            "#{"Found #{arguments[i+1]} instead." if arguments[i+1] }"
          end

        # opulent -v
        when '-v', 'version'
          write "Version #{Opulent::VERSION} is currently installed."
          return

        # opulent -c
        when '-c', 'context', '-lc', 'locals'
          @locals_file = arguments[(i += 1)]
          error "Given context file #{@locals_file.inspect} does not exist or an incorrect path has been specified." unless File.file? @locals_file

          if File.extname(@locals_file) == '.json'
            @locals = JSON.parse File.read(@locals_file), symbolize_keys: true
          elsif File.extname(@locals_file) == '.yml'
            @locals = YAML.load_file @locals_file
          else
            error "Unknown file extension #{@locals_file.inspect} given as locals file. Please use JSON or YAML as input."
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
        error "Given input file #{@input.inspect} does not exist or an incorrect path has been specified." unless File.file? @input

        message = ""
        opulent = Opulent.new
        if @layout
          output = Proc.new do
            opulent.render_file(@layout, @locals) {
              opulent.render_file(@input, @locals){}
            }
          end[]
        else
          output = Proc.new do
            opulent.render_file(@input, @locals)
          end[]
        end

        if @output
          File.open @output, 'w' do |file| file.write output end
          message += "Successfully rendered #{@input.inspect} to #{@output.inspect}."
          #message += "Used #{@locals_file.inspect} as local context file." if @locals_file
        else
          message += "Successfully rendered #{@input.inspect}.\n\n"
          #message += "Used #{@locals_file.inspect} as local context file.\n\n" if @locals_file
          message += "No output file specified. Writing result to terminal.\n\n#{output}"
        end

        write message
      else
        error "You haven't specified an input file."
      end
    end

    def help(extra = "")
      "#{extra}You can use the following commands with the Opulent Command Line Interface: \n\n
opulent input.op output.op      Render an input file and write the result to the output file.\n
opulent layout [-l] layout.op   Render an input file using given input layout file.\n
opulent help [-h]               Show available command line options.\n
opulent version [-v]            Show installed version.\n"
    end

    # Give an explicit response for the given input arguments
    #
    # @param message [String] Response message to display to the user
    #
    def write(message)
      # Reconstruct lines to display where errors occur
      puts "\nOpulent " + Logger.green('[Engine]') +
      "\n---\n" +
      "#{message}\n\n\n"
    end

    # Give an explicit error report where an unexpected sequence of tokens
    # appears and give indications on how to solve it
    #
    # @param message [String] Error message to display to the user
    #
    def error(message)
      # Reconstruct lines to display where errors occur
      fail "\nOpulent " + Logger.red('[Engine]') +
      "\n---\n" +
      "#{message}\n\n#{help}\n\n\n"
    end
  end
end
