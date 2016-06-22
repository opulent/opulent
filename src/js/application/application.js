
/*
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
 */

(function() {
  $('document').ready(function() {
    var benchmark, benchmark_canvas, benchmark_chart, benchmark_ctx, benchmark_data, benchmark_data_values, resize_header;
    resize_header = function() {
      $('.header').height($(window).height());
    };
    resize_header();
    $('.navbar').navbar();
    $('.form').form();
    $('[data-toggle="tooltip"]').tooltip();
    $('#browser').slidea({
      autoplay: false,
      layout: "content",
      controls: {
        enabled: true
      }
    });
    $('[data-href]').on('click', function() {
      window.location = $(this).find('a').attr('href');
    });
    $('.social-icons a').each(function(index, icon) {
      var color_class;
      color_class = 'social-colored social-' + $(icon).attr('data-color');
      $(icon).on('mouseenter', (function(_this) {
        return function() {
          $('#social-section').addClass(color_class);
        };
      })(this));
      $(icon).on('mouseleave', (function(_this) {
        return function() {
          $('#social-section').removeClass(color_class);
        };
      })(this));
    });
    benchmark = {
      erb: [79659, 51130, 33472],
      opulent: [76803, 48989, 5784],
      slim: [78587, 50629, 2156],
      haml: [11809, 10744, 5603]
    };
    benchmark_data_values = [];
    $.each(benchmark, (function(_this) {
      return function(index, item) {
        benchmark_data_values.push(parseInt((item[0] + item[1] + item[2]) / 3));
      };
    })(this));
    benchmark_canvas = $('#benchmark-chart');
    if ($('#benchmark-chart').length > 0) {
      benchmark_ctx = benchmark_canvas.get(0).getContext("2d");
      benchmark_data = {
        labels: ["ERB", "Opulent", "Slim", "Haml"],
        datasets: [
          {
            label: "My First dataset",
            fillColor: ["#ffffff", "#E32546", "#ffffff", "#ffffff"],
            strokeColor: ["#ffffff", "#E32546", "#ffffff", "#ffffff"],
            highlightFill: ["#ffffff", "#E32546", "#ffffff", "#ffffff"],
            highlightStroke: ["#ffffff", "#E32546", "#ffffff", "#ffffff"],
            data: benchmark_data_values
          }
        ]
      };
      benchmark_chart = new Chart(benchmark_ctx).Bar(benchmark_data, {
        responsive: true,
        legend: true
      });
    }
  });

}).call(this);

//# sourceMappingURL=../../maps/application/application.js.map
