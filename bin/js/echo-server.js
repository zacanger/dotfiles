#!/usr/bin/env node

const { createServer } = require('http')
const port = process.argv[2] || process.env.PORT || 9999

createServer((req, res) => {
  console.log(req)
  res.end('k', 200)
}).listen(port)
