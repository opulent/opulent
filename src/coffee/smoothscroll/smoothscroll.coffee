(($, window, document) ->
  "use strict"

  $.smoothscroll = (element, options) ->
    _defaults =
      friction: 0.95
      direction: undefined
      on_render: null
      step_amount: 1
      min_movement: 0.1

    @container = $(element)

    @running = false

    @max_scroll_top = 0
    @min_scroll_top = undefined

    @current_y = 0
    @target_y = 0
    @old_y = 0
    @vy = 0


    @initialize = =>
      #  var args = [].splice.call(arguments, 0);
      @settings = $.extend {}, _defaults, options

      if !('ontouchstart' of window)
        @container.bind 'mousewheel DOMMouseScroll', @on_wheel

        @target_y = @old_y = @container.scrollTop()
        @current_y = -@target_y

        @min_scroll_top = @container.get(0).clientHeight - (@container.get(0).scrollHeight)

        if !@running
          @running = true
          @animate_loop()
      return

    @remove = =>
      @running = false
      @container.unbind 'mousewheel', @on_wheel
      @container.unbind 'DOMMouseScroll', @on_wheel
      return

    @update_scroll_target = (amt) =>
      @target_y += amt
      @vy += (@target_y - @old_y) * @settings.step_amount
      @old_y = @target_y
      return

    @render = =>
      if @vy < -@settings.min_movement or @vy > @settings.min_movement
        @current_y = @current_y + @vy

        if @current_y > @max_scroll_top
          @vy = 0
          @current_y = 0
        else if @current_y < @min_scroll_top
          @vy = 0
          @current_y = @min_scroll_top

        @container.scrollTop -@current_y
        @vy *= @settings.friction

        if @settings.on_render
          @settings.on_render()
      return

    @animate_loop = =>
      if !@running
        return
      window.request_animation_frame @animate_loop
      @render()
      return

    @on_wheel = (e) =>
      e.preventDefault()

      event = e.originalEvent

      if e.type is 'DOMMouseScroll' and event.detail?
        delta = event.detail * -1
      else if event.wheelDelta?
        delta = event.wheelDelta.toFixed(2) / 40
      else if event.deltaY?
        delta = event.deltaY.toFixed(2) / -10

      dir = if delta < 0 then -1 else 1

      if dir != @settings.direction
        @vy = 0
        @settings.direction = dir

      #reset @current_y in case non-wheel scroll has occurred (scrollbar drag, etc.)
      @current_y = -@container.scrollTop()

      # console.log delta, event.detail, event.wheelDelta, event.deltaY

      @update_scroll_target delta

      return

    @initialize()
    return

  ###
  # http://paulirish.com/2011/requestanimationframe-for-smart-animating/
  ###
  window.request_animation_frame = do =>
    window.requestAnimationFrame or window.webkitRequestAnimationFrame or window.mozRequestAnimationFrame or window.oRequestAnimationFrame or window.msRequestAnimationFrame or (callback) ->
      window.setTimeout callback, 1000 / 60
      return

  ###
  # http://jsbin.com/iqafek/2/edit
  ###
  normalize_wheel_delta = do =>
    # Keep a distribution of observed values, and scale by the
    # 33rd percentile.
    distribution = []
    done = null
    scale = 30
    (n) =>
      # Zeroes don't count.
      if n == 0
        return n
      # After 500 samples, we stop sampling and keep current factor.
      if done != null
        return n * done
      abs = Math.abs(n)
      # Insert value (sorted in ascending order).

      outer = ->
        i = 0
        while i < distribution.length
          if abs <= distribution[i]
            distribution.splice i, 0, abs
            outer()
            break
          ++i
        distribution.push abs
        return

      # Factor is scale divided by 33rd percentile.
      factor = scale / distribution[Math.floor(distribution.length / 3)]
      if distribution.length == 500
        done = factor
      n * factor

  $.fn.smoothscroll = (opts) ->
    @each (index, element) ->
      unless $.data element, "smoothscroll"
        $.data element, "smoothscroll", new $.smoothscroll element, opts


  return
) window.jQuery, window, document
