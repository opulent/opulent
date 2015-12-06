# @Opulent
module Opulent
  # @Logger
  module Logger
    # @Singleton
    class << self
      # Color the input text with the chosen color
      #
      # @param text [String] the string that will be colored
      # @param color_code [String] preset code for certain colors
      #
      def colorize(text, color_code)
        require_windows_libs
        "#{color_code}#{text}\e[0m"
      end

      # Colors available in the terminal
      #
      def black(text)
        colorize(text, "\e[30m")
      end

      def red(text)
        colorize(text, "\e[31m")
      end

      def green(text)
        colorize(text, "\e[32m")
      end

      def yellow(text)
        colorize(text, "\e[33m")
      end

      def blue(text)
        colorize(text, "\e[34m")
      end

      def magenta(text)
        colorize(text, "\e[35m")
      end

      def cyan(text)
        colorize(text, "\e[36m")
      end

      def white(text)
        colorize(text, "\e[37m")
      end

      def default(text)
        colorize(text, "\e[38m")
      end

      # Require windows libraries for ANSI Console output
      #
      def require_windows_libs
        return unless RUBY_PLATFORM =~ /win32/

        begin
          require 'Win32/Console/ANSI'
        rescue LoadError
          raise 'You must run "gem install win32console" to use Opulent\'s
                error reporting on Windows.'
        end
      end


      # Output an error message based on class context and input data
      #
      # @param message [Symbol] Message to be displayed
      # @param data [Array] Data to be displayed with the message
      #
      def log(message, *data)
        case error
        when :version
          title = 'Version'
          message = <<-LOG
Version #{Opulent::VERSION} is currently installed.
          LOG
        when :successful_render
          title = 'Render Complete'
          message = <<-LOG
Successfully rendered #{data[0].inspect} to #{data[1].inspect}.
          LOG
        when :successful_render_print
          title = 'Render Complete'
          message = <<-LOG
Successfully rendered #{data[0].inspect}.

No output file specified. Writing result to terminal.

#{data[1]}"

          LOG
        when :help
          title = 'Help'
          message = <<-LOG
You can use the following commands with the Opulent Command  Line Interface:

opulent input.op output.op      Render an input file and write the result to
                                the output file.
opulent layout [-l] layout.op   Render an input file using given input
                                layout file.
opulent help [-h]               Show available command line options.
opulent version [-v]            Show installed version.
          LOG
        end

        puts <<-OPULENT_LOG
\n
[Opulent Engine] #{title}

#{message}

        OPULENT_LOG
      end

      # Display an error message based on context
      #
      def error(type, *data)
        case type
        when :parse
          parse_error data[0], data[1], data[2], data[3], data[4..-1]
        when :compile
          compile_error data[0], data[1], data[2..-1]
        when :exec
          exec_error data[0], data[1..-1]
        end
      end

      # Output an error message based on class context and input data
      #
      # @param klass [Symbol] Class in which the error happens
      # @param error [Symbol] Error identification symbol
      # @param data [Array] Data to be displayed with the error
      #
      def exec_error(error, *data)
        case error
        when :input
          message = <<-ERROR
Given input file #{data[0].inspect} does not exist or an incorrect path
has been specified.
          ERROR
        when :layout_error
          message = <<-ERROR
Missing input or incorrect file extension for layout [-l] argument.
Found #{data[0]} instead.
          ERROR
        when :locals_file
          message = <<-ERROR
Given context file #{data[0].inspect} does not exist or
an incorrect path has been specified.
          ERROR
        when :locals_file_format
          message = <<-ERROR
Unknown file extension #{data[0].inspect} given as locals file. Please use
JSON or YAML as input.
          ERROR
        when :input_arguments
          message = <<-ERROR
Unknown input argument [#{data[0]}] has been encountered.
          ERROR
        when :no_input
          message = <<-ERROR
You haven't specified an input file.
          ERROR
        end

        fail <<-OPULENT_ERROR
\n
[Opulent Engine] Runtime Error

#{message}

        OPULENT_ERROR
      end

      # Output an error message based on class context and input data
      #
      # @param klass [Symbol] Class in which the error happens
      # @param error [Symbol] Error identification symbol
      # @param data [Array] Data to be displayed with the error
      #
      def compile_error(template, error, *data)
        case error
        when :explicit_end
          message = <<-ERROR
Explicit "end" evaluation nodes are not allowed. End expressions are
inserted automatically.
          ERROR
        end

        fail <<-OPULENT_ERROR
\n
[Opulent Compiler] Runtime Error

#{message}

        OPULENT_ERROR
      end

      # Output an error message based on class context and input data
      #
      # @param klass [Symbol] Class in which the error happens
      # @param error [Symbol] Error identification symbol
      # @param data [Array] Data to be displayed with the error
      #
      def parse_error(code, line, character, error, *data)
        line += 1

        case error
        when :unknown_node_type
          message = <<-ERROR
An unknown node type has been encountered.
          ERROR
        when :expected
          if [:'(', :'{', :'[', :'<'].include? data[0]
            data[0] = "#{Tokens.bracket data[0]}"
          end
          message = <<-ERROR
Expected to find a :#{data[0]} token on line #{line} of input.
          ERROR
        when :root
          message = <<-ERROR
Unknown node type encountered on line #{line} of input.
          ERROR
        when :assignments_colon
          message = <<-ERROR
Unexpected end of element attributes reached on line #{line}
of input.
          ERROR
        when :assignments_comma
          message = <<-ERROR
Unexpected end of element attributes reached on line #{line}
of input. Expected to find an attribute value.
          ERROR
        when :expression
          message = <<-ERROR
Unexpected end of expression reached on line #{line} of input.
Expected to find another expression term.
          ERROR
        when :control_child
          message = <<-ERROR
Unexpected control structure child found on line #{line} of input.
Expected to find a parent #{data[0]} structure.
          ERROR
        when :whitespace_expression
          message = <<-ERROR
Unexpected end of expression reached on line #{line} of input.
Please use paranthesis for method parameters
          ERROR
        when :definition
          message = <<-ERROR
Unexpected start of definition on line #{line} of input.
Found a definition inside another definition or element.
          ERROR
        when :self_enclosing
          message = <<-ERROR
Unexpected content found after self enclosing node on line
#{line} of input.
          ERROR
        when :self_enclosing_children
          message = <<-ERROR
Unexpected child elements found for self enclosing node on line
#{data[0] + 1} of input.
          ERROR
        when :include
          message = <<-ERROR
The included file #{data[0]} does not exist or an incorrect path
has been specified.
          ERROR
        when :include_dir
          message = <<-ERROR
The included file path #{data[0]} is a directory.
          ERROR
        when :include_end
          message = <<-ERROR
Missing argument for include on line #{line} of input.
          ERROR
        else
          message = <<-ERROR
Unexpected syntax error on line #{line} of input.
          ERROR
        end

        fail <<-OPULENT_ERROR
\n
[Opulent Parser] Runtime Error

#{message}
#{code[line - 1].chomp}
#{' ' * character}^

        OPULENT_ERROR
      end
    end
  end
end
