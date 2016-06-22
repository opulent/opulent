(($, window, document) ->
  "use strict"

  $.fn.slidea.retina = ->
    ###
    Enable or disable retina feature
    ###
    @settings = true

    # Check if current screen is retina. If yes, replace images with their larger
    # versions using the data-slidea-at2x attribute
    #
    @initialize = ->
      retina = false
      root = (exports? ? window : exports)
      mediaQuery = '(-webkit-min-device-pixel-ratio: 1.5), (min--moz-device-pixel-ratio: 1.5), (-o-min-device-pixel-ratio: 3/2), (min-resolution: 1.5dppx)';

      if root.devicePixelRatio > 1
          retina = true

      if root.matchMedia && root.matchMedia(mediaQuery).matches
          retina = true

      if retina
        @log "This device has a retina display."

        $('img[data-slidea-at2x]', $slide).each (index, element) =>
          img = $(element)
          src = img.attr('data-slidea-src')
          retina_src = img.attr 'data-slidea-at2x'

          if retina_src == "true"
            src = src.replace /(\.[\w\?=]+)$/, "@2x$1"
          else
            src = retina_src

          @log "Found a Retina image with src=\"#{src}\"."

          img.attr 'data-slidea-src', src
          return
      else
        @log "This device doesn't have a Retina display."
      return

    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'retina', $.fn.slidea.retina

) window.jQuery, window, document
