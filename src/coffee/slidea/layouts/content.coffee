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

  $.fn.slidea.contentLayout = ->
    ###
    Resize slider to showcase the given slide
    ###
    resize_slider = (slide) ->
      # Reset current slide index if slider hasn't started
      if slide is -1
        slide = @first_slide

      # Set size for the current slide
      content_height = $(@settings.selector.contentContainer, @active).outerHeight(true)

      # Slider Size
      @slider_width = @parent_width
      @slider_height = content_height

      # Set overvflow wrapper size
      @animate.to @wrapper, 0.5,
        css:
          height: @slider_height
          width: @slider_width

      # Set inner wrapper size
      @inner.width @slider_width
      @inner.height @slider_height

      @log "Slider size set to #{@slider_width} x #{@slider_height}"
      return

    ###
    Initialize the @parameters
    ###
    @initialize = ->
      # Add Classes
      @element.addClass 'slidea-content-layout'
      return

    ###
    Set up the slider and each of the slides
    ###
    @resize = ->
      unless @data?
        return

      resize_slider.apply @, [@current]

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
      return
    return

  # Add the layer to Slidea as a new instance
  #
  $.slidea.register_layout 'content', $.fn.slidea.contentLayout
  return

) jQuery, window, document
