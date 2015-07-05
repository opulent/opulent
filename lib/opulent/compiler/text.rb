# @Opulent
module Opulent
  # @Compiler
  module Compiler
    # @Singleton
    class << self
      def text(node, indent, context)
        indentation = " " * indent

        if node[@options][:evaluate]
          value = context.evaluate "\"#{node[@value]}\""
        else
          value = node[@value]
        end

        value = indent_lines value, indentation

        if @inline_node.include? @last_node
          remove_trailing_newline
          value.lstrip!
        end

        text_tag = "#{value}"
        text_tag += "\n" if @inline_parent.include?(@parent_node) || !@inline_node.include?(@parent_node)

        @last_node = :text
        @code += text_tag
      end

      def printeval(node, indent, context)
        indentation = " " * indent

        value = context.evaluate node[@value]

        comment_tag = "#{indentation}#{value}\n"

        @last_node = :print
        @code += comment_tag
      end
    end
  end
end
