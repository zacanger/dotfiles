// adds 'log' fn to window obj
;(function(){
  window.log = Function.prototype.bind.call(console.log, console)
})()
