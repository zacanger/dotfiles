#!/usr/bin/env node

const generateHangul = () => {
  let string = ''
  for (let s = '가'.charCodeAt(0); s <= '힣'.charCodeAt(0); s++) {
    string += (String.fromCharCode(s) + '\n')
  }
  return string
}

process.stdout.write(generateHangul())
