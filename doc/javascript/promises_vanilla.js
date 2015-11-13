var promise = new Promise(function(resolve, reject){
  setTimeout(function(){
    resolve('hi');
  },5000);
});

return promise;

function whatUp(){
  say("BLAHR");
}
