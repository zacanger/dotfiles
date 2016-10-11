;(function () {
  const cssee = `\
    * { outline: 2px dotted red !important }
    * * { outline: 2px dotted green !important }
    * * * { outline: 2px dotted orange !important }
    * * * * { outline: 2px dotted blue !important }
    * * * * * { outline: 1px solid red !important }
    * * * * * * { outline: 1px solid green !important }
    * * * * * * * { outline: 1px solid orange !important }
    * * * * * * * * { outline: 1px solid blue !important }
  `

  const style = document.createElement('style')
  style.id = 'cssee'
  style.innerHTML = cssee
  document.body.appendChild(style)
})()
