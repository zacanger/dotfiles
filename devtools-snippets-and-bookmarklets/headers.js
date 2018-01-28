// print out response headers for current URL

;(() => {
  const request = new window.XMLHttpRequest()
  request.open('HEAD', window.location, false)
  request.send(null)

  const headers = request.getAllResponseHeaders()
  const tab = headers.split('\n').map((h) => ({
    Key: h.split(': ')[0],
    Value: h.split(': ')[1]
  })).filter((h) => h.Value !== undefined)

  console.group('Request Headers')
  console.log(headers)
  console.table(tab)
  console.groupEnd('Request Headers')
})()
