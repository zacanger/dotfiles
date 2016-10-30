const blacklist = [
  'DATALIST'
, 'INPUT'
, 'KEYGEN'
, 'OPTION'
, 'SELECT'
, 'TEXTAREA'
]

document.addEventListener('keydown', function (event) {
  if (event.key === 'Backspace' || event.keyCode === 8) {
    if (
      blacklist.indexOf(document.activeElement.nodeName.toLowerCase()) === -1 &&
      document.activeElement.contentEditable !== 'true' &&
      document.activeElement.contentEditable !== 'plaintext-only'
    ) {
      event.stopImmediatePropagation()
      history.go(event.shiftKey ? 1 : -1) // eslint-disable-line no-undef
    }
  }
}, true)
