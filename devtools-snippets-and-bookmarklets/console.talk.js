if (console.log.name !== 'talkLog') {
  console.l = console.log
  console.log = function talkLog () {
    Array.prototype.forEach.call(arguments, function (a) {
      if (typeof a !== 'string') {
        try {
          a = 'Object: ' + JSON.stringify(a)
        } catch (e) {}
      }
      window.speechSynthesis.speak(new SpeechSynthesisUtterance(a))
    })
    console.l.apply(this, arguments)
  }
}
