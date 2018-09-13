#!/usr/bin/env node

/* eslint-disable no-useless-escape */

const normal = `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,';0123456789?!"&()[]/\_‾=-<>`

const flipped = `∀qƆpƎℲ⅁HIſʞ⅂WNOԀΌᴚS⊥∩ɅMX⅄Zɐqɔpǝɟ6ɥıſʞlɯuodbɹsʇnʌʍxʎz˙',؛0Ɩ2Ɛᔭ59Ɫ86¿¡„⅋)(][/\‾_=-><`

const flip = (s) =>
  s.split('').map((c) =>
    normal.includes(c) ? flipped[normal.indexOf(c)] : c
  ).reverse().join('')

let text = ''
process.stdin.resume()
process.stdin.setEncoding('utf8')
process.stdin.on('data', (chunk) => {
  text += chunk
})
process.stdin.on('end', () => {
  console.log(flip(text))
})
