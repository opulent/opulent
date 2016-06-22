(($, window, document) ->
  "use strict"

  $.fn.slidea.pauseOnHover = ->
    ###
    Enable or disable pause on hover feature
    ###
    @settings = false

    ###
    Pause the slider on mouse hover
    ###
    @load = ->
      @element.on 'mouseenter', =>
        @pause_timer()
        return
      @element.on 'mouseleave', =>
        @unpause_timer()
        return

      @log "Enabled pause on hover."
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'pauseOnHover', $.fn.slidea.pauseOnHover

) window.jQuery, window, document
