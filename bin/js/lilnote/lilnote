#!/usr/bin/env node

// md ~/.lilnote
// touch ~/.lilnote/db.json
// npm i --save lowdb mkdirp tmp-editor user-home
// bugs: can't remove note at [1]

var tmpEditor    = require('tmp-editor')
  , low          = require('lowdb')
  , userHome     = require('user-home')
  , mkdirp       = require('mkdirp')
  , lilDir			 = userHome + '/.lilnotes'

var addNote = function(notes, note){
  notes.push(note)
}

var printNotes = function(notes){
  notes.each(function(note, index){
    console.log('  [' + (index + 1) + '] ' + note + '\n')
  })
}

var removeNote = function(notes, noteIndex){
  if (!noteIndex){
    return console.log('but which one?')
  }
  notes.pullAt(noteIndex)
}

var main = function(){
  var db         = low(lilDir + '/db.json')
    , notes      = db('notes')
    , flagOrNote = process.argv[2]

  if (flagOrNote) {
    switch (flagOrNote) {
      case '-s':
        console.log('your notes:')
        printNotes(notes)
        break
      case '-r':
        var noteIndex = process.argv[3] - 1
        removeNote(notes, noteIndex)
        break
      case '-e':
        tmpEditor().then(function(note){
          addNote(notes, note)
        }).catch(console.error)
        break
      case '-h':
        console.log('take a little note!')
        console.log('lilnote [note]         writes that new [note]')
        console.log('lilnote [stdin]        writes it directly from stdin')
        console.log('lilnote -s             show all your lil notes')
        console.log('lilnote -e             add and edit a new note with your editor')
        console.log('lilnote -r [note]      bye bye, lilnote number [note]')
        console.log('lilnote -h             i think you just did this one!')
        break
      default:
        addNote(notes, flagOrNote)
    }
  } else {
    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    process.stdin.on('data', function(note){
      addNote(notes, note.trim())
    })
  }
}

mkdirp(lilDir, function(error){
  if (error) {
    console.error('lilnote is having trouble! error: ', error)
  }
  main()
})

