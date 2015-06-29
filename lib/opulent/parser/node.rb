# @Opulent
module Opulent
  # @Parser
  module Parser
    # @Singleton
    class << self
      def attributes
        atts = {}
        wrapped_attributes atts
        #unrwapped_attributes atts

        return atts
      end

      def wrapped_attributes(atts = {})
        if(bracket = consume :brackets)
          consume bracket.to_sym, :*
        end

        return atts
      end
    end
  end
end
