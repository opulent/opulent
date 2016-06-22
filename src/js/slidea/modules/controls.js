(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.controls = function() {

      /*
      Set up slider controls
       */
      this.settings = {
        enabled: false,
        thumbnail: false,
        html: {
          prev: "&lt;",
          next: "&gt;"
        },
        "class": "slidea-controls-alternate"
      };

      /*
      Slider Initialization Event
       */
      this.initialize = function() {
        if (this.slides_length === 1) {
          this.settings.controls.enabled = false;
        }
      };

      /*
      Update slide data
       */
      this.get_slide_data = function(index, slide) {
        var thumbnail;
        if (this.settings.controls.thumbnail && (this.data[index].thumbnail == null)) {
          thumbnail = slide.attr('data-slidea-thumbnail');
          if (thumbnail != null) {
            this.data[index].thumbnail = thumbnail;
          } else {
            this.data[index].thumbnail = $(this.settings.selector.background, slide).attr('src');
          }
        }
      };

      /*
      Add controls to the slider
       */
      this.load = function() {
        var alt, control, html, i, len, ref;
        html = '';
        ref = ['next', 'prev'];
        for (i = 0, len = ref.length; i < len; i++) {
          control = ref[i];
          alt = control.toLowerCase().replace(/\b[a-z]/g, function(letter) {
            return letter.toUpperCase();
          });
          html += '<a href="javascript:void(0);" class="slidea-control slidea-' + control + ' ' + this.settings.controls["class"] + '">';
          html += '<div class="slidea-control-inner">';
          if (this.settings.controls.thumbnail === true) {
            html += '<div class="slidea-control-thumbnail">';
            html += '<img src="" alt="' + alt + ' Slide" class="slidea-control-image"/>';
            html += '</div>';
          }
          html += '<div class="slidea-control-text">';
          html += this.settings.controls.html[control];
          html += '</div>';
          html += '</div>';
          html += '</a>';
        }
        this.wrapper.append(html);
        this.prev_button = $(this.settings.selector.prev, this.element);
        this.prev_button.on('click', (function(_this) {
          return function() {
            _this.slide(_this.current - 1);
          };
        })(this));
        this.next_button = $(this.settings.selector.next, this.element);
        this.next_button.on('click', (function(_this) {
          return function() {
            _this.slide(_this.current + 1);
          };
        })(this));
        if (this.settings.controls.thumbnail === true) {
          this.prev_thumbnail = $('.slidea-control-image', this.prev_button);
          this.next_thumbnail = $('.slidea-control-image', this.next_button);
        }
      };

      /*
      Run on slide modifiers for controls
       */
      this.slide = function(from, to) {
        if (this.settings.controls.thumbnail) {
          this.prev_thumbnail.attr('src', this.data[this.prev].thumbnail);
          this.next_thumbnail.attr('src', this.data[this.next].thumbnail);
          this.log("Changed control thumbnails to prev[" + from + "] and next[" + to + "].");
        }
      };
    };
    return $.slidea.register_module('controls', $.fn.slidea.controls);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/controls.js.map
