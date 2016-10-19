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
import React, { PropTypes } from 'react'

const ${component} = () => (
  <div>${component}</div>
)

${component}.propTypes = {

}

export default ${component}
`

const classComponent = `
import React, { Component, PropTypes } from 'react'

export default class ${component} extends Component {
  static propTypes = {

  }

  render() {
    return (
      <div>${component}</div>
    )
  }
}
`

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
`

const doTheThing = kind => {
  const fileName = type === 'test'
    ? `${component}.test.js`
    : `${component}.js`
  writeFile(fileName, kind.substr(1), 'utf8', err => {
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
