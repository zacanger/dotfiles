// window-performance.js by Brian Grinstead; gh:bgrins/window-performance
// include as a script, or just paste it in the console
// to test, do something (in your page) like:
// function compute(first, second){return first + second}
// window.onload = function(){var j = 0;for(var i = 0; i < 10000000; i++){var k = i + j;j = i;}}
// setInterval(function(){for(var i = 0; i < 10000; i++){var y = compute(i, i+1)}}, 10000)

;(function () {
  var OPEN_BY_DEFAULT = false
  var PERFORMANCE_STYLES = '\
  #pm-all{z-index:2147483647;position:absolute;top:0;right:0;border:rgba(0,0,0,.4) solid 2px;padding:2px;width:110px;background-color:rgba(220, 220, 220, .3);border-top:none;border-right:none;font-size:12px;font-family:monospace;} \
  #pm-all[open]{background-color:rgb(220, 220, 220);width:600px;} \
  #pm-all > summary  span{color:#6fb6e1;text-decoration:underline;cursor:pointer;position:absolute;top:0;right:2px;} \
  #pm-all details, #pm-all details > div{margin-left:15px;} \
  '
  var CLOSE_CLICK = 'javascript:(function(e){e&&e.parentElement.removeChild(e);})(document.getElementById("pm-all")); return false'
  var PERFORMANCE_HTML = "\
  <summary>Performance \
  <span onclick='" + CLOSE_CLICK + "'>x</span></summary> \
  <details><summary>Timing</summary><div id='pm-timing'></div><details><summary>Raw</summary><div id='pm-timing-raw'></div></details></details> \
  <details><summary>Memory</summary><div id='pm-memory'>--enable-memory-info</div></details> \
  <details><summary>Navigation</summary><div id='pm-navigation'></div></details> \
  "

  if (window.performance && window.performance.timing && window.performanceTrack !== false) {
    var p = window.performance,
      waitForLoadMax = 100,
      waitForLoadInterval = 100
    if (document.readyState === 'complete') {onDOMContentLoaded()} else {document.addEventListener('DOMContentLoaded', onDOMContentLoadedDefer, false)}

    function onDOMContentLoadedDefer () {setTimeout(onDOMContentLoaded, 1)}

    function onDOMContentLoaded () {
      printContainer()
      printStyleSheet()
      printTiming(p.timing)
      var waiting = setInterval(waitForLoad, waitForLoadInterval),
        stopCounter = 0
      function waitForLoad () {
        if (p.timing.loadEventEnd > 0 || (stopCounter++ > waitForLoadMax)) {
          printTiming(p.timing)
          clearInterval(waiting)
        }
      }
    }

    function printStyleSheet () {
      var head = document.getElementsByTagName('head')[0],
        style = document.createElement('style'),
        rules = document.createTextNode(PERFORMANCE_STYLES)
      style.type = 'text/css'
      if (style.styleSheet) {style.styleSheet.cssText = rules.nodeValue} else {style.appendChild(rules)}
      head.appendChild(style)
    }

    function printContainer () {
      var perf = document.createElement('details')
      perf.id = 'pm-all'
      perf.innerHTML = PERFORMANCE_HTML
      if (OPEN_BY_DEFAULT) {perf.open = 'open'}
      document.body.appendChild(perf)
    }

    function printTiming (t) {
      var timingContainer = document.getElementById('pm-timing')
      if (timingContainer) {
        var html = []
        var groups = {
          'Connection': function () {return t.connectEnd - t.connectStart},           'Response': function () {return t.responseEnd - t.responseStart},           'Domain Lookup': function () {return t.domainLookupEnd - t.domainLookupStart},           'Load Event': function () {return t.loadEventEnd - t.loadEventStart},           'Unload Event': function () {return t.unloadEventEnd - t.unloadEventStart},           'DOMContentLoaded Event': function () {return t.domContentLoadedEventEnd - t.domContentLoadedEventStart}
        }
        for (var i in groups) {
          html.push('<span>' + i + '</span>: ' + groups[i]() + 'ms')
        }
        timingContainer.innerHTML = html.join('<br />')
      }
      var timingContainerRaw = document.getElementById('pm-timing-raw')
      if (timingContainerRaw) {
        var html = []
        for (var i in t) {
          html.push('<span>' + i + '</span>: ' + t[i])
        }
        timingContainerRaw.innerHTML = html.join('<br />')
      }
    }
  }
})()
