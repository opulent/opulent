# @Opulent
module Opulent
  # @Compiler
  module Compiler
    # @Singleton
    class << self
      # Generate the code for a standard text node
      #
      # @param node [Array] Node code generation data
      # @param indent [Fixnum] Size of the indentation to be added
      # @param context [Context] Processing environment data
      #
      def plain(node, indent, context)
        indentation = " " * indent

        inline = @inline_node.include? @node_stack.last

        # Evaluate text node if it's marked as such and print nodes in the
        # current context
        if node[@value] == :text
          if node[@options][:evaluate]
            value = context.evaluate "\"#{node[@options][:value]}\""
          else
            value = node[@options][:value]
          end
        else
          value = context.evaluate node[@options][:value]
        end

        # Indent all the lines with the given indentation
        value = indent_lines value, indentation

        # If the last node was an inline node, we remove the trailing newline
        # character and we left strip the value
        #pp @node_stack
        if @node_stack.last == :text
          remove_trailing_newline
          value = " " + value.lstrip
        elsif inline
          remove_trailing_newline
          value.lstrip!
        end

        # Escape the value unless explicitly set to false
        value = node[@options][:escaped] ? escape(value) : value

        # Create the text tag to be added
        text_tag = "#{value}"
        text_tag += "\n"

        # Set the current child node as last processed node
        @node_stack << :text

        @code += text_tag
      end
    end
  end
end
