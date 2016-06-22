(($, window, document) ->
  "use strict"

  $.fn.slidea.contentScaling = ->
    ###
    Enable or disable content scaling feature
    ###
    @settings =
      enabled: false # Scale content based on parent width
      mode: 'responsive' # natural or responsive
      factor: # Scale multiplication coefficient
        xs: 1
        sm: 1
        md: 1
        lg: 1
        xlg: 1


    scale_content = (index) ->
      return if index == -1

      current_slide = @slides.eq(index)
      content = $('.slidea-content', current_slide)

      # Set scaling origin
      origin_x = '0%'
      if content.hasClass 'slidea-content-center'
        origin_y = '50%'
      else if content.hasClass 'slidea-content-bottom'
        origin_y = '100%'
      else
        origin_y = '0%'


      # Set reference widths
      content_width = content.width()
      calculated_width = @wrapper_width


      if @settings.contentScaling.mode is 'responsive'
        # Calculate scaling value based on current width
        scaling_value = @settings.contentScaling.factor[@current_responsive_size]

        @animate.set content,
          scale: scaling_value
          x:  (calculated_width - content_width * scaling_value) /2
          transformOriginX: origin_x
          transformOriginY: origin_y
      else
        # Calculate scaling width based on scaling factor
        scaling_reference = @data[index].background[0].width

        # Calculate scaling value based on current width
        scaling_value = calculated_width / scaling_reference * @settings.contentScaling.factor[@current_responsive_size]

        # Center content based on current resize value 8
        if @settings.contentScaling.factor[@current_responsive_size] == 1
          @animate.set content, x: 0
        else
          @animate.set content, x: (calculated_width * (1 - @settings.contentScaling.factor[@current_responsive_size]) / 2)

        # @animate.set content, 'translateX', '-50%'
        @animate.set content,
          z: 0
          transformOriginX: origin_x
          transformOriginY: origin_y
          scaleX: scaling_value
          scaleY: scaling_value

      @log "Content has been scaled with #{scaling_value}."

      return

    ###
    Scale content on window resize
    ###
    @slide = (from, to) ->
      scale_content.call @, to
      return

    @resize = ->
      scale_content.call @, @current
      return
    return

  # Add the feature to RockSlider as a new instance
  #
  $.slidea.register_module 'contentScaling', $.fn.slidea.contentScaling

) window.jQuery, window, document
