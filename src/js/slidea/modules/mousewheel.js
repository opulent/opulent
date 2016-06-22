(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.mousewheel = function() {

      /*
      Enable or disable mousewheel handler
       */
      this.settings = false;

      /*
      Add mousewheel handler
      @require mousewheel.js
       */
      this.load = function() {
        var enable_timeout, enabled;
        enabled = true;
        enable_timeout = 750;
        this.element.mousewheel((function(_this) {
          return function(event) {
            if (!enabled) {
              return;
            }
            enabled = false;
            if (event.deltaY === -1) {
              _this.slide(_this.current + 1);
            }
            if (event.deltaY === 1) {
              _this.slide(_this.current - 1);
            }
            if (_this.settings.prevent_scrolling === true) {
              event.preventDefault();
            }
            setTimeout(function() {
              enabled = true;
            }, enable_timeout);
          };
        })(this));
        this.log("Bound mousewheel event.");
      };
    };
    return $.slidea.register_module('mousewheel', $.fn.slidea.mousewheel);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/mousewheel.js.map
