# @Opulent
module Opulent
  # @Parser
  class Parser
    # Check if we match a new node definition to use within our page.
    #
    # Definitions will not be recursive because, by the time we parse
    # the definition children, the definition itself is not in the
    # knowledgebase yet.
    #
    # However, we may use previously defined nodes inside new definitions,
    # due to the fact that they are known at parse time.
    #
    # @param nodes [Array] Parent node to which we append to
    #
    def require_file(parent, indent)
      if(match = accept :require)

        # Process data
        name = accept :exp_string, :*

        # Check if there is any string after the require input
        unless (feed = accept(:line_feed) || "").strip.empty?
          undo feed; error :require_end
        end

        # Get the complete file path based on the current file being compiled
        require_path = File.expand_path name[1..-2], @dir

        # Try to see if it has any existing extension, otherwise add .op
        require_path += '.op' unless Settings::Extensions.include? File.extname require_path

        # Throw an error if the file doesn't exist
        error :require, name unless Dir[require_path].any?

        # Require entire directory tree
        Dir[require_path].each do |file|
          # Skip current file when including from same directory
          next if file == @file

          # Throw an error if the file doesn't exist
          error :require_dir, file if File.directory? file

          # Throw an error if the file doesn't exist
          error :require, file unless File.file? file

          # Indent all lines and prepare them for the parser
          lines = indent_lines File.read(file), " " * indent

          # Indent all the output lines with the current indentation
          @code.insert @i + 1, *lines.lines
        end

        return true
      end
    end
  end
end
