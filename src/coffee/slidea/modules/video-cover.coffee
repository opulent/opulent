(($, window, document) ->
  "use strict"

  $.fn.slidea.videoCover = ->
    ###
    Enable or disable video cover features
    ###
    @settings = true 

    ###
    Set up the video covers so that they fade out and play the
    actual video on click event
    ###
    @load = ->
      hide = (cover) =>
        @animate.to cover, 0.5,
          opacity: 0
          onComplete: =>
            cover.css display: 'none'
            return
        return

      covers = $(@settings.selector.videoCover, @element)
      covers.each (i, el) =>
        cover = $(el)
        parent = cover.parent()
        video = $(@settings.selector.video, parent)
        type = video.attr 'data-slidea-video-type'
        id = video.attr("id")
        switch type
          when "html5"
            cover.on "click", =>
              video.get(0).play()
              hide cover
              return

          when "youtube"
            cover.on "click", =>
              @youtube_player[id].playVideo()
              hide cover
              return

          when "vimeo"
            cover.on "click", =>
              @vimeo_player[id].api "play"
              hide cover
              return

        return
      @log "Added video cover events." if covers.length > 0
      return

    ###
    Animate progress bar from 0% to 100%
    ###
    @slide = (from, to) ->
      slide = @slides.eq(to)
      covers = $(@settings.selector.videoCover, slide)
      covers.each (i, el) =>
        cover = $(el)
        cover.css display: 'block'
        @animate.to cover, 0.5, opacity: 1
        return
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'videoCover', $.fn.slidea.videoCover

) window.jQuery, window, document
