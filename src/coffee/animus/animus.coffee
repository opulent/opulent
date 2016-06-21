###

                  oo

.d8888b. 88d888b. dP 88d8b.d8b. dP    dP .d8888b.
88'  `88 88'  `88 88 88'`88'`88 88    88 Y8ooooo.
88.  .88 88    88 88 88  88  88 88.  .88       88
`88888P8 dP    dP dP dP  dP  dP `88888P' `88888P'
oooooooooooooooooooooooooooooooooooooooooooooooooo

@plugin    jQuery
@license   CodeCanyon Standard / Extended
@author    Alex Grozav
@company   Pixevil
@website   http://pixevil.com
@email     alex@grozav.com
###

(($, window, document) ->
  'use strict'

  $.animus = (defaults, finals) ->
    # Animation Model
    model = {}

    # Model Default State
    model.defaults =
      duration: 600
      easing: 'swing'
      state:
        opacity: 1
        rotateX: '0deg'
        rotateY: '0deg'
        rotateZ: '0deg'
        translateX: 0
        translateY: 0
        translateZ: 0
        scale: 1
        scaleX: 1
        scaleY: 1
        scaleZ: 1
        skewX: '0%'
        skewY: '0%'
      timeline: null

    # Model final State
    model.finals = state:
      opacity: 0
      rotateX: '45deg'
      rotateY: '45deg'
      rotateZ: '45deg'
      translateX: '-100%'
      translateY: '-100%'
      translateZ: '-100%'
      scale: 2
      scaleX: 2
      scaleY: 2
      scaleZ: 2
      skewX: '100%'
      skewY: '100%'

    # Override default and final animus animation model
    #
    @init = ->
      $.extend model.defaults, defaults
      $.extend model.finals, finals
      return

    # Process an animation string of the form "rotate 45, fade in" into
    # a usable VelocityJS animation object
    #
    # @var     string      The animation string to be modified, of the form
    #                      move x 300px, fade in, scale up
    #
    @get = (string) ->
      animation = {}

      # Animation Object
      animation.state =
        translateZ: 0
      animation.duration = model.defaults.duration
      animation.easing = model.defaults.easing
      animation.timeline = null

      if string == '' or !string?
        return animation

      string = string.split ','
      $.each string, (string)->
        i = 0

        string = $.trim(this)
        if /\(.*\)/.test(string)
          string = string.replace(/\s*\(\s*/, ' ').replace(/\s*\)\s*/, ' ')
        string = string.split(/\s+/)
        string = $.grep string, (n) ->
          n != ""

        switch string[i]
          # Animation Speed
          #
          # speed [800]
          when 'duration', 'speed'
            error 'argument', string[1] unless string[1]?
            animation.duration = parseInt(string[1])

          # Animation Easing
          #
          # easing [easeInOut]
          when 'easing'
            error 'argument', string[1] unless string[1]?

            if string[1][0] == '['
              string[1] = string[1].slice(1)
              string[string.length - 1] = string[string.length - 1].slice(0, -1)
              animation.easing = string.slice(1).map (item) ->
                parseFloat item
            else
              animation.easing = string[1]


          # Fade Animation
          #
          # fade [in, out] from 0 to 0.5
          when 'opacity', 'fade'
            parameter = 'opacity'

            switch string[1]
              when 'in' then animation.state[parameter] = 1
              when 'out' then animation.state[parameter] = 0
              else animation.state[parameter] = string[1]

          # Rotate Animation
          #
          # rotate [x,y,z] [left,right] from 180 to 0
          when 'rotate'
            parameter = 'rotateZ'

            # Get direction
            i = 1
            switch string[i]
              when 'x', 'y', 'z' then parameter = "rotate#{string[i].toUpperCase()}"
              else --i

            # Get parameters
            if string[++i]?
              animation.state[parameter] = string[i]
            else
              animation.state[parameter] = model.finals.state[parameter]

          # Scale Animation
          #
          # scale [up,down] from 0 to 1
          when 'scale'
            parameter = 'scale'

            # Get direction
            i = 1
            switch string[i]
              when 'x', 'y', 'z' then parameter = "scale#{string[i].toUpperCase()}"
              else --i

            # Get parameters
            if string[++i]?
              switch string[i]
                when 'up' then animation.state[parameter] = operation('*', 1, model.finals.state[parameter])
                when 'down' then animation.state[parameter] = operation('/', 1, model.finals.state[parameter])
                else animation.state[parameter] = string[i]
            else
              animation.state[parameter] = operation('*', 1, model.finals.state[parameter])

          # Skew Animation
          #
          # skew x from 0 to 1
          when 'skew'
            parameter = 'skewX'

            # Get direction
            i = 1
            switch string[i]
              when 'x', 'y' then parameter = "rotate#{string[i].toUpperCase()}"
              else --i

            # Get parameters
            if string[++i]?
              animation.state[parameter] = string[i]
            else
              animation.state[parameter] = model.finals.state[parameter]


          # Translate Animation
          #
          # translate [x,y,z] from 0 to 100
          when 'move', 'slide', 'translate'
            parameter = 'translateX'

            # Get direction
            i = 1
            switch string[i]
              when 'left', 'right', 'x' then parameter = 'translateX'
              when 'up', 'down', 'y' then parameter = 'translateY'
              when 'z' then parameter = 'translateZ'
              else --i

            # Get parameters
            if string[++i]?
               animation.state[parameter] = string[i]
            else
              switch string[i - 1]
                when 'x', 'y', 'z' then animation.state[parameter] = model.finals.state[parameter]
                when 'in', 'up', 'left' then animation.state[parameter] = model.finals.state[parameter]
                when 'out', 'down', 'right' then animation.state[parameter] = operation('*', -1, model.finals.state[parameter])
                else animation.state[parameter] = model.finals.state[parameter]

          # Other Animation
          #
          # animate
          else
            parameter = string[0]

            # Check if we have a VelocityJS parameter
            if (parameter in $.Velocity.CSS.Lists.transforms3D) ||
               (parameter in $.Velocity.CSS.Lists.transformsBase) ||
               (parameter in $.Velocity.CSS.Lists.colors)
              animation.state[parameter] = string[1]

            # Check if we have a VelocityJS redirect
            else if parameter of $.Velocity.Redirects
              animation.state = parameter

            # Don't know how to handle this string
            else
              error 'unknown', string[0]

        return

      animation

    # Set reset state by getting all the animation variables
    # and setting them to the default values
    #
    # @param data [State] State which overwrites reset variables
    # @param data [Object] Element states data in RockSlider
    # @param deep [Boolean] Generate reset from an array of animations if true
    #                       or from a single animation if false
    #
    @reset = (state, data, deep) ->
      reset = {}
      if deep == true
        $.each data.animation, (anim)->
          return if $.type(@state) is 'string'
          $.each @state, (key) ->
            if !(key of reset) and key of model.defaults.state
              reset[key] = model.defaults.state[key]
            return
          return
      else
        $.each data, (key) ->
          if !(key of reset) and key of model.defaults.state
            reset[key] = model.defaults.state[key]
          return


      $.extend reset, state


    # Set reset state by getting all the animation variables
    # and setting them to the default values
    #
    # @param initial [State] Initial animation state
    # @param final [State] Final animation state
    #
    @forcefeed = (final, initial) ->
      result = {}

      initial = if initial
        $.extend {}, model.defaults.state, initial
      else
        model.defaults.state

      for key of final
        if final[key] isnt initial[key]
          result[key] = [initial[key], final[key]]
        else
          result[key] = final[key]

      return result

    # Basic JSON calculator
    #
    calc =
      '+': (a, b) ->
        a + b
      '-': (a, b) ->
        a - b
      '*': (a, b) ->
        a * b
      '/': (a, b) ->
        a / b

    # Helper function to add two variables a, b with a measurement unit suffix
    #
    operation = (op, x, y) ->
      if !(typeof x == 'string' or x instanceof String)
        x = x.toString()
      if !(typeof y == 'string' or y instanceof String)
        y = y.toString()

      exp = /(-?[0-9]*)(px|%|deg)/i

      matchx = x.match(exp)
      matchy = y.match(exp)

      x = if matchx != null then parseFloat(matchx[1]) else parseFloat(x)
      y = if matchy != null then parseFloat(matchy[1]) else parseFloat(y)

      if matchx != null and matchy != null
        return calc[op](x, y) + matchx[2]

      if matchx != null and matchy == null
        return calc[op](x, y) + matchx[2]

      if matchx == null and matchy != null
        return calc[op](x, y) + matchy[2]

      calc[op] x, y

    error = (context, data) ->
      switch context
        when 'argument'
          message = "Missing animation argument for \"#{data}\"."
        else
          message = "Unknown animation parameter \"#{data}\"."

      console.error "[Animus] #{message}"

    # Initialize Animus
    #
    @init()

    return
  return

) jQuery, window, document
