JavaScript for the Lazy
=======================

## Introduction

This tutorial exists to give concise examples of the most common, simple JavaScript usage. 
We will be limiting the scope to the browser for these purposes.

The purpose of this guide is not necessarily to be correct. You are encouraged to research beyond this page, as usual.

Dedicated to Ivey and her chronic stubbornness.

## Resources 

A good resource is the [Mozilla Developer Network](https://developer.mozilla.org/). 

## The freaking basics 

Assuming you have a simple HTML page:
	
	<body>
	Here's some <i>HTML</i> content.
	<script>
		document.write("This is now being parsed by the browser as JavaScript.");

		// This is a one-line JavaScript comment 
		/* We also have 
		   multi-liners in here */
	</script> 
	<b>And now it's HTML again.</b>
	</body>

It is also common to see JavaScript stored in an external file, and referenced like so:

	<html>
		<head>
			<script src='somefile.js'></script>
		</head>
	...

Basic stuff.

## Variables 

	var foo = "bar";
	var number = 5;
	var double = 3.14;
	var boolean = true;

	// JavaScript, like any other language, has restricted keywords
	// But for the most part, you can name variables anything 
	var name = "Jonathan";

	// "var" declares the variable. You can then change it like:
	name = "Ivey";

	// Variables are then used to retrieve the data stored 
	alert("Hello, " + name);

## Strings 
	
	var name = "Jonathan"; // this is a string 
	
	// string is just a fancy name for a string of  
	// characters, or basically any text 

	alert("This is a raw string");

	var str = "This is a string being stored in a variable";
	alert(str); // and then used 

	alert("Hello, " + name); // the + concatenates two strings, or strings them together 

## Operations, aka math 

	var number = 4;
	var number2 = 16;

	var sum = number + number2;
	var difference = number - number2;
	var product = number * number2;
	var quotient = number / number2; 

	// to separate operations, it's just like a calculator:
	var number3 = (number + number2) / sum;

	// And then we can use them
	alert("Sum: " + sum);

## Arrays 

	// An array is basically a list
	var cars = ["95 BMW", "08 Altima", "2013 KIA", "94 Eclipse", "01 Infiniti"];

	// It's indexed, or numbered, from 0 to array.length - 1
	alert(cars[0]); // 95 BMW
	alert(cars[1]); // 94 Eclipse

	alert(cars[cars.length - 1]); // 01 Infiniti 

	// It is also common to see arrays in a sort of key-value pair
	// This is technically an object, but we'll worry about that later.
	var clothes = [];
	clothes["favorite"] = "My Rolling Stones T-Shirt";
	clothes["newest"] = "Red Aero shirt";
	clothes["coolest"] = "Black turtleneck";

	alert(clothes["favorite"]); // My Rolling Stones T-Shirt

## Conditions

	// Now, we'll look at some flow control 
	if (true) {
		// this will always happen
	}

	if (false) {
		// this will never happen
	}

	if (false) {
		// this won't happen
	} else {
		// but this will
	}

	// true and false are booleans 
	var condition = true;
	if (condition) {
		do_something();
	}

	// booleans can be computed from expressions
	condition = (5 > 3); // a true statement 
	if (condition) {
		alert("5 is indeed greater than 3");
	}

	// we can also just put the expression directly in the if: 
	if (5 > 3) {
		alert("Math checks out");
	} else {
		alert("Oops, broke the laws of math."); // this will never happen
	}

	var name = "Jonathan";
	if (name == "Jonathan") { //note the double =
		alert("Hey Jonathan!");
	} else {
		alert("Who are you?");
	}
	
	// you can also combine expressions 
	var classyear = 2013;
	if (name == "Jonathan" && classyear = 2013) {
		alert("Good, you are the same Jonathan.");
	} else {
		alert("Either you are not Jonathan, or your classyear is not 2013, or both");
	}

	if (name == "Jonathan" || classyear == 2013) {
		alert("Either you are Jonathan, or you are in class of 2013, or both");
	} else {
		alert("Your name is not Jonathan, and you are not in class of 2013");
	}

	// these can also be chained together, using parenthesis for order
	if (name == "Jonathan" or (classyear == 2013 && name == "Ivey")) {
		// make sense?
	}

## Loops

	// Loops exist in JavaScript in the form of for and while 
	// There is also a special type of for ... in, but we'll focus
	// On that later 

	for (var i = 0; i < 10; i++) {
		alert(i);
		// This will alert numbers 0 through 9
	}

	// generally, you will see them with arrays 

	var cars = ["95 BMW", "08 Altima", "2013 KIA", "94 Eclipse", "01 Infiniti"];

	alert("My cars are: ");
	for (var i = 0; i < cars.length; i++) { // note the <, which gives a domain
		alert(cars[i]);						// from 0 to array.length - 1
	}										// (this is what we want)

	// while is a very simple loop
	// it repeats while the condition is true
	while (true) {
		// this will never stop. don't try this, it'll freeze your browser 
	}

	// they are not seen or used too frequently, but it's important to know 
	// of their existence 

## Functions 

	// Functions allow us to put common functionality inside something we can call later 
	function sayhi() {
		alert("Hello!");
	}

	sayhi(); // runs the code inside sayhi 

	function getName() {
		return "jonathan"; // return, or give back 
	}

	alert(getName()); // jonathan 

	// functions can also have parameters, or ordered values that are set to variables 
	// within the scope of the function 
	function sum(num1, num2) {
		return num1 + num2;
	}
	
	alert(sum(100, 20)); // 120 

	function makeGreeting(name, prefix) {
		return "Hello, " + prefix + " " + name + "!";
	}

	var greeting = makeGreeting("Jonathan", "Mr.");
	alert(greeting); // Hello, Mr. Jonathan! 

## Built-in Functions 

	// As usual, JavaScript has a lot of built-in functionality, especially in the 
	// context of a browser 

	alert(str); // shows a modal dialog box displaying str 

	// a lot of these functions are needed for DOM stuff:

	</script>
	<div id='message'>Hello, world!</div>
	<script>
	// displays the content of message element
	alert(document.getElementById("message").innerHTML); // Hello, world!

## Todo

	// examples, objects, etc


