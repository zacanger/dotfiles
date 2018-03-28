// print out key/value pairs from querystring

(() => {
  const url = location
  const querystring = location.search.slice(1)
  const tab = querystring.split("&").map((qs) => ({
    key: qs.split("=")[0],
    value: qs.split("=")[1],
    prettyValue: decodeURIComponent(qs.split("=")[1]).replace(//g," ")
  })))

  console.group('Querystring Values')
  console.log('URL:', url, '\nQS:', querystring)
  console.table(tab)
  console.groupEnd('Querystring Values')
})()
