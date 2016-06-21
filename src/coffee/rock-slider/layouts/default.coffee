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

  $.fn.rockSlider.defaultLayout = ->
    # Initialize the @parameters
    #
    @init = ->
      # Add Classes
      @element.addClass 'rock-slider-default'

      return

    # Set up the slider and each of the slides
    #
    @setup = ->
      unless @cache?
        return

      # Slider Size
      @element_width = @parent_width
      @element_height = @parent_width / @settings.width * @settings.height

      @element.height @element_height
      @element.width @element_width

      @outer.height @element_height
      @outer.width @element_width

      # Compute visible background image size and set margins to center the image
      @slides.each (i, element) =>
        $slide = $ element

        # Set slider visible width and height, meaning area which is inside the
        # container, overflowing on the screen
        @visible_width = @element_width
        @visible_height = @visible_width / @cache[i].background[0].width * @cache[i].background[0].height

        # Slide Layers
        width_ratio = @element_width / @settings.width
        height_ratio = @element_height / @settings.height

        # Get top, right, bottom and left position of the slide layers
        $layers = $('.rock-layer-wrapper', $slide)
        $layers.each (layer_index, layer) =>
          layer_css = {}

          if 'top' of @cache[i].layer[layer_index].position
            layer_css.top = height_ratio * @cache[i].layer[layer_index].position.top
          else if 'bottom' of @cache[i].layer[layer_index].position
            layer_css.bottom = height_ratio * @cache[i].layer[layer_index].position.bottom

          if 'left' of @cache[i].layer[layer_index].position
            layer_css.left = width_ratio * @cache[i].layer[layer_index].position.left
          else if 'right' of @cache[i].layer[layer_index].position
            layer_css.right = width_ratio * @cache[i].layer[layer_index].position.right

          if 'width' of @cache[i].layer[layer_index]
            layer_css.width = width_ratio * @cache[i].layer[layer_index].width
          if 'height' of @cache[i].layer[layer_index]
            layer_css.height = height_ratio * @cache[i].layer[layer_index].height

          $(layer).css layer_css

          return

        # Fit rock-slider videos to their containers
        # $(@settings.selector.video, @element).each (i, video)=>
        #   $video = $(video)
        #   $parent = $video.parent()
        #
        #   if $parent.is('.rock-video-background')
        #     return
        #
        #   height = $parent.height()
        #   width = $parent.width()
        #
        #   $video.css
        #     width: width
        #     height: height
        #
        #   return

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
      return
    return

  # Add the layer to RockSlider as a new instance
  #
  $.rockSlider.add_layout 'default', $.fn.rockSlider.defaultLayout
  return

) jQuery, window, document
