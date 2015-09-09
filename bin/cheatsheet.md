<!-- [fuck][0] -->

# get external ip
curl http://ipecho.net/plain

# cheat\_sheet.org.sh

# The contents of this file are released under the GNU General Public License. Feel free to reuse the contents of this work, as long as the resultant works give proper attribution and are made publicly available under the GNU General Public License.

# Best viewed in emacs org-mode.

# Alternately, one can keep this cheat sheet handy by adding the following line to ~/.bashrc:

\#

# alias cheatsheet="less ~/path\_to\_cheat\_sheet.org.sh"

*   Reference:  
    **Basics:  
    \*** Getting help:
    

# View the manual for target command

man command

# Get help with a target command (probably the same as above, but not always):

command -h

# In case you forget the name of a command, print possible commands relating to any given word:

apropos word

# View index of help pages:

info

**_Command Line Utilities:  
\*_** Basic File and Directory Operations:

# Print current working directory:

pwd

# Show files in current directory:

ls

# Show maximum information about all files, including hidden:

ls -a

# Recurse into subdirectories and list those as well:

ls -R

# List files by modification time, most recent first.

ls -lt

# Move/rename a file or directory (be careful that you don't move the source over a destination with the same name):

mv source destination

# Delete target forever (be very careful), use -r recursive flag for directories:

rm target

# Copy file or directory:

cp source destination

# Mount filesytem:

mount /dev/device\_name /media/device\_name

# Unmount:

umount /media/device\_name

# Forensically clone filesystems and do other low-level operations on files. Be careful with this one. Can be destructive:

dd

# Work with disk partitions:

parted

# Filesystem creation tool:

mkfs

_\*\*_ System Administration:

# Execute command as an administrator (can be destructive/insecure. Use only for system administration tasks):

sudo command

# Become system administrator:

sudo -s

# Quit system administration:

exit

# Forgot to type sudo in front of a command and already hit enter? Repeat the last command using sudo:

sudo !!

**\*** Installing software from a .tgz (also known as a tarball):

# First, unzip the tarball (see section on tar, below)

# Next, move into unzipped directory:

cd software\_directory

# Always read README first if it is provided, in case there are any modifications to the procedure outlined below:

cat README

# Automatically check for appropriate configurations and generate a MAKE file in the directory:

./configure

# Compile software. May require sudo:

make

# Move files into their appropriate locations. May also require sudo:

make install

# Clean up files in directory, in case make command fails, or just to remove unnecessary cruft:

make clean

**\*** Ubuntu/Debian Software repositories:

# Check distro repositories for software updates:

sudo apt-get update

# Download and install updates (update first):

sudo apt-get upgrade

# Search for package in the repositories:

apt-cache search keyword

# Get more detail on one specific package:

apt-cache show package\_name

# Download and install a package:

sudo apt-get install package\_name

# View the output of a command in a more convenient format:

command | less

_\*\*_ Working With Files:

# Print a file in terminal:

cat file

# Find files matching filename:

locate filename

# See the version of a program or the location of the program

which appname

# Search through filename for matches to phrase:

grep phrase filename

# Search through output of a command for phrase:

command | grep phrase

_\*\*_ Working With Processes:

# List all running processes:

ps -e

# Standard system monitor showing a more extensive view of all processes and system resources:

top

# Like top, but with a better, cleaner interface:

htop

# Stop a process from using all system resources and lagging computer:

renice process\_name

# Kill misbehaving process (use sparingly, last resort, try 'renice' command first):

pkill process name

# Start a process in the background

command &

# Start a process in the background and have it keep running after you log off

nohup command &

_\*\*_ Compression and Encryption:

# Make a simple compressed backup of files or directories:

tar -cvzf backup\_output.tgz target\_files\_or\_directories

# Open a compressed .tgz or .tar.gz file:

tar -xvf target.tgz

# Encrypt a file:

gpg -o outputfilename.gpg -c target\_file

# Decrypt a file:

gpg -o outputfilename -d target.gpg

# Zip and encrypt a directory simultaneously:

gpg-zip -o encrypted\_filename.tgz.gpg -c -s file\_to\_be\_encrypted

**_The Bash shell:  
\*_** File Name expansions:

# Current user's home directory:

~/

# Current directory:

./

# Parent directory:

../

# Or even (Two parent directories down):

../../

# All files in target directory. (Be very careful.):

/\*

_\*\*_ Output Redirects:

# Redirect output of one command into the input of another with a pipe:

command\_1 | command\_2

# Or even:

command\_1 | command\_2 | command\_3

# Redirect output to a file:

command \> file

# Or:

file \> file

# Or even, to redirect in a different direction:

file < file

# Append output rather than writing over the target file:

file\_or\_command \>\> file

# Works like |, but it writes output to both target and terminal:

tee target

# Redirect standard output and error to /dev/null, where it is deleted.

command \> /dev/null 2\>&1

_\*\*_ Controlling Execution:

# Wait until command 1 is finished to execute command 2

command\_1 ; command\_2

# Or even:

command\_1 ; command\_2 ; command\_3

# && acts like ; but only executes command\_2 if command\_1 indicates that it succeeded without error by returning 0\.

command\_1 && command\_2

# || acts like && but only executes command\_2 if command\_1 indicates an error by returning 1\.

command\_1 || command\_2

_\*\*_ Bash Wildcards:

# Zero or more characters:

\*

# Matches "phrase" and any number of trailing characters:

phrase\*

# Matches any incidences of "phrase" with any trailing or leading chars:

_phrase_

# Matches any one char:

?

# Matches any of the characters listed inside brackets:

\[chars\]

# Matches a range of chars between a-z:

\[a-z\]

**Advanced:  
\*** Command Line Utilities, Continued:  
_\*\*_ Networking:

# Configure network interfaces:

ifconfig

# Configure wireless network interfaces:

iwconfig

# Connect to a remote server.

ssh username@ip\_address

# Forward X from target to current machine (Get a remote desktop. Somewhat obscure, but very useful):

ssh -X username@ip\_address

# Copy files/directory over the network from one machine to another recursively:

scp -r source\_filename:username@ip\_address target\_filename:target\_username@target\_ip\_address

# Copy only changes between files or directories (super efficient way to sync directories, works either locally or with remote servers using username@ip\_address:optionalport, just like ssh):

rsync source target

# Check to see if target is online and responding

ping ip\_address

# View network route to target:

traceroute6 ip\_address

# Network Monitor

netstat

# View firewall rules

iptables -L

# Scan this machine(localhost) to check for open ports:

nmap localhost

**\*** wget:

# download a file over http:

wget [http://example.com/folder/file][1] 

# complete a partially downloaded file:

wget -c [http://example.com/folder/file][1]

# start download in background:

wget -b wget -c [http://example.com/folder/file][1]

# download a file from ftp server:

wget --ftp-user=USER --ftp-password=PASS ftp://example.com/folder/file

**\*** netcat:

# Listen for input from network on recieving\_port, dump it to a file (insecure, but handy):

netcat -l recieving\_port \> file\_copied

# Pipe the output of a command to a target ip and port over the network:

command | netcat -w number\_of\_seconds\_before\_timeout target\_ip target\_port

# Use tar to compress and output a file as a stream, pipe it to a target ip and port over the network:

sudo tar -czf - filename | netcat -w number\_of\_seconds\_before\_timeout target\_ip target\_port

_\*\*_ Users and Groups:

# Change owner of a file or directory:

chown user\_name:group\_name directory\_name

# Change privileges over file or directory (see man page for details.)

chmod

# Create a new user:

adduser

# Change user privileges (be very careful with this one):

usermod

# Delete user

deluser

# Print groups:

groups

# Create a new group:

groupadd

# Change group privileges:

groupmod

# Delete group:

delgroup

# Temporarily become a different user:

su username

# Print usernames of logged in users:

users

# Write one line to another user from your terminal:

talk

# Interactive talk program to talk to other users from terminal (must be installed from repositories.):

ytalk

_\*\*_ Working With Files, Continued:

# View what processes are using what files:

lsof

# View the differences between two files:

diff file\_1 file\_2

# Output the top number\_of\_lines of file:

head -n number\_of\_lines file

# Like head, but it outputs the last -n lines:

tail -n number\_of\_lines file

# Checksum a file:

md5sum file

# Checksum every file in a directory (install this one from repositories.):

md5deep directory

# Checksum a file (better algorithm with no hash collisions):

sha1sum

# Same operation as md5deep, but using sha1:

sha1deep

# Call command every few number\_of\_seconds, and highlight difference in output:

watch -d -n number\_of\_seconds command

# Execute command, print how long it took:

time command

# View files in directory from largest to smallest:

du -a directory | sort -n -r | less

# remove spaces from filenames in current directory:

rename -n 's/\[\\s\]/''/g' \*

# change capitals to lowercase in filenames in current directory:

rename 'y/A-Z/a-z/' \*

**\*** Environment and Hardware:

# print motherboard information

dmidecode

# Print full date and time:

date

# Print the hostname of this machine:

echo $HOSTNAME

# Print information about current linux distro:

lsb\_release -a

# Or even:

more /etc/issue

# Print linux kernel version:

uname -a

# Print information about kernel modules:

lsmod

# Configure kernel modules (never do this ;p ):

modprobe

# View Installed packages:

dpkg --get-selections

# Print environment variables:

printenv 

# List hardware connected via PCI ports:

lspci

# List hardware connected via USB ports:

lsusb

# Print hardware info stored in BIOS:

sudo dmidecode

# Dump captured data off of wireless card:

dumpcap

# Dump info about keyboard drivers:

dumpkeys

**\*** Ubuntu System Administration, Advanced (Continued):

# Add a Personal Package Archive from Ubuntu Launchpad:

add-apt-repository

# Install a .deb file from command line:

sudo dpkg -i package.deb

_\*\*_ Python:

# Update pip (Python package manager):

pip install -U pip

# search pip repos for a library:

pip search library\_name

# create a virtual python environment to allow install of many different versions of the same Python modules:

virtualenv dirname --no-site-packages

# connect to a virtual python environment

source dirname/bin/activate

# disconnect from a virtual python environment:

deactivate

# install package into virtual python environment from outside:

pip install packagename==version\_number -E dirname

# export python virtual environment into a shareable format:

pip freeze -E dirname \> requirements.txt

# import python virtual environment from a requirements.txt file:

pip install -E dirname -r requirements.txt

_\*\*_ git (all commands must be performed in the same directory as .git folder):

# Start a new git project:

git init

git config user.name "user\_name"

git config user.email "email"

# Make a copy of a git (target can be specified either locally or remotely, via any number of protocols):

git clone target

# Commit changes to a git:

git commit -m "message"

# Get info on current repository:

git status

# Show change log for current repository:

git log

# Update git directory from another repository:

git pull \[target\]

# Push branch to other repository:

git push \[target\]

# Create a new branch:

git branch \[branchname\]

# Switch to target branch:

git checkout \[branchname\]

# Delete a branch:

git branch -d \[branchname\]

# Merge two branches:

git merge \[branchname\] \[branchname\]

# Show all branches of a project:

git branch

_\*_ Virtualization:

\#clone a virtual machine (this works, it's been tested):  
vboxmanage clonehd virtual\_machine\_name.vdi --format VDI ~/target\_virtual\_machine\_name.vdi

\#mount a shared virtual folder:

\#you need to make sure you have the right kernel modules. You can do this with modprobe, but this package works instead in a ubuntu-specific way.

sudo apt-get install virtualbox-ose-guest-utils

sudo mount -t vboxsf name\_of\_shared\_folder\_specified\_in\_Virtualbox path\_of\_mountpoint

_\*_ mysql:

# Get help:

help

# Show databases:

show databases;

# Choose a database to use:

use database\_name\_here;

# Show database schema:

show tables;

# Delete database:

DROP DATABASE databasename;

# New database:

CREATE DATABASE databasename;

# Create a new user:

CREATE USER username@localhost IDENTIFIED BY 'password';

# Show users:

select \* from mysql.user;

# Delete a user:

delete from mysql.user WHERE User='user\_name';

# Give user access to all tables (make them root). the "%" means that they can sign in remotely, from any machine, not just localhost.:

grant all privileges on _._ to someusr@"%" identified by 'password';

# give certain privileges to a user on a certain database:

grant select,insert,update,delete,create,drop on somedb.\* to someusr@"%" identified by 'password';

# Tell mysql to use new user priv policies:

flush privileges;

# change user password:

use mysql;

update user set password='password'('newpassword') where User='user\_name';

# mysql command line args:

# export text file with commands to rebuild all mysql tables:

mysqldump databasename \> dumpfilename.txt

# restore from a dump:

mysql -u username -p < dumpfilename.txt

# dump entire database:

mysqldump -u username -p --opt databasename \> dumpfile.sql

# restore from entire database dump:

mysql -u username -p --database=databasename < dumpfile.sql

