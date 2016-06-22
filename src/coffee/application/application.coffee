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
  # Resize the header element to always fit window size
  resize_header = ->
    $('.header')
      .height $(window).height()
    return
  resize_header()

  # Start navbar events plugin
  $('.navbar').navbar()

  # Start form events plugin
  $('.form').form()

  # Start form events plugin
  $('[data-toggle="tooltip"]').tooltip()

  # Initialize rock-slider plugin
  #
  $('#browser').slidea
    autoplay: false
    layout: "content"
    controls:
      enabled: true

  # Bind click event to whole divs, not just anchor links
  #
  $('[data-href]').on 'click', ->
    window.location = $(@).find('a').attr('href')
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
