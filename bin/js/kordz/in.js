var kordz = kordz || {}

if (typeof require === 'function' && typeof exports === 'object') {
  kordz = require('./m.js').kordz;
}

kordz.input = {
  getChord: function (chord) {
    var a, o;
    if (chord.indexOf(',') > 0) {
      if (chord.indexOf(':') > 0) {
        chord = chord.replace(/:/g, '":"').replace(/,/g, '","')
        chord = '{"' + chord + '"}'
        o = JSON.parse(chord);
        chord = kordz.guitar.chordByFrets(o)
      } else {
        chord = '["' + chord.split(',').join('","') + '"]'
        a = JSON.parse(chord)
        if (typeof a === 'object') {
          chord = kordz.reverseChord(a)
        }
      }
      if (chord) {
        chord = chord.short
      }
    }
    return chord
  }
}

if (typeof exports === 'object') {
  exports.input = kordz.input
}
