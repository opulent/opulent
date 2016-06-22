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

  $.fn.slidea.fluidLayout = ->
    # Extend layout settings
    @settings =
      anchor: 'center'
      size: 'fullscreen'

    ###
    Get Parent sizes
    ###
    set_parent_size = ->
      if @settings.layoutSettings.size == 'fullscreen'
        @parent_width = @window_width
        @parent_height = @window_height
      else if @settings.layoutSettings.size == 'screenHeight'
        @parent_height = @window_height
      else if @settings.layoutSettings.size == 'screenWidth'
        @parent_width = @window_width

    ###
    Resize slider to showcase the given slide
    ###
    resize_slider = (slide) ->
      # Reset current slide index if slider hasn't started
      if slide is -1
        slide = @first_slide

      # Set size for the current slide
      current_slide_image_width = @data[slide].background[0].width
      current_slide_image_height = @data[slide].background[0].height

      # Get parent size
      set_parent_size.call @

      # Slider Size
      @slider_width = @parent_width
      @slider_height = @parent_width / current_slide_image_width * current_slide_image_height

      if @parent_height > @slider_height
        @slider_width = @parent_height / current_slide_image_height * current_slide_image_width
        @slider_height = @parent_height

      # Set overvflow wrapper size
      @wrapper_width = @parent_width
      @wrapper_height = @parent_height
      @wrapper.css
        height: @wrapper_height
        width: @wrapper_width


      # Set inner wrapper size
      @inner.width @slider_width
      @inner.height @slider_height

      @log "Slider size set to #{@slider_width} x #{@slider_height}"
      return

    ###
    Resize the slide with the given index
    ###
    resize_slide = (index) ->
      return unless @data[index].background?

      slide = @slides.eq(index)

      # Get parent size
      set_parent_size.call @

      # Set slide images width
      slide_image_width = @data[index].background[0].width
      slide_image_height = @data[index].background[0].height

      # Set slider visible width and height, meaning area which is inside the
      # container, overflowing on the screen
      slide_width = @slider_width
      slide_height = slide_width / slide_image_width * slide_image_height

      $(@settings.selector.contentWrapper, @element).css
        height: @parent_height
        width: @parent_width

      # Slide Layers
      width_ratio = slide_width / slide_image_width
      height_ratio = slide_height / slide_image_height

      # Margins for centering the images
      switch @settings.layoutSettings.anchor
        when 'center'
          margin_left = -(@slider_width - (@parent_width)) / 2
          margin_top = -(@slider_height - (@parent_height)) / 2
        when 'top'
          margin_left = -(@slider_width - (@parent_width)) / 2
          margin_top = 0
        when 'bottom'
          margin_left = -(@slider_width - (@parent_width)) / 2
          margin_top = -(@slider_height - (@parent_height))
        when 'left'
          margin_left = 0
          margin_top = -(@slider_height - (@parent_height))
        when 'right'
          margin_left = -(@slider_width - (@parent_width))
          margin_top = -(@slider_height - (@parent_height)) / 2
        when 'top-left'
          margin_left = 0
          margin_top = 0
        when 'bottom-left'
          margin_left = 0
          margin_top = -(@slider_height - (@parent_height))
        when 'top-right'
          margin_left = -(@slider_width - (@parent_width))
          margin_top = 0
        when 'bottom-right'
          margin_left = -(@slider_width - (@parent_width))
          margin_top = -(@slider_height - (@parent_height))

      margin_left = 0 if margin_left > 0
      margin_top = 0 if margin_top > 0

      $(@settings.selector.backgroundWrapper, slide).css
        'margin-top': margin_top
        'margin-left': margin_left

      # Get top, right, bottom and left position of the slide layers
      slide_layers = $(@settings.selector.layerWrapper, slide)
      slide_layers.each (layer_index, layer) =>
        layer_css = {}

        if 'top' of @data[index].layer[layer_index].position
          layer_css.top = height_ratio * @data[index].layer[layer_index].position.top + margin_top
        else if 'bottom' of @data[index].layer[layer_index].position
          layer_css.bottom = height_ratio * @data[index].layer[layer_index].position.bottom - margin_top

        if 'left' of @data[index].layer[layer_index].position
          layer_css.left = width_ratio * @data[index].layer[layer_index].position.left + margin_left
        else if 'right' of @data[index].layer[layer_index].position
          layer_css.right = width_ratio * @data[index].layer[layer_index].position.right - margin_left

        if 'width' of @data[index].layer[layer_index]
          layer_css.width = width_ratio * @data[index].layer[layer_index].width
        if 'height' of @data[index].layer[layer_index]
          layer_css.height = height_ratio * @data[index].layer[layer_index].height

        $(layer).css layer_css
        return
      return

    ###
    Initialize the @parameters
    ###
    @initialize = ->
      # Add Classes
      @element.addClass 'slidea-fluid-layout'

      return

    ###
    Set up the slider and each of the slides
    ###
    @resize = ->
      unless @data?
        return

      resize_slider.apply @, [@current]

      # Compute visible background image size and set margins to center the image
      @slides.each (index, slide) =>
        resize_slide.apply @, [index]
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
    @slide = (from, to) ->
      resize_slider.apply @, [to]
      resize_slide.apply @, [to]
      return
    return

  # Add the layer to Slidea as a new instance
  #
  $.slidea.register_layout 'fluid', $.fn.slidea.fluidLayout
  return

) jQuery, window, document
