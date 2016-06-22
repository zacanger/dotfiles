;(function(){
  var fp = chrome.loadTimes().firstPaintTime - chrome.loadTimes().startLoadTime
  console.log('first paint: ' + fp)
}())
