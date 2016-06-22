(function() {
  (function($, window, document) {
    "use strict";
    $.fn.slidea.video = function() {

      /*
      Enable or disable video features
       */
      this.settings = true;

      /*
      Setup video events at slide start for HTML5, YouTube and Vimeo videos
       */
      this.initialize = function() {

        /*
        Handle autoplay timeouts using a timeout timeline
         */
        var delay, i, interval, tries;
        this.video_timeline = {};
        delay = 500;
        interval = void 0;
        i = 0;
        tries = 10;
        $('.slidea-video-background').each(function(index, background) {
          if (!$(background).hasClass('slidea-object')) {
            $(background).addClass('slidea-object');
          }
        });
        $("video.slidea-video", this.element).attr("data-slidea-video-type", "html5");
        $("iframe[data-slidea-src*=\"youtube.com\"].slidea-video", this.element).attr("data-slidea-video-type", "youtube");
        $("iframe[data-slidea-src*=\"vimeo.com\"].slidea-video", this.element).attr("data-slidea-video-type", "vimeo");
        return $(this.settings.selector.video, this.element).each((function(_this) {
          return function(i, el) {
            var controls, id, pause_slider, separator, src, video, video_id, video_type, volume;
            video = $(el);
            volume = video.attr("data-slidea-volume");
            volume = (isNaN(volume) ? 0 : volume);
            controls = video.attr("data-slidea-controls") === "true";
            pause_slider = video.attr("data-slidea-pause-slider") === "true";
            src = video.attr("data-slidea-src");
            video_type = video.attr("data-slidea-video-type");
            if (video.attr("id") == null) {
              video.attr("id", _this.get_random_id("slidea-video"));
            }
            id = video.attr("id");
            if (video_type === "html5") {
              video.get(0).volume = volume;
              if (controls === true) {
                video.attr("controls", "controls");
              }
              if (_this.settings.autoplay === true && pause_slider === true) {
                video.on("play", function() {
                  _this.pause_timer();
                });
                video.on("pause ended", function() {
                  _this.unpause_timer();
                });
              }
            }
            if (video_type === "youtube") {
              video_id = void 0;
              separator = void 0;
              if (src.indexOf("enablejsapi=1") === -1) {
                if (src.indexOf("?") === -1) {
                  video.attr("src", src + "?enablejsapi=1");
                } else {
                  video.attr("src", src + "&enablejsapi=1");
                }
                src = video.attr("src");
              }
              if (src.indexOf("playerapiid=") === -1) {
                if (src.indexOf("?") === -1) {
                  video.attr("src", src + "?playerapiid=" + id);
                } else {
                  video.attr("src", src + "&playerapiid=" + id);
                }
                src = video.attr("src");
              }
              if (src.indexOf("embed") === "-1") {
                video_id = src.split("v=")[1];
                separator = video_id.indexOf("&");
                if (separator !== -1) {
                  video_id = video_id.substring(0, separator);
                }
              } else {
                video_id = src.split("/");
                video_id = video_id[video_id.length - 1];
                separator = video_id.indexOf("?");
                if (separator !== -1) {
                  video_id = video_id.substring(0, separator);
                }
              }
              video.load(function() {
                _this.youtube_player[id] = new YT.Player(id, {
                  height: "720",
                  width: "1280",
                  video_id: video_id,
                  events: {
                    onStateChange: function(e) {
                      if (e.data === 1) {
                        _this.pause_timer();
                      }
                      if (e.data === 2 || e.data === 0) {
                        _this.unpause_timer();
                      }
                    }
                  }
                });
                i = 0;
                interval = setInterval(function() {
                  i++;
                  if (i === tries) {
                    clearInterval(interval);
                  } else if ((_this.youtube_player[id] == null) || typeof _this.youtube_player[id].setVolume !== "function") {
                    return;
                  } else {
                    clearInterval(interval);
                  }
                  _this.youtube_player[id].setVolume(volume);
                }, delay);
              });
            }
            if (video_type === "vimeo") {
              if (src.indexOf("api=1") === -1) {
                if (src.indexOf("?") === -1) {
                  video.attr("src", src + "?api=1");
                } else {
                  video.attr("src", src + "&api=1");
                }
                src = video.attr("src");
              }
              if (src.indexOf("player_id=") === -1) {
                if (src.indexOf("?") === -1) {
                  video.attr("src", src + "?player_id=" + id);
                } else {
                  video.attr("src", src + "&player_id=" + id);
                }
                src = video.attr("src");
              }
              video.load(function() {
                _this.vimeo_player[id] = $f(id);
                _this.vimeo_player[id].addEvent("ready", function() {
                  video.attr("data-slidea-ready", "true");
                  _this.vimeo_player[id].api("setVolume", volume);
                  if (_this.settings.autoplay === true && pause_slider === true) {
                    _this.vimeo_player[id].addEvent("play", _this.pause_timer);
                    _this.vimeo_player[id].addEvent("pause", _this.unpause_timer);
                    _this.vimeo_player[id].addEvent("finish", _this.unpause_timer);
                  }
                });
              });
            }
          };
        })(this));
      };

      /*
      Handle video events at slide start for HTML5, YouTube and Vimeo videos
       */
      this.slide = function(from, to) {
        var from_slide, from_videos, to_slide, to_videos;
        from_slide = this.slides.eq(from);
        to_slide = this.slides.eq(to);
        from_videos = $(this.settings.selector.video, from_slide);
        to_videos = $(this.settings.selector.video, to_slide);
        if (from !== -1 && from_videos.length > 0) {
          from_videos.each((function(_this) {
            return function(video_index, video) {
              var id, reset, video_type;
              video = $(video);
              id = video.attr('id');
              video_type = video.attr('data-slidea-video-type');
              reset = video.attr('data-slidea-reset') === 'true';
              clearTimeout(_this.video_timeline[id]);
              if (video_type === 'html5') {
                video.get(0).pause();
                if (reset) {
                  setTimeout((function() {
                    video.get(0).current_time = 0;
                  }), _this.data[to].background[0].animation[0].duration);
                }
              } else if (video_type === 'youtube') {
                _this.youtube_player[id].pauseVideo();
                if (reset) {
                  setTimeout((function() {
                    _this.youtube_player[id].stopVideo();
                  }), _this.data[to].background[0].animation[0].duration);
                }
              } else if (video_type === 'vimeo') {
                _this.vimeo_player[id].api('pause');
                if (reset) {
                  setTimeout((function() {
                    _this.vimeo_player[id].api('unload');
                  }), _this.data[to].background[0].animation[0].duration);
                }
              }
            };
          })(this));
          this.log("Paused (handled) videos from slide " + from + ".");
        }
        if (to_videos.length > 0) {
          to_videos.each((function(_this) {
            return function(index, video) {
              var autoplay, autoplay_time, delay, i, id, interval, pause_slider, tries;
              video = $(video);
              id = video.attr('id');
              i = 0;
              tries = 10;
              delay = 500;
              interval = void 0;
              autoplay = video.attr('data-slidea-autoplay') === 'true';
              if (video.attr('data-slidea-autoplay-time') != null) {
                autoplay_time = parseInt(video.attr('data-slidea-autoplay-time'), 10);
              } else {
                autoplay_time = 100;
              }
              pause_slider = video.attr('data-slidea-pause-slider') === 'true';
              if (video.attr('data-slidea-video-type') === 'html5') {
                if (autoplay === true) {
                  _this.video_timeline[id] = setTimeout((function() {
                    video.get(0).play();
                  }), autoplay_time);
                }
              }
              if (video.attr('data-slidea-video-type') === 'youtube') {
                if (autoplay === true) {
                  i = 0;
                  interval = setInterval(function() {
                    i++;
                    if (i === tries) {
                      clearInterval(interval);
                    } else if ((video.attr('data-slidea-ready') == null) || !defined(_this.youtube_player[id]) || typeof _this.youtube_player[id].playVideo !== 'function') {
                      return;
                    } else {
                      clearInterval(interval);
                    }
                    _this.video_timeline[id] = setTimeout(function() {
                      _this.youtube_player[id].playVideo();
                    }, autoplay_time);
                  }, delay);
                }
              }
              if (video.attr('data-slidea-video-type') === 'vimeo') {
                if (autoplay === true) {
                  i = 0;
                  interval = setInterval(function() {
                    i++;
                    if (i === tries) {
                      clearInterval(interval);
                    } else if ((video.attr('data-slidea-ready') == null) || typeof _this.vimeo_player[id].api !== 'function') {
                      return;
                    } else {
                      clearInterval(interval);
                    }
                    _this.video_timeline[id] = setTimeout(function() {
                      Froogaloop(id).api('play');
                    }, autoplay_time);
                  }, delay);
                }
              }
            };
          })(this));
          this.log("Played (handled) videos from slide " + to + ".");
        }
      };
      this.resize = function() {
        this.slides.each((function(_this) {
          return function(i, element) {
            var data_height, data_width, margin_left, margin_top, slide, video, video_background, video_height, video_width;
            slide = $(element);
            $(_this.settings.selector.video, _this.element).each(function(i, video) {
              var height, parent, width;
              video = $(video);
              parent = video.parent();
              if (parent.is('.slidea-video-background')) {
                return;
              }
              height = parent.height();
              width = parent.width();
              video.css({
                width: width,
                height: height
              });
            });
            video_background = $('.slidea-video-background', slide);
            if (video_background.length > 0) {
              video = $('.video', video_background);
              data_width = parseInt(video.attr('data-slidea-width'));
              data_height = parseInt(video.attr('data-slidea-height'));
              video_width = _this.slider_width;
              video_height = video_width * data_height / data_width;
              margin_left = -(video_width - _this.slider_width) / 2;
              margin_top = -(video_height - _this.slider_height) / 2;
              video.css({
                'width': video_width,
                'height': video_height,
                'margin-left': margin_left,
                'margin-top': margin_top
              });
            }
          };
        })(this));
      };
    };
    return $.slidea.register_module('video', $.fn.slidea.video);
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../../maps/slidea/modules/video.js.map
