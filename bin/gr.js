#!/usr/bin/env node

// cat package.json | gr.js
// cat package.json | gr.js | grep repository | gr.js -u

const isObject = val => val && typeof val === 'object' && !Array.isArray(val)
const addDelimiter = (a, b) => a ? `${a}.${b}` : b
const addKv = (k, v) => `${k} = ${JSON.stringify(v)}`

const toGreppable = (obj) => {
  const paths = (obj = {}, head = '') =>
    Object.entries(obj)
      .reduce((product, [key, value]) => {
        const fullPath = addDelimiter(head, key)
        return isObject(value)
          ? product.concat(paths(value, fullPath))
          // TODO: little bug here, should be key.index = value
          : Array.isArray(value)
            ? product.concat(addDelimiter(key, toGreppable(value)))
            : product.concat(addKv(fullPath, value))
      }, [])

  return paths(obj).join('\n')
}

const set = (obj, rawPath, value) => {
  if (Object(obj) !== obj) { return obj }

  const path = rawPath.toString().match(/[^.[\]]+/g) || []

  // eslint-disable-next-line no-return-assign
  path.slice(0, -1).reduce((a, c, i) =>
    Object(a[c]) === a[c]
    // if exists and obj, follow
      ? a[c]
    // else, create key. is the next key a potential array-index?
      : a[c] = Math.abs(path[i + 1]) >> 0 === +path[i + 1]
        ? [] // yes: assign a new array object
        : {} // no: assign a new plain object
  , obj)[path[path.length - 1]] = value // assign the value to the last key

  return obj
}

const toJson = (str) =>
  str.trim().split('\n').filter(Boolean).reduce((obj, line) => {
    const splitLine = line.split('=')
    const rawKey = splitLine[0]
    const rawValue = splitLine[1]
    return set(obj, rawKey.trim(), JSON.parse(rawValue))
  }, {})

const s = process.openStdin()
let d = ''

const main = () => {
  const fn = (x) => process.argv[2] === '-u'
    ? JSON.stringify(toJson(x), null, 2)
    : toGreppable(JSON.parse(x))

  s.on('data', c => { d += c })
    .on('end', () => {
      console.log(fn(d))
    })
}

main()
