#!/usr/bin/env node

const http = require('http')
const https = require('https')
const arg = process.argv[2]

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

const opts = {
  host,
  port,
  path : '/'
}

protocol.get(opts, (res) => {
  if (res.statusCode.toString().charAt(0) !== '5') {
    console.log(`${host} is up, status code ${res.statusCode}`)
  } else {
    console.log(`${host} is down, status code ${res.statusCode}`)
  }
}).on('error', (err) => {
  console.log(`Error: ${err.message}`)
})
