"use strict"

var fs = require('fs')
var path = require('path')
var spawn = require('child_process').spawn
var licenses = require('osi-licenses')
var request = require('request')

try { fs.mkdirSync(__dirname + '/licenses/')} catch(e) {}

var pending = Object.keys(licenses).length
for (var license in licenses) {
  get(license)
}

function get(license) {
  var scrape = path.resolve(path.dirname(require.resolve('scrape-markdown')), 'bin', 'cli.js')
  spawn(scrape, [
    '--selector',
    '#block-system-main .field-items',
    'http://opensource.org/licenses/' + license
  ], {stdio: 'pipe'})
  .stdout
  .on('error', function(err) {
    console.log('Errored %s', license)
    console.log(err)
    if (!--pending) done()
  })
  .on('finish', function() {
    console.log('Finished %s', license)
    if (!--pending) done()
  })
  .pipe(fs.createWriteStream(__dirname + '/licenses/' + license + '.md'))
}


function done() {
  console.log('Done!')
  process.exit(0)
}
