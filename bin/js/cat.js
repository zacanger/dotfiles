#!/usr/bin/env node

const
  fs   = require('fs')
, args = process.argv.slice(2)

if (!args[0]) {
  console.error('please specify file(s) to catenate')
}

else {
  for (let i = 0; i < args.length; i++) {
    fs.createReadStream(args[i]).pipe(process.stdout)
  }
}

