#!/usr/bin/env node

'use strict'

// there's another file ('cat-tiny.js') in this repo which just reads the first
// argument and pipes it to stdout. i like that one because it's one line
// (two including the shebang). but here's a better attempt at `cat(1)` in node.
// :)

const
  fs   = require('fs')
, args = process.argv.slice(2)

if(!args[0]){
  console.error('please specify file(s) to catenate')
}

else {
  for(let i = 0; i < args.length; i++){
    fs.createReadStream(args[i]).pipe(process.stdout)
  }
}
