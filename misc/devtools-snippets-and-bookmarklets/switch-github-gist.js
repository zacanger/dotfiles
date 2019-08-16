;(function () {
  let u
  let loc = document.location
  let p = loc.pathname
  let l = 'gist.github.com'
  let r = 'github.com'

  function l2r (p) {
    return p
  }

  function r2l (p) {
    return p
  }

  if (loc.host === l) {
    u = r + l2r(p)
  } else if (loc.host === r) {
    u = l + r2l(p)
  }
  loc.href = 'http://' + u + loc.hash + loc.search
})()
