
$(document).ready ->
  onClick = (_event) -> window.location.href += '/edit'
  button = $('button.btn')  # should only be on the 'show' template
  button.click(onClick) if button.length == 1
