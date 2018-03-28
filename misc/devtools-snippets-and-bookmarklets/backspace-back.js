// chrome (intentionally) broke using backspace for history for some reason
document.onkeydown = (evt) => {
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
