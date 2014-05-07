# A flash message
App.Flash = (element) ->
  element = $(element)
  element.data('app', @)

  @show = (msg, opt_class) =>
    opt_class = opt_class || 'warning'

    p = $('<p></p>')
    p.text(msg)
    element.empty().append(p)
    element.removeClass('hide alert-success alert-info alert-warning alert-danger')
    element.addClass("alert-#{opt_class}")
    element.show()

  @hide = =>
    element.hide()

  this