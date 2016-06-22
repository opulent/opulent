(($, window, document) ->
  "use strict"

  $.fn.slidea.keyboard = ->
    ###
    Enable or disable keyboard handler
    ###
    @settings = true

    ###
    Add keyboard bindings
    ###
    @load = ->
      $(document).keydown (e) =>
        switch e.which
          when 37 then @slide @current - 1
          when 39 then @slide @current + 1
          else return
      @log "Bound keyboard arrows event."
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'keyboard', $.fn.slidea.keyboard

) window.jQuery, window, document
