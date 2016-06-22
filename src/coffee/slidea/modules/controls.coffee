(($, window, document) ->
  "use strict"

  $.fn.slidea.controls = ->
    ###
    Set up slider controls
    ###
    @settings =
      enabled: false # Add next / prev buttons
      thumbnail: false # Add thumbnail to controls
      html:
        prev: "&lt;"
        next: "&gt;"
      class: "slidea-controls-alternate" # Additional control classes

    ###
    Slider Initialization Event
    ###
    @initialize = ->
      @settings.controls.enabled = false if @slides_length == 1
      return

    ###
    Update slide data
    ###
    @get_slide_data = (index, slide) ->
      if @settings.controls.thumbnail and !@data[index].thumbnail?
        thumbnail = slide.attr('data-slidea-thumbnail')
        if thumbnail?
          @data[index].thumbnail = thumbnail
        else
          @data[index].thumbnail = $(@settings.selector.background, slide).attr('src')
      return

    ###
    Add controls to the slider
    ###
    @load = ->
      html = ''
      for control in ['next', 'prev']
        alt = control.toLowerCase().replace /\b[a-z]/g, (letter) ->
          return letter.toUpperCase()

        html += '<a href="javascript:void(0);" class="slidea-control slidea-' + control + ' ' + @settings.controls.class + '">'
        html += '<div class="slidea-control-inner">'
        if @settings.controls.thumbnail is true
          html += '<div class="slidea-control-thumbnail">'
          html += '<img src="" alt="' + alt + ' Slide" class="slidea-control-image"/>'
          html += '</div>'
        html += '<div class="slidea-control-text">'
        html += @settings.controls.html[control]
        html += '</div>'
        html += '</div>'
        html += '</a>'

      # Add controls HTML
      @wrapper.append html

      # Set previous button
      @prev_button = $(@settings.selector.prev, @element)
      @prev_button.on 'click', =>
        @slide @current - 1
        return

      # Set next button
      @next_button = $(@settings.selector.next, @element)
      @next_button.on 'click', =>
        @slide @current + 1
        return

      # Set thumbnails
      if @settings.controls.thumbnail is true
        @prev_thumbnail = $('.slidea-control-image', @prev_button)
        @next_thumbnail = $('.slidea-control-image', @next_button)

      return

    ###
    Run on slide modifiers for controls
    ###
    @slide = (from, to) ->
      if @settings.controls.thumbnail
        @prev_thumbnail.attr 'src', @data[@prev].thumbnail
        @next_thumbnail.attr 'src', @data[@next].thumbnail

        @log "Changed control thumbnails to prev[#{from}] and next[#{to}]."
      return
    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'controls', $.fn.slidea.controls

) window.jQuery, window, document
