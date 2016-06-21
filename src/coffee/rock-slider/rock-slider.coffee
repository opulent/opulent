###

                           dP
                           88
88d888b. .d8888b. .d8888b. 88  .dP
88'  `88 88'  `88 88'  `"" 88888"
88       88.  .88 88.  ... 88  `8b.
dP       `88888P' `88888P' dP   `YP
oooooooooooooooooooooooooooooooooooo

@plugin    jQuery
@license   CodeCanyon Standard / Extended
@author    Alex Grozav
@company   Pixevil
@website   http://pixevil.com
@email     alex@grozav.com
@guide
  Running rock-slider
    $('.rock-slider').rockSlider
      width: 1280
      height: 720
      layout: 'layout_name'

  Using methods
    $('.rock-slider').data('rock-slider').method_name()

  Adding events
    $('.rock-slider').on 'event_name', ->
###

(($, window, document) ->
  "use strict"

  # @RockSlider
  $.rockSlider = (element, options) ->

    # Default attribute values
    _defaults =
      width: 1280 # Slide canvas width
      height: 720 # Slide canvas height
      animation:
        in: "opacity 0" # Slide initial animation state
        out: "fade out" # Slide default out animation
        easing: "swing" # Default animation easing
        duration: 500 # Default animation duration

      delay: 4000 # Slide delay / display time

      overlap: 1 # Overlap previous out and current in animations (value >= 0)
                 # where 0 means overlap and 1 means wait for transition to finish

      layout: "default" # RockSlider layout
      layout_settings: {} # Layout initialization settings

      layer_index: 99 # Starting z-index for layers

      autoplay: true # Autoplay feature
      pause_on_hover: false # Pause autoplay on hover
      loop: true # Start from first slide after reaching last

      preload: 1 # Number of slides to be preloaded

      content_scaling: false # Scale content based on parent width
      content_scaling_factor: # Scale multiplication coefficient
        xs: 1
        sm: 1
        md: 1
        lg: 1
        xlg: 1
      content_width: null # Set content reference width. Default: canvas width

      content_parallax: true # Fade content on scroll
      content_parallax_data:
        mode: 'from-middle'
        transform:
          translateY: 0.6 # Scroll fade translate speed coefficient
          opacity: 0.4 # Scroll fade fade speed coefficient
        transform_style:
          opacity: 'default' # from-middle, to-middle, default

      grid:           # Split rock-slider background into tiles
        rows: 1       # Number of rows to split the background into
        columns: 1    # Number of columns to split the background into
        stagger: 100  # Animation delay in between tiles

      canvas_parallax: true # Parallax scroll coefficient
      canvas_parallax_data:
        transform:
          translateY: 0.2
      canvas_parallax_layers: true # Parallax layers as well

      touch: true # Touch controls
      keyboard: true # Slide next / prev with keyboard arrows
      mousewheel: false # Enable Slide on Scroll
      prevent_scrolling: true # Prevent page scrolling if mousewheel enabled

      loader: true # Add a loader if it doesn't exist in the markup

      retina: true # Check for retina images

      scroller: false # Enable Scroller Item
      scroller_markup: "<span class=\"rock-scroller-1\"></span>" # Markup for scroller item (1 or 2)
      scroller_position: "center" # Scroller position: left, center, right

      progress: true # Add progress bar
      progress_position: "bottom" # Progress bar position top / bottom
      progress_class: "rock-progress-light" # Additional thumbnail classes

      thumbnails: false # Add thumbnails
      thumbnails_visible: # Maximum number of thumbnails on page
        xs: 3
        sm: 4
        md: 5
        lg: 6
        xlg: 8
      thumbnails_position: "after" # Thumbnails position before or after
      thumbnails_orientation: "horizontal" # Thumbnails scroll orientation
      thumbnails_class: "" # Additional thumbnail classes

      controls: true # Add next / prev buttons
      controls_thumbnail: true # Add thumbnail to controls
      controls_html:
        prev: "&lt;"
        next: "&gt;"
      controls_class: "rock-controls-alternate" # Additional control classes

      pagination: false # Add pagination
      pagination_position: "inside" # Pagination position outside / inside
      pagination_class: "rock-pagination-light" # Additional pagination classes

      prevent_dragging: true # Prevent image dragging

      retina: true # Allow and look for retina images

      screen_size: # Refers to the current screen size
        xs: 0
        sm: 768
        md: 992
        lg: 1200
        xlg: 1840

      selector: # Element selectors
        slide: ".rock-slide" # Should not be changed unless absolutely necessary
        content: ".rock-content"
        background: ".rock-background"
        video_background: ".rock-video-background"
        video: ".rock-video"
        video_cover: ".rock-video-cover"
        layer: ".rock-layer"
        object: ".rock-object"
        next: ".rock-next"
        prev: ".rock-prev"
        outer: ".rock-outer"
        inner: ".rock-inner"

    @debug = false

    # Set @options
    @_defaults = _defaults
    @settings = $.extend {}, _defaults, options
    @settings.content_scaling_factor = $.extend {}, @_defaults.content_scaling_factor, @settings.content_scaling_factor

    # Set current @element
    @context = $ element

    # Animation States
    @animation = {}

    # Slider
    @element = $ element
    @parent = @element.parent()
    @current = -1

    # Get slider ID
    @id = if @element.attr('id')?
      @element.attr 'id'
    else
      'rock-' + Math.floor((Math.random() * 1000) + 1)

    # Window
    @window = $ window

    # Cache
    @cache = {}

    # Video Players
    @youtube_player = {}
    @vimeo_player = {}

    # Timer
    # Used in slide to set timeout to next slide
    @timer = {}
    @timer.timeout = null
    @timer.start = 0
    @timer.remaining = 0

    # Sets the @default variables and animations
    #
    @initialize = =>
      # Check for retina images if applicable
      @check_retina if @settings.retina

      # @Loader
      @add_loader() if @settings.loader

      # Animation States
      @init_animus()

      # @Settings
      @set_data_settings()

      # Add RockSlider Classes
      @add_classes()

      # Wrap Objects
      @wrap_objects()

      # Set inner
      @inner = $ @settings.selector.slide, @element

      # Set outer
      @outer = $ @settings.selector.outer, @element

      # Set Slides
      @slides = $ @settings.selector.slide, @element
      @slides_length = @slides.length

      # Set Active Slide
      @active = @slides.eq(0)

      # Set Size Setup
      @window_width = @window.width()
      @window_height = @window.height()

      # Visible @Size
      @visible_width = @window_width
      @visible_height = @window_height

      # @Parent Size
      @parent_width = @parent.width()
      @parent_height = @parent.height()

      # Entire Element Width
      @element_width = @parent_width
      @element_height = @element_width / @settings.width * @settings.height

      # Get current responsive context
      @set_responsive_context()

      # Setup Layers
      @setup_layers()

      # Setup Videos
      @setup_videos()

      # Bind Window Resize
      @bind_resize()

      # Prevent Image Dragging
      @prevent_dragging()  if @settings.prevent_dragging is true

      # Perform Initial Load
      @load =>
        # Enable features
        @enable_pause_on_hover()  if @settings.pause_on_hover is true
        @enable_touch()  if @settings.touch is true
        @enable_mousewheel()  if @settings.mousewheel is true
        @enable_keyboard()  if @settings.keyboard is true

        # Scaling value is required for some layouts to set content in the right
        # position before sliding starts
        @scale_content()

        # Layout setup
        @setup()

        # Add feature elements
        @add_progress_bar()  if @settings.progress is true
        @add_thumbnails()  if @settings.thumbnails is true
        @add_scroller()  if @settings.scroller is true
        @add_pagination()  if @settings.pagination is true
        @add_controls()  if @settings.controls is true

        # Setup layout and content
        @setup_scaling() if @settings.content_scaling

        # Split into grid
        @setup_grid()

        # Bind Window Scroll
        @bind_scroll()

        # Refresh sizes after intermediary computations are done
        @refresh()

        # Enable scrolling events
        @enable_content_parallax() if @settings.content_parallax
        @enable_canvas_parallax()

        # Hide the loader element
        @hide_loader()

        # Start the slider after loader is hidden
        setTimeout (=>
          @slide 0
        ), 500

        # Trigger on load event
        @element.trigger "rock-slider.load"

        return

      if @debug
        console.log @cache

      return

    # Load function to imagesLoaded images and cache slide animations
    #
    @load = (callback) ->
      i = 0

      # Do not try to preload more than the maximum number of slides
      @settings.preload = @slides_length if @settings.preload < @slides_length

      # Preload images from all the slides
      @slides.each (index, el) =>
        $slide = $(el)

        # Preload Image
        $slide.imagesLoaded().always =>
          $background = $(@settings.selector.background, $slide)
          $layers = $(@settings.selector.layer, $slide)
          objects = $(@settings.selector.object, $slide)

          # Cache initialization
          @cache[index] = {}
          @cache[index].layer = {}
          @cache[index].object = {}

          # Cache background by setting a 0 index, used for easier animation
          # method in layout
          @cache[index].background =
            0: @get_data($slide, $background, 'background', @settings.delay)

          # Layer animation values based on the background transitions
          layer_delay = @cache[index].background[0].delay - (@cache[index].background[0].animation[0].duration / 2)
          layer_start = @cache[index].background[0].animation[@cache[index].background[0].start].duration

          # Cache layers by determining whether they are images or object layers
          $layers.each (layer_index, layer) =>
            $layer = $(layer)

            image = null
            if $layer.is('img')
              image = $(layer)

            @cache[index].layer[layer_index] = @get_data($layer, image, 'layer', layer_delay, layer_start)
            return

          # Cache objects
          objects.each (object_index, object) =>
            object = $(object)
            @cache[index].object[object_index] = @get_data(object, null, 'object', layer_delay, layer_start)
            return

          # Cache Thumbnail
          thumbnail = $slide.attr('data-rock-thumbnail')
          if thumbnail
            @cache[index].thumbnail = thumbnail
          else
            @cache[index].thumbnail = $background.attr('src')

          # If all slides are loaded, call the actual setup function
          i++ if index < @settings.preload
          if i == @settings.preload
            @element.addClass 'rock-loaded'
            callback.call()

          return
        return
      return

    # Get element animation data based on its type
    #
    # @param object [Object] Current data gathering target
    # @param image [Object] Image target from which we gather layer sizes
    # @param type [String] Target type identifier
    # @param delay [Fixnum] Element default on screen display time
    # @param default_start [Fixnum] Element animation default start time
    #
    @get_data = (object, image, type, default_delay, default_start) ->
      string = ''

      time_stack = []
      animation_stack = {}

      i = 0

      # Set Element
      data = {}
      data.type = type
      data.animation = {}

      # Get Base Image Size
      if image != null and image.get(0)
        data.width = image.get(0).naturalWidth
        if !data.width?
          data.width = image.get(0).width
          if !data.width?
            data.width = image.width()
            if !data.width?
              data.width = @settings.width

        data.height = image.get(0).naturalHeight
        if !data.height?
          data.height = image.get(0).height
          if !data.height?
            data.height = image.height()
            if !data.height?
              data.height = @settings.height
      else
        data.width = 'auto'
        data.height = 'auto'

      # Get Layer Settings
      if type is 'layer'
        data.position = {}

        if object.attr('data-rock-top')?
          data.position.top = parseFloat(object.attr('data-rock-top'))
        else if object.attr('data-rock-bottom')?
          data.position.bottom = parseFloat(object.attr('data-rock-bottom'))
        else
          data.position.top = 0

        if object.attr('data-rock-left')?
          data.position.left = parseFloat(object.attr('data-rock-left'))
        else if object.attr('data-rock-right')?
          data.position.right = parseFloat(object.attr('data-rock-right'))
        else
          data.position.left = 0

        if object.attr('data-rock-width')?
          data.width = parseFloat(object.attr('data-rock-width'))
        if object.attr('data-rock-height')?
          data.height = parseFloat(object.attr('data-rock-height'))

      # Gather canvas parallax data
      canvas_parallax_data = object.attr('data-rock-parallax')
      data.canvas_parallax_data = {}
      if canvas_parallax_data?
        if canvas_parallax_data is 'false'
          data.canvas_parallax = false
        else
          data.canvas_parallax = true
          data.canvas_parallax_data.transform = {}
          data.canvas_parallax_data.transform.translateY = parseFloat canvas_parallax_data
      else
        data.canvas_parallax = @settings.canvas_parallax
        data.canvas_parallax_data = @settings.canvas_parallax_data if @settings.canvas_parallax

      # Starting time for layer animation
      start = if object.attr('data-rock-start')?
        parseInt(object.attr('data-rock-start'), 10)
      else
        if type == 'background' then 0 else default_start

      data.start = start

      # Get Initial State
      initial_state = object.attr('data-rock')
      initial_state = object.attr('data-rock-initial') unless initial_state?

      if initial_state?
        starting_animation = initial_state
      else if type == 'background'
        starting_animation = @settings.animation.in
      else
        starting_animation = ''

      # This sets the initial state of our animated object
      # The entering animation will be set as css and will
      # transition to the default state
      animation_stack[start] = starting_animation
      time_stack[i++] = start

      # Set animation in override to set a different beginning state
      # other than the default one
      initial_animation_override = if object.attr('data-rock-in')?
        @animus.get object.attr('data-rock-in')
      else
        false

      # Get Animation Timeline
      timeline = object.data()
      $.each timeline, (key, value) ->
        time = undefined
        # Check if data key matches animation
        if (time = key.match(/rockAt([0-9]+)/)) != null
          at_time = parseInt(time[1], 10)

          # Set value animation at time
          animation_stack[at_time] = value

          # Add time to time stack
          time_stack[i++] = at_time

        return

      # Set ending time as default delay or when last animation ends
      last_time = 0

      # The time stack is needed to maintain the order of
      # the object animations since JSON objects aren't ordered
      time_stack.sort()
      $.each time_stack, (key, value) =>
        data.animation[time_stack[key]] = @animus.get animation_stack[time_stack[key]]
        last_time = value if value > last_time
        return

      # Set grid initial status as disabled for now, might be possible to add
      # layers in the future
      data.grid =
        enabled: false

      # For backgrounds, we allow splitting images into tiles using set rows and
      # columns.
      if type is 'background'
        rows = object.attr('data-rock-grid-rows')
        data.grid.rows = if rows?
          parseInt rows, 10
        else
          @settings.grid.rows

        columns = object.attr('data-rock-grid-columns')
        data.grid.columns = if columns?
          parseInt columns, 10
        else
          @settings.grid.columns

        stagger = object.attr('data-rock-grid-stagger')
        data.grid.stagger = if stagger?
          parseInt stagger, 10
        else
          @settings.grid.stagger


        if data.grid.columns > 1 or data.grid.rows > 1
          data.grid.enabled = true
          object.addClass 'rock-grid-slide'

      # Get display time
      delay = object.attr('data-rock-delay')
      if delay?
        data.delay = parseInt(delay, 10) + parseInt(data.animation[start].duration, 10)
      else if @settings.autoplay is false
        data.delay = 99999
      else
        data.delay = parseInt(default_delay, 10) + parseInt(data.animation[start].duration, 10)

      # Get Exit Animation
      out_animation = object.attr('data-rock-out')
      out_animation = if out_animation?
        out_animation
      else
        if type == 'background'
          @settings.animation.out
        else
          ''

      # Set ending animation unless we have a null string
      if out_animation != ''
        end_time = if type == 'background'
          if data.delay > last_time + data.animation[last_time].duration
            data.delay
          else
            last_time + data.animation[last_time].duration
        else
          delay

        data.animation[end_time] = @animus.get out_animation

      # Set reset state by getting all the animation variables
      # and setting them to the default values
      if $.type(data.animation[start].state) isnt 'string'
        # Fade elements in, as they are faded out by default
        data.animation[start].state.opacity = 0 unless 'opacity' of data.animation[start].state

        # Get animation with resets, meaning besides initial values, we pass through all other
        # data animations and set default values for them as well
        data.animation[start].state = @animus.reset data.animation[start].state, data, true

        # Set initial animation data
        data.default_state = @animus.reset initial_animation_override.state, data, true
        data.initial_state = data.animation[start].state

        # Set initial animation as a forcefed animation, meaning we use the
        # initial state as final state, and we override the default state, if applicable
        data.animation[start].state = @animus.forcefeed data.animation[start].state, initial_animation_override.state

      # Set looping timeout
      data.loop = if object.attr('data-rock-loop')?
        last_time + data.animation[last_time].duration + 1
      else
        false

      return data


    # Slide wrapper function for calling static slider method to move
    # the carousel to the next slide
    #
    @slide = (i) ->
      from = @current
      next = if i + 1 > @slides_length - 1 then 0 else i + 1
      prev = if i - 1 < 0 then @slides_length - 1 else i - 1

      # Index Logic
      if i == @current
        return
      if i > @slides_length - 1
        i = 0
      if i < 0
        i = @slides_length - 1

      # Set Active
      $('.previous', @element).removeClass 'previous'
      @slides.eq(prev).addClass 'previous'

      $('.active', @element).removeClass 'active'
      @active = @slides.eq(i)
      @active.addClass 'active'

      $('.next', @element).removeClass 'next'
      @slides.eq(next).addClass 'next'

      # Clear Timeouts
      if @current != -1
        @clear_timeouts @current
      @clear_timeouts i

      # Layout specific slide method
      @layout[@settings.layout].slide.call this, i, @current

      # RockSlider specific slide method
      @animate i, @current

      # Set Current
      @current = i

      # Go to the next slide after the slide specific delay
      if @settings.autoplay is true
        @timer.start = new Date
        @timer.remaining = @cache[i].background[0].delay
        clearTimeout @timer.clock
        @timer.clock = setTimeout((=>
          if @settings.loop isnt true and i + 1 == @slides_length - 1
            return
          @slide i + 1
          return
        ), @timer.remaining)

      # Animate Progress Bar
      if @settings.progress is true
        @progress.bar.velocity('stop').velocity({ width: '0%' }, 0).velocity { width: '100%' }, @timer.remaining

      # Set Control Thumbnails
      if @settings.controls is true and @settings.controls_thumbnail is true
        @prev_thumbnail.attr 'src', @cache[prev].thumbnail
        @next_thumbnail.attr 'src', @cache[next].thumbnail

      # Set Pagination Active
      if @settings.pagination
        @pagination.filter('.active').removeClass 'active'
        @pagination.eq(i).addClass 'active'

      # Set Thumbnails Active
      if @settings.thumbnails
        @thumbnails.elements.filter('.active').removeClass 'active'
        @thumbnails.elements.eq(i).addClass 'active'
        @scroll_to_thumbnail i

      # Handle Videos
      @handle_videos from, i
      @element.trigger 'rock-slider.change', [
        prev
        @current
        next
        @slides_length
        @active
      ]
      return

    # Apply animations for all slider elements. Run previous slide out animation
    # and set time required to crossfade slides
    #
    # @param i [Fixnum] Current slide index
    # @param prev [Fixnum] Previous slide index
    #
    @animate = (i, prev) =>
      # Set main active slide
      $active = @slides.eq(i)

      # Staggering timeout when using grid layouts
      prev_stagger = 0

      # Clear main animation timeout to prevent bad behaviour for unusual
      # request counts (click spamming)
      clearTimeout @animate_timeout

      # Run animateOut animation for previous slide
      if prev != -1 and @settings.layout_settings.animate_background isnt false
        $prev = @slides.eq(prev)
        $prev_layers = $ '.rock-layer-wrapper', $prev
        $prev_objects = $ @settings.selector.object, $prev
        previous_delay = @cache[prev].background[0].delay

        # Fade content out together with the slide for a smooth transition
        $(".rock-content-wrapper, #{@settings.selector.layer}", $prev).velocity
          opacity: 0
        , @cache[prev].background[0].animation[previous_delay].duration

        # Animate background out if we have an out animation set for the previous slide
        unless $.isEmptyObject @cache[prev].background[0].animation[previous_delay].state
          prev_target = $prev

          # Set animation options
          options =
            duration: @cache[prev].background[0].animation[previous_delay].duration
            easing: @cache[prev].background[0].animation[previous_delay].easing
            display: null
            complete: =>
              # When we're done with the previous slide, we stop all animations
              # to prevent lagging and other bad behaviour
              $prev.velocity('stop')
              $prev_layers.velocity('stop')
              $prev_objects.velocity('stop')
              #$('.rock-grid-cell', $prev).velocity('stop') if @cache[prev].background[0].grid.enabled
              return

          # When a grid is set, animate the grid elements of the previous slide
          if @cache[prev].background[0].grid.enabled
            options.stagger = @cache[prev].background[0].grid.stagger

            # Set cells as animation target when grid is enabled
            prev_target = $('.rock-grid-cell', $prev)

            # Fade the background out and fade the grid in, also reset
            # state for active grid
            $.Velocity.hook $('.rock-grid', $active), 'opacity', 1
            $.Velocity.hook $('.rock-grid-cell', $active), 'opacity', 0
            $.Velocity.hook $('.rock-grid', $prev), 'opacity', 1
            $('.rock-background-main', $prev).velocity opacity: 0, 20

            # When we have an UI animation, override display settings
            if $.type(@cache[prev].background[0].animation[previous_delay].state) is 'string'
              prev_stagger += $('.rock-grid-cell', $prev).length * @cache[prev].background[0].grid.stagger

          # After fading the grid in if it exists, animate the previous slide
          prev_target.velocity @cache[prev].background[0].animation[previous_delay].state, options

      # Add the staggering (if it exists) to the next animation timeout
      if prev is -1
        timeout = prev_stagger
      else
        if @cache[prev].background[0].animation[previous_delay]
          prev_animation_out = @cache[prev].background[0].animation[previous_delay].duration
        else
          prev_animation_out = 0

        timeout = prev_animation_out + prev_stagger

      # If we want the slides to play one after another, the overlap parameter
      # should be 1, otherwise 0. Everything in between will cause partial
      # overlapping
      timeout *=  @settings.overlap

      # Runs active slide animation timeline for background, layers and objects
      #
      # Set a timeout to overlap, depending on slider settings
      $.Velocity.hook $('.rock-background-main', $active), 'opacity', 0
      @animate_timeout = setTimeout =>
        $layers = $ '.rock-layer-wrapper', $active
        $objects = $ @settings.selector.object, $active

        # Fade content in, together with the slide for a smooth transition
        $(".rock-content-wrapper, #{@settings.selector.layer}", $active).velocity
          opacity: 1
        , @cache[i].background[0].animation[@cache[i].background[0].start].duration

        # Background animations
        if @settings.layout_settings.animate_background isnt false
          if @cache[i].background[0].grid.enabled
            @run_grid_animation i, $('.rock-grid-cell', $active), 'background', 0, false
          else
            @run_animation i, $active, 'background', 0, false

        # Layer animations
        $layers.each (layer_index, layer) =>
          @run_animation i, $(layer), 'layer', layer_index, false

        # Object animation
        $objects.each (object_index, object) =>
          @run_animation i, $(object), 'object', object_index, false

        return
      , timeout
      return

    # Grid animation wrapper to run a callback after grid animation ends
    #
    @run_grid_animation = (i, $element, context, context_index, in_loop)  =>
      $active = @slides.eq(i)
      @run_animation i, $element, context, context_index, in_loop, =>
        $.Velocity.hook $('.rock-background-main', $active), 'opacity', 1
        $('.rock-grid', $active).velocity opacity: 0, 20
        return
      return

    # Runs animation for current slide, generalized for background, layers and
    # objects use
    #
    # @param i [Fixnum] Index of current cached element
    # @param $element [Object] Element on which animation is applied
    # @param context [String] Current animation cache accessor
    # @param context_index [Fixnum] Current animation cache accessor index
    #
    @run_animation = (i, $element, context, context_index, in_loop, callback) =>
      # Set initial animation position for active slide
      current_delay = @cache[i].background[0].delay

      # Set initial state for element
      unless in_loop || !@cache[i][context][context_index].initial_state?
        $element.velocity @cache[i][context][context_index].initial_state,
          duration: 1

      # Run each background animation as long as the animation index isn't greater
      # than the slide's preview delay
      $.each @cache[i][context][context_index].animation, (index) =>
        if index >= current_delay or isNaN(index) or $.isEmptyObject(@cache[i][context][context_index].animation[index].state)
          return

        # Set timeout for each animation, with it's state
        @cache[i][context][context_index].animation[index].timeline = setTimeout((=>
          options =
            duration: @cache[i][context][context_index].animation[index].duration
            easing: @cache[i][context][context_index].animation[index].easing
            display: null

          if @cache[i][context][context_index].grid.enabled
            options.stagger = @cache[i][context][context_index].grid.stagger

            if callback? and parseInt(index) == @cache[i][context][context_index].start
              options.complete = callback

          # if @cache[i][context][context_index].grid.enabled
          #   console.log @cache[i][context][context_index].animation[index]

          $element.velocity @cache[i][context][context_index].animation[index].state, options
          return
        ), index)

        return

      if @cache[i][context][context_index].loop
        @cache[i][context][context_index].loop_timeout = setTimeout =>
          @run_animation i, $element, context, context_index, true
        , @cache[i][context][context_index].loop

      return


    # Setup wrapper function for calling static @method
    #
    @setup = =>
      # Create Layout
      @layout = {}
      $.each $.rockSlider.layouts, (index, value) =>
        @layout[index] = new value
        return

      if @layout[@settings.layout]
        @layout[@settings.layout].init.call this
      else
        tries = 0
        max_tries = 6
        try_interval = setInterval =>
          $.each $.rockSlider.layouts, (index, value) =>
            return if index of @layout
            @layout[index] = new value
            return

          # Init Layout
          if @layout[@settings.layout]
            @layout[@settings.layout].init.call this
            clearInterval try_interval
            return

          if tries == max_tries
            clearInterval try_interval
            console.error "RockSlider couldn't find any \"#{@settings.layout}\" layout."

          tries += 1
        , 500


      if @layout.length == 0
        console.error "RockSlider couldn't find any valid layouts."

      return

    # Setup layout wrapper
    #
    @setup_layout = =>
      # Setup Layout
      @layout[@settings.layout].setup.call this

      return

    # Resize layout wrapper
    #
    @resize_layout = =>
      # Setup Layout
      if @layout[@settings.layout].resize
        @layout[@settings.layout].resize.call this

      return

    # Set default animation parameters for RockSlider animation objects
    # and create animus model
    #
    @init_animus = =>
      override =
        duration: @settings.animation.duration
        easing: @settings.animation.easing

      # Animus
      @animus = new $.animus(override)
      return

    # Adds a CSS3 Animated loader to the slider
    #
    @add_loader = =>
      if $(".rock-loader-wrapper", @element).length is 0
        html = ""
        html += '<div class="rock-loader-wrapper">'
        html += '<div class="rock-loader">'
        html += '<div class="rock-loader-inner">'
        html += '<div class="rock-loader-tile"></div>'
        html += '<div class="rock-loader-tile"></div>'
        html += '<div class="rock-loader-tile"></div>'
        html += '<div class="rock-loader-tile"></div>'
        html += '<div class="rock-loader-tile"></div>'
        html += '</div>'
        html += '</div>'
        html += '<div class="rock-loader-text">'
        html += '<h5 class="rock-loader-title font-normal">'
        html += 'SLIDEA'
        html += '</h5>'
        html += '<h6 class="rock-loader-subtitle font-thin">'
        html += 'A Smarter Slider Plugin'
        html += '</h6>'
        html += '</div>'
        html += '</div>'
        @element.prepend html
      return

    # Hides CSS3 Animated loader to the slider
    #
    @hide_loader = =>
      $(".rock-loader-wrapper", @element).velocity
        scale: 1.5
        opacity: 0
      ,
        display: "none"
      ,
        duration: 600
      return

    # Check if @has data-rock-settings which override default init settings
    #
    @set_data_settings = =>
      @settings.width = @element.attr("data-rock-width")  if @element.attr("data-rock-width")?
      @settings.height = @element.attr("data-rock-height")  if @element.attr("data-rock-height")?
      @settings.animation.initial = @element.attr("data-rock-initial")  if @element.attr("data-rock-animation-initial")?
      @settings.animation.out = @element.attr("data-rock-out")  if @element.attr("data-rock-animation-out")?
      @settings.animation.duration = @element.attr("data-rock-duration")  if @element.attr("data-rock-duration")?
      @settings.animation.easing = @element.attr("data-rock-easing")  if @element.attr("data-rock-easing")?
      @settings.delay = @element.attr("data-rock-delay")  if @element.attr("data-rock-delay")?
      @settings.layout = @element.attr("data-rock-layout")  if @element.attr("data-rock-layout")?
      return

    # Add the actual classes to the RockSlider selector classes
    #
    @add_classes = =>
      # $(@settings.selector.slide, @element).addClass "rock-slide"
      # $(@settings.selector.content, @element).addClass "rock-content"
      # $(@settings.selector.background, @element).addClass "rock-background"
      # $(@settings.selector.video_background, @element).addClass "rock-video-background"
      # $(@settings.selector.video, @element).addClass "rock-video"
      # $(@settings.selector.video_cover, @element).addClass "rock-video-cover"
      # $(@settings.selector.layer, @element).addClass "rock-layer"
      # $(@settings.selector.object, @element).addClass "rock-object"
      # $(@settings.selector.next, @element).addClass "rock-next"
      # $(@settings.selector.prev, @element).addClass "rock-prev"
      # $(@settings.selector.pagination, @element).addClass "rock-pagination"

      return

    # Wrap the slides with a .rock-inner class for layout flexibility
    #
    @wrap_objects = =>
      $(@settings.selector.slide, @element).each (i, slide) =>
        $(@settings.selector.background + ', ' + @settings.selector.layer, $(slide)).wrapAll "<div class=\"rock-canvas\"></div>"
      .wrapAll "<div class=\"rock-outer\"><div class=\"rock-inner\"></div></div>"
      $(@settings.selector.content, @element).wrap '<div class="rock-content-wrapper"></div>'
      $(@settings.selector.background, @element).wrap '<div class="rock-background-wrapper"></div>'
      $(@settings.selector.layer, @element).wrap '<div class="rock-layer-wrapper"></div>'
      return

    # Set the z-index of each of the @layers
    #
    @setup_layers = =>
      @slides.each (si, slide) =>
        layers = $(".rock-layer-wrapper", $(slide))
        layer_count = layers.length
        layers.each (li, layer) =>
          $(layer).css "z-index", @settings.layer_index + layer_count - li
      return

    # Setup video events at slide start for HTML5, YouTube and Vimeo videos
    #
    @setup_videos = =>
      delay = 500
      interval = undefined
      i = 0
      tries = 10

      # Handle background videos
      $('.rock-video-background').each (index, background) ->
        unless $(background).hasClass 'rock-object'
          $(background).addClass 'rock-object'
        return

      $("video.rock-video", @element).attr "data-rock-video-type", "html5"
      $("iframe[data-rock-src*=\"youtube.com\"].rock-video", @element).attr "data-rock-video-type", "youtube"
      $("iframe[data-rock-src*=\"vimeo.com\"].rock-video", @element).attr "data-rock-video-type", "vimeo"

      $(@settings.selector.video, @element).each (i, el) =>
        $video = $(el)
        volume = $video.attr("data-rock-volume")
        controls = ($video.attr("data-rock-controls") is "true")
        pause_slider= ($video.attr("data-rock-pause-slider") is "true")
        random_id = "rock-video-" + Math.floor((Math.random() * 1000) + 1)
        volume = (if isNaN(volume) then 0 else volume)
        $video.attr "id", random_id  unless $video.attr("id")?
        id = $video.attr("id")
        src = $video.attr("data-rock-src")

        # HTML5
        if $video.attr("data-rock-video-type") is "html5"
          $video.get(0).volume = volume
          $video.attr "controls", "controls"  if controls is true
          if @settings.autoplay is true and pause_slider is true
            $video.on "play", =>
              @pause_timer()
              return

            $video.on "pause ended", =>
              @unpause_timer()
              return


        # YouTube
        if $video.attr("data-rock-video-type") is "youtube"
          video_id = undefined
          separator = undefined

          if src.indexOf("enablejsapi=1") is -1
            if src.indexOf("?") is -1
              $video.attr "src", src + "?enablejsapi=1"
            else
              $video.attr "src", src + "&enablejsapi=1"
            src = $video.attr("src")

          if src.indexOf("playerapiid=") is -1
            if src.indexOf("?") is -1
              $video.attr "src", src + "?playerapiid=" + id
            else
              $video.attr "src", src + "&playerapiid=" + id
            src = $video.attr("src")

          unless src.indexOf("embed") is "-1"
            video_id = src.split("/")
            video_id = video_id[video_id.length - 1]
            separator = video_id.indexOf("?")
            video_id = video_id.substring(0, separator)  unless separator is -1
          else
            video_id = src.split("v=")[1]
            separator = video_id.indexOf("&")
            video_id = video_id.substring(0, separator)  unless separator is -1

          $video.load =>
            @youtube_player[id] = new YT.Player(id,
              height: "720"
              width: "1280"
              video_id: video_id
              events:
                onStateChange: (e) =>
                  @pause_timer()  if e.data is 1
                  @unpause_timer()  if e.data is 2 or e.data is 0
            )

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
            , delay)
            return

        # Vimeo
        if $video.attr("data-rock-video-type") is "vimeo"
          if src.indexOf("api=1") is -1
            if src.indexOf("?") is -1
              $video.attr "src", src + "?api=1"
            else
              $video.attr "src", src + "&api=1"
            src = $video.attr("src")
          if src.indexOf("player_id=") is -1
            if src.indexOf("?") is -1
              $video.attr "src", src + "?player_id=" + id
            else
              $video.attr "src", src + "&player_id=" + id
            src = $video.attr("src")
          $video.load =>
            @vimeo_player[id] = $f(id)
            @vimeo_player[id].addEvent "ready", =>
              $video.attr "data-rock-ready", "true"
              @vimeo_player[id].api "setVolume", volume
              if @settings.autoplay is true and pause_slider is true
                @vimeo_player[id].addEvent "play", @pause_timer
                @vimeo_player[id].addEvent "pause", @unpause_timer
                @vimeo_player[id].addEvent "finish", @unpause_timer
            return
        return

      $(@settings.selector.video_cover, @element).each (i, el) =>
        $cover = $(el)
        $parent = $cover.parent()
        $video = $(@settings.selector.video, $parent)
        type = $video.attr("data-rock-video-type")
        id = $video.attr("id")

        switch type
          when "html5"
            $cover.on "click", =>
              $video.get(0).play()
              $cover.velocity "fadeOut"
              return

          when "youtube"
            $cover.on "click", =>
              @youtube_player[id].playVideo()
              $cover.velocity "fadeOut"
              return

          when "vimeo"
            $cover.on "click", =>
              @vimeo_player[id].api "play"
              $cover.velocity "fadeOut"
              return

        return
      return

    # Handle autoplay timeouts using a timeout timeline
    #
    video_timeline = {}

    # Handle video events at slide start for HTML5, YouTube and Vimeo videos
    #
    @handle_videos = (previous, current) ->
      $previous = @slides.eq(previous)
      $current = @slides.eq(current)

      # Pause or stop videos from previous slide
      if previous != -1
        $(@settings.selector.video, $previous).each =>
          $video = $(` this `)
          id = $video.attr('id')
          reset = $video.attr('data-rock-reset') == 'true'
          clearTimeout video_timeline[id]

          # HTML5
          if $video.attr('data-rock-video-type') == 'html5'
            $video.get(0).pause()
            if reset
              setTimeout (=>
                $video.get(0).current_time = 0
                return
              ), @cache[current].background[0].animation[0].duration

          # Youtube
          if $video.attr('data-rock-video-type') == 'youtube'
            @youtube_player[id].pauseVideo()
            if reset
              setTimeout (=>
                @youtube_player[id].stopVideo()
                return
              ), @cache[current].background[0].animation[0].duration

          # Vimeo
          if $video.attr('data-rock-video-type') == 'vimeo'
            @vimeo_player[id].api 'pause'
            if reset
              setTimeout (=>
                @vimeo_player[id].api 'unload'
                return
              ), @cache[current].background[0].animation[0].duration
          return

      # Play videos from current slide
      $(@settings.selector.video, $current).each =>
        $video = $(` this `)
        id = $video.attr('id')
        delay = 500
        interval = undefined
        i = 0
        tries = 10
        autoplay = $video.attr('data-rock-autoplay') == 'true'
        autoplay_time = if $video.attr('data-rock-autoplay-time')? then parseInt($video.attr('data-rock-autoplay-time'), 10) else 100
        pause_slider = $video.attr('data-rock-pause-slider') == 'true'

        # HTML5
        if $video.attr('data-rock-video-type') == 'html5'
          if autoplay == true
            video_timeline[id] = setTimeout((->
              $video.get(0).play()
              return
            ), autoplay_time)

        # Youtube
        if $video.attr('data-rock-video-type') == 'youtube'
          if autoplay == true
            i = 0
            interval = setInterval((=>
              i++
              if i == tries
                clearInterval interval
              else if !defined(@youtube_player[id]) or typeof @youtube_player[id].playVideo != 'function'
                return
              else
                clearInterval interval
              video_timeline[id] = setTimeout((=>
                @youtube_player[id].playVideo()
                return
              ), autoplay_time)
              return
            ), delay)

        # Vimeo
        if $video.attr('data-rock-video-type') == 'vimeo'
          if autoplay == true
            i = 0
            interval = setInterval((=>
              i++
              if i == tries
                clearInterval interval
              else if !$video.attr('data-rock-ready')? or typeof @vimeo_player[id].api != 'function'
                return
              else
                clearInterval interval
              video_timeline[id] = setTimeout((->
                Froogaloop(id).api 'play'
                return
              ), autoplay_time)
              return
            ), delay)
        return
      return

    # Recompute every relevant size
    #
    @refresh = =>
      @window_width = @window.width()
      @window_height = @window.height()

      @parent_width = @parent.width()
      @parent_height = @parent.height()

      @element_width = @parent_width
      @element_height = @element_width / @settings.width * @settings.height

      @setup_content()
      @setup_layout()

      @resize_grid()
      @resize_thumbnails()  if @settings.thumbnails is true

      return


    # Binds the slider window resize event to cache current window
    # width and height and to set the layout up
    #
    @bind_resize = =>
      @window.resize =>
        @refresh()
        @resize_layout()
        @set_responsive_context()

        @element.trigger 'rock-slider.resize', [
          @window_width
          @window_height
          @current_responsive_size
        ]

        return
      # , 300, false
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

    # Bind the window scroll event to fade content on scroll down
    #
    @bind_scroll = =>
      @window.on 'scroll', =>
        return
      return

    # Scroll fade a the rock-slider content if the current scroll is greater than
    # the slider's top position
    #
    # @param position [Fixnum] Current scrolling position
    #
    @enable_content_parallax = ->
      $(@settings.selector.content, @element).each (index, element) =>
        settings = $.extend {}, @settings.content_parallax_data,
          reset: true
          source: @outer

        $(element).visuallax settings
        return

      return

    # Parallax images
    #
    # @param position [Fixnum] Current scrolling position
    #
    @enable_canvas_parallax = ->
      @slides.each (index, slide) =>
        settings = $.extend {}, @settings.canvas_parallax_data,
          parent: @outer
          source: @inner
          reset: true

        if @cache[index].background[0].canvas_parallax
          $('.rock-background-wrapper', $(slide)).visuallax settings

          if @settings.canvas_parallax_layers
            $(@settings.selector.layer, $(slide)).each (li, layer) =>
              if @cache[index].layer[li].canvas_parallax
                settings = $.extend {}, @cache[index].layer[li].canvas_parallax_data,
                  parent: @outer
                  source: @inner
                  reset: true

                $(layer).visuallax settings
              return
        return
      return


    # Add progress bar to the @container
    #
    @add_progress_bar = =>
      position = (if @settings.progress_position is "top" then "rock-progress-top" else "rock-progress-bottom")

      html = ""
      html += "<div class=\"rock-progress " + position + " " + @settings.progress_class + "\">"
      html += "<div class=\"rock-progress-bar\">"
      html += "</div>"
      html += "</div>"
      @element.prepend html

      @progress = {}
      @progress.element = $(".rock-progress", @element)
      @progress.bar = $(".rock-progress-bar", @element)

      return

    # Prevent image dragging
    #
    @prevent_dragging = =>
      $("img", @element).on "dragstart", (event) =>
        event.preventDefault()
        return
      return

    # Add pagination bullets to the slider
    #
    @add_pagination = =>
      position = (if @settings.pagination_position is "inside" then "rock-pagination-inside" else "rock-pagination-outside")

      # Don't add pagination if we have only one slide
      return if @slides_length == 1

      html = ""
      html += "<div class=\"rock-pagination " + position + " " + @settings.pagination_class + "\">"
      i = 0
      while i < @slides_length
        html += "<div class=\"rock-pagination-bullet\"></div>"
        i++
      html += "</div>"
      $pagination = $(html)

      if @settings.pagination_position is "inside"
        @element.prepend $pagination
      else
        @element.after $pagination

      @pagination = $(".rock-pagination-bullet", $pagination)
      @pagination.each (i, el) =>
        $bullet = $(el)
        $bullet.on "click", =>
          @pagination.filter(".active").removeClass "active"
          $bullet.addClass "active"
          @slide i
          return
        return
      return

    # Add scroller item to @and bind click action
    #
    @add_scroller = =>
      scroller = "<div class=\"rock-scroller-wrapper rock-scroller-" + @settings.scroller_position + "\">"
      scroller += @settings.scroller_markup
      scroller += "</div>"

      @scroller = $ scroller
      @element.prepend @scroller

      @scroller.on "click", =>
        $("html").velocity "scroll",
          offset: @element.height()
          mobileHA: true
          duration: 1000
        return
      return


    # Add thumbnails underneath our slider
    #
    @add_thumbnails = =>
      thumbs_count = @settings.thumbnails_visible[@current_responsive_size]

      if @settings.thumbnails_orientation == 'horizontal'
        individual_size = @element_width / thumbs_count
        inner_size = individual_size * @slides_length
        css_param = 'width'
      else if @settings.thumbnails_orientation == 'vertical'
        individual_size = @element_height / thumbs_count
        inner_size = individual_size * @slides_length
        css_param = 'height'

      html = ""
      html += "<div class=\"rock-thumbnails #{@settings.thumbnails_class} #{@settings.thumbnails_orientation}\">"
      html += "<div class=\"rock-thumbnails-inner\" style=\"#{css_param}: " + inner_size + "px;\">"
      $.each @cache, (index, item) ->
        html += "<div class=\"rock-thumbnail-wrapper\" style=\"#{css_param}: " + individual_size + "px;\">"
        html += "<img class=\"rock-thumbnail\" src=\"" + item.thumbnail + "\" alt=\"Slide " + index + "\" />"
        html += "</div>"
      html += "</div>"
      html += "</div>"

      @thumbnails = {}
      @thumbnails.wrapper = $(html)

      if @settings.thumbnails_position is "before"
        @element.before @thumbnails.wrapper
      else if @settings.thumbnails_position is "after"
        @element.after @thumbnails.wrapper
      else
        @settings.thumbnails_position.append @thumbnails.wrapper

      @thumbnails.inner = $(".rock-thumbnails-inner", @thumbnails.wrapper)
      @thumbnails.elements = $(".rock-thumbnail-wrapper", @thumbnails.wrapper)

      if @settings.thumbnails_orientation == 'horizontal'
        @thumbnails.size = @thumbnails.inner.width()
        @thumbnails.parent_size = @thumbnails.wrapper.width()
      else if @settings.thumbnails_orientation == 'vertical'
        @thumbnails.size = @thumbnails.inner.height()
        @thumbnails.parent_size = @thumbnails.wrapper.height()

      @thumbnails.starting_position = 0
      @thumbnails.starting_direction = undefined

      @thumbnails.elements.each (i, el) =>
        $thumbnail = $(el)
        $thumbnail.on "click", =>
          @thumbnails.elements.filter(".active").removeClass "active"
          $thumbnail.addClass "active"
          @slide i
          return
        return

      $("img", @thumbnails.elements.eq(0)).each (i, el) =>
        $(el).load =>
          height = $(el).height()

          if @settings.thumbnails_orientation == 'horizontal'
            @thumbnails.inner.height height
          else if @settings.thumbnails_orientation == 'vertical'
            @thumbnails.inner.height height * @slides_length
          return
        return

      $("img", @thumbnails.elements).on "dragstart", (event) ->
        event.preventDefault()
        return

      if @settings.touch is true
        touch_thumbnails = new Hammer @thumbnails.wrapper[0]

        if @settings.thumbnails_orientation == 'horizontal'
          pan_events = 'panleft panright'
          touch_thumbnails.get('pan').set
            direction: Hammer.DIRECTION_HORIZONTAL
        else if @settings.thumbnails_orientation == 'vertical'
          pan_events = 'panup pandown'
          touch_thumbnails.get('pan').set
            direction: Hammer.DIRECTION_VERTICAL


        # Bind touch event to the thumbnails
        touch_thumbnails.on "panstart pancancel panend #{pan_events}", (event) =>
          if @settings.thumbnails_orientation == 'horizontal'
            distance = event.deltaX
          else if @settings.thumbnails_orientation == 'vertical'
            distance = event.deltaY

          # When moving, sync the slider with the mouse movement
          if @settings.thumbnails_orientation == 'horizontal' and event.type is 'panleft' or event.type is 'panright'
            if event.direction is Hammer.DIRECTION_LEFT or event.direction is Hammer.DIRECTION_RIGHT
              transform = "translate3d(#{@thumbnails.starting_position + distance}px, 0, 0)"
              @thumbnails.inner.css
                'transform': transform
                '-o-transform': transform
                '-ms-transform': transform
                '-moz-transform': transform
                '-webkit-transform': transform

          else if @settings.thumbnails_orientation == 'vertical' and event.type is 'panup' or event.type is 'pandown'
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
            @thumbnails.inner.addClass 'rock-dragging'

            @thumbnails.starting_direction = event.direction

          # When letting go, check if we have enough distance to go to the next slide
          # otherwise return to the initial position
          else if event.type is 'panend'
            @thumbnails.inner.removeClass 'rock-dragging'

            # Set new starting position
            @thumbnails.starting_position += distance

            # Don't go past last thumbnail
            if @thumbnails.starting_position < - @thumbnails.size + @thumbnails.parent_size
              @scroll_to_thumbnail @slides_length - 1

            # Don't go past first thumbnail
            else if @thumbnails.starting_position > 0
              @scroll_to_thumbnail 0

            # Snap to current thumbnail
            else
              snap_distance = 0
              @thumbnails.elements.each (index, item) =>
                if @thumbnails.starting_position > -snap_distance
                  @scroll_to_thumbnail index
                  return false

                if @settings.thumbnails_orientation == 'horizontal'
                  snap_distance += $(item).width()
                else if @settings.thumbnails_orientation == 'vertical'
                  snap_distance += $(item).height()

                return

          event.preventDefault()
          return

      return

    # Scroll to the i-th thumbnail in the collection
    #
    @scroll_to_thumbnail = (i) =>
      i = 0 if i < 0

      # Calculate distance to thumbnail
      # thumbnails may have variable sizes
      distance = 0
      @thumbnails.elements.each (index, item) =>
        return false if index == i
        if @settings.thumbnails_orientation == 'horizontal'
          distance += $(item).width()
        else if @settings.thumbnails_orientation == 'vertical'
          distance += $(item).height()
        return

      # If distance required is greater than the last set of thumbnails we can
      # see, then don't go past them
      if @thumbnails.size - distance < @thumbnails.parent_size
        distance = @thumbnails.size - @thumbnails.parent_size

      # Set the new starting position
      @thumbnails.starting_position = -distance

      # Animate the thumbnails to the new position
      if @settings.thumbnails_orientation == 'horizontal'
        transform = 'translate3d(' + (-distance) + 'px, 0, 0)'
      else if @settings.thumbnails_orientation == 'vertical'
        transform = 'translate3d(0, ' + (-distance) + 'px, 0)'

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

    # Resize thumbnails when window resize happens
    #
    @resize_thumbnails = =>
      thumbs_count = @settings.thumbnails_visible[@current_responsive_size]

      if @settings.thumbnails_orientation == 'horizontal'
        individual_size = @element_width / thumbs_count
        inner_size = individual_size * @slides_length
        css_param = 'width'
      else if @settings.thumbnails_orientation == 'vertical'
        individual_size = @thumbnails.wrapper.parent().height() / thumbs_count
        inner_size = individual_size * @slides_length
        css_param = 'height'

      @thumbnails.inner[css_param] inner_size
      @thumbnails.elements[css_param] individual_size

      if @settings.thumbnails_orientation == 'horizontal'
        @thumbnails.size = inner_size
      else if @settings.thumbnails_orientation == 'vertical'
        @thumbnails.size = inner_size

      @thumbnails.parent_size = @thumbnails.wrapper[css_param]()

      size = undefined
      if @settings.thumbnails_orientation == 'horizontal'
        size = $("img", @thumbnails.elements.eq(0)).height()
        @thumbnails.inner.height size
      else if @settings.thumbnails_orientation == 'vertical'
        size = $("img", @thumbnails.elements.eq(0)).width()
        @thumbnails.inner.width size

      @scroll_to_thumbnail @current

      return



    # Get swipe direction and go to next or previous slide
    #
    @enable_touch = =>
      @touch_object = new Hammer @element[0]
      @touch_object.get('pan').set
        direction: Hammer.DIRECTION_HORIZONTAL
      @touch_object.on 'panleft panright', (event) =>
        if event.eventType is Hammer.INPUT_START
          @element.addClass 'rock-dragging'

        else if event.eventType is Hammer.INPUT_END or event.eventType is Hammer.INPUT_CANCEL
          @element.removeClass 'rock-dragging'

          if event.direction is Hammer.DIRECTION_LEFT
            @slide @current + 1
          else if event.direction is Hammer.DIRECTION_RIGHT
            @slide @current - 1

        return
      return

    # Get scrolling direction and go to next or previous slide
    #
    @enable_mousewheel = =>
      @element.mousewheel (event) =>
        if event.deltaY == -1
          @slide @current + 1
        if event.deltaY == 1
          @slide @current - 1
        if @settings.prevent_scrolling is true
          event.preventDefault()
        return
      return

    # Get arrow input and slide to next or previous slide
    #
    @enable_keyboard = =>
      $(document).keydown (e) =>
        switch e.which
          when 37 then @slide @current - 1
          when 39 then @slide @current + 1
          else return
      return

    # Enable next and previous buttons and bind the controls
    #
    @add_controls = =>
      prev_html = ''
      prev_html += '<a href="javascript:void(0);" class="rock-control rock-prev ' + @settings.controls_class + '">'
      prev_html += '<div class="rock-control-inner">'
      if @settings.controls_thumbnail is true
        prev_html += '<div class="rock-control-thumbnail">'
        prev_html += '<img src="" alt="Previous Slide" class="rock-control-image"/>'
        prev_html += '</div>'
      prev_html += '<div class="rock-control-text">'
      prev_html += @settings.controls_html.prev
      prev_html += '</div>'
      prev_html += '</div>'
      prev_html += '</a>'

      next_html = ''
      next_html += '<a href="javascript:void(0);" class="rock-control rock-next ' + @settings.controls_class + '">'
      next_html += '<div class="rock-control-inner">'
      if @settings.controls_thumbnail is true
        next_html += '<div class="rock-control-thumbnail">'
        next_html += '<img src="" alt="Next Slide" class="rock-control-image"/>'
        next_html += '</div>'
      next_html += '<div class="rock-control-text">'
      next_html += @settings.controls_html.next
      next_html += '</div>'
      next_html += '</div>'
      next_html += '</a>'

      @outer.append prev_html + next_html
      @prev_button = $(@settings.selector.prev, @element)
      @next_button = $(@settings.selector.next, @element)

      if @settings.controls_thumbnail is true
        @prev_thumbnail = $('.rock-control-image', @prev_button)
        @next_thumbnail = $('.rock-control-image', @next_button)

      @prev_button.on 'click', =>
        @slide @current - 1
        return
      @next_button.on 'click', =>
        @slide @current + 1
        return

      return

    # Get swipe direction and go to next or previous slide
    #
    @enable_pause_on_hover = =>
      @element.on 'mouseenter', =>
        @pause_timer()
        return
      @element.on 'mouseleave', =>
        @unpause_timer()
        return
      return

    # Pause autoplay when mouse is over @element
    #
    @pause_timer = =>
      current_time = new Date
      @timer.remaining = @timer.remaining - (current_time - (@timer.start))
      clearTimeout @timer.clock
      if @settings.progress is true
        @progress.bar.velocity 'stop'
      @element.trigger 'rock-slider.pause'
      return

    # Unpause timer when hovering over @element
    #
    @unpause_timer = =>
      next_slide = if @current == -1 then 1 else @current + 1

      @timer.start = new Date

      clearTimeout @timer.clock

      @timer.clock = setTimeout((=>
        @slide next_slide
        return
      ), @timer.remaining)

      if @settings.progress is true
        @progress.bar.velocity { width: '100%' }, @timer.remaining

      @element.trigger 'rock-slider.resume'

      return

    # Prevent image dragging on computers
    #
    @prevent_dragging = =>
      $('img', @element).on 'dragstart', (event) ->
        event.preventDefault()
        return
      return

    # Add progress bar to the @container
    #
    @add_progress_bar = =>
      position = if @settings.progress_position == 'top' then 'rock-progress-top' else 'rock-progress-bottom'
      html = ''
      html += '<div class="rock-progress ' + position + ' ' + @settings.progress_class + '">'
      html += '<div class="rock-progress-bar">'
      html += '</div>'
      html += '</div>'
      @element.prepend html
      @progress = {}
      @progress.element = $('.rock-progress', @element)
      @progress.bar = $('.rock-progress-bar', @element)
      return

    # Set the content width and responsive font size utility
    #
    @setup_content = =>
      $content = $('.rock-content-wrapper', @element)

      # Responsive Content scaling
      if @settings.content_scaling is true
        @scale_content()
      else
        $content.width @outer.width()
        $content.height @outer.height()
      return


    # Set content width and height if content scaling is enabled
    #
    @setup_scaling = =>
      $content = $('.rock-content-wrapper', @element)

      # Set reference content width, in relation with slide canvas default width
      @scaling_reference = if @settings.content_width
        @settings.content_width
      else
        @settings.width

      $content.width @scaling_reference
      $content.height @settings.width / @scaling_reference * @settings.height

      return

    # Calculate scaling values based on input settings
    #
    @scale_content = =>
      $content = $('.rock-content-wrapper', @element)
      origin_x = '0%'
      origin_y = '0%'

      # Calculate scaling width based on scaling factor
      calculated_width = @outer.width()

      # Calculate scaling value based on current width
      @scaling_value = calculated_width / @scaling_reference * @settings.content_scaling_factor[@current_responsive_size]

      # Center content based on current resize value 8
      if @settings.content_scaling_factor[@current_responsive_size] == 1
        $.Velocity.hook $content, 'translateX', "0px"
      else
        $.Velocity.hook $content, 'translateX', "#{calculated_width * (1 - @settings.content_scaling_factor[@current_responsive_size]) / 2}px"

      # $.Velocity.hook $content, 'translateX', '-50%'
      $.Velocity.hook $content, 'translateZ', '0px'
      $.Velocity.hook $content, 'transformOriginX', origin_x
      $.Velocity.hook $content, 'transformOriginY', origin_y
      $.Velocity.hook $content, 'scaleX', @scaling_value
      $.Velocity.hook $content, 'scaleY', @scaling_value

      return

    # Setup the rock-slider grid system
    #
    @setup_grid = =>
      grid_is_set = false

      $('.rock-background-wrapper', @element).each (index, element) =>
        grid = @cache[index].background[0].grid

        if grid.enabled
          grid_is_set = true

          cell_count = grid.columns * grid.rows

          $(element).append $('<div class="rock-grid"></div>')

          background = $(@settings.selector.background, $(element))
          for i in [0..cell_count - 1]
            background.clone().appendTo($('.rock-grid', $(element))).wrap '<div class="rock-grid-cell"></div>'

          background.addClass 'rock-background-main'
        return

      # Set correct sizes for the grid system
      @resize_grid()

      @setup_layout() if grid_is_set

      return

    # If a grid is set, split the background images
    #
    @resize_grid = =>
      $('.rock-background-wrapper', @element).each (index, element) =>
        grid = @cache[index].background[0].grid

        if grid.enabled
          main_width = @inner.width()
          main_height = @inner.height()

          cell_width = main_width / grid.columns
          cell_height = main_height / grid.rows

          # Set cell width and height, percentage based
          cells = $('.rock-grid-cell', $(element))
          cells.width(cell_width).height cell_height

          # Translate each grid and column background in order to maintain
          # a perfect ratio and resemble the original image
          for i in [0..grid.rows]
            for j in [0..grid.columns]
              this_cell = cells.eq(i * grid.columns + j)
              $.Velocity.hook this_cell, 'translateX', "#{cell_width * j}px"
              $.Velocity.hook this_cell, 'translateY', "#{cell_height * i}px"

              this_background = $(@settings.selector.background, this_cell)
              this_background.width(main_width).height main_height
              $.Velocity.hook this_background, 'translateX', "-#{cell_width * j}px"
              $.Velocity.hook this_background, 'translateY', "-#{cell_height * i}px"
        return
      return

    # Clears all the set timeouts for the chosen slide in order to stop all
    # programmed animations.
    #
    # @version2.0 Loop timeouts must also be cleared after every slide
    #
    @clear_timeouts = (i) ->
      $.each @cache[i].background[0].animation, (index) =>
        clearTimeout @cache[i].background[0].animation[index].timeline
        return
      if 'loop_timeout' of @cache[i].background[0]
        clearTimeout @cache[i].background[0].loop_timeout

      $.each @cache[i].layer, (index) =>
        $.each @cache[i].layer[index].animation, (animateIndex) =>
          clearTimeout @cache[i].layer[index].animation[animateIndex].timeline
          return
        if 'loop_timeout' of @cache[i].layer[index]
          clearTimeout @cache[i].layer[index].loop_timeout
        return

      $.each @cache[i].object, (index) =>
        $.each @cache[i].object[index].animation, (animateIndex) =>
          clearTimeout @cache[i].object[index].animation[animateIndex].timeline
          return
        if 'loop_timeout' of @cache[i].object[index]
          clearTimeout @cache[i].object[index].loop_timeout
        return

      return


    @debounce = (func, wait, immediate) ->
      timeout = undefined
      ->
        context = this
        args = arguments

        later = ->
          timeout = null
          if !immediate
            func.apply context, args
          return

        callNow = immediate and !timeout
        clearTimeout timeout
        timeout = setTimeout(later, wait)
        if callNow
          func.apply context, args
        return

    # Check if current screen is retina. If yes, replace images with their larger
    # versions using the data-rock-at2x attribute
    #
    @check_retina = =>
      retina = false
      root = (exports? ? window : exports)
      mediaQuery = '(-webkit-min-device-pixel-ratio: 1.5), (min--moz-device-pixel-ratio: 1.5), (-o-min-device-pixel-ratio: 3/2), (min-resolution: 1.5dppx)';

      if root.devicePixelRatio > 1
          retina = true

      if root.matchMedia && root.matchMedia(mediaQuery).matches
          retina = true

      if retina
        $('img[data-at2x]', $slide).each (index, element) =>
          img = $(element)
          newsrc = img.attr 'data-rock-at2x'

          if newsrc?
            src = img.attr('src')

            if newsrc == "true"
                src = src.replace /(\.[\w\?=]+)$/, "@2x$1"
            else
                src = newsrc

            img.attr 'src', src
      return


    # Helper methods to slide to next slide or to the previous one
    #
    @next = =>
      @slide @current + 1
      return

    @prev = =>
      @slide @current - 1
      return

    # Helper methods to pause or unpause the slider
    #
    @pause = =>
      @pause_timer()
      return

    @resume = =>
      @unpause_timer()
      return

    @initialize()


  # Keeps all RockSlider layout definitions to be instantiated when needed
  $.rockSlider.layouts = {}

  # Add a new RockSlider layout at runtime
  $.rockSlider.add_layout = (name, layout) ->
    $.rockSlider.layouts[name] = layout

  # Lightweight plugin wrapper that prevents multiple instantiations.
  #
  $.fn.rockSlider = (opts) ->
    @each (index, element) ->
      unless $.data element, "rock-slider"
        $.data element, "rock-slider", new $.rockSlider element, opts

) window.jQuery, window, document


# A factory that uses AMD, CommonJS or window globals to
# create the jQuery plugin.
# do (plugin = rock-slider, window) ->
#   hasDefine  = typeof define is "function" and define.amd?
#   hasExports = typeof module isnt "undefined" and module.exports?
#
#   # AMD.
#   if hasDefine
#     define ["jquery"], plugin
#
#   # NodeJS/CommonJS.
#   else if hasExports
#     module.exports = plugin require "jquery"
#
#   # Window globals.
#   else
#     plugin window.jQuery or window.$
