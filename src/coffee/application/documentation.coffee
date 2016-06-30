$('document').ready ->
  $('.nano').nanoScroller
    iOSNativeScrolling: true

  $('.table-of-contents li a').on 'click', (e) ->
    target = $(e.currentTarget).attr 'href'

    if ! /^#/.test target
      return

    target = $ target

    $("html, body").animate scrollTop:(target.offset().top - 150), 1000

    if $('#sidebar').hasClass 'sidebar-visible'
      $('#sidebar-toggle').trigger 'click'

    e.preventDefault()
    return

  # Scrollspy
  $('body').scrollspy
    target: '#table-of-contents'
    offset: 150

  $('#sidebar-toggle').on 'click', =>
    $('#sidebar').toggleClass 'sidebar-visible'
    $('.nano').nanoScroller()
    return



  # Change footer background on icon hover
  $('.social-icons a').each (index, icon) ->
    color_class = 'social-colored social-' + $(icon).attr('data-color')

    $(icon).on 'mouseenter', =>
      $('#social-section').addClass color_class
      return

    $(icon).on 'mouseleave', =>
      $('#social-section').removeClass color_class
      return
    return

  SyntaxHighlighter.defaults.toolbar = false
  SyntaxHighlighter.all()

  return
