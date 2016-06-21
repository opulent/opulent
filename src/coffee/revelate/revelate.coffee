###
                                    dP            dP
                                    88            88
88d888b. .d8888b. dP   .dP .d8888b. 88 .d8888b. d8888P .d8888b.
88'  `88 88ooood8 88   d8' 88ooood8 88 88'  `88   88   88ooood8
88       88.  ... 88 .88'  88.  ... 88 88.  .88   88   88.  ...
dP       `88888P' 8888P'   `88888P' dP `88888P8   dP   `88888P'
ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

A smart and efficient scroll reveal plugin by Alex Grozav
from Pixevil built to make the web a better place.

@plugin  	Revelate
@author 	Alex Grozav
@website  http://pixevil.com
@version 	1.0
@license 	Commercial
###

(($, window, document) ->
  "use strict"

  # @Revelate
  $.revelate = (element, options) ->
    # This is where we place our default values.
    _defaults =
      selector: '[data-revelate]'
      delay: 400
      edge: [150, 150]
      screen: [1920, 1080]
      repeat: false
      direction: 'vertical'
      animation:
        duration: 700
        easing: 'swing'

    debug: true

    @_defaults = _defaults

    @settings = $.extend {}, _defaults, options
    @context = $ element

    if @debug
      console.log @elements


    # Get all child elements which have revelate
    # events attached through data attributes
    #
    @initialize = =>
      @init_animus()
      @init_window()
      @init_elements()

      @bind_resize()
      @bind_scroll()

      return


    # Initialize animus plugin for animation objects
    #
    @init_animus = =>
      override =
        duration: @settings.animation.duration
        easing: @settings.animation.easing

      @animus = new ($.animus)(override)

      return


    # Initialize window size with bleeding edge
    #
    @init_window = =>
      @edge = @settings.edge.slice(0)

      if @settings.direction is 'vertical'
        win_height = $(window).height()
        doc_height = $(document).height()

        @edge = @edge.map (edge) =>
          parseInt edge * (win_height / @settings.screen[1])
        @viewport = win_height - @edge[1]
        @endscroll = doc_height - win_height
      else
        win_width = $(window).width()
        doc_width = $(document).width()

        @edge = @edge.map (edge) =>
          parseInt edge * (win_width / @settings.screen[0])
        @viewport = win_width - @edge[1]
        @endscroll = doc_width - win_height

      if @debug
        console.log "Edge: ", @edge
        console.log "Viewport: ", @viewport
        console.log "End Scroll: ", @endscroll

      return



    # Initialize elements by caching data attributes
    #
    @init_elements = =>
      @elements = {}
      $(@settings.selector, @context).each (index, element) =>
        offset = @get_offset $ element
        data = @get_data $ element

        @elements[offset] = new Array() unless @elements[offset]?
        @elements[offset].push data

        $(element).attr 'data-revelate-index', "#{offset}-#{@elements[offset].length - 1}"
        $(element).velocity data.starting_animation.state, 1

      return


    # Get top or left offset of the element depending
    # on input settings
    #
    @get_offset = (element) ->
      offset = if @settings.direction is 'vertical'
        Math.round element.offset().top
      else
        Math.round element.offset().left

      offset = 0 if offset < 0

      return offset


    # Get animation data for the current element
    #
    @get_data = (element) ->
      data =
        done: false
        height: element.outerHeight(true)
        width: element.outerWidth(true)
        animation: {}

      # Get repeat data
      repeat = element.attr "data-revelate-repeat"
      data.repeat = if not repeat? then @settings.repeat else !!repeat

      # Get element delay
      start = element.attr "data-revelate-start"
      start = if not start? then @settings.delay else parseInt start

      # Create Stacks for ordering animations
      time_stack = []
      animation_stack = {}

      # Get initial state animation
      initial = element.attr "data-revelate"
      initial = element.attr "data-revelate-initial" unless initial?

      # Add initial animation to the stacks
      animation_stack[start] = initial
      time_stack.push start

      # Get in animation
      initial_animation_override = if element.attr('data-revelate-in')?
        @animus.get element.attr('data-revelate-in')
      else
        false

      # Get animation timeline
      timeline = element.data()
      for key, value of timeline
        if (atMatch = key.match(/revelateAt([0-9]*)/)) isnt null
          time = parseInt atMatch[1], 10

          # Add time to time stack
          animation_stack[time] = value
          time_stack.push time

      # Set animation timeline
      #
      # The time stack is needed to maintain the order of
      # the object animations since JSON objects aren't ordered
      time_stack.sort()

      # Last animation from time stack
      last_animation_time = time_stack[0]

      for key of time_stack
        data.animation[time_stack[key]] = @animus.get animation_stack[time_stack[key]]
        last_animation_time = time_stack[key] if time_stack[key] > last_animation_time

      # Set reset state by getting all the animation variables
      # and setting them to the default values
      if $.type(data.animation[start].state) isnt 'string'
        data.animation[start].state = @animus.reset data.animation[start].state, data, true
        data.starting_animation = data.animation[start]
        data.animation[start].state = @animus.forcefeed data.animation[start].state, initial_animation_override

      # Get loop data
      data.loop = if element.attr("data-revelate-loop")?
        last_animation_time + data.animation[last_animation_time].duration + 1
      else
        false

      return data


    # Bind functionality to the window resize event
    #
    @bind_resize = =>
      resize_timeout = null
      $(window).resize =>
        clearTimeout resize_timeout
        resize_timeout = setTimeout =>
          @init_window()
          @elements = @restructure()

          scroll = @window.scrollTop()
          @check scroll
        ,500

      return


    # Responsively restructure elements based on current offset
    #
    @restructure = =>
      new_elements = {}
      $(@settings.selector, @context).each (index, element) =>
        id = $(element).attr "data-revelate-index"
        [old_offset, index] = id.split "-"
        index = parseInt index

        offset = this.get_offset $ element

        new_elements[offset] = new Array() unless new_elements[offset]?
        new_elements[offset].push @elements[old_offset][index]

        current = new_elements[offset].length - 1
        new_elements[offset][current].width = $(element).outerWidth true
        new_elements[offset][current].height = $(element).outerHeight true

        $(element).attr "data-revelate-index", "#{offset}-#{new_elements[offset].length - 1}"

      if @debug
        console.log "Restructured: ", @elements

      return new_elements


    # Bind functionality to the window scroll event
    #
    @bind_scroll = =>
      @window = $(window)
      @window.scroll =>
        scroll = @window.scrollTop()
        @check scroll

      @window.trigger 'scroll'


    # Check if elements in view and animate them accordingly
    #
    @check = (scroll) ->
      for offset, group of @elements
        # Inside viewport
        for index, data of group

          if @in_viewport offset, data.height, scroll
            if data.done is off
              id = offset + '-' + index
              element = $('[data-revelate-index="' + id + '"]')
              @animate element, data

              if @debug
                console.log "Animate: [#{scroll}, #{offset}]"

          else
            if data.repeat is on and data.done is on
              id = offset + '-' + index
              element = $('[data-revelate-index="' + id + '"]')
              @reset element, data

      return


    # Check if element offset group is in view
    #
    @in_viewport = (offset, height, scroll) ->
      top = parseInt offset
      bottom = top + height

      [min, max] = if scroll is 0
        [0, scroll + @viewport]
      else if scroll is @endscroll
        [scroll + @edge[0], scroll + @viewport + @edge[1]]
      else
        [scroll + @edge[0], scroll + @viewport]

      return (top >= min and bottom <= max) or (top < min and min < bottom < max) or (min < top < max  and bottom > max) or (top < min and bottom > max)


    # Animate the element based on animation objects
    # and check for repeaters
    #
    @animate = (element, data) ->
      states = ->
        $.each data.animation, (key, animation) ->
          animation.timeline = setTimeout ->
            element.velocity animation.state,
              easing: animation.easing
              duration: animation.duration
              visibility: 'visible'
            return
          ,key

      data.done = true

      states()
      if data.loop
        data.interval = setInterval states, data.loop

      return


    # Reset animation if out of viewport and everything is finished.
    #
    @reset = (element, data) ->
      data.done = false

      if data.loop
        clearInterval data.interval

      for key, animation of data.animation
        clearTimeout animation.timeline

      element.velocity data.starting_animation.state,
        duration: data.starting_animation.duration
        visibility: 'hidden'

      return

    @initialize()



  # Lightweight plugin wrapper that prevents multiple instantiations.
  #
  $.fn.revelate = (opts) ->
    @each (index, element) ->
      unless $.data element, "revelate"
        $.data element, "revelate", new $.revelate element, opts

) window.jQuery, window, document
