###
.d8888b.  88d888b.  88d888b.
88'  `88  88'  `88  88'  `88
88.  .88  88.  .88  88.  .88
`88888P8  88Y888P'  88Y888P'
ooooooooo~88~oooooo~88~oooooo
          dP        dP

@plugin  	Revelate
@author 	Alex Grozav
@website   	http://pixevil.com
@version 	1.0
@license 	Commercial
###

$('document').ready ->
  window_width = 0
  window_height = 0

  navbar = if $('.navbar').hasClass('navbar-scroll')
    $('.navbar')
  else
    false

  # Resize header to always fit window height and width, with borders
  #
  resize_header = ->
    $('.header')
      .height $(window).height() - 30
    return
  resize_header()

  $('.cover-image').each (index, element) =>
    $(element).one "load", =>
      $(element).imageCentered()
      return
    return

  # Initialize rock-slider plugin
  #
  $('#browser').rockSlider
    width: 1920
    height: 1275
    autoplay: false
    content_parallax: false
    layout: "content"
    scroller: false
    controls_thumbnail: false
    controls_class: "rock-controls-dark"
    progress: false


  # Initialize our awesome revelate plugin
  #
  $('body').revelate()

  # Initialize visuallax plugin
  #
  $('[data-visuallax]').visuallax()

  # Bind click event to whole divs, not just anchor links
  #
  $('[data-href]').on 'click', ->
    window.location = $(@).find('a').attr('href')
    return

  # $(window).smoothscroll()

  # Enlarge timeout variable, used for avoiding conflict with parallax method
  # of rock-slider. CSS Transition from enlarge-transition class conflicts with
  # velocity's 1ms animation used in parallaxing
  enlarge_timeout = undefined

  # When leaving, remove hovering classes
  #
  $('.header-link').on 'mouseleave', ->
    link = $(` this `)
    slide = link.closest('.rock-slider-slide')
    button = $('.header-btn', link)

    slide.removeClass 'background-enlarge'
    button.removeClass 'hover'

    $('.rock-slider').data('rock-slider').unpause_timer()
    return

  # Bind methods to window resize event
  #
  $(window).resize $.debounce( =>
    window_width = $(window).width()
    window_height = $(window).height()

    resize_header()
    return
  , 10)
  $(window).resize resize_header

  # Scroll navbar with the document up to 25px, after which we remove the
  # transparent class
  #
  $(window).scroll =>
    scroll_top = $(@).scrollTop()
    if navbar
      if scroll_top < 25
        transform_navbar = "translate3d(0,#{25-scroll_top}px,0)"

        navbar.css
          'transform': transform_navbar
          '-o-transform': transform_navbar
          '-ms-transform': transform_navbar
          '-moz-transform': transform_navbar
          '-webkit-transform': transform_navbar
        navbar.addClass 'navbar-transparent'
      else if navbar.hasClass 'navbar-transparent'
        transform_navbar = "translate3d(0,#{0},0)"

        navbar.css
          'transform': transform_navbar
          '-o-transform': transform_navbar
          '-ms-transform': transform_navbar
          '-moz-transform': transform_navbar
          '-webkit-transform': transform_navbar
        navbar.removeClass 'navbar-transparent'

    return
  .trigger 'scroll'

  # Toggle bootstrap dropdown on hover
  #
  $('ul.nav li.dropdown').hover (->
    return if $('.navbar-collapse').hasClass('collapse in')

    $(this).addClass('open')
    return
  ), ->
    return if $('.navbar-collapse').hasClass('collapse in')

    $(this).removeClass('open')
    return

  # Hide boostrap navbar when clicking outside of the collapsed item
  #
  $('body').bind 'click', (e) ->
    if $(e.target).closest('.navbar').length == 0
      # Click happened outside of .navbar, so hide
      if $('.navbar-collapse').hasClass('collapse in')
        jQuery('.navbar-collapse').collapse 'hide'
    return

  if $('#contact-form').length > 0
    name_input = $('#contact-name')
    email_input = $('#contact-email')
    subject_input = $('#contact-subject')
    message_input = $('#contact-message')

    remove_input_error = (input) ->
      input.parent().removeClass 'has-error'
      return

    name_input.on 'click', -> remove_input_error name_input
    email_input.on 'click', -> remove_input_error email_input
    subject_input.on 'click', -> remove_input_error subject_input
    message_input.on 'click', -> remove_input_error message_input

    $('.contact-response').on 'click', ->
      $('.contact-response').velocity
        opacity: 0
      ,
        duration: 1000
        complete: ->
          $('.contact-response').addClass('contact-hidden')
      return

    $('#contact-form').on 'submit', (e) =>
      error = false
      name = name_input.val()
      email = email_input.val()
      subject = subject_input.val()
      message = message_input.val()

      unless 3 < name.length < 64
        name_input.parent().addClass 'has-error'
        error = true

      unless /[A-Z0-9._%+-]+\@[A-Z0-9.-]+\.[A-Z]+/i.test email
        email_input.parent().addClass 'has-error'
        error = true

      unless 16 < message.length < 5000
        message_input.parent().addClass 'has-error'
        error = true

      unless 3 < subject.length < 64
        subject_input.parent().addClass 'has-error'
        error = true

      if error
        e.preventDefault()
        return false
      else
        $('#contact-form').ajaxSubmit
          error: ->
            $('#contact-failure').removeClass('contact-hidden').velocity
              opacity: 1
            ,
              duration: 1000
          success: ->
            $('#contact-success').removeClass('contact-hidden').velocity
              opacity: 1
            ,
              duration: 1000
        return false

  $('.navbar ul li a').on 'click', (e) ->
    target = $(e.currentTarget).attr 'href'

    unless /^\#/.test target
      return

    if $(target).length > 0
      target = $ target
    else
      window.location = '/rock-slider/' + target

    $("html").velocity "scroll",
      offset: "#{target.offset().top}px"
      mobileHA: false

    e.preventDefault()
    return

  # Toggle tooltips using title attribute
  $('[data-toggle="tooltip"]').tooltip()

  # Benchmark Chart
  benchmark =
    erb: [79659, 51130, 33472]
    opulent: [76803, 48989, 5784] 
    slim: [78587, 50629, 2156]
    haml: [11809, 10744, 5603]
  benchmark_data_values = []
  $.each benchmark, (index, item) =>
    benchmark_data_values.push parseInt (item[0] + item[1] + item[2]) / 3
    return

  benchmark_canvas = $('#benchmark-chart')
  if $('#benchmark-chart').length > 0
    benchmark_ctx = benchmark_canvas.get(0).getContext("2d")
    benchmark_data =
      labels: ["ERB", "Opulent", "Slim", "Haml"],
      datasets: [
        {
          label: "My First dataset",
          fillColor: ["#ffffff", "#E32546", "#ffffff", "#ffffff"]
          strokeColor: ["#ffffff", "#E32546", "#ffffff", "#ffffff"]
          highlightFill: ["#ffffff", "#E32546", "#ffffff", "#ffffff"]
          highlightStroke: ["#ffffff", "#E32546", "#ffffff", "#ffffff"]
          data: benchmark_data_values
        }
      ]

    benchmark_chart = new Chart(benchmark_ctx).Bar benchmark_data,
      responsive: true
      legend : true


  return
