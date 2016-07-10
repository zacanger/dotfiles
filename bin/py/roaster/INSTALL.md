Making Roaster Run Everywhere
=======

Due to the simple nature and design concepts related to Roaster, it should be within reason to run it on many different GNU/Linux distributions.  It is written as a single python script, and as long as a few imports are met, it should be able to be set up to function as intended.

If you note the "import" lines, we're pulling in a few files that are necessary.  python-gtk, pango, python-webkit, urllib, python-simplejson, python-gobject, and config parser.  If using a package manager, then you should be able to simply search out the most/more recent versions of said packages from your repositories and allow the package manager to maintain them for you.  It is now being built on and tested using Debian sid, but any feedback from other distributions is welcome.

Python is also required to use it...as it's a python script.  I would assume this to be obvious, but I've often been surprised in these regards.

One of the more complicated manners is that it is being developed with an intentional integration with links2.  The file controlling the bookmarks is actually native to links2.  This file should be located at ~/.links2/bookmarks.html.  If you wish to use Roaster without installing links2 (which is a good cli-based browser, always good if X won't start), then you will need to create this file for bookmarking to function.

From the terminal, this is easy:
```
mkdir ~/.links2
cd ~/.links2
touch bookmarks.html
```

Also, it is necessary to migrate the .roaster.conf file into the user's home directory, or into /etc/and save it simply as roaster.conf (without the "." in front of it).  The local user's file will take precendence over the global one.  It's important to note that the file inside the git directory (or tarball, if you pull it using the web interface) is preceded by a "."  So, you'll have to enable viewing hidden files in you file manager, or list it with "ls -a".  

Since many configuration options are used on a global scale, I'd leave the ones that you don't wish to customize.  Trying to clean things up ini the config is an effort in futility, and will lead to breakage.   

If you have questions about installing (and I use that word loosely), then feel free to shoot me an email at <DebianJoe@linuxbbq.org> or simply stop by the forums and ask for help.  There are tons of systems that I cannot possibly test it on myself, so the feedback would be appreciated.

Regards,
Joe
