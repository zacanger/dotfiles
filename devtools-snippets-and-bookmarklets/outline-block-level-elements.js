function addClientRectsOverlay (elt) {
  var rects = elt.getClientRects()
  for (var i = 0; i != rects.length; i++) {
    var rect = rects[i]
    var tableRectDiv = document.createElement('div')
    var scrollTop = document.documentElement.scrollTop || document.body.scrollTop
    var scrollLeft = document.documentElement.scrollLeft || document.body.scrollLeft
    tableRectDiv.style.position = 'absolute' // so the border is the same as the size of the
    tableRectDiv.style.border = '1px solid red'; // rectangle. will go screwy on zoom or resize.
    tableRectDiv.style.margin = tableRectDiv.style.padding = 0
    tableRectDiv.style.top = (rect.top + scrollTop) + 'px'
    tableRectDiv.style.left = (rect.left + scrollLeft) + 'px'
    tableRectDiv.style.width = (rect.width - 2) + 'px'; // we want this to be the same as border,
    tableRectDiv.style.height = (rect.height - 2) + 'px' // so content must be 2px less
    document.body.appendChild(tableRectDiv)
  }
}
;(function () {
  var elt = document.querySelectorAll(['p', 'div', 'ol', 'table', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6'])
  for (var i = 0; i < elt.length; i++) {
    addClientRectsOverlay(elt[i])
  }
})()
