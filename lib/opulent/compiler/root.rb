module Opulent
  # @Compiler
  module Compiler
    # @Singleton
    class << self
      # Generate code for all nodes by calling the method with their type name
      #
      # @param current [Array] Current node data with options
      # @param indent [Fixnum] Indentation size for current node
      # @param context [Context] Context holding environment variables
      #
      def root(current, indent, context)
        if Parser::Keywords.include? current[@type]
          send :"#{current[@type]}_node", current, indent, context
        else
          send current[@type], current, indent, context
        end
      end
    end
  end
end
