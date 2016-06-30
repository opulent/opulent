$('document').ready ->
  responsive =
    xs: 0
    sm: 544
    md: 768
    lg: 992
    xl: 1200

  # Initialize nanoscroller
  sidebar = $('.nano')
  sidebar.nanoScroller
    iOSNativeScrolling: true
  sidebar.addClass 'has-nano'

  # Scroll to div
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

  # Toggle sidebar visibility
  $('#sidebar-toggle').on 'click', =>
    $('#sidebar').toggleClass 'sidebar-visible'
    return

  # Build or destroy nanoscroller responsively
  $(window).resize =>
    window_width = $(window).width()
    if window_width < responsive['md'] && sidebar.hasClass('has-nano')
      sidebar.removeClass 'has-nano'
      sidebar.nanoScroller
        destroy: true
      $('.nano-pane', sidebar).remove()
    else if window_width >= responsive['md'] && !sidebar.hasClass('has-nano')
      sidebar.addClass 'has-nano'
      sidebar.nanoScroller
        iOSNativeScrolling: true
    return
  .trigger('resize')

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
