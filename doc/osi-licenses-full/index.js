var fs = require('fs')
var path = require('path')

var LICENSE_DIR = path.resolve(__dirname, 'licenses')

var licenses = fs.readdirSync(LICENSE_DIR)

licenses.forEach(function(license) {
  var value = undefined
  var name = path.basename(license, path.extname(license))
  Object.defineProperty(module.exports, name, {
    get: function() {
      value = value || fs.readFileSync(path.resolve(LICENSE_DIR, license), 'utf8')
      return value
    },
    enumerable: true
  })
})
