(($, window, document) ->
  "use strict"

  # @Navbar
  $.navbar = (element, options) ->
    @element = $(element)

    @settings =
      condense: true
      transparentize: true

    if @element.attr('data-navbar-condensed')? && @element.attr('data-navbar-condensed') == 'false'
      @settings.condense = false
    if @element.attr('data-navbar-transparentize')? && @element.attr('data-navbar-transparentize') == 'false'
      @settings.transparentize = false

    $('.navbar-toggle', @element).on 'click', =>
      @element.toggleClass 'navbar-collapsed'
      return

    # Scroll navbar with the document up to 25px, after which we remove the
    # transparent class
    #
    $(window).scroll =>
      scroll_top = $(window).scrollTop()
      if scroll_top > 25
        # Modify navbar szize
        @element.addClass 'navbar-condensed' if @settings.condense

        # Modify navbar transparency
        @element.addClass 'navbar-faded'
        if @settings.transparentize
          @element.removeClass 'navbar-transparent'
      else
        # Modify navbar szize
        if @element.hasClass('navbar-condensed') && @settings.condense
          @element.removeClass 'navbar-condensed'

        # Modify navbar transparency
        @element.addClass 'navbar-transparent' if @settings.transparentize
        if @element.hasClass('navbar-faded')
          @element.removeClass 'navbar-faded'

      return
    .trigger 'scroll'

    return

  # Lightweight plugin wrapper that prevents multiple instantiations.
  #
  $.fn.navbar = (opts) ->
    @each (index, element) ->
      unless $.data element, "navbar"
        $.data element, "navbar", new $.navbar element, opts

) window.jQuery, window, document


# A factory that uses AMD, CommonJS or window globals to
# create the jQuery plugin.
# do (plugin = navbar, window) ->
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
