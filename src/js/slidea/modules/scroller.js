(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.scroller = function() {

      /*
      Set up scroller component
       */
      this.settings = {
        enabled: false,
        markup: "<span class=\"slidea-scroller-1\"></span>",
        position: "center"
      };
      this.load = function() {
        var scroller;
        scroller = "<div class=\"slidea-scroller-wrapper slidea-scroller-" + this.settings.scroller.position + "\">";
        scroller += this.settings.scroller.markup;
        scroller += "</div>";
        this.scroller = $(scroller);
        this.element.prepend(this.scroller);
        this.scroller.on("click", (function(_this) {
          return function() {
            $("html, body").animate({
              scrollTop: _this.element.height()
            }, 1000);
          };
        })(this));
      };
    };
    return $.slidea.register_module('scroller', $.fn.slidea.scroller);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/scroller.js.map
