#!/usr/bin/env node

var arg, chord, kordz

arg = process.argv[2]

if (!arg) {
  quitme()
}

kordz =       require('./m.js').kordz
kordz.input = require('./in.js').input

chord = kordz.input.getChord(arg)

if (!chord) {
  quitme('sorry, i don\'t know that one')
}
console.log(' ' + chord)
console.log(kordz.guitar.printChord(chord, 'tab'))

function quitme(m){
  var cmd
  if (m) {
    console.log(m)
  }
  console.log('usage:...')
  cmd = '$ node kordz.js '
  console.log(cmd + 'Am7')
  console.log(cmd + 'A,C,E,G')
  console.log(cmd + '1:0,2:1,3:2,4:2,5:0,6:x')
  process.exit(1)
}
