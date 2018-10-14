#!/usr/bin/env node

const { createServer } = require('http')
const port = process.argv[2] || process.env.PORT || 9999

createServer((req, res) => {
  let body = []
  req.on('data', (a) => {
    body.push(a)
  })
  req.on('end', () => {
    console.log(Buffer.concat(body).toString())
  })
  res.end('', 200)
}).listen(port)
