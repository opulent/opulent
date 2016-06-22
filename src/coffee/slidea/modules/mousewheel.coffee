(($, window, document) ->
  "use strict"

  $.fn.slidea.mousewheel = ->
    ###
    Enable or disable mousewheel handler
    ###
    @settings = false

    ###
    Add mousewheel handler
    @require mousewheel.js
    ###
    @load = ->
      enabled = true
      enable_timeout = 750

      # Bind Mousewheel event
      @element.mousewheel (event) =>
        return unless enabled

        # Prevent scrolling for a while
        enabled = false

        if event.deltaY == -1
          @slide @current + 1
        if event.deltaY == 1
          @slide @current - 1
        if @settings.prevent_scrolling is true
          event.preventDefault()

        # Reenable scrolling after timeout
        setTimeout =>
          enabled = true
          return
        , enable_timeout

        return

      @log "Bound mousewheel event."
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'mousewheel', $.fn.slidea.mousewheel

) window.jQuery, window, document
