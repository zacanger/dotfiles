#!/usr/bin/env node

const
  net  = require('net')
, repl = require('repl')
, port = process.argv[2] || 5100
, face = () => {
  const m = [
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
  return m[~~(Math.random() * m.length)]
}

net.createServer(socket => {
  let remote = repl.start(face()+' |> ', socket)
  remote.context.face  = face
  remote.context.bonus = 'UNLOCKED'
}).listen(port)

console.log(`remote repl available on ${port}`)

let local = repl.start(face()+' |> ')
local.context.face = face
