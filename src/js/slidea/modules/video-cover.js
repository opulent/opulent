(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.videoCover = function() {

      /*
      Enable or disable video cover features
       */
      this.settings = true;

      /*
      Set up the video covers so that they fade out and play the
      actual video on click event
       */
      this.load = function() {
        var covers, hide;
        hide = (function(_this) {
          return function(cover) {
            _this.animate.to(cover, 0.5, {
              opacity: 0,
              onComplete: function() {
                cover.css({
                  display: 'none'
                });
              }
            });
          };
        })(this);
        covers = $(this.settings.selector.videoCover, this.element);
        covers.each((function(_this) {
          return function(i, el) {
            var cover, id, parent, type, video;
            cover = $(el);
            parent = cover.parent();
            video = $(_this.settings.selector.video, parent);
            type = video.attr('data-slidea-video-type');
            id = video.attr("id");
            switch (type) {
              case "html5":
                cover.on("click", function() {
                  video.get(0).play();
                  hide(cover);
                });
                break;
              case "youtube":
                cover.on("click", function() {
                  _this.youtube_player[id].playVideo();
                  hide(cover);
                });
                break;
              case "vimeo":
                cover.on("click", function() {
                  _this.vimeo_player[id].api("play");
                  hide(cover);
                });
            }
          };
        })(this));
        if (covers.length > 0) {
          this.log("Added video cover events.");
        }
      };

      /*
      Animate progress bar from 0% to 100%
       */
      this.slide = function(from, to) {
        var covers, slide;
        slide = this.slides.eq(to);
        covers = $(this.settings.selector.videoCover, slide);
        covers.each((function(_this) {
          return function(i, el) {
            var cover;
            cover = $(el);
            cover.css({
              display: 'block'
            });
            _this.animate.to(cover, 0.5, {
              opacity: 1
            });
          };
        })(this));
      };
    };
    return $.slidea.register_module('videoCover', $.fn.slidea.videoCover);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/video-cover.js.map
