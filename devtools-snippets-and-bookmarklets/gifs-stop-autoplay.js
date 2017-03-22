const isGif = (i) => /^(?!data:).*\.gif/i.test(i.src)

const freezeGif = (i) => {
  const c = document.createElement('canvas')
  const w = c.width = i.width
  const h = c.height = i.height
  c.getContext('2d').drawImage(i, 0, 0, w, h)
  try {
    i.src = c.toDataURL('image/gif') // if possible, retain all css aspects
  } catch (e) { // cross-domain -- mimic original with all its tag attributes
    for (let j = 0, a; a = i.attributes[j]; j++) {
      c.setAttribute(a.name, a.value)
    }
    i.parentNode.replaceChild(c, i)
  }
}

[].slice.apply(document.images).filter(isGif).map(freezeGif)
