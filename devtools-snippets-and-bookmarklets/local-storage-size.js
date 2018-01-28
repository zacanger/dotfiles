;(() => {
  const stringSizeBytes = (str) => str.length * 2

  const toMB = (bytes) => bytes / 1024 / 1024

  const toSize = (key) => ({
    name: key,
    size: stringSizeBytes(localStorage[key])
  })

  const toSizeMB = (info) => {
    info.size = toMB(info.size).toFixed(2) + ' MB'
    return info
  }

  const sizes = Object.keys(localStorage).map(toSize).map(toSizeMB)

  console.table(sizes)
})()
