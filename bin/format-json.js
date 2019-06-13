#!/usr/bin/env node

const port = process.argv[2] || process.env.PORT || 9999

require('http').
  createServer((req, res) => {
    let body = []
    req.on('data', (a) => {
      body.push(a)
    })
    req.on('end', () => {
      res.setHeader('content-type', 'application/json')
      try {
        const send = JSON.stringify(
          JSON.parse(Buffer.concat(body).toString()),
          null,
          2
        ) + '\n'
        res.end(send)
      } catch (_) {
        const send = JSON.stringify({ error: 'Invalid JSON' }) + '\n'
        res.statusCode = 400
        res.end(send)
      }
    })
  }).listen(port, () => {
    console.log(`listening on ${port}`)
  })
