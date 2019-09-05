;[].forEach.call(document.getElementsByTagName('input'), (input) => {
  input.onpaste = () => true
  input.autocomplete = 'on'
})
