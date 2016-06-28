// everyone hates this crap

setInterval(function () {
  var list = document.getElementsByTagName('a')
  for (var i = 0; i < list.length; i++) {
    if (list[i].innerHTML.indexOf('Poke Back') > -1) {
      list[i].click()
      console.log('Poked someone')
    }
  }
}, 3000)

