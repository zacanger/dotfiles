#!/usr/bin/env node

const type = process.argv[2]
const comp = process.argv[3]
const { writeFile } = require('fs')

const help = () =>
  console.log(`
  please pass component type and component name
  component type can be one of class, function, or test
  example: ./rcg.js function Foo
`)

if (!comp || !type) return help()

const component = comp.charAt(0).toUpperCase() + comp.slice(1)

const pureComponent = `
import React from 'react'

const ${component} = () => <div>${component}</div>

export default ${component}
`.substr(1)

const classComponent = `
import React, { Component } from 'react'

export default class ${component} extends Component {
  render() {
    return (
      <div>${component}</div>
    )
  }
}
`.substr(1)

const test = `
import React from 'react'
import { shallow } from 'enzyme'
import { spy } from 'sinon'
import ${component} from './${component}'

describe('<${component} />', () => {
  const noop = () => {}

  it('looks like a ${component}', () => {
    const ${component.toLowerCase()} = shallow(<${component} />)

    expect(true).toBe(true)
  })
})
`.substr(1)

const doTheThing = kind => {
  let fileName
  if (type === 'test') fileName = `${component}.test.js`
  else fileName = `${component}.js`
  writeFile(fileName, kind, 'utf8', err => {
    if (err) console.log(err)
  })
}

switch (type) {
  case 'function':
    doTheThing(pureComponent)
    break
  case 'class':
    doTheThing(classComponent)
    break
  case 'test':
    doTheThing(test)
    break
  default:
    return help()
}
