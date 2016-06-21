(function() {
  (function($, window, document) {
    "use strict";
    var normalize_wheel_delta;
    $.smoothscroll = function(element, options) {
      var _defaults;
      _defaults = {
        friction: 0.95,
        direction: void 0,
        on_render: null,
        step_amount: 1,
        min_movement: 0.1
      };
      this.container = $(element);
      this.running = false;
      this.max_scroll_top = 0;
      this.min_scroll_top = void 0;
      this.current_y = 0;
      this.target_y = 0;
      this.old_y = 0;
      this.vy = 0;
      this.initialize = (function(_this) {
        return function() {
          _this.settings = $.extend({}, _defaults, options);
          if (!('ontouchstart' in window)) {
            _this.container.bind('mousewheel DOMMouseScroll', _this.on_wheel);
            _this.target_y = _this.old_y = _this.container.scrollTop();
            _this.current_y = -_this.target_y;
            _this.min_scroll_top = _this.container.get(0).clientHeight - (_this.container.get(0).scrollHeight);
            if (!_this.running) {
              _this.running = true;
              _this.animate_loop();
            }
          }
        };
      })(this);
      this.remove = (function(_this) {
        return function() {
          _this.running = false;
          _this.container.unbind('mousewheel', _this.on_wheel);
          _this.container.unbind('DOMMouseScroll', _this.on_wheel);
        };
      })(this);
      this.update_scroll_target = (function(_this) {
        return function(amt) {
          _this.target_y += amt;
          _this.vy += (_this.target_y - _this.old_y) * _this.settings.step_amount;
          _this.old_y = _this.target_y;
        };
      })(this);
      this.render = (function(_this) {
        return function() {
          if (_this.vy < -_this.settings.min_movement || _this.vy > _this.settings.min_movement) {
            _this.current_y = _this.current_y + _this.vy;
            if (_this.current_y > _this.max_scroll_top) {
              _this.vy = 0;
              _this.current_y = 0;
            } else if (_this.current_y < _this.min_scroll_top) {
              _this.vy = 0;
              _this.current_y = _this.min_scroll_top;
            }
            _this.container.scrollTop(-_this.current_y);
            _this.vy *= _this.settings.friction;
            if (_this.settings.on_render) {
              _this.settings.on_render();
            }
          }
        };
      })(this);
      this.animate_loop = (function(_this) {
        return function() {
          if (!_this.running) {
            return;
          }
          window.request_animation_frame(_this.animate_loop);
          _this.render();
        };
      })(this);
      this.on_wheel = (function(_this) {
        return function(e) {
          var delta, dir, event;
          e.preventDefault();
          event = e.originalEvent;
          if (e.type === 'DOMMouseScroll' && (event.detail != null)) {
            delta = event.detail * -1;
          } else if (event.wheelDelta != null) {
            delta = event.wheelDelta.toFixed(2) / 40;
          } else if (event.deltaY != null) {
            delta = event.deltaY.toFixed(2) / -10;
          }
          dir = delta < 0 ? -1 : 1;
          if (dir !== _this.settings.direction) {
            _this.vy = 0;
            _this.settings.direction = dir;
          }
          _this.current_y = -_this.container.scrollTop();
          _this.update_scroll_target(delta);
        };
      })(this);
      this.initialize();
    };

    /*
     * http://paulirish.com/2011/requestanimationframe-for-smart-animating/
     */
    window.request_animation_frame = (function(_this) {
      return function() {
        return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame || function(callback) {
          window.setTimeout(callback, 1000 / 60);
        };
      };
    })(this)();

    /*
     * http://jsbin.com/iqafek/2/edit
     */
    normalize_wheel_delta = (function(_this) {
      return function() {
        var distribution, done, scale;
        distribution = [];
        done = null;
        scale = 30;
        return function(n) {
          var abs, factor, outer;
          if (n === 0) {
            return n;
          }
          if (done !== null) {
            return n * done;
          }
          abs = Math.abs(n);
          outer = function() {
            var i;
            i = 0;
            while (i < distribution.length) {
              if (abs <= distribution[i]) {
                distribution.splice(i, 0, abs);
                outer();
                break;
              }
              ++i;
            }
            distribution.push(abs);
          };
          factor = scale / distribution[Math.floor(distribution.length / 3)];
          if (distribution.length === 500) {
            done = factor;
          }
          return n * factor;
        };
      };
    })(this)();
    $.fn.smoothscroll = function(opts) {
      return this.each(function(index, element) {
        if (!$.data(element, "smoothscroll")) {
          return $.data(element, "smoothscroll", new $.smoothscroll(element, opts));
        }
      });
    };
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../src/maps/smoothscroll/smoothscroll.js.map
