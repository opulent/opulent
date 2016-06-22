(($, window, document) ->
  "use strict"

  # @Navbar
  $.form = (element, options) ->
    @settings = {}
    @settings.maxMessages = 2

    @messages_sent = 0

    @form = $(element)
    @groups = $('.form-group', @form)
    @inputs = $('input, textarea', @form)
    @check = {}

    @action = @form.attr 'action'
    @method = @form.attr 'method'
    @method = 'POST' unless @method?

    @send_button = $('.send-button')

    @success_message = $('.contact-success', @form)
    @show_success = =>
      @send_button.removeClass 'sending'
      @success_message.addClass 'active'
      setTimeout =>
        @success_message.removeClass 'active'
        return
      , 5000
      return

    @error_message = $('.contact-error', @form)
    @show_error = =>
      @send_button.removeClass 'sending'
      @error_message.addClass 'active'
      setTimeout =>
        @error_message.removeClass 'active'
        return
      , 5000
      return

    # Captcha fields
    $('[data-validate-captcha]', @form).each (index, input) =>
      input = $(input)
      parent = input.parent()
      label = $('label', parent)

      min = 1
      max = 10
      random1 = Math.floor(Math.random() * (max - min + 1)) + min
      random2 = Math.floor(Math.random() * (max - min + 1)) + min

      captcha = random1 + random2

      input.data 'captcha', captcha
      label.text "#{random1} + #{random2} = ?"
      return

    # Focus Animation
    @groups.each (index, group) =>
      group = $(group)
      input = $('input, textarea', group)
      label = $('label', group)

      group.on 'click', =>
        input.focus()
        return

      if input.val() != ""
        label.addClass 'active'

      input.on 'focusin', =>
        group.removeClass 'has-error'
        label.addClass 'active'
        return

      input.on 'focusout', =>
        if input.val() == ""
          label.removeClass 'active'
        return
      return

    ###
    Validate all inputs by validation type
    ###
    @validate = =>
      valid = true
      @inputs.each (index, input) =>
        input_valid = true
        input = $(input)
        value = input.val()
        $.each @check, (method) =>
          input_valid &&= @check[method](input, value)
          input.parent().addClass 'has-error' unless input_valid
          return
        valid &&= input_valid
        return
      return valid

    ###
    Get validate attribute
    ###
    @get_attr = (input, data, fallback) =>
      attr = input.attr "data-validate-#{data}"
      if attr?
        return attr
      else if fallback?
        return fallback

    ###
    Validate Email
    ###
    @check['email'] = (input, value) =>
      attr = @get_attr input, 'email'
      return true unless attr?
      return /[A-Z0-9._%+-]+\@[A-Z0-9.-]+\.[A-Z]+/i.test value

    ###
    Validate Minimum Length
    ###
    @check['min-length'] = (input, value) =>
      attr = @get_attr input, 'min-length'
      return true unless attr?
      return value.length > parseInt(attr)

    ###
    Validate Maximum Length
    ###
    @check['max-length'] = (input, value) =>
      attr = @get_attr input, 'max-length'
      return true unless attr?
      return value.length < parseInt(attr)

    ###
    Validate Required
    ###
    @check['required'] = (input, value) =>
      attr = @get_attr input, 'required'
      return true unless attr?
      return value != ''

    ###
    Validate Captcha
    ###
    @check['captcha'] = (input, value) =>
      attr = @get_attr input, 'captcha'
      return true unless attr?
      return /[0-9]+/.test(value) and parseInt(value) == input.data('captcha')

    # Form submit check
    @form.submit (e) =>
      valid = @validate()

      if valid and not @send_button.hasClass('sending')
        @messages_sent += 1

        if @messages_sent > @settings.maxMessages
          alert "You have already sent #{@settings.maxMessages} messages."
        else
          @send_button.addClass 'sending'

          ajax = {}
          ajax['url'] = @action if @action?
          ajax['type'] = @method
          ajax['data'] = @form.serialize()
          ajax['success'] = =>
            @show_success()
            return
          ajax['error'] = (e) =>
            console.error e
            @show_error()
            return
          $.ajax ajax

      e.preventDefault()
      return false

    return

  # Lightweight plugin wrapper that prevents multiple instantiations.
  #
  $.fn.form = (opts) ->
    @each (index, element) ->
      unless $.data element, "form"
        $.data element, "form", new $.form element, opts

) window.jQuery, window, document
