# @Opulent
module Opulent
  module Utils
    # Used by escape_html
    #
    EscapeHTML = {
      '&'  => '&amp;',
      '"'  => '&quot;',
      '\'' => '&#39;',
      '<'  => '&lt;',
      '>'  => '&gt;'
    }.freeze

    EscapeHTMLPattern = Regexp.union(*EscapeHTML.keys)

    class << self
      if defined?(EscapeUtils)
        # Returns an escaped copy of `html`.
        #
        # @param html [String] The string to escape
        # @return [String] The escaped string
        def escape(html)
          EscapeUtils.escape_html html.to_s, false
        end
      else
        # Returns an escaped copy of `html`.
        #
        # @param html [String] The string to escape
        # @return [String] The escaped string
        def escape(html)
          html.to_s.gsub EscapeHTMLPattern, EscapeHTML
        end
      end


    end
  end
end
