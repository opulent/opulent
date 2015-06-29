# @Opulent
module Opulent
  # @PreProcessor
  module PreProcessor
    # @Singleton
    class << self
      # Preprocessor directives which will be checked before lexing starts.
      # Each directive takes leading whitespace into account, therefore all the
      # included lines will have the same indentation size as the directive
      #
      REQUIRE_DIRECTIVE =  /([\t ]*)\/\/= *require +("(.*)"|'(.*)')/

      # Include required files using the \\=directive_name pattern and keep
      # the expanded directory path to make the require relative to the input
      #
      # @param file [String] name of the file to be processed
      #
      def process(input, mode = :file, &block)
        # We can preprocess the code in file mode without requiring a block, but
        # if we're preprocessing code directly, we need a block to get the
        # caller file path, otherwise we return an error
        if mode == :file
          # Get the complete path of the input file
          dir = File.dirname File.expand_path input
          # Process the file contents
          code = File.read input
        elsif block
          # Get the complete path of the input file
          dir = File.dirname File.expand_path eval('__FILE__', block.binding)
          # Process the file contents
          code = input
        elsif input =~ REQUIRE_DIRECTIVE
          error :block, 'require', $~
        else
          return input
        end

        return require_files code, dir
      end

      private

      # Replace the found \\=require directive with the file's contents
      #
      # @param contents [String] contents of the input file
      # @param dir [String] complete path of the input file
      #
      def require_files(contents, dir)
        contents.gsub REQUIRE_DIRECTIVE do |path|
          require_contents = ''
          match = $2[1..-2]

          # Check if file already has extension
          path = "#{dir}/#{match}"

          # Check if the required file exists
          if File.file? path
            # Get contents
            require_contents = process path
          else
            error :file, $2
          end

          # Indent lines
          indent_lines $1, require_contents
        end
      end

      # Add indentation to each line if the require directive is indented
      #
      # @param indent [String] a string containing whitespace
      # @param contents [String] required file's contents
      #
      def indent_lines(indent, contents)
        unless indent.empty?
           contents.lines.map!{ |line| indent + line }.join
        end

        return contents
      end

      # Give an explicit error report where an unexpected sequence of tokens
      # appears and give indications on how to solve it
      #
      def error(context, *data)
        message = case context
        when :file
          "The file #{data[0]} does not exist at the specified path."
        when :block
          "Found a #{data[0]} directive at \"#{data[1]}\" but no block was given as rendering environment.\n" +
          "Please include a block when rendering to fix this issue.\n\n" +
          "E.g. opulent.render(code, locals){}"
        end

        # Reconstruct lines to display where errors occur
        fail "\n\nOpulent " + Logger.red('[Preprocessor Error]') + "\n---\n" +
        "#{message}\n\n"
      end

    end
  end
end
