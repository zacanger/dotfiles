#!/usr/bin/env node

// ./chat-server.js
// nc localhost 6789

const
  net     = require('net')
, sockets = []
, port    = process.argv[2] || 6789

net.Server(socket => {
  sockets.push(socket)                       // connecting, announcing number of connections
  socket.write(`there are ${sockets.length} people chatting\n`)
  for (let i = 0; i < sockets.length; i++) { // announcing newbie
    console.log(`new user; total of ${sockets.length}`)
    if (sockets[i] == socket) {
      continue                               // don't announce to newbie
    }
    sockets[i].write('one user joined\n')
  }
  socket.on('data', d => {                   // the chat
    for (let i = 0; i < sockets.length; i++) {
      if (sockets[i] == socket) {
        continue                             // don't send message to sender
      }
      sockets[i].write(d)                    // send message
      console.log('message sent')
    }
  })
  socket.on('end', () => {                   // remove disconnected peeps
    let i = sockets.indexOf(socket)
    sockets.splice(i, 1)
    for (let i = 0; i < sockets.length; i++) {
      sockets[i].write('one user left\n')    // tell people when people leave
      console.log(`lost user; total of ${sockets.length}`)
    }
  })
}).listen(port)
