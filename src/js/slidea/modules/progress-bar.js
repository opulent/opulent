(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.progressBar = function() {

      /*
      Set up progress bar element
       */
      this.settings = {
        enabled: false,
        position: "bottom",
        "class": "slidea-progress-light"
      };

      /*
      Add progress bar
       */
      this.load = function() {
        var html, position;
        position = (this.settings.progress.position === "top" ? "slidea-progress-top" : "slidea-progress-bottom");
        html = "";
        html += "<div class=\"slidea-progress " + position + " " + this.settings.progress["class"] + "\">";
        html += "<div class=\"slidea-progress-bar\">";
        html += "</div>";
        html += "</div>";
        this.element.prepend(html);
        this.progress = {};
        this.progress.element = $(".slidea-progress", this.element);
        this.progress.bar = $(".slidea-progress-bar", this.element);
      };

      /*
      Animate progress bar from 0% to 100%
       */
      this.slide = function(from, to) {
        if (this.progress_animation) {
          this.progress_animation.kill();
        }
        this.progress_animation = this.animate.fromTo(this.progress.bar, this.timer.remaining / 1000, {
          width: '0%'
        }, {
          width: '100%'
        });
      };
      this.pause = function() {
        this.progress_animation.pause();
      };
      this.resume = function() {
        this.progress_animation.resume();
      };
    };
    return $.slidea.register_module('progress', $.fn.slidea.progressBar);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/progress-bar.js.map
