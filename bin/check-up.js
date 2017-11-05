#!/usr/bin/env node

const http = require('http')
const https = require('https')
const arg = process.argv[2]
const path = '/'

if (!arg) {
  console.log('Usage: check-up.js example.com')
  process.exit(0)
}

let port = 80
let protocol = http
let host

if (arg.includes('https://')) {
  host = arg.replace('https://', '')
  port = 443
  protocol = https
}

if (arg.includes('http://')) {
  host = arg.replace('http://', '')
} else {
  host = arg
}

const opts = { host, port, path }

protocol.get(opts, (res) => {
  const s = res.statusCode.toString().charAt(0) !== '5' ? 'up' : 'down'
  console.log(`${host} is ${s}, status code ${res.statusCode}`)
}).on('error', (err) => {
  console.warn(`Error: ${err.message}`)
})
