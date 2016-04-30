#! /usr/bin/env node

// all this does is serve up an index.html file in cwd

const
  http  = require('http')
, fs    = require('fs')
, path  = require('path')
, index = path.resolve(__dirname, './index.html')
, port  = process.argv[2] || 4444

http.createServer((req, res) => {
  const stream = fs.createReadStream(index)
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

