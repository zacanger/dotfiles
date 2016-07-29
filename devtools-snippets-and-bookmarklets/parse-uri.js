const parsedQuery = (function () {
  let query  = window.location.search
  ,   parsed = {}
  query = query.substr(1)
  query = query.split('&')
  for (let i = 0; i < query.length; i++) {
    let field = query[i].split('=')
      , key   = window.decodeURIComponent(field[0])
      , value = window.decodeURIComponent(field[1])
    parsed[key] = value
  }
  return parsed
}())
