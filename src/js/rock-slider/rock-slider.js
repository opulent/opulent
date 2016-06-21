
/*

                           dP
                           88
88d888b. .d8888b. .d8888b. 88  .dP
88'  `88 88'  `88 88'  `"" 88888"
88       88.  .88 88.  ... 88  `8b.
dP       `88888P' `88888P' dP   `YP
oooooooooooooooooooooooooooooooooooo

@plugin    jQuery
@license   CodeCanyon Standard / Extended
@author    Alex Grozav
@company   Pixevil
@website   http://pixevil.com
@email     alex@grozav.com
@guide
  Running rock-slider
    $('.rock-slider').rockSlider
      width: 1280
      height: 720
      layout: 'layout_name'

  Using methods
    $('.rock-slider').data('rock-slider').method_name()

  Adding events
    $('.rock-slider').on 'event_name', ->
 */

(function() {
  (function($, window, document) {
    "use strict";
    $.rockSlider = function(element, options) {
      var _defaults, video_timeline;
      _defaults = {
        width: 1280,
        height: 720,
        animation: {
          "in": "opacity 0",
          out: "fade out",
          easing: "swing",
          duration: 500
        },
        delay: 4000,
        overlap: 1,
        layout: "default",
        layout_settings: {},
        layer_index: 99,
        autoplay: true,
        pause_on_hover: false,
        loop: true,
        preload: 1,
        content_scaling: false,
        content_scaling_factor: {
          xs: 1,
          sm: 1,
          md: 1,
          lg: 1,
          xlg: 1
        },
        content_width: null,
        content_parallax: true,
        content_parallax_data: {
          mode: 'from-middle',
          transform: {
            translateY: 0.6,
            opacity: 0.4
          },
          transform_style: {
            opacity: 'default'
          }
        },
        grid: {
          rows: 1,
          columns: 1,
          stagger: 100
        },
        canvas_parallax: true,
        canvas_parallax_data: {
          transform: {
            translateY: 0.2
          }
        },
        canvas_parallax_layers: true,
        touch: true,
        keyboard: true,
        mousewheel: false,
        prevent_scrolling: true,
        loader: true,
        retina: true,
        scroller: false,
        scroller_markup: "<span class=\"rock-scroller-1\"></span>",
        scroller_position: "center",
        progress: true,
        progress_position: "bottom",
        progress_class: "rock-progress-light",
        thumbnails: false,
        thumbnails_visible: {
          xs: 3,
          sm: 4,
          md: 5,
          lg: 6,
          xlg: 8
        },
        thumbnails_position: "after",
        thumbnails_orientation: "horizontal",
        thumbnails_class: "",
        controls: true,
        controls_thumbnail: true,
        controls_html: {
          prev: "&lt;",
          next: "&gt;"
        },
        controls_class: "rock-controls-alternate",
        pagination: false,
        pagination_position: "inside",
        pagination_class: "rock-pagination-light",
        prevent_dragging: true,
        retina: true,
        screen_size: {
          xs: 0,
          sm: 768,
          md: 992,
          lg: 1200,
          xlg: 1840
        },
        selector: {
          slide: ".rock-slide",
          content: ".rock-content",
          background: ".rock-background",
          video_background: ".rock-video-background",
          video: ".rock-video",
          video_cover: ".rock-video-cover",
          layer: ".rock-layer",
          object: ".rock-object",
          next: ".rock-next",
          prev: ".rock-prev",
          outer: ".rock-outer",
          inner: ".rock-inner"
        }
      };
      this.debug = false;
      this._defaults = _defaults;
      this.settings = $.extend({}, _defaults, options);
      this.settings.content_scaling_factor = $.extend({}, this._defaults.content_scaling_factor, this.settings.content_scaling_factor);
      this.context = $(element);
      this.animation = {};
      this.element = $(element);
      this.parent = this.element.parent();
      this.current = -1;
      this.id = this.element.attr('id') != null ? this.element.attr('id') : 'rock-' + Math.floor((Math.random() * 1000) + 1);
      this.window = $(window);
      this.cache = {};
      this.youtube_player = {};
      this.vimeo_player = {};
      this.timer = {};
      this.timer.timeout = null;
      this.timer.start = 0;
      this.timer.remaining = 0;
      this.initialize = (function(_this) {
        return function() {
          if (_this.settings.retina) {
            _this.check_retina;
          }
          if (_this.settings.loader) {
            _this.add_loader();
          }
          _this.init_animus();
          _this.set_data_settings();
          _this.add_classes();
          _this.wrap_objects();
          _this.inner = $(_this.settings.selector.slide, _this.element);
          _this.outer = $(_this.settings.selector.outer, _this.element);
          _this.slides = $(_this.settings.selector.slide, _this.element);
          _this.slides_length = _this.slides.length;
          _this.active = _this.slides.eq(0);
          _this.window_width = _this.window.width();
          _this.window_height = _this.window.height();
          _this.visible_width = _this.window_width;
          _this.visible_height = _this.window_height;
          _this.parent_width = _this.parent.width();
          _this.parent_height = _this.parent.height();
          _this.element_width = _this.parent_width;
          _this.element_height = _this.element_width / _this.settings.width * _this.settings.height;
          _this.set_responsive_context();
          _this.setup_layers();
          _this.setup_videos();
          _this.bind_resize();
          if (_this.settings.prevent_dragging === true) {
            _this.prevent_dragging();
          }
          _this.load(function() {
            if (_this.settings.pause_on_hover === true) {
              _this.enable_pause_on_hover();
            }
            if (_this.settings.touch === true) {
              _this.enable_touch();
            }
            if (_this.settings.mousewheel === true) {
              _this.enable_mousewheel();
            }
            if (_this.settings.keyboard === true) {
              _this.enable_keyboard();
            }
            _this.scale_content();
            _this.setup();
            if (_this.settings.progress === true) {
              _this.add_progress_bar();
            }
            if (_this.settings.thumbnails === true) {
              _this.add_thumbnails();
            }
            if (_this.settings.scroller === true) {
              _this.add_scroller();
            }
            if (_this.settings.pagination === true) {
              _this.add_pagination();
            }
            if (_this.settings.controls === true) {
              _this.add_controls();
            }
            if (_this.settings.content_scaling) {
              _this.setup_scaling();
            }
            _this.setup_grid();
            _this.bind_scroll();
            _this.refresh();
            if (_this.settings.content_parallax) {
              _this.enable_content_parallax();
            }
            _this.enable_canvas_parallax();
            _this.hide_loader();
            setTimeout((function() {
              return _this.slide(0);
            }), 500);
            _this.element.trigger("rock-slider.load");
          });
          if (_this.debug) {
            console.log(_this.cache);
          }
        };
      })(this);
      this.load = function(callback) {
        var i;
        i = 0;
        if (this.settings.preload < this.slides_length) {
          this.settings.preload = this.slides_length;
        }
        this.slides.each((function(_this) {
          return function(index, el) {
            var $slide;
            $slide = $(el);
            $slide.imagesLoaded().always(function() {
              var $background, $layers, layer_delay, layer_start, objects, thumbnail;
              $background = $(_this.settings.selector.background, $slide);
              $layers = $(_this.settings.selector.layer, $slide);
              objects = $(_this.settings.selector.object, $slide);
              _this.cache[index] = {};
              _this.cache[index].layer = {};
              _this.cache[index].object = {};
              _this.cache[index].background = {
                0: _this.get_data($slide, $background, 'background', _this.settings.delay)
              };
              layer_delay = _this.cache[index].background[0].delay - (_this.cache[index].background[0].animation[0].duration / 2);
              layer_start = _this.cache[index].background[0].animation[_this.cache[index].background[0].start].duration;
              $layers.each(function(layer_index, layer) {
                var $layer, image;
                $layer = $(layer);
                image = null;
                if ($layer.is('img')) {
                  image = $(layer);
                }
                _this.cache[index].layer[layer_index] = _this.get_data($layer, image, 'layer', layer_delay, layer_start);
              });
              objects.each(function(object_index, object) {
                object = $(object);
                _this.cache[index].object[object_index] = _this.get_data(object, null, 'object', layer_delay, layer_start);
              });
              thumbnail = $slide.attr('data-rock-thumbnail');
              if (thumbnail) {
                _this.cache[index].thumbnail = thumbnail;
              } else {
                _this.cache[index].thumbnail = $background.attr('src');
              }
              if (index < _this.settings.preload) {
                i++;
              }
              if (i === _this.settings.preload) {
                _this.element.addClass('rock-loaded');
                callback.call();
              }
            });
          };
        })(this));
      };
      this.get_data = function(object, image, type, default_delay, default_start) {
        var animation_stack, canvas_parallax_data, columns, data, delay, end_time, i, initial_animation_override, initial_state, last_time, out_animation, rows, stagger, start, starting_animation, string, time_stack, timeline;
        string = '';
        time_stack = [];
        animation_stack = {};
        i = 0;
        data = {};
        data.type = type;
        data.animation = {};
        if (image !== null && image.get(0)) {
          data.width = image.get(0).naturalWidth;
          if (data.width == null) {
            data.width = image.get(0).width;
            if (data.width == null) {
              data.width = image.width();
              if (data.width == null) {
                data.width = this.settings.width;
              }
            }
          }
          data.height = image.get(0).naturalHeight;
          if (data.height == null) {
            data.height = image.get(0).height;
            if (data.height == null) {
              data.height = image.height();
              if (data.height == null) {
                data.height = this.settings.height;
              }
            }
          }
        } else {
          data.width = 'auto';
          data.height = 'auto';
        }
        if (type === 'layer') {
          data.position = {};
          if (object.attr('data-rock-top') != null) {
            data.position.top = parseFloat(object.attr('data-rock-top'));
          } else if (object.attr('data-rock-bottom') != null) {
            data.position.bottom = parseFloat(object.attr('data-rock-bottom'));
          } else {
            data.position.top = 0;
          }
          if (object.attr('data-rock-left') != null) {
            data.position.left = parseFloat(object.attr('data-rock-left'));
          } else if (object.attr('data-rock-right') != null) {
            data.position.right = parseFloat(object.attr('data-rock-right'));
          } else {
            data.position.left = 0;
          }
          if (object.attr('data-rock-width') != null) {
            data.width = parseFloat(object.attr('data-rock-width'));
          }
          if (object.attr('data-rock-height') != null) {
            data.height = parseFloat(object.attr('data-rock-height'));
          }
        }
        canvas_parallax_data = object.attr('data-rock-parallax');
        data.canvas_parallax_data = {};
        if (canvas_parallax_data != null) {
          if (canvas_parallax_data === 'false') {
            data.canvas_parallax = false;
          } else {
            data.canvas_parallax = true;
            data.canvas_parallax_data.transform = {};
            data.canvas_parallax_data.transform.translateY = parseFloat(canvas_parallax_data);
          }
        } else {
          data.canvas_parallax = this.settings.canvas_parallax;
          if (this.settings.canvas_parallax) {
            data.canvas_parallax_data = this.settings.canvas_parallax_data;
          }
        }
        start = object.attr('data-rock-start') != null ? parseInt(object.attr('data-rock-start'), 10) : type === 'background' ? 0 : default_start;
        data.start = start;
        initial_state = object.attr('data-rock');
        if (initial_state == null) {
          initial_state = object.attr('data-rock-initial');
        }
        if (initial_state != null) {
          starting_animation = initial_state;
        } else if (type === 'background') {
          starting_animation = this.settings.animation["in"];
        } else {
          starting_animation = '';
        }
        animation_stack[start] = starting_animation;
        time_stack[i++] = start;
        initial_animation_override = object.attr('data-rock-in') != null ? this.animus.get(object.attr('data-rock-in')) : false;
        timeline = object.data();
        $.each(timeline, function(key, value) {
          var at_time, time;
          time = void 0;
          if ((time = key.match(/rockAt([0-9]+)/)) !== null) {
            at_time = parseInt(time[1], 10);
            animation_stack[at_time] = value;
            time_stack[i++] = at_time;
          }
        });
        last_time = 0;
        time_stack.sort();
        $.each(time_stack, (function(_this) {
          return function(key, value) {
            data.animation[time_stack[key]] = _this.animus.get(animation_stack[time_stack[key]]);
            if (value > last_time) {
              last_time = value;
            }
          };
        })(this));
        data.grid = {
          enabled: false
        };
        if (type === 'background') {
          rows = object.attr('data-rock-grid-rows');
          data.grid.rows = rows != null ? parseInt(rows, 10) : this.settings.grid.rows;
          columns = object.attr('data-rock-grid-columns');
          data.grid.columns = columns != null ? parseInt(columns, 10) : this.settings.grid.columns;
          stagger = object.attr('data-rock-grid-stagger');
          data.grid.stagger = stagger != null ? parseInt(stagger, 10) : this.settings.grid.stagger;
          if (data.grid.columns > 1 || data.grid.rows > 1) {
            data.grid.enabled = true;
            object.addClass('rock-grid-slide');
          }
        }
        delay = object.attr('data-rock-delay');
        if (delay != null) {
          data.delay = parseInt(delay, 10) + parseInt(data.animation[start].duration, 10);
        } else if (this.settings.autoplay === false) {
          data.delay = 99999;
        } else {
          data.delay = parseInt(default_delay, 10) + parseInt(data.animation[start].duration, 10);
        }
        out_animation = object.attr('data-rock-out');
        out_animation = out_animation != null ? out_animation : type === 'background' ? this.settings.animation.out : '';
        if (out_animation !== '') {
          end_time = type === 'background' ? data.delay > last_time + data.animation[last_time].duration ? data.delay : last_time + data.animation[last_time].duration : delay;
          data.animation[end_time] = this.animus.get(out_animation);
        }
        if ($.type(data.animation[start].state) !== 'string') {
          if (!('opacity' in data.animation[start].state)) {
            data.animation[start].state.opacity = 0;
          }
          data.animation[start].state = this.animus.reset(data.animation[start].state, data, true);
          data.default_state = this.animus.reset(initial_animation_override.state, data, true);
          data.initial_state = data.animation[start].state;
          data.animation[start].state = this.animus.forcefeed(data.animation[start].state, initial_animation_override.state);
        }
        data.loop = object.attr('data-rock-loop') != null ? last_time + data.animation[last_time].duration + 1 : false;
        return data;
      };
      this.slide = function(i) {
        var from, next, prev;
        from = this.current;
        next = i + 1 > this.slides_length - 1 ? 0 : i + 1;
        prev = i - 1 < 0 ? this.slides_length - 1 : i - 1;
        if (i === this.current) {
          return;
        }
        if (i > this.slides_length - 1) {
          i = 0;
        }
        if (i < 0) {
          i = this.slides_length - 1;
        }
        $('.previous', this.element).removeClass('previous');
        this.slides.eq(prev).addClass('previous');
        $('.active', this.element).removeClass('active');
        this.active = this.slides.eq(i);
        this.active.addClass('active');
        $('.next', this.element).removeClass('next');
        this.slides.eq(next).addClass('next');
        if (this.current !== -1) {
          this.clear_timeouts(this.current);
        }
        this.clear_timeouts(i);
        this.layout[this.settings.layout].slide.call(this, i, this.current);
        this.animate(i, this.current);
        this.current = i;
        if (this.settings.autoplay === true) {
          this.timer.start = new Date;
          this.timer.remaining = this.cache[i].background[0].delay;
          clearTimeout(this.timer.clock);
          this.timer.clock = setTimeout(((function(_this) {
            return function() {
              if (_this.settings.loop !== true && i + 1 === _this.slides_length - 1) {
                return;
              }
              _this.slide(i + 1);
            };
          })(this)), this.timer.remaining);
        }
        if (this.settings.progress === true) {
          this.progress.bar.velocity('stop').velocity({
            width: '0%'
          }, 0).velocity({
            width: '100%'
          }, this.timer.remaining);
        }
        if (this.settings.controls === true && this.settings.controls_thumbnail === true) {
          this.prev_thumbnail.attr('src', this.cache[prev].thumbnail);
          this.next_thumbnail.attr('src', this.cache[next].thumbnail);
        }
        if (this.settings.pagination) {
          this.pagination.filter('.active').removeClass('active');
          this.pagination.eq(i).addClass('active');
        }
        if (this.settings.thumbnails) {
          this.thumbnails.elements.filter('.active').removeClass('active');
          this.thumbnails.elements.eq(i).addClass('active');
          this.scroll_to_thumbnail(i);
        }
        this.handle_videos(from, i);
        this.element.trigger('rock-slider.change', [prev, this.current, next, this.slides_length, this.active]);
      };
      this.animate = (function(_this) {
        return function(i, prev) {
          var $active, $prev, $prev_layers, $prev_objects, prev_animation_out, prev_stagger, prev_target, previous_delay, timeout;
          $active = _this.slides.eq(i);
          prev_stagger = 0;
          clearTimeout(_this.animate_timeout);
          if (prev !== -1 && _this.settings.layout_settings.animate_background !== false) {
            $prev = _this.slides.eq(prev);
            $prev_layers = $('.rock-layer-wrapper', $prev);
            $prev_objects = $(_this.settings.selector.object, $prev);
            previous_delay = _this.cache[prev].background[0].delay;
            $(".rock-content-wrapper, " + _this.settings.selector.layer, $prev).velocity({
              opacity: 0
            }, _this.cache[prev].background[0].animation[previous_delay].duration);
            if (!$.isEmptyObject(_this.cache[prev].background[0].animation[previous_delay].state)) {
              prev_target = $prev;
              options = {
                duration: _this.cache[prev].background[0].animation[previous_delay].duration,
                easing: _this.cache[prev].background[0].animation[previous_delay].easing,
                display: null,
                complete: function() {
                  $prev.velocity('stop');
                  $prev_layers.velocity('stop');
                  $prev_objects.velocity('stop');
                }
              };
              if (_this.cache[prev].background[0].grid.enabled) {
                options.stagger = _this.cache[prev].background[0].grid.stagger;
                prev_target = $('.rock-grid-cell', $prev);
                $.Velocity.hook($('.rock-grid', $active), 'opacity', 1);
                $.Velocity.hook($('.rock-grid-cell', $active), 'opacity', 0);
                $.Velocity.hook($('.rock-grid', $prev), 'opacity', 1);
                $('.rock-background-main', $prev).velocity({
                  opacity: 0
                }, 20);
                if ($.type(_this.cache[prev].background[0].animation[previous_delay].state) === 'string') {
                  prev_stagger += $('.rock-grid-cell', $prev).length * _this.cache[prev].background[0].grid.stagger;
                }
              }
              prev_target.velocity(_this.cache[prev].background[0].animation[previous_delay].state, options);
            }
          }
          if (prev === -1) {
            timeout = prev_stagger;
          } else {
            if (_this.cache[prev].background[0].animation[previous_delay]) {
              prev_animation_out = _this.cache[prev].background[0].animation[previous_delay].duration;
            } else {
              prev_animation_out = 0;
            }
            timeout = prev_animation_out + prev_stagger;
          }
          timeout *= _this.settings.overlap;
          $.Velocity.hook($('.rock-background-main', $active), 'opacity', 0);
          _this.animate_timeout = setTimeout(function() {
            var $layers, $objects;
            $layers = $('.rock-layer-wrapper', $active);
            $objects = $(_this.settings.selector.object, $active);
            $(".rock-content-wrapper, " + _this.settings.selector.layer, $active).velocity({
              opacity: 1
            }, _this.cache[i].background[0].animation[_this.cache[i].background[0].start].duration);
            if (_this.settings.layout_settings.animate_background !== false) {
              if (_this.cache[i].background[0].grid.enabled) {
                _this.run_grid_animation(i, $('.rock-grid-cell', $active), 'background', 0, false);
              } else {
                _this.run_animation(i, $active, 'background', 0, false);
              }
            }
            $layers.each(function(layer_index, layer) {
              return _this.run_animation(i, $(layer), 'layer', layer_index, false);
            });
            $objects.each(function(object_index, object) {
              return _this.run_animation(i, $(object), 'object', object_index, false);
            });
          }, timeout);
        };
      })(this);
      this.run_grid_animation = (function(_this) {
        return function(i, $element, context, context_index, in_loop) {
          var $active;
          $active = _this.slides.eq(i);
          _this.run_animation(i, $element, context, context_index, in_loop, function() {
            $.Velocity.hook($('.rock-background-main', $active), 'opacity', 1);
            $('.rock-grid', $active).velocity({
              opacity: 0
            }, 20);
          });
        };
      })(this);
      this.run_animation = (function(_this) {
        return function(i, $element, context, context_index, in_loop, callback) {
          var current_delay;
          current_delay = _this.cache[i].background[0].delay;
          if (!(in_loop || (_this.cache[i][context][context_index].initial_state == null))) {
            $element.velocity(_this.cache[i][context][context_index].initial_state, {
              duration: 1
            });
          }
          $.each(_this.cache[i][context][context_index].animation, function(index) {
            if (index >= current_delay || isNaN(index) || $.isEmptyObject(_this.cache[i][context][context_index].animation[index].state)) {
              return;
            }
            _this.cache[i][context][context_index].animation[index].timeline = setTimeout((function() {
              options = {
                duration: _this.cache[i][context][context_index].animation[index].duration,
                easing: _this.cache[i][context][context_index].animation[index].easing,
                display: null
              };
              if (_this.cache[i][context][context_index].grid.enabled) {
                options.stagger = _this.cache[i][context][context_index].grid.stagger;
                if ((callback != null) && parseInt(index) === _this.cache[i][context][context_index].start) {
                  options.complete = callback;
                }
              }
              $element.velocity(_this.cache[i][context][context_index].animation[index].state, options);
            }), index);
          });
          if (_this.cache[i][context][context_index].loop) {
            _this.cache[i][context][context_index].loop_timeout = setTimeout(function() {
              return _this.run_animation(i, $element, context, context_index, true);
            }, _this.cache[i][context][context_index].loop);
          }
        };
      })(this);
      this.setup = (function(_this) {
        return function() {
          var max_tries, tries, try_interval;
          _this.layout = {};
          $.each($.rockSlider.layouts, function(index, value) {
            _this.layout[index] = new value;
          });
          if (_this.layout[_this.settings.layout]) {
            _this.layout[_this.settings.layout].init.call(_this);
          } else {
            tries = 0;
            max_tries = 6;
            try_interval = setInterval(function() {
              $.each($.rockSlider.layouts, function(index, value) {
                if (index in _this.layout) {
                  return;
                }
                _this.layout[index] = new value;
              });
              if (_this.layout[_this.settings.layout]) {
                _this.layout[_this.settings.layout].init.call(_this);
                clearInterval(try_interval);
                return;
              }
              if (tries === max_tries) {
                clearInterval(try_interval);
                console.error("RockSlider couldn't find any \"" + _this.settings.layout + "\" layout.");
              }
              return tries += 1;
            }, 500);
          }
          if (_this.layout.length === 0) {
            console.error("RockSlider couldn't find any valid layouts.");
          }
        };
      })(this);
      this.setup_layout = (function(_this) {
        return function() {
          _this.layout[_this.settings.layout].setup.call(_this);
        };
      })(this);
      this.resize_layout = (function(_this) {
        return function() {
          if (_this.layout[_this.settings.layout].resize) {
            _this.layout[_this.settings.layout].resize.call(_this);
          }
        };
      })(this);
      this.init_animus = (function(_this) {
        return function() {
          var override;
          override = {
            duration: _this.settings.animation.duration,
            easing: _this.settings.animation.easing
          };
          _this.animus = new $.animus(override);
        };
      })(this);
      this.add_loader = (function(_this) {
        return function() {
          var html;
          if ($(".rock-loader-wrapper", _this.element).length === 0) {
            html = "";
            html += '<div class="rock-loader-wrapper">';
            html += '<div class="rock-loader">';
            html += '<div class="rock-loader-inner">';
            html += '<div class="rock-loader-tile"></div>';
            html += '<div class="rock-loader-tile"></div>';
            html += '<div class="rock-loader-tile"></div>';
            html += '<div class="rock-loader-tile"></div>';
            html += '<div class="rock-loader-tile"></div>';
            html += '</div>';
            html += '</div>';
            html += '<div class="rock-loader-text">';
            html += '<h5 class="rock-loader-title font-normal">';
            html += 'SLIDEA';
            html += '</h5>';
            html += '<h6 class="rock-loader-subtitle font-thin">';
            html += 'A Smarter Slider Plugin';
            html += '</h6>';
            html += '</div>';
            html += '</div>';
            _this.element.prepend(html);
          }
        };
      })(this);
      this.hide_loader = (function(_this) {
        return function() {
          $(".rock-loader-wrapper", _this.element).velocity({
            scale: 1.5,
            opacity: 0
          }, {
            display: "none"
          }, {
            duration: 600
          });
        };
      })(this);
      this.set_data_settings = (function(_this) {
        return function() {
          if (_this.element.attr("data-rock-width") != null) {
            _this.settings.width = _this.element.attr("data-rock-width");
          }
          if (_this.element.attr("data-rock-height") != null) {
            _this.settings.height = _this.element.attr("data-rock-height");
          }
          if (_this.element.attr("data-rock-animation-initial") != null) {
            _this.settings.animation.initial = _this.element.attr("data-rock-initial");
          }
          if (_this.element.attr("data-rock-animation-out") != null) {
            _this.settings.animation.out = _this.element.attr("data-rock-out");
          }
          if (_this.element.attr("data-rock-duration") != null) {
            _this.settings.animation.duration = _this.element.attr("data-rock-duration");
          }
          if (_this.element.attr("data-rock-easing") != null) {
            _this.settings.animation.easing = _this.element.attr("data-rock-easing");
          }
          if (_this.element.attr("data-rock-delay") != null) {
            _this.settings.delay = _this.element.attr("data-rock-delay");
          }
          if (_this.element.attr("data-rock-layout") != null) {
            _this.settings.layout = _this.element.attr("data-rock-layout");
          }
        };
      })(this);
      this.add_classes = (function(_this) {
        return function() {};
      })(this);
      this.wrap_objects = (function(_this) {
        return function() {
          $(_this.settings.selector.slide, _this.element).each(function(i, slide) {
            return $(_this.settings.selector.background + ', ' + _this.settings.selector.layer, $(slide)).wrapAll("<div class=\"rock-canvas\"></div>");
          }).wrapAll("<div class=\"rock-outer\"><div class=\"rock-inner\"></div></div>");
          $(_this.settings.selector.content, _this.element).wrap('<div class="rock-content-wrapper"></div>');
          $(_this.settings.selector.background, _this.element).wrap('<div class="rock-background-wrapper"></div>');
          $(_this.settings.selector.layer, _this.element).wrap('<div class="rock-layer-wrapper"></div>');
        };
      })(this);
      this.setup_layers = (function(_this) {
        return function() {
          _this.slides.each(function(si, slide) {
            var layer_count, layers;
            layers = $(".rock-layer-wrapper", $(slide));
            layer_count = layers.length;
            return layers.each(function(li, layer) {
              return $(layer).css("z-index", _this.settings.layer_index + layer_count - li);
            });
          });
        };
      })(this);
      this.setup_videos = (function(_this) {
        return function() {
          var delay, i, interval, tries;
          delay = 500;
          interval = void 0;
          i = 0;
          tries = 10;
          $('.rock-video-background').each(function(index, background) {
            if (!$(background).hasClass('rock-object')) {
              $(background).addClass('rock-object');
            }
          });
          $("video.rock-video", _this.element).attr("data-rock-video-type", "html5");
          $("iframe[data-rock-src*=\"youtube.com\"].rock-video", _this.element).attr("data-rock-video-type", "youtube");
          $("iframe[data-rock-src*=\"vimeo.com\"].rock-video", _this.element).attr("data-rock-video-type", "vimeo");
          $(_this.settings.selector.video, _this.element).each(function(i, el) {
            var $video, controls, id, pause_slider, random_id, separator, src, video_id, volume;
            $video = $(el);
            volume = $video.attr("data-rock-volume");
            controls = $video.attr("data-rock-controls") === "true";
            pause_slider = $video.attr("data-rock-pause-slider") === "true";
            random_id = "rock-video-" + Math.floor((Math.random() * 1000) + 1);
            volume = (isNaN(volume) ? 0 : volume);
            if ($video.attr("id") == null) {
              $video.attr("id", random_id);
            }
            id = $video.attr("id");
            src = $video.attr("data-rock-src");
            if ($video.attr("data-rock-video-type") === "html5") {
              $video.get(0).volume = volume;
              if (controls === true) {
                $video.attr("controls", "controls");
              }
              if (_this.settings.autoplay === true && pause_slider === true) {
                $video.on("play", function() {
                  _this.pause_timer();
                });
                $video.on("pause ended", function() {
                  _this.unpause_timer();
                });
              }
            }
            if ($video.attr("data-rock-video-type") === "youtube") {
              video_id = void 0;
              separator = void 0;
              if (src.indexOf("enablejsapi=1") === -1) {
                if (src.indexOf("?") === -1) {
                  $video.attr("src", src + "?enablejsapi=1");
                } else {
                  $video.attr("src", src + "&enablejsapi=1");
                }
                src = $video.attr("src");
              }
              if (src.indexOf("playerapiid=") === -1) {
                if (src.indexOf("?") === -1) {
                  $video.attr("src", src + "?playerapiid=" + id);
                } else {
                  $video.attr("src", src + "&playerapiid=" + id);
                }
                src = $video.attr("src");
              }
              if (src.indexOf("embed") !== "-1") {
                video_id = src.split("/");
                video_id = video_id[video_id.length - 1];
                separator = video_id.indexOf("?");
                if (separator !== -1) {
                  video_id = video_id.substring(0, separator);
                }
              } else {
                video_id = src.split("v=")[1];
                separator = video_id.indexOf("&");
                if (separator !== -1) {
                  video_id = video_id.substring(0, separator);
                }
              }
              $video.load(function() {
                _this.youtube_player[id] = new YT.Player(id, {
                  height: "720",
                  width: "1280",
                  video_id: video_id,
                  events: {
                    onStateChange: function(e) {
                      if (e.data === 1) {
                        _this.pause_timer();
                      }
                      if (e.data === 2 || e.data === 0) {
                        return _this.unpause_timer();
                      }
                    }
                  }
                });
                i = 0;
                interval = setInterval(function() {
                  i++;
                  if (i === tries) {
                    clearInterval(interval);
                  } else if ((_this.youtube_player[id] == null) || typeof _this.youtube_player[id].setVolume !== "function") {
                    return;
                  } else {
                    clearInterval(interval);
                  }
                  return _this.youtube_player[id].setVolume(volume);
                }, delay);
              });
            }
            if ($video.attr("data-rock-video-type") === "vimeo") {
              if (src.indexOf("api=1") === -1) {
                if (src.indexOf("?") === -1) {
                  $video.attr("src", src + "?api=1");
                } else {
                  $video.attr("src", src + "&api=1");
                }
                src = $video.attr("src");
              }
              if (src.indexOf("player_id=") === -1) {
                if (src.indexOf("?") === -1) {
                  $video.attr("src", src + "?player_id=" + id);
                } else {
                  $video.attr("src", src + "&player_id=" + id);
                }
                src = $video.attr("src");
              }
              $video.load(function() {
                _this.vimeo_player[id] = $f(id);
                _this.vimeo_player[id].addEvent("ready", function() {
                  $video.attr("data-rock-ready", "true");
                  _this.vimeo_player[id].api("setVolume", volume);
                  if (_this.settings.autoplay === true && pause_slider === true) {
                    _this.vimeo_player[id].addEvent("play", _this.pause_timer);
                    _this.vimeo_player[id].addEvent("pause", _this.unpause_timer);
                    return _this.vimeo_player[id].addEvent("finish", _this.unpause_timer);
                  }
                });
              });
            }
          });
          $(_this.settings.selector.video_cover, _this.element).each(function(i, el) {
            var $cover, $parent, $video, id, type;
            $cover = $(el);
            $parent = $cover.parent();
            $video = $(_this.settings.selector.video, $parent);
            type = $video.attr("data-rock-video-type");
            id = $video.attr("id");
            switch (type) {
              case "html5":
                $cover.on("click", function() {
                  $video.get(0).play();
                  $cover.velocity("fadeOut");
                });
                break;
              case "youtube":
                $cover.on("click", function() {
                  _this.youtube_player[id].playVideo();
                  $cover.velocity("fadeOut");
                });
                break;
              case "vimeo":
                $cover.on("click", function() {
                  _this.vimeo_player[id].api("play");
                  $cover.velocity("fadeOut");
                });
            }
          });
        };
      })(this);
      video_timeline = {};
      this.handle_videos = function(previous, current) {
        var $current, $previous;
        $previous = this.slides.eq(previous);
        $current = this.slides.eq(current);
        if (previous !== -1) {
          $(this.settings.selector.video, $previous).each((function(_this) {
            return function() {
              var $video, id, reset;
              $video = $( this );
              id = $video.attr('id');
              reset = $video.attr('data-rock-reset') === 'true';
              clearTimeout(video_timeline[id]);
              if ($video.attr('data-rock-video-type') === 'html5') {
                $video.get(0).pause();
                if (reset) {
                  setTimeout((function() {
                    $video.get(0).current_time = 0;
                  }), _this.cache[current].background[0].animation[0].duration);
                }
              }
              if ($video.attr('data-rock-video-type') === 'youtube') {
                _this.youtube_player[id].pauseVideo();
                if (reset) {
                  setTimeout((function() {
                    _this.youtube_player[id].stopVideo();
                  }), _this.cache[current].background[0].animation[0].duration);
                }
              }
              if ($video.attr('data-rock-video-type') === 'vimeo') {
                _this.vimeo_player[id].api('pause');
                if (reset) {
                  setTimeout((function() {
                    _this.vimeo_player[id].api('unload');
                  }), _this.cache[current].background[0].animation[0].duration);
                }
              }
            };
          })(this));
        }
        $(this.settings.selector.video, $current).each((function(_this) {
          return function() {
            var $video, autoplay, autoplay_time, delay, i, id, interval, pause_slider, tries;
            $video = $( this );
            id = $video.attr('id');
            delay = 500;
            interval = void 0;
            i = 0;
            tries = 10;
            autoplay = $video.attr('data-rock-autoplay') === 'true';
            autoplay_time = $video.attr('data-rock-autoplay-time') != null ? parseInt($video.attr('data-rock-autoplay-time'), 10) : 100;
            pause_slider = $video.attr('data-rock-pause-slider') === 'true';
            if ($video.attr('data-rock-video-type') === 'html5') {
              if (autoplay === true) {
                video_timeline[id] = setTimeout((function() {
                  $video.get(0).play();
                }), autoplay_time);
              }
            }
            if ($video.attr('data-rock-video-type') === 'youtube') {
              if (autoplay === true) {
                i = 0;
                interval = setInterval((function() {
                  i++;
                  if (i === tries) {
                    clearInterval(interval);
                  } else if (!defined(_this.youtube_player[id]) || typeof _this.youtube_player[id].playVideo !== 'function') {
                    return;
                  } else {
                    clearInterval(interval);
                  }
                  video_timeline[id] = setTimeout((function() {
                    _this.youtube_player[id].playVideo();
                  }), autoplay_time);
                }), delay);
              }
            }
            if ($video.attr('data-rock-video-type') === 'vimeo') {
              if (autoplay === true) {
                i = 0;
                interval = setInterval((function() {
                  i++;
                  if (i === tries) {
                    clearInterval(interval);
                  } else if (($video.attr('data-rock-ready') == null) || typeof _this.vimeo_player[id].api !== 'function') {
                    return;
                  } else {
                    clearInterval(interval);
                  }
                  video_timeline[id] = setTimeout((function() {
                    Froogaloop(id).api('play');
                  }), autoplay_time);
                }), delay);
              }
            }
          };
        })(this));
      };
      this.refresh = (function(_this) {
        return function() {
          _this.window_width = _this.window.width();
          _this.window_height = _this.window.height();
          _this.parent_width = _this.parent.width();
          _this.parent_height = _this.parent.height();
          _this.element_width = _this.parent_width;
          _this.element_height = _this.element_width / _this.settings.width * _this.settings.height;
          _this.setup_content();
          _this.setup_layout();
          _this.resize_grid();
          if (_this.settings.thumbnails === true) {
            _this.resize_thumbnails();
          }
        };
      })(this);
      this.bind_resize = (function(_this) {
        return function() {
          _this.window.resize(function() {
            _this.refresh();
            _this.resize_layout();
            _this.set_responsive_context();
            _this.element.trigger('rock-slider.resize', [_this.window_width, _this.window_height, _this.current_responsive_size]);
          });
        };
      })(this);
      this.set_responsive_context = (function(_this) {
        return function() {
          if (_this.window_width >= _this.settings.screen_size.xlg) {
            _this.current_responsive_size = 'xlg';
          } else if (_this.window_width >= _this.settings.screen_size.lg) {
            _this.current_responsive_size = 'lg';
          } else if (_this.window_width >= _this.settings.screen_size.md) {
            _this.current_responsive_size = 'md';
          } else if (_this.window_width >= _this.settings.screen_size.sm) {
            _this.current_responsive_size = 'sm';
          } else {
            _this.current_responsive_size = 'xs';
          }
        };
      })(this);
      this.bind_scroll = (function(_this) {
        return function() {
          _this.window.on('scroll', function() {});
        };
      })(this);
      this.enable_content_parallax = function() {
        $(this.settings.selector.content, this.element).each((function(_this) {
          return function(index, element) {
            var settings;
            settings = $.extend({}, _this.settings.content_parallax_data, {
              reset: true,
              source: _this.outer
            });
            $(element).visuallax(settings);
          };
        })(this));
      };
      this.enable_canvas_parallax = function() {
        this.slides.each((function(_this) {
          return function(index, slide) {
            var settings;
            settings = $.extend({}, _this.settings.canvas_parallax_data, {
              parent: _this.outer,
              source: _this.inner,
              reset: true
            });
            if (_this.cache[index].background[0].canvas_parallax) {
              $('.rock-background-wrapper', $(slide)).visuallax(settings);
              if (_this.settings.canvas_parallax_layers) {
                $(_this.settings.selector.layer, $(slide)).each(function(li, layer) {
                  if (_this.cache[index].layer[li].canvas_parallax) {
                    settings = $.extend({}, _this.cache[index].layer[li].canvas_parallax_data, {
                      parent: _this.outer,
                      source: _this.inner,
                      reset: true
                    });
                    $(layer).visuallax(settings);
                  }
                });
              }
            }
          };
        })(this));
      };
      this.add_progress_bar = (function(_this) {
        return function() {
          var html, position;
          position = (_this.settings.progress_position === "top" ? "rock-progress-top" : "rock-progress-bottom");
          html = "";
          html += "<div class=\"rock-progress " + position + " " + _this.settings.progress_class + "\">";
          html += "<div class=\"rock-progress-bar\">";
          html += "</div>";
          html += "</div>";
          _this.element.prepend(html);
          _this.progress = {};
          _this.progress.element = $(".rock-progress", _this.element);
          _this.progress.bar = $(".rock-progress-bar", _this.element);
        };
      })(this);
      this.prevent_dragging = (function(_this) {
        return function() {
          $("img", _this.element).on("dragstart", function(event) {
            event.preventDefault();
          });
        };
      })(this);
      this.add_pagination = (function(_this) {
        return function() {
          var $pagination, html, i, position;
          position = (_this.settings.pagination_position === "inside" ? "rock-pagination-inside" : "rock-pagination-outside");
          if (_this.slides_length === 1) {
            return;
          }
          html = "";
          html += "<div class=\"rock-pagination " + position + " " + _this.settings.pagination_class + "\">";
          i = 0;
          while (i < _this.slides_length) {
            html += "<div class=\"rock-pagination-bullet\"></div>";
            i++;
          }
          html += "</div>";
          $pagination = $(html);
          if (_this.settings.pagination_position === "inside") {
            _this.element.prepend($pagination);
          } else {
            _this.element.after($pagination);
          }
          _this.pagination = $(".rock-pagination-bullet", $pagination);
          _this.pagination.each(function(i, el) {
            var $bullet;
            $bullet = $(el);
            $bullet.on("click", function() {
              _this.pagination.filter(".active").removeClass("active");
              $bullet.addClass("active");
              _this.slide(i);
            });
          });
        };
      })(this);
      this.add_scroller = (function(_this) {
        return function() {
          var scroller;
          scroller = "<div class=\"rock-scroller-wrapper rock-scroller-" + _this.settings.scroller_position + "\">";
          scroller += _this.settings.scroller_markup;
          scroller += "</div>";
          _this.scroller = $(scroller);
          _this.element.prepend(_this.scroller);
          _this.scroller.on("click", function() {
            $("html").velocity("scroll", {
              offset: _this.element.height(),
              mobileHA: true,
              duration: 1000
            });
          });
        };
      })(this);
      this.add_thumbnails = (function(_this) {
        return function() {
          var css_param, html, individual_size, inner_size, pan_events, thumbs_count, touch_thumbnails;
          thumbs_count = _this.settings.thumbnails_visible[_this.current_responsive_size];
          if (_this.settings.thumbnails_orientation === 'horizontal') {
            individual_size = _this.element_width / thumbs_count;
            inner_size = individual_size * _this.slides_length;
            css_param = 'width';
          } else if (_this.settings.thumbnails_orientation === 'vertical') {
            individual_size = _this.element_height / thumbs_count;
            inner_size = individual_size * _this.slides_length;
            css_param = 'height';
          }
          html = "";
          html += "<div class=\"rock-thumbnails " + _this.settings.thumbnails_class + " " + _this.settings.thumbnails_orientation + "\">";
          html += ("<div class=\"rock-thumbnails-inner\" style=\"" + css_param + ": ") + inner_size + "px;\">";
          $.each(_this.cache, function(index, item) {
            html += ("<div class=\"rock-thumbnail-wrapper\" style=\"" + css_param + ": ") + individual_size + "px;\">";
            html += "<img class=\"rock-thumbnail\" src=\"" + item.thumbnail + "\" alt=\"Slide " + index + "\" />";
            return html += "</div>";
          });
          html += "</div>";
          html += "</div>";
          _this.thumbnails = {};
          _this.thumbnails.wrapper = $(html);
          if (_this.settings.thumbnails_position === "before") {
            _this.element.before(_this.thumbnails.wrapper);
          } else if (_this.settings.thumbnails_position === "after") {
            _this.element.after(_this.thumbnails.wrapper);
          } else {
            _this.settings.thumbnails_position.append(_this.thumbnails.wrapper);
          }
          _this.thumbnails.inner = $(".rock-thumbnails-inner", _this.thumbnails.wrapper);
          _this.thumbnails.elements = $(".rock-thumbnail-wrapper", _this.thumbnails.wrapper);
          if (_this.settings.thumbnails_orientation === 'horizontal') {
            _this.thumbnails.size = _this.thumbnails.inner.width();
            _this.thumbnails.parent_size = _this.thumbnails.wrapper.width();
          } else if (_this.settings.thumbnails_orientation === 'vertical') {
            _this.thumbnails.size = _this.thumbnails.inner.height();
            _this.thumbnails.parent_size = _this.thumbnails.wrapper.height();
          }
          _this.thumbnails.starting_position = 0;
          _this.thumbnails.starting_direction = void 0;
          _this.thumbnails.elements.each(function(i, el) {
            var $thumbnail;
            $thumbnail = $(el);
            $thumbnail.on("click", function() {
              _this.thumbnails.elements.filter(".active").removeClass("active");
              $thumbnail.addClass("active");
              _this.slide(i);
            });
          });
          $("img", _this.thumbnails.elements.eq(0)).each(function(i, el) {
            $(el).load(function() {
              var height;
              height = $(el).height();
              if (_this.settings.thumbnails_orientation === 'horizontal') {
                _this.thumbnails.inner.height(height);
              } else if (_this.settings.thumbnails_orientation === 'vertical') {
                _this.thumbnails.inner.height(height * _this.slides_length);
              }
            });
          });
          $("img", _this.thumbnails.elements).on("dragstart", function(event) {
            event.preventDefault();
          });
          if (_this.settings.touch === true) {
            touch_thumbnails = new Hammer(_this.thumbnails.wrapper[0]);
            if (_this.settings.thumbnails_orientation === 'horizontal') {
              pan_events = 'panleft panright';
              touch_thumbnails.get('pan').set({
                direction: Hammer.DIRECTION_HORIZONTAL
              });
            } else if (_this.settings.thumbnails_orientation === 'vertical') {
              pan_events = 'panup pandown';
              touch_thumbnails.get('pan').set({
                direction: Hammer.DIRECTION_VERTICAL
              });
            }
            touch_thumbnails.on("panstart pancancel panend " + pan_events, function(event) {
              var distance, snap_distance, transform;
              if (_this.settings.thumbnails_orientation === 'horizontal') {
                distance = event.deltaX;
              } else if (_this.settings.thumbnails_orientation === 'vertical') {
                distance = event.deltaY;
              }
              if (_this.settings.thumbnails_orientation === 'horizontal' && event.type === 'panleft' || event.type === 'panright') {
                if (event.direction === Hammer.DIRECTION_LEFT || event.direction === Hammer.DIRECTION_RIGHT) {
                  transform = "translate3d(" + (_this.thumbnails.starting_position + distance) + "px, 0, 0)";
                  _this.thumbnails.inner.css({
                    'transform': transform,
                    '-o-transform': transform,
                    '-ms-transform': transform,
                    '-moz-transform': transform,
                    '-webkit-transform': transform
                  });
                }
              } else if (_this.settings.thumbnails_orientation === 'vertical' && event.type === 'panup' || event.type === 'pandown') {
                if (event.direction === Hammer.DIRECTION_UP || event.direction === Hammer.DIRECTION_DOWN) {
                  transform = "translate3d(0, " + (_this.thumbnails.starting_position + distance) + "px, 0)";
                  _this.thumbnails.inner.css({
                    'transform': transform,
                    '-o-transform': transform,
                    '-ms-transform': transform,
                    '-moz-transform': transform,
                    '-webkit-transform': transform
                  });
                }
              } else if (event.type === 'panstart' && !_this.thumbnails.inner.hasClass('animating')) {
                _this.thumbnails.inner.addClass('rock-dragging');
                _this.thumbnails.starting_direction = event.direction;
              } else if (event.type === 'panend') {
                _this.thumbnails.inner.removeClass('rock-dragging');
                _this.thumbnails.starting_position += distance;
                if (_this.thumbnails.starting_position < -_this.thumbnails.size + _this.thumbnails.parent_size) {
                  _this.scroll_to_thumbnail(_this.slides_length - 1);
                } else if (_this.thumbnails.starting_position > 0) {
                  _this.scroll_to_thumbnail(0);
                } else {
                  snap_distance = 0;
                  _this.thumbnails.elements.each(function(index, item) {
                    if (_this.thumbnails.starting_position > -snap_distance) {
                      _this.scroll_to_thumbnail(index);
                      return false;
                    }
                    if (_this.settings.thumbnails_orientation === 'horizontal') {
                      snap_distance += $(item).width();
                    } else if (_this.settings.thumbnails_orientation === 'vertical') {
                      snap_distance += $(item).height();
                    }
                  });
                }
              }
              event.preventDefault();
            });
          }
        };
      })(this);
      this.scroll_to_thumbnail = (function(_this) {
        return function(i) {
          var distance, transform;
          if (i < 0) {
            i = 0;
          }
          distance = 0;
          _this.thumbnails.elements.each(function(index, item) {
            if (index === i) {
              return false;
            }
            if (_this.settings.thumbnails_orientation === 'horizontal') {
              distance += $(item).width();
            } else if (_this.settings.thumbnails_orientation === 'vertical') {
              distance += $(item).height();
            }
          });
          if (_this.thumbnails.size - distance < _this.thumbnails.parent_size) {
            distance = _this.thumbnails.size - _this.thumbnails.parent_size;
          }
          _this.thumbnails.starting_position = -distance;
          if (_this.settings.thumbnails_orientation === 'horizontal') {
            transform = 'translate3d(' + (-distance) + 'px, 0, 0)';
          } else if (_this.settings.thumbnails_orientation === 'vertical') {
            transform = 'translate3d(0, ' + (-distance) + 'px, 0)';
          }
          _this.thumbnails.inner.addClass('animating').css({
            'transform': transform,
            '-o-transform': transform,
            '-ms-transform': transform,
            '-moz-transform': transform,
            '-webkit-transform': transform
          });
          setTimeout(function() {
            _this.thumbnails.inner.removeClass('animating');
          }, 700);
        };
      })(this);
      this.resize_thumbnails = (function(_this) {
        return function() {
          var css_param, individual_size, inner_size, size, thumbs_count;
          thumbs_count = _this.settings.thumbnails_visible[_this.current_responsive_size];
          if (_this.settings.thumbnails_orientation === 'horizontal') {
            individual_size = _this.element_width / thumbs_count;
            inner_size = individual_size * _this.slides_length;
            css_param = 'width';
          } else if (_this.settings.thumbnails_orientation === 'vertical') {
            individual_size = _this.thumbnails.wrapper.parent().height() / thumbs_count;
            inner_size = individual_size * _this.slides_length;
            css_param = 'height';
          }
          _this.thumbnails.inner[css_param](inner_size);
          _this.thumbnails.elements[css_param](individual_size);
          if (_this.settings.thumbnails_orientation === 'horizontal') {
            _this.thumbnails.size = inner_size;
          } else if (_this.settings.thumbnails_orientation === 'vertical') {
            _this.thumbnails.size = inner_size;
          }
          _this.thumbnails.parent_size = _this.thumbnails.wrapper[css_param]();
          size = void 0;
          if (_this.settings.thumbnails_orientation === 'horizontal') {
            size = $("img", _this.thumbnails.elements.eq(0)).height();
            _this.thumbnails.inner.height(size);
          } else if (_this.settings.thumbnails_orientation === 'vertical') {
            size = $("img", _this.thumbnails.elements.eq(0)).width();
            _this.thumbnails.inner.width(size);
          }
          _this.scroll_to_thumbnail(_this.current);
        };
      })(this);
      this.enable_touch = (function(_this) {
        return function() {
          _this.touch_object = new Hammer(_this.element[0]);
          _this.touch_object.get('pan').set({
            direction: Hammer.DIRECTION_HORIZONTAL
          });
          _this.touch_object.on('panleft panright', function(event) {
            if (event.eventType === Hammer.INPUT_START) {
              _this.element.addClass('rock-dragging');
            } else if (event.eventType === Hammer.INPUT_END || event.eventType === Hammer.INPUT_CANCEL) {
              _this.element.removeClass('rock-dragging');
              if (event.direction === Hammer.DIRECTION_LEFT) {
                _this.slide(_this.current + 1);
              } else if (event.direction === Hammer.DIRECTION_RIGHT) {
                _this.slide(_this.current - 1);
              }
            }
          });
        };
      })(this);
      this.enable_mousewheel = (function(_this) {
        return function() {
          _this.element.mousewheel(function(event) {
            if (event.deltaY === -1) {
              _this.slide(_this.current + 1);
            }
            if (event.deltaY === 1) {
              _this.slide(_this.current - 1);
            }
            if (_this.settings.prevent_scrolling === true) {
              event.preventDefault();
            }
          });
        };
      })(this);
      this.enable_keyboard = (function(_this) {
        return function() {
          $(document).keydown(function(e) {
            switch (e.which) {
              case 37:
                return _this.slide(_this.current - 1);
              case 39:
                return _this.slide(_this.current + 1);
            }
          });
        };
      })(this);
      this.add_controls = (function(_this) {
        return function() {
          var next_html, prev_html;
          prev_html = '';
          prev_html += '<a href="javascript:void(0);" class="rock-control rock-prev ' + _this.settings.controls_class + '">';
          prev_html += '<div class="rock-control-inner">';
          if (_this.settings.controls_thumbnail === true) {
            prev_html += '<div class="rock-control-thumbnail">';
            prev_html += '<img src="" alt="Previous Slide" class="rock-control-image"/>';
            prev_html += '</div>';
          }
          prev_html += '<div class="rock-control-text">';
          prev_html += _this.settings.controls_html.prev;
          prev_html += '</div>';
          prev_html += '</div>';
          prev_html += '</a>';
          next_html = '';
          next_html += '<a href="javascript:void(0);" class="rock-control rock-next ' + _this.settings.controls_class + '">';
          next_html += '<div class="rock-control-inner">';
          if (_this.settings.controls_thumbnail === true) {
            next_html += '<div class="rock-control-thumbnail">';
            next_html += '<img src="" alt="Next Slide" class="rock-control-image"/>';
            next_html += '</div>';
          }
          next_html += '<div class="rock-control-text">';
          next_html += _this.settings.controls_html.next;
          next_html += '</div>';
          next_html += '</div>';
          next_html += '</a>';
          _this.outer.append(prev_html + next_html);
          _this.prev_button = $(_this.settings.selector.prev, _this.element);
          _this.next_button = $(_this.settings.selector.next, _this.element);
          if (_this.settings.controls_thumbnail === true) {
            _this.prev_thumbnail = $('.rock-control-image', _this.prev_button);
            _this.next_thumbnail = $('.rock-control-image', _this.next_button);
          }
          _this.prev_button.on('click', function() {
            _this.slide(_this.current - 1);
          });
          _this.next_button.on('click', function() {
            _this.slide(_this.current + 1);
          });
        };
      })(this);
      this.enable_pause_on_hover = (function(_this) {
        return function() {
          _this.element.on('mouseenter', function() {
            _this.pause_timer();
          });
          _this.element.on('mouseleave', function() {
            _this.unpause_timer();
          });
        };
      })(this);
      this.pause_timer = (function(_this) {
        return function() {
          var current_time;
          current_time = new Date;
          _this.timer.remaining = _this.timer.remaining - (current_time - _this.timer.start);
          clearTimeout(_this.timer.clock);
          if (_this.settings.progress === true) {
            _this.progress.bar.velocity('stop');
          }
          _this.element.trigger('rock-slider.pause');
        };
      })(this);
      this.unpause_timer = (function(_this) {
        return function() {
          var next_slide;
          next_slide = _this.current === -1 ? 1 : _this.current + 1;
          _this.timer.start = new Date;
          clearTimeout(_this.timer.clock);
          _this.timer.clock = setTimeout((function() {
            _this.slide(next_slide);
          }), _this.timer.remaining);
          if (_this.settings.progress === true) {
            _this.progress.bar.velocity({
              width: '100%'
            }, _this.timer.remaining);
          }
          _this.element.trigger('rock-slider.resume');
        };
      })(this);
      this.prevent_dragging = (function(_this) {
        return function() {
          $('img', _this.element).on('dragstart', function(event) {
            event.preventDefault();
          });
        };
      })(this);
      this.add_progress_bar = (function(_this) {
        return function() {
          var html, position;
          position = _this.settings.progress_position === 'top' ? 'rock-progress-top' : 'rock-progress-bottom';
          html = '';
          html += '<div class="rock-progress ' + position + ' ' + _this.settings.progress_class + '">';
          html += '<div class="rock-progress-bar">';
          html += '</div>';
          html += '</div>';
          _this.element.prepend(html);
          _this.progress = {};
          _this.progress.element = $('.rock-progress', _this.element);
          _this.progress.bar = $('.rock-progress-bar', _this.element);
        };
      })(this);
      this.setup_content = (function(_this) {
        return function() {
          var $content;
          $content = $('.rock-content-wrapper', _this.element);
          if (_this.settings.content_scaling === true) {
            _this.scale_content();
          } else {
            $content.width(_this.outer.width());
            $content.height(_this.outer.height());
          }
        };
      })(this);
      this.setup_scaling = (function(_this) {
        return function() {
          var $content;
          $content = $('.rock-content-wrapper', _this.element);
          _this.scaling_reference = _this.settings.content_width ? _this.settings.content_width : _this.settings.width;
          $content.width(_this.scaling_reference);
          $content.height(_this.settings.width / _this.scaling_reference * _this.settings.height);
        };
      })(this);
      this.scale_content = (function(_this) {
        return function() {
          var $content, calculated_width, origin_x, origin_y;
          $content = $('.rock-content-wrapper', _this.element);
          origin_x = '0%';
          origin_y = '0%';
          calculated_width = _this.outer.width();
          _this.scaling_value = calculated_width / _this.scaling_reference * _this.settings.content_scaling_factor[_this.current_responsive_size];
          if (_this.settings.content_scaling_factor[_this.current_responsive_size] === 1) {
            $.Velocity.hook($content, 'translateX', "0px");
          } else {
            $.Velocity.hook($content, 'translateX', (calculated_width * (1 - _this.settings.content_scaling_factor[_this.current_responsive_size]) / 2) + "px");
          }
          $.Velocity.hook($content, 'translateZ', '0px');
          $.Velocity.hook($content, 'transformOriginX', origin_x);
          $.Velocity.hook($content, 'transformOriginY', origin_y);
          $.Velocity.hook($content, 'scaleX', _this.scaling_value);
          $.Velocity.hook($content, 'scaleY', _this.scaling_value);
        };
      })(this);
      this.setup_grid = (function(_this) {
        return function() {
          var grid_is_set;
          grid_is_set = false;
          $('.rock-background-wrapper', _this.element).each(function(index, element) {
            var background, cell_count, grid, i, k, ref;
            grid = _this.cache[index].background[0].grid;
            if (grid.enabled) {
              grid_is_set = true;
              cell_count = grid.columns * grid.rows;
              $(element).append($('<div class="rock-grid"></div>'));
              background = $(_this.settings.selector.background, $(element));
              for (i = k = 0, ref = cell_count - 1; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
                background.clone().appendTo($('.rock-grid', $(element))).wrap('<div class="rock-grid-cell"></div>');
              }
              background.addClass('rock-background-main');
            }
          });
          _this.resize_grid();
          if (grid_is_set) {
            _this.setup_layout();
          }
        };
      })(this);
      this.resize_grid = (function(_this) {
        return function() {
          $('.rock-background-wrapper', _this.element).each(function(index, element) {
            var cell_height, cell_width, cells, grid, i, j, k, l, main_height, main_width, ref, ref1, this_background, this_cell;
            grid = _this.cache[index].background[0].grid;
            if (grid.enabled) {
              main_width = _this.inner.width();
              main_height = _this.inner.height();
              cell_width = main_width / grid.columns;
              cell_height = main_height / grid.rows;
              cells = $('.rock-grid-cell', $(element));
              cells.width(cell_width).height(cell_height);
              for (i = k = 0, ref = grid.rows; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
                for (j = l = 0, ref1 = grid.columns; 0 <= ref1 ? l <= ref1 : l >= ref1; j = 0 <= ref1 ? ++l : --l) {
                  this_cell = cells.eq(i * grid.columns + j);
                  $.Velocity.hook(this_cell, 'translateX', (cell_width * j) + "px");
                  $.Velocity.hook(this_cell, 'translateY', (cell_height * i) + "px");
                  this_background = $(_this.settings.selector.background, this_cell);
                  this_background.width(main_width).height(main_height);
                  $.Velocity.hook(this_background, 'translateX', "-" + (cell_width * j) + "px");
                  $.Velocity.hook(this_background, 'translateY', "-" + (cell_height * i) + "px");
                }
              }
            }
          });
        };
      })(this);
      this.clear_timeouts = function(i) {
        $.each(this.cache[i].background[0].animation, (function(_this) {
          return function(index) {
            clearTimeout(_this.cache[i].background[0].animation[index].timeline);
          };
        })(this));
        if ('loop_timeout' in this.cache[i].background[0]) {
          clearTimeout(this.cache[i].background[0].loop_timeout);
        }
        $.each(this.cache[i].layer, (function(_this) {
          return function(index) {
            $.each(_this.cache[i].layer[index].animation, function(animateIndex) {
              clearTimeout(_this.cache[i].layer[index].animation[animateIndex].timeline);
            });
            if ('loop_timeout' in _this.cache[i].layer[index]) {
              clearTimeout(_this.cache[i].layer[index].loop_timeout);
            }
          };
        })(this));
        $.each(this.cache[i].object, (function(_this) {
          return function(index) {
            $.each(_this.cache[i].object[index].animation, function(animateIndex) {
              clearTimeout(_this.cache[i].object[index].animation[animateIndex].timeline);
            });
            if ('loop_timeout' in _this.cache[i].object[index]) {
              clearTimeout(_this.cache[i].object[index].loop_timeout);
            }
          };
        })(this));
      };
      this.debounce = function(func, wait, immediate) {
        var timeout;
        timeout = void 0;
        return function() {
          var args, callNow, context, later;
          context = this;
          args = arguments;
          later = function() {
            timeout = null;
            if (!immediate) {
              func.apply(context, args);
            }
          };
          callNow = immediate && !timeout;
          clearTimeout(timeout);
          timeout = setTimeout(later, wait);
          if (callNow) {
            func.apply(context, args);
          }
        };
      };
      this.check_retina = (function(_this) {
        return function() {
          var mediaQuery, ref, retina, root;
          retina = false;
          root = (ref = typeof exports !== "undefined" && exports !== null) != null ? ref : {
            window: exports
          };
          mediaQuery = '(-webkit-min-device-pixel-ratio: 1.5), (min--moz-device-pixel-ratio: 1.5), (-o-min-device-pixel-ratio: 3/2), (min-resolution: 1.5dppx)';
          if (root.devicePixelRatio > 1) {
            retina = true;
          }
          if (root.matchMedia && root.matchMedia(mediaQuery).matches) {
            retina = true;
          }
          if (retina) {
            $('img[data-at2x]', $slide).each(function(index, element) {
              var img, newsrc, src;
              img = $(element);
              newsrc = img.attr('data-rock-at2x');
              if (newsrc != null) {
                src = img.attr('src');
                if (newsrc === "true") {
                  src = src.replace(/(\.[\w\?=]+)$/, "@2x$1");
                } else {
                  src = newsrc;
                }
                return img.attr('src', src);
              }
            });
          }
        };
      })(this);
      this.next = (function(_this) {
        return function() {
          _this.slide(_this.current + 1);
        };
      })(this);
      this.prev = (function(_this) {
        return function() {
          _this.slide(_this.current - 1);
        };
      })(this);
      this.pause = (function(_this) {
        return function() {
          _this.pause_timer();
        };
      })(this);
      this.resume = (function(_this) {
        return function() {
          _this.unpause_timer();
        };
      })(this);
      return this.initialize();
    };
    $.rockSlider.layouts = {};
    $.rockSlider.add_layout = function(name, layout) {
      return $.rockSlider.layouts[name] = layout;
    };
    return $.fn.rockSlider = function(opts) {
      return this.each(function(index, element) {
        if (!$.data(element, "rock-slider")) {
          return $.data(element, "rock-slider", new $.rockSlider(element, opts));
        }
      });
    };
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../src/maps/rock-slider/rock-slider.js.map
