
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
 */

(function() {
  (function($, window, document) {
    "use strict";
    $.fn.rockSlider.swipeLayout = function() {
      this.init = function() {
        var _defaults, easing;
        _defaults = {
          speed: 700,
          overflow: 0,
          highlight: true,
          highlight_color: 'rgba(0, 156, 255, 1)',
          animate_background: false,
          threshold: 25
        };
        this.settings.layout_settings = $.extend({}, _defaults, this.settings.layout_settings);
        this.element.addClass('rock-slider-swipe');
        this.slides.wrap('<div class="rock-swipe-wrapper"></div>');
        this.wrapped_slides = $('.rock-swipe-wrapper', this.element);
        this.inner = $('.rock-inner', this.element);
        this.left_highlight = $('<div class="rock-swipe-highlight left"></div>');
        this.right_highlight = $('<div class="rock-swipe-highlight right"></div>');
        $('.rock-outer').prepend(this.left_highlight);
        $('.rock-outer').prepend(this.right_highlight);
        easing = "ease-out";
        $('html > head').append($(("<style data-rock-style-id='" + this.id + "'>") + ("#" + this.id + " .rock-inner.animating { ") + ("transition: transform " + this.settings.layout_settings.speed + "ms " + easing + ";") + ("-o-transition: -o-transform " + this.settings.layout_settings.speed + "ms " + easing + ";") + ("-moz-transition: -moz-transform " + this.settings.layout_settings.speed + "ms " + easing + ";") + ("-webkit-transition: -webkit-transform " + this.settings.layout_settings.speed + "ms " + easing + ";") + " }" + "</style>"));
        this.first_setup = true;
        this.starting_position = 0;
        this.element.attr('data-rock-swipe-position', 0);
        this.touch_object.destroy();
        this.touch_object = new Hammer(this.element[0]);
        this.touch_object.get('pan').set({
          direction: Hammer.DIRECTION_HORIZONTAL
        });
        this.starting_direction = void 0;
        this.touch_object.on('panstart pancancel panend panleft panright', (function(_this) {
          return function(event) {
            var distance, leftmost_slide, rightmost_slide, shadow_reset, transform;
            distance = event.deltaX;
            if (event.type === 'panleft' || event.type === 'panright') {
              leftmost_slide = _this.current === 0 && event.deltaX > 0;
              rightmost_slide = _this.current === _this.slides_length - 1 && event.deltaX < 0;
              if (leftmost_slide || rightmost_slide) {
                if (_this.settings.layout_settings.highlight) {
                  if (leftmost_slide) {
                    _this.left_highlight.css({
                      'box-shadow': "0px 0px " + distance + "px 0px " + _this.settings.layout_settings.highlight_color,
                      '-moz-box-shadow': "0px 0px " + distance + "px 0px " + _this.settings.layout_settings.highlight_color,
                      '-webkit-box-shadow': "0px 0px " + distance + "px 0px " + _this.settings.layout_settings.highlight_color
                    });
                  } else {
                    _this.right_highlight.css({
                      'box-shadow': "0px 0px " + (-distance) + "px 0px " + _this.settings.layout_settings.highlight_color,
                      '-moz-box-shadow': "0px 0px " + (-distance) + "px 0px " + _this.settings.layout_settings.highlight_color,
                      '-webkit-box-shadow': "0px 0px " + (-distance) + "px 0px " + _this.settings.layout_settings.highlight_color
                    });
                  }
                }
                if (_this.settings.layout_settings.overflow === 0) {
                  return;
                } else {
                  distance /= _this.settings.layout_settings.overflow;
                }
              }
              if (event.direction === Hammer.DIRECTION_LEFT || event.direction === Hammer.DIRECTION_RIGHT) {
                transform = "translate3d(" + (_this.starting_position + distance) + "px, 0, 0)";
                _this.inner.css({
                  'transform': transform,
                  '-o-transform': transform,
                  '-ms-transform': transform,
                  '-moz-transform': transform,
                  '-webkit-transform': transform
                });
              }
            } else if (event.type === 'panstart' && !_this.inner.hasClass('animating')) {
              _this.element.addClass('rock-dragging');
              _this.starting_direction = event.direction;
            } else if (event.type === 'panend') {
              _this.element.removeClass('rock-dragging');
              if (_this.settings.layout_settings.highlight) {
                shadow_reset = {
                  'box-shadow': "0px 0px 0px 0px " + _this.settings.layout_settings.highlight_color,
                  '-moz-box-shadow': "0px 0px 0px 0px " + _this.settings.layout_settings.highlight_color,
                  '-webkit-box-shadow': "0px 0px 0px 0px " + _this.settings.layout_settings.highlight_color
                };
                _this.left_highlight.addClass('animating').css(shadow_reset);
                _this.right_highlight.addClass('animating').css(shadow_reset);
                setTimeout(function() {
                  _this.left_highlight.removeClass('animating');
                  return _this.right_highlight.removeClass('animating');
                }, 700);
              }
              if (Math.abs(distance) > _this.settings.layout_settings.threshold / 100 * _this.parent_width) {
                if (event.direction === Hammer.DIRECTION_RIGHT) {
                  _this.slide(_this.current - 1);
                } else if (event.direction === Hammer.DIRECTION_LEFT) {
                  _this.slide(_this.current + 1);
                }
              } else {
                transform = 'translate3d(' + _this.starting_position + 'px, 0, 0)';
                _this.inner.addClass('animating').css({
                  'transform': transform,
                  '-o-transform': transform,
                  '-ms-transform': transform,
                  '-moz-transform': transform,
                  '-webkit-transform': transform
                });
                setTimeout(function() {
                  _this.inner.removeClass('animating');
                }, _this.settings.layout_settings.speed + 300);
              }
            }
            event.preventDefault();
          };
        })(this));
      };
      this.setup = function() {
        if (this.cache == null) {
          return;
        }
        this.element.width(this.parent_width);
        this.element.height(this.parent_width / this.settings.width * this.settings.height);
        this.inner.height(this.element_height);
        this.inner.width(this.element_width * this.slides_length);
        this.wrapped_slides.height(this.element_height);
        this.wrapped_slides.width(this.element_width);
        this.slides.width(this.element_width);
        this.slides.height(this.element_height);
        this.slides.each((function(_this) {
          return function(i, element) {
            var $background, $layers, $slide, $video, $video_background, data_height, data_width, height_ratio, video_height, video_width, width_ratio;
            $slide = $(element);
            _this.visible_width = _this.element_width;
            _this.visible_height = _this.visible_width / _this.cache[i].background[0].width * _this.cache[i].background[0].height;
            $background = $('.rock-background-wrapper', $slide);
            width_ratio = _this.element_width / _this.settings.width;
            height_ratio = _this.element_height / _this.settings.height;
            $layers = $('.rock-layer-wrapper', $slide);
            $layers.each(function(layer_index, layer) {
              var layer_css;
              layer_css = {};
              if ('top' in _this.cache[i].layer[layer_index].position) {
                layer_css.top = height_ratio * _this.cache[i].layer[layer_index].position.top;
              } else if ('bottom' in _this.cache[i].layer[layer_index].position) {
                layer_css.bottom = height_ratio * _this.cache[i].layer[layer_index].position.bottom;
              }
              if ('left' in _this.cache[i].layer[layer_index].position) {
                layer_css.left = width_ratio * _this.cache[i].layer[layer_index].position.left;
              } else if ('right' in _this.cache[i].layer[layer_index].position) {
                layer_css.right = width_ratio * _this.cache[i].layer[layer_index].position.right;
              }
              if ('width' in _this.cache[i].layer[layer_index]) {
                layer_css.width = width_ratio * _this.cache[i].layer[layer_index].width;
              }
              if ('height' in _this.cache[i].layer[layer_index]) {
                layer_css.height = height_ratio * _this.cache[i].layer[layer_index].height;
              }
              $(layer).css(layer_css);
            });
            $video_background = $('.rock-video-background', $slide);
            if ($video_background.length > 0) {
              $video = $('.video', $video_background);
              data_width = parseInt($video.attr('data-rock-width'));
              data_height = parseInt($video.attr('data-rock-height'));
              video_width = _this.element_width;
              video_height = video_width * data_height / data_width;
              $video.css({
                'width': video_width,
                'height': video_height
              });
            }
          };
        })(this));
      };
      this.resize = function() {
        var transform;
        transform = 'translate3d(' + (-this.parent_width * this.current) + 'px, 0, 0)';
        this.inner.css({
          'transform': transform,
          '-o-transform': transform,
          '-ms-transform': transform,
          '-moz-transform': transform,
          '-webkit-transform': transform
        });
      };
      this.slide = function(i, prev) {
        var $layers, $objects, transform;
        $layers = $('.rock-layer-wrapper', this.active);
        $objects = $('.rock-object', this.active);
        transform = 'translate3d(' + (-this.parent_width * i) + 'px, 0, 0)';
        this.inner.addClass('animating').css({
          'transform': transform,
          '-o-transform': transform,
          '-ms-transform': transform,
          '-moz-transform': transform,
          '-webkit-transform': transform
        });
        setTimeout((function(_this) {
          return function() {
            return _this.inner.removeClass('animating');
          };
        })(this), this.settings.layout_settings.speed + 300);
        return this.starting_position = -this.parent_width * i;
      };
    };
    $.rockSlider.add_layout('swipe', $.fn.rockSlider.swipeLayout);
  })(jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../src/maps/rock-slider/layouts/swipe.js.map
