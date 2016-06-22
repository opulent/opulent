(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.pagination = function() {

      /*
      Set up pagination component
       */
      this.settings = {
        enabled: false,
        position: "bottom",
        "class": "slidea-pagination-light"
      };

      /*
      Add pagination bullets to the slider
       */
      this.initialize = function() {
        var html, i, pagination, position;
        if (this.slides_length === 1) {
          return;
        }
        position = "slidea-pagination-" + this.settings.pagination.position;
        html = "";
        html += "<div class=\"slidea-pagination " + position + " " + this.settings.pagination["class"] + "\">";
        i = 0;
        while (i < this.slides_length) {
          html += "<div class=\"slidea-pagination-bullet\"></div>";
          i++;
        }
        html += "</div>";
        pagination = $(html);
        switch (this.settings.pagination.position) {
          case "before":
            this.element.before(pagination);
            break;
          case "after":
            this.element.after(pagination);
            break;
          default:
            this.element.prepend(pagination);
        }
        this.pagination = $(".slidea-pagination-bullet", pagination);
        this.pagination.each((function(_this) {
          return function(i, el) {
            var pagination_bullet;
            pagination_bullet = $(el);
            pagination_bullet.on("click", function() {
              _this.pagination.filter(".active").removeClass("active");
              pagination_bullet.addClass("active");
              _this.slide(i);
            });
          };
        })(this));
      };
      this.slide = function(from, to) {
        this.pagination.filter('.active').removeClass('active');
        this.pagination.eq(to).addClass('active');
      };
    };
    return $.slidea.register_module('pagination', $.fn.slidea.pagination);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/pagination.js.map
