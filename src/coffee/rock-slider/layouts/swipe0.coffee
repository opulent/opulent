###

         dP oo       dP
         88          88
.d8888b. 88 dP .d888b88 .d8888b. .d8888b.
Y8ooooo. 88 88 88'  `88 88ooood8 88'  `88
      88 88 88 88.  .88 88.  ... 88.  .88
`88888P' dP dP `88888P8 `88888P' `88888P8
oooooooooooooooooooooooooooooooooooooooooo

@plugin    jQuery
@license   CodeCanyon Standard / Extended
@author    Alex Grozav
@company   Pixevil
@website   http://pixevil.com
@email     alex@grozav.com
###

(($, window, document) ->
  "use strict"

  $.fn.rockSlider.swipeLayout = ->
    # Initialize the @parameters
    #
    @init = ->
      # Initialize layout settings
      _defaults =
        speed: 700
        overflow: 0
        highlight: true
        highlight_color: 'rgba(0, 156, 255, 1)'
        animate_background: false
        threshold: 25

      @settings.layout_settings = $.extend {}, _defaults, @settings.layout_settings


      # Add Classes
      @element.addClass 'rock-slider-swipe'
      @slides.wrap '<div class="rock-swipe-wrapper"></div>'

      # Wrap each slide in order to prevent overflowing backgrounds
      @wrapped_slides = $('.rock-swipe-wrapper', @element)

      # Add highlight objects
      @left_highlight = $ '<div class="rock-swipe-highlight left"></div>'
      @right_highlight = $ '<div class="rock-swipe-highlight right"></div>'

      $('.rock-outer').prepend @left_highlight
      $('.rock-outer').prepend @right_highlight

      # Get CSS Animation speed
      $('html > head').append $ "<style data-rock-style-id='#{@id}'>" +
        "##{@id} .rock-inner.animating { " +
        "transition: transform #{@settings.layout_settings.speed}ms ease;" +
        "-o-transition: -o-transform #{@settings.layout_settings.speed}ms ease;" +
        "-moz-transition: -moz-transform #{@settings.layout_settings.speed}ms ease;" +
        "-webkit-transition: -webkit-transform #{@settings.layout_settings.speed}ms ease;" +
        " }" +
        "</style>"

      # Keep track of slider translation position
      @starting_position = 0
      @element.attr 'data-rock-swipe-position', 0

      # Add touch synchronisation to the slider element
      @touch_object.destroy()
      @touch_object = new Hammer @element[0]
      @touch_object.get('pan').set
        direction: Hammer.DIRECTION_HORIZONTAL
      @starting_direction = undefined
      @touch_object.on 'panstart pancancel panend panleft panright', (event) =>
        distance = event.deltaX

        # When moving, sync the slider with the mouse movement
        if event.type is 'panleft' or event.type is 'panright'
          leftmost_slide = @current == 0 and event.deltaX > 0
          rightmost_slide = @current == @slides_length - 1 and event.deltaX < 0
          if leftmost_slide or rightmost_slide
            if @settings.layout_settings.highlight
              if leftmost_slide
                @left_highlight.css
                  'box-shadow': "0px 0px #{distance}px 0px #{@settings.layout_settings.highlight_color}"
                  '-moz-box-shadow': "0px 0px #{distance}px 0px #{@settings.layout_settings.highlight_color}"
                  '-webkit-box-shadow': "0px 0px #{distance}px 0px #{@settings.layout_settings.highlight_color}"
              else
                @right_highlight.css
                  'box-shadow': "0px 0px #{-distance}px 0px #{@settings.layout_settings.highlight_color}"
                  '-moz-box-shadow': "0px 0px #{-distance}px 0px #{@settings.layout_settings.highlight_color}"
                  '-webkit-box-shadow': "0px 0px #{-distance}px 0px #{@settings.layout_settings.highlight_color}"

            if @settings.layout_settings.overflow is 0
              return
            else
              distance /= @settings.layout_settings.overflow

          if event.direction is Hammer.DIRECTION_LEFT or event.direction is Hammer.DIRECTION_RIGHT
            transform = "translate3d(#{@starting_position + distance}px, 0, 0)"
            @inner.css
              'transform': transform
              '-o-transform': transform
              '-ms-transform': transform
              '-moz-transform': transform
              '-webkit-transform': transform

        # Get starting transform position
        else if event.type is 'panstart' and !@inner.hasClass 'animating'
          @element.addClass 'rock-dragging'

          @starting_direction = event.direction


        # When letting go, check if we have enough distance to go to the next slide
        # otherwise return to the initial position
        else if event.type is 'panend'
          @element.removeClass 'rock-dragging'

          if @settings.layout_settings.highlight
            shadow_reset =
              'box-shadow': "0px 0px 0px 0px #{@settings.layout_settings.highlight_color}"
              '-moz-box-shadow': "0px 0px 0px 0px #{@settings.layout_settings.highlight_color}"
              '-webkit-box-shadow': "0px 0px 0px 0px #{@settings.layout_settings.highlight_color}"

            @left_highlight.addClass('animating').css shadow_reset
            @right_highlight.addClass('animating').css shadow_reset

            setTimeout =>
              @left_highlight.removeClass 'animating'
              @right_highlight.removeClass 'animating'
            , 700

          if Math.abs(distance) > @settings.layout_settings.threshold / 100 * @parent_width
            if event.direction is Hammer.DIRECTION_RIGHT
              @slide @current - 1
            else if event.direction is Hammer.DIRECTION_LEFT
              @slide @current + 1

          else
            transform = 'translate3d(' + (@starting_position) + 'px, 0, 0)'
            @inner.addClass('animating').css
              'transform': transform
              '-o-transform': transform
              '-ms-transform': transform
              '-moz-transform': transform
              '-webkit-transform': transform
            setTimeout =>
              @inner.removeClass 'animating'
            , @settings.layout_settings.speed

        event.preventDefault()
        return
      return


    # Set up the slider and each of the slides
    #
    @setup = ->
      unless @cache?
        return

      @element.height @parent_height
      @element.width @parent_width

      # Set actual slider size, visible on the screen without overflowing
      #
      # @if parent_height > sliderHeight
      #      Set 100% height to slides
      # @else
      #      Set 100% width to slides
      if @parent_height > @element_height
        @element_height = @parent_height
        @element_width = @element_height / @settings.layout_settings.height * @settings.layout_settings.width

        @inner.height @element_height
        @inner.width @parent_width * @slides_length

        @wrapped_slides.height @element_height
        @wrapped_slides.width @parent_width

      else
        @element_width = @parent_width
        @element_height = @element_width / @settings.layout_settings.width * @settings.layout_settings.height

        @inner.height @element_height
        @inner.width @element_width * @slides_length

        @wrapped_slides.height @parent_height
        @wrapped_slides.width @element_width

      @slides.height @element_height
      @slides.width @element_width


      # Slides Size
      # Compute visible background image size and set margins to center the image
      @slides.each (i, element) =>
        $slide = $ element

        # Set slider visible width and height, meaning area which is inside the
        # container, overflowing on the screen
        @visible_width = @element_width
        @visible_height = @visible_width / @cache[i].background[0].width * @cache[i].background[0].height

        # Margins for centering the images
        margin_left = -(@visible_width - (@parent_width)) / 2
        margin_top = -(@visible_height - (@parent_height)) / 2

        # Set the margins
        $background = $('.rock-background-wrapper', $slide)
        $background.css
          'margin-top': margin_top
          'margin-left': margin_left

        # Slide Layers
        width_ratio = @element_width / @settings.layout_settings.width
        height_ratio = @element_height / @settings.layout_settings.height

        # Get top, right, bottom and left position of the slide layers
        $layers = $('.rock-layer-wrapper', $slide)
        $layers.each (layer_index, layer) =>
          layer_css = {}

          if 'top' of @cache[i].layer[layer_index].position
            layer_css.top = height_ratio * @cache[i].layer[layer_index].position.top + margin_top
          else if 'bottom' of @cache[i].layer[layer_index].position
            layer_css.bottom = height_ratio * @cache[i].layer[layer_index].position.bottom - margin_top

          if 'left' of @cache[i].layer[layer_index].position
            layer_css.left = width_ratio * @cache[i].layer[layer_index].position.left + margin_left
          else if 'right' of @cache[i].layer[layer_index].position
            layer_css.right = width_ratio * @cache[i].layer[layer_index].position.right - margin_left

          if 'width' of @cache[i].layer[layer_index]
            layer_css.width = width_ratio * @cache[i].layer[layer_index].width
          if 'height' of @cache[i].layer[layer_index]
            layer_css.height = height_ratio * @cache[i].layer[layer_index].height

          $(layer).css layer_css

          return


        # Set slide to have a full screen Video Background
        $video_background = $('.rock-video-background', $slide)
        if $video_background.length > 0
          $video = $('.video', $video_background)

          data_width = parseInt($video.attr('data-rock-width'))
          data_height = parseInt($video.attr('data-rock-height'))

          video_width = @element_width
          video_height = video_width * data_height / data_width

          margin_left = -(video_width - (@parent_width)) / 2
          margin_top = -(video_height - (@parent_height)) / 2

          $video.css
            'width': video_width
            'height': video_height
            'margin-left': margin_left
            'margin-top': margin_top

        return
      return

    # Display the slide element with index i and program the animation logic for
    # each background, layer and object
    #
    # Previous slide needs to be set in order to preview the out animation so that
    # we can create a transition between every slide
    #
    # The layers and objects need to be stopped and reanimated in order to prevent
    # animation flaws.
    #
    # Layer and object animation will transition from an inverted
    # animation state to a default state to provide normal slider behaviour
    #
    @slide = (i, prev) ->
      $layers = $('.rock-layer-wrapper', @active)
      $objects = $('.rock-object', @active)

      transform = 'translate3d(' + (-@parent_width * i) + 'px, 0, 0)'
      @inner.addClass('animating').css
        'transform': transform
        '-o-transform': transform
        '-ms-transform': transform
        '-moz-transform': transform
        '-webkit-transform': transform
      setTimeout =>
        @inner.removeClass 'animating'
      , @settings.layout_settings.speed


      @starting_position = -@parent_width * i
    return

  # Add the layer to RockSlider as a new instance
  #
  $.rockSlider.add_layout 'swipe', $.fn.rockSlider.swipeLayout
  return

) jQuery, window, document
