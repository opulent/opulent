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

  $.fn.slidea.defaultLayout = ->
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

      # Slider Size
      @slider_width = @parent_width
      @slider_height = @parent_width / current_slide_image_width * current_slide_image_height

      # Set overvflow wrapper size
      @animate.to @wrapper, 0.75,
        css:
          height: @slider_height
          width: @slider_width

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

      # Set slide images width
      slide_image_width = @data[index].background[0].width
      slide_image_height = @data[index].background[0].height

      # Set slider visible width and height, meaning area which is inside the
      # container, overflowing on the screen
      slide_width = @slider_width
      slide_height = slide_width / slide_image_width * slide_image_height

      # Slide Layers
      width_ratio = slide_width / slide_image_width
      height_ratio = slide_height / slide_image_height

      # Get top, right, bottom and left position of the slide layers
      slide_layers = $(@settings.selector.layerWrapper, slide)
      slide_layers.each (layer_index, layer) =>
        layer_css = {}

        if 'top' of @data[index].layer[layer_index].position
          layer_css.top = height_ratio * @data[index].layer[layer_index].position.top
        else if 'bottom' of @data[index].layer[layer_index].position
          layer_css.bottom = height_ratio * @data[index].layer[layer_index].position.bottom

        if 'left' of @data[index].layer[layer_index].position
          layer_css.left = width_ratio * @data[index].layer[layer_index].position.left
        else if 'right' of @data[index].layer[layer_index].position
          layer_css.right = width_ratio * @data[index].layer[layer_index].position.right

        if 'width' of @data[index].layer[layer_index]
          layer_css.width = width_ratio * @data[index].layer[layer_index].width
        if 'height' of @data[index].layer[layer_index]
          layer_css.height = height_ratio * @data[index].layer[layer_index].height

        $(layer).css layer_css
        return
      return

    ###
    Initialize slider layout
    ###
    @initialize = ->
      # Add Classes
      @element.addClass 'slidea-default-layout'
      return

    ###
    Resize slide with given index
    ###
    @resize_slide = (index)->
      resize_slide.apply @, [index]
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

    ###
    Display the slide element with index i and program the animation logic for
    each background, layer and object

    Previous slide needs to be set in order to preview the out animation so that
    we can create a transition between every slide

    The layers and objects need to be stopped and reanimated in order to prevent
    animation flaws.

    Layer and object animation will transition from an inverted
    animation state to a default state to provide normal slider behaviour
    ###
    @slide = (from, to) ->
      resize_slider.apply @, [to]
      resize_slide.apply @, [to]
      return
    return

  ###
  Add the layer to Slidea as a new instance
  ###
  $.slidea.register_layout 'default', $.fn.slidea.defaultLayout
  return

) jQuery, window, document
