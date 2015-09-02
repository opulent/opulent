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
    def include_file(parent, indent)
      if(match = accept :include)

        # Process data
        name = accept :line_feed || ""
        name.strip!


        # Check if there is any string after the include input
        if name.empty?
          error :include_end
        end

        # Get the complete file path based on the current file being compiled
        include_path = File.expand_path name, File.dirname(@file[-1][0])

        # Try to see if it has any existing extension, otherwise add .op
        include_path += Settings::FileExtension if File.extname(name).empty?

        # Throw an error if the file doesn't exist
        error :include, name unless Dir[include_path].any?

        # include entire directory tree
        Dir[include_path].each do |file|
          # Skip current file when including from same directory
          next if file == @file[-1][0]

          @file << [include_path, indent]

          # Throw an error if the file doesn't exist
          error :include_dir, file if File.directory? file

          # Throw an error if the file doesn't exist
          error :include, file unless File.file? file

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
