(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.thumbnails = function() {

      /*
      Set up slider thumbnails
       */
      var resize_wrapper, scroll_to_thumbnail;
      this.settings = {
        enabled: false,
        visible: {
          xs: 12,
          sm: 6,
          md: 6,
          lg: 5,
          xlg: 5
        },
        position: "bottom",
        "class": ""
      };

      /*
      Scroll to the nth thumbnail in the collection
       */
      scroll_to_thumbnail = function(to) {
        var distance, transform;
        if (to < 0) {
          to = 0;
        }
        distance = 0;
        this.thumbnails.elements.each((function(_this) {
          return function(index, item) {
            if (index === to) {
              return false;
            }
            if (_this.settings.thumbnails.orientation === 'horizontal') {
              distance += $(item).width();
            } else if (_this.settings.thumbnails.orientation === 'vertical') {
              distance += $(item).height();
            }
          };
        })(this));
        if (this.thumbnails.size - distance < this.thumbnails.parent_size) {
          distance = this.thumbnails.size - this.thumbnails.parent_size;
        }
        this.thumbnails.starting_position = -distance;
        if (this.settings.thumbnails.orientation === 'horizontal') {
          transform = 'translate3d(' + (-distance) + 'px, 0, 0)';
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          transform = 'translate3d(0, ' + (-distance) + 'px, 0)';
        }
        this.thumbnails.inner.addClass('animating').css({
          'transform': transform,
          '-o-transform': transform,
          '-ms-transform': transform,
          '-moz-transform': transform,
          '-webkit-transform': transform
        });
        setTimeout((function(_this) {
          return function() {
            _this.thumbnails.inner.removeClass('animating');
          };
        })(this), 700);
      };

      /*
      Resize thumbnails wrapper
       */
      resize_wrapper = function() {
        var obj, thumbnail_height, thumbnail_width;
        if (!this.thumbnails.loaded) {
          return;
        }
        if (this.settings.thumbnails.orientation === 'horizontal') {
          thumbnail_height = $('img', this.thumbnails.elements.eq(0)).height();
          this.thumbnails.container.height(thumbnail_height);
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          thumbnail_width = $('img', this.thumbnails.elements.eq(0)).width();
          this.parent.css((
            obj = {},
            obj["padding-" + this.settings.thumbnails.position] = thumbnail_width,
            obj
          ));
          this.thumbnails.container.width($('img', this.thumbnails.elements.eq(0)).width());
        }
      };

      /*
      Update slide data
       */
      this.get_slide_data = function(index, slide) {
        var thumbnail;
        if (this.data[index].thumbnail == null) {
          thumbnail = slide.attr('data-slidea-thumbnail');
          if (thumbnail != null) {
            this.data[index].thumbnail = thumbnail;
          } else {
            this.data[index].thumbnail = $(this.settings.selector.background, slide).attr('src');
          }
        }
      };

      /*
      Initialize thumbnails
       */
      this.initialize = function() {
        this.thumbnails.loaded = false;
      };

      /*
      Wrap slidea inside a thumbnails wrapper for position handling
       */
      this.wrap_objects = function() {
        this.thumbnails = {};
        this.element.wrap("<div class=\"slidea-with-thumbnails " + this.settings.thumbnails.position + "\"><div class='slidea-with-thumbnails-container'></div></div>");
        this.parent = this.element.parent();
        this.thumbnails.parent = this.parent.parent();
      };

      /*
      Add thumbnails to the slider
       */
      this.load = function() {
        var css_param, html, individual_size, inner_size, pan_events, parent_height, parent_width, thumbs_count, touch_thumbnails;
        if (['left', 'right'].indexOf(this.settings.thumbnails.position) !== -1) {
          this.settings.thumbnails.orientation = 'vertical';
        } else {
          this.settings.thumbnails.orientation = 'horizontal';
        }
        thumbs_count = this.settings.thumbnails.visible[this.current_responsive_size];
        parent_height = this.wrapper_height;
        parent_width = this.wrapper_width;
        if (this.settings.thumbnails.orientation === 'horizontal') {
          individual_size = parent_width / thumbs_count;
          inner_size = individual_size * this.slides_length;
          css_param = 'width';
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          individual_size = parent_height / thumbs_count;
          inner_size = individual_size * this.slides_length;
          css_param = 'height';
        }
        html = "";
        html += "<div class=\"slidea-thumbnails-container\">";
        html += "<div class=\"slidea-thumbnails " + this.settings.thumbnails["class"] + " " + this.settings.thumbnails.orientation + "\">";
        html += ("<div class=\"slidea-thumbnails-inner\" style=\"" + css_param + ": ") + inner_size + "px;\">";
        $.each(this.data, function(index, item) {
          html += ("<div class=\"slidea-thumbnail-wrapper\" style=\"" + css_param + ": ") + individual_size + "px;\">";
          html += "<img class=\"slidea-thumbnail\" src=\"" + item.thumbnail + "\" alt=\"Slide " + index + "\" />";
          return html += "</div>";
        });
        html += "</div>";
        html += "</div>";
        html += "</div>";
        this.thumbnails.wrapper = $(html);
        if (["top", "left", "right"].indexOf(this.settings.thumbnails.position) !== -1) {
          this.element.closest('.slidea-with-thumbnails').prepend(this.thumbnails.wrapper);
        } else if (this.settings.thumbnails.position === "bottom") {
          this.element.closest('.slidea-with-thumbnails').append(this.thumbnails.wrapper);
        } else {
          this.settings.thumbnails.position.append(this.thumbnails.wrapper);
        }
        this.thumbnails.inner = $(".slidea-thumbnails-inner", this.thumbnails.wrapper);
        this.thumbnails.elements = $(".slidea-thumbnail-wrapper", this.thumbnails.wrapper);
        this.thumbnails.container = $('.slidea-thumbnails-container', this.thumbnails.parent);
        if (this.settings.thumbnails.orientation === 'horizontal') {
          this.thumbnails.size = this.thumbnails.inner.width();
          this.thumbnails.parent_size = this.thumbnails.wrapper.width();
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          this.thumbnails.size = this.thumbnails.inner.height();
          this.thumbnails.parent_size = this.thumbnails.wrapper.height();
        }
        this.thumbnails.elements.each((function(_this) {
          return function(i, el) {
            var $thumbnail;
            $thumbnail = $(el);
            $thumbnail.on("click", function() {
              _this.thumbnails.elements.filter(".active").removeClass("active");
              $thumbnail.addClass("active");
              _this.slide(i);
            });
          };
        })(this));
        $("img", this.thumbnails.elements).on("dragstart", function(event) {
          event.preventDefault();
        });
        this.thumbnails.starting_position = 0;
        this.thumbnails.starting_direction = void 0;
        if (this.settings.touch === true) {
          touch_thumbnails = new Hammer(this.thumbnails.wrapper[0]);
          if (this.settings.thumbnails.orientation === 'horizontal') {
            pan_events = 'panleft panright';
            touch_thumbnails.get('pan').set({
              direction: Hammer.DIRECTION_HORIZONTAL
            });
          } else if (this.settings.thumbnails.orientation === 'vertical') {
            pan_events = 'panup pandown';
            touch_thumbnails.get('pan').set({
              direction: Hammer.DIRECTION_VERTICAL
            });
          }
          touch_thumbnails.on("panstart pancancel panend " + pan_events, (function(_this) {
            return function(event) {
              var distance, snap_distance, transform;
              if (_this.settings.thumbnails.orientation === 'horizontal') {
                distance = event.deltaX;
              } else if (_this.settings.thumbnails.orientation === 'vertical') {
                distance = event.deltaY;
              }
              if (_this.settings.thumbnails.orientation === 'horizontal' && event.type === 'panleft' || event.type === 'panright') {
                if (event.direction === Hammer.DIRECTION_LEFT || event.direction === Hammer.DIRECTION_RIGHT) {
                  transform = "translate3d(" + (_this.thumbnails.starting_position + distance) + "px, 0, 0)";
                  _this.thumbnails.inner.css({
                    'transform': transform,
                    '-o-transform': transform,
                    '-ms-transform': transform,
                    '-moz-transform': transform,
                    '-webkit-transform': transform
                  });
                }
              } else if (_this.settings.thumbnails.orientation === 'vertical' && event.type === 'panup' || event.type === 'pandown') {
                if (event.direction === Hammer.DIRECTION_UP || event.direction === Hammer.DIRECTION_DOWN) {
                  transform = "translate3d(0, " + (_this.thumbnails.starting_position + distance) + "px, 0)";
                  _this.thumbnails.inner.css({
                    'transform': transform,
                    '-o-transform': transform,
                    '-ms-transform': transform,
                    '-moz-transform': transform,
                    '-webkit-transform': transform
                  });
                }
              } else if (event.type === 'panstart' && !_this.thumbnails.inner.hasClass('animating')) {
                _this.thumbnails.inner.addClass('slidea-dragging');
                _this.thumbnails.starting_direction = event.direction;
              } else if (event.type === 'panend') {
                _this.thumbnails.inner.removeClass('slidea-dragging');
                _this.thumbnails.starting_position += distance;
                if (_this.thumbnails.starting_position < -_this.thumbnails.size + _this.thumbnails.parent_size) {
                  scroll_to_thumbnail.call(_this, _this.slides_length - 1);
                } else if (_this.thumbnails.starting_position > 0) {
                  scroll_to_thumbnail.call(_this, 0);
                } else {
                  snap_distance = 0;
                  _this.thumbnails.elements.each(function(index, item) {
                    if (_this.thumbnails.starting_position > -snap_distance) {
                      scroll_to_thumbnail.call(_this, index);
                      return false;
                    }
                    if (_this.settings.thumbnails.orientation === 'horizontal') {
                      snap_distance += $(item).width();
                    } else if (_this.settings.thumbnails.orientation === 'vertical') {
                      snap_distance += $(item).height();
                    }
                  });
                }
              }
              event.preventDefault();
            };
          })(this));
        }
        this.thumbnails.loaded = true;
        $('img', this.thumbnails.elements.eq(0)).load((function(_this) {
          return function() {
            _this.resize();
          };
        })(this));
      };
      this.before_resize = function() {
        resize_wrapper.call(this);
      };
      this.resize = function() {
        var css_param, individual_size, inner_size, parent_height, parent_width, thumbs_count;
        if (!this.thumbnails.loaded) {
          return;
        }
        thumbs_count = this.settings.thumbnails.visible[this.current_responsive_size];
        parent_height = this.wrapper_height;
        parent_width = this.wrapper_width;
        if (this.settings.thumbnails.orientation === 'horizontal') {
          individual_size = parent_width / thumbs_count;
          inner_size = individual_size * this.slides_length;
          css_param = 'width';
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          individual_size = parent_height / thumbs_count;
          inner_size = individual_size * this.slides_length;
          css_param = 'height';
        }
        this.thumbnails.inner[css_param](inner_size);
        this.thumbnails.elements[css_param](individual_size);
        if (this.settings.thumbnails.orientation === 'horizontal') {
          this.thumbnails.size = inner_size;
        } else if (this.settings.thumbnails.orientation === 'vertical') {
          this.thumbnails.size = inner_size;
        }
        this.thumbnails.parent_size = this.thumbnails.wrapper[css_param]();
        scroll_to_thumbnail.call(this, this.current);
      };
      this.slide = function(from, to) {
        if (!this.thumbnails.loaded) {
          return;
        }
        this.thumbnails.elements.filter('.active').removeClass('active');
        this.thumbnails.elements.eq(to).addClass('active');
        scroll_to_thumbnail.call(this, to);
        this.log("Scrolled to thumbnail " + to + ".");
      };
    };
    return $.slidea.register_module('thumbnails', $.fn.slidea.thumbnails);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/thumbnails.js.map
