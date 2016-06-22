(($, window, document) ->
  "use strict"

  $.fn.slidea.video = ->
    ###
    Enable or disable video features
    ###
    @settings = true

    ###
    Setup video events at slide start for HTML5, YouTube and Vimeo videos
    ###
    @initialize = ->
      ###
      Handle autoplay timeouts using a timeout timeline
      ###
      @video_timeline = {}

      delay = 500
      interval = undefined
      i = 0
      tries = 10

      # Handle background videos
      $('.slidea-video-background').each (index, background) ->
        unless $(background).hasClass 'slidea-object'
          $(background).addClass 'slidea-object'
        return

      $("video.slidea-video", @element).attr "data-slidea-video-type", "html5"
      $("iframe[data-slidea-src*=\"youtube.com\"].slidea-video", @element).attr "data-slidea-video-type", "youtube"
      $("iframe[data-slidea-src*=\"vimeo.com\"].slidea-video", @element).attr "data-slidea-video-type", "vimeo"

      $(@settings.selector.video, @element).each (i, el) =>
        # Get video
        video = $(el)

        # Get volume
        volume = video.attr("data-slidea-volume")
        volume = (if isNaN(volume) then 0 else volume)

        # Get controls
        controls = (video.attr("data-slidea-controls") is "true")

        # Pause slider on video play
        pause_slider = (video.attr("data-slidea-pause-slider") is "true")

        # Get src
        src = video.attr("data-slidea-src")

        # Get video type
        video_type = video.attr("data-slidea-video-type")

        # Get video id
        video.attr "id", @get_random_id("slidea-video") unless video.attr("id")?
        id = video.attr("id")

        # HTML5
        if video_type is "html5"
          # Set volume
          video.get(0).volume = volume

          # Enable or disable controls
          video.attr "controls", "controls"  if controls is true

          # If slider is set to autoplay, pause the slider when video starts
          if @settings.autoplay is true and pause_slider is true
            # On video play
            video.on "play", =>
              @pause_timer()
              return

            # On video pause
            video.on "pause ended", =>
              @unpause_timer()
              return


        # YouTube
        if video_type is "youtube"
          video_id = undefined
          separator = undefined

          # Enable video JS API
          if src.indexOf("enablejsapi=1") is -1
            if src.indexOf("?") is -1
              video.attr "src", src + "?enablejsapi=1"
            else
              video.attr "src", src + "&enablejsapi=1"
            src = video.attr("src")

          # Set player API ID
          if src.indexOf("playerapiid=") is -1
            if src.indexOf("?") is -1
              video.attr "src", src + "?playerapiid=" + id
            else
              video.attr "src", src + "&playerapiid=" + id
            src = video.attr("src")

          # Get youtube Video ID
          if src.indexOf("embed") == "-1"
            video_id = src.split("v=")[1]
            separator = video_id.indexOf("&")
            video_id = video_id.substring(0, separator)  unless separator is -1
          else
            video_id = src.split("/")
            video_id = video_id[video_id.length - 1]
            separator = video_id.indexOf("?")
            video_id = video_id.substring(0, separator)  unless separator is -1


          # Create a new YT Player using the API
          video.load =>
            @youtube_player[id] = new YT.Player(id,
              height: "720"
              width: "1280"
              video_id: video_id
              events:
                onStateChange: (e) =>
                  @pause_timer()  if e.data is 1
                  @unpause_timer()  if e.data is 2 or e.data is 0
                  return
            )

            # Try to set the video volume
            i = 0
            interval = setInterval(=>
              i++
              if i is tries
                clearInterval interval
              else if not @youtube_player[id]? or typeof @youtube_player[id].setVolume isnt "function"
                return
              else
                clearInterval interval
              @youtube_player[id].setVolume volume
              return
            , delay)
            return

        # Vimeo
        if video_type is "vimeo"
          # Enable vimeo JS API
          if src.indexOf("api=1") is -1
            if src.indexOf("?") is -1
              video.attr "src", src + "?api=1"
            else
              video.attr "src", src + "&api=1"
            src = video.attr("src")

          # Setup Vimeo player ID
          if src.indexOf("player_id=") is -1
            if src.indexOf("?") is -1
              video.attr "src", src + "?player_id=" + id
            else
              video.attr "src", src + "&player_id=" + id
            src = video.attr("src")

          # Create a new Vimeo Player API
          video.load =>
            @vimeo_player[id] = $f(id)
            @vimeo_player[id].addEvent "ready", =>
              video.attr "data-slidea-ready", "true"
              @vimeo_player[id].api "setVolume", volume
              if @settings.autoplay is true and pause_slider is true
                @vimeo_player[id].addEvent "play", @pause_timer
                @vimeo_player[id].addEvent "pause", @unpause_timer
                @vimeo_player[id].addEvent "finish", @unpause_timer
              return
            return
        return

    ###
    Handle video events at slide start for HTML5, YouTube and Vimeo videos
    ###
    @slide = (from, to) ->
      from_slide = @slides.eq(from)
      to_slide = @slides.eq(to)

      from_videos = $(@settings.selector.video, from_slide)
      to_videos = $(@settings.selector.video, to_slide)

      # Pause or stop videos from from slide
      if from != -1 and from_videos.length > 0
        from_videos.each (video_index, video)=>
          # to Video
          video = $(video)

          # Get video ID
          id = video.attr('id')

          # Get video type
          video_type = video.attr('data-slidea-video-type')

          # Check if the video resets when next slide is triggered
          reset = video.attr('data-slidea-reset') == 'true'

          # Clear the video timeout for the to video
          clearTimeout @video_timeline[id]

          # HTML5
          if video_type == 'html5'
            # Pause the video
            video.get(0).pause()

            # Reset the video after the slide animation has finished
            if reset
              setTimeout (=>
                video.get(0).current_time = 0
                return
              ), @data[to].background[0].animation[0].duration

          # Youtube
          else if video_type == 'youtube'
            # Pause the video
            @youtube_player[id].pauseVideo()

            # Reset the video after the slide animation has finished
            if reset
              setTimeout (=>
                @youtube_player[id].stopVideo()
                return
              ), @data[to].background[0].animation[0].duration

          # Vimeo
          else if video_type == 'vimeo'
            # Pause the video
            @vimeo_player[id].api 'pause'

            # Reset the video after the slide animation has finished
            if reset
              setTimeout (=>
                @vimeo_player[id].api 'unload'
                return
              ), @data[to].background[0].animation[0].duration
          return

        @log "Paused (handled) videos from slide #{from}."

      if to_videos.length > 0
        # Play videos from to slide
        to_videos.each  (index, video) =>
          # Get video
          video = $(video)

          # Get video ID
          id = video.attr('id')

          # Set try interval data
          i = 0
          tries = 10
          delay = 500
          interval = undefined

          # Check if video should autoplay
          autoplay = video.attr('data-slidea-autoplay') == 'true'
          if video.attr('data-slidea-autoplay-time')?
            autoplay_time = parseInt(video.attr('data-slidea-autoplay-time'), 10)
          else
            autoplay_time = 100

          # Check if the video pauses the slider
          pause_slider = video.attr('data-slidea-pause-slider') == 'true'

          # HTML5
          if video.attr('data-slidea-video-type') == 'html5'
            if autoplay == true
              # Start the video player after the set delay
              @video_timeline[id] = setTimeout((->
                video.get(0).play()
                return
              ), autoplay_time)

          # Youtube
          if video.attr('data-slidea-video-type') == 'youtube'
            if autoplay == true
              # Try to get the youtube player
              i = 0
              interval = setInterval =>
                i++
                if i == tries
                  clearInterval interval
                else if !video.attr('data-slidea-ready')? or
                        !defined(@youtube_player[id]) or
                        typeof @youtube_player[id].playVideo != 'function'
                  return
                else
                  clearInterval interval

                # Start the video player after the set delay
                @video_timeline[id] = setTimeout =>
                  @youtube_player[id].playVideo()
                  return
                , autoplay_time
                return
              , delay

          # Vimeo
          if video.attr('data-slidea-video-type') == 'vimeo'
            if autoplay == true
              # Try to get the vimeo player
              i = 0
              interval = setInterval =>
                i++
                if i == tries
                  clearInterval interval
                else if !video.attr('data-slidea-ready')? or
                        typeof @vimeo_player[id].api != 'function'
                  return
                else
                  clearInterval interval

                # Start the video player after the set delay
                @video_timeline[id] = setTimeout =>
                  Froogaloop(id).api 'play'
                  return
                , autoplay_time
                return
              , delay
          return

        @log "Played (handled) videos from slide #{to}."
      return

    @resize = ->
      @slides.each (i, element) =>
        slide = $ element
        # Fit slidea videos to their containers
        $(@settings.selector.video, @element).each (i, video)=>
          video = $(video)
          parent = video.parent()

          if parent.is('.slidea-video-background')
            return

          height = parent.height()
          width = parent.width()

          video.css
            width: width
            height: height

          return

        # Set slide to have a full screen Video Background
        video_background = $('.slidea-video-background', slide)
        if video_background.length > 0
          video = $('.video', video_background)

          data_width = parseInt(video.attr('data-slidea-width'))
          data_height = parseInt(video.attr('data-slidea-height'))

          video_width = @slider_width
          video_height = video_width * data_height / data_width

          margin_left = -(video_width - (@slider_width)) / 2
          margin_top = -(video_height - (@slider_height)) / 2

          video.css
            'width': video_width
            'height': video_height
            'margin-left': margin_left
            'margin-top': margin_top
        return
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'video', $.fn.slidea.video

) window.jQuery, window, document
