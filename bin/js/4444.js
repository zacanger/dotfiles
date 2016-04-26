#! /usr/bin/env node

// this is very sraightforward, but in case it's somehow unclear...
// all this does is serve up an index.html file in cwd
// that's it.
// want options? reloading? anything like that? this is totally not
// the right server for you.

const
  http  = require('http')
, fs    = require('fs')
, path  = require('path')
, index = path.resolve(__dirname, './index.html')
, port  = 4444

http.createServer((req, res) => {
  let stream = fs.createReadStream(index)
  stream.on('open', () => {
    res.writeHead(200, {'Content-Type' : 'text/html'})
  })
  stream.on('error', () => {
    res.writeHead(400)
    res.end()
  })
  stream.pipe(res)
}).listen(port)

console.log(`check over at ${port}`)

