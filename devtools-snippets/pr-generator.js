;(function() {
  var e = document.getElementById('pull_request_body')
  if (e) {
    e.value += '#### :tophat: What? Why?\n\n\n' +
    '#### :dart: What should QA test?\n\n\n'  +
    '#### :pushpin: Related tasks?\n\n\n'     +
    '#### :family: Dependencies?\n\n\n'       +
    '#### :clipboard: Subtasks\n- [x]\n- '    +
    '[ ]\n\n\n'                               +
    '#### :ghost: GIF\n![]()'
  }
})()

