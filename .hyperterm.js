module.exports = {
  config : {
    // default font size in pixels for all tabs
    fontSize: 12

    // font family with optional fallbacks
// , fontFamily : '"Fira Code", monospace'

    // terminal cursor background color (hex)
// , cursorColor : '#d2d8cf'

    // color of the text
// , foregroundColor : '#fff'

    // terminal background color
// , backgroundColor : '#000'

    // border color (window, tabs)
// , borderColor : '#050505'

    // custom css to embed in the main window
// , css :

    // custom padding (css format, i.e.: `top right bottom left`)
// , termCss: ''

    // custom padding
// , padding : ''

    // some color overrides. see http://bit.ly/29k1iU2
  /* , colors : [
      '#0c0d0d'
    , '#6f6565'
    , '#f68080'
    , '#ffff00'
    , '#0066ff'
    , '#cc00ff'
    , '#00ffff'
    , '#d0d0d0'
    , '#808080'
    , '#ff0000'
    , '#33ff00'
    , '#ffff00'
    , '#0066ff'
    , '#cc00ff'
    , '#00ffff'
    , '#ffffff'
    ] */
  }

, plugins : [
  'hypercwd'
  // , 'hyperline'
, 'hyperterm-mild-dark'
]
, localPlugins : []

  // in development, you can create a directory under
  // `~/.hyperterm_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
}
