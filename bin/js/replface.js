#!/usr/bin/env node

var net  = require('net')
  , repl = require('repl')
  , port = 5100

var face = function(){
  var m = [
    '^__^'
  , '-__-'
  , '>.<'
  , '^.^'
  , '@_@'
  , '8_8'
  , '%.%'
  , '^_-'
  , '^.-'
  , ';)'
  , 'xD'
  ]
  return m[Math.floor(Math.random()*m.length)]
}

net.createServer(function(socket){
  var remote = repl.start(face()+' |> ', socket)
  remote.context.face  = face
  remote.context.bonus = 'UNLOCKED'
}).listen(port)

console.log('remote repl available on ' + port)

var local = repl.start(face()+' |> ')
local.context.face = face

