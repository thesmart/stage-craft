# The login control partial
App.LoginPartial = ((element) ->
  element = $(element)
  element.data('app', @)

  form_el = element.find('form')
  parsley = App.parsley(form_el)
  flash = new App.Flash(element.find('.alert'))

  @focus = $.proxy(App.mixins.focus, @, form_el)

  # handle form submit
  on_submit_lock = App.lock()
  on_submit = (e) =>
    return if e.isDefaultPrevented()
    return unless parsley.isValid()
    return if on_submit_lock.locked

    App.post("/api/session/login", App.serializeForm(form_el), on_submit_lock).done((meta, msg) =>
      flash.hide()
      App.redirect('/')
    ).fail((meta, msg) =>
      flash.show(msg)
      form_el.find('input[type="password"]').val('')
      parsley.validate()
      @focus()
    )

  form_el.on('submit.LoginPartial', on_submit)
  this
)

# The signup control partial
App.SignupPartial = ((element) ->
  element = $(element)
  element.data('app', @)

  form_el = element.find('form')
  parsley = App.parsley(form_el)
  flash = new App.Flash(element.find('.alert'))

  # focus on the last element
  @focus = $.proxy(App.mixins.focus, @, form_el)

  # handle form submit
  on_submit_lock = App.lock()
  on_submit = (e) =>
    return if e.isDefaultPrevented()
    return unless parsley.isValid()
    return if on_submit_lock.locked

    App.post("/api/session/signup", App.serializeForm(form_el), on_submit_lock).done((meta, msg) =>
      flash.hide()
      App.redirect('/validate')
    ).fail((meta, msg) =>
      flash.show(msg)
      @focus()
    )

  form_el.on('submit.SignupPartial', on_submit)
  this
)


# reset the password
App.PasswordForgotPartial = ((element) ->
  element = $(element)
  element.data('app', @)

  form_el = element.find('form')
  parsley = App.parsley(form_el)
  flash = new App.Flash(element.find('.alert'))

  # handle form submit
  on_submit_lock = App.lock()
  on_submit = (e) =>
    return if e.isDefaultPrevented()
    return unless parsley.isValid()
    return if on_submit_lock.locked

    App.post("/api/password/forgot", App.serializeForm(form_el), on_submit_lock).done((meta, msg)->
      flash.show(msg, 'success')
    ).fail((meta, msg)->
      flash.show(msg, 'warning')
    )

  form_el.on('submit.PasswordForgotPartial', on_submit)
  this
)

App.PasswordChangePartial = ((element) =>
  element = $(element)
  element.data('app', @)

  form_el = element.find('form')
  parsley = App.parsley(form_el)
  flash = new App.Flash(element.find('.alert'))

  # handle form submit
  on_submit_lock = App.lock()
  on_submit = ((e) =>
    return if e.isDefaultPrevented()
    return unless parsley.isValid()
    return if on_submit_lock.locked

    flash.hide()

    # force passwords to match
    password = null
    password_inputs = form_el.find('input[type=password]')
    for input in password_inputs
      input = $(input)
      password = if password then password else input.val()
      if password != input.val()
        password_inputs.val('')
        flash.show('Your passwords didn\'t match. Try again.')
        return

    path_pieces = window.location.pathname.split('/')
    App.ajax.headers['X-Smart-Token'] = path_pieces[path_pieces.length - 1]
    App.post("/api/password/change", {
      password: password_inputs.eq(0).val()
    }, on_submit_lock).done((meta, msg)->
      App.redirect("/login?username=#{encodeURIComponent(meta.email)}")
    ).fail((meta, msg)->
      password_inputs.val('')
      flash.show(msg, 'warning')
    )
  )

  form_el.on('submit.PasswordChangePartial', on_submit)
  this
)

# Email validation instructions page
App.EmailValidationInstructions = ((element) ->
  element = $(element)
  element.data('app', @)

  resend_btn = element.find('.resend-btn')

  # handle form submit
  on_resend_click_lock = App.lock()
  on_resend_click = ((e) =>
    App.post("/api/validation/email/send", on_resend_click_lock).done((meta, msg) =>
      resend_btn.off('.EmailValidationInstructions')
      resend_btn.parent().empty().html('Confirmation email has been resent.')
    ).fail((meta, msg) =>
    )
  )

  resend_btn.on('click.EmailValidationInstructions', on_resend_click)
  this
)