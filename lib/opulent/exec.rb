require 'json'
require 'yaml'
require 'opulent/version'
require 'opulent/logger'

# @Opulent
module Opulent
  # @CLI
  class CLI
    EXTENSION = /\.(op|opl|opulent)\Z/

    KEYWORDS = %w(context layout locals version help)

    def initialize(arguments)
      i = 0

      while arguments[i]
        case arguments[i]

        # opulent input.op output.html
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
            Logger.error :exec, arguments[i + 1], :layout_error
          end

        # opulent -v
        when '-v', 'version'
          Logger.log :version
          return

        # opulent -c
        when '-c', 'context', '-lc', 'locals'
          @locals_file = arguments[(i += 1)]
          unless File.file? @locals_file
            Logger.error :exec, @locals_file, :locals_file
          end

          if File.extname(@locals_file) == '.json'
            @locals = JSON.parse File.read(@locals_file), symbolize_keys: true
          elsif File.extname(@locals_file) == '.yml'
            @locals = YAML.load_file @locals_file
          else
            Logger.error :exec, @locals_file, :locals_file_format
          end

        # opulent -h
        when '-h', 'help'
          Logger.log :help
          return
        else
          Logger.error :exec, arguments[i], :input_arguments
        end

        i += 1
      end

      if @input
        @locals ||= {}

        Logger.error :exec, @input, :input unless File.file? @input

        input_file = File.read @input
        opulent_page = Opulent.new input_file

        scope = Object.new

        if @layout
          layout_file = File.read @layout
          opulent_layout = Opulent.new layout_file
          output = proc do
            opulent_layout.render scope, @locals do
              opulent_page.render scope, @locals do
              end
            end
          end[]
        else
          output = proc do
            opulent_page.render scope, @locals do
            end
          end[]
        end

        if @output
          File.open(@output, 'w') { |file| file.write output }
          Logger.log :successful_render, @input, @output
        else
          Logger.log :successful_render_print, @input, output
        end
      else
        Logger.error :exec, :no_input
      end
    end
  end
end
