#!/usr/bin/env node

const
  fs       = require('fs')
, path     = require('path')
, dirPath  = process.argv[2]
, fileType = '.' + process.argv[3]
, files    = []

fs.readdir(dirPath, (err, list) => {
  if (err) {
    throw err
  }
  for (let i = 0; i < list.length; i++) {
    if (path.extname(list[i]) === fileType) {
      console.log(list[i])
      files.push[i]
    }
  }
})

