#!/usr/bin/env node

// ./chat-server.js
// nc localhost 6789

var net     = require('net')
  , sockets = [] /* connected persons */
  , port    = process.argv[2] || 6789

var server = net.Server(function(socket){
  sockets.push(socket) // connecting, announcing number of connections
  socket.write('there are ' + sockets.length + ' people chatting\n')
  for(var i = 0; i < sockets.length; i++){ // announcing newbie
    console.log('new user; total of ' + sockets.length)
    if(sockets[i] == socket) continue // except to newbie
    sockets[i].write('one user joined\n')
  }
  socket.on('data', function(d){ // the chat
    for(var i = 0; i < sockets.length; i++){
      if(sockets[i] == socket) continue // don't send message to sender
      sockets[i].write(d) // send message
      console.log('message sent')
    }
  })
  socket.on('end', function(){ // remove disconnected peeps
    var i = sockets.indexOf(socket)
    sockets.splice(i, 1)
    for(var i = 0; i < sockets.length; i++){ // tell people when people leave
      sockets[i].write('one user left\n')
      console.log('lost user; total of ' + sockets.length)
    }
  })
})

server.listen(port)

