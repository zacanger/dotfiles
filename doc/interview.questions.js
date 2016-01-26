// 1. write an `add` function that can be used with two arguments
// ex: add(1, 2) // => 3

// 2. extend the `add` function so that it can be called with 1 argument as well
// -- calling `add` with 1 argument should return a new function bound to that number
// ex: var add1 = add(1)
//     add1(2)   // => 3
//     add(2, 3) // => 5 <-- this should still work

// 3. extend the `add` function to take any number of arguments (see example)
// -- be sure to retain the functionality from problems 1 and 2
// ex: add(1, 2, 3, 4) // => 10
//     add(2, 3)       // => 5  <-- this should still work
//     add(2)(3)       // => 5  <-- this should still work
//     add(2)(3, 4, 5) // => 14 <-- this is how using features 2 and 3 together will work

// bonus points: write an `add` function with es2015 (es6) syntax
// -- should meet all requirements from 1, 2, and 3
// -- only if it enhances readability

// you are given two methods: getClasses, which gets all of the class names of an element,  and getChildren, which get all of the children of an element.
// Create a function that takes in a class name and an element (starting with “document”) as it’s arguments, and returns all of the elements in the document that have that class.

// You just got a job for a business owner who wants to redo his website.  He owns 20,000 stores in the US and has 3 different types of stores:
// retail, grocery, & restaurants.  He wants a map of the US on his landing page that shows all of his stores as pins (think google) so that
// people are wow’d with how many stores there are.  He asks you if you can see any problems with this (user interaction or functionality).

// Once you give your answer to the first part, he agrees to only have 300 stores on the map.  He wants them evenly distributed on the map,
// and he wants 100 of each store type. How would you code that?

// WHAT ARE CLOSURES AND SCOPE?

// WHAT IS HOISTING?

// HOW WOULD YOU DESIGN YOUR CODE IF YOU ARE BUILDING A CHECKERS GAME?
// Go draw your file and code design on the whiteboard

// A SINGLE DATA POINT FROM OUR SERVER IS NOT RELIABLE, WHAT WOULD YOU DO TO MAKE SURE WE ARE GIVING RELIABLE DATA TO THE USER?

// ANGULAR VS REACT (PROS AND CONS)?

// TELL ME ABOUT A TIME WHEN YOU HAD TO DO SOMETHING REALLY HARD ON THE CODE, TELL ME HOW YOU SOLVED IT, AND SHOW ME THE CODE.

// ANY QUESTIONS FOR US?

// WHAT ARE YOU LOOKING FOR IN REGARDS OF COMPENSATION?

// HOW WOULD YOU STRUCTURE YOUR FILES IF YOU ARE BUILDING A NEW APPLICATION?

// TELL ME ABOUT YOUR EXPERIENCE WITH X…

// I CAN HIRE YOU OR HIRE 3 PEOPLE IN MEXICO. ARE YOU REALLY WORTH MORE THAN 3 DEVELOPERS IN MEXICO?

// WHAT QUESTIONS DO YOU HAVE?

// TELL ME SOMETHING UNIQUE ABOUT YOURSELF

// WHY DID YOU DECIDE TO START CODING?

// The “About Us” page problem
// Write JS, HTML and CSS code to allow user to click on one of the blue thumbnails of an employee below and have
// it blow up to the position of “pane1”, while right sliding the existing pane 1 and pane 2 to the position of
// pane 2 and 3. In addition to the Javascript pane sliding functionality, please spend some time to make the
// animation of the sliding action look smooth, and layout beautiful. Must be working code. Please reply and return
// your results via email to me within 24 hours.


// Adding an array
// Write a function that adds all the numbers of an array, regardless of how many levels nested they are. Ex. [[[1,3,4], true, 2], "test", false, 7] would be 17.
// Possible solution:
// function count (arr) {
//  arr = arr.toString().split(",");
//  var count = 0;
//  arr.forEach(function (item) {
//    var num = Number(item);
//    if (num) count = count + num;
//  })
//  return count;
//}
