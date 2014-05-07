App.mixins = {
  # This method will focus on the last input element
  focus: (element) ->
    element = $(element)
    inputs = element.find('input')
    last_input = null
    for input in inputs
      last_input = $(input)
      break unless $(input).val()
    last_input.focus() if last_input

  # call when page is loading, automatically focuses after a delay
  autofocus: (element) ->
    $(->
      window.setTimeout(->
        App.mixins.focus(element)
      , 200)
    )
}

App.parsley = ((element) ->
  $(element).parsley({
    successClass: 'has-success'
    errorClass: 'has-error'
    classHandler: (el) ->
      return el.$element.closest('.form-group')
    errorsWrapper: "<span class='help-block'></span>"
    errorTemplate: "<span></span>"
  })
)