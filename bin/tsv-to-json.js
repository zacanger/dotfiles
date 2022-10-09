#!/usr/bin/env node

const fs = require('fs')
const inputFile = process.argv[2]
const inputData = fs.readFileSync(inputFile, { encoding: 'utf8' })

const tsv2arr = (tsv) => {
  const [headers, ...rows] = tsv.trim().split('\n').map((r) => r.split('\t'))
  return rows.reduce((a, r) => [
    ...a,
    Object.assign(...(r.map(
      (x, i, _, c = x.trim()) => ({ [headers[i].trim()]: isNaN(c) ? c : Number(c) })
    )))
  ], [])
}

const res = JSON.stringify(tsv2arr(inputData), null, 2)
console.log(res)
