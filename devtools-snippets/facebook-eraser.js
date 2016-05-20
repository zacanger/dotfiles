!this.FBEraser && (function(window) {
  var _keyword = []
    , _height = 0
    , _interval

  function hasKeyword(html) {
    for (var i = 0; _keyword[i] != null; ++i) {
      if (html.indexOf(_keyword[i]) > -1) {
        return true
      }
    }
    return false
  }

  window.FBEraser = function() {
    if (_height == (_height = document.documentElement.scrollHeight)) {
      return
    }

    var html, i, ii
    , items = document.querySelectorAll('.uiUnifiedStory,.uiStreamStory,.genericStreamStory')

    for (i = 0; (item = items[i]); ++i) {
      item.style.display = hasKeyword(item.innerText.toLowerCase()) ? 'none' : 'block'
    }
    return true
  }

  window.FBEraser.updateKeywords = function() {
    for (var a = localStorage.facebookEraserKeyword = prompt('what to hide on fb?', localStorage.facebookEraserKeyword || 'Trump, GOP').split(','), l = a.length, i = 0; i < l; ++i) {
      a[i] = a[i].toLowerCase().replace(/^\s+|\s+$/g, '') || 'Trump'
    }

    _keyword = a
    _height = 0
    !_interval && setInterval(window.FBEraser, 1000)
    window.FBEraser()
  }
})(this) || window.FBEraser.updateKeywords()

