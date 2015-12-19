#!/usr/bin/env node

// Reads a list of unique names from stdin then when the stream is closed,
// Prints the assignments to stdout

var es = require('event-stream'),
  random = require('random-item-in-array')

var names = {}

process.stdin
  .pipe(es.split())
  .pipe(es.mapSync(function(name){
    if (name && name.length) return name
  }))
  .on('data', function(name){
    names[name] = name
  })
  .on('end', function(){
    console.log('Names received', Object.keys(names))

    var toAssign = Object.keys(names)

    names = Object.keys(names).reduce(function(prev, curr){
      // Get a name that isn't their own
      var name = random(
        toAssign
          .filter(function(name){
          return name !== curr
      }))

      // Remove it from the list of available names
      toAssign.splice(toAssign.indexOf(name), 1)

      // Make the assignment
      prev[curr] = name
      return prev
    }, {})

    console.log('Assignments:', names)
  })
