XMLHttpRequest.prototype.send = (function (orig) {
  return function () {
    this.addEventListener('loadend', function () {
      console.timeEnd()
    }, false)
    return orig.apply(this, arguments)
  }
})(XMLHttpRequest.prototype.send)

;(function (history) {
  var pushState = history.pushState
  history.pushState = function (state) {
    console.time()
    if (typeof history.onpushstate == 'function') {
      history.onpushstate({ state: state })
    }
    // when requests created are complete:
    return pushState.apply(history, arguments)
  }
})(window.history)
