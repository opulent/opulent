
/*

                  oo

.d8888b. 88d888b. dP 88d8b.d8b. dP    dP .d8888b.
88'  `88 88'  `88 88 88'`88'`88 88    88 Y8ooooo.
88.  .88 88    88 88 88  88  88 88.  .88       88
`88888P8 dP    dP dP dP  dP  dP `88888P' `88888P'
oooooooooooooooooooooooooooooooooooooooooooooooooo

@plugin    jQuery
@license   CodeCanyon Standard / Extended
@author    Alex Grozav
@company   Pixevil
@website   http://pixevil.com
@email     alex@grozav.com
 */

(function() {
  var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  (function($, window, document) {
    'use strict';
    $.animus = function(override) {
      var model;
      model = {};
      model.duration = 600;
      model.defaults = {
        opacity: 1,
        rotationX: 0,
        rotationY: 0,
        rotationZ: 0,
        x: 0,
        y: 0,
        z: 0,
        xPercent: 0,
        yPercent: 0,
        scale: 1,
        scaleX: 1,
        scaleY: 1,
        scaleZ: 1,
        skewX: 0,
        skewY: 0,
        easing: "Quad.easeOut"
      };
      this.parameters = ['scale', 'scaleX', 'scaleY', 'scaleZ', 'x', 'y', 'z', 'skewX', 'skewY', 'rotation', 'rotationX', 'rotationY', 'rotationZ', 'perspective', 'xPercent', 'yPercent', 'shortRotation', 'shortRotationX', 'shortRotationY', 'shortRotationZ', 'transformOrigin', 'svgOrigin', 'transformPerspective', 'directionalRotation', 'parseTransform', 'force3D', 'skewType', 'smoothOrigin', 'boxShadow', 'borderRadius', 'backgroundPosition', 'backgroundSize', 'perspectiveOrigin', 'transformStyle', 'backfaceVisibility', 'userSelect', 'margin', 'padding', 'color', 'clip', 'textShadow', 'autoRound', 'strictUnits', 'border', 'borderWidth', 'float', 'cssFloat', 'styleFloat', 'perspectiveOrigin', 'transformStyle', 'backfaceVisibility', 'userSelect', 'opacity', 'alpha', 'autoAlpha', 'className', 'clearProps'];
      this.init = function() {
        $.extend(model, override);
      };

      /*
      Process an animation string of the form "rotate 45, fade in" into
      a usable VelocityJS animation object
      
      @var     string      The animation string to be modified, of the form
                           move x 300px, fade in, scale up
       */
      this.get = function(input) {
        var animation;
        animation = {};
        animation.state = {
          z: 0
        };
        animation.duration = model.duration / 1000;
        animation.timeline = null;
        if (input === '' || (input == null) || !input) {
          return animation;
        }
        input = input.split(/(\,\s*)/);
        $.each(input, (function(_this) {
          return function(index, string) {
            var i, parameter, value;
            i = 0;
            string = $.trim(string);
            if (/\(.*\)/.test(string)) {
              string = string.replace(/\s*\(\s*/, ' ').replace(/\s*\)\s*/, ' ');
            }
            string = string.split(/\s+/);
            string = $.grep(string, function(n) {
              return n !== "";
            });
            parameter = string.shift();
            value = string.join(' ');
            if (['duration', 'speed'].indexOf(parameter) !== -1) {
              animation.duration = parseFloat(value, 10) / 1000;
            } else if (['ease', 'easing'].indexOf(parameter) !== -1) {
              animation.state.ease = value;
            } else if (indexOf.call(_this.parameters, parameter) >= 0) {
              if ((value != null) && !/.+(\s+.+)+/.test(value)) {
                if (/px/.test(value)) {
                  value = parseFloat(value.replace('px', ''), 10);
                } else if (/deg/.test(value)) {
                  value = parseFloat(value.replace('deg', ''), 10);
                }
                if (/^[0-9](\.[0-9]+)?$/.test(value)) {
                  value = parseFloat(value, 10);
                }
              }
              animation.state[parameter] = value;
            } else if (parameter in $.animus.presets) {
              animation.state = parameter;
            }
          };
        })(this));
        return animation;
      };

      /*
      Set reset state by getting all the animation variables
      and setting them to the default values
      
      @param data [State] State which overwrites reset variables
      @param data [Object] Element states data in RockSlider
      @param deep [Boolean] Generate reset from an array of animations if true
                            or from a single animation if false
       */
      this.reset = function(state, data) {

        /*
        Check if we need to add the percentage sign to the default state value
         */
        var percentage, reset;
        percentage = function(value) {
          if (/\%$/.test(value)) {
            return '%';
          } else {
            return '';
          }
        };
        reset = {};
        $.each(data, function(anim) {
          if ($.type(this.state) === 'string') {
            return;
          }
          $.each(this.state, function(key, value) {
            if (!(key in reset) && key in model.defaults) {
              reset[key] = model.defaults[key] + percentage(value);
            }
          });
        });
        return $.extend({}, reset, state);
      };
      this.init();
    };
    $.animus.presets = {};
    $.animus.register_preset = function(name, timeline) {
      $.animus.presets[name] = timeline;
    };
  })(jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../maps/animus/animus.js.map
