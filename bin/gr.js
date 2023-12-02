#!/usr/bin/env node

// like gron, but not abandoned, like 3%
// of gron's sloc, and in node
//
// usage:
// cat package.json | gr.js
// cat package.json | gr.js | grep repository | gr.js -u

const isObject = (val) =>
  val && typeof val === 'object' && !Array.isArray(val) && val != null
const addDelimiter = (a, b) =>
  a ? `${a}.${b}` : b
const addKv = (k, v) =>
  `${k} = ${JSON.stringify(v)}`

const _toGreppable = (obj) => {
  const paths = (obj = {}, head = '') =>
    Object.entries(obj)
      .reduce((product, [key, value]) => {
        const fullPath = addDelimiter(head, key)
        if (isObject(value)) {
          return product.concat(paths(value, fullPath))
        }
        if (Array.isArray(value)) {
          return product.concat(
            value.map((v, i) =>
              addKv(addDelimiter(fullPath, i), v)))
        }

        return product.concat(addKv(fullPath, value))
      }, [])

  return paths(obj)
}

const toGreppable = (obj) =>
  _toGreppable(obj)
    .map((a) =>
      addDelimiter('json', a))
    .join('\n')

const set = (obj, rawPath, value) => {
  if (Object(obj) !== obj) { return obj }

  const path = rawPath.toString().match(/[^.[\]]+/g) || []

  path.slice(0, -1).reduce((a, c, i) => {
    if (Object(a[c]) === a[c]) {
      // if exists and obj
      return a[c]
    }

    // else, create key
    return a[c] = Math.abs(path[i + 1]) >> 0 === +path[i + 1]
      // is the next key a potential array-index?
      // if so, assign to array
      // else, assign to obj
      ? []
      : {}
  }, obj)[
    // assign the value to the last key
    path[path.length - 1]] = value

  return obj
}

const toJson = (str) =>
  str.trim().split('\n').filter(Boolean).reduce((obj, line) => {
    const splitLine = line.split('=')
    const rawKey = splitLine[0]
    const rawValue = splitLine[1]
    return set(obj, rawKey.trim(), JSON.parse(rawValue))
  }, {}).json

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
