;(function() {
  var u
  , loc = document.location
  , p   = loc.pathname
  , l   = 'gist.github.com'
  , r   = 'github.com'

  function l2r(p) {
    return p
  }

  function r2l(p) {
    return p
  }

  if (loc.host === l) {
    u = r + l2r(p)
  } else if (loc.host === r) {
    u = l + r2l(p)
  }
  loc.href = 'http://' + u + loc.hash + loc.search
})()
