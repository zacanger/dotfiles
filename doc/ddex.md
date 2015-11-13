## dd-ex: a line editor

dd-ex is a simple line editor completely written as a shell script. Yup, you read it right - a shell script. To make things more interesting, we use only two external commands: dd and rm; the latter is not necessary, but it is nice to clean up temporary files.
Table of contents


### Why did I do it?

I knew you would ask that. Well, some friend of mine claimed that you can do all text editing you need using dd only. This is obviously true, as you can use it to copy portions on files. You can see the section "How?" for an example. The challenge, of course, is to do this automatically. Although we can do everything using dd, it is not obvious that the Bourne shell is powerful enough for that. So I had to try and see - and now I can say that it is possible.


### How does it work?

Suppose that you need to replace the 5 bytes starting at position 372 in your_file with the string "hyewrfub", you can type:
  dd if=your_file bs=1 count=372 of=/tmp/file.beginning
  dd if=your_file bs=1 skip=377 of=/tmp/file.end
  dd of=/tmp/file.replacement bs=1 count=8 <<EOF
  hyewrfub
  EOF
  ( dd if=/tmp/file.beginning; dd if=/file.replacement dd if=file.end ) | \
  dd of=your_file
This might just need some explanation. The first line copies the initial 372 bytes of your_file to /tmp/file.beginning; the next line copies the bytes after 377 to /tmp/file.end; finally, we copy the new string to /tmp/file.replacement. If we just used:
  dd of=/tmp/file.replacement bs=1 <<EOF
  hyewrfub
  EOF
we would get an extra newline at the end of the string - we add "count=8" to copy only the first 8 bytes, skipping the newline. Finally, the last command concatenates the three temporary files and writes the result back to your_file.
From this example it is obvious that we can do any text manipulation if we have a way to find the appropriate byte offsets. This will be explained in the Implementation notes below.

One point to note is that, although we cannot use some common commands line "cat", we can quite easily avoid using it (see last command in the example).

I could have used "echo" to insert the replacement string in a temporary file, but it is easier to write a shell function which emulates it using (what else?) dd: some implementations use -n to remove the extra newline, other use \c, other might even not implement "echo" as a shell builtin! We don't need to worry about that - we have our own!


### Usage of dd-ex

dd-ex maintains a notion of current file (initially none) and of current line within the file. All text manipulation happens on the current line. The available commands are described below, divided by category.

#### Entering and leaving the editor

To enter the editor, copy the script and just run it. There are no command line parameters.
To leave the editor, type "quit"

### File commands

open file
Tries to open the file. If it succeeds, this becomes the current file. Otherwise it prints an error message. It cannot be used if there is already a current file.
new file
Like open, but creates the file if needed.
close
Forgets about the current file, if one is defined. It refuses to do so if there are unsaved changes
save
Saves the current file.
save file
Copies the current file to the one named.
name file
Causes subsequent saves to behave as "save file"
discard
Forgets that the current file has been modified - allows to close it without saving.

#### Movement commands

next
Moves the current line down in the file. You can move to the line just after the end of file, but if you move after that you probably get an endless loop. This might or might not bother you.
prev
Moves the current line up in the file. Unline next, it has some rudimentary checks so it doesn't try to move before the beginning of file.
goto n
Moves the current line to the line numbered "n". It does so by calling next or prev as necessary, so the same remarks about end of file apply.

#### Text modification commands

replace string1 string2
Looks for "string1" in the current line and, if found, replaces it with "string2". Since the two are separated by a space, the first one cannot contain a space (although you are welcome to implement quoting). The search uses shell patterns, so you can put a "?" instead of a space. Note, however, that you should avoid to use *, as the editor has no way to know the length of the pattern matched and will replace the wrong text. You are welcome to fix this and send me the patch.
nreplace n string1 string2
Like replace, except that it looks for the n-th occurrence of "string1"
delete
Throws away the current line. The next line in the file is made current. Not recommended on the first line after end of file, because of the implementation of next
insert text
Inserts "text;" before the current line, and then makes the new line current. There is no need to implement an insert after the current line, as you are allowed to move just after the end of file.

#### Misc commands

You could edit your file without these commands, but I personally find them useful to figure out what's happening.
print
Prints the number and contents of the current line.
autoprint
Causes the commands open, new, prev, next, goto, insert, delete, replace, and insert to print the current line after execution. It is equivalent to typing print after each such command
noprint
Disables the autoprint feature.


### Implementation notes

The editor itself is written as a collection of shell functions which implement useful operations. For simplicity, we have divided the function by type here and commented each type separately. The complete editor doesn't contain many comments, so it is not recommended for human reading.
Note that not all the functions are actually used - this is meant as a toolkit which you can use to create your own editor (such as, for example, an implementation of emacs with complete elisp support), so I have provided extra functions whenever it was easy to do so.

----------

I can't resist copying this comment:
_Okay, so the idea of using the dd command as the fundamental primitive operation for an editor written in shell script occurs to you. "Wow, I bet that'd work," you think. STOP RIGHT THERE. There's no need to bring that monster to life._

