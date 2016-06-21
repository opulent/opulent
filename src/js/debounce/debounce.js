(function() {
  (function($, window, document) {
    "use strict";
    return $.debounce = function(func, wait, immediate) {
      var timeout;
      timeout = void 0;
      return function() {
        var args, callNow, context, later;
        context = this;
        args = arguments;
        later = function() {
          timeout = null;
          if (!immediate) {
            func.apply(context, args);
          }
        };
        callNow = immediate && !timeout;
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
        if (callNow) {
          func.apply(context, args);
        }
      };
    };
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../src/maps/debounce/debounce.js.map
