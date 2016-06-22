(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.pauseOnHover = function() {

      /*
      Enable or disable pause on hover feature
       */
      this.settings = false;

      /*
      Pause the slider on mouse hover
       */
      this.load = function() {
        this.element.on('mouseenter', (function(_this) {
          return function() {
            _this.pause_timer();
          };
        })(this));
        this.element.on('mouseleave', (function(_this) {
          return function() {
            _this.unpause_timer();
          };
        })(this));
        this.log("Enabled pause on hover.");
      };
    };
    return $.slidea.register_module('pauseOnHover', $.fn.slidea.pauseOnHover);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/pause-on-hover.js.map
