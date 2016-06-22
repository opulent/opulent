(function() {
  (function($, window, document) {
    "use strict";
    $.form = function(element, options) {
      this.settings = {};
      this.settings.maxMessages = 2;
      this.messages_sent = 0;
      this.form = $(element);
      this.groups = $('.form-group', this.form);
      this.inputs = $('input, textarea', this.form);
      this.check = {};
      this.action = this.form.attr('action');
      this.method = this.form.attr('method');
      if (this.method == null) {
        this.method = 'POST';
      }
      this.send_button = $('.send-button');
      this.success_message = $('.contact-success', this.form);
      this.show_success = (function(_this) {
        return function() {
          _this.send_button.removeClass('sending');
          _this.success_message.addClass('active');
          setTimeout(function() {
            _this.success_message.removeClass('active');
          }, 5000);
        };
      })(this);
      this.error_message = $('.contact-error', this.form);
      this.show_error = (function(_this) {
        return function() {
          _this.send_button.removeClass('sending');
          _this.error_message.addClass('active');
          setTimeout(function() {
            _this.error_message.removeClass('active');
          }, 5000);
        };
      })(this);
      $('[data-validate-captcha]', this.form).each((function(_this) {
        return function(index, input) {
          var captcha, label, max, min, parent, random1, random2;
          input = $(input);
          parent = input.parent();
          label = $('label', parent);
          min = 1;
          max = 10;
          random1 = Math.floor(Math.random() * (max - min + 1)) + min;
          random2 = Math.floor(Math.random() * (max - min + 1)) + min;
          captcha = random1 + random2;
          input.data('captcha', captcha);
          label.text(random1 + " + " + random2 + " = ?");
        };
      })(this));
      this.groups.each((function(_this) {
        return function(index, group) {
          var input, label;
          group = $(group);
          input = $('input, textarea', group);
          label = $('label', group);
          group.on('click', function() {
            input.focus();
          });
          if (input.val() !== "") {
            label.addClass('active');
          }
          input.on('focusin', function() {
            group.removeClass('has-error');
            label.addClass('active');
          });
          input.on('focusout', function() {
            if (input.val() === "") {
              label.removeClass('active');
            }
          });
        };
      })(this));

      /*
      Validate all inputs by validation type
       */
      this.validate = (function(_this) {
        return function() {
          var valid;
          valid = true;
          _this.inputs.each(function(index, input) {
            var input_valid, value;
            input_valid = true;
            input = $(input);
            value = input.val();
            $.each(_this.check, function(method) {
              input_valid && (input_valid = _this.check[method](input, value));
              if (!input_valid) {
                input.parent().addClass('has-error');
              }
            });
            valid && (valid = input_valid);
          });
          return valid;
        };
      })(this);

      /*
      Get validate attribute
       */
      this.get_attr = (function(_this) {
        return function(input, data, fallback) {
          var attr;
          attr = input.attr("data-validate-" + data);
          if (attr != null) {
            return attr;
          } else if (fallback != null) {
            return fallback;
          }
        };
      })(this);

      /*
      Validate Email
       */
      this.check['email'] = (function(_this) {
        return function(input, value) {
          var attr;
          attr = _this.get_attr(input, 'email');
          if (attr == null) {
            return true;
          }
          return /[A-Z0-9._%+-]+\@[A-Z0-9.-]+\.[A-Z]+/i.test(value);
        };
      })(this);

      /*
      Validate Minimum Length
       */
      this.check['min-length'] = (function(_this) {
        return function(input, value) {
          var attr;
          attr = _this.get_attr(input, 'min-length');
          if (attr == null) {
            return true;
          }
          return value.length > parseInt(attr);
        };
      })(this);

      /*
      Validate Maximum Length
       */
      this.check['max-length'] = (function(_this) {
        return function(input, value) {
          var attr;
          attr = _this.get_attr(input, 'max-length');
          if (attr == null) {
            return true;
          }
          return value.length < parseInt(attr);
        };
      })(this);

      /*
      Validate Required
       */
      this.check['required'] = (function(_this) {
        return function(input, value) {
          var attr;
          attr = _this.get_attr(input, 'required');
          if (attr == null) {
            return true;
          }
          return value !== '';
        };
      })(this);

      /*
      Validate Captcha
       */
      this.check['captcha'] = (function(_this) {
        return function(input, value) {
          var attr;
          attr = _this.get_attr(input, 'captcha');
          if (attr == null) {
            return true;
          }
          return /[0-9]+/.test(value) && parseInt(value) === input.data('captcha');
        };
      })(this);
      this.form.submit((function(_this) {
        return function(e) {
          var ajax, valid;
          valid = _this.validate();
          if (valid && !_this.send_button.hasClass('sending')) {
            _this.messages_sent += 1;
            if (_this.messages_sent > _this.settings.maxMessages) {
              alert("You have already sent " + _this.settings.maxMessages + " messages.");
            } else {
              _this.send_button.addClass('sending');
              ajax = {};
              if (_this.action != null) {
                ajax['url'] = _this.action;
              }
              ajax['type'] = _this.method;
              ajax['data'] = _this.form.serialize();
              ajax['success'] = function() {
                _this.show_success();
              };
              ajax['error'] = function(e) {
                console.error(e);
                _this.show_error();
              };
              $.ajax(ajax);
            }
          }
          e.preventDefault();
          return false;
        };
      })(this));
    };
    return $.fn.form = function(opts) {
      return this.each(function(index, element) {
        if (!$.data(element, "form")) {
          return $.data(element, "form", new $.form(element, opts));
        }
      });
    };
  })(window.jQuery, window, document);

}).call(this);

//# sourceMappingURL=../../maps/application/form.js.map
