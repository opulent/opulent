(($, window, document) ->
  "use strict"

  $.fn.slidea.scroller = ->
    ###
    Set up scroller component
    ###
    @settings =
      enabled: false # Enable Scroller Item
      markup: "<span class=\"slidea-scroller-1\"></span>" # Markup for scroller item (1 or 2)
      position: "center" # Scroller position: left, center, right


    @load = ->
      scroller = "<div class=\"slidea-scroller-wrapper slidea-scroller-" + @settings.scroller.position + "\">"
      scroller += @settings.scroller.markup
      scroller += "</div>"

      @scroller = $ scroller
      @element.prepend @scroller

      @scroller.on "click", =>
        $("html, body").animate scrollTop: @element.height(), 1000
        return
      return


    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'scroller', $.fn.slidea.scroller

) window.jQuery, window, document
