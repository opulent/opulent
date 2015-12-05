# @Opulent
module Opulent
  # @Utils
  module Utils
    # Used by escape_html
    #
    ESCAPE_HTML = {
      '&'  => '&amp;',
      '"'  => '&quot;',
      '\'' => '&#39;',
      '<'  => '&lt;',
      '>'  => '&gt;'
    }.freeze

    # Pattern matching for html escape characters
    ESCAPE_HTML_PATTERN = Regexp.union(*ESCAPE_HTML.keys)

    # Ruby interpolation pattern
    INTERPOLATION_PATTERN = /\#\{([^}]+)\}/

    # @Utils
    class << self
      if defined?(EscapeUtils)
        # Returns an escaped copy of `html`.
        #
        # @param html [String] The string to escape
        # @return [String] The escaped string
        def escape(html)
          EscapeUtils.escape_html html.to_s.chomp, false
        end
      else
        # Returns an escaped copy of `html`.
        #
        # @param html [String] The string to escape
        # @return [String] The escaped string
        def escape(html)
          html.to_s.chomp.gsub ESCAPE_HTML_PATTERN, ESCAPE_HTML
        end
      end
    end
  end
end
