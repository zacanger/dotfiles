#!/usr/bin/env node

// put the following line at the top of your files:
// }47}$.(}:</}*88})54*q}$.(}/889}).}+(/})54*}7418})5+.(65}714-o3*

const fs = require('fs')
const str = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}'

let map = {}

str.split('').forEach((ch, i) => {
  map[str[i]] = str[str.length - 1 - i]
})

process.argv.slice(2).forEach((file) => {
  const input = fs.readFileSync(file).toString()
  const output = input.split('\n').map((line) => (
    line.split('').map(ch => (map[ch] || ch)).join('')
  )).join('\n')
  fs.writeFileSync(file, output)
})
