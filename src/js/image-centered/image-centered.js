
/*
@plugin  	Image Centered
@author 	Alex Grozav
@website  http://pixevil.com
@version 	1.0
@license 	Commercial
 */

(function() {
  (function($, window, document) {
    "use strict";
    var _defaults;
    _defaults = {
      source: null,
      parent: null,
      resize_timeout: 10,
      debug: false
    };
    $.imageCentered = function(element, options) {
      this._defaults = _defaults;
      this.settings = $.extend(true, {}, this._defaults, options);
      this.element = $(element);
      this.source = this.settings.source ? this.settings.source : this.element;
      this.parent = this.settings.parent ? this.settings.parent : this.source.parent();
      this.initialize = (function(_this) {
        return function() {
          _this.bind_resize();
          _this.set_size();
          _this.center();
        };
      })(this);
      this.set_size = (function(_this) {
        return function() {
          _this.parent_height = _this.parent.outerHeight(true);
          _this.parent_width = _this.parent.outerWidth(true);
          _this.height = _this.source.outerHeight(true);
          _this.width = _this.source.outerWidth(true);
        };
      })(this);
      this.center = (function(_this) {
        return function() {
          if (_this.settings.debug) {
            console.log(_this.parent_height, _this.height, _this.parent_height - _this.height);
          }
          if (_this.parent_height > _this.height) {
            _this.element.removeClass('full-width').addClass('full-height');
            _this.element.css({
              'margin-top': "0px",
              'margin-left': ((_this.parent_width - _this.width) / 2) + "px"
            });
          } else if (_this.parent_width > _this.width) {
            _this.element.removeClass('full-height').addClass('full-width');
            _this.element.css({
              'margin-top': ((_this.parent_height - _this.height) / 2) + "px",
              'margin-left': "0px"
            });
          } else {
            _this.element.css({
              'margin-top': ((_this.parent_height - _this.height) / 2) + "px",
              'margin-left': ((_this.parent_width - _this.width) / 2) + "px"
            });
          }
        };
      })(this);
      this.bind_resize = (function(_this) {
        return function() {
          var resize_timeout;
          resize_timeout = null;
          return $(window).resize(function() {
            clearTimeout(resize_timeout);
            resize_timeout = setTimeout(function() {
              _this.set_size();
              _this.center();
            }, _this.settings.resize_timeout);
          });
        };
      })(this);
      this.initialize();
    };
    return $.fn.imageCentered = function(opts) {
      return this.each(function(index, element) {
        if (!$.data(element, "imageCentered")) {
          return $.data(element, "imageCentered", new $.imageCentered(element, opts));
        }
      });
    };
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../src/maps/image-centered/image-centered.js.map
