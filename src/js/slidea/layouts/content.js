
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
    $.fn.slidea.contentLayout = function() {

      /*
      Resize slider to showcase the given slide
       */
      var resize_slider;
      resize_slider = function(slide) {
        var content_height;
        if (slide === -1) {
          slide = this.first_slide;
        }
        content_height = $(this.settings.selector.contentContainer, this.active).outerHeight(true);
        this.slider_width = this.parent_width;
        this.slider_height = content_height;
        this.animate.to(this.wrapper, 0.5, {
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
      Initialize the @parameters
       */
      this.initialize = function() {
        this.element.addClass('slidea-content-layout');
      };

      /*
      Set up the slider and each of the slides
       */
      this.resize = function() {
        if (this.data == null) {
          return;
        }
        return resize_slider.apply(this, [this.current]);
      };
      this.slide = function(from, to) {
        resize_slider.apply(this, [to]);
      };
    };
    $.slidea.register_layout('content', $.fn.slidea.contentLayout);
  })(jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/layouts/content.js.map
