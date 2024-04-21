#!/usr/bin/env node

const fs = require('fs')

// Originally copied from https://github.com/donatj/CsvToMarkdownTable, MIT,
// though I'll be simplifying. Why copy it? So I can just throw it in my ~/bin/

const csvToMarkdown = (csvContent, delimiter = ',', hasHeader = true) => {
  if (delimiter !== '\t') {
    csvContent = csvContent.replace(/\t/g, '    ')
  }

  const columns = csvContent.split(/\r?\n/)

  const tabularData = []
  const maxRowLen = []

  columns.forEach((e, i) => {
    if (typeof tabularData[i] === 'undefined') {
      tabularData[i] = []
    }
    const regex = new RegExp(`${delimiter}(?![^"]*"(?:$|${delimiter}))`)
    const row = e.split(regex)
    row.forEach((ee, ii) => {
      if (typeof maxRowLen[ii] === 'undefined') {
        maxRowLen[ii] = 0
      }

      // escape pipes and backslashes
      ee = ee.replace(/(\||\\)/g, '\\$1')

      maxRowLen[ii] = Math.max(maxRowLen[ii], ee.length)
      tabularData[i][ii] = ee
    })
  })

  let headerOutput = ''
  let seperatorOutput = ''

  maxRowLen.forEach((len) => {
    const sizer = Array(len + 1 + 2)

    seperatorOutput += '|' + sizer.join('-')
    headerOutput += '|' + sizer.join(' ')
  })

  headerOutput += '| \n'
  seperatorOutput += '| \n'

  if (hasHeader) {
    headerOutput = ''
  }

  let rowOutput = ''
  tabularData.forEach((col, i) => {
    maxRowLen.forEach((len, y) => {
      const row = typeof col[y] === 'undefined' ? '' : col[y]
      const spacing = Array((len - row.length) + 1).join(' ')
      const out = `| ${row}${spacing} `
      if (hasHeader && i === 0) {
        headerOutput += out
      } else {
        rowOutput += out
      }
    })

    if (hasHeader && i === 0) {
      headerOutput += '| \n'
    } else {
      rowOutput += '| \n'
    }
  })

  return `${headerOutput}${seperatorOutput}${rowOutput}`
}

const main = () => {
  const fileToProcess = process.argv[2]
  if (!fileToProcess) {
    console.error('Pass an input file.')
    process.exit(1)
  }

  console.log(csvToMarkdown(fs.readFileSync(fileToProcess, 'utf-8').trim()))
}

if (require.main === module) {
  main()
}
