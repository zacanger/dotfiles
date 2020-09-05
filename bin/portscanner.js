#!/usr/bin/env node

const net = require('net')
const host = process.argv[2] || 'localhost'
const end = 50000
// we want the sockets to time out quickly so as not to waste
// resources, but not _too_ quickly, so we don't miss open sockets.
const timeout = 2000

let start = 1

while (start <= end) {
  let port = start
  ;((port) => {
    let s = new net.Socket()

    s.setTimeout(timeout, () => s.destroy())
    s.connect(port, host, () => console.log(`${port} is open!`))
    s.on('data', (data) => {
      console.log(port, data.toString())
      s.destroy()
    })
    s.on('error', () => s.destroy())
  })(port)
  start++
}
