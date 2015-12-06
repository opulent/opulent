# @Opulent
module Opulent
  # @Parser
  class Parser
    # Check if we have an include node, which will include a new file inside
    # of the current one to be parsed
    #
    # @param parent [Array] Parent node to which we append to
    #
    def include_file(_parent, indent)
      return unless accept :include

      # Process data
      name = accept :line_feed || ''
      name.strip!

      # Check if there is any string after the include input
      Logger.error :parse, @code, @i, @j, :include_end if name.empty?

      # Get the complete file path based on the current file being compiled
      include_path = File.expand_path name, File.dirname(@file[-1][0])

      # Try to see if it has any existing extension, otherwise add .op
      include_path += Settings::FILE_EXTENSION if File.extname(name).empty?

      # Throw an error if the file doesn't exist
      unless Dir[include_path].any?
        Logger.error :parse, @code, @i, @j, :include, name
      end

      # include entire directory tree
      Dir[include_path].each do |file|
        # Skip current file when including from same directory
        next if file == @file[-1][0]

        @file << [include_path, indent]

        # Throw an error if the file doesn't exist
        if File.directory? file
          Logger.error :parse, @code, @i, @j, :include_dir, file
        end

        # Throw an error if the file doesn't exist
        unless File.file? file
          Logger.error :parse, @code, @i, @j, :include, file
        end

        # Indent all lines and prepare them for the parser
        lines = indent_lines File.read(file), ' ' * indent
        lines << ' '

        # Indent all the output lines with the current indentation
        @code.insert @i + 1, *lines.lines
      end

      true
    end
  end
end
