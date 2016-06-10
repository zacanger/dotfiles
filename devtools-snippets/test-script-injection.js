;(function testInlineScriptInjection () {
  var el = document.createElement('script')
  el.innerText = 'alert("hi there")'
  document.body.appendChild(el) // runs the code by default
}())

;(function testExternalScriptInjection () {
  var el = document.createElement('script')
  el.src = 'https://rawgit.com/hakimel/reveal.js/tree/master/js'
  document.body.appendChild(el)
}())
