PHP for the Lazy
================

Introduction
------------

The purpose of this tutorial is to give a concise example of simple PHP usage.

The purpose is *not* to be necessarily correct, and I encourage all readers to research beyond this page for information they may require.

Know Your Resources
-------------------

* [The PHP Manual](http://php.net/manual/en/index.php) has all the official docs on every function, variable, etc. in the language, plus helpful comments and examples.

	For example, [here's what file_get\_contents](http://php.net/manual/en/function.file-get-contents.php) looks like. They're boring, but **learn to appreciate them**. You'll need them.

* [Google](http://google.com/). Learn to search for questions and find instant answers.

The freaking basics
-------------------
In a file called example.php

	<?php

		echo "This is a php file.<br>"; 
		echo "Your server (Apache, etc) will pass it to the php parser.";

		// This is one-line PHP comment
		/* This is a
		   multi-line comment */

		// I'll be using these for the reminder of the tutorial.
	?>
	<html>
		<body>
			<p>This content is HTML. 
			It gets output directly to the browser, as if it were in an echo statement.
		   	No special formatting goes on here.</p>
			<?php
				echo "However, opening the <?php tag will start PHP parsing again";
				?>
				And closing it will stop it.
		</body>
	</html>


The most important hint, for the absolute beginner, is this:

* If it's a PHP file, you access it via your local server, e.g. http://localhost/

	You can't just use file:// or double click on it, as it won't be parsed by PHP.
* Find a simple Apache and PHP setup tutorial for details on that.


Variables
---------

	<?php
		// Some examples
		$integer = 5;
		$double = 3.14;
		$boolean = true;
		$string = "Hello, world!";

		// You can pretty much name them whatever you want
		$myname = "Jonathan";
		$age = 18;

		// And use them in a variety of ways
		echo "My name is $myname. I am $age years old.";

		$favoritecolor = "blue";
		echo $favoritecolor;
	?>

Strings
-------

	<?php
		$name = "Jonathan"; // this is a string 
		$greeting = "Hello, "; // this is also a string 
		
		// string is just a fancy name for a string 
		// of characters, or, really, any text.

		echo "You can echo a raw string";
		
		// or set it to a variable like above.
		// to combine ("concatenate") two or more strings,
		// use a .

		echo $greeting . $name . "!";
		// Hello, Jonathan!
	?

Operations, aka math
--------------------

	<?php
		$number = 4;
		$number2 = 16;

		$sum = $number + $number2;
		$difference = $number - $number2;
		$product = $number * $number2;
		$quotient = $number / $number2;

		// use ( )'s when handling several operations
		$number3 = ($number + $number2) / $sum;

		echo "Sum: $sum Product: $product";
		
	?>

Arrays
------

	<?php 
		// An array is basically a list
		$cars = array("95 BMW", "08 Altima", "2010 KIA", "94 Eclipse", "01 Infiniti");

		// It's numbered from 0 to count($arr) - 1
		echo $cars[0]; // 95 BMW
		echo $cars[4]; // 94 Eclipse
		
		// Arrays also exist in the form of key-value pairs:
		$clothes = array("favorite" => "My Rolling Stones T-Shirt",
					"newest" => "Red Aero shirt",
					"coolest" => "Black turtleneck");

		echo $clothes["favorite"]; // My Rolling Stones T-Shirt
	?>

Conditions
----------

	<?php
		if (true) {
			do_something();
			// this will always happen 
		}
		
		if (false) {
			do_something();
			// this will never happen 
		}

		if (false) {
			// this won't happen 
		} else {
			// but this will 
		}

		// true and false are booleans
		$condition = true;
		if ($condition) {
			// etc
		}

		// you can also set a variable to an expression
		$condition = (5 > 3); // a true statement
		if ($condition) {
			echo "5 is indeed greater than 3";
		}

		// or just put them in the if directly

		if (4 >= 3) {
			// code 
		} else {
			// we broke the laws of math 
		}

		$name = "Jonathan";
		if ($name == "Jonathan") { // Note the double =
			echo "Hey!";
		} else {
			echo "I don't know you.";
		}

		// you can also combine expressions 
		$pin = 130;
		if ($name == "Jonathan" and $pin == 130) {
			echo "Verified!";
		} else {
			echo "Either you aren't Jonathan or your pin isn't 130";
		}

		if ($name == "Jonathan" or $pin == 130) {
			echo "Either your name is Jonathan, or your pin is 130";
		} else {
			echo "Your name isn't Jonathan, and your pin isn't 130";
		}

		// you can chain as many as you like, and use ('s to separate
		if ($name == "Jonathan" or ($pin == 130 and $name == "Ivey")) {
			// make sense?
		}
	?>

Loops
-----

	<?php
		// Loops exist in the popular forms 
		// for, foreach, and while

		// for loops count, aka iterate
		for ($i = 0; $i < 10; $i += 1) {
			// The code in here will happen for
			// i = 0 to i = 9

			echo $i;
		}

		// we generally use them with Arrays

		$cars = array("95 BMW", "08 Altima", "2010 KIA", "90 Camaro", "94 Eclipse");

		echo "My cars are: <br>";
		for ($i = 0; $i < count($cars); $i++) { //note the < operator, which gives
												// the domain 0 - count($cars) - 1
			echo $cars[$i] . "<br>";			// count gives us the one-based length,
												// but arrays are numbered from 0!
		}
		
		// a foreach loop is special and iterates arrays 

		echo "These are also my cars: <br>";
		foreach ($cars as $car) {
			echo $car . "<br>";
		}
		
		// you can also use them in keyed arrays 
		$clothes = array("favorite" => "My Rolling Stones T-Shirt",
					"newest" => "Red Aero shirt",
					"coolest" => "Black turtleneck");

		foreach ($clothes as $category => $description) {
			echo $description . " is my " . $category . " piece of clothing.<br>";
		}

		// lastly, `while` is a special type of array
		// that repeats while `condition` is true

		$condition = true;
		while ($condition) {
			// some code
			if (something) {
				$condition = false; // makes this the last loop iteration
			}

			this_code(); // will still run, but just this last time
						 // once condition is false
		}
	?>

Functions
---------

	<?php
		function sayhi() {
			echo "Hi!";
		}

		sayhi(); // we can put blocks of code into different functions 
				 // and call them when they are needed

		function sum($num1, $num2) {
			return $num1 + $num2; // return, or give this back 
		}

		// you can also call a function with parameters, or ordered 
		// values that are set to the variables 
		echo sum(5, 7); 
		// 12
		
		// if you remember algebra, it's like f(x) 

		// one more
		function greetUser($name, $prefix) {
			return "Hello, $prefix $name!";
		}

		// it returns a string, and as such, we can set
		// the result of the function call to a variable
		// just as we did above with the sum 
		$greeting = greetUser("Jonathan", "Mr.");
		echo $greeting; // Hello, Mr. Jonathan!

	?>

Built-in Functions
------------------

	<?php
		// php contains hundreds of built-in functions 
		$randomnum = rand(0, 5); // random num between 0 and 5
		
		$int = floor(5.24); // round down to 5
	
		$filedata = file_get_contents("readme.txt");
		
		$string = "Hello, world!";
		$substring = substr($string, 6);
		// world!

		// you can find all the functions you need, and their parameters, 
		// in the php manual 
	?>


