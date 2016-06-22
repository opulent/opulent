
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
    $.fn.slidea.fluidLayout = function() {
      var resize_slide, resize_slider, set_parent_size;
      this.settings = {
        anchor: 'center',
        size: 'fullscreen'
      };

      /*
      Get Parent sizes
       */
      set_parent_size = function() {
        if (this.settings.layoutSettings.size === 'fullscreen') {
          this.parent_width = this.window_width;
          return this.parent_height = this.window_height;
        } else if (this.settings.layoutSettings.size === 'screenHeight') {
          return this.parent_height = this.window_height;
        } else if (this.settings.layoutSettings.size === 'screenWidth') {
          return this.parent_width = this.window_width;
        }
      };

      /*
      Resize slider to showcase the given slide
       */
      resize_slider = function(slide) {
        var current_slide_image_height, current_slide_image_width;
        if (slide === -1) {
          slide = this.first_slide;
        }
        current_slide_image_width = this.data[slide].background[0].width;
        current_slide_image_height = this.data[slide].background[0].height;
        set_parent_size.call(this);
        this.slider_width = this.parent_width;
        this.slider_height = this.parent_width / current_slide_image_width * current_slide_image_height;
        if (this.parent_height > this.slider_height) {
          this.slider_width = this.parent_height / current_slide_image_height * current_slide_image_width;
          this.slider_height = this.parent_height;
        }
        this.wrapper_width = this.parent_width;
        this.wrapper_height = this.parent_height;
        this.wrapper.css({
          height: this.wrapper_height,
          width: this.wrapper_width
        });
        this.inner.width(this.slider_width);
        this.inner.height(this.slider_height);
        this.log("Slider size set to " + this.slider_width + " x " + this.slider_height);
      };

      /*
      Resize the slide with the given index
       */
      resize_slide = function(index) {
        var height_ratio, margin_left, margin_top, slide, slide_height, slide_image_height, slide_image_width, slide_layers, slide_width, width_ratio;
        if (this.data[index].background == null) {
          return;
        }
        slide = this.slides.eq(index);
        set_parent_size.call(this);
        slide_image_width = this.data[index].background[0].width;
        slide_image_height = this.data[index].background[0].height;
        slide_width = this.slider_width;
        slide_height = slide_width / slide_image_width * slide_image_height;
        $(this.settings.selector.contentWrapper, this.element).css({
          height: this.parent_height,
          width: this.parent_width
        });
        width_ratio = slide_width / slide_image_width;
        height_ratio = slide_height / slide_image_height;
        switch (this.settings.layoutSettings.anchor) {
          case 'center':
            margin_left = -(this.slider_width - this.parent_width) / 2;
            margin_top = -(this.slider_height - this.parent_height) / 2;
            break;
          case 'top':
            margin_left = -(this.slider_width - this.parent_width) / 2;
            margin_top = 0;
            break;
          case 'bottom':
            margin_left = -(this.slider_width - this.parent_width) / 2;
            margin_top = -(this.slider_height - this.parent_height);
            break;
          case 'left':
            margin_left = 0;
            margin_top = -(this.slider_height - this.parent_height);
            break;
          case 'right':
            margin_left = -(this.slider_width - this.parent_width);
            margin_top = -(this.slider_height - this.parent_height) / 2;
            break;
          case 'top-left':
            margin_left = 0;
            margin_top = 0;
            break;
          case 'bottom-left':
            margin_left = 0;
            margin_top = -(this.slider_height - this.parent_height);
            break;
          case 'top-right':
            margin_left = -(this.slider_width - this.parent_width);
            margin_top = 0;
            break;
          case 'bottom-right':
            margin_left = -(this.slider_width - this.parent_width);
            margin_top = -(this.slider_height - this.parent_height);
        }
        if (margin_left > 0) {
          margin_left = 0;
        }
        if (margin_top > 0) {
          margin_top = 0;
        }
        $(this.settings.selector.backgroundWrapper, slide).css({
          'margin-top': margin_top,
          'margin-left': margin_left
        });
        slide_layers = $(this.settings.selector.layerWrapper, slide);
        slide_layers.each((function(_this) {
          return function(layer_index, layer) {
            var layer_css;
            layer_css = {};
            if ('top' in _this.data[index].layer[layer_index].position) {
              layer_css.top = height_ratio * _this.data[index].layer[layer_index].position.top + margin_top;
            } else if ('bottom' in _this.data[index].layer[layer_index].position) {
              layer_css.bottom = height_ratio * _this.data[index].layer[layer_index].position.bottom - margin_top;
            }
            if ('left' in _this.data[index].layer[layer_index].position) {
              layer_css.left = width_ratio * _this.data[index].layer[layer_index].position.left + margin_left;
            } else if ('right' in _this.data[index].layer[layer_index].position) {
              layer_css.right = width_ratio * _this.data[index].layer[layer_index].position.right - margin_left;
            }
            if ('width' in _this.data[index].layer[layer_index]) {
              layer_css.width = width_ratio * _this.data[index].layer[layer_index].width;
            }
            if ('height' in _this.data[index].layer[layer_index]) {
              layer_css.height = height_ratio * _this.data[index].layer[layer_index].height;
            }
            $(layer).css(layer_css);
          };
        })(this));
      };

      /*
      Initialize the @parameters
       */
      this.initialize = function() {
        this.element.addClass('slidea-fluid-layout');
      };

      /*
      Set up the slider and each of the slides
       */
      this.resize = function() {
        if (this.data == null) {
          return;
        }
        resize_slider.apply(this, [this.current]);
        this.slides.each((function(_this) {
          return function(index, slide) {
            resize_slide.apply(_this, [index]);
          };
        })(this));
      };
      this.slide = function(from, to) {
        resize_slider.apply(this, [to]);
        resize_slide.apply(this, [to]);
      };
    };
    $.slidea.register_layout('fluid', $.fn.slidea.fluidLayout);
  })(jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/layouts/fluid.js.map
