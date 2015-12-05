# @Opulent
module Opulent
  # @Compiler
  class Compiler
    # Generate code for all nodes by calling the method with their type name
    #
    # @param current [Array] Current node data with options
    # @param indent [Fixnum] Indentation size for current node
    #
    def root(current, indent)
      if KEYWORDS.include? current[@type]
        send :"#{current[@type]}_node", current, indent
      else
        send current[@type], current, indent
      end
    end
  end
end
