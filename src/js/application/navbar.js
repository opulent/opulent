(function() {
  (function($, window, document) {
    "use strict";
    $.navbar = function(element, options) {
      this.element = $(element);
      this.settings = {
        condense: true,
        transparentize: true
      };
      if ((this.element.attr('data-navbar-condensed') != null) && this.element.attr('data-navbar-condensed') === 'false') {
        this.settings.condense = false;
      }
      if ((this.element.attr('data-navbar-transparentize') != null) && this.element.attr('data-navbar-transparentize') === 'false') {
        this.settings.transparentize = false;
      }
      $('.navbar-toggle', this.element).on('click', (function(_this) {
        return function() {
          _this.element.toggleClass('navbar-collapsed');
        };
      })(this));
      $(window).scroll((function(_this) {
        return function() {
          var scroll_top;
          scroll_top = $(window).scrollTop();
          if (scroll_top > 25) {
            if (_this.settings.condense) {
              _this.element.addClass('navbar-condensed');
            }
            _this.element.addClass('navbar-faded');
            if (_this.settings.transparentize) {
              _this.element.removeClass('navbar-transparent');
            }
          } else {
            if (_this.element.hasClass('navbar-condensed') && _this.settings.condense) {
              _this.element.removeClass('navbar-condensed');
            }
            if (_this.settings.transparentize) {
              _this.element.addClass('navbar-transparent');
            }
            if (_this.element.hasClass('navbar-faded')) {
              _this.element.removeClass('navbar-faded');
            }
          }
        };
      })(this)).trigger('scroll');
    };
    return $.fn.navbar = function(opts) {
      return this.each(function(index, element) {
        if (!$.data(element, "navbar")) {
          return $.data(element, "navbar", new $.navbar(element, opts));
        }
      });
    };
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../maps/application/navbar.js.map
