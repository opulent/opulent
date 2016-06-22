(function() {
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

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/content-scaling.js.map
