###
         oo                            dP dP
                                       88 88
dP   .dP dP .d8888b. dP    dP .d8888b. 88 88 .d8888b. dP.  .dP
88   d8' 88 Y8ooooo. 88    88 88'  `88 88 88 88'  `88  `8bd8'
88 .88'  88       88 88.  .88 88.  .88 88 88 88.  .88  .d88b.
8888P'   dP `88888P' `88888P' `88888P8 dP dP `88888P8 dP'  `dP
ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

A smart and efficient parallax plugin by Alex Grozav
from Pixevil built to make the web a better place.

@plugin  	Visuallax
@author 	Alex Grozav
@website  http://pixevil.com
@version 	1.0
@license 	Commercial
###

(($, window, document) ->
  "use strict"

  # This is where we place our default values.
  _defaults =
    orientation: 'vertical'
    mode: 'default' # 'to-middle', 'from-middle', 'default'

    overflow: false # Take parent overflowing into account
    reset: false # Reset animation when conditions not met

    transform: {}
    transform_style:
      opacity: 'default'
      scale: 'default'

    parent: false # Parent element, by default set as direct parent
    source: false # Element from which to gather size data

    screen_size: # Refers to the current screen size
      xs: 0
      sm: 768
      md: 992
      lg: 1200
      xlg: 1840
    disabled: # Deactivate certain animations
      xs: []
      sm: []
      md: []
      lg: []
      xlg: []

  debug: true

  # @Visuallax
  $.visuallax = (element, options) ->
    @_defaults = _defaults
    @settings = $.extend true, {}, @_defaults, options

    @element = $ element
    @source = if @settings.source then @settings.source else @element
    @parent = if @settings.parent then @settings.parent else @source.parent()

    @window = $ window

    @image_resize_timeout = null

    # Get all child elements which have revelate
    # events attached through data attributes
    #
    @initialize = =>
      @get_data()

      @set_size()
      @set_position()

      @set_responsive_context()

      @bind_resize()
      @bind_scroll()

      @parallax @window.scrollTop()

      return

    # Initialize element cache with its data settings
    #
    @get_data = =>
      data = @element.attr 'data-visuallax'
      if data?
        data = data.split /\,\s+/
        $.each data, (index, string) =>
          string = $.trim string
          string = string.split /\s+/
          string = string.map (n) ->
            if n is 'false' then false else n.toLowerCase()

          switch string[0]
            when 'translate', 'move'
              if string[1] == 'x' or string[1] == 'y' or string[1] == 'z'
                @settings.transform["translate#{string[1].toUpperCase()}"] = parseFloat string[2]
              else
                @settings.transform.translateY = parseFloat string[1]

            when 'rotate'
              if string[1] == 'x' or string[1] == 'y' or string[1] == 'z'
                @settings.transform["rotate#{string[1].toUpperCase()}"] = parseFloat string[2]
              else
                @settings.transform.rotateZ = parseFloat string[1]

            when 'opacity', 'fade'
              i = 1
              if string[i] is 'simple' or string[i] is 'default'
                @settings.transform_style.opacity = string[i++]
              @settings.transform.opacity = parseFloat string[i]

            when 'scale'
              i = 1
              if string[i] is 'simple' or string[i] is 'default'
                @settings.transform_style.scale = string[i++]
              @settings.transform.scale = parseFloat string[i]

            when 'disabled'
              i = 1
              while string[++i]
                @settings.disabled[string[1]].push string[i]
            else
              i = 0
              @settings[string[i++]] = string[i]
          return

      unless 'translateZ' of @settings.transform
        @settings.transform.translateZ = 0

      return

    # Set element top and bottom positioning on the page
    #
    @set_position = =>
      @top = @source.offset().top
      @bottom = @top + @source_height

      @left = @source.offset().left
      @right = @left + @source_width

      @parent_top = @parent.offset().top
      @parent_bottom = @parent_top + @parent_height

      @parent_left = @parent.offset().left
      @parent_right = @parent_left + @parent_width

      return


    # Set element and slider size
    #
    @set_size = =>
      @parent_width = @parent.outerWidth(true)
      @parent_height = @parent.outerHeight(true)

      @source_width = @source.outerWidth(true)
      @source_height = @source.outerHeight(true)

      @element_width = @element.outerWidth(true)
      @element_height = @element.outerHeight(true)

      @window_width = @window.width()
      @window_height = @window.height()

      return

    # Set current responsive range parameter as xs,sm,md or lg
    #
    @set_responsive_context = =>
      if @window_width >= @settings.screen_size.xlg
        @current_responsive_size = 'xlg'
      else if @window_width >= @settings.screen_size.lg
        @current_responsive_size = 'lg'
      else if @window_width >= @settings.screen_size.md
        @current_responsive_size = 'md'
      else if @window_width >= @settings.screen_size.sm
        @current_responsive_size = 'sm'
      else
        @current_responsive_size = 'xs'

      return

    # Reset all parameters to the default values
    #
    @reset = (style) =>
      reset =
        translateX: 0
        translateY: 0
        rotateX: 0
        rotateY: 0
        rotateZ: 0
        scale: 1
        opacity: 1

      if style is '*'
        for key, value in reset
          $.Velocity.hook @element, key, value
      else
        $.Velocity.hook @element, style, reset[style]

      return


    # Binds the slider window resize event to cache current window
    # width and height and to set the layout up
    #
    @bind_resize = =>
      @window.resize =>
        @set_size()
        @set_position()
        @set_responsive_context()

        @parallax @window.scrollTop()
        return
      return

    # Bind the window scroll event to fade content on scroll down
    #
    @bind_scroll = =>
      @window.on 'scroll', =>
        @parallax @window.scrollTop()
        return
      return

    # Parallax images when in fluid layout mode
    #
    # @param position [Fixnum] Current scrolling position
    #
    @parallax = (position) =>
      delta_y = (position + @window_height / 2 - (@top + @bottom) / 2)

      # Check if element is in view
      in_view = position + @window_height < @top || position > @bottom

      # Only parallax until the middle point or start from the middle point
      # if set as mode
      middle_trigger = (@settings.mode is 'to-middle' and delta_y >= 0) ||
                       (@settings.mode is 'from-middle' and delta_y <= 0)

      # Check if our element height is smaller than our parent height
      smaller_than_parent = @source_height < @parent_height

      # Do not overflow the parent height when parallaxing
      translated = if 'translateY' of @settings.transform
        @settings.transform.translateY * delta_y
      else
        0

      # Check if the translation we're using is overflowing our parent container
      overflowing_translation = (@top + translated > @parent_top) ||
                                (@bottom + translated > @parent_bottom)

      # If we need to check containment overflowing, this will be set to true
      overflow_condition = @settings.overflow && (smaller_than_parent || overflowing_translation)

      # Check if we need to return
      if in_view || middle_trigger || overflow_condition
        @reset '*' if @settings.reset
        return

      for transform, value of @settings.transform
        unless $.inArray(transform, @settings.disabled[@current_responsive_size]) is -1
          @reset transform
          return

        transform_unit = if transform.indexOf('translate') != -1
          'px'
        else if transform.indexOf('rotate') != -1
          'deg'
        else
          ''

        transform_factor = if transform of @settings.transform_style
          if @settings.transform_style[transform] is 'default'
            1 - Math.abs (delta_y / 100 * @settings.transform[transform])
          else
            1 - delta_y / 100 * @settings.transform[transform]
        else
          delta_y * value

        transform_string = "#{transform_factor}#{transform_unit}"

        $.Velocity.hook @element, transform, transform_string

      return

    @initialize()

  # Lightweight plugin wrapper that prevents multiple instantiations.
  #
  $.fn.visuallax = (opts) ->
    @each (index, element) ->
      unless $.data element, "visuallax"
        $.data element, "visuallax", new $.visuallax element, opts

) window.jQuery, window, document
