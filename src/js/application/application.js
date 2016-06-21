
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
    var benchmark, benchmark_canvas, benchmark_chart, benchmark_ctx, benchmark_data, benchmark_data_values, email_input, enlarge_timeout, message_input, name_input, navbar, remove_input_error, resize_header, subject_input, window_height, window_width;
    window_width = 0;
    window_height = 0;
    navbar = $('.navbar').hasClass('navbar-scroll') ? $('.navbar') : false;
    resize_header = function() {
      $('.header').height($(window).height() - 30);
    };
    resize_header();
    $('.cover-image').each((function(_this) {
      return function(index, element) {
        $(element).one("load", function() {
          $(element).imageCentered();
        });
      };
    })(this));
    $('#browser').rockSlider({
      width: 1920,
      height: 1275,
      autoplay: false,
      content_parallax: false,
      layout: "content",
      scroller: false,
      controls_thumbnail: false,
      controls_class: "rock-controls-dark",
      progress: false
    });
    $('body').revelate();
    $('[data-visuallax]').visuallax();
    $('[data-href]').on('click', function() {
      window.location = $(this).find('a').attr('href');
    });
    enlarge_timeout = void 0;
    $('.header-link').on('mouseleave', function() {
      var button, link, slide;
      link = $( this );
      slide = link.closest('.rock-slider-slide');
      button = $('.header-btn', link);
      slide.removeClass('background-enlarge');
      button.removeClass('hover');
      $('.rock-slider').data('rock-slider').unpause_timer();
    });
    $(window).resize($.debounce((function(_this) {
      return function() {
        window_width = $(window).width();
        window_height = $(window).height();
        resize_header();
      };
    })(this), 10));
    $(window).resize(resize_header);
    $(window).scroll((function(_this) {
      return function() {
        var scroll_top, transform_navbar;
        scroll_top = $(_this).scrollTop();
        if (navbar) {
          if (scroll_top < 25) {
            transform_navbar = "translate3d(0," + (25 - scroll_top) + "px,0)";
            navbar.css({
              'transform': transform_navbar,
              '-o-transform': transform_navbar,
              '-ms-transform': transform_navbar,
              '-moz-transform': transform_navbar,
              '-webkit-transform': transform_navbar
            });
            navbar.addClass('navbar-transparent');
          } else if (navbar.hasClass('navbar-transparent')) {
            transform_navbar = "translate3d(0," + 0. + ",0)";
            navbar.css({
              'transform': transform_navbar,
              '-o-transform': transform_navbar,
              '-ms-transform': transform_navbar,
              '-moz-transform': transform_navbar,
              '-webkit-transform': transform_navbar
            });
            navbar.removeClass('navbar-transparent');
          }
        }
      };
    })(this)).trigger('scroll');
    $('ul.nav li.dropdown').hover((function() {
      if ($('.navbar-collapse').hasClass('collapse in')) {
        return;
      }
      $(this).addClass('open');
    }), function() {
      if ($('.navbar-collapse').hasClass('collapse in')) {
        return;
      }
      $(this).removeClass('open');
    });
    $('body').bind('click', function(e) {
      if ($(e.target).closest('.navbar').length === 0) {
        if ($('.navbar-collapse').hasClass('collapse in')) {
          jQuery('.navbar-collapse').collapse('hide');
        }
      }
    });
    if ($('#contact-form').length > 0) {
      name_input = $('#contact-name');
      email_input = $('#contact-email');
      subject_input = $('#contact-subject');
      message_input = $('#contact-message');
      remove_input_error = function(input) {
        input.parent().removeClass('has-error');
      };
      name_input.on('click', function() {
        return remove_input_error(name_input);
      });
      email_input.on('click', function() {
        return remove_input_error(email_input);
      });
      subject_input.on('click', function() {
        return remove_input_error(subject_input);
      });
      message_input.on('click', function() {
        return remove_input_error(message_input);
      });
      $('.contact-response').on('click', function() {
        $('.contact-response').velocity({
          opacity: 0
        }, {
          duration: 1000,
          complete: function() {
            return $('.contact-response').addClass('contact-hidden');
          }
        });
      });
      $('#contact-form').on('submit', (function(_this) {
        return function(e) {
          var email, error, message, name, ref, ref1, ref2, subject;
          error = false;
          name = name_input.val();
          email = email_input.val();
          subject = subject_input.val();
          message = message_input.val();
          if (!((3 < (ref = name.length) && ref < 64))) {
            name_input.parent().addClass('has-error');
            error = true;
          }
          if (!/[A-Z0-9._%+-]+\@[A-Z0-9.-]+\.[A-Z]+/i.test(email)) {
            email_input.parent().addClass('has-error');
            error = true;
          }
          if (!((16 < (ref1 = message.length) && ref1 < 5000))) {
            message_input.parent().addClass('has-error');
            error = true;
          }
          if (!((3 < (ref2 = subject.length) && ref2 < 64))) {
            subject_input.parent().addClass('has-error');
            error = true;
          }
          if (error) {
            e.preventDefault();
            return false;
          } else {
            $('#contact-form').ajaxSubmit({
              error: function() {
                return $('#contact-failure').removeClass('contact-hidden').velocity({
                  opacity: 1
                }, {
                  duration: 1000
                });
              },
              success: function() {
                return $('#contact-success').removeClass('contact-hidden').velocity({
                  opacity: 1
                }, {
                  duration: 1000
                });
              }
            });
            return false;
          }
        };
      })(this));
    }
    $('.navbar ul li a').on('click', function(e) {
      var target;
      target = $(e.currentTarget).attr('href');
      if (!/^\#/.test(target)) {
        return;
      }
      if ($(target).length > 0) {
        target = $(target);
      } else {
        window.location = '/rock-slider/' + target;
      }
      $("html").velocity("scroll", {
        offset: (target.offset().top) + "px",
        mobileHA: false
      });
      e.preventDefault();
    });
    $('[data-toggle="tooltip"]').tooltip();
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

//# sourceMappingURL=../src/maps/application/application.js.map
