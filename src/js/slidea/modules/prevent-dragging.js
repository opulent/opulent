(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.preventDragging = function() {

      /*
      Enable or disable image dragging
       */
      this.settings = true;
      this.initialize = function() {
        $("img", this.element).on("dragstart", (function(_this) {
          return function(event) {
            event.preventDefault();
          };
        })(this));
      };
    };
    return $.slidea.register_module('preventDragging', $.fn.slidea.preventDragging);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/prevent-dragging.js.map
