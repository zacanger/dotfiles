function JSONstringify(json) {
  if (typeof json != 'string') {
    json = JSON.stringify(json, undefined, '\t')
  }

  var
    arr      = []
  , _string  = 'color:green'
  , _number  = 'color:darkorange'
  , _boolean = 'color:blue'
  , _null    = 'color:magenta'
  , _key     = 'color:red'

  json = json.replace(
    /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g,
    function(match) {
      var style = _number
      if (/^"/.test(match)) {
        if (/:$/.test(match)) {
          style = _key
        } else {
          style = _string
        }
      } else if (/true|false/.test(match)) {
        style = _boolean
      } else if (/null/.test(match)) {
        style = _null
      }
      arr.push(style)
      arr.push('')
      return '%c' + match + '%c'
    })

  arr.unshift(json)
  console.log.apply(console, arr)
}
void(0)

