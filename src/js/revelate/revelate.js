
/*
                                    dP            dP
                                    88            88
88d888b. .d8888b. dP   .dP .d8888b. 88 .d8888b. d8888P .d8888b.
88'  `88 88ooood8 88   d8' 88ooood8 88 88'  `88   88   88ooood8
88       88.  ... 88 .88'  88.  ... 88 88.  .88   88   88.  ...
dP       `88888P' 8888P'   `88888P' dP `88888P8   dP   `88888P'
ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

A smart and efficient scroll reveal plugin by Alex Grozav
from Pixevil built to make the web a better place.

@plugin  	Revelate
@author 	Alex Grozav
@website  http://pixevil.com
@version 	1.0
@license 	Commercial
 */

(function() {
  (function($, window, document) {
    "use strict";
    $.revelate = function(element, options) {
      var _defaults;
      _defaults = {
        selector: '[data-revelate]',
        delay: 400,
        edge: [150, 150],
        screen: [1920, 1080],
        repeat: false,
        direction: 'vertical',
        animation: {
          duration: 700,
          easing: 'swing'
        }
      };
      ({
        debug: true
      });
      this._defaults = _defaults;
      this.settings = $.extend({}, _defaults, options);
      this.context = $(element);
      if (this.debug) {
        console.log(this.elements);
      }
      this.initialize = (function(_this) {
        return function() {
          _this.init_animus();
          _this.init_window();
          _this.init_elements();
          _this.bind_resize();
          _this.bind_scroll();
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
      this.init_window = (function(_this) {
        return function() {
          var doc_height, doc_width, win_height, win_width;
          _this.edge = _this.settings.edge.slice(0);
          if (_this.settings.direction === 'vertical') {
            win_height = $(window).height();
            doc_height = $(document).height();
            _this.edge = _this.edge.map(function(edge) {
              return parseInt(edge * (win_height / _this.settings.screen[1]));
            });
            _this.viewport = win_height - _this.edge[1];
            _this.endscroll = doc_height - win_height;
          } else {
            win_width = $(window).width();
            doc_width = $(document).width();
            _this.edge = _this.edge.map(function(edge) {
              return parseInt(edge * (win_width / _this.settings.screen[0]));
            });
            _this.viewport = win_width - _this.edge[1];
            _this.endscroll = doc_width - win_height;
          }
          if (_this.debug) {
            console.log("Edge: ", _this.edge);
            console.log("Viewport: ", _this.viewport);
            console.log("End Scroll: ", _this.endscroll);
          }
        };
      })(this);
      this.init_elements = (function(_this) {
        return function() {
          _this.elements = {};
          $(_this.settings.selector, _this.context).each(function(index, element) {
            var data, offset;
            offset = _this.get_offset($(element));
            data = _this.get_data($(element));
            if (_this.elements[offset] == null) {
              _this.elements[offset] = new Array();
            }
            _this.elements[offset].push(data);
            $(element).attr('data-revelate-index', offset + "-" + (_this.elements[offset].length - 1));
            return $(element).velocity(data.starting_animation.state, 1);
          });
        };
      })(this);
      this.get_offset = function(element) {
        var offset;
        offset = this.settings.direction === 'vertical' ? Math.round(element.offset().top) : Math.round(element.offset().left);
        if (offset < 0) {
          offset = 0;
        }
        return offset;
      };
      this.get_data = function(element) {
        var animation_stack, atMatch, data, initial, initial_animation_override, key, last_animation_time, repeat, start, time, time_stack, timeline, value;
        data = {
          done: false,
          height: element.outerHeight(true),
          width: element.outerWidth(true),
          animation: {}
        };
        repeat = element.attr("data-revelate-repeat");
        data.repeat = repeat == null ? this.settings.repeat : !!repeat;
        start = element.attr("data-revelate-start");
        start = start == null ? this.settings.delay : parseInt(start);
        time_stack = [];
        animation_stack = {};
        initial = element.attr("data-revelate");
        if (initial == null) {
          initial = element.attr("data-revelate-initial");
        }
        animation_stack[start] = initial;
        time_stack.push(start);
        initial_animation_override = element.attr('data-revelate-in') != null ? this.animus.get(element.attr('data-revelate-in')) : false;
        timeline = element.data();
        for (key in timeline) {
          value = timeline[key];
          if ((atMatch = key.match(/revelateAt([0-9]*)/)) !== null) {
            time = parseInt(atMatch[1], 10);
            animation_stack[time] = value;
            time_stack.push(time);
          }
        }
        time_stack.sort();
        last_animation_time = time_stack[0];
        for (key in time_stack) {
          data.animation[time_stack[key]] = this.animus.get(animation_stack[time_stack[key]]);
          if (time_stack[key] > last_animation_time) {
            last_animation_time = time_stack[key];
          }
        }
        if ($.type(data.animation[start].state) !== 'string') {
          data.animation[start].state = this.animus.reset(data.animation[start].state, data, true);
          data.starting_animation = data.animation[start];
          data.animation[start].state = this.animus.forcefeed(data.animation[start].state, initial_animation_override);
        }
        data.loop = element.attr("data-revelate-loop") != null ? last_animation_time + data.animation[last_animation_time].duration + 1 : false;
        return data;
      };
      this.bind_resize = (function(_this) {
        return function() {
          var resize_timeout;
          resize_timeout = null;
          $(window).resize(function() {
            clearTimeout(resize_timeout);
            return resize_timeout = setTimeout(function() {
              var scroll;
              _this.init_window();
              _this.elements = _this.restructure();
              scroll = _this.window.scrollTop();
              return _this.check(scroll);
            }, 500);
          });
        };
      })(this);
      this.restructure = (function(_this) {
        return function() {
          var new_elements;
          new_elements = {};
          $(_this.settings.selector, _this.context).each(function(index, element) {
            var current, id, offset, old_offset, ref;
            id = $(element).attr("data-revelate-index");
            ref = id.split("-"), old_offset = ref[0], index = ref[1];
            index = parseInt(index);
            offset = _this.get_offset($(element));
            if (new_elements[offset] == null) {
              new_elements[offset] = new Array();
            }
            new_elements[offset].push(_this.elements[old_offset][index]);
            current = new_elements[offset].length - 1;
            new_elements[offset][current].width = $(element).outerWidth(true);
            new_elements[offset][current].height = $(element).outerHeight(true);
            return $(element).attr("data-revelate-index", offset + "-" + (new_elements[offset].length - 1));
          });
          if (_this.debug) {
            console.log("Restructured: ", _this.elements);
          }
          return new_elements;
        };
      })(this);
      this.bind_scroll = (function(_this) {
        return function() {
          _this.window = $(window);
          _this.window.scroll(function() {
            var scroll;
            scroll = _this.window.scrollTop();
            return _this.check(scroll);
          });
          return _this.window.trigger('scroll');
        };
      })(this);
      this.check = function(scroll) {
        var data, group, id, index, offset, ref;
        ref = this.elements;
        for (offset in ref) {
          group = ref[offset];
          for (index in group) {
            data = group[index];
            if (this.in_viewport(offset, data.height, scroll)) {
              if (data.done === false) {
                id = offset + '-' + index;
                element = $('[data-revelate-index="' + id + '"]');
                this.animate(element, data);
                if (this.debug) {
                  console.log("Animate: [" + scroll + ", " + offset + "]");
                }
              }
            } else {
              if (data.repeat === true && data.done === true) {
                id = offset + '-' + index;
                element = $('[data-revelate-index="' + id + '"]');
                this.reset(element, data);
              }
            }
          }
        }
      };
      this.in_viewport = function(offset, height, scroll) {
        var bottom, max, min, ref, top;
        top = parseInt(offset);
        bottom = top + height;
        ref = scroll === 0 ? [0, scroll + this.viewport] : scroll === this.endscroll ? [scroll + this.edge[0], scroll + this.viewport + this.edge[1]] : [scroll + this.edge[0], scroll + this.viewport], min = ref[0], max = ref[1];
        return (top >= min && bottom <= max) || (top < min && (min < bottom && bottom < max)) || ((min < top && top < max) && bottom > max) || (top < min && bottom > max);
      };
      this.animate = function(element, data) {
        var states;
        states = function() {
          return $.each(data.animation, function(key, animation) {
            return animation.timeline = setTimeout(function() {
              element.velocity(animation.state, {
                easing: animation.easing,
                duration: animation.duration,
                visibility: 'visible'
              });
            }, key);
          });
        };
        data.done = true;
        states();
        if (data.loop) {
          data.interval = setInterval(states, data.loop);
        }
      };
      this.reset = function(element, data) {
        var animation, key, ref;
        data.done = false;
        if (data.loop) {
          clearInterval(data.interval);
        }
        ref = data.animation;
        for (key in ref) {
          animation = ref[key];
          clearTimeout(animation.timeline);
        }
        element.velocity(data.starting_animation.state, {
          duration: data.starting_animation.duration,
          visibility: 'hidden'
        });
      };
      return this.initialize();
    };
    return $.fn.revelate = function(opts) {
      return this.each(function(index, element) {
        if (!$.data(element, "revelate")) {
          return $.data(element, "revelate", new $.revelate(element, opts));
        }
      });
    };
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../src/maps/revelate/revelate.js.map
