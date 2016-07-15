// removes all elements except for given selectors
// example: called with ('.foo', '#bar')
// everything except those will be removed
;(function hideAllBut () {
  const selectors = Array.from(arguments)
  if (!selectors.length) {
    throw new Error('Need at least one selector to leave')
  }
  const keep = selectors.reduce(function (all, selector) {
    return all.concat(Array.from(document.querySelectorAll(selector)))
  }, [])
  function shouldKeep (el) {
    return keep.some(function (keepElement) {
      return keepElement.contains(el) || el.contains(keepElement)
    })
  }
  const all = Array.from(document.body.querySelectorAll('*'))
  let removed = 0
  all.forEach(function (el) {
    if (!shouldKeep(el)) {
      el.parentNode.removeChild(el)
      removed += 1
    }
  })
  console.log('removed %d elements', removed)
}(/* arguments here */))
