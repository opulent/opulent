# @Opulent
module Opulent
  # @Compiler
  module Compiler
    # @Singleton
    class << self
      # Compile input nodes, replace them with their definitions and
      #
      def compile(root, context)
        @code = ""

        root[Parser.children].each do |node|

          pp node
        end
      end
    end
  end
end
