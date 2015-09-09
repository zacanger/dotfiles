Part I: Working With Files

1. Empty a file (truncate to 0 size)

$ > file

This one-liner uses the output redirection operator >. Redirection of output causes the file to be opened for writing. If the file does not exist it is created; if it does exist it is truncated to zero size. As we're not redirecting anything to the file it remains empty.

If you wish to replace the contents of a file with some string or create a file with specific content, you can do this:

$ echo "some string" > file

This puts the string "some string" in the file.

2. Append a string to a file

$ echo "foo bar baz" >> file

This one-liner uses a different output redirection operator >>, which appends to the file. If the file does not exist it is created. The string appended to the file is followed by a newline. If you don't want a newline appended after the string, add the -n argument to echo:

$ echo -n "foo bar baz" >> file

3. Read the first line from a file and put it in a variable

$ read -r line < file

This one-liner uses the built-in bash command read and the input redirection operator <. The read command reads one line from the standard input and puts it in the line variable. The -r parameter makes sure the input is read raw, meaning the backslashes won't get escaped (they'll be left as is). The redirection command < file opens file for reading and makes it the standard input to the read command.

The read command removes all characters present in the special IFS variable. IFS stands for Internal Field Separator that is used for word splitting after expansion and to split lines into words with the read built-in command. By default IFS contains space, tab, and newline, which means that the leading and trailing tabs and spaces will get removed. If you wish to preserve them, you can set IFS to nothing for the time being:

$ IFS= read -r line < file

This will change the value of IFS just for this command and will make sure the first line gets read into the line variable really raw with all the leading and trailing whitespaces.

Another way to read the first line from a file into a variable is to do this:

$ line=$(head -1 file)

This one-liner uses the command substitution operator $(...). It runs the command in ..., and returns its output. In this case the command is head -1 file that outputs the first line of the file. The output is then assigned to the line variable. Using $(...) is exactly the same as `...`, so you could have also written:

$ line=`head -1 file`

However $(...) is the preferred way in bash as it's cleaner and easier to nest.

4. Read a file line-by-line

$ while read -r line; do
    # do something with $line
done < file

This is the one and only right way to read lines from a file one-by-one. This method puts the read command in a while loop. When the read command encounters end-of-file, it returns a positive return code (code for failure) and the while loop stops.

Remember that read trims leading and trailing whitespace, so if you wish to preserve it, clear the IFS variable:

$ while IFS= read -r line; do
    # do something with $line
done < file

If you don't like the to put < file at the end, you can also pipe the contents of the file to the while loop:

$ cat file | while IFS= read -r line; do
    # do something with $line
done

5. Read a random line from a file and put it in a variable

$ read -r random_line < <(shuf file)

There is no clean way to read a random line from a file with just bash, so we'll need to use some external programs for help. If you're on a modern Linux machine, then it comes with the shuf utility that's in GNU coreutils.

This one-liner uses the process substitution <(...) operator. This process substitution operator creates an anonymous named pipe, and connects the stdout of the process to the write part of the named pipe. Then bash executes the process, and it replaces the whole process substitution expression with the filename of the anonymous named pipe.

When bash sees <(shuf file) it opens a special file /dev/fd/n, where n is a free file descriptor, then runs shuf file with its stdout connected to /dev/fd/n and replaces <(shuf file) with /dev/fd/n so the command effectively becomes:

$ read -r random_line < /dev/fd/n

Which reads the first line from the shuffled file.

Here is another way to do it with the help of GNU sort. GNU sort takes the -R option that randomizes the input.

$ read -r random_line < <(sort -R file)

Another way to get a random line in a variable is this:

$ random_line=$(sort -R file | head -1)

Here the file gets randomly sorted by sort -R and then head -1 takes the first line.

6. Read the first three columns/fields from a file into variables

$ while read -r field1 field2 field3 throwaway; do
    # do something with $field1, $field2, and $field3
done < file

If you specify more than one variable name to the read command, it shall split the line into fields (splitting is done based on what's in the IFS variable, which contains a whitespace, a tab, and a newline by default), and put the first field in the first variable, the second field in the second variable, etc., and it will put the remaining fields in the last variable. That's why we have the throwaway variable after the three field variables. if we didn't have it, and the file had more than three columns, the third field would also get the leftovers.

Sometimes it's shorter to just write _ for the throwaway variable:

$ while read -r field1 field2 field3 _; do
    # do something with $field1, $field2, and $field3
done < file

Or if you have a file with exactly three fields, then you don't need it at all:

$ while read -r field1 field2 field3; do
    # do something with $field1, $field2, and $field3
done < file

Here is an example. Let's say you wish to find out number of lines, number of words, and number of bytes in a file. If you run wc on a file you get these 3 numbers plus the filename as the fourth field:

$ cat file-with-5-lines
x 1
x 2
x 3
x 4
x 5

$ wc file-with-5-lines
 5 10 20 file-with-5-lines

So this file has 5 lines, 10 words, and 20 chars. We can use the read command to get this info into variables:

$ read lines words chars _ < <(wc file-with-5-lines)

$ echo $lines
5
$ echo $words
10
$ echo $chars
20

Similarly you can use here-strings to split strings into variables. Let's say you have a string "20 packets in 10 seconds" in a $info variable and you want to extract 20 and 10. Not too long ago I'd have written this:

$ packets=$(echo $info | awk '{ print $1 }')
$ time=$(echo $info | awk '{ print $4 }')

However given the power of read and our bash knowledge, we can now do this:

$ read packets _ _ time _ <<< "$info"

Here the <<< is a here-string, which lets you pass strings directly to the standard input of commands.

7. Find the size of a file, and put it in a variable

$ size=$(wc -c < file)

This one-liner uses the command substitution operator $(...) that I explained in one-liner #3. It runs the command in ..., and returns its output. In this case the command is wc -c < file that prints the number of chars (bytes) in the file. The output is then assigned to size variable.

8. Extract the filename from the path

Let's say you have a /path/to/file.ext, and you wish to extract just the filename file.ext. How do you do it? A good solution is to use the parameter expansion mechanism:

$ filename=${path##*/}

This one-liner uses the ${var##pattern} parameter expansion. This expansion tries to match the pattern at the beginning of the $var variable. If it matches, then the result of the expansion is the value of $var with the longest matching pattern deleted.

In this case the pattern is */ which matches at the beginning of /path/to/file.ext and as it's a greedy match, the pattern matches all the way till the last slash (it matches /path/to/). The result of this expansion is then just the filename file.ext as the matched pattern gets deleted.

9. Extract the directory name from the path

This is similar to the previous one-liner. Let's say you have a /path/to/file.ext, and you wish to extract just the path to the file /path/to. You can use the parameter expansion again:

$ dirname=${path%/*}

This time it's the ${var%pattern} parameter expansion that tries to match the pattern at the end of the $var variable. If the pattern matches, then the result of the expansion is the value of $var shortest matching pattern deleted.

In this case the pattern is /*, which matches at the end of /path/to/file.ext (it matches /file.ext). The result then is just the dirname /path/to as the matched pattern gets deleted.

10. Make a copy of a file quickly

Let's say you wish to copy the file at /path/to/file to /path/to/file_copy. Normally you'd write:

$ cp /path/to/file /path/to/file_copy

However you can do it much quicker by using the brace expansion {...}:

$ cp /path/to/file{,_copy}

Brace expansion is a mechanism by which arbitrary strings can be generated. In this particular case /path/to/file{,_copy} generates the string /path/to/file /path/to/file_copy, and the whole command becomes cp /path/to/file /path/to/file_copy.

Similarly you can move a file quickly:

$ mv /path/to/file{,_old}

This expands to mv /path/to/file /path/to/file_old.





rt II: Working With Strings

1. Generate the alphabet from a-z

$ echo {a..z}

This one-liner uses brace expansion. Brace expansion is a mechanism for generating arbitrary strings. This one-liner uses a sequence expression of the form {x..y}, where x and y are single characters. The sequence expression expands to each character lexicographically between x and y, inclusive.

If you run it, you get all the letters from a-z:

$ echo {a..z}
a b c d e f g h i j k l m n o p q r s t u v w x y z

2. Generate the alphabet from a-z without spaces between characters

$ printf "%c" {a..z}

This is an awesome bash trick that 99.99% bash users don't know about. If you supply a list of items to the printf function it actually applies the format in a loop until the list is empty! printf as a loop! There is nothing more awesome than that!

In this one-liner the printf format is "%c", which means "a character" and the arguments are all letters from a-z separated by space. So what printf does is it iterates over the list outputting each character after character until it runs out of letters.

Here is the output if you run it:

abcdefghijklmnopqrstuvwxyz

This output is without a terminating newline because the format string was "%c" and it doesn't include \n. To have it newline terminated, just add $'\n' to the list of chars to print:

$ printf "%c" {a..z} $'\n'

$'\n' is bash idiomatic way to represent a newline character. printf then just prints chars a to z, and the newline character.

Another way to add a trailing newline character is to echo the output of printf:

$ echo $(printf "%c" {a..z})

This one-liner uses command substitution, which runs printf "%c" {a..z} and replaces the command with its output. Then echo prints this output and adds a newline itself.

Want to output all letters in a column instead? Add a newline after each character!

$ printf "%c\n" {a..z}

Output:

a
b
...
z

Want to put the output from printf in a variable quickly? Use the -v argument:

$ printf -v alphabet "%c" {a..z}

This puts abcdefghijklmnopqrstuvwxyz in the $alphabet variable.

Similarly you can generate a list of numbers. Let's say from 1 to 100:

$ echo {1..100}

Output:

1 2 3 ... 100

Alternatively, if you forget this method, you can use the external seq utility to generate a sequence of numbers:

$ seq 1 100

3. Pad numbers 0 to 9 with a leading zero

$ printf "%02d " {0..9}

Here we use the looping abilities of printf again. This time the format is "%02d ", which means "zero pad the integer up to two positions", and the items to loop through are the numbers 0-9, generated by the brace expansion (as explained in the previous one-liner).

Output:

00 01 02 03 04 05 06 07 08 09

If you use bash 4, you can do the same with the new feature of brace expansion:

$ echo {00..09}

Older bashes don't have this feature.

4. Produce 30 English words

$ echo {w,t,}h{e{n{,ce{,forth}},re{,in,fore,with{,al}}},ither,at}

This is an abuse of brace expansion. Just look at what this produces:

when whence whenceforth where wherein wherefore wherewith wherewithal whither what then thence thenceforth there therein therefore therewith therewithal thither that hen hence henceforth here herein herefore herewith herewithal hither hat
Crazy awesome!

Here is how it works - you can produce permutations of words/symbols with brace expansion. For example, if you do this,

$ echo {a,b,c}{1,2,3}

It will produce the result a1 a2 a3 b1 b2 b3 c1 c2 c3. It takes the first a, and combines it with {1,2,3}, producing a1 a2 a3. Then it takes b and combines it with {1,2,3}, and then it does the same for c.

So this one-liner is just a smart combination of braces that when expanded produce all these English words!

5. Produce 10 copies of the same string

$ echo foo{,,,,,,,,,,}

This one-liner uses the brace expansion again. What happens here is foo gets combined with 10 empty strings, so the output is 10 copies of foo:

foo foo foo foo foo foo foo foo foo foo foo
6. Join two strings

$ echo "$x$y"

This one-liner simply concatenates two variables together. If the variable x contains foo and y contains bar then the result is foobar.

Notice that "$x$y" were quoted. If we didn't quote it, echo would interpret the $x$y as regular arguments, and would first try to parse them to see if they contain command line switches. So if $x contains something beginning with -, it would be a command line argument rather than an argument to echo:

x=-n
y=" foo"
echo $x$y
Output:

foo
Versus the correct way:

x=-n
y=" foo"
echo "$x$y"
Output:

-n foo
If you need to put the two joined strings in a variable, you can omit the quotes:

var=$x$y
7. Split a string on a given character

Let's say you have a string foo-bar-baz in the variable $str and you wish to split it on the dash and iterate over it. You can simply combine IFS with read to do it:

$ IFS=- read -r x y z <<< "$str"

Here we use the read x command that reads data from stdin and puts the data in the x y z variables. We set IFS to - as this variable is used for field splitting. If multiple variable names are specified to read, IFS is used to split the line of input so that each variable gets a single field of the input.

In this one-liner $x gets foo, $y gets bar, $z gets baz.

Also notice the use of <<< operator. This is the here-string operator that allows strings to be passed to stdin of commands easily. In this case string $str is passed as stdin to read.

You can also put the split fields and put them in an array:

$ IFS=- read -ra parts <<< "foo-bar-baz"

The -a argument to read makes it put the split words in the given array. In this case the array is parts. You can access array elements through ${parts[0]}, ${parts[1]}, and ${parts[0]}. Or just access all of them through ${parts[@]}.

8. Process a string character by character

$ while IFS= read -rn1 c; do
    # do something with $c
done <<< "$str"

Here we use the -n1 argument to read command to make it read the input character at a time. Similarly we can use -n2 to read two chars at a time, etc.

9. Replace "foo" with "bar" in a string

$ echo ${str/foo/bar}

This one-liner uses parameter expansion of form ${var/find/replace}. It finds the string find in var and replaces it with replace. Really simple!

To replace all occurrences of "foo" with "bar", use the ${var//find/replace} form:

$ echo ${str//foo/bar}

10. Check if a string matches a pattern

$ if [[ $file = *.zip ]]; then
    # do something
fi

Here the one-liner does something if $file matches *.zip. This is a simple glob pattern matching, and you can use symbols * ? [...] to do matching. Code * matches any string, ? matches a single char, and [...] matches any character in ... or a character class.

Here is another example that matches if answer is Y or y:

$ if [[ $answer = [Yy]* ]]; then
    # do something
fi

11. Check if a string matches a regular expression

$ if [[ $str =~ [0-9]+\.[0-9]+ ]]; then
    # do something
fi

This one-liner tests if the string $str matches regex [0-9]+\.[0-9]+, which means match a number followed by a dot followed by number. The format for regular expressions is described in man 3 regex.

12. Find the length of the string

$ echo ${#str}

Here we use parameter expansion ${#str} which returns the length of the string in variable str. Really simple.

13. Extract a substring from a string

$ str="hello world"
$ echo ${str:6}

This one-liner extracts world from hello world. It uses the substring expansion. In general substring expansion looks like ${var:offset:length}, and it extracts length characters from var starting at index offset. In our one-liner we omit the length that makes it extract all characters starting at offset 6.

Here is another example:

$ echo ${str:7:2}

Output:

or
14. Uppercase a string

$ declare -u var
$ var="foo bar"

The declare command in bash declares variables and/or gives them attributes. In this case we give the variable var attribute -u, which upper-cases its content whenever it gets assigned something. Now if you echo it, the contents will be upper-cased:

$ echo $var

FOO BAR
Note that -u argument was introduced in bash 4. Similarly you can use another feature of bash 4, which is the ${var^^} parameter expansion that upper-cases a string in var:

$ str="zoo raw"
$ echo ${str^^}

Output:

ZOO RAW
15. Lowercase a string

$ declare -l var
$ var="FOO BAR"

Similar to the previous one-liner, -l argument to declare sets the lower-case attribute on var, which makes it always be lower-case:

$ echo $var

foo bar
The -l argument is also available only in bash 4 and later.

Another way to lowercase a string is to use ${var,,} parameter expansion:

$ str="ZOO RAW"
$ echo ${str,,}

Output:

zoo raw



Part IV: Working with history

1. Erase all shell history

$ rm ~/.bash_history

Bash keeps the shell history in a hidden file called .bash_history. This file is located in your home directory. To get rid of the history, just delete it.

Note that if you logout after erasing the shell history, this last rm ~/.bash_history command will be logged. If you want to hide that you erased shell history, see the next one-liner.

2. Stop logging history for this session

$ unset HISTFILE

The HISTFILE special bash variable points to the file where the shell history should be saved. If you unset it, bash won't save the history.

Alternatively you can point it to /dev/null,

$ HISTFILE=/dev/null

3. Don't log the current command to history

Just start the command with an extra space:

$  command

If the command starts with an extra space, it's not logged to history.

Note that this only works if the HISTIGNORE variable is properly configured. This variable contains : separated values of command prefixes that shouldn't be logged.

For example to ignore spaces set it to this:

HISTIGNORE="[ ]*"
My HISTIGNORE looks like this:

HISTIGNORE="&:[ ]*"
The ampersand has a special meaning - don't log repeated commands.

4. Change the file where bash logs command history

$ HISTFILE=~/docs/shell_history.txt

Here we simply change the HISTFILE special bash variable and point it to ~/docs/shell_history.txt. From now on bash will save the command history in that file.

5. Add timestamps to history log

$ HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S"

If you set the HISTTIMEFORMAT special bash variable to a valid date format (see man 3 strftime) then bash will log the timestamps to the history log. It will also display them when you call the history command (see the next one-liner).

6. Show the history

$ history

The history command displays the history list with line numbers. If HISTTIMEFORMAT is set, it also displays the timestamps.

7. Show the last 50 commands from the history

$ history 50

If you specify a numeric argument, such as 50, to history, it prints the last 50 commands from the history.

7. Show the top 10 most used commands from the bash history

$ history |
    sed 's/^ \+//;s/  / /' |
    cut -d' ' -f2- |
    awk '{ count[$0]++ } END { for (i in count) print count[i], i }' |
    sort -rn |
    head -10

This one-liner combines bash with sed, cut, awk, sort and head. The perfect combination. Let's walk through this to understand what happens. Let's say the output of history is:

$ history
    1  rm .bash_history 
    2  dmesg
    3  su -
    4  man cryptsetup
    5  dmesg

First we use the sed command to remove the leading spaces and convert the double space after the history command number to a single space:

$ history | sed 's/^ \+//;s/  / /'
1 rm .bash_history 
2 dmesg
3 su -
4 man cryptsetup
5 dmesg

Next we use cut to remove the first column (the history numbers):

$ history |
    sed 's/^ \+//;s/  / /' |
    cut -d' ' -f2-

rm .bash_history 
dmesg
su -
man cryptsetup
dmesg

Next we use awk to record how many times each command has been seen:

$ history |
    sed 's/^ \+//;s/  / /' |
    cut -d' ' -f2- |
    awk '{ count[$0]++ } END { for (i in count) print count[i], i }'

1 rm .bash_history 
2 dmesg
1 su -
1 man cryptsetup

Then we sort the output numerically and reverse it:

$ history |
    sed 's/^ \+//;s/  / /' |
    cut -d' ' -f2- |
    awk '{ count[$0]++ } END { for (i in count) print count[i], i }' |
    sort -rn

2 dmesg
1 rm .bash_history 
1 su -
1 man cryptsetup

Finally we take the first 10 lines that correspond to 10 most frequently used commands:

$ history |
    sed 's/^ \+//;s/  / /' |
    cut -d' ' -f2- |
    awk '{ count[$0]++ } END { for (i in count) print count[i], i }' |
    sort -rn |
    head -10

Here is what my 10 most frequently used commands look like:

2172 ls
1610 gs
252 cd ..
215 gp
213 ls -las
197 cd projects
155 gpu
151 cd
119 gl
119 cd tests/

Here I've gs that's an alias for git status, gp is git push, gpu is git pull and gl is git log.

8. Execute the previous command quickly

$ !!

That's right. Type two bangs. The first bang starts history substitution, and the second one refers to the last command. Here is an example:

$ echo foo
foo
$ !!
foo

Here the echo foo command was repeated.

It's especially useful if you wanted to execute a command through sudo but forgot. Then all you've to do is run:

$ rm /var/log/something
rm: cannot remove `/var/log/something': Permission denied
$
$ sudo !!   # executes `sudo rm /var/log/something`

9. Execute the most recent command starting with the given string

$ !foo

The first bang starts history substitution, and the second one refers to the most recent command starting with foo.

For example,

$ echo foo
foo
$ ls /
/bin /boot /home /dev /proc /root /tmp
$ awk -F: '{print $2}' /etc/passwd
...
$ !ls
/bin /boot /home /dev /proc /root /tmp

Here we executed commands echo, ls, awk, and then used !ls to refer to the ls / command.

10. Open the previous command you executed in a text editor

$ fc

Fc opens the previous command in a text editor. It's useful if you've a longer, more complex command and want to edit it.

For example, let's say you've written a one-liner that has an error, such as:

$ for wav in wav/*; do mp3=$(sed 's/\.wav/\.mp3/' <<< "$wav"); ffmpeg -i "$wav" "$m3p"; done

And you can't see what's going on because you've to scroll around, then you can simply type fc to load it in your text editor, and then quickly find that you mistyped mp3 at the end.


