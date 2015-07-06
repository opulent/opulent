# @Opulent
module Opulent
  # @Compiler
  module Compiler
    # @Singleton
    class << self
      def comment(node, indent, context)
        indentation = " " * indent

        value = context.evaluate "\"#{node[@value]}\""

        comment_tag = "#{indentation}<!-- #{value} -->\n"

        @node_stack << :comment
        @code += comment_tag
      end
    end
  end
end
