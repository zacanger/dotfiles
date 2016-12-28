document.onkeydown = function (evt) {
  if (evt.key !== 'Backspace') return
  if (evt.target.nodeName === 'INPUT') return
  if (evt.target.nodeName === 'TEXTAREA') return
  if (evt.target.nodeName === 'EMBED') return
  if (evt.target.nodeName === 'OBJECT') return
  if (evt.target.isContentEditable) return
  evt.preventDefault()
  if (evt.shiftKey) window.history.forward()
  else window.history.back()
}
