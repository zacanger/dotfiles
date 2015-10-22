<!-- [List of command line commands | Codecademy][0] -->

![no](https://codecademy-production.s3.amazonaws.com/profile_thumbnail/56034de0e39efe9213000261_886285152.png?AWSAccessKeyId=AKIAI7LDEVVIL32I5WXQ&Expires=1443060803&Signature=4xVj9q2kGshjyxa%2F8dlTmwCSPqE%3D)

[![Codecademy](https://cdn-production.codecademy.com/assets/logo/logo--dark-blue-ac069c03cf75e3cb300995028104f92e.svg)
][1]

[Codecademy Resources ][2] \>
web

# List of command line commands

Glossary of commonly used commands

## Background

The command line is a text interface for your computer. It's a program that takes in commands, which it passes on to the computer's operating system to run.

From the command line, you can navigate through files and folders on your computer, just as you would with Windows Explorer on Windows or Finder on Mac OS. The difference is that the command line is fully text-based.

Here's an appendix of commonly used commands.

## Commands

### \>

    $ cat oceans.txt > continents.txt
    

`>` takes the standard output of the command on the left, and redirects it to the file on the right.

### \>\>

    $ cat glaciers.txt >> rivers.txt
    

`>>` takes the standard output of the command on the left and _appends_ (adds) it to the file on the right.

### <

    $ cat < lakes.txt
    

`<` takes the standard input from the file on the right and inputs it into the program on the left.

### |

    $ cat volcanoes.txt | wc
    

`|` is a "pipe". The `|` takes the standard output of the command on the left, and _pipes_ it as standard input to the command on the right. You can think of this as "command to command" redirection.

### ~/.bash\_profile

    $ nano ~/.bash_profile
    

**~/.bash\_profile** is the name of file used to store environment settings. It is commonly called the "bash profile". When a session starts, it will load the contents of the bash profile before executing commands.

### alias

    alias pd="pwd"
    

The `alias` command allows you to create keyboard shortcuts, or aliases, for commonly used commands.

### cd

    cd Desktop/
    

`cd` takes a directory name as an argument, and switches into that directory.

    $ cd jan/memory
    

To navigate directly to a directory, use `cd` with the directory's path as an argument. Here, `cd jan/memory/` command navigates directly to the **jan/memory** directory.

### cd ..

    $ cd ..
    

To move up one directory, use `cd ..`. Here, `cd ..` navigates up from **jan/memory/** to **jan/**.

### cp

    $ cp frida.txt historical/
    

`cp` copies files or directories. Here, we copy the file **lincoln.txt** and place it in the **historical/** directory

Wildcards

    $ cp * satire/
    

The wildcard `*` selects in the working directory, so here we use cp to copy all files into the satire/ directory.

    $ cp m*.txt scifi/
    

Here, m\*.txt selects all files in the working directory starting with "m" and ending with ".txt", and copies them to scifi/.

### env

    env
    

The `env` command stands for "environment", and returns a list of the environment variables for the current user.

### env | grep VARIABLE

    env | grep PATH
    

`env | grep PATH` is a command that displays the value of a single environment variable.

### export

    export USER="Jane Doe"
    

`export` makes the variable to be available to all child sessions initiated from the session you are in. This is a way to make the variable persist across programs.

### grep

    $ grep Mount mountains.txt
    

`grep` stands for "global regular expression print". It searches files for lines that match a pattern and returns the results. It is case sensitive.

### grep -i

    $ grep -i Mount mountains.txt
    

`grep -i` enables the command to be case insensitive.

### grep -R

    $ grep -R Arctic /home/ccuser/workspace/geography
    

`grep -R` searches all files in a directory and outputs filenames and lines containing matched results. `-R` stands for "recursive".

### grep -Rl

    $ grep -Rl Arctic /home/ccuser/workspace/geography
    

`grep -Rl` searches all files in a directory and outputs only filenames with matched results. `-R` stands for "recursive" and `l` stands for "files with matches".

### HOME

    $ echo $HOME
    

The `HOME` variable is an environment variable that displays the path of the home directory.

### ls

      $ ls
      2014  2015  hardware.txt
    

`ls` lists all files and directories in the working directory

ls -a

      ls -a
      .  ..  .preferences  action  drama comedy  genres.xt
    

`ls -a` lists all contents in the working directory, including hidden files and directories

ls -l

      ls -l
      drwxr-xr-x 5  cc  eng  4096 Jun 24 16:51  action
      drwxr-xr-x 4  cc  eng  4096 Jun 24 16:51  comedy
      drwxr-xr-x 6  cc  eng  4096 Jun 24 16:51  drama
      -rw-r--r-- 1  cc  eng     0 Jun 24 16:51  genres.txt
    

`ls -l` lists all contents of a directory in long format. [Here's what each column means][3].

ls -t

`ls -t` orders files and directories by the time they were last modified.

### mkdir

    $ mkdir media
    

`mkdir` takes in a directory name as an argument, and then creates a new directory in the current working directory. Here we used mkdir to create a new directory named **media/**.

### mv

    $ mv superman.txt superhero/
    

To move a file into a directory, use mv with the source file as the first argument and the destination directory as the second argument. Here we move superman.txt into superhero/.

### nano

    $ nano hello.txt
    

_nano_ is a command line text editor. It works just like a desktop text editor like TextEdit or Notepad, except that it is accessible from the the command line and only accepts keyboard input.

### PATH

    $ echo $PATH
    
    /home/ccuser/.gem/ruby/2.0.0/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/sbin:/bin
    

`PATH` is an environment variable that stores a list of directories separated by a colon. Each directory contains scripts for the command line to execute. PATH lists which directories contain scripts.

### pwd

    $ pwd
    /home/ccuser/workspace/blog
    

`pwd` prints the name of the working directory

### rm

    $ rm waterboy.txt
    

`rm` deletes files. Here we remove the file waterboy.txt from the file system.

### rm -r

    $ rm -r comedy
    

`rm -r` deletes a directory and all of its child directories.

### sed

    $ sed 's/snow/rain/' forests.txt
    

`sed` stands for "stream editor". It accepts standard input and modifies it based on an _expression_, before displaying it as output data.

In the expression `'s/snow/rain/'`:

*   `s`: stands for "substitution".
*   `snow`: the search string, the text to find.
*   `rain`: the replacement string, the text to add in place.
    

### sort

    $ sort lakes.txt
    

`sort` takes the standard input and orders it alphabetically for the standard output.

### standard error

_standard error_, abbreviated as `stderr`, is an error message outputted by a failed process.

### source

    source ~/.bash_profile
    

`source` activates the changes in **~/.bash\_profile** for the current session. Instead of closing the terminal and needing to start a new session, `source` makes the changes available right away in the session we are in.

### standard input

_standard input_, abbreviated as `stdin`, is information inputted into the terminal through the keyboard or input device.

### standard output

_standard output_, abbreviated as `stdout`, is the information outputted after a process is run.

### touch

    $ touch data.tx
    

`touch` creates a new file inside the working directory. It takes in a file name as an argument, and then creates a new empty file in the current working directory. Here we used touch to create a new file named keyboard.txt inside the 2014/dec/ directory.

If the file exists, touch is used to update the modification time of the file

### uniq

    $ sort lakes.txt
    

`sort` takes the standard input and orders it alphabetically for the standard output.

![Logo--grey](https://cdn-production.codecademy.com/assets/logo/logo--grey-c17e2f784936aae503757e692a8f26cc.svg)

Teaching the world how to code.

[][4]
[][5]
[][6]
[][7]
[][8]
[][9]
[][10]

##### **Company**

*   [About][11]
*   [Stories][12]
*   [We're hiring][13]
*   [Blog][14]
    

##### **Resources**

*   [Articles][2]
*   [Schools][15]
    

##### **Learn To Code**

*   [Make a Website][16]
*   [Make a Website Projects][17]
*   [Make an Interactive Website][18]
*   [Learn Rails][19]
*   [Learn AngularJS][20]
*   [Ruby on Rails Authentication][21]
*   [Learn the Command Line][22]
*   [Learn SQL][23]
    

*   [HTML & CSS][24]
*   [JavaScript][25]
*   [jQuery][26]
*   [PHP][27]
*   [Python][28]
*   [Ruby][29]
*   [Learn APIs][30]
    

[Privacy Policy][31]
[Terms][32]

Made in NYC (c) 2015 Codecademy



[0]: https://www.codecademy.com/articles/command-line-commands
[1]: https://www.codecademy.com/
[2]: https://www.codecademy.com/articles
[3]: http://www.codecademy.com/en/learn/learn-the-command-line/topics/manipulation/exercises/manipulation-ls-l
[4]: http://www.reddit.com/r/codecademy
[5]: http://stackoverflow.com/tags
[6]: https://www.youtube.com/channel/UC5CMtpogD_P3mOoeiDHD5eQ
[7]: https://twitter.com/Codecademy
[8]: https://www.facebook.com/codecademy
[9]: https://instagram.com/codecademy
[10]: https://medium.com/about-codecademy
[11]: https://www.codecademy.com/about
[12]: https://www.codecademy.com/stories
[13]: https://www.codecademy.com/about/jobs
[14]: https://www.codecademy.com/blog
[15]: https://www.codecademy.com/schools
[16]: https://www.codecademy.com/skills/make-a-website
[17]: https://www.codecademy.com/courses/html-css-prj
[18]: https://www.codecademy.com/skills/make-an-interactive-website
[19]: https://www.codecademy.com/courses/learn-rails
[20]: https://www.codecademy.com/courses/learn-angularjs
[21]: https://www.codecademy.com/courses/rails-auth
[22]: https://www.codecademy.com/courses/learn-the-command-line
[23]: https://www.codecademy.com/courses/learn-sql
[24]: https://www.codecademy.com/tracks/web
[25]: https://www.codecademy.com/tracks/javascript
[26]: https://www.codecademy.com/tracks/jquery
[27]: https://www.codecademy.com/tracks/php
[28]: https://www.codecademy.com/tracks/python
[29]: https://www.codecademy.com/tracks/ruby
[30]: https://www.codecademy.com/apis
[31]: https://www.codecademy.com/policy
[32]: https://www.codecademy.com/terms
