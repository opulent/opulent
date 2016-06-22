(($, window, document) ->
  "use strict"

  $.fn.slidea.pagination = ->
    ###
    Set up pagination component
    ###
    @settings =
      enabled: false # Add pagination
      position: "bottom" # top / bottom / left / right / before / after
      class: "slidea-pagination-light" # Additional pagination classes

    ###
    Add pagination bullets to the slider
    ###
    @initialize = ->
      # Don't add pagination if we have only one slide
      return if @slides_length == 1

      position = "slidea-pagination-#{@settings.pagination.position}"

      html = ""
      html += "<div class=\"slidea-pagination " + position + " " + @settings.pagination.class + "\">"
      i = 0
      while i < @slides_length
        html += "<div class=\"slidea-pagination-bullet\"></div>"
        i++
      html += "</div>"
      pagination = $(html)

      switch @settings.pagination.position
        when "before"
          @element.before pagination
        when "after"
          @element.after pagination
        else
          @element.prepend pagination

      @pagination = $(".slidea-pagination-bullet", pagination)
      @pagination.each (i, el) =>
        pagination_bullet = $(el)
        pagination_bullet.on "click", =>
          @pagination.filter(".active").removeClass "active"
          pagination_bullet.addClass "active"
          @slide i
          return
        return
      return

    @slide = (from, to) ->
      @pagination.filter('.active').removeClass 'active'
      @pagination.eq(to).addClass 'active'
      return

    return

  # Add the feature to Slidea as a new instance
  #
  $.slidea.register_module 'pagination', $.fn.slidea.pagination

) window.jQuery, window, document
