(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.retina = function() {

      /*
      Enable or disable retina feature
       */
      this.settings = true;
      this.initialize = function() {
        var mediaQuery, ref, retina, root;
        retina = false;
        root = (ref = typeof exports !== "undefined" && exports !== null) != null ? ref : {
          window: exports
        };
        mediaQuery = '(-webkit-min-device-pixel-ratio: 1.5), (min--moz-device-pixel-ratio: 1.5), (-o-min-device-pixel-ratio: 3/2), (min-resolution: 1.5dppx)';
        if (root.devicePixelRatio > 1) {
          retina = true;
        }
        if (root.matchMedia && root.matchMedia(mediaQuery).matches) {
          retina = true;
        }
        if (retina) {
          this.log("This device has a retina display.");
          $('img[data-slidea-at2x]', $slide).each((function(_this) {
            return function(index, element) {
              var img, retina_src, src;
              img = $(element);
              src = img.attr('data-slidea-src');
              retina_src = img.attr('data-slidea-at2x');
              if (retina_src === "true") {
                src = src.replace(/(\.[\w\?=]+)$/, "@2x$1");
              } else {
                src = retina_src;
              }
              _this.log("Found a Retina image with src=\"" + src + "\".");
              img.attr('data-slidea-src', src);
            };
          })(this));
        } else {
          this.log("This device doesn't have a Retina display.");
        }
      };
    };
    return $.slidea.register_module('retina', $.fn.slidea.retina);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/retina.js.map
