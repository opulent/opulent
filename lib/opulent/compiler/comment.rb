# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate the code for a while control structure
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    #
    def comment(node, indent)
      buffer_freeze "\n" if node[@options][:newline]
      if @settings[:pretty]
        if @in_definition
          buffer "' ' * (indent + #{indent})"
        else
          buffer_freeze " " * indent
        end
      end
      buffer_freeze '<!-- '
      buffer_split_by_interpolation node[@value].strip, false
      buffer_freeze ' -->'
      buffer_freeze "\n" if @settings[:pretty]
    end
  end
end
