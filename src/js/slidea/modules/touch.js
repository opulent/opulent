(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.touch = function() {

      /*
      Enable or disable video features
       */
      this.settings = true;

      /*
      Enable touch handler for the slider.
      @require Hammer.js
       */
      this.load = function() {
        this.touch_object = new Hammer(this.element[0]);
        this.touch_object.get('pan').set({
          direction: Hammer.DIRECTION_HORIZONTAL
        });
        this.touch_object.on('panleft panright', (function(_this) {
          return function(event) {
            if (event.eventType === Hammer.INPUT_START) {
              _this.element.addClass('slidea-dragging');
            } else if (event.eventType === Hammer.INPUT_END || event.eventType === Hammer.INPUT_CANCEL) {
              _this.element.removeClass('slidea-dragging');
              if (event.direction === Hammer.DIRECTION_LEFT) {
                _this.slide(_this.current + 1);
              } else if (event.direction === Hammer.DIRECTION_RIGHT) {
                _this.slide(_this.current - 1);
              }
            }
          };
        })(this));
        this.log("Bound touch pan left and right events.");
      };
    };
    return $.slidea.register_module('touch', $.fn.slidea.touch);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/touch.js.map
