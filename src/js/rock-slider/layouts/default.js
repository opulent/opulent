
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
    $.fn.rockSlider.defaultLayout = function() {
      this.init = function() {
        this.element.addClass('rock-slider-default');
      };
      this.setup = function() {
        if (this.cache == null) {
          return;
        }
        this.element_width = this.parent_width;
        this.element_height = this.parent_width / this.settings.width * this.settings.height;
        this.element.height(this.element_height);
        this.element.width(this.element_width);
        this.outer.height(this.element_height);
        this.outer.width(this.element_width);
        this.slides.each((function(_this) {
          return function(i, element) {
            var $layers, $slide, $video, $video_background, data_height, data_width, height_ratio, margin_left, margin_top, video_height, video_width, width_ratio;
            $slide = $(element);
            _this.visible_width = _this.element_width;
            _this.visible_height = _this.visible_width / _this.cache[i].background[0].width * _this.cache[i].background[0].height;
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
              margin_left = -(video_width - _this.parent_width) / 2;
              margin_top = -(video_height - _this.parent_height) / 2;
              $video.css({
                'width': video_width,
                'height': video_height,
                'margin-left': margin_left,
                'margin-top': margin_top
              });
            }
          };
        })(this));
      };
      this.slide = function(i, prev) {};
    };
    $.rockSlider.add_layout('default', $.fn.rockSlider.defaultLayout);
  })(jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../src/maps/rock-slider/layouts/default.js.map
