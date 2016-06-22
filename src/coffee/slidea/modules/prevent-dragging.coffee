(($, window, document) ->
  "use strict"

  $.fn.slidea.preventDragging = ->
    ###
    Enable or disable image dragging
    ###
    @settings = true

    # Check if current screen is retina. If yes, replace images with their larger
    # versions using the data-slidea-at2x attribute
    #
    @initialize = ->
      $("img", @element).on "dragstart", (event) =>
        event.preventDefault()
        return
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'preventDragging', $.fn.slidea.preventDragging

) window.jQuery, window, document
