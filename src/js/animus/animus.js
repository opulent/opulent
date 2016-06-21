
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
    $.animus = function(defaults, finals) {
      var calc, error, model, operation;
      model = {};
      model.defaults = {
        duration: 600,
        easing: 'swing',
        state: {
          opacity: 1,
          rotateX: '0deg',
          rotateY: '0deg',
          rotateZ: '0deg',
          translateX: 0,
          translateY: 0,
          translateZ: 0,
          scale: 1,
          scaleX: 1,
          scaleY: 1,
          scaleZ: 1,
          skewX: '0%',
          skewY: '0%'
        },
        timeline: null
      };
      model.finals = {
        state: {
          opacity: 0,
          rotateX: '45deg',
          rotateY: '45deg',
          rotateZ: '45deg',
          translateX: '-100%',
          translateY: '-100%',
          translateZ: '-100%',
          scale: 2,
          scaleX: 2,
          scaleY: 2,
          scaleZ: 2,
          skewX: '100%',
          skewY: '100%'
        }
      };
      this.init = function() {
        $.extend(model.defaults, defaults);
        $.extend(model.finals, finals);
      };
      this.get = function(string) {
        var animation;
        animation = {};
        animation.state = {
          translateZ: 0
        };
        animation.duration = model.defaults.duration;
        animation.easing = model.defaults.easing;
        animation.timeline = null;
        if (string === '' || (string == null)) {
          return animation;
        }
        string = string.split(',');
        $.each(string, function(string) {
          var i, parameter;
          i = 0;
          string = $.trim(this);
          if (/\(.*\)/.test(string)) {
            string = string.replace(/\s*\(\s*/, ' ').replace(/\s*\)\s*/, ' ');
          }
          string = string.split(/\s+/);
          string = $.grep(string, function(n) {
            return n !== "";
          });
          switch (string[i]) {
            case 'duration':
            case 'speed':
              if (string[1] == null) {
                error('argument', string[1]);
              }
              animation.duration = parseInt(string[1]);
              break;
            case 'easing':
              if (string[1] == null) {
                error('argument', string[1]);
              }
              if (string[1][0] === '[') {
                string[1] = string[1].slice(1);
                string[string.length - 1] = string[string.length - 1].slice(0, -1);
                animation.easing = string.slice(1).map(function(item) {
                  return parseFloat(item);
                });
              } else {
                animation.easing = string[1];
              }
              break;
            case 'opacity':
            case 'fade':
              parameter = 'opacity';
              switch (string[1]) {
                case 'in':
                  animation.state[parameter] = 1;
                  break;
                case 'out':
                  animation.state[parameter] = 0;
                  break;
                default:
                  animation.state[parameter] = string[1];
              }
              break;
            case 'rotate':
              parameter = 'rotateZ';
              i = 1;
              switch (string[i]) {
                case 'x':
                case 'y':
                case 'z':
                  parameter = "rotate" + (string[i].toUpperCase());
                  break;
                default:
                  --i;
              }
              if (string[++i] != null) {
                animation.state[parameter] = string[i];
              } else {
                animation.state[parameter] = model.finals.state[parameter];
              }
              break;
            case 'scale':
              parameter = 'scale';
              i = 1;
              switch (string[i]) {
                case 'x':
                case 'y':
                case 'z':
                  parameter = "scale" + (string[i].toUpperCase());
                  break;
                default:
                  --i;
              }
              if (string[++i] != null) {
                switch (string[i]) {
                  case 'up':
                    animation.state[parameter] = operation('*', 1, model.finals.state[parameter]);
                    break;
                  case 'down':
                    animation.state[parameter] = operation('/', 1, model.finals.state[parameter]);
                    break;
                  default:
                    animation.state[parameter] = string[i];
                }
              } else {
                animation.state[parameter] = operation('*', 1, model.finals.state[parameter]);
              }
              break;
            case 'skew':
              parameter = 'skewX';
              i = 1;
              switch (string[i]) {
                case 'x':
                case 'y':
                  parameter = "rotate" + (string[i].toUpperCase());
                  break;
                default:
                  --i;
              }
              if (string[++i] != null) {
                animation.state[parameter] = string[i];
              } else {
                animation.state[parameter] = model.finals.state[parameter];
              }
              break;
            case 'move':
            case 'slide':
            case 'translate':
              parameter = 'translateX';
              i = 1;
              switch (string[i]) {
                case 'left':
                case 'right':
                case 'x':
                  parameter = 'translateX';
                  break;
                case 'up':
                case 'down':
                case 'y':
                  parameter = 'translateY';
                  break;
                case 'z':
                  parameter = 'translateZ';
                  break;
                default:
                  --i;
              }
              if (string[++i] != null) {
                animation.state[parameter] = string[i];
              } else {
                switch (string[i - 1]) {
                  case 'x':
                  case 'y':
                  case 'z':
                    animation.state[parameter] = model.finals.state[parameter];
                    break;
                  case 'in':
                  case 'up':
                  case 'left':
                    animation.state[parameter] = model.finals.state[parameter];
                    break;
                  case 'out':
                  case 'down':
                  case 'right':
                    animation.state[parameter] = operation('*', -1, model.finals.state[parameter]);
                    break;
                  default:
                    animation.state[parameter] = model.finals.state[parameter];
                }
              }
              break;
            default:
              parameter = string[0];
              if ((indexOf.call($.Velocity.CSS.Lists.transforms3D, parameter) >= 0) || (indexOf.call($.Velocity.CSS.Lists.transformsBase, parameter) >= 0) || (indexOf.call($.Velocity.CSS.Lists.colors, parameter) >= 0)) {
                animation.state[parameter] = string[1];
              } else if (parameter in $.Velocity.Redirects) {
                animation.state = parameter;
              } else {
                error('unknown', string[0]);
              }
          }
        });
        return animation;
      };
      this.reset = function(state, data, deep) {
        var reset;
        reset = {};
        if (deep === true) {
          $.each(data.animation, function(anim) {
            if ($.type(this.state) === 'string') {
              return;
            }
            $.each(this.state, function(key) {
              if (!(key in reset) && key in model.defaults.state) {
                reset[key] = model.defaults.state[key];
              }
            });
          });
        } else {
          $.each(data, function(key) {
            if (!(key in reset) && key in model.defaults.state) {
              reset[key] = model.defaults.state[key];
            }
          });
        }
        return $.extend(reset, state);
      };
      this.forcefeed = function(final, initial) {
        var key, result;
        result = {};
        initial = initial ? $.extend({}, model.defaults.state, initial) : model.defaults.state;
        for (key in final) {
          if (final[key] !== initial[key]) {
            result[key] = [initial[key], final[key]];
          } else {
            result[key] = final[key];
          }
        }
        return result;
      };
      calc = {
        '+': function(a, b) {
          return a + b;
        },
        '-': function(a, b) {
          return a - b;
        },
        '*': function(a, b) {
          return a * b;
        },
        '/': function(a, b) {
          return a / b;
        }
      };
      operation = function(op, x, y) {
        var exp, matchx, matchy;
        if (!(typeof x === 'string' || x instanceof String)) {
          x = x.toString();
        }
        if (!(typeof y === 'string' || y instanceof String)) {
          y = y.toString();
        }
        exp = /(-?[0-9]*)(px|%|deg)/i;
        matchx = x.match(exp);
        matchy = y.match(exp);
        x = matchx !== null ? parseFloat(matchx[1]) : parseFloat(x);
        y = matchy !== null ? parseFloat(matchy[1]) : parseFloat(y);
        if (matchx !== null && matchy !== null) {
          return calc[op](x, y) + matchx[2];
        }
        if (matchx !== null && matchy === null) {
          return calc[op](x, y) + matchx[2];
        }
        if (matchx === null && matchy !== null) {
          return calc[op](x, y) + matchy[2];
        }
        return calc[op](x, y);
      };
      error = function(context, data) {
        var message;
        switch (context) {
          case 'argument':
            message = "Missing animation argument for \"" + data + "\".";
            break;
          default:
            message = "Unknown animation parameter \"" + data + "\".";
        }
        return console.error("[Animus] " + message);
      };
      this.init();
    };
  })(jQuery, window, document);

}).call(this);

//# sourceMappingURL=../src/maps/animus/animus.js.map
