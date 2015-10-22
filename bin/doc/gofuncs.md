INTRODUCTION

Like many unix users, I have the need to easily move about the directory
tree. 

The three shell functions shown here are the ones I find most useful. Unlike
some other techniques, the paths you wish to save are remembered from one
login session to the next.

I have used these functions in ksh and bash.  The definitions shown below
work as-is in bash.  On some systems you will need to remove the ()'s that
follow the function names.


OVERVIEW

Locations (i.e. paths) are saved by the 'here' command. This writes the
current directory name (literally 'here' at the time you type it) into a
file in your ~/.going directory (which you 'mkdir' ahead of time).  You can
return to the location later using the 'go' command (it 'goes' to a named
location).  To list the available locations use the 'there' command (to see
what locations are out 'there').  Since the locations are saved in files,
they persist from one session to the next, unlike some other available
techniques.  


INSTALLATION

	1) mkdir ~/.going
	2) place the following 'bash' commands in a file such 
	   as ~/.bashrc

--- CUT ---
 function go()   { cd `cat ~/.going/${1-_back} || echo .` ; }
 function here() { pwd > ~/.going/${1-_back} ; 
                   echo "go ${1} will go to `pwd`" ;  } 
 function there() { ( cd ~/.going ; 
                      grep '' * ) | 
                      awk '{ FS=":" ; printf("%-10s %s\n",$1,$2); }' | 
                      grep -i -E ${1-.\*} ; }
--- END ---


NAME
	here  - save the current directory for later
	go    - go somewhere you have previously saved with 'here'
	there - view the places you can 'go'

SYNOPSIS
	here  [name]	(default name = _back)
	go    [name]	(default name = _back)
	there [grep-E-expresssion]	default = .*

DESCRIPTION
	'here' assigns a name to a directory, and saves the
	name for later use by 'go'. With no parametre the name
	_back is used.

	'go' returns you to a directory.  The parametre is the
	name assigned earlier with the 'here' command.  With
	no parametre the name _back is used.

	'there' lists the assigned names and paths.  If
	specified, a parametre filters the list.  Filter words
	can be OR'd with the | character (which may have to be
	escaped for the shell).

 
EXAMPLES
	A typical session might look like the following
	(output denoted by =>) 

	# save my own bin location for later
		$ cd ~/bin
		$ here mybin
		=> go mybin will go to /home/malcolm/bin

	# later, to return to my own bin directory
		$ go mybin

	# later still, when I've forgotten where I can 'go'
		$ there
		=> mybin	/home/malcolm/bin
		=> sbin		/usr/local/sbin
		=> cgi		/var/lib/httpd/cgi-bin
		  ...etc...

	Some more 'there' examples
		$ there bin	# name or path contains 'bin'
		=> mybin	/home/malcolm/bin
		=> sbin		/usr/local/sbin
		=> cgi		/var/liv/httpd/cgi-bin
	
		$ there ^my	# name starts with 'my'
		=> mybin	/home/malcolm/bin
		=> mysrc	/home/malcolm/bin/src
	
		$there bin\|cgi	# look for 'bin' OR 'cgi'
		=> mybin	/home/malcolm/bin
		=> sbin		/usr/local/sbin
		=> cgi		/var/lib/httpd/cgi-bin
		=> modules	/var/lib/httpd/cgi-bin/perl/modules

AUTHOR
	Malcolm Dew-Jones. 73312.2317@compuserve.com

COPYRIGHT
	GNU Copyleft.  This software is provided AS-IS in the hopes
	that it will be useful, and comes with no warranty of any sort.

BUGS
	The top row of the there output is not formatted as
	nicely as the other rows.

