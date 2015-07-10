# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Compile a new Opulent file using the current page context data
    #
    # @param node [Array] Node code generation data
    # @param indent [Fixnum] Size of the indentation to be added
    # @param context [Context] Processing environment data
    #
    def require_node(node, indent, context)
      require_file = File.expand_path context.evaluate(node[@value]), @path
      error :require, node[@value] unless File.file? require_file

      data = {
        definitions: @definitions,
        overwrite: true
      }
      rendered = Engine.new(data).render_file require_file, &context.block

      @code += indent_lines rendered, " " * indent
    end
  end
end
