# @Opulent
module Opulent
  # @Compiler
  module Compiler
    # @Singleton
    class << self
      # Generate the code for a while control structure
      #
      # @param node [Array] Node code generation data
      # @param indent [Fixnum] Size of the indentation to be added
      # @param context [Context] Processing environment data
      #
      def yield_node(node, indent, context)
        if @block_stack[-1].has_key? node[@value]
          @block_stack[-1][node[@value]].each do |child|
            root child, indent, context.parent
          end
        end
      end

      # Generate the code for a while control structure
      #
      # @param node [Array] Node code generation data
      # @param indent [Fixnum] Size of the indentation to be added
      # @param context [Context] Processing environment data
      #
      def block_node(node, indent, context)
        node[@children].each do |child|
          root child, indent, context
        end
      end
    end
  end
end
