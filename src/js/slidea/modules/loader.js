(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.loader = function() {

      /*
      Enable or disable loader component
       */
      this.settings = true;

      /*
      Add the loader element if it hasn't been added with HTML
       */
      this.initialize = function() {
        var html;
        if ($(".slidea-loader-wrapper", this.element).length === 0) {
          html = "";
          html += '<div class="slidea-loader-wrapper">';
          html += '<div class="slidea-loader">';
          html += '<div class="slidea-loader-inner">';
          html += '<div class="slidea-loader-tile"></div>';
          html += '<div class="slidea-loader-tile"></div>';
          html += '<div class="slidea-loader-tile"></div>';
          html += '<div class="slidea-loader-tile"></div>';
          html += '<div class="slidea-loader-tile"></div>';
          html += '</div>';
          html += '</div>';
          html += '</div>';
          this.element.prepend(html);
          this.log("No loader found. Added default loader.");
        } else {
          this.log("Loader markup already exists.");
        }
        this.loader = $(".slidea-loader-wrapper", this.element);
      };

      /*
      When all the slider images have been loaded, hide the
      loading spinner
       */
      this.load = function() {
        this.animate.to(this.loader, 0.5, {
          opacity: 0,
          onComplete: (function(_this) {
            return function() {
              _this.loader.css({
                display: 'none'
              });
              _this.log("Loader element faded out.");
            };
          })(this)
        });
      };
    };
    return $.slidea.register_module('loader', $.fn.slidea.loader);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/loader.js.map
