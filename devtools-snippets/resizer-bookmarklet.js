;(function (d) {
  // don't open a second one
  if (d.getElementById('bm_resizer')) {
    return
  }
  // load the actual js
  var scriptNode = d.createElement('script')
  scriptNode.src = 'resizer.js'
  d.body.appendChild(scriptNode)
}(document))
