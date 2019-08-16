;(function () {
  let path = window.location.pathname
  let ps = path.split('/')
  let f = ps[ps.length - 1]
  let host = window.location.host
  if (host === 'github.com') {
    let repo = path.split('/')[1]
    if ((ps.length === 4 && f === '') || (ps.length === 3)) {
      window.location.href = 'http://' + repo + '.github.io/' + path.replace('/' + repo + '/', '')
    } else if (ps.length === 5 || (ps.length === 6 && ps[5] === '')) {
      window.location.href = 'http://' + repo + '.github.io/' + ps[2]
    } else if (ps.length > 3 && f.split('.').length === 2) {
      let newpath = path.replace('/' + repo + '/', '').replace('blob/gh-pages/', '')
      window.location.href = 'http://' + repo + '.github.io/' + newpath.replace('.md', '.html').replace('.Rmd', '.html')
    }
  } else if (host.split('.')[1] === 'github' && host.split('.')[2] === 'io') {
    let repo = host.split('.')[0]
    if ((ps.length === 3 && f === '') || (ps.length === 2)) {
      window.location.href = 'http://github.com' + '/' + repo + path + 'tree/gh-pages'
    } else if (ps.length > 2) {
      let newpath = path.replace(f, '') + 'blob/gh-pages/' + f
      window.location.href = 'http://github.com' + '/' + repo + newpath
    }
  }
})()
