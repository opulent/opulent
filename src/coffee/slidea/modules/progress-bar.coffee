(($, window, document) ->
  "use strict"

  $.fn.slidea.progressBar = ->
    ###
    Set up progress bar element
    ###
    @settings =
      enabled: false # Add progress bar
      position: "bottom" # Progress bar position top / bottom
      class: "slidea-progress-light" # Additional thumbnail classes

    ###
    Add progress bar
    ###
    @load = ->
      position = (if @settings.progress.position is "top" then "slidea-progress-top" else "slidea-progress-bottom")

      html = ""
      html += "<div class=\"slidea-progress " + position + " " + @settings.progress.class + "\">"
      html += "<div class=\"slidea-progress-bar\">"
      html += "</div>"
      html += "</div>"
      @element.prepend html

      @progress = {}
      @progress.element = $(".slidea-progress", @element)
      @progress.bar = $(".slidea-progress-bar", @element)

      return

    ###
    Animate progress bar from 0% to 100%
    ###
    @slide = (from, to) ->
      if @progress_animation
        @progress_animation.kill()

      @progress_animation = @animate.fromTo @progress.bar,
        @timer.remaining / 1000,
        { width: '0%' },
        { width: '100%' }
      return

    @pause = ->
      @progress_animation.pause()
      return

    @resume = ->
      @progress_animation.resume()
      return

    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'progress', $.fn.slidea.progressBar

) window.jQuery, window, document
