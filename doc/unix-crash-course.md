onion soup

[home](http://soupksx6vqh3ydda.onion.city/index.html)

####  UNIX crash course

The following screed contains a relatively painless romp through the sometimes
painful terrain of UNIX commands. My intent is to describe a simple (though
comprehensive) presentation of the basic, UNIX commandline. The commands -
below - are generic; that is to say, they _should_ all be valid and execute on
_most_ modern, UNIX operating systems. (In the future, this page may be
expanded to include networking.)

  1. Filesystem
  2. Permissions and ownerships
  3. The find utility
  4. Data archives
  5. Miscellaneous

Navigating a filesystem, listing files and manipulating them

Display the absolute PATH of the current working directory.

$ pwd

Display the absolute path of an executable, named: "rm".

$ which rm

Change directory to /home/doctor/medical_abnormalities - using the absolute
PATH.

$ cd /home/doctor/medical_abnormalities

Change from the current working directory to its sub-directory, named: "music"
- using the relative path.

$ cd music

Change the working directory to $HOME.

$ cd ~/

List all non-hidden files and directories in the current working directory.

$ ls

List ALL files and directories (hidden or otherwise) within the current
working directory in long format - displaying their attributes, i.e. size,
ownership, time last edited, permissions, etc.

$ ls -la

Recursively list all non-hidden files and directories residing under the music
directory.

$ ls -Rl music

List in long format a single file, named: "politics.txt"

$ ls -la politics.txt

List the attributes: size, ownership, time when updated, permissions, etc. on
the_damned directory.

$ ls -ld the_damned

Print, as a numerical count, all files in the_damned directory.

$ ls -la the_damned |wc -l

Print the contents of hell.txt to standard out.

$ cat hell.txt

Copy (as a backup) hell.txt to hell.txt.OLD.

$ cp hell.txt hell.txt.OLD

Recursively copy the putrid directory to stinks, while preserving ("-p") the
modification time, access time, file flags, file mode, user ID, and group ID
attributes.

$ cp -Rp putrid stinks

Move ugly.txt to stupid.txt, i.e. rename a file. This command works without
additional flags for a directory, unlike cp.

$ mv ugly.txt stupid.txt

Create a new file, named: "operation_file".

$ touch operation_file

Add the word "brain" to the operation_file, append "surgery" to the bottom of
it then erase all of the contents in the file.

$ echo "brain" > operation_file  
  
$ echo "surgery" >> operation_file  
  
$ echo "" > operation_file

Delete operation_file.

$ rm operation_file

Create evil directory.

$ mkdir evil

Delete the evil directory and its contents recursively - without prompting for
a confirmation when deleting any file or directory in (or under) evil.

$ rm -rf evil

Print to the screen the details of the type of a file queried: text, binary,
image, audio, etc.

$ file air_supply.mp3

Create a symbolic link ("short cut") from an existing file called "real_file"
in the home directory to a linked_file in the www sub-directory. This command
works identically for directories.

$ ln -s $HOME/real_file $HOME/www/linked_file

Altering permissions and ownerships

"chmod" is employed to alter the read, write and execute permissions on files
and directories. The breakdown of the absolute (numerical) mode for the
permissions of files and directories is as follows: the first field signifies
the owner, the second field the group and the third field all others, i.e.
world.

(owner)(group)(other)

read = 4  
write = 2  
execute = 1

So - by placing 755 on a file means that the owner has read, write and execute
permissions, while the group and other have only read and execute permissions
on that file. Three examples follow:

The numerical bits, 644, signify that the owner of index.html will be able to
write to and read it, all members of the owner's group will be able to read
it, and all other system users will be able to read it.

$ chmod 644 index.html

After the following command is executed, the owner will have read, write and
execute permissions, the group will have read and execute permissions, and all
others will have execute permissions over index.cgi.

$ chmod 751 index.cgi

Change the permissions on the www directory to user read, write and execute,
group execute and other execute.

$ chmod 711 www

Change _both_ the user and group ownership on "trap.txt" to "rat" and
"cheese", respectively. (Verify that the cheese group exists in /etc/group. If
not, add it with groupadd and associate the user to it with usermod.)

$ chown -h rat:cheese trap.txt

Change user and group ownership - recursively - on all files and sub-
directories under the trap directory.

$ chown -R rat:cheese trap

Change the group ownership to "graft" on a file, named: "politician.txt".

$ chgrp -h graft politician.txt

Change the group ownership to "graft" recursively on a directory, named:
"judges".

$ chgrp -R graft judges

Strip **all** permissions from a file, so as to have it not be executable,
read from or written to. (Generally, a sysadmin will do so in the wake of a
misbehaving script, and he will change the owner to root, preventing an under-
priviledged user from altering the permissions on the script.)

# chmod 000 misbehaved.cgi  
  
# chown -h root misbehaved.cgi

Locating files and directories with the find utility

Locate and print all files in the www directory and its child directories
which contain the .php extension. When using
[find](http://unixhelp.ed.ac.uk/CGI/man-cgi?find), always enclose wildcards
expressions in quotes to prevent shell expansion.

$ find $HOME/www -iname "*.php"

Find and remove a file, -C with a non-escapable "-" character in its name.

$ find . -iname '-C' -exec rm {} \;

Locate all files in the current directory with the extension of .html, then
search each located file for "<p class="e">" and change every found instance
of it to "<p>" with the [sed](http://www.grymoire.com/Unix/Sed.html) (stream)
editor. (**N.B.** On *BSD machines, sed requires an argument after "-i".
Usually, 2 double quotes, " ", will work.)

$ find . -type f -iname "*.html" -exec sed -i \ 's/<p class=\"e\">/<p>/g' {}
\;

Find all child directories with _dangerous_ 777 permissions and alter them to
reasonably sane 751 permissions.

$ find . -type d -perm 777 -exec chmod 751 {} \;

Find all files in the current and child directories with world write
permissions and alter them so that only the user can write to them but group
and other can read them.

$ find . -type f -perm 666 -exec chmod 644 {} \;

Find all child directories with the old group ID "felony" and change them to
the new group ID "misdemeanor".

$ find . -type d -group felony -exec chown -R misdemeanor {} \;

Locate all files in the current directory and it sub-directories owned by the
rat user, then delete the located files. (_Be careful when using find with
-exec and rm._)

$ find . -type f -user rat -exec rm {} \;

Archiving data

Compress the frauds file with tar to create frauds.tar.

$ tar cvf frauds.tar frauds

Extract the contents of the frauds.tar file.

$ tar xvf frauds.tar

Extract the crimes.tar.gz file.

$ tar xzvf crimes.tar.gz

Extract the diseases.tgz file.

$ tar xzvf diseases.tgz

Compress music.tar with the highest level of
[gzip](https://www.gnu.org/software/gzip/manual/gzip.html) compression. After
executing the command, the file created will be "music.tar.gz".

$ gzip -9 music.tar

Decompress hack.gz.

$ gzip -d hack.gz

Extract the entire pr0n archive, which has the .tar.bz2 extension.

$ tar xjvf pr0n.tar.bz2

Create png_archive.tar from the contents of png_directory - located in the
current directory.

$ tar cvf png_archive.tar ./png_directory

List (test) but do not extract any file from png_archive.tar.

$ tar tvf png_archive.tar

Extract only the dirty.png from png_archive.tar.

$ tar xvf png_archive.tar dirty.png

Unzip a file, named: "dresses.zip".

$ unzip dresses.zip

Miscellaneous utilities

Search for and display a string of characters "Drone Assassination" in
"cia.html" with [grep](http://www.gnu.org/savannah-
checkouts/gnu/grep/manual/grep.html). Below, "-i" = case insensitive.

$ grep -i "Drone Assassination" cia.html

Search for and display "Charles Manson" in every file residing under the
"prison" directory.

$ grep -r "Charles Manson" prison \;

Determine which partitions are currently mounted and print their sizes in a
human, understandable format.

$ df -h

Print the size of the contents of the "cracked" directory in a human,
understandable format.

$ du -sh cracked

Change the password. The user will be prompted for his current password, a new
password and the confirmation of the new password.

$ passwd

Inspect the memory usage, percentage of cpu resources consumed, programs
executed, etc. by the user "stinky" with [top](http://www.unixtop.org/).

$ top -u stinky

Display all of the processes spawned by the user "pinhead".

$ ps aux |grep pinhead

vi (visual editor) is the only text editor that a user needs to master.
Written in the 1970s by ultra-guru, Berkeley-grad, co-inventor of the TCP/IP
protocol, inventor of JAVA, etc. Bill Joy, vi is installed - by default - on
virtually every UNIX operating system. For an introduction, see:
<http://www.linfo.org/vi>.

$ vi joy.txt

Inspect the last screen of characters written to "log_file". Use tail to
monitor frequently updating files (e.g. logs) in real time.

$ tail -f log_file

Inspect the first screen of characters written to "crash.html" with more. Hit
the space bar to navigate downwards into the text.

$ more crash.html

links

     [TORring the net](http://soupksx6vqh3ydda.onion.city/tor_serv.html)
     [Nginx+Tor](http://soupksx6vqh3ydda.onion.city/nginx_onion.html)
     [Apache+Tor](http://soupksx6vqh3ydda.onion.city/apache_onion.html)
     [Lighttpd+Tor](http://soupksx6vqh3ydda.onion.city/lighttpd_onion.html)

