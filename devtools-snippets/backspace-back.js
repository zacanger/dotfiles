document.onkeyup = function (evt) {
  if (evt.keyCode != 8) {
    return
  }
  if (evt.target.nodeName == 'INPUT') {
    return
  }
  if (evt.target.nodeName == 'TEXTAREA') {
    return
  }
  if (evt.target.isContentEditable) {
    return
  }
  evt.preventDefault()
  window.history.back()
}
