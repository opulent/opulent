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
@guide
  Running slidea
    $('.slidea').slidea
      width: 1280
      height: 720
      layout: 'layoutName'

  Using methods
    $('.slidea').data('slidea').method_name()

  Adding events
    $('.slidea').on 'eventName', ->
###

(($, window, document) ->
  "use strict"

  # @Slidea
  $.slidea = (element, options) ->
    ###
    Default attribute values
    ###
    _defaults =
      animation:
        initial: "opacity 0" # Slide initial animation state
        out: "opacity 0" # Slide default out animation
        easing: "easeOutQuad" # Default animation easing
        duration: 500 # Default animation duration

      duration: 4000 # Slide duration (display time) in milliseconds

      overlap: 1 # Overlap previous out and current in animations (value >= 0)
                 # where 0 means overlap and 1 means wait for transition to finish

      layout: "default" # Slidea layout

      layerIndex: 99 # Starting z-index for layers

      autoplay: false # Autoplay feature
      loop: true # Start from first slide after reaching last

      preload: 'fast' # Preload mode: 'fast' or 'all'

      animate: 'TweenLite'

      # content_parallax:
      #   enabled: true # Fade content on scroll
      #   data:
      #     mode: 'from-middle'
      #     transform:
      #       translateY: 0.6 # Scroll fade translate speed coefficient
      #       opacity: 0.4 # Scroll fade fade speed coefficient
      #     transform_style:
      #       opacity: 'default' # from-middle, to-middle, default

      grid:           # Split slidea background into tiles
        rows: 1       # Number of rows to split the background into
        columns: 1    # Number of columns to split the background into
        stagger: 0.1  # Animation delay in between tiles

      # canvas_parallax:
      #   enabled: true # Parallax scroll coefficient
      #   data:
      #     transform:
      #       translateY: 0.2
      #   layers: true # Parallax layers as well

      screen: # Refers to the current screen size
        xs: 0
        sm: 768
        md: 992
        lg: 1200
        xlg: 1560

      selector: # Element selectors
        slide: ".slidea-slide" # Should not be changed unless absolutely necessary
        content: ".slidea-content"
        contentWrapper: ".slidea-content-wrapper"
        contentContainer: ".slidea-content-container"
        canvas: ".slidea-canvas"
        background: ".slidea-background"
        backgroundWrapper: ".slidea-background-wrapper"
        videoBackground: ".slidea-video-background"
        video: ".slidea-video"
        videoCover: ".slidea-video-cover"
        layer: ".slidea-layer"
        layerWrapper: ".slidea-layer-wrapper"
        object: ".slidea-object, .s-obj"
        objectWrapper: ".slidea-object-wrapper"
        next: ".slidea-next"
        prev: ".slidea-prev"
        inner: ".slidea-inner"
        wrapper: ".slidea-wrapper"

    # Debugging flag
    @debug = true

    # Set @options
    @_defaults = _defaults
    @settings = $.extend true, {}, _defaults, options

    # Slider
    @element = $ element
    @parent = @element.parent()

    ###
    Current active slide. We're using -1 to say that there is no current
    slide yet, or that the slider hasn't started yet.
    ###
    @current = -1

    # Video Players
    @youtube_player = {}
    @vimeo_player = {}

    # Window selector
    @window = $(window)

    # Slides loaded
    @loaded = false

    ###
    Timer
    Used in slide to set timeout to next slide
    ###
    @timer = {}
    @timer.timeout = null
    @timer.start = 0
    @timer.remaining = 0

    # Get or set slider ID
    if @element.attr('id')?
      @id = @element.attr 'id'
    else
      @id = @get_random_id 'rock'
      @element.attr 'id', @id

    @initialize = =>
      @log "Initializing Slidea.."
      @log @settings

      # Register modules and layouts
      @register()

      # Add Slidea Classes
      @add_classes()

      # Wrap Objects
      @wrap_objects()

      # Set wrapper
      @wrapper = $ @settings.selector.wrapper, @element

      # Set inner
      @inner = $ @settings.selector.inner, @element

      # Set Slides
      @slides = $ @settings.selector.slide, @element

      # Set total slide count
      @slides_length = @slides.length

      # Initialize slides animation data
      @data = {}
      @slides.each (index) => @data[index] = {}

      # Set the indexes of the relevant first slides
      if @settings.first_slide?
        @first_slide = @settings.first_slide
      else
        @first_slide = 0
      @set_adjacent_slides @first_slide

      # Set Active Slide
      @active = @slides.eq @first_slide

      # Set Animation Platform
      @animate = window[@settings.animate]
      @log "Animating using the #{@settings.animate} platform."

      # Initialize layouts
      @eval.layouts 'initialize'

      # Initialize modules
      @eval.modules 'initialize'

      # Animation States
      @init_animus()

      # @Settings
      @set_data_settings()

      # Set relevant object sizes
      @set_parent_sizes()

      # Get current responsive context
      @set_responsive_context()

      # Setup Layers
      @set_layers_zindex()

      # Bind Window Resize
      @bind_resize()

      # Bind Window Blur and focus
      @bind_focus()

      # Add links
      @bind_inner_links()

      # Perform Initial Load
      @load =>

        # Initial slider sizing
        @resize()

        @log "Animation data parsed."
        @log @data

        # Start the slider after loader is hidden
        setTimeout (=>
          @slide @first_slide
        ), 500

        @log "Load callback has finished."
        return
      return

    ###
    Slide wrapper function for calling static slider method to move
    the carousel to the next slide
    ###
    @slide = (to) ->
      from = @current

      # Index Logic
      if to == @current
        return
      if to > @slides_length - 1
        to = 0
      if to < 0
        to = @slides_length - 1

      @log "---------------------------------------"
      @log "Slide transition from #{from} to #{to}."

      # Set adjacent next and prev slides
      @set_adjacent_slides to

      # Set Previous
      $('.previous', @element).removeClass 'previous'
      @slides.eq(@prev).addClass 'previous'

      # Set Active
      $('.active', @element).removeClass 'active'
      @active = @slides.eq(to)
      @active.addClass 'active'

      # Set next
      $('.next', @element).removeClass 'next'
      @slides.eq(@next).addClass 'next'

      # Clear Timeouts
      if from != -1
        setTimeout =>
          @clear_timeouts from
          return
        , @data[from].background[0].animation[@data[from].background[0].duration].duration * 1000
      @clear_timeouts to

      # Call layouts slide call
      @eval.layouts 'slide', [from, to]

      # Call modules slide call
      @eval.modules 'slide', [from, to]

      # Slidea specific slide method
      @transition from, to

      # Set Current
      @current = to
      @log "Indexes are current: #{@current}, previous: #{@prev}, next: #{@next}."

      # Go to the next slide after the slide specific duration
      if @settings.autoplay is true
        @timer.start = new Date
        @timer.remaining = @data[to].background[0].duration
        clearTimeout @timer.clock
        @timer.clock = setTimeout((=>
          if @settings.loop isnt true and to + 1 == @slides_length - 1
            @log "Looping is off. Autoplay stops here."
            return
          @slide to + 1
          return
        ), @timer.remaining)
        @log "Autoplay timer has been reset."

      # Trigger transition event
      @element.trigger 'slidea.transition', [
        from
        to
        @prev
        @next
        @slides_length
        @active
      ]
      return

    ###
    Set the index of the next and previous slides
    ###
    @set_adjacent_slides = (to) =>
      @next = if to + 1 > @slides_length - 1 then 0 else to + 1
      @prev = if to - 1 < 0 then @slides_length - 1 else to - 1
      return

    ###
    Apply animations for all slider elements. Run previous slide out animation
    and set time required to crossfade slides

    @param i [Fixnum] Current slide index
    @param prev [Fixnum] Previous slide index
    ###
    @transition = (from, to) =>
      # Call layouts transition call
      @eval.layouts 'transition', [from, to]

      # Call modules transition call
      @eval.modules 'transition', [from, to]

      # Staggering timeout when using grid layouts
      from_stagger = 0

      # Transition timeout, used for overlapping transitions
      timeout = 0

      # Clear main animation timeout to prevent bad behaviour for unusual
      # request counts (click spamming)
      clearTimeout @animate_timeout

      # Run animateOut animation for previous slide
      if from != -1
        @transition_run from, 'out'

        from_slide_duration = @data[from].background[0].duration
        if @data[from].background[0].animation[from_slide_duration]
          timeout += @data[from].background[0].animation[from_slide_duration].duration * 1000

      # If we want the slides to play one after another, the overlap parameter
      # should be 1, otherwise 0. Everything in between will cause partial
      # overlapping
      timeout *= @settings.overlap
      timeout = 0 if timeout < 0 # For non autoplay sliders

      # Runs active slide animation timeline for background, layers and objects
      #
      # Set a timeout to overlap, depending on slider settings
      @animate_timeout = setTimeout =>
        @transition_run to, 'in'
        return
      , timeout

      # Call layouts slide call
      @eval.layouts 'after_transition', [from, to]

      # Call modules slide call
      @eval.modules 'after_transition', [from, to]

      return

    ###
    Run initial transition animations for the slide
    ###
    @transition_run = (index, mode) =>
      # Set current slide variables
      slide = @slides.eq(index)
      canvas = $ @settings.selector.canvas, slide
      layers = $ @settings.selector.layerWrapper, slide
      objects = $ @settings.selector.object, slide

      # Background animations
      if @settings.layoutSettings.animate_background isnt false
        @log "Running animations for background."

        @transition_animate index, slide, 'background', 0, mode, false

      # Layer animations
      layers.each (layer_index, layer) =>
        @log "Running animations for layer #{layer_index}."

        @transition_animate index, $(layer), 'layer', layer_index, mode, false
        return

      # Object animation
      objects.each (object_index, object) =>
        @log "Running animations for object #{object_index}."

        @transition_animate index, $(object), 'object', object_index, mode, false
        return
      return


    ###
    Validate transition index for given animation element
    ###
    @transition_validate = (i, index, element, context, context_index, mode) =>
      slide_duration = @data[i].background[0].duration
      index = parseInt index

      switch mode
        when 'in'
          return index != 'initial' &&                                                    # Not initial state
            index != -1 &&                                                                # Not -1 state
            !isNaN(index) &&                                                              # Not NaN
            !$.isEmptyObject(@data[i][context][context_index].animation[index].state) &&  # Not empty object
            (slide_duration == -1 or slide_duration != -1 and index < slide_duration)     # Not > slide_duration
        when 'out'
          return index != 'initial' &&                                                    # Not initial state
            (index == -1 or slide_duration != -1 and index >= slide_duration) &&        # Is -1 state or > slide_duration
            !$.isEmptyObject(@data[i][context][context_index].animation[index].state)     # Not empty object
        else
          return true

    ###
    Runs animation for current slide, generalized for background, layers and
    objects

    @param i [Fixnum] Slide index
    @param $element [Object] Element on which animation is applied
    @param context [String] Current animation cache accessor
    @param context_index [Fixnum] Current animation cache accessor index
    ###
    @transition_animate = (i, element, context, context_index, mode, in_loop, callback) =>
      # Set initial animation position for active slide
      slide_duration = @data[i].background[0].duration

      # Set initial state for element
      unless mode == 'out' || in_loop || !@data[i][context][context_index].animation.initial?
        @animate.set element, @data[i][context][context_index].animation.initial.state

        if 'callback' of @data[i][context][context_index]
          @data[i][context][context_index].callback.call @, element, 'initial'


      # Run each background animation as long as the animation index isn't greater
      # than the slide's preview duration
      $.each @data[i][context][context_index].animation, (index, animation) =>
        if !@transition_validate(i, index, element, context, context_index, mode)
          return

        @log "Running #{mode} transition[#{index}] for #{context}[#{context_index}]."
        @log @data[i][context][context_index].animation[index]

        # Set animation timeout
        if mode == 'in'
          timeout = index
        else
          timeout = slide_duration - parseInt(index)

        # Set in loop timeout and stop if it's negative. Negative values mean
        # that the animation is outside the loop
        if in_loop
          timeout = timeout - @data[i][context][context_index].loop_diff
          return if timeout < 0

        # Set timeout for each animation, with it's state
        @data[i][context][context_index].animation[index].timeline = setTimeout =>
          if 'callback' of @data[i][context][context_index]
            @data[i][context][context_index].callback.call @, element, index

          if typeof @data[i][context][context_index].animation[index].state == 'string'
            @animate_preset element, @data[i][context][context_index].animation[index]
          else
            @animate.to element,
              @data[i][context][context_index].animation[index].duration,
              @data[i][context][context_index].animation[index].state
          return
        , timeout
        return

      # If we have a loop, calculate timeout to the next animation iteration and
      # restart animation with loop parameters
      if @data[i][context][context_index].loop
        if in_loop
          loop_timeout = @data[i][context][context_index].loop - @data[i][context][context_index].loop_diff
        else
          loop_timeout = @data[i][context][context_index].loop

        @data[i][context][context_index].loop_timeout = setTimeout =>
          @transition_animate i, element, context, context_index, mode, true
          return
        , loop_timeout

      return

    ###
    Grid animation wrapper to run a callback after grid animation ends
    ###
    @run_grid_transition = (to, $element, context, context_index, in_loop)  =>
      to_slide = @slides.eq(to)
      @run_transition i, $element, context, context_index, in_loop, =>
        $.Velocity.hook $('.slidea-background-main', to_slide), 'opacity', 1
        $('.slidea-grid', to_slide).velocity opacity: 0, 20
        return
      return


    ###
    Run animus animation preset
    ###
    @animate_preset = (element, data) =>
      @log "Animating preset #{data}."
      timeout = 0
      $.each $.animus.presets[data.state], (index, animation) =>
        duration = data.duration * animation[1]
        setTimeout =>
          @animate.to element,
            duration,
            $.animus.presets[data.state][index][0]
          return
        , timeout * 1000
        timeout += duration
        return
      return

    ###
    Registers modules and layouts which are loaded
    ###
    @register = =>
      # Create instances of registered layouts
      @layouts = {}
      $.each $.slidea.layouts, (index, value) =>
        @layouts[index] = new value

        # Add module default settings and override them with the
        # user preferred settings
        if @layouts[index].settings?
          if @settings.layoutSettings?
            @settings.layoutSettings = $.extend true, {}, @layouts[index].settings, @settings.layoutSettings
          else
            @settings.layoutSettings = @layouts[index].settings

        @log "Layout \"#{index}\" registered."
        return

      # Register modules
      @modules = {}
      $.each $.slidea.modules, (index, module) =>
        # Create module instance
        @modules[index] = new module

        # Add module default settings and override them with the
        # user preferred settings
        if @modules[index].settings?
          if @settings[index]?
            if typeof(@modules[index].settings) is 'object'
              @settings[index] = $.extend true, {}, @modules[index].settings, @settings[index]
          else
            @settings[index] = @modules[index].settings

        @log "Module \"#{index}\" registered."
        @log @modules[index]
        return

      @log "Settings changed after module registration."
      @log @settings
      return

    ###
    Method call wrapper for layout and modules
    ###
    @eval = {}

    ###
    Setup wrapper function for calling layout method
    ###
    @eval.layouts = (method, args) =>
      args = [] unless args?

      # Call layout method if it exists
      if @layouts[@settings.layout]
        if @layouts[@settings.layout][method]?
          @layouts[@settings.layout][method].apply this, args
      else
        @error "Couldn't find any valid layouts with the name \"#{@settings.layout}\"."
      return

    ###
    Setup wrapper function for calling modules method
    ###
    @eval.modules = (method, args) =>
      args = [] unless args?

      # Call module method if it exists
      $.each @modules, (name, module) =>
        if @settings[name]? and
           (@settings[name].enabled == true or @settings[name] == true) and
           @modules[name][method]?
          @modules[name][method].apply this, args
      return

    ###
    Get data such as height, width and animations for the slide with
    the current index
    ###
    @get_slide_data = (index) =>
      @data[index].background = {}
      @data[index].layer = {}
      @data[index].object = {}

      slide = @slides.eq(index)
      slide_background = $(@settings.selector.background, slide)
      slide_layers = $(@settings.selector.layer, slide)
      slide_objects = $(@settings.selector.object, slide)

      # Get background data
      slide_background.each (background_index, background) =>
        background = $(background)
        @data[index].background[background_index] = @get_data(
          index, 'background', background_index, slide, @check_image(background), @settings.duration
        )

        @log "Received data for slide #{index} -> background #{background_index}."
        @log @data[index].background[background_index]
        return

      if slide_background.length == 0
        @data[index].background[0] = @get_data(
          index, 'background', 0, slide, null, @settings.duration
        )

      # Layer animation values based on the background transitions
      default_duration = @data[index].background[0].duration
      # @deprecated 2.1
      # default_duration = @data[index].background[0].duration - (@data[index].background[0].animation[0].duration / 2)
      # @deprecated 2.0
      # default_start = @data[index].background[0].animation[@data[index].background[0].start].duration

      # Cache layers by determining whether they are images or object layers
      slide_layers.each (layer_index, layer) =>
        layer = $(layer)
        @data[index].layer[layer_index] = @get_data(
          index, 'layer',layer_index, layer, @check_image(layer), default_duration
        )

        @log "Received data for slide #{index} -> layer #{layer_index}."
        @log @data[index].layer[layer_index]
        return

      # Cache objects by determining whether they are images or object layers
      slide_objects.each (object_index, object) =>
        object = $(object)
        @data[index].object[object_index] = @get_data(
          index, 'object', object_index, object, @check_image(object), default_duration
        )

        @log "Received data for slide #{index} -> object #{object_index}."
        @log @data[index].object[object_index]
        return

      # Get module specific data
      @eval.modules 'get_slide_data', [
        index
        slide
        slide_background
        slide_layers
        slide_objects
      ]

      @log "Finished gathering data for all elements."
      return

    ###
    Get element animation data based on its type

    @param object [Object] Current data gathering target
    @param image [Object] Image target from which we gather layer sizes
    @param type [String] Target type identifier
    @param duration [Fixnum] Element default on screen display time
    ###
    @get_data = (index, context, context_index, object, image, default_duration) ->
      # String data to parse
      string = ''

      # JS Data to use for the object
      js_data = false

      # Get JS Settings object
      slide_id = @slides.eq(index).attr 'id'
      slide_classes = @slides.eq(index).attr 'class'


      if @settings.slide?
        slide_js_data = []

        # Get slide data by index
        if @settings.slide[index]?
          slide_js_data.push @settings.slide[index]

        # Get slide data by class
        if slide_classes?
          $.each slide_classes.split(' '), (index, slide_class) =>
            if @settings.slide['.' + slide_class]?
              slide_js_data.push @settings.slide['.' + slide_class]
            return

        # Get slide data by id
        if slide_id? and @settings.slide['#' + slide_id]?
          slide_js_data.push @settings.slide['#' + slide_id]

        # Get JS data for current object
        if slide_js_data.length > 0
          object_id = object.attr 'id'
          object_classes = object.attr 'class'

          # Gather
          identifiers = []
          identifiers.push context_index
          if object_classes?
            identifiers = identifiers.concat object_classes.split(' ').map (element) -> '.' + element
          if object_id?
            identifiers.push '#' + object_id

          $.each slide_js_data, (index, slide_js_data) =>
            if slide_js_data[context]?
              $.each identifiers, (index, identifier) =>
                if slide_js_data[context]? and slide_js_data[context][identifier]?
                  if js_data
                    js_data = $.extend js_data, slide_js_data[context][identifier]
                  else
                    js_data = $.extend {}, slide_js_data[context][identifier]
                return
            return

      # Handler stacks for animation timing
      time_stack = []
      current_time_stack = 0
      animation_stack = {}

      # Set Element
      data = {}
      data.type = context
      data.animation = {}

      # Get the sizes of the loaded image element
      if image != null
        image_size = @get_image_size image

        data.width = image_size.width
        data.height = image_size.height

      # Get data for the layer position and size
      if context is 'layer'
        data.position = {}

        if object.attr('data-slidea-width')?
          data.width = parseFloat(object.attr('data-slidea-width'))
        else if js_data and js_data.width?
          data.width = parseFloat @delete_property js_data, 'width'

        if object.attr('data-slidea-height')?
          data.height = parseFloat(object.attr('data-slidea-height'))
        else if js_data and js_data.height?
          data.height = parseFloat @delete_property js_data, 'height'

        # Get top or bottom offset
        if object.attr('data-slidea-top')?
          data.position.top = parseFloat(object.attr('data-slidea-top'))
        else if js_data and js_data.top?
          data.position.top = parseFloat @delete_property js_data, 'top'
        else if object.attr('data-slidea-bottom')?
          data.position.bottom = parseFloat(object.attr('data-slidea-bottom'))
        else if js_data and js_data.bottom?
          data.position.bottom = parseFloat @delete_property js_data, 'bottom'
        else
          data.position.top = 0

        # Get left or right offset
        if object.attr('data-slidea-left')?
          data.position.left = parseFloat(object.attr('data-slidea-left'))
        else if js_data and js_data.left?
          data.position.left = parseFloat @delete_property js_data, 'left'
        else if object.attr('data-slidea-right')?
          data.position.right = parseFloat(object.attr('data-slidea-right'))
        else if js_data and js_data.right?
          data.position.right = parseFloat @delete_property js_data, 'right'
        else
          data.position.left = 0

      # Starting time for layer animation
      if object.attr('data-slidea-start')?
        data.start = parseFloat(object.attr('data-slidea-start'), 10)
      else if js_data and js_data.start?
        data.start =  parseInt @delete_property js_data, 'start'
      else
        data.start =  0

      # Get Initial State
      initial_state = object.attr('data-slidea')
      initial_state = object.attr('data-slidea-initial') unless initial_state?
      initial_state = @delete_property js_data, 'initial' unless initial_state?

      if initial_state?
        starting_animation = initial_state
      else if context == 'background'
        starting_animation = @settings.animation.initial
      else
        starting_animation = ''

      ###
      This sets the initial state of our animated object
      The entering animation will be set as css and will
      transition to the default state
      ###
      animation_stack[data.start] = starting_animation
      time_stack[current_time_stack++] = data.start


      ###
      Set animation in override to set a different beginning state
      other than the default one
      ###
      if object.attr('data-slidea-in')?
        initial_animation_override = @animus.get object.attr('data-slidea-in')
      else if js_data and js_data.in?
        initial_animation_override = @animus.get @delete_property(js_data, 'in')
      else
        initial_animation_override = false

      # Get Animation Timeline
      timeline = object.data()
      $.each timeline, (key, value) ->
        time = undefined
        # Check if data key matches animation
        if (time = key.match(/slideaAt([0-9]+)/)) != null
          at_time = parseInt(time[1], 10)

          # Set value animation at time
          animation_stack[at_time] = value

          # Add time to time stack
          time_stack[current_time_stack++] = at_time
        return


      # Get animation data from JS
      $.each js_data, (index, value) =>
        return unless /[0-9]+/.test index

        animation_stack[index] = value
        time_stack[current_time_stack++] = index
        return

      # Set ending time as default duration or when last animation ends
      last_time = 0

      ###
      The time stack is needed to maintain the order of
      the object animations since JSON objects aren't ordered
      ###
      time_stack.sort()
      $.each time_stack, (key, time) =>
        data.animation[time_stack[key]] = @animus.get animation_stack[time_stack[key]]
        if time > last_time
          last_time = time
        return

      ###
      For backgrounds, we allow splitting images into tiles using set rows and
      columns.
      ###
      if context is 'background'
        data.grid = @get_grid_data(object)

      # Get display time
      duration = object.attr('data-slidea-duration')
      if !duration? and js_data and js_data.duration?
        duration = @delete_property js_data, 'duration'

      if @settings.autoplay is false
        data.duration = -1
      else if duration?
        data.duration = parseFloat(duration, 10)
      else
        data.duration = parseFloat(default_duration, 10)

      # Get Exit Animation
      if object.attr('data-slidea-out')?
        out_animation = object.attr('data-slidea-out')
      else if js_data and js_data.out?
        out_animation = @delete_property js_data, 'out'
      else if context == 'background'
        out_animation = @settings.animation.out
      else
        out_animation = ''

      # Set ending animation unless we have a null string
      if out_animation != ''
        if context == 'background'
          if data.duration == -1 or data.duration > last_time + data.animation[last_time].duration
            end_time = data.duration
          else
            end_time = last_time + data.animation[last_time].duration
        else
          end_time = data.duration

        data.animation[end_time] = @animus.get out_animation

      ###
      Set reset state by getting all the animation variables
      and setting them to the default values
      ###
      if $.type(data.animation[data.start].state) isnt 'string'
        # Get animation with resets, meaning besides initial values, we pass through all other
        # data animations and set default values for them as well
        data.animation.initial =
          timeline: null
          duration: 0
          state: @animus.reset data.animation[data.start].state, data.animation

        # Set initial opacity to 1
        unless 'opacity' of data.animation.initial.state
          data.animation.initial.state.opacity = 1

        # Set initial animation as a forcefed animation, meaning we use the
        # initial state as final state, and we override the default state,
        # if applicable
        data.animation[data.start].state = @animus.reset initial_animation_override.state, data.animation

        # Add initial state's easing to the first animation state
        if 'ease' of data.animation.initial.state
          data.animation[data.start].state.ease = data.animation.initial.state.ease

      # Set looping timeout
      if object.attr('data-slidea-loop')?
        data.loop = parseInt(last_time) + data.animation[last_time].duration * 1000
        data.loop_diff = data.start + data.animation[data.start].duration * 1000
      else if js_data and js_data.loop?
        data.loop = parseInt(last_time) + data.animation[last_time].duration * 1000
        data.loop_diff = data.start + data.animation[data.start].duration * 1000
        @delete_property js_data, 'loop'
      else
        data.loop = false

      # Set animation callback
      if js_data and js_data.callback?
        data.callback = js_data.callback

      # Get module specific data
      @eval.modules 'get_data', [
        data,
        index,
        context,
        context_index,
        object,
        image,
        default_duration,
      ]

      return data

    ###
    Get grid data for the given background object
    ###
    @get_grid_data = (object) =>
      grid = {}

      rows = object.attr('data-slidea-grid-rows')
      grid.rows = if rows?
        parseInt rows, 10
      else
        @settings.grid.rows

      columns = object.attr('data-slidea-grid-columns')
      grid.columns = if columns?
        parseInt columns, 10
      else
        @settings.grid.columns

      stagger = object.attr('data-slidea-grid-stagger')
      grid.stagger = if stagger?
        parseInt stagger, 10
      else
        @settings.grid.stagger


      if grid.columns > 1 or grid.rows > 1
        grid.enabled = true
        object.addClass 'slidea-grid-slide'

      return grid


    ###
    Get the size of an image element
    ###
    @get_image_size = (image) =>
      size = {}

      # Get image width
      size.width = if image[0].naturalWidth?
                    image[0].naturalWidth
                   else if image[0].width?
                    image[0].width
                   else if image.width?
                    image.width()
                   else
                    'auto'

      # Get image height
      size.height = if image[0].naturalHeight?
                      image[0].naturalHeight
                    else if image[0].height?
                      image[0].height
                    else if image.height?
                      image.height()
                    else
                      'auto'

      return size

    ###
    Verify if the first required slides have been loaded
    ###
    @check_loaded = (callback) =>
      initial = @loaded

      if @settings.preload == 'fast'
        dynamic = 'load_first'

        @loaded = (
          @slides_loaded.indexOf(@prev) != -1 and
          @slides_loaded.indexOf(@first_slide) != -1 and
          @slides_loaded.indexOf(@next) != -1
        )

        # All slides have been loaded
        if @slides_loaded.length == @slides_length
          # Enable modules
          @eval.layouts 'load'

          # Enable layouts
          @eval.modules 'load'

      else
        dynamic = 'load'

        @loaded = (@slides_loaded.length == @slides_length)

      # Initial load callback, useful for the fast mode because we don't want to
      # call the callback multiple times
      if !initial and @loaded
        @log "Required number of slides has been loaded."

        # Enable layouts
        @eval.layouts dynamic

        # Enable modules
        @eval.modules dynamic

        # Trigger Load event
        @element.trigger 'slidea.load'

        # Apply callback
        callback.call()

      return

    ###
    Load function to imagesLoaded images and cache slide animations
    ###
    @load = (callback) ->
      @slides_loaded = []

      # Preload images from all the slides
      @slides.each (index, slide) =>
        slide = $(slide)
        slide_images = $('img', slide)

        if slide_images.length == 0
          @log "No images to load for slide #{index}."
          @get_slide_data index

          # Add slide to loaded slides
          @slides_loaded.push index
          @check_loaded callback
          return

        # Preload images from current slide
        images_loaded = 0
        slide_images.each (image_index, image) =>
          if $(image).attr('data-slidea-src')?
            src = $(image).attr('data-slidea-src')
          else
            src = $(image).attr('src')

          image_loader = $("<img>")
          image_loader.attr 'src', src

          # Set image sizes on load
          image_loader.load =>
            # Set actual src attribute to the loaded images
            $(image).attr 'src', src

            # When all images are loaded, gather slide data for current slide
            images_loaded += 1
            if images_loaded == slide_images.length
              @log "Loaded images for slide #{index}."
              @get_slide_data index

              # After gathering data, set the size for the current slide
              @eval.layouts 'resize_slide', [index]

              # Add slide to loaded slides
              @slides_loaded.push index

              # Call callback if slides are loaded
              @check_loaded callback
            return
          return
        return


    ###
    Checks if given element is an image and returns it,
    otherwise it returns null
    ###
    @check_image = (element) =>
      if element.is 'img'
        return element
      else
        return null

    ###
    Resize the slider by setting sizes in current context
    ###
    @resize = =>
      # Initialize modules
      @eval.modules 'before_resize'

      @set_responsive_context()
      @set_parent_sizes()

      # Initialize layouts
      @eval.layouts 'resize'

      # Initialize modules
      @eval.modules 'resize'

      @log "Slider elements have been resized."
      return

    ###
    Binds the slider window resize event to cache current window
    width and height and to set the layout up
    ###
    @bind_resize = =>
      @window.resize =>
        @resize()

        @element.trigger 'slidea.resize', [
          @window_width
          @window_height
          @current_responsive_size
        ]

        return

      @log "Bound window resize event."
      return

    ###
    Binds the slider window resize event to cache current window
    width and height and to set the layout up
    ###
    @bind_focus = =>
      return unless @settings.autoplay and @settings.pauseOnBlur

      @window.focus =>
        @unpause_timer()
        return

      @window.blur =>
        @pause_timer()
        return
      return

    ###
    Bind inner button links
    ###
    @bind_inner_links = =>
      $('[data-slidea-href]', @element).each (index, element) =>
        element = $(element)
        href = element.attr 'data-slidea-href'

        if /^[0-9]+/.test href
          href = parseInt href
        else if /^\#[a-zA-Z\_][a-zA-Z0-9\_\-]*/.test href
          return unless $(href).hasClass 'slidea-slide'
          href = $(href).index()

        element.on 'click', =>
          @slide href
          return
        return
      return

    ###
    Set the z-index of each of the @layers
    ###
    @set_layers_zindex = =>
      @log "Setting layer z-index starting from #{@settings.layerIndex}."

      @slides.each (si, slide) =>
        layers = $(".slidea-layer-wrapper", $(slide))
        layer_count = layers.length
        layers.each (li, layer) =>
          $(layer).css "z-index", @settings.layerIndex + layer_count - li
          return
        return
      return

    ###
    Set current responsive range parameter as xs,sm,md or lg
    ###
    @set_responsive_context = =>
      if @window_width >= @settings.screen.xlg
        @current_responsive_size = 'xlg'
      else if @window_width >= @settings.screen.lg
        @current_responsive_size = 'lg'
      else if @window_width >= @settings.screen.md
        @current_responsive_size = 'md'
      else if @window_width >= @settings.screen.sm
        @current_responsive_size = 'sm'
      else
        @current_responsive_size = 'xs'

      @log "Responsive context is \"#{ @current_responsive_size }\"."

      return

    ###
    Sets the size of the slide relevant parents
    ###
    @set_parent_sizes = =>
      # Set Size Setup
      @window_width = @window.width()
      @window_height = @window.height()

      # @Parent Size
      @parent_width = @parent.width()
      @parent_height = @parent.height()

      # @Wrapper Size
      @wrapper_width = @wrapper.width()
      @wrapper_height = @wrapper.height()

      @log "Parent size is #{@parent_width} x #{@parent_height}"
      @log "Window size is #{@window_width} x #{@window_height}"
      @log "Wrapper size is #{@wrapper_width} x #{@wrapper_height}"

      return

    ###
    Add the actual classes to the Slidea selector classes
    ###
    @add_classes = =>
      # $(@settings.selector.slide, @element).addClass "slidea-slide"
      # $(@settings.selector.content, @element).addClass "slidea-content"
      # $(@settings.selector.background, @element).addClass "slidea-background"
      # $(@settings.selector.videoBackground, @element).addClass "slidea-video-background"
      # $(@settings.selector.video, @element).addClass "slidea-video"
      # $(@settings.selector.videoCover, @element).addClass "slidea-video-cover"
      # $(@settings.selector.layer, @element).addClass "slidea-layer"
      # $(@settings.selector.object, @element).addClass "slidea-object"
      # $(@settings.selector.next, @element).addClass "slidea-next"
      # $(@settings.selector.prev, @element).addClass "slidea-prev"
      # $(@settings.selector.pagination, @element).addClass "slidea-pagination"

      @log "Added additional classes."
      return

    ###
    Wrap all the elements into slidea specific classes
    ###
    @wrap_objects = =>
      # Wrap background and layers with .slidea-canvas
      $(@settings.selector.slide, @element).each (i, slide) =>
        $(@settings.selector.background + ', ' + @settings.selector.layer, $(slide)).wrapAll "<div class=\"#{ @settings.selector.canvas.substring(1) }\"></div>"

      # Wrap all slides with .slidea-outer > .slidea-inner
      .wrapAll "<div class=\"#{ @settings.selector.wrapper.substring(1) }\"><div class=\"#{ @settings.selector.inner.substring(1) }\"></div></div>"

      # Wrap content with .slidea-content-wrapper
      $(@settings.selector.content, @element).wrap "<div class=\"#{ @settings.selector.contentWrapper.substring(1) }\"></div>"

      # Wrap background with .slidea-background-wrapper
      $(@settings.selector.background, @element).wrap "<div class=\"#{ @settings.selector.backgroundWrapper.substring(1) }\"></div>"

      # Wrap layers with .slidea-layer-wrapper
      $(@settings.selector.layer, @element).wrap "<div class=\"#{ @settings.selector.layerWrapper.substring(1) }\"></div>"

      # Call modules and layout method
      @eval.layouts 'wrap_objects'
      @eval.modules 'wrap_objects'
      return


    ###
    Check if element has data-slidea-settings which override default init settings
    ###
    @set_data_settings = =>
      if @element.attr("data-slidea-in")?
        @settings.animation.in = @element.attr("data-slidea-in")
      if @element.attr("data-slidea-out")?
        @settings.animation.out = @element.attr("data-slidea-out")
      if @element.attr("data-slidea-duration")?
        @settings.duration = @element.attr("data-slidea-duration")
      if @element.attr("data-slidea-layout")?
        @settings.layout = @element.attr("data-slidea-layout")

      @log "Gathered slider data settings."

      return

    ###
    Set default animation parameters for Slidea animation objects
    and create animus model
    ###
    @init_animus = =>
      override =
        duration: @settings.animation.duration
        easing: @settings.animation.easing

      # Animus
      @animus = new $.animus(override)

      @log "Initialized animus parser."
      return

    ###
    Clears all the set timeouts for the chosen slide in order to stop all
    programmed animations.

    @version 2.0 Loop timeouts must also be cleared after every slide
    ###
    @clear_timeouts = (i) =>
      if 'background' of @data[i]
        $.each @data[i].background, (index) =>
          $.each @data[i].background[index].animation, (animate_index) =>
            clearTimeout @data[i].background[index].animation[animate_index].timeline
            return
          if 'loop_timeout' of @data[i].background[index]
            clearTimeout @data[i].background[index].loop_timeout

      if 'layer' of @data[i]
        $.each @data[i].layer, (index) =>
          $.each @data[i].layer[index].animation, (animate_index) =>
            clearTimeout @data[i].layer[index].animation[animate_index].timeline
            return
          if 'loop_timeout' of @data[i].layer[index]
            clearTimeout @data[i].layer[index].loop_timeout
          return

      if 'object' of @data[i]
        $.each @data[i].object, (index) =>
          $.each @data[i].object[index].animation, (animate_index) =>
            clearTimeout @data[i].object[index].animation[animate_index].timeline
            return
          if 'loop_timeout' of @data[i].object[index]
            clearTimeout @data[i].object[index].loop_timeout
          return

      @log "Cleared timeouts for slide #{i}."
      return


    ###
    Pause autoplay when mouse is over @element
    ###
    @pause_timer = =>
      current_time = new Date
      @timer.remaining = @timer.remaining - (current_time - (@timer.start))
      clearTimeout @timer.clock

      @eval.modules 'pause'

      @element.trigger 'slidea.pause'
      return

    ###
    Unpause timer when hovering over @element
    ###
    @unpause_timer = =>
      next_slide = if @current == -1 then 1 else @current + 1
      clearTimeout @timer.clock

      @timer.start = new Date
      @timer.clock = setTimeout((=>
        @slide next_slide
        return
      ), @timer.remaining)

      @eval.modules 'resume'

      @element.trigger 'slidea.resume'

      return


    ###
    Helper method
    ###
    @next = =>
      @slide @current + 1
      return

    ###
    Helper method
    ###
    @prev = =>
      @slide @current - 1
      return

    ###
    Debounce helper to make resize happen every n milliseconds
    ###
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

    ###
    Delete an object property and return its value
    ###
    @delete_property = (object, property) ->
      temporary = object[property]
      delete object[property]
      return temporary

    ###
    Get a random id by concatenating input string
    with a random number
    ###
    @get_random_id = (string) ->
      return string + '-' + Math.floor((Math.random() * 1000) + 1)

    ###
    Extend given default settings with user input
    ###
    @extend_settings = (id, defaults) =>
      if @settings[id]?
        @settings[id] = $.extend {}, defaults, @settings[id]
      else
        @settings[id] = defaults

    ###
    Logger snippet within Slidea
    ###
    @log = (item) =>
      return unless @debug

      if typeof item == 'object'
        console.log "[Slidea]", item
      else
        console.log "[Slidea] #{item}"
      return

    ###
    Error logger snippet within Slidea
    ###
    @error = (item) =>
      return unless @debug

      if typeof item == 'object'
        console.error "[Slidea]", item
      else
        console.error "[Slidea] #{item}"
      return

    @initialize()
    return

  # Keeps all Slidea layout definitions to be instantiated when needed
  $.slidea.modules = {}

  # Add a new Slidea layout at runtime
  $.slidea.register_module = (name, module) ->
    $.slidea.modules[name] = module
    return

  # Keeps all Slidea layout definitions to be instantiated when needed
  $.slidea.layouts = {}

  # Add a new Slidea layout at runtime
  $.slidea.register_layout = (name, layout) ->
    $.slidea.layouts[name] = layout
    return

  ###
  Lightweight plugin wrapper that prevents multiple instantiations.
  ###
  $.fn.slidea = (opts) ->
    @each (index, element) ->
      unless $.data element, "slidea"
        $.data element, "slidea", new $.slidea element, opts

) window.jQuery, window, document

#
# Default Slidea modules
#

#=include modules/content-scaling.coffee
#=include modules/controls.coffee
#=include modules/keyboard.coffee
#=include modules/loader.coffee
#=include modules/mousewheel.coffee
#=include modules/pagination.coffee
#=include modules/pause-on-hover.coffee
#=include modules/prevent-dragging.coffee
#=include modules/progress-bar.coffee
#=include modules/retina.coffee
#=include modules/scroller.coffee
#=include modules/thumbnails.coffee
#=include modules/touch.coffee
#=include modules/video.coffee
#=include modules/video-cover.coffee

# A factory that uses AMD, CommonJS or window globals to
# create the jQuery plugin.
# do (plugin = slidea, window) ->
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
