#!/usr/bin/env node

'use strict'

const
  fs       = require('fs')
, path     = require('path')
, dirPath  = process.argv[2]
, files    = []

fs.readdir(dirPath, (err, list) => {
  if(err){
    throw err
  }
  for(let i = 0; i < list.length; i++){
    console.log(list[i])
    files.push[i]
  }
})

