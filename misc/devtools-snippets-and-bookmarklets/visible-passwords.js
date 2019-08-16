Array.prototype.slice
  .call(document.body.getElementsByTagName('input'), 0)
  .filter(
    (n) =>
      n &&
      n.type &&
      (n.type.toLowerCase() === 'password' || n._oldType === 'password')
  )
  .forEach((n) => {
    if (n.type.toLowerCase() === 'password') {
      n.type = 'text'
      n._oldType = 'password'
    } else {
      n.type = n._oldType
    }
  })
