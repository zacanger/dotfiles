;(function(){
  var path = window.location.pathname
  var ps = path.split('/')
  var f = ps[ps.length - 1]
  var host = window.location.host
  if (host === 'github.com') {
    var repo = path.split('/')[1]
    if ((ps.length === 4 && f === '') || (ps.length ===3)) {
      window.location.href = 'http://' + repo + '.github.io/' + path.replace('/' + repo + '/', '')
    } else if (ps.length === 5 || (ps.length === 6 && ps[5] === '')) {
      window.location.href = 'http://' + repo + '.github.io/' + ps[2]
    } else if (ps.length > 3 && f.split('.').length === 2) {
      var newpath = path.replace('/' + repo + '/', '').replace('blob/gh-pages/', '')
      window.location.href = 'http://' + repo + '.github.io/' + newpath.replace('.md', '.html').replace('.Rmd', '.html')
    }
  } else if (host.split('.')[1] === 'github' && host.split('.')[2] === 'io') {
    var repo = host.split('.')[0]
    if ((ps.length === 3 && f === '') || (ps.length === 2)) {
      window.location.href = 'http://github.com' + '/' + repo + path + 'tree/gh-pages'
    } else if (ps.length > 2) {
      var newpath = path.replace(f, '') + 'blob/gh-pages/' + f
      window.location.href = 'http://github.com' + '/' + repo + newpath
    }
  }
})()
