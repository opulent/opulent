###
@plugin  	Image Centered
@author 	Alex Grozav
@website  http://pixevil.com
@version 	1.0
@license 	Commercial
###

(($, window, document) ->
  "use strict"

  # This is where we place our default values.
  _defaults =
    source: null
    parent: null
    resize_timeout: 10
    debug: false

  # @imageCentered
  $.imageCentered = (element, options) ->
    @_defaults = _defaults
    @settings = $.extend true, {}, @_defaults, options

    @element = $ element
    @source = if @settings.source then @settings.source else @element
    @parent = if @settings.parent then @settings.parent else @source.parent()

    @initialize = =>
      @bind_resize()

      @set_size()
      @center()
      return

    @set_size = =>
      @parent_height = @parent.outerHeight(true)
      @parent_width = @parent.outerWidth(true)

      @height = @source.outerHeight(true)
      @width = @source.outerWidth(true)

      return

    @center = =>
      if @settings.debug
        console.log @parent_height, @height,  (@parent_height - @height)

      if @parent_height > @height
        @element.removeClass('full-width').addClass 'full-height'

        @element.css
          'margin-top': "0px"
          'margin-left': "#{(@parent_width - @width) / 2}px"

      else if @parent_width > @width
        @element.removeClass('full-height').addClass 'full-width'

        @element.css
          'margin-top': "#{(@parent_height - @height) / 2}px"
          'margin-left': "0px"

      else
        @element.css
          'margin-top': "#{(@parent_height - @height) / 2}px"
          'margin-left': "#{(@parent_width - @width) / 2}px"

      return

    @bind_resize = =>
      resize_timeout = null

      $(window).resize =>
        clearTimeout resize_timeout
        resize_timeout = setTimeout =>
          @set_size()
          @center()
          return
        , @settings.resize_timeout

        return

    @initialize()

    return

  # Lightweight plugin wrapper that prevents multiple instantiations.
  #
  $.fn.imageCentered = (opts) ->
    @each (index, element) ->
      unless $.data element, "imageCentered"
        $.data element, "imageCentered", new $.imageCentered element, opts

) window.jQuery, window, document
