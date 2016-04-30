#!/usr/bin/env node

const num = process.argv[2] || 8

let str = ''

for (let i = num; i >= 1; i--) {
  str += '#'
  console.log(str)
}

