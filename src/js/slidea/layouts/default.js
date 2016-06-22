
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
    $.fn.slidea.defaultLayout = function() {

      /*
      Resize slider to showcase the given slide
       */
      var resize_slide, resize_slider;
      resize_slider = function(slide) {
        var current_slide_image_height, current_slide_image_width;
        if (slide === -1) {
          slide = this.first_slide;
        }
        current_slide_image_width = this.data[slide].background[0].width;
        current_slide_image_height = this.data[slide].background[0].height;
        this.slider_width = this.parent_width;
        this.slider_height = this.parent_width / current_slide_image_width * current_slide_image_height;
        this.animate.to(this.wrapper, 0.75, {
          css: {
            height: this.slider_height,
            width: this.slider_width
          }
        });
        this.inner.width(this.slider_width);
        this.inner.height(this.slider_height);
        this.log("Slider size set to " + this.slider_width + " x " + this.slider_height);
      };

      /*
      Resize the slide with the given index
       */
      resize_slide = function(index) {
        var height_ratio, slide, slide_height, slide_image_height, slide_image_width, slide_layers, slide_width, width_ratio;
        if (this.data[index].background == null) {
          return;
        }
        slide = this.slides.eq(index);
        slide_image_width = this.data[index].background[0].width;
        slide_image_height = this.data[index].background[0].height;
        slide_width = this.slider_width;
        slide_height = slide_width / slide_image_width * slide_image_height;
        width_ratio = slide_width / slide_image_width;
        height_ratio = slide_height / slide_image_height;
        slide_layers = $(this.settings.selector.layerWrapper, slide);
        slide_layers.each((function(_this) {
          return function(layer_index, layer) {
            var layer_css;
            layer_css = {};
            if ('top' in _this.data[index].layer[layer_index].position) {
              layer_css.top = height_ratio * _this.data[index].layer[layer_index].position.top;
            } else if ('bottom' in _this.data[index].layer[layer_index].position) {
              layer_css.bottom = height_ratio * _this.data[index].layer[layer_index].position.bottom;
            }
            if ('left' in _this.data[index].layer[layer_index].position) {
              layer_css.left = width_ratio * _this.data[index].layer[layer_index].position.left;
            } else if ('right' in _this.data[index].layer[layer_index].position) {
              layer_css.right = width_ratio * _this.data[index].layer[layer_index].position.right;
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
      Initialize slider layout
       */
      this.initialize = function() {
        this.element.addClass('slidea-default-layout');
      };

      /*
      Resize slide with given index
       */
      this.resize_slide = function(index) {
        resize_slide.apply(this, [index]);
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

      /*
      Display the slide element with index i and program the animation logic for
      each background, layer and object
      
      Previous slide needs to be set in order to preview the out animation so that
      we can create a transition between every slide
      
      The layers and objects need to be stopped and reanimated in order to prevent
      animation flaws.
      
      Layer and object animation will transition from an inverted
      animation state to a default state to provide normal slider behaviour
       */
      this.slide = function(from, to) {
        resize_slider.apply(this, [to]);
        resize_slide.apply(this, [to]);
      };
    };

    /*
    Add the layer to Slidea as a new instance
     */
    $.slidea.register_layout('default', $.fn.slidea.defaultLayout);
  })(jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/layouts/default.js.map
