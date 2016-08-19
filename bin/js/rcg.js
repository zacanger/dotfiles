#!/usr/bin/env node

const type = process.argv[2]
const component = process.argv[3]
const { writeFile } = require('fs')

const help = () =>
  console.log(`
  please pass component type and component name
  example: ./rcg.js function Foo
`)

if (!component || !type) {
  return help()
}

const pureComponent = `
import React from 'react'

const ${component} = () => <div>${component}</div>

export default ${component}
`.trim()

const classComponent = `
import React, { Component } from 'react'

export default class ${component} extends Component {
  render() {
    return (
      <div>${component}</div>
    )
  }
}
`.trim()

const doTheThing = kind => (
  writeFile(`${component}.js`, kind, 'utf8', err => {
    if (err) console.log(err)
  })
)

switch (type) {
  case 'function':
    doTheThing(pureComponent)
    break
  case 'class':
    doTheThing(classComponent)
    break
  default:
    return help()
}
