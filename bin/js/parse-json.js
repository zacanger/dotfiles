#!/usr/bin/env node

const arg = process.argv.slice(2)

process.stdin.resume()
process.stdin.setEncoding('utf8')

process.stdin.on('data', (ch) => {
  let json = {}

  try {
    json = JSON.parse(ch)

    if (arg.length) {
      for (let i = 0; i < arg.length; i++) {
        json = json[arg[i]]
      }
    }

    console.dir(json, { depth: null, colors: true })
  } catch (e) {
    console.log(e)
  }
})
