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

  $.animus = (override) ->
    # Animation Model
    model = {}

    # Animation duration
    model.duration = 600

    # Model Default State
    model.defaults =
      opacity: 1
      rotationX: 0
      rotationY: 0
      rotationZ: 0
      x: 0
      y: 0
      z: 0
      xPercent: 0
      yPercent: 0
      scale: 1
      scaleX: 1
      scaleY: 1
      scaleZ: 1
      skewX: 0
      skewY: 0
      easing: "Quad.easeOut"


    # List of allowed GSAP parameters
    @parameters = [
      'scale'
      'scaleX'
      'scaleY'
      'scaleZ'
      'x'
      'y'
      'z'
      'skewX'
      'skewY'
      'rotation'
      'rotationX'
      'rotationY'
      'rotationZ'
      'perspective'
      'xPercent'
      'yPercent'
      'shortRotation'
      'shortRotationX'
      'shortRotationY'
      'shortRotationZ'
      'transformOrigin'
      'svgOrigin'
      'transformPerspective'
      'directionalRotation'
      'parseTransform'
      'force3D'
      'skewType'
      'smoothOrigin'
      'boxShadow'
      'borderRadius'
      'backgroundPosition'
      'backgroundSize'
      'perspectiveOrigin'
      'transformStyle'
      'backfaceVisibility'
      'userSelect'
      'margin'
      'padding'
      'color'
      'clip'
      'textShadow'
      'autoRound'
      'strictUnits'
      'border'
      'borderWidth'
      'float'
      'cssFloat'
      'styleFloat'
      'perspectiveOrigin'
      'transformStyle'
      'backfaceVisibility'
      'userSelect'
      'opacity'
      'alpha'
      'autoAlpha'
      'className'
      'clearProps'
    ]

    # Override default and final animus animation model
    #
    @init = ->
      $.extend model, override
      return

    ###
    Process an animation string of the form "rotate 45, fade in" into
    a usable VelocityJS animation object

    @var     string      The animation string to be modified, of the form
                         move x 300px, fade in, scale up
    ###
    @get = (input) ->
      # Animation Object
      animation = {}
      animation.state = { z: 0 }
      animation.duration = model.duration / 1000
      animation.timeline = null

      if input == '' or !input? or !input
        return animation

      input = input.split /(\,\s*)/
      $.each input, (index, string) =>
        i = 0

        # Trim input string partial
        string = $.trim(string)

        # Replace round brackets
        if /\(.*\)/.test(string)
          string = string.replace(/\s*\(\s*/, ' ').replace(/\s*\)\s*/, ' ')

        # Split by space
        string = string.split /\s+/

        # Remove empty strings
        string = $.grep string, (n) ->
          n != ""

        # Set current working parameter
        parameter = string.shift()

        # Set current working value
        value = string.join ' '

        # Check if we have a VelocityJS parameter
        if ['duration', 'speed'].indexOf(parameter) != -1
          animation.duration = parseFloat(value, 10) / 1000
        else if ['ease', 'easing'].indexOf(parameter) != -1
          animation.state.ease = value
        else if parameter in @parameters
          if value? and !/.+(\s+.+)+/.test(value)
            if /px/.test value
              value = parseFloat value.replace('px', ''), 10
            else if /deg/.test value
              value = parseFloat value.replace('deg', ''), 10

            # Set as float if it isn't a percentage value
            if /^[0-9](\.[0-9]+)?$/.test value
              value = parseFloat value, 10

          # @TODO Add final values
          # else
          #   value = model.finals[parameter]
          animation.state[parameter] = value

        # Check if we have a VelocityJS redirect
        else if parameter of $.animus.presets
          animation.state = parameter

        return

      return animation


    ###
    Set reset state by getting all the animation variables
    and setting them to the default values

    @param data [State] State which overwrites reset variables
    @param data [Object] Element states data in RockSlider
    @param deep [Boolean] Generate reset from an array of animations if true
                          or from a single animation if false
    ###
    @reset = (state, data) ->
      ###
      Check if we need to add the percentage sign to the default state value
      ###
      percentage = (value) ->
        if /\%$/.test value
          return '%'
        else
          return ''

      reset = {}
      $.each data, (anim)->
        return if $.type(@state) is 'string'
        $.each @state, (key, value) ->
          if !(key of reset) and key of model.defaults
            reset[key] = model.defaults[key] + percentage(value)
          return
        return

      return $.extend {}, reset, state

    # Initialize Animus
    @init()

    return

  # Keeps all Animus presets
  $.animus.presets = {}

  # Add a new Animus preset
  $.animus.register_preset = (name, timeline) ->
    $.animus.presets[name] = timeline
    return

  return
) jQuery, window, document
