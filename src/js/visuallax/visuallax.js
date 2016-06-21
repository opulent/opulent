
/*
         oo                            dP dP
                                       88 88
dP   .dP dP .d8888b. dP    dP .d8888b. 88 88 .d8888b. dP.  .dP
88   d8' 88 Y8ooooo. 88    88 88'  `88 88 88 88'  `88  `8bd8'
88 .88'  88       88 88.  .88 88.  .88 88 88 88.  .88  .d88b.
8888P'   dP `88888P' `88888P' `88888P8 dP dP `88888P8 dP'  `dP
ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

A smart and efficient parallax plugin by Alex Grozav
from Pixevil built to make the web a better place.

@plugin  	Visuallax
@author 	Alex Grozav
@website  http://pixevil.com
@version 	1.0
@license 	Commercial
 */

(function() {
  (function($, window, document) {
    "use strict";
    var _defaults;
    _defaults = {
      orientation: 'vertical',
      mode: 'default',
      overflow: false,
      reset: false,
      transform: {},
      transform_style: {
        opacity: 'default',
        scale: 'default'
      },
      parent: false,
      source: false,
      screen_size: {
        xs: 0,
        sm: 768,
        md: 992,
        lg: 1200,
        xlg: 1840
      },
      disabled: {
        xs: [],
        sm: [],
        md: [],
        lg: [],
        xlg: []
      }
    };
    ({
      debug: true
    });
    $.visuallax = function(element, options) {
      this._defaults = _defaults;
      this.settings = $.extend(true, {}, this._defaults, options);
      this.element = $(element);
      this.source = this.settings.source ? this.settings.source : this.element;
      this.parent = this.settings.parent ? this.settings.parent : this.source.parent();
      this.window = $(window);
      this.image_resize_timeout = null;
      this.initialize = (function(_this) {
        return function() {
          _this.get_data();
          _this.set_size();
          _this.set_position();
          _this.set_responsive_context();
          _this.bind_resize();
          _this.bind_scroll();
          _this.parallax(_this.window.scrollTop());
        };
      })(this);
      this.get_data = (function(_this) {
        return function() {
          var data;
          data = _this.element.attr('data-visuallax');
          if (data != null) {
            data = data.split(/\,\s+/);
            $.each(data, function(index, string) {
              var i;
              string = $.trim(string);
              string = string.split(/\s+/);
              string = string.map(function(n) {
                if (n === 'false') {
                  return false;
                } else {
                  return n.toLowerCase();
                }
              });
              switch (string[0]) {
                case 'translate':
                case 'move':
                  if (string[1] === 'x' || string[1] === 'y' || string[1] === 'z') {
                    _this.settings.transform["translate" + (string[1].toUpperCase())] = parseFloat(string[2]);
                  } else {
                    _this.settings.transform.translateY = parseFloat(string[1]);
                  }
                  break;
                case 'rotate':
                  if (string[1] === 'x' || string[1] === 'y' || string[1] === 'z') {
                    _this.settings.transform["rotate" + (string[1].toUpperCase())] = parseFloat(string[2]);
                  } else {
                    _this.settings.transform.rotateZ = parseFloat(string[1]);
                  }
                  break;
                case 'opacity':
                case 'fade':
                  i = 1;
                  if (string[i] === 'simple' || string[i] === 'default') {
                    _this.settings.transform_style.opacity = string[i++];
                  }
                  _this.settings.transform.opacity = parseFloat(string[i]);
                  break;
                case 'scale':
                  i = 1;
                  if (string[i] === 'simple' || string[i] === 'default') {
                    _this.settings.transform_style.scale = string[i++];
                  }
                  _this.settings.transform.scale = parseFloat(string[i]);
                  break;
                case 'disabled':
                  i = 1;
                  while (string[++i]) {
                    _this.settings.disabled[string[1]].push(string[i]);
                  }
                  break;
                default:
                  i = 0;
                  _this.settings[string[i++]] = string[i];
              }
            });
          }
          if (!('translateZ' in _this.settings.transform)) {
            _this.settings.transform.translateZ = 0;
          }
        };
      })(this);
      this.set_position = (function(_this) {
        return function() {
          _this.top = _this.source.offset().top;
          _this.bottom = _this.top + _this.source_height;
          _this.left = _this.source.offset().left;
          _this.right = _this.left + _this.source_width;
          _this.parent_top = _this.parent.offset().top;
          _this.parent_bottom = _this.parent_top + _this.parent_height;
          _this.parent_left = _this.parent.offset().left;
          _this.parent_right = _this.parent_left + _this.parent_width;
        };
      })(this);
      this.set_size = (function(_this) {
        return function() {
          _this.parent_width = _this.parent.outerWidth(true);
          _this.parent_height = _this.parent.outerHeight(true);
          _this.source_width = _this.source.outerWidth(true);
          _this.source_height = _this.source.outerHeight(true);
          _this.element_width = _this.element.outerWidth(true);
          _this.element_height = _this.element.outerHeight(true);
          _this.window_width = _this.window.width();
          _this.window_height = _this.window.height();
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
      this.reset = (function(_this) {
        return function(style) {
          var j, key, len, reset, value;
          reset = {
            translateX: 0,
            translateY: 0,
            rotateX: 0,
            rotateY: 0,
            rotateZ: 0,
            scale: 1,
            opacity: 1
          };
          if (style === '*') {
            for (value = j = 0, len = reset.length; j < len; value = ++j) {
              key = reset[value];
              $.Velocity.hook(_this.element, key, value);
            }
          } else {
            $.Velocity.hook(_this.element, style, reset[style]);
          }
        };
      })(this);
      this.bind_resize = (function(_this) {
        return function() {
          _this.window.resize(function() {
            _this.set_size();
            _this.set_position();
            _this.set_responsive_context();
            _this.parallax(_this.window.scrollTop());
          });
        };
      })(this);
      this.bind_scroll = (function(_this) {
        return function() {
          _this.window.on('scroll', function() {
            _this.parallax(_this.window.scrollTop());
          });
        };
      })(this);
      this.parallax = (function(_this) {
        return function(position) {
          var delta_y, in_view, middle_trigger, overflow_condition, overflowing_translation, ref, smaller_than_parent, transform, transform_factor, transform_string, transform_unit, translated, value;
          delta_y = position + _this.window_height / 2 - (_this.top + _this.bottom) / 2;
          in_view = position + _this.window_height < _this.top || position > _this.bottom;
          middle_trigger = (_this.settings.mode === 'to-middle' && delta_y >= 0) || (_this.settings.mode === 'from-middle' && delta_y <= 0);
          smaller_than_parent = _this.source_height < _this.parent_height;
          translated = 'translateY' in _this.settings.transform ? _this.settings.transform.translateY * delta_y : 0;
          overflowing_translation = (_this.top + translated > _this.parent_top) || (_this.bottom + translated > _this.parent_bottom);
          overflow_condition = _this.settings.overflow && (smaller_than_parent || overflowing_translation);
          if (in_view || middle_trigger || overflow_condition) {
            if (_this.settings.reset) {
              _this.reset('*');
            }
            return;
          }
          ref = _this.settings.transform;
          for (transform in ref) {
            value = ref[transform];
            if ($.inArray(transform, _this.settings.disabled[_this.current_responsive_size]) !== -1) {
              _this.reset(transform);
              return;
            }
            transform_unit = transform.indexOf('translate') !== -1 ? 'px' : transform.indexOf('rotate') !== -1 ? 'deg' : '';
            transform_factor = transform in _this.settings.transform_style ? _this.settings.transform_style[transform] === 'default' ? 1 - Math.abs(delta_y / 100 * _this.settings.transform[transform]) : 1 - delta_y / 100 * _this.settings.transform[transform] : delta_y * value;
            transform_string = "" + transform_factor + transform_unit;
            $.Velocity.hook(_this.element, transform, transform_string);
          }
        };
      })(this);
      return this.initialize();
    };
    return $.fn.visuallax = function(opts) {
      return this.each(function(index, element) {
        if (!$.data(element, "visuallax")) {
          return $.data(element, "visuallax", new $.visuallax(element, opts));
        }
      });
    };
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../src/maps/visuallax/visuallax.js.map
