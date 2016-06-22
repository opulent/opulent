(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.keyboard = function() {

      /*
      Enable or disable keyboard handler
       */
      this.settings = true;

      /*
      Add keyboard bindings
       */
      this.load = function() {
        $(document).keydown((function(_this) {
          return function(e) {
            switch (e.which) {
              case 37:
                return _this.slide(_this.current - 1);
              case 39:
                return _this.slide(_this.current + 1);
            }
          };
        })(this));
        this.log("Bound keyboard arrows event.");
      };
    };
    return $.slidea.register_module('keyboard', $.fn.slidea.keyboard);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/keyboard.js.map
