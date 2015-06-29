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
      def black(text); colorize(text, "\e[30m"); end
      def red(text); colorize(text, "\e[31m"); end
      def green(text); colorize(text, "\e[32m"); end
      def yellow(text); colorize(text, "\e[33m"); end
      def blue(text); colorize(text, "\e[34m"); end
      def magenta(text); colorize(text, "\e[35m"); end
      def cyan(text); colorize(text, "\e[36m"); end
      def white(text); colorize(text, "\e[37m"); end
      def default(text); colorize(text, "\e[38m"); end

      # Require windows libraries for ANSI Console output
      #
      def require_windows_libs
        begin
          require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/
        rescue LoadError
          raise 'You must run "gem install win32console" to use Opulent\'s
                error reporting on Windows.'
        end
      end

      # Pretty print Nodes with their important details
      #
      def pretty_print(model, indent = 0)
        model.each do |node|
          case node
          when Nodes::Node
            puts " " * indent +
            node.name.to_s +
            "::" + node.class.to_s.split('::').last +
            " #{node.attributes unless node.attributes.empty?}"
            pretty_print node.children, indent + 2
          when Nodes::Text, Nodes::Print
            puts " " * indent +
            "text" +
            "::" + node.class.to_s.split('::').last +
            " {:value => \"#{node.value}\"}"
          when NilClass
          else
            puts " " * indent +
            node.name.to_s +
            "::" + node.class.to_s.split('::').last +
            " {:value => \"#{node.value}\"}"
          end
        end
      end
    end
  end
end
