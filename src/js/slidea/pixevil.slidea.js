
/*

         dP oo       dP
         88          88
.d8888b. 88 dP .d888b88 .d8888b. .d8888b.
Y8ooooo. 88 88 88'  `88 88ooood8 88'  `88
      88 88 88 88.  .88 88.  ... 88.  .88
`88888P' dP dP `88888P8 `88888P' `88888P8
oooooooooooooooooooooooooooooooooooooooooo

@plugin    jQuery
@license   CodeCanyon Standard / Extended
@author    Alex Grozav
@company   Pixevil
@website   http://pixevil.com
@email     alex@grozav.com
@guide
  Running slidea
    $('.slidea').slidea
      width: 1280
      height: 720
      layout: 'layoutName'

  Using methods
    $('.slidea').data('slidea').method_name()

  Adding events
    $('.slidea').on 'eventName', ->
 */

(function() {
  (function($, window, document) {
    "use strict";
    $.slidea = function(element, options) {

      /*
      Default attribute values
       */
      var _defaults;
      _defaults = {
        animation: {
          initial: "opacity 0",
          out: "opacity 0",
          easing: "easeOutQuad",
          duration: 500
        },
        duration: 4000,
        overlap: 1,
        layout: "default",
        layerIndex: 99,
        autoplay: false,
        loop: true,
        preload: 'fast',
        animate: 'TweenLite',
        grid: {
          rows: 1,
          columns: 1,
          stagger: 0.1
        },
        screen: {
          xs: 0,
          sm: 768,
          md: 992,
          lg: 1200,
          xlg: 1560
        },
        selector: {
          slide: ".slidea-slide",
          content: ".slidea-content",
          contentWrapper: ".slidea-content-wrapper",
          contentContainer: ".slidea-content-container",
          canvas: ".slidea-canvas",
          background: ".slidea-background",
          backgroundWrapper: ".slidea-background-wrapper",
          videoBackground: ".slidea-video-background",
          video: ".slidea-video",
          videoCover: ".slidea-video-cover",
          layer: ".slidea-layer",
          layerWrapper: ".slidea-layer-wrapper",
          object: ".slidea-object, .s-obj",
          objectWrapper: ".slidea-object-wrapper",
          next: ".slidea-next",
          prev: ".slidea-prev",
          inner: ".slidea-inner",
          wrapper: ".slidea-wrapper"
        }
      };
      this.debug = true;
      this._defaults = _defaults;
      this.settings = $.extend(true, {}, _defaults, options);
      this.element = $(element);
      this.parent = this.element.parent();

      /*
      Current active slide. We're using -1 to say that there is no current
      slide yet, or that the slider hasn't started yet.
       */
      this.current = -1;
      this.youtube_player = {};
      this.vimeo_player = {};
      this.window = $(window);
      this.loaded = false;

      /*
      Timer
      Used in slide to set timeout to next slide
       */
      this.timer = {};
      this.timer.timeout = null;
      this.timer.start = 0;
      this.timer.remaining = 0;
      if (this.element.attr('id') != null) {
        this.id = this.element.attr('id');
      } else {
        this.id = this.get_random_id('rock');
        this.element.attr('id', this.id);
      }
      this.initialize = (function(_this) {
        return function() {
          _this.log("Initializing Slidea..");
          _this.log(_this.settings);
          _this.register();
          _this.add_classes();
          _this.wrap_objects();
          _this.wrapper = $(_this.settings.selector.wrapper, _this.element);
          _this.inner = $(_this.settings.selector.inner, _this.element);
          _this.slides = $(_this.settings.selector.slide, _this.element);
          _this.slides_length = _this.slides.length;
          _this.data = {};
          _this.slides.each(function(index) {
            return _this.data[index] = {};
          });
          if (_this.settings.first_slide != null) {
            _this.first_slide = _this.settings.first_slide;
          } else {
            _this.first_slide = 0;
          }
          _this.set_adjacent_slides(_this.first_slide);
          _this.active = _this.slides.eq(_this.first_slide);
          _this.animate = window[_this.settings.animate];
          _this.log("Animating using the " + _this.settings.animate + " platform.");
          _this["eval"].layouts('initialize');
          _this["eval"].modules('initialize');
          _this.init_animus();
          _this.set_data_settings();
          _this.set_parent_sizes();
          _this.set_responsive_context();
          _this.set_layers_zindex();
          _this.bind_resize();
          _this.bind_focus();
          _this.bind_inner_links();
          _this.load(function() {
            _this.resize();
            _this.log("Animation data parsed.");
            _this.log(_this.data);
            setTimeout((function() {
              return _this.slide(_this.first_slide);
            }), 500);
            _this.log("Load callback has finished.");
          });
        };
      })(this);

      /*
      Slide wrapper function for calling static slider method to move
      the carousel to the next slide
       */
      this.slide = function(to) {
        var from;
        from = this.current;
        if (to === this.current) {
          return;
        }
        if (to > this.slides_length - 1) {
          to = 0;
        }
        if (to < 0) {
          to = this.slides_length - 1;
        }
        this.log("---------------------------------------");
        this.log("Slide transition from " + from + " to " + to + ".");
        this.set_adjacent_slides(to);
        $('.previous', this.element).removeClass('previous');
        this.slides.eq(this.prev).addClass('previous');
        $('.active', this.element).removeClass('active');
        this.active = this.slides.eq(to);
        this.active.addClass('active');
        $('.next', this.element).removeClass('next');
        this.slides.eq(this.next).addClass('next');
        if (from !== -1) {
          setTimeout((function(_this) {
            return function() {
              _this.clear_timeouts(from);
            };
          })(this), this.data[from].background[0].animation[this.data[from].background[0].duration].duration * 1000);
        }
        this.clear_timeouts(to);
        this["eval"].layouts('slide', [from, to]);
        this["eval"].modules('slide', [from, to]);
        this.transition(from, to);
        this.current = to;
        this.log("Indexes are current: " + this.current + ", previous: " + this.prev + ", next: " + this.next + ".");
        if (this.settings.autoplay === true) {
          this.timer.start = new Date;
          this.timer.remaining = this.data[to].background[0].duration;
          clearTimeout(this.timer.clock);
          this.timer.clock = setTimeout(((function(_this) {
            return function() {
              if (_this.settings.loop !== true && to + 1 === _this.slides_length - 1) {
                _this.log("Looping is off. Autoplay stops here.");
                return;
              }
              _this.slide(to + 1);
            };
          })(this)), this.timer.remaining);
          this.log("Autoplay timer has been reset.");
        }
        this.element.trigger('slidea.transition', [from, to, this.prev, this.next, this.slides_length, this.active]);
      };

      /*
      Set the index of the next and previous slides
       */
      this.set_adjacent_slides = (function(_this) {
        return function(to) {
          _this.next = to + 1 > _this.slides_length - 1 ? 0 : to + 1;
          _this.prev = to - 1 < 0 ? _this.slides_length - 1 : to - 1;
        };
      })(this);

      /*
      Apply animations for all slider elements. Run previous slide out animation
      and set time required to crossfade slides
      
      @param i [Fixnum] Current slide index
      @param prev [Fixnum] Previous slide index
       */
      this.transition = (function(_this) {
        return function(from, to) {
          var from_slide_duration, from_stagger, timeout;
          _this["eval"].layouts('transition', [from, to]);
          _this["eval"].modules('transition', [from, to]);
          from_stagger = 0;
          timeout = 0;
          clearTimeout(_this.animate_timeout);
          if (from !== -1) {
            _this.transition_run(from, 'out');
            from_slide_duration = _this.data[from].background[0].duration;
            if (_this.data[from].background[0].animation[from_slide_duration]) {
              timeout += _this.data[from].background[0].animation[from_slide_duration].duration * 1000;
            }
          }
          timeout *= _this.settings.overlap;
          if (timeout < 0) {
            timeout = 0;
          }
          _this.animate_timeout = setTimeout(function() {
            _this.transition_run(to, 'in');
          }, timeout);
          _this["eval"].layouts('after_transition', [from, to]);
          _this["eval"].modules('after_transition', [from, to]);
        };
      })(this);

      /*
      Run initial transition animations for the slide
       */
      this.transition_run = (function(_this) {
        return function(index, mode) {
          var canvas, layers, objects, slide;
          slide = _this.slides.eq(index);
          canvas = $(_this.settings.selector.canvas, slide);
          layers = $(_this.settings.selector.layerWrapper, slide);
          objects = $(_this.settings.selector.object, slide);
          if (_this.settings.layoutSettings.animate_background !== false) {
            _this.log("Running animations for background.");
            _this.transition_animate(index, slide, 'background', 0, mode, false);
          }
          layers.each(function(layer_index, layer) {
            _this.log("Running animations for layer " + layer_index + ".");
            _this.transition_animate(index, $(layer), 'layer', layer_index, mode, false);
          });
          objects.each(function(object_index, object) {
            _this.log("Running animations for object " + object_index + ".");
            _this.transition_animate(index, $(object), 'object', object_index, mode, false);
          });
        };
      })(this);

      /*
      Validate transition index for given animation element
       */
      this.transition_validate = (function(_this) {
        return function(i, index, element, context, context_index, mode) {
          var slide_duration;
          slide_duration = _this.data[i].background[0].duration;
          index = parseInt(index);
          switch (mode) {
            case 'in':
              return index !== 'initial' && index !== -1 && !isNaN(index) && !$.isEmptyObject(_this.data[i][context][context_index].animation[index].state) && (slide_duration === -1 || slide_duration !== -1 && index < slide_duration);
            case 'out':
              return index !== 'initial' && (index === -1 || slide_duration !== -1 && index >= slide_duration) && !$.isEmptyObject(_this.data[i][context][context_index].animation[index].state);
            default:
              return true;
          }
        };
      })(this);

      /*
      Runs animation for current slide, generalized for background, layers and
      objects
      
      @param i [Fixnum] Slide index
      @param $element [Object] Element on which animation is applied
      @param context [String] Current animation cache accessor
      @param context_index [Fixnum] Current animation cache accessor index
       */
      this.transition_animate = (function(_this) {
        return function(i, element, context, context_index, mode, in_loop, callback) {
          var loop_timeout, slide_duration;
          slide_duration = _this.data[i].background[0].duration;
          if (!(mode === 'out' || in_loop || (_this.data[i][context][context_index].animation.initial == null))) {
            _this.animate.set(element, _this.data[i][context][context_index].animation.initial.state);
            if ('callback' in _this.data[i][context][context_index]) {
              _this.data[i][context][context_index].callback.call(_this, element, 'initial');
            }
          }
          $.each(_this.data[i][context][context_index].animation, function(index, animation) {
            var timeout;
            if (!_this.transition_validate(i, index, element, context, context_index, mode)) {
              return;
            }
            _this.log("Running " + mode + " transition[" + index + "] for " + context + "[" + context_index + "].");
            _this.log(_this.data[i][context][context_index].animation[index]);
            if (mode === 'in') {
              timeout = index;
            } else {
              timeout = slide_duration - parseInt(index);
            }
            if (in_loop) {
              timeout = timeout - _this.data[i][context][context_index].loop_diff;
              if (timeout < 0) {
                return;
              }
            }
            _this.data[i][context][context_index].animation[index].timeline = setTimeout(function() {
              if ('callback' in _this.data[i][context][context_index]) {
                _this.data[i][context][context_index].callback.call(_this, element, index);
              }
              if (typeof _this.data[i][context][context_index].animation[index].state === 'string') {
                _this.animate_preset(element, _this.data[i][context][context_index].animation[index]);
              } else {
                _this.animate.to(element, _this.data[i][context][context_index].animation[index].duration, _this.data[i][context][context_index].animation[index].state);
              }
            }, timeout);
          });
          if (_this.data[i][context][context_index].loop) {
            if (in_loop) {
              loop_timeout = _this.data[i][context][context_index].loop - _this.data[i][context][context_index].loop_diff;
            } else {
              loop_timeout = _this.data[i][context][context_index].loop;
            }
            _this.data[i][context][context_index].loop_timeout = setTimeout(function() {
              _this.transition_animate(i, element, context, context_index, mode, true);
            }, loop_timeout);
          }
        };
      })(this);

      /*
      Grid animation wrapper to run a callback after grid animation ends
       */
      this.run_grid_transition = (function(_this) {
        return function(to, $element, context, context_index, in_loop) {
          var to_slide;
          to_slide = _this.slides.eq(to);
          _this.run_transition(i, $element, context, context_index, in_loop, function() {
            $.Velocity.hook($('.slidea-background-main', to_slide), 'opacity', 1);
            $('.slidea-grid', to_slide).velocity({
              opacity: 0
            }, 20);
          });
        };
      })(this);

      /*
      Run animus animation preset
       */
      this.animate_preset = (function(_this) {
        return function(element, data) {
          var timeout;
          _this.log("Animating preset " + data + ".");
          timeout = 0;
          $.each($.animus.presets[data.state], function(index, animation) {
            var duration;
            duration = data.duration * animation[1];
            setTimeout(function() {
              _this.animate.to(element, duration, $.animus.presets[data.state][index][0]);
            }, timeout * 1000);
            timeout += duration;
          });
        };
      })(this);

      /*
      Registers modules and layouts which are loaded
       */
      this.register = (function(_this) {
        return function() {
          _this.layouts = {};
          $.each($.slidea.layouts, function(index, value) {
            _this.layouts[index] = new value;
            if (_this.layouts[index].settings != null) {
              if (_this.settings.layoutSettings != null) {
                _this.settings.layoutSettings = $.extend(true, {}, _this.layouts[index].settings, _this.settings.layoutSettings);
              } else {
                _this.settings.layoutSettings = _this.layouts[index].settings;
              }
            }
            _this.log("Layout \"" + index + "\" registered.");
          });
          _this.modules = {};
          $.each($.slidea.modules, function(index, module) {
            _this.modules[index] = new module;
            if (_this.modules[index].settings != null) {
              if (_this.settings[index] != null) {
                if (typeof _this.modules[index].settings === 'object') {
                  _this.settings[index] = $.extend(true, {}, _this.modules[index].settings, _this.settings[index]);
                }
              } else {
                _this.settings[index] = _this.modules[index].settings;
              }
            }
            _this.log("Module \"" + index + "\" registered.");
            _this.log(_this.modules[index]);
          });
          _this.log("Settings changed after module registration.");
          _this.log(_this.settings);
        };
      })(this);

      /*
      Method call wrapper for layout and modules
       */
      this["eval"] = {};

      /*
      Setup wrapper function for calling layout method
       */
      this["eval"].layouts = (function(_this) {
        return function(method, args) {
          if (args == null) {
            args = [];
          }
          if (_this.layouts[_this.settings.layout]) {
            if (_this.layouts[_this.settings.layout][method] != null) {
              _this.layouts[_this.settings.layout][method].apply(_this, args);
            }
          } else {
            _this.error("Couldn't find any valid layouts with the name \"" + _this.settings.layout + "\".");
          }
        };
      })(this);

      /*
      Setup wrapper function for calling modules method
       */
      this["eval"].modules = (function(_this) {
        return function(method, args) {
          if (args == null) {
            args = [];
          }
          $.each(_this.modules, function(name, module) {
            if ((_this.settings[name] != null) && (_this.settings[name].enabled === true || _this.settings[name] === true) && (_this.modules[name][method] != null)) {
              return _this.modules[name][method].apply(_this, args);
            }
          });
        };
      })(this);

      /*
      Get data such as height, width and animations for the slide with
      the current index
       */
      this.get_slide_data = (function(_this) {
        return function(index) {
          var default_duration, slide, slide_background, slide_layers, slide_objects;
          _this.data[index].background = {};
          _this.data[index].layer = {};
          _this.data[index].object = {};
          slide = _this.slides.eq(index);
          slide_background = $(_this.settings.selector.background, slide);
          slide_layers = $(_this.settings.selector.layer, slide);
          slide_objects = $(_this.settings.selector.object, slide);
          slide_background.each(function(background_index, background) {
            background = $(background);
            _this.data[index].background[background_index] = _this.get_data(index, 'background', background_index, slide, _this.check_image(background), _this.settings.duration);
            _this.log("Received data for slide " + index + " -> background " + background_index + ".");
            _this.log(_this.data[index].background[background_index]);
          });
          if (slide_background.length === 0) {
            _this.data[index].background[0] = _this.get_data(index, 'background', 0, slide, null, _this.settings.duration);
          }
          default_duration = _this.data[index].background[0].duration;
          slide_layers.each(function(layer_index, layer) {
            layer = $(layer);
            _this.data[index].layer[layer_index] = _this.get_data(index, 'layer', layer_index, layer, _this.check_image(layer), default_duration);
            _this.log("Received data for slide " + index + " -> layer " + layer_index + ".");
            _this.log(_this.data[index].layer[layer_index]);
          });
          slide_objects.each(function(object_index, object) {
            object = $(object);
            _this.data[index].object[object_index] = _this.get_data(index, 'object', object_index, object, _this.check_image(object), default_duration);
            _this.log("Received data for slide " + index + " -> object " + object_index + ".");
            _this.log(_this.data[index].object[object_index]);
          });
          _this["eval"].modules('get_slide_data', [index, slide, slide_background, slide_layers, slide_objects]);
          _this.log("Finished gathering data for all elements.");
        };
      })(this);

      /*
      Get element animation data based on its type
      
      @param object [Object] Current data gathering target
      @param image [Object] Image target from which we gather layer sizes
      @param type [String] Target type identifier
      @param duration [Fixnum] Element default on screen display time
       */
      this.get_data = function(index, context, context_index, object, image, default_duration) {
        var animation_stack, current_time_stack, data, duration, end_time, identifiers, image_size, initial_animation_override, initial_state, js_data, last_time, object_classes, object_id, out_animation, slide_classes, slide_id, slide_js_data, starting_animation, string, time_stack, timeline;
        string = '';
        js_data = false;
        slide_id = this.slides.eq(index).attr('id');
        slide_classes = this.slides.eq(index).attr('class');
        if (this.settings.slide != null) {
          slide_js_data = [];
          if (this.settings.slide[index] != null) {
            slide_js_data.push(this.settings.slide[index]);
          }
          if (slide_classes != null) {
            $.each(slide_classes.split(' '), (function(_this) {
              return function(index, slide_class) {
                if (_this.settings.slide['.' + slide_class] != null) {
                  slide_js_data.push(_this.settings.slide['.' + slide_class]);
                }
              };
            })(this));
          }
          if ((slide_id != null) && (this.settings.slide['#' + slide_id] != null)) {
            slide_js_data.push(this.settings.slide['#' + slide_id]);
          }
          if (slide_js_data.length > 0) {
            object_id = object.attr('id');
            object_classes = object.attr('class');
            identifiers = [];
            identifiers.push(context_index);
            if (object_classes != null) {
              identifiers = identifiers.concat(object_classes.split(' ').map(function(element) {
                return '.' + element;
              }));
            }
            if (object_id != null) {
              identifiers.push('#' + object_id);
            }
            $.each(slide_js_data, (function(_this) {
              return function(index, slide_js_data) {
                if (slide_js_data[context] != null) {
                  $.each(identifiers, function(index, identifier) {
                    if ((slide_js_data[context] != null) && (slide_js_data[context][identifier] != null)) {
                      if (js_data) {
                        js_data = $.extend(js_data, slide_js_data[context][identifier]);
                      } else {
                        js_data = $.extend({}, slide_js_data[context][identifier]);
                      }
                    }
                  });
                }
              };
            })(this));
          }
        }
        time_stack = [];
        current_time_stack = 0;
        animation_stack = {};
        data = {};
        data.type = context;
        data.animation = {};
        if (image !== null) {
          image_size = this.get_image_size(image);
          data.width = image_size.width;
          data.height = image_size.height;
        }
        if (context === 'layer') {
          data.position = {};
          if (object.attr('data-slidea-width') != null) {
            data.width = parseFloat(object.attr('data-slidea-width'));
          } else if (js_data && (js_data.width != null)) {
            data.width = parseFloat(this.delete_property(js_data, 'width'));
          }
          if (object.attr('data-slidea-height') != null) {
            data.height = parseFloat(object.attr('data-slidea-height'));
          } else if (js_data && (js_data.height != null)) {
            data.height = parseFloat(this.delete_property(js_data, 'height'));
          }
          if (object.attr('data-slidea-top') != null) {
            data.position.top = parseFloat(object.attr('data-slidea-top'));
          } else if (js_data && (js_data.top != null)) {
            data.position.top = parseFloat(this.delete_property(js_data, 'top'));
          } else if (object.attr('data-slidea-bottom') != null) {
            data.position.bottom = parseFloat(object.attr('data-slidea-bottom'));
          } else if (js_data && (js_data.bottom != null)) {
            data.position.bottom = parseFloat(this.delete_property(js_data, 'bottom'));
          } else {
            data.position.top = 0;
          }
          if (object.attr('data-slidea-left') != null) {
            data.position.left = parseFloat(object.attr('data-slidea-left'));
          } else if (js_data && (js_data.left != null)) {
            data.position.left = parseFloat(this.delete_property(js_data, 'left'));
          } else if (object.attr('data-slidea-right') != null) {
            data.position.right = parseFloat(object.attr('data-slidea-right'));
          } else if (js_data && (js_data.right != null)) {
            data.position.right = parseFloat(this.delete_property(js_data, 'right'));
          } else {
            data.position.left = 0;
          }
        }
        if (object.attr('data-slidea-start') != null) {
          data.start = parseFloat(object.attr('data-slidea-start'), 10);
        } else if (js_data && (js_data.start != null)) {
          data.start = parseInt(this.delete_property(js_data, 'start'));
        } else {
          data.start = 0;
        }
        initial_state = object.attr('data-slidea');
        if (initial_state == null) {
          initial_state = object.attr('data-slidea-initial');
        }
        if (initial_state == null) {
          initial_state = this.delete_property(js_data, 'initial');
        }
        if (initial_state != null) {
          starting_animation = initial_state;
        } else if (context === 'background') {
          starting_animation = this.settings.animation.initial;
        } else {
          starting_animation = '';
        }

        /*
        This sets the initial state of our animated object
        The entering animation will be set as css and will
        transition to the default state
         */
        animation_stack[data.start] = starting_animation;
        time_stack[current_time_stack++] = data.start;

        /*
        Set animation in override to set a different beginning state
        other than the default one
         */
        if (object.attr('data-slidea-in') != null) {
          initial_animation_override = this.animus.get(object.attr('data-slidea-in'));
        } else if (js_data && (js_data["in"] != null)) {
          initial_animation_override = this.animus.get(this.delete_property(js_data, 'in'));
        } else {
          initial_animation_override = false;
        }
        timeline = object.data();
        $.each(timeline, function(key, value) {
          var at_time, time;
          time = void 0;
          if ((time = key.match(/slideaAt([0-9]+)/)) !== null) {
            at_time = parseInt(time[1], 10);
            animation_stack[at_time] = value;
            time_stack[current_time_stack++] = at_time;
          }
        });
        $.each(js_data, (function(_this) {
          return function(index, value) {
            if (!/[0-9]+/.test(index)) {
              return;
            }
            animation_stack[index] = value;
            time_stack[current_time_stack++] = index;
          };
        })(this));
        last_time = 0;

        /*
        The time stack is needed to maintain the order of
        the object animations since JSON objects aren't ordered
         */
        time_stack.sort();
        $.each(time_stack, (function(_this) {
          return function(key, time) {
            data.animation[time_stack[key]] = _this.animus.get(animation_stack[time_stack[key]]);
            if (time > last_time) {
              last_time = time;
            }
          };
        })(this));

        /*
        For backgrounds, we allow splitting images into tiles using set rows and
        columns.
         */
        if (context === 'background') {
          data.grid = this.get_grid_data(object);
        }
        duration = object.attr('data-slidea-duration');
        if ((duration == null) && js_data && (js_data.duration != null)) {
          duration = this.delete_property(js_data, 'duration');
        }
        if (this.settings.autoplay === false) {
          data.duration = -1;
        } else if (duration != null) {
          data.duration = parseFloat(duration, 10);
        } else {
          data.duration = parseFloat(default_duration, 10);
        }
        if (object.attr('data-slidea-out') != null) {
          out_animation = object.attr('data-slidea-out');
        } else if (js_data && (js_data.out != null)) {
          out_animation = this.delete_property(js_data, 'out');
        } else if (context === 'background') {
          out_animation = this.settings.animation.out;
        } else {
          out_animation = '';
        }
        if (out_animation !== '') {
          if (context === 'background') {
            if (data.duration === -1 || data.duration > last_time + data.animation[last_time].duration) {
              end_time = data.duration;
            } else {
              end_time = last_time + data.animation[last_time].duration;
            }
          } else {
            end_time = data.duration;
          }
          data.animation[end_time] = this.animus.get(out_animation);
        }

        /*
        Set reset state by getting all the animation variables
        and setting them to the default values
         */
        if ($.type(data.animation[data.start].state) !== 'string') {
          data.animation.initial = {
            timeline: null,
            duration: 0,
            state: this.animus.reset(data.animation[data.start].state, data.animation)
          };
          if (!('opacity' in data.animation.initial.state)) {
            data.animation.initial.state.opacity = 1;
          }
          data.animation[data.start].state = this.animus.reset(initial_animation_override.state, data.animation);
          if ('ease' in data.animation.initial.state) {
            data.animation[data.start].state.ease = data.animation.initial.state.ease;
          }
        }
        if (object.attr('data-slidea-loop') != null) {
          data.loop = parseInt(last_time) + data.animation[last_time].duration * 1000;
          data.loop_diff = data.start + data.animation[data.start].duration * 1000;
        } else if (js_data && (js_data.loop != null)) {
          data.loop = parseInt(last_time) + data.animation[last_time].duration * 1000;
          data.loop_diff = data.start + data.animation[data.start].duration * 1000;
          this.delete_property(js_data, 'loop');
        } else {
          data.loop = false;
        }
        if (js_data && (js_data.callback != null)) {
          data.callback = js_data.callback;
        }
        this["eval"].modules('get_data', [data, index, context, context_index, object, image, default_duration]);
        return data;
      };

      /*
      Get grid data for the given background object
       */
      this.get_grid_data = (function(_this) {
        return function(object) {
          var columns, grid, rows, stagger;
          grid = {};
          rows = object.attr('data-slidea-grid-rows');
          grid.rows = rows != null ? parseInt(rows, 10) : _this.settings.grid.rows;
          columns = object.attr('data-slidea-grid-columns');
          grid.columns = columns != null ? parseInt(columns, 10) : _this.settings.grid.columns;
          stagger = object.attr('data-slidea-grid-stagger');
          grid.stagger = stagger != null ? parseInt(stagger, 10) : _this.settings.grid.stagger;
          if (grid.columns > 1 || grid.rows > 1) {
            grid.enabled = true;
            object.addClass('slidea-grid-slide');
          }
          return grid;
        };
      })(this);

      /*
      Get the size of an image element
       */
      this.get_image_size = (function(_this) {
        return function(image) {
          var size;
          size = {};
          size.width = image[0].naturalWidth != null ? image[0].naturalWidth : image[0].width != null ? image[0].width : image.width != null ? image.width() : 'auto';
          size.height = image[0].naturalHeight != null ? image[0].naturalHeight : image[0].height != null ? image[0].height : image.height != null ? image.height() : 'auto';
          return size;
        };
      })(this);

      /*
      Verify if the first required slides have been loaded
       */
      this.check_loaded = (function(_this) {
        return function(callback) {
          var dynamic, initial;
          initial = _this.loaded;
          if (_this.settings.preload === 'fast') {
            dynamic = 'load_first';
            _this.loaded = _this.slides_loaded.indexOf(_this.prev) !== -1 && _this.slides_loaded.indexOf(_this.first_slide) !== -1 && _this.slides_loaded.indexOf(_this.next) !== -1;
            if (_this.slides_loaded.length === _this.slides_length) {
              _this["eval"].layouts('load');
              _this["eval"].modules('load');
            }
          } else {
            dynamic = 'load';
            _this.loaded = _this.slides_loaded.length === _this.slides_length;
          }
          if (!initial && _this.loaded) {
            _this.log("Required number of slides has been loaded.");
            _this["eval"].layouts(dynamic);
            _this["eval"].modules(dynamic);
            _this.element.trigger('slidea.load');
            callback.call();
          }
        };
      })(this);

      /*
      Load function to imagesLoaded images and cache slide animations
       */
      this.load = function(callback) {
        this.slides_loaded = [];
        return this.slides.each((function(_this) {
          return function(index, slide) {
            var images_loaded, slide_images;
            slide = $(slide);
            slide_images = $('img', slide);
            if (slide_images.length === 0) {
              _this.log("No images to load for slide " + index + ".");
              _this.get_slide_data(index);
              _this.slides_loaded.push(index);
              _this.check_loaded(callback);
              return;
            }
            images_loaded = 0;
            slide_images.each(function(image_index, image) {
              var image_loader, src;
              if ($(image).attr('data-slidea-src') != null) {
                src = $(image).attr('data-slidea-src');
              } else {
                src = $(image).attr('src');
              }
              image_loader = $("<img>");
              image_loader.attr('src', src);
              image_loader.load(function() {
                $(image).attr('src', src);
                images_loaded += 1;
                if (images_loaded === slide_images.length) {
                  _this.log("Loaded images for slide " + index + ".");
                  _this.get_slide_data(index);
                  _this["eval"].layouts('resize_slide', [index]);
                  _this.slides_loaded.push(index);
                  _this.check_loaded(callback);
                }
              });
            });
          };
        })(this));
      };

      /*
      Checks if given element is an image and returns it,
      otherwise it returns null
       */
      this.check_image = (function(_this) {
        return function(element) {
          if (element.is('img')) {
            return element;
          } else {
            return null;
          }
        };
      })(this);

      /*
      Resize the slider by setting sizes in current context
       */
      this.resize = (function(_this) {
        return function() {
          _this["eval"].modules('before_resize');
          _this.set_responsive_context();
          _this.set_parent_sizes();
          _this["eval"].layouts('resize');
          _this["eval"].modules('resize');
          _this.log("Slider elements have been resized.");
        };
      })(this);

      /*
      Binds the slider window resize event to cache current window
      width and height and to set the layout up
       */
      this.bind_resize = (function(_this) {
        return function() {
          _this.window.resize(function() {
            _this.resize();
            _this.element.trigger('slidea.resize', [_this.window_width, _this.window_height, _this.current_responsive_size]);
          });
          _this.log("Bound window resize event.");
        };
      })(this);

      /*
      Binds the slider window resize event to cache current window
      width and height and to set the layout up
       */
      this.bind_focus = (function(_this) {
        return function() {
          if (!(_this.settings.autoplay && _this.settings.pauseOnBlur)) {
            return;
          }
          _this.window.focus(function() {
            _this.unpause_timer();
          });
          _this.window.blur(function() {
            _this.pause_timer();
          });
        };
      })(this);

      /*
      Bind inner button links
       */
      this.bind_inner_links = (function(_this) {
        return function() {
          $('[data-slidea-href]', _this.element).each(function(index, element) {
            var href;
            element = $(element);
            href = element.attr('data-slidea-href');
            if (/^[0-9]+/.test(href)) {
              href = parseInt(href);
            } else if (/^\#[a-zA-Z\_][a-zA-Z0-9\_\-]*/.test(href)) {
              if (!$(href).hasClass('slidea-slide')) {
                return;
              }
              href = $(href).index();
            }
            element.on('click', function() {
              _this.slide(href);
            });
          });
        };
      })(this);

      /*
      Set the z-index of each of the @layers
       */
      this.set_layers_zindex = (function(_this) {
        return function() {
          _this.log("Setting layer z-index starting from " + _this.settings.layerIndex + ".");
          _this.slides.each(function(si, slide) {
            var layer_count, layers;
            layers = $(".slidea-layer-wrapper", $(slide));
            layer_count = layers.length;
            layers.each(function(li, layer) {
              $(layer).css("z-index", _this.settings.layerIndex + layer_count - li);
            });
          });
        };
      })(this);

      /*
      Set current responsive range parameter as xs,sm,md or lg
       */
      this.set_responsive_context = (function(_this) {
        return function() {
          if (_this.window_width >= _this.settings.screen.xlg) {
            _this.current_responsive_size = 'xlg';
          } else if (_this.window_width >= _this.settings.screen.lg) {
            _this.current_responsive_size = 'lg';
          } else if (_this.window_width >= _this.settings.screen.md) {
            _this.current_responsive_size = 'md';
          } else if (_this.window_width >= _this.settings.screen.sm) {
            _this.current_responsive_size = 'sm';
          } else {
            _this.current_responsive_size = 'xs';
          }
          _this.log("Responsive context is \"" + _this.current_responsive_size + "\".");
        };
      })(this);

      /*
      Sets the size of the slide relevant parents
       */
      this.set_parent_sizes = (function(_this) {
        return function() {
          _this.window_width = _this.window.width();
          _this.window_height = _this.window.height();
          _this.parent_width = _this.parent.width();
          _this.parent_height = _this.parent.height();
          _this.wrapper_width = _this.wrapper.width();
          _this.wrapper_height = _this.wrapper.height();
          _this.log("Parent size is " + _this.parent_width + " x " + _this.parent_height);
          _this.log("Window size is " + _this.window_width + " x " + _this.window_height);
          _this.log("Wrapper size is " + _this.wrapper_width + " x " + _this.wrapper_height);
        };
      })(this);

      /*
      Add the actual classes to the Slidea selector classes
       */
      this.add_classes = (function(_this) {
        return function() {
          _this.log("Added additional classes.");
        };
      })(this);

      /*
      Wrap all the elements into slidea specific classes
       */
      this.wrap_objects = (function(_this) {
        return function() {
          $(_this.settings.selector.slide, _this.element).each(function(i, slide) {
            return $(_this.settings.selector.background + ', ' + _this.settings.selector.layer, $(slide)).wrapAll("<div class=\"" + (_this.settings.selector.canvas.substring(1)) + "\"></div>");
          }).wrapAll("<div class=\"" + (_this.settings.selector.wrapper.substring(1)) + "\"><div class=\"" + (_this.settings.selector.inner.substring(1)) + "\"></div></div>");
          $(_this.settings.selector.content, _this.element).wrap("<div class=\"" + (_this.settings.selector.contentWrapper.substring(1)) + "\"></div>");
          $(_this.settings.selector.background, _this.element).wrap("<div class=\"" + (_this.settings.selector.backgroundWrapper.substring(1)) + "\"></div>");
          $(_this.settings.selector.layer, _this.element).wrap("<div class=\"" + (_this.settings.selector.layerWrapper.substring(1)) + "\"></div>");
          _this["eval"].layouts('wrap_objects');
          _this["eval"].modules('wrap_objects');
        };
      })(this);

      /*
      Check if element has data-slidea-settings which override default init settings
       */
      this.set_data_settings = (function(_this) {
        return function() {
          if (_this.element.attr("data-slidea-in") != null) {
            _this.settings.animation["in"] = _this.element.attr("data-slidea-in");
          }
          if (_this.element.attr("data-slidea-out") != null) {
            _this.settings.animation.out = _this.element.attr("data-slidea-out");
          }
          if (_this.element.attr("data-slidea-duration") != null) {
            _this.settings.duration = _this.element.attr("data-slidea-duration");
          }
          if (_this.element.attr("data-slidea-layout") != null) {
            _this.settings.layout = _this.element.attr("data-slidea-layout");
          }
          _this.log("Gathered slider data settings.");
        };
      })(this);

      /*
      Set default animation parameters for Slidea animation objects
      and create animus model
       */
      this.init_animus = (function(_this) {
        return function() {
          var override;
          override = {
            duration: _this.settings.animation.duration,
            easing: _this.settings.animation.easing
          };
          _this.animus = new $.animus(override);
          _this.log("Initialized animus parser.");
        };
      })(this);

      /*
      Clears all the set timeouts for the chosen slide in order to stop all
      programmed animations.
      
      @version 2.0 Loop timeouts must also be cleared after every slide
       */
      this.clear_timeouts = (function(_this) {
        return function(i) {
          if ('background' in _this.data[i]) {
            $.each(_this.data[i].background, function(index) {
              $.each(_this.data[i].background[index].animation, function(animate_index) {
                clearTimeout(_this.data[i].background[index].animation[animate_index].timeline);
              });
              if ('loop_timeout' in _this.data[i].background[index]) {
                return clearTimeout(_this.data[i].background[index].loop_timeout);
              }
            });
          }
          if ('layer' in _this.data[i]) {
            $.each(_this.data[i].layer, function(index) {
              $.each(_this.data[i].layer[index].animation, function(animate_index) {
                clearTimeout(_this.data[i].layer[index].animation[animate_index].timeline);
              });
              if ('loop_timeout' in _this.data[i].layer[index]) {
                clearTimeout(_this.data[i].layer[index].loop_timeout);
              }
            });
          }
          if ('object' in _this.data[i]) {
            $.each(_this.data[i].object, function(index) {
              $.each(_this.data[i].object[index].animation, function(animate_index) {
                clearTimeout(_this.data[i].object[index].animation[animate_index].timeline);
              });
              if ('loop_timeout' in _this.data[i].object[index]) {
                clearTimeout(_this.data[i].object[index].loop_timeout);
              }
            });
          }
          _this.log("Cleared timeouts for slide " + i + ".");
        };
      })(this);

      /*
      Pause autoplay when mouse is over @element
       */
      this.pause_timer = (function(_this) {
        return function() {
          var current_time;
          current_time = new Date;
          _this.timer.remaining = _this.timer.remaining - (current_time - _this.timer.start);
          clearTimeout(_this.timer.clock);
          _this["eval"].modules('pause');
          _this.element.trigger('slidea.pause');
        };
      })(this);

      /*
      Unpause timer when hovering over @element
       */
      this.unpause_timer = (function(_this) {
        return function() {
          var next_slide;
          next_slide = _this.current === -1 ? 1 : _this.current + 1;
          clearTimeout(_this.timer.clock);
          _this.timer.start = new Date;
          _this.timer.clock = setTimeout((function() {
            _this.slide(next_slide);
          }), _this.timer.remaining);
          _this["eval"].modules('resume');
          _this.element.trigger('slidea.resume');
        };
      })(this);

      /*
      Helper method
       */
      this.next = (function(_this) {
        return function() {
          _this.slide(_this.current + 1);
        };
      })(this);

      /*
      Helper method
       */
      this.prev = (function(_this) {
        return function() {
          _this.slide(_this.current - 1);
        };
      })(this);

      /*
      Debounce helper to make resize happen every n milliseconds
       */
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

      /*
      Delete an object property and return its value
       */
      this.delete_property = function(object, property) {
        var temporary;
        temporary = object[property];
        delete object[property];
        return temporary;
      };

      /*
      Get a random id by concatenating input string
      with a random number
       */
      this.get_random_id = function(string) {
        return string + '-' + Math.floor((Math.random() * 1000) + 1);
      };

      /*
      Extend given default settings with user input
       */
      this.extend_settings = (function(_this) {
        return function(id, defaults) {
          if (_this.settings[id] != null) {
            return _this.settings[id] = $.extend({}, defaults, _this.settings[id]);
          } else {
            return _this.settings[id] = defaults;
          }
        };
      })(this);

      /*
      Logger snippet within Slidea
       */
      this.log = (function(_this) {
        return function(item) {
          if (!_this.debug) {
            return;
          }
          if (typeof item === 'object') {
            console.log("[Slidea]", item);
          } else {
            console.log("[Slidea] " + item);
          }
        };
      })(this);

      /*
      Error logger snippet within Slidea
       */
      this.error = (function(_this) {
        return function(item) {
          if (!_this.debug) {
            return;
          }
          if (typeof item === 'object') {
            console.error("[Slidea]", item);
          } else {
            console.error("[Slidea] " + item);
          }
        };
      })(this);
      this.initialize();
    };
    $.slidea.modules = {};
    $.slidea.register_module = function(name, module) {
      $.slidea.modules[name] = module;
    };
    $.slidea.layouts = {};
    $.slidea.register_layout = function(name, layout) {
      $.slidea.layouts[name] = layout;
    };

    /*
    Lightweight plugin wrapper that prevents multiple instantiations.
     */
    return $.fn.slidea = function(opts) {
      return this.each(function(index, element) {
        if (!$.data(element, "slidea")) {
          return $.data(element, "slidea", new $.slidea(element, opts));
        }
      });
    };
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.contentScaling = function() {

      /*
      Enable or disable content scaling feature
       */
      var scale_content;
      this.settings = {
        enabled: false,
        mode: 'responsive',
        factor: {
          xs: 1,
          sm: 1,
          md: 1,
          lg: 1,
          xlg: 1
        }
      };
      scale_content = function(index) {
        var calculated_width, content, content_width, current_slide, origin_x, origin_y, scaling_reference, scaling_value;
        if (index === -1) {
          return;
        }
        current_slide = this.slides.eq(index);
        content = $('.slidea-content', current_slide);
        origin_x = '0%';
        if (content.hasClass('slidea-content-center')) {
          origin_y = '50%';
        } else if (content.hasClass('slidea-content-bottom')) {
          origin_y = '100%';
        } else {
          origin_y = '0%';
        }
        content_width = content.width();
        calculated_width = this.wrapper_width;
        if (this.settings.contentScaling.mode === 'responsive') {
          scaling_value = this.settings.contentScaling.factor[this.current_responsive_size];
          this.animate.set(content, {
            scale: scaling_value,
            x: (calculated_width - content_width * scaling_value) / 2,
            transformOriginX: origin_x,
            transformOriginY: origin_y
          });
        } else {
          scaling_reference = this.data[index].background[0].width;
          scaling_value = calculated_width / scaling_reference * this.settings.contentScaling.factor[this.current_responsive_size];
          if (this.settings.contentScaling.factor[this.current_responsive_size] === 1) {
            this.animate.set(content, {
              x: 0
            });
          } else {
            this.animate.set(content, {
              x: calculated_width * (1 - this.settings.contentScaling.factor[this.current_responsive_size]) / 2
            });
          }
          this.animate.set(content, {
            z: 0,
            transformOriginX: origin_x,
            transformOriginY: origin_y,
            scaleX: scaling_value,
            scaleY: scaling_value
          });
        }
        this.log("Content has been scaled with " + scaling_value + ".");
      };

      /*
      Scale content on window resize
       */
      this.slide = function(from, to) {
        scale_content.call(this, to);
      };
      this.resize = function() {
        scale_content.call(this, this.current);
      };
    };
    return $.slidea.register_module('contentScaling', $.fn.slidea.contentScaling);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.controls = function() {

      /*
      Set up slider controls
       */
      this.settings = {
        enabled: false,
        thumbnail: false,
        html: {
          prev: "&lt;",
          next: "&gt;"
        },
        "class": "slidea-controls-alternate"
      };

      /*
      Slider Initialization Event
       */
      this.initialize = function() {
        if (this.slides_length === 1) {
          this.settings.controls.enabled = false;
        }
      };

      /*
      Update slide data
       */
      this.get_slide_data = function(index, slide) {
        var thumbnail;
        if (this.settings.controls.thumbnail && (this.data[index].thumbnail == null)) {
          thumbnail = slide.attr('data-slidea-thumbnail');
          if (thumbnail != null) {
            this.data[index].thumbnail = thumbnail;
          } else {
            this.data[index].thumbnail = $(this.settings.selector.background, slide).attr('src');
          }
        }
      };

      /*
      Add controls to the slider
       */
      this.load = function() {
        var alt, control, html, j, len, ref;
        html = '';
        ref = ['next', 'prev'];
        for (j = 0, len = ref.length; j < len; j++) {
          control = ref[j];
          alt = control.toLowerCase().replace(/\b[a-z]/g, function(letter) {
            return letter.toUpperCase();
          });
          html += '<a href="javascript:void(0);" class="slidea-control slidea-' + control + ' ' + this.settings.controls["class"] + '">';
          html += '<div class="slidea-control-inner">';
          if (this.settings.controls.thumbnail === true) {
            html += '<div class="slidea-control-thumbnail">';
            html += '<img src="" alt="' + alt + ' Slide" class="slidea-control-image"/>';
            html += '</div>';
          }
          html += '<div class="slidea-control-text">';
          html += this.settings.controls.html[control];
          html += '</div>';
          html += '</div>';
          html += '</a>';
        }
        this.wrapper.append(html);
        this.prev_button = $(this.settings.selector.prev, this.element);
        this.prev_button.on('click', (function(_this) {
          return function() {
            _this.slide(_this.current - 1);
          };
        })(this));
        this.next_button = $(this.settings.selector.next, this.element);
        this.next_button.on('click', (function(_this) {
          return function() {
            _this.slide(_this.current + 1);
          };
        })(this));
        if (this.settings.controls.thumbnail === true) {
          this.prev_thumbnail = $('.slidea-control-image', this.prev_button);
          this.next_thumbnail = $('.slidea-control-image', this.next_button);
        }
      };

      /*
      Run on slide modifiers for controls
       */
      this.slide = function(from, to) {
        if (this.settings.controls.thumbnail) {
          this.prev_thumbnail.attr('src', this.data[this.prev].thumbnail);
          this.next_thumbnail.attr('src', this.data[this.next].thumbnail);
          this.log("Changed control thumbnails to prev[" + from + "] and next[" + to + "].");
        }
      };
    };
    return $.slidea.register_module('controls', $.fn.slidea.controls);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.keyboard = function() {

      /*
      Enable or disable keyboard handler
       */
      this.settings = true;

      /*
      Add keyboard bindings
       */
      this.load = function() {
        $(document).keydown((function(_this) {
          return function(e) {
            switch (e.which) {
              case 37:
                return _this.slide(_this.current - 1);
              case 39:
                return _this.slide(_this.current + 1);
            }
          };
        })(this));
        this.log("Bound keyboard arrows event.");
      };
    };
    return $.slidea.register_module('keyboard', $.fn.slidea.keyboard);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.loader = function() {

      /*
      Enable or disable loader component
       */
      this.settings = true;

      /*
      Add the loader element if it hasn't been added with HTML
       */
      this.initialize = function() {
        var html;
        if ($(".slidea-loader-wrapper", this.element).length === 0) {
          html = "";
          html += '<div class="slidea-loader-wrapper">';
          html += '<div class="slidea-loader">';
          html += '<div class="slidea-loader-inner">';
          html += '<div class="slidea-loader-tile"></div>';
          html += '<div class="slidea-loader-tile"></div>';
          html += '<div class="slidea-loader-tile"></div>';
          html += '<div class="slidea-loader-tile"></div>';
          html += '<div class="slidea-loader-tile"></div>';
          html += '</div>';
          html += '</div>';
          html += '</div>';
          this.element.prepend(html);
          this.log("No loader found. Added default loader.");
        } else {
          this.log("Loader markup already exists.");
        }
        this.loader = $(".slidea-loader-wrapper", this.element);
      };

      /*
      When all the slider images have been loaded, hide the
      loading spinner
       */
      this.load = function() {
        this.animate.to(this.loader, 0.5, {
          opacity: 0,
          onComplete: (function(_this) {
            return function() {
              _this.loader.css({
                display: 'none'
              });
              _this.log("Loader element faded out.");
            };
          })(this)
        });
      };
    };
    return $.slidea.register_module('loader', $.fn.slidea.loader);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.mousewheel = function() {

      /*
      Enable or disable mousewheel handler
       */
      this.settings = false;

      /*
      Add mousewheel handler
      @require mousewheel.js
       */
      this.load = function() {
        var enable_timeout, enabled;
        enabled = true;
        enable_timeout = 750;
        this.element.mousewheel((function(_this) {
          return function(event) {
            if (!enabled) {
              return;
            }
            enabled = false;
            if (event.deltaY === -1) {
              _this.slide(_this.current + 1);
            }
            if (event.deltaY === 1) {
              _this.slide(_this.current - 1);
            }
            if (_this.settings.prevent_scrolling === true) {
              event.preventDefault();
            }
            setTimeout(function() {
              enabled = true;
            }, enable_timeout);
          };
        })(this));
        this.log("Bound mousewheel event.");
      };
    };
    return $.slidea.register_module('mousewheel', $.fn.slidea.mousewheel);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.pagination = function() {

      /*
      Set up pagination component
       */
      this.settings = {
        enabled: false,
        position: "bottom",
        "class": "slidea-pagination-light"
      };

      /*
      Add pagination bullets to the slider
       */
      this.initialize = function() {
        var html, i, pagination, position;
        if (this.slides_length === 1) {
          return;
        }
        position = "slidea-pagination-" + this.settings.pagination.position;
        html = "";
        html += "<div class=\"slidea-pagination " + position + " " + this.settings.pagination["class"] + "\">";
        i = 0;
        while (i < this.slides_length) {
          html += "<div class=\"slidea-pagination-bullet\"></div>";
          i++;
        }
        html += "</div>";
        pagination = $(html);
        switch (this.settings.pagination.position) {
          case "before":
            this.element.before(pagination);
            break;
          case "after":
            this.element.after(pagination);
            break;
          default:
            this.element.prepend(pagination);
        }
        this.pagination = $(".slidea-pagination-bullet", pagination);
        this.pagination.each((function(_this) {
          return function(i, el) {
            var pagination_bullet;
            pagination_bullet = $(el);
            pagination_bullet.on("click", function() {
              _this.pagination.filter(".active").removeClass("active");
              pagination_bullet.addClass("active");
              _this.slide(i);
            });
          };
        })(this));
      };
      this.slide = function(from, to) {
        this.pagination.filter('.active').removeClass('active');
        this.pagination.eq(to).addClass('active');
      };
    };
    return $.slidea.register_module('pagination', $.fn.slidea.pagination);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.pauseOnHover = function() {

      /*
      Enable or disable pause on hover feature
       */
      this.settings = false;

      /*
      Pause the slider on mouse hover
       */
      this.load = function() {
        this.element.on('mouseenter', (function(_this) {
          return function() {
            _this.pause_timer();
          };
        })(this));
        this.element.on('mouseleave', (function(_this) {
          return function() {
            _this.unpause_timer();
          };
        })(this));
        this.log("Enabled pause on hover.");
      };
    };
    return $.slidea.register_module('pauseOnHover', $.fn.slidea.pauseOnHover);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.preventDragging = function() {

      /*
      Enable or disable image dragging
       */
      this.settings = true;
      this.initialize = function() {
        $("img", this.element).on("dragstart", (function(_this) {
          return function(event) {
            event.preventDefault();
          };
        })(this));
      };
    };
    return $.slidea.register_module('preventDragging', $.fn.slidea.preventDragging);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.progressBar = function() {

      /*
      Set up progress bar element
       */
      this.settings = {
        enabled: false,
        position: "bottom",
        "class": "slidea-progress-light"
      };

      /*
      Add progress bar
       */
      this.load = function() {
        var html, position;
        position = (this.settings.progress.position === "top" ? "slidea-progress-top" : "slidea-progress-bottom");
        html = "";
        html += "<div class=\"slidea-progress " + position + " " + this.settings.progress["class"] + "\">";
        html += "<div class=\"slidea-progress-bar\">";
        html += "</div>";
        html += "</div>";
        this.element.prepend(html);
        this.progress = {};
        this.progress.element = $(".slidea-progress", this.element);
        this.progress.bar = $(".slidea-progress-bar", this.element);
      };

      /*
      Animate progress bar from 0% to 100%
       */
      this.slide = function(from, to) {
        if (this.progress_animation) {
          this.progress_animation.kill();
        }
        this.progress_animation = this.animate.fromTo(this.progress.bar, this.timer.remaining / 1000, {
          width: '0%'
        }, {
          width: '100%'
        });
      };
      this.pause = function() {
        this.progress_animation.pause();
      };
      this.resume = function() {
        this.progress_animation.resume();
      };
    };
    return $.slidea.register_module('progress', $.fn.slidea.progressBar);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.retina = function() {

      /*
      Enable or disable retina feature
       */
      this.settings = true;
      this.initialize = function() {
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
          this.log("This device has a retina display.");
          $('img[data-slidea-at2x]', $slide).each((function(_this) {
            return function(index, element) {
              var img, retina_src, src;
              img = $(element);
              src = img.attr('data-slidea-src');
              retina_src = img.attr('data-slidea-at2x');
              if (retina_src === "true") {
                src = src.replace(/(\.[\w\?=]+)$/, "@2x$1");
              } else {
                src = retina_src;
              }
              _this.log("Found a Retina image with src=\"" + src + "\".");
              img.attr('data-slidea-src', src);
            };
          })(this));
        } else {
          this.log("This device doesn't have a Retina display.");
        }
      };
    };
    return $.slidea.register_module('retina', $.fn.slidea.retina);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.scroller = function() {

      /*
      Set up scroller component
       */
      this.settings = {
        enabled: false,
        markup: "<span class=\"slidea-scroller-1\"></span>",
        position: "center"
      };
      this.load = function() {
        var scroller;
        scroller = "<div class=\"slidea-scroller-wrapper slidea-scroller-" + this.settings.scroller.position + "\">";
        scroller += this.settings.scroller.markup;
        scroller += "</div>";
        this.scroller = $(scroller);
        this.element.prepend(this.scroller);
        this.scroller.on("click", (function(_this) {
          return function() {
            $("html, body").animate({
              scrollTop: _this.element.height()
            }, 1000);
          };
        })(this));
      };
    };
    return $.slidea.register_module('scroller', $.fn.slidea.scroller);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.thumbnails = function() {

      /*
      Set up slider thumbnails
       */
      var resize_wrapper, scroll_to_thumbnail;
      this.settings = {
        enabled: false,
        visible: {
          xs: 12,
          sm: 6,
          md: 6,
          lg: 5,
          xlg: 5
        },
        position: "bottom",
        "class": ""
      };

      /*
      Scroll to the nth thumbnail in the collection
       */
      scroll_to_thumbnail = function(to) {
        var distance, transform;
        if (to < 0) {
          to = 0;
        }
        distance = 0;
        this.thumbnails.elements.each((function(_this) {
          return function(index, item) {
            if (index === to) {
              return false;
            }
            if (_this.settings.thumbnails.orientation === 'horizontal') {
              distance += $(item).width();
            } else if (_this.settings.thumbnails.orientation === 'vertical') {
              distance += $(item).height();
            }
          };
        })(this));
        if (this.thumbnails.size - distance < this.thumbnails.parent_size) {
          distance = this.thumbnails.size - this.thumbnails.parent_size;
        }
        this.thumbnails.starting_position = -distance;
        if (this.settings.thumbnails.orientation === 'horizontal') {
          transform = 'translate3d(' + (-distance) + 'px, 0, 0)';
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          transform = 'translate3d(0, ' + (-distance) + 'px, 0)';
        }
        this.thumbnails.inner.addClass('animating').css({
          'transform': transform,
          '-o-transform': transform,
          '-ms-transform': transform,
          '-moz-transform': transform,
          '-webkit-transform': transform
        });
        setTimeout((function(_this) {
          return function() {
            _this.thumbnails.inner.removeClass('animating');
          };
        })(this), 700);
      };

      /*
      Resize thumbnails wrapper
       */
      resize_wrapper = function() {
        var obj, thumbnail_height, thumbnail_width;
        if (!this.thumbnails.loaded) {
          return;
        }
        if (this.settings.thumbnails.orientation === 'horizontal') {
          thumbnail_height = $('img', this.thumbnails.elements.eq(0)).height();
          this.thumbnails.container.height(thumbnail_height);
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          thumbnail_width = $('img', this.thumbnails.elements.eq(0)).width();
          this.parent.css((
            obj = {},
            obj["padding-" + this.settings.thumbnails.position] = thumbnail_width,
            obj
          ));
          this.thumbnails.container.width($('img', this.thumbnails.elements.eq(0)).width());
        }
      };

      /*
      Update slide data
       */
      this.get_slide_data = function(index, slide) {
        var thumbnail;
        if (this.data[index].thumbnail == null) {
          thumbnail = slide.attr('data-slidea-thumbnail');
          if (thumbnail != null) {
            this.data[index].thumbnail = thumbnail;
          } else {
            this.data[index].thumbnail = $(this.settings.selector.background, slide).attr('src');
          }
        }
      };

      /*
      Initialize thumbnails
       */
      this.initialize = function() {
        this.thumbnails.loaded = false;
      };

      /*
      Wrap slidea inside a thumbnails wrapper for position handling
       */
      this.wrap_objects = function() {
        this.thumbnails = {};
        this.element.wrap("<div class=\"slidea-with-thumbnails " + this.settings.thumbnails.position + "\"><div class='slidea-with-thumbnails-container'></div></div>");
        this.parent = this.element.parent();
        this.thumbnails.parent = this.parent.parent();
      };

      /*
      Add thumbnails to the slider
       */
      this.load = function() {
        var css_param, html, individual_size, inner_size, pan_events, parent_height, parent_width, thumbs_count, touch_thumbnails;
        if (['left', 'right'].indexOf(this.settings.thumbnails.position) !== -1) {
          this.settings.thumbnails.orientation = 'vertical';
        } else {
          this.settings.thumbnails.orientation = 'horizontal';
        }
        thumbs_count = this.settings.thumbnails.visible[this.current_responsive_size];
        parent_height = this.wrapper_height;
        parent_width = this.wrapper_width;
        if (this.settings.thumbnails.orientation === 'horizontal') {
          individual_size = parent_width / thumbs_count;
          inner_size = individual_size * this.slides_length;
          css_param = 'width';
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          individual_size = parent_height / thumbs_count;
          inner_size = individual_size * this.slides_length;
          css_param = 'height';
        }
        html = "";
        html += "<div class=\"slidea-thumbnails-container\">";
        html += "<div class=\"slidea-thumbnails " + this.settings.thumbnails["class"] + " " + this.settings.thumbnails.orientation + "\">";
        html += ("<div class=\"slidea-thumbnails-inner\" style=\"" + css_param + ": ") + inner_size + "px;\">";
        $.each(this.data, function(index, item) {
          html += ("<div class=\"slidea-thumbnail-wrapper\" style=\"" + css_param + ": ") + individual_size + "px;\">";
          html += "<img class=\"slidea-thumbnail\" src=\"" + item.thumbnail + "\" alt=\"Slide " + index + "\" />";
          return html += "</div>";
        });
        html += "</div>";
        html += "</div>";
        html += "</div>";
        this.thumbnails.wrapper = $(html);
        if (["top", "left", "right"].indexOf(this.settings.thumbnails.position) !== -1) {
          this.element.closest('.slidea-with-thumbnails').prepend(this.thumbnails.wrapper);
        } else if (this.settings.thumbnails.position === "bottom") {
          this.element.closest('.slidea-with-thumbnails').append(this.thumbnails.wrapper);
        } else {
          this.settings.thumbnails.position.append(this.thumbnails.wrapper);
        }
        this.thumbnails.inner = $(".slidea-thumbnails-inner", this.thumbnails.wrapper);
        this.thumbnails.elements = $(".slidea-thumbnail-wrapper", this.thumbnails.wrapper);
        this.thumbnails.container = $('.slidea-thumbnails-container', this.thumbnails.parent);
        if (this.settings.thumbnails.orientation === 'horizontal') {
          this.thumbnails.size = this.thumbnails.inner.width();
          this.thumbnails.parent_size = this.thumbnails.wrapper.width();
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          this.thumbnails.size = this.thumbnails.inner.height();
          this.thumbnails.parent_size = this.thumbnails.wrapper.height();
        }
        this.thumbnails.elements.each((function(_this) {
          return function(i, el) {
            var $thumbnail;
            $thumbnail = $(el);
            $thumbnail.on("click", function() {
              _this.thumbnails.elements.filter(".active").removeClass("active");
              $thumbnail.addClass("active");
              _this.slide(i);
            });
          };
        })(this));
        $("img", this.thumbnails.elements).on("dragstart", function(event) {
          event.preventDefault();
        });
        this.thumbnails.starting_position = 0;
        this.thumbnails.starting_direction = void 0;
        if (this.settings.touch === true) {
          touch_thumbnails = new Hammer(this.thumbnails.wrapper[0]);
          if (this.settings.thumbnails.orientation === 'horizontal') {
            pan_events = 'panleft panright';
            touch_thumbnails.get('pan').set({
              direction: Hammer.DIRECTION_HORIZONTAL
            });
          } else if (this.settings.thumbnails.orientation === 'vertical') {
            pan_events = 'panup pandown';
            touch_thumbnails.get('pan').set({
              direction: Hammer.DIRECTION_VERTICAL
            });
          }
          touch_thumbnails.on("panstart pancancel panend " + pan_events, (function(_this) {
            return function(event) {
              var distance, snap_distance, transform;
              if (_this.settings.thumbnails.orientation === 'horizontal') {
                distance = event.deltaX;
              } else if (_this.settings.thumbnails.orientation === 'vertical') {
                distance = event.deltaY;
              }
              if (_this.settings.thumbnails.orientation === 'horizontal' && event.type === 'panleft' || event.type === 'panright') {
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
              } else if (_this.settings.thumbnails.orientation === 'vertical' && event.type === 'panup' || event.type === 'pandown') {
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
                _this.thumbnails.inner.addClass('slidea-dragging');
                _this.thumbnails.starting_direction = event.direction;
              } else if (event.type === 'panend') {
                _this.thumbnails.inner.removeClass('slidea-dragging');
                _this.thumbnails.starting_position += distance;
                if (_this.thumbnails.starting_position < -_this.thumbnails.size + _this.thumbnails.parent_size) {
                  scroll_to_thumbnail.call(_this, _this.slides_length - 1);
                } else if (_this.thumbnails.starting_position > 0) {
                  scroll_to_thumbnail.call(_this, 0);
                } else {
                  snap_distance = 0;
                  _this.thumbnails.elements.each(function(index, item) {
                    if (_this.thumbnails.starting_position > -snap_distance) {
                      scroll_to_thumbnail.call(_this, index);
                      return false;
                    }
                    if (_this.settings.thumbnails.orientation === 'horizontal') {
                      snap_distance += $(item).width();
                    } else if (_this.settings.thumbnails.orientation === 'vertical') {
                      snap_distance += $(item).height();
                    }
                  });
                }
              }
              event.preventDefault();
            };
          })(this));
        }
        this.thumbnails.loaded = true;
        $('img', this.thumbnails.elements.eq(0)).load((function(_this) {
          return function() {
            _this.resize();
          };
        })(this));
      };
      this.before_resize = function() {
        resize_wrapper.call(this);
      };
      this.resize = function() {
        var css_param, individual_size, inner_size, parent_height, parent_width, thumbs_count;
        if (!this.thumbnails.loaded) {
          return;
        }
        thumbs_count = this.settings.thumbnails.visible[this.current_responsive_size];
        parent_height = this.wrapper_height;
        parent_width = this.wrapper_width;
        if (this.settings.thumbnails.orientation === 'horizontal') {
          individual_size = parent_width / thumbs_count;
          inner_size = individual_size * this.slides_length;
          css_param = 'width';
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          individual_size = parent_height / thumbs_count;
          inner_size = individual_size * this.slides_length;
          css_param = 'height';
        }
        this.thumbnails.inner[css_param](inner_size);
        this.thumbnails.elements[css_param](individual_size);
        if (this.settings.thumbnails.orientation === 'horizontal') {
          this.thumbnails.size = inner_size;
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          this.thumbnails.size = inner_size;
        }
        this.thumbnails.parent_size = this.thumbnails.wrapper[css_param]();
        scroll_to_thumbnail.call(this, this.current);
      };
      this.slide = function(from, to) {
        if (!this.thumbnails.loaded) {
          return;
        }
        this.thumbnails.elements.filter('.active').removeClass('active');
        this.thumbnails.elements.eq(to).addClass('active');
        scroll_to_thumbnail.call(this, to);
        this.log("Scrolled to thumbnail " + to + ".");
      };
    };
    return $.slidea.register_module('thumbnails', $.fn.slidea.thumbnails);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.touch = function() {

      /*
      Enable or disable video features
       */
      this.settings = true;

      /*
      Enable touch handler for the slider.
      @require Hammer.js
       */
      this.load = function() {
        this.touch_object = new Hammer(this.element[0]);
        this.touch_object.get('pan').set({
          direction: Hammer.DIRECTION_HORIZONTAL
        });
        this.touch_object.on('panleft panright', (function(_this) {
          return function(event) {
            if (event.eventType === Hammer.INPUT_START) {
              _this.element.addClass('slidea-dragging');
            } else if (event.eventType === Hammer.INPUT_END || event.eventType === Hammer.INPUT_CANCEL) {
              _this.element.removeClass('slidea-dragging');
              if (event.direction === Hammer.DIRECTION_LEFT) {
                _this.slide(_this.current + 1);
              } else if (event.direction === Hammer.DIRECTION_RIGHT) {
                _this.slide(_this.current - 1);
              }
            }
          };
        })(this));
        this.log("Bound touch pan left and right events.");
      };
    };
    return $.slidea.register_module('touch', $.fn.slidea.touch);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.video = function() {

      /*
      Enable or disable video features
       */
      this.settings = true;

      /*
      Setup video events at slide start for HTML5, YouTube and Vimeo videos
       */
      this.initialize = function() {

        /*
        Handle autoplay timeouts using a timeout timeline
         */
        var delay, i, interval, tries;
        this.video_timeline = {};
        delay = 500;
        interval = void 0;
        i = 0;
        tries = 10;
        $('.slidea-video-background').each(function(index, background) {
          if (!$(background).hasClass('slidea-object')) {
            $(background).addClass('slidea-object');
          }
        });
        $("video.slidea-video", this.element).attr("data-slidea-video-type", "html5");
        $("iframe[data-slidea-src*=\"youtube.com\"].slidea-video", this.element).attr("data-slidea-video-type", "youtube");
        $("iframe[data-slidea-src*=\"vimeo.com\"].slidea-video", this.element).attr("data-slidea-video-type", "vimeo");
        return $(this.settings.selector.video, this.element).each((function(_this) {
          return function(i, el) {
            var controls, id, pause_slider, separator, src, video, video_id, video_type, volume;
            video = $(el);
            volume = video.attr("data-slidea-volume");
            volume = (isNaN(volume) ? 0 : volume);
            controls = video.attr("data-slidea-controls") === "true";
            pause_slider = video.attr("data-slidea-pause-slider") === "true";
            src = video.attr("data-slidea-src");
            video_type = video.attr("data-slidea-video-type");
            if (video.attr("id") == null) {
              video.attr("id", _this.get_random_id("slidea-video"));
            }
            id = video.attr("id");
            if (video_type === "html5") {
              video.get(0).volume = volume;
              if (controls === true) {
                video.attr("controls", "controls");
              }
              if (_this.settings.autoplay === true && pause_slider === true) {
                video.on("play", function() {
                  _this.pause_timer();
                });
                video.on("pause ended", function() {
                  _this.unpause_timer();
                });
              }
            }
            if (video_type === "youtube") {
              video_id = void 0;
              separator = void 0;
              if (src.indexOf("enablejsapi=1") === -1) {
                if (src.indexOf("?") === -1) {
                  video.attr("src", src + "?enablejsapi=1");
                } else {
                  video.attr("src", src + "&enablejsapi=1");
                }
                src = video.attr("src");
              }
              if (src.indexOf("playerapiid=") === -1) {
                if (src.indexOf("?") === -1) {
                  video.attr("src", src + "?playerapiid=" + id);
                } else {
                  video.attr("src", src + "&playerapiid=" + id);
                }
                src = video.attr("src");
              }
              if (src.indexOf("embed") === "-1") {
                video_id = src.split("v=")[1];
                separator = video_id.indexOf("&");
                if (separator !== -1) {
                  video_id = video_id.substring(0, separator);
                }
              } else {
                video_id = src.split("/");
                video_id = video_id[video_id.length - 1];
                separator = video_id.indexOf("?");
                if (separator !== -1) {
                  video_id = video_id.substring(0, separator);
                }
              }
              video.load(function() {
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
                        _this.unpause_timer();
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
                  _this.youtube_player[id].setVolume(volume);
                }, delay);
              });
            }
            if (video_type === "vimeo") {
              if (src.indexOf("api=1") === -1) {
                if (src.indexOf("?") === -1) {
                  video.attr("src", src + "?api=1");
                } else {
                  video.attr("src", src + "&api=1");
                }
                src = video.attr("src");
              }
              if (src.indexOf("player_id=") === -1) {
                if (src.indexOf("?") === -1) {
                  video.attr("src", src + "?player_id=" + id);
                } else {
                  video.attr("src", src + "&player_id=" + id);
                }
                src = video.attr("src");
              }
              video.load(function() {
                _this.vimeo_player[id] = $f(id);
                _this.vimeo_player[id].addEvent("ready", function() {
                  video.attr("data-slidea-ready", "true");
                  _this.vimeo_player[id].api("setVolume", volume);
                  if (_this.settings.autoplay === true && pause_slider === true) {
                    _this.vimeo_player[id].addEvent("play", _this.pause_timer);
                    _this.vimeo_player[id].addEvent("pause", _this.unpause_timer);
                    _this.vimeo_player[id].addEvent("finish", _this.unpause_timer);
                  }
                });
              });
            }
          };
        })(this));
      };

      /*
      Handle video events at slide start for HTML5, YouTube and Vimeo videos
       */
      this.slide = function(from, to) {
        var from_slide, from_videos, to_slide, to_videos;
        from_slide = this.slides.eq(from);
        to_slide = this.slides.eq(to);
        from_videos = $(this.settings.selector.video, from_slide);
        to_videos = $(this.settings.selector.video, to_slide);
        if (from !== -1 && from_videos.length > 0) {
          from_videos.each((function(_this) {
            return function(video_index, video) {
              var id, reset, video_type;
              video = $(video);
              id = video.attr('id');
              video_type = video.attr('data-slidea-video-type');
              reset = video.attr('data-slidea-reset') === 'true';
              clearTimeout(_this.video_timeline[id]);
              if (video_type === 'html5') {
                video.get(0).pause();
                if (reset) {
                  setTimeout((function() {
                    video.get(0).current_time = 0;
                  }), _this.data[to].background[0].animation[0].duration);
                }
              } else if (video_type === 'youtube') {
                _this.youtube_player[id].pauseVideo();
                if (reset) {
                  setTimeout((function() {
                    _this.youtube_player[id].stopVideo();
                  }), _this.data[to].background[0].animation[0].duration);
                }
              } else if (video_type === 'vimeo') {
                _this.vimeo_player[id].api('pause');
                if (reset) {
                  setTimeout((function() {
                    _this.vimeo_player[id].api('unload');
                  }), _this.data[to].background[0].animation[0].duration);
                }
              }
            };
          })(this));
          this.log("Paused (handled) videos from slide " + from + ".");
        }
        if (to_videos.length > 0) {
          to_videos.each((function(_this) {
            return function(index, video) {
              var autoplay, autoplay_time, delay, i, id, interval, pause_slider, tries;
              video = $(video);
              id = video.attr('id');
              i = 0;
              tries = 10;
              delay = 500;
              interval = void 0;
              autoplay = video.attr('data-slidea-autoplay') === 'true';
              if (video.attr('data-slidea-autoplay-time') != null) {
                autoplay_time = parseInt(video.attr('data-slidea-autoplay-time'), 10);
              } else {
                autoplay_time = 100;
              }
              pause_slider = video.attr('data-slidea-pause-slider') === 'true';
              if (video.attr('data-slidea-video-type') === 'html5') {
                if (autoplay === true) {
                  _this.video_timeline[id] = setTimeout((function() {
                    video.get(0).play();
                  }), autoplay_time);
                }
              }
              if (video.attr('data-slidea-video-type') === 'youtube') {
                if (autoplay === true) {
                  i = 0;
                  interval = setInterval(function() {
                    i++;
                    if (i === tries) {
                      clearInterval(interval);
                    } else if ((video.attr('data-slidea-ready') == null) || !defined(_this.youtube_player[id]) || typeof _this.youtube_player[id].playVideo !== 'function') {
                      return;
                    } else {
                      clearInterval(interval);
                    }
                    _this.video_timeline[id] = setTimeout(function() {
                      _this.youtube_player[id].playVideo();
                    }, autoplay_time);
                  }, delay);
                }
              }
              if (video.attr('data-slidea-video-type') === 'vimeo') {
                if (autoplay === true) {
                  i = 0;
                  interval = setInterval(function() {
                    i++;
                    if (i === tries) {
                      clearInterval(interval);
                    } else if ((video.attr('data-slidea-ready') == null) || typeof _this.vimeo_player[id].api !== 'function') {
                      return;
                    } else {
                      clearInterval(interval);
                    }
                    _this.video_timeline[id] = setTimeout(function() {
                      Froogaloop(id).api('play');
                    }, autoplay_time);
                  }, delay);
                }
              }
            };
          })(this));
          this.log("Played (handled) videos from slide " + to + ".");
        }
      };
      this.resize = function() {
        this.slides.each((function(_this) {
          return function(i, element) {
            var data_height, data_width, margin_left, margin_top, slide, video, video_background, video_height, video_width;
            slide = $(element);
            $(_this.settings.selector.video, _this.element).each(function(i, video) {
              var height, parent, width;
              video = $(video);
              parent = video.parent();
              if (parent.is('.slidea-video-background')) {
                return;
              }
              height = parent.height();
              width = parent.width();
              video.css({
                width: width,
                height: height
              });
            });
            video_background = $('.slidea-video-background', slide);
            if (video_background.length > 0) {
              video = $('.video', video_background);
              data_width = parseInt(video.attr('data-slidea-width'));
              data_height = parseInt(video.attr('data-slidea-height'));
              video_width = _this.slider_width;
              video_height = video_width * data_height / data_width;
              margin_left = -(video_width - _this.slider_width) / 2;
              margin_top = -(video_height - _this.slider_height) / 2;
              video.css({
                'width': video_width,
                'height': video_height,
                'margin-left': margin_left,
                'margin-top': margin_top
              });
            }
          };
        })(this));
      };
    };
    return $.slidea.register_module('video', $.fn.slidea.video);
  })(window.jQuery, window, document);

  (function($, window, document) {
    "use strict";
    $.fn.slidea.videoCover = function() {

      /*
      Enable or disable video cover features
       */
      this.settings = true;

      /*
      Set up the video covers so that they fade out and play the
      actual video on click event
       */
      this.load = function() {
        var covers, hide;
        hide = (function(_this) {
          return function(cover) {
            _this.animate.to(cover, 0.5, {
              opacity: 0,
              onComplete: function() {
                cover.css({
                  display: 'none'
                });
              }
            });
          };
        })(this);
        covers = $(this.settings.selector.videoCover, this.element);
        covers.each((function(_this) {
          return function(i, el) {
            var cover, id, parent, type, video;
            cover = $(el);
            parent = cover.parent();
            video = $(_this.settings.selector.video, parent);
            type = video.attr('data-slidea-video-type');
            id = video.attr("id");
            switch (type) {
              case "html5":
                cover.on("click", function() {
                  video.get(0).play();
                  hide(cover);
                });
                break;
              case "youtube":
                cover.on("click", function() {
                  _this.youtube_player[id].playVideo();
                  hide(cover);
                });
                break;
              case "vimeo":
                cover.on("click", function() {
                  _this.vimeo_player[id].api("play");
                  hide(cover);
                });
            }
          };
        })(this));
        if (covers.length > 0) {
          this.log("Added video cover events.");
        }
      };

      /*
      Animate progress bar from 0% to 100%
       */
      this.slide = function(from, to) {
        var covers, slide;
        slide = this.slides.eq(to);
        covers = $(this.settings.selector.videoCover, slide);
        covers.each((function(_this) {
          return function(i, el) {
            var cover;
            cover = $(el);
            cover.css({
              display: 'block'
            });
            _this.animate.to(cover, 0.5, {
              opacity: 1
            });
          };
        })(this));
      };
    };
    return $.slidea.register_module('videoCover', $.fn.slidea.videoCover);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../maps/pixevil.slidea.js.map
