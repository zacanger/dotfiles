// detects font
// works well as a bookmarklet:
/*
javascript:var%20d=document,b=d.body,s=d.createElement('style'),m;s.innerHTML='*{cursor:help%20!important;}';b.appendChild(s);b.addEventListener('click',l,0);function%20l(e){m=/"([^"]+)"|'([^']+)'|([^,]+)/.exec(window.getComputedStyle(e.target).fontFamily);alert('That%20font%20is%20'+(m[1]||m[2]||m[3]));b.removeChild(s);b.removeEventListener('click',l);e.preventDefault()}
*/

var stylesheet = document.createElement('style')
stylesheet.innerHTML = '*{cursor:help!important;}'
document.body.appendChild(stylesheet)

document.body.addEventListener('click', handleClick, false)

function handleClick (e) {
  var matches = /"([^"]+)"|'([^']+)'|([^,]+)/.exec(window.getComputedStyle(e.target).fontFamily)

  alert('Font: ' + (matches[1] || matches[2] || matches[3]))

  document.body.removeEventListener('click', handleClick)
  document.body.removeChild(stylesheet)

  e.preventDefault()
}
