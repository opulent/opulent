(($, window, document) ->
  "use strict"

  $.fn.slidea.thumbnails = ->
    ###
    Set up slider thumbnails
    ###
    @settings =
      enabled: false # Add thumbnails
      visible: # Maximum number of thumbnails on page
        xs: 12
        sm: 6
        md: 6
        lg: 5
        xlg: 5
      position: "bottom" # Thumbnails position before or after
      class: "" # Additional thumbnail classes

    ###
    Scroll to the nth thumbnail in the collection
    ###
    scroll_to_thumbnail = (to) ->
      to = 0 if to < 0

      # Calculate distance to thumbnail
      # thumbnails may have variable sizes
      distance = 0
      @thumbnails.elements.each (index, item) =>
        return false if index == to
        if @settings.thumbnails.orientation == 'horizontal'
          distance += $(item).width()
        else if @settings.thumbnails.orientation == 'vertical'
          distance += $(item).height()
        return

      # If distance required is greater than the last set of thumbnails we can
      # see, then don't go past them
      if @thumbnails.size - distance < @thumbnails.parent_size
        distance = @thumbnails.size - @thumbnails.parent_size

      # Set the new starting position
      @thumbnails.starting_position = -distance

      # Animate the thumbnails to the new position
      if @settings.thumbnails.orientation == 'horizontal'
        transform = 'translate3d(' + (-distance) + 'px, 0, 0)'
      else if @settings.thumbnails.orientation == 'vertical'
        transform = 'translate3d(0, ' + (-distance) + 'px, 0)'

      # Animate thumbnails inner wrapper
      @thumbnails.inner.addClass('animating').css
        'transform': transform
        '-o-transform': transform
        '-ms-transform': transform
        '-moz-transform': transform
        '-webkit-transform': transform
      setTimeout =>
        @thumbnails.inner.removeClass 'animating'
        return
      , 700
      return

    ###
    Resize thumbnails wrapper
    ###
    resize_wrapper = ->
      return unless @thumbnails.loaded

      # Set thumbnails container size and set padding in case of
      # vertical orientation
      if @settings.thumbnails.orientation == 'horizontal'
        thumbnail_height = $('img', @thumbnails.elements.eq(0)).height()
        @thumbnails.container.height thumbnail_height
      else if @settings.thumbnails.orientation == 'vertical'
        thumbnail_width = $('img', @thumbnails.elements.eq(0)).width()
        @parent.css "padding-#{@settings.thumbnails.position}": thumbnail_width
        @thumbnails.container.width $('img', @thumbnails.elements.eq(0)).width()

      return

    ###
    Update slide data
    ###
    @get_slide_data = (index, slide) ->
      unless @data[index].thumbnail?
        thumbnail = slide.attr('data-slidea-thumbnail')
        if thumbnail?
          @data[index].thumbnail = thumbnail
        else
          @data[index].thumbnail = $(@settings.selector.background, slide).attr('src')
      return

    ###
    Initialize thumbnails
    ###
    @initialize = ->
      @thumbnails.loaded = false
      return

    ###
    Wrap slidea inside a thumbnails wrapper for position handling
    ###
    @wrap_objects = ->
      @thumbnails = {}

      # Add wrapper
      @element.wrap "<div class=\"slidea-with-thumbnails #{@settings.thumbnails.position}\"><div class='slidea-with-thumbnails-container'></div></div>"

      # Set new parent elements
      @parent = @element.parent()
      @thumbnails.parent = @parent.parent()
      return

    ###
    Add thumbnails to the slider
    ###
    @load = ->
      # Set thumbnails orientation
      if ['left', 'right'].indexOf(@settings.thumbnails.position) != -1
        @settings.thumbnails.orientation = 'vertical'
      else
        @settings.thumbnails.orientation = 'horizontal'

      # Get thumbnails count for the current responsive size
      thumbs_count = @settings.thumbnails.visible[@current_responsive_size]

      # Get parent sizes
      parent_height = @wrapper_height
      parent_width = @wrapper_width

      # Set parameters for horizontal or vertical thumbnails
      # scrolling orientation
      if @settings.thumbnails.orientation == 'horizontal'
        individual_size = parent_width / thumbs_count
        inner_size = individual_size * @slides_length
        css_param = 'width'
      else if @settings.thumbnails.orientation == 'vertical'
        individual_size = parent_height / thumbs_count
        inner_size = individual_size * @slides_length
        css_param = 'height'

      # Thumbnails HTML Code
      html = ""
      html += "<div class=\"slidea-thumbnails-container\">"
      html += "<div class=\"slidea-thumbnails #{@settings.thumbnails.class} #{@settings.thumbnails.orientation}\">"
      html += "<div class=\"slidea-thumbnails-inner\" style=\"#{css_param}: " + inner_size + "px;\">"
      $.each @data, (index, item) ->
        html += "<div class=\"slidea-thumbnail-wrapper\" style=\"#{css_param}: " + individual_size + "px;\">"
        html += "<img class=\"slidea-thumbnail\" src=\"" + item.thumbnail + "\" alt=\"Slide " + index + "\" />"
        html += "</div>"
      html += "</div>"
      html += "</div>"
      html += "</div>"

      # Append thumbnails wrapper
      @thumbnails.wrapper = $(html)
      if  ["top", "left", "right"].indexOf(@settings.thumbnails.position) != -1
        @element.closest('.slidea-with-thumbnails').prepend @thumbnails.wrapper
      else if @settings.thumbnails.position is "bottom"
        @element.closest('.slidea-with-thumbnails').append @thumbnails.wrapper
      else
        @settings.thumbnails.position.append @thumbnails.wrapper

      # Set thumbnails relevant elements
      @thumbnails.inner = $(".slidea-thumbnails-inner", @thumbnails.wrapper)
      @thumbnails.elements = $(".slidea-thumbnail-wrapper", @thumbnails.wrapper)
      @thumbnails.container = $('.slidea-thumbnails-container', @thumbnails.parent)

      # Set thumbnails inner size and parent size
      if @settings.thumbnails.orientation == 'horizontal'
        @thumbnails.size = @thumbnails.inner.width()
        @thumbnails.parent_size = @thumbnails.wrapper.width()
      else if @settings.thumbnails.orientation == 'vertical'
        @thumbnails.size = @thumbnails.inner.height()
        @thumbnails.parent_size = @thumbnails.wrapper.height()

      # Set thumbnails click event
      @thumbnails.elements.each (i, el) =>
        $thumbnail = $(el)
        $thumbnail.on "click", =>
          @thumbnails.elements.filter(".active").removeClass "active"
          $thumbnail.addClass "active"
          @slide i
          return
        return

      # Prevent thumbnail image dragging
      $("img", @thumbnails.elements).on "dragstart", (event) ->
        event.preventDefault()
        return

      # Startind direction used for animation
      @thumbnails.starting_position = 0
      @thumbnails.starting_direction = undefined

      # Set thumbnails on touch events
      if @settings.touch is true
        touch_thumbnails = new Hammer @thumbnails.wrapper[0]

        if @settings.thumbnails.orientation == 'horizontal'
          pan_events = 'panleft panright'
          touch_thumbnails.get('pan').set
            direction: Hammer.DIRECTION_HORIZONTAL
        else if @settings.thumbnails.orientation == 'vertical'
          pan_events = 'panup pandown'
          touch_thumbnails.get('pan').set
            direction: Hammer.DIRECTION_VERTICAL


        # Bind touch event to the thumbnails
        touch_thumbnails.on "panstart pancancel panend #{pan_events}", (event) =>
          if @settings.thumbnails.orientation == 'horizontal'
            distance = event.deltaX
          else if @settings.thumbnails.orientation == 'vertical'
            distance = event.deltaY

          # When moving, sync the slider with the mouse movement
          if @settings.thumbnails.orientation == 'horizontal' and event.type is 'panleft' or event.type is 'panright'
            if event.direction is Hammer.DIRECTION_LEFT or event.direction is Hammer.DIRECTION_RIGHT
              transform = "translate3d(#{@thumbnails.starting_position + distance}px, 0, 0)"
              @thumbnails.inner.css
                'transform': transform
                '-o-transform': transform
                '-ms-transform': transform
                '-moz-transform': transform
                '-webkit-transform': transform

          else if @settings.thumbnails.orientation == 'vertical' and event.type is 'panup' or event.type is 'pandown'
            if event.direction is Hammer.DIRECTION_UP or event.direction is Hammer.DIRECTION_DOWN
              transform = "translate3d(0, #{@thumbnails.starting_position + distance}px, 0)"
              @thumbnails.inner.css
                'transform': transform
                '-o-transform': transform
                '-ms-transform': transform
                '-moz-transform': transform
                '-webkit-transform': transform

          # Get starting transform position
          else if event.type is 'panstart' and !@thumbnails.inner.hasClass 'animating'
            @thumbnails.inner.addClass 'slidea-dragging'

            @thumbnails.starting_direction = event.direction

          # When letting go, check if we have enough distance to go to the next slide
          # otherwise return to the initial position
          else if event.type is 'panend'
            @thumbnails.inner.removeClass 'slidea-dragging'

            # Set new starting position
            @thumbnails.starting_position += distance

            # Don't go past last thumbnail
            if @thumbnails.starting_position < - @thumbnails.size + @thumbnails.parent_size
              scroll_to_thumbnail.call @, @slides_length - 1

            # Don't go past first thumbnail
            else if @thumbnails.starting_position > 0
              scroll_to_thumbnail.call @, 0

            # Snap to current thumbnail
            else
              snap_distance = 0
              @thumbnails.elements.each (index, item) =>
                if @thumbnails.starting_position > -snap_distance
                  scroll_to_thumbnail.call @, index
                  return false

                if @settings.thumbnails.orientation == 'horizontal'
                  snap_distance += $(item).width()
                else if @settings.thumbnails.orientation == 'vertical'
                  snap_distance += $(item).height()

                return

          event.preventDefault()
          return

      # Thumbnails are loaded
      @thumbnails.loaded = true

      # Resize the slider after adding thumbnails
      $('img', @thumbnails.elements.eq(0)).load =>
        @resize()
        return

      return

    # Before resize event
    #
    @before_resize = ->
      # Set wrapper sizes
      resize_wrapper.call @
      return

    # Resize thumbnails when window resize happens
    #
    @resize = ->
      return unless @thumbnails.loaded

      thumbs_count = @settings.thumbnails.visible[@current_responsive_size]

      # Get parent sizes
      parent_height = @wrapper_height
      parent_width = @wrapper_width

      # Set parameters for horizontal or vertical thumbnails
      # scrolling orientation
      if @settings.thumbnails.orientation == 'horizontal'
        individual_size = parent_width / thumbs_count
        inner_size = individual_size * @slides_length
        css_param = 'width'
      else if @settings.thumbnails.orientation == 'vertical'
        individual_size = parent_height / thumbs_count
        inner_size = individual_size * @slides_length
        css_param = 'height'

      # Set inner and thumbnails width or height
      @thumbnails.inner[css_param] inner_size
      @thumbnails.elements[css_param] individual_size

      if @settings.thumbnails.orientation == 'horizontal'
        @thumbnails.size = inner_size
      else if @settings.thumbnails.orientation == 'vertical'
        @thumbnails.size = inner_size

      # Set parent size
      @thumbnails.parent_size = @thumbnails.wrapper[css_param]()

      # Scroll to current thumbnail
      scroll_to_thumbnail.call @, @current

      return

    @slide = (from, to) ->
      return unless @thumbnails.loaded

      @thumbnails.elements.filter('.active').removeClass 'active'
      @thumbnails.elements.eq(to).addClass 'active'
      scroll_to_thumbnail.call @, to

      @log "Scrolled to thumbnail #{to}."
      return

    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'thumbnails', $.fn.slidea.thumbnails

) window.jQuery, window, document
