var setTitle = function() {
   if (document.title.indexOf("ಠ_ಠ") != 0) {
      document.title = "ಠ_ಠ " + document.title;
   }
}
window.addEventListener("load", function() {
   titleChange = function() {
      console.log('changed');
      setTimeout(function() {
         setTitle();
      }, 20);
   };

   var target = document.getElementsByTagName('title')[0];
   target.addEventListener('DOMSubtreeModified',titleChange,false);
   setTitle();
}, false);

setTitle();

