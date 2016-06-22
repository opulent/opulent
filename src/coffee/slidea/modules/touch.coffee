(($, window, document) ->
  "use strict"

  $.fn.slidea.touch = ->
    ###
    Enable or disable video features
    ###
    @settings = true

    ###
    Enable touch handler for the slider.
    @require Hammer.js
    ###
    @load = ->
      # Get touch target
      @touch_object = new Hammer @element[0]

      # Allow horizontal touch only
      @touch_object.get('pan').set
        direction: Hammer.DIRECTION_HORIZONTAL

      # Add panleft and panright events
      @touch_object.on 'panleft panright', (event) =>
        # Show dragging cursor on drag start
        if event.eventType is Hammer.INPUT_START
          @element.addClass 'slidea-dragging'

        else if event.eventType is Hammer.INPUT_END or event.eventType is Hammer.INPUT_CANCEL
          @element.removeClass 'slidea-dragging'

          # Swipe left or right based on direction
          if event.direction is Hammer.DIRECTION_LEFT
            @slide @current + 1
          else if event.direction is Hammer.DIRECTION_RIGHT
            @slide @current - 1

        return

      @log "Bound touch pan left and right events."
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'touch', $.fn.slidea.touch

) window.jQuery, window, document
