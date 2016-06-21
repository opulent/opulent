
# Returns a function, that, as long as it continues to be invoked, will not
# be triggered. The function will be called after it stops being called for
# N milliseconds. If `immediate` is passed, trigger the function on the
# leading edge, instead of the trailing.
(($, window, document) ->
  "use strict"

  $.debounce = (func, wait, immediate) ->
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

) window.jQuery, window, document
