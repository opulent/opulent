(($, window, document) ->
  "use strict"

  $.fn.slidea.loader = ->
    ###
    Enable or disable loader component
    ###
    @settings = true

    ###
    Add the loader element if it hasn't been added with HTML
    ###
    @initialize = ->
      if $(".slidea-loader-wrapper", @element).length is 0
        html = ""
        html += '<div class="slidea-loader-wrapper">'
        html += '<div class="slidea-loader">'
        html += '<div class="slidea-loader-inner">'
        html += '<div class="slidea-loader-tile"></div>'
        html += '<div class="slidea-loader-tile"></div>'
        html += '<div class="slidea-loader-tile"></div>'
        html += '<div class="slidea-loader-tile"></div>'
        html += '<div class="slidea-loader-tile"></div>'
        html += '</div>'
        html += '</div>'
        # html += '<div class="slidea-loader-text">'
        # html += '<h5 class="slidea-loader-title font-normal">'
        # html += 'SLIDEA'
        # html += '</h5>'
        # html += '<h6 class="slidea-loader-subtitle font-thin">'
        # html += 'A Smarter Slider Plugin'
        # html += '</h6>'
        # html += '</div>'
        html += '</div>'

        @element.prepend html

        @log "No loader found. Added default loader."
      else
        @log "Loader markup already exists."

      @loader = $(".slidea-loader-wrapper", @element)
      return

    ###
    When all the slider images have been loaded, hide the
    loading spinner
    ###
    @load = ->
      @animate.to @loader, 0.5,
        opacity: 0
        onComplete: =>
          @loader.css display: 'none'
          @log "Loader element faded out."
          return
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'loader', $.fn.slidea.loader

) window.jQuery, window, document
