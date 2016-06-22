
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

}).call(this);

//# sourceMappingURL=../../maps/slidea/slidea.js.map
