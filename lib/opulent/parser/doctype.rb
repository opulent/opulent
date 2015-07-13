# @Opulent
module Opulent
  # @Parser
  class Parser
    # Match one line or multiline comments
    #
    def doctype(parent, indent)
      if (accept :doctype)
        buffer = accept(:line_feed)

        parent[@children] << [:doctype, buffer.strip.to_sym, {}, nil, indent]
      end
    end
  end
end
