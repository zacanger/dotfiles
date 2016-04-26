#!/usr/bin/env node

const
  http   = require('http')
, path   = require('path')
, fs     = require('fs')
, port   = process.env.PORT || 4444

http.createServer((req, res) => {

  let filePath = '.' + req.url
  if (filePath == './') {
    filePath = './index.html'
  }

  let extname = path.extname(filePath)

  let contentType = 'text/html'
  switch (extname) {
    case '.js':
      contentType = 'text/javascript'
      break
    case '.css':
      contentType = 'text/css'
      break
    case '.json':
      contentType = 'application/json'
      break
    case '.png':
      contentType = 'image/png'
      break
    case '.jpg':
      contentType = 'image/jpg'
      break
    case '.wav':
      contentType = 'audio/wav'
      break
  }

  fs.readFile(filePath, (err, content) => {
    if (err) {
      if (err.code == 'ENOENT') {
        fs.readFile('./404.html', (err, content) => {
          res.writeHead(200, {'Content-Type' : contentType})
          res.end(content, 'utf-8')
        })
      } else {
        res.writeHead(500)
        res.end('Server error ' + err.code + '\n')
        res.end()
      }
    } else {
      res.writeHead(200, {'Content-Type' : contentType})
      res.end(content, 'utf-8')
    }
  })

}).listen(port, () => {
  console.log(`listening on ${port}`)
})

