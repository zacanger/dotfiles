#!/usr/bin/env node

'use strict'

const
  net   = require('net')
, host  = process.argv[2] || 'localhost'
, end   = 50000
, timeout = 2000
// we want the sockets to time out quickly so as not to waste
// resources, but not _too_ quickly, so we don't miss open sockets.
let start = 1


while (start <= end) {
  let port = start
  ;(port => {
    console.log('now on ' + port)
    let s = new net.Socket()

    s.setTimeout(timeout, () => {s.destroy()})
    s.connect(port, host, () => {
      console.log('open! ' + port)
    })
    s.on('data', (data) => {
      console.log(port, data)
      s.destroy()
    })
    s.on('error', (e) => {
      s.destroy()
    })
  })(port)
  start++
}
