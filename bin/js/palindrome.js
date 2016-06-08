#!/usr/bin/env node

const str = process.argv[2]

const pal = str => str == str.split('').reverse().join('')

console.log(`is ${str} a palindrome? that's ${pal(str)}`)

