$('document').ready ->
  $('.nano').nanoScroller()

  $('.table-of-contents li a').on 'click', (e) ->
    target = $(e.currentTarget).attr 'href'

    if ! /^#/.test target
      return

    target = $ target

    $("html").velocity "scroll",
      offset: "#{target.offset().top}px"
      mobileHA: false

    e.preventDefault()
    return

  SyntaxHighlighter.defaults.toolbar = false
  SyntaxHighlighter.all()

  return
