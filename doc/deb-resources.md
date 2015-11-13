**Is Linux right for you?**  
  
[About Debian**](http://www.debian.org/intro/about)  
  
The Debian Project is an association of individuals who have made common cause
to create a free operating system.  
This operating system that has been created is called Debian GNU/Linux, or
simply Debian for short.  
Debian is also known for its package management system and APT, the Advanced
Packaging Tool in particular,  
its strict policies regarding the quality of its packages and releases, and
its open development and testing process.  
These practices afford easy upgrades between releases without rebooting and
easy installation and removal of packages.  
  
[Debian Social Contract, Version
1.0](http://www.debian.org/social_contract#guidelines)  
"Debian, the producers of the Debian GNU/Linux system, have created the Debian
Social Contract.  
The Debian Free Software Guidelines (DFSG) part of the contract, initially
designed as a set of commitments  
that we agree to abide by, has been adopted by the free software community as
the basis of the [Open Source
Definition](http://www.opensource.org/docs/definition_plain.html)."  
  
**[How do I get Debian?**](http://www.debian.org/distrib/)  
Below are all of the various ways to download Debian, along with the
Installation Guides. The simplest way is using the netinstall.  
[Installing Debian GNU/Linux via the
Internet](http://www.debian.org/distrib/netinst)  
[Say goodbye to Microsoft today ...](http://goodbye-microsoft.com/)  
[Downloading Debian Which cds do I
need?](http://www.geocities.com/reverendsky/debianinstaller.html)  
[Debian -- Network install from a minimal
CD](http://www.debian.org/CD/netinst/)  
[New Features and other interesting stuff in Debian GNU/Linux 4.0
"Etch"](http://wiki.debian.org/NewInEtch)  
[DebianInstaller - DebianWiki](http://wiki.debian.net/?DebianInstaller)  
[Installing with the Debian-Installer](http://www.nl.debian.org/devel/debian-
installer/)  
[Debian Live](http://live.debian.net/index.html)  
[Debian GNU/Linux on CDs](http://www.debian.org/CD/)  
[Booting from floppy disks and installing using the
network](http://www.debian.org/distrib/floppyinst)  
[Debian GNU/Linux 3.1 (Sarge) -- Installation
Manual](http://www.debian.org/releases/stable/installmanual)  
[Debian Jigdo mini-HOWTO](http://www.tldp.org/HOWTO/Debian-Jigdo/index.html)  
[Downloading Debian CD images with jigdo](http://www.debian.org/CD/jigdo-
cd/#how)  
[Downloading Debian CD images with BitTorrent](http://www.debian.org/CD
/torrent-cd/)  
Buy the CDs from [Vendors of Debian CDs](http://www.debian.org/CD/vendors/)  
[Debian Media Cover/Label Generator](http://debian.semistable.com/cdcover.pl)  
[Debian Linux Installation & Getting
Started](http://www.linuxgazette.com/issue15/debian.html)  
  
**What is a Debian package?**  
**[Debian -- Packages**](http://www.debian.org/distrib/packages)   
[Debian Tutorial - Removing and installing
software](http://www.debian.org/doc/manuals/debian-tutorial/ch-dpkg.html)  
**["Overview of Debian packages"**](http://www.debian.org/doc/manuals/reference/ch-system.en.html#s-package-basics)  
  
Packages generally contain all of the files necessary to implement a set of
related commands or features. There are two types of Debian packages:  
    * Binary packages, which contain executables, configuration files, man/info pages, copyright information, and other documentation. These packages are distributed in a Debian-specific archive format; they are usually distinguished by having a '.deb' file extension. Binary packages can be unpacked using the Debian utility dpkg; details are given in its manual page.  
  
    * Source packages, which consist of a .dsc file describing the source package (including the names of the following files), a .orig.tar.gz file that contains the original unmodified source in gzip-compressed tar format and usually a .diff.gz file that contains the Debian-specific changes to the original source. The utility dpkg-source packs and unpacks Debian source archives; details are provided in its manual page.  
  
Installation of software by the package system uses "dependencies" which are
carefully designed by the package maintainers. These dependencies are
documented in the control file associated with each package.  
  
**_The good points about Debian Package handling_**:   
  
    * Installing a package doesn't require manual downloading.  
    * Installing a package automatically installs its dependencies.  
    * Single-command upgrading.  
    * Upgrading won't clobber config files without prompting.  
    * Purge (completely remove a package) vs Remove (don't delete config files).  
  
There are many different tools available in Debian to manage "packages", the
ones you use are entirely up to you.  
  
**_Package Management Tools_**  
  
**Text Based Tools**  
  
**[dpkg**](http://www.debian.org/doc/FAQ/ch-pkgtools.en.html)\- This is the main package management program. dpkg can be invoked with many options.  
  
**[Advanced Packaging Tool, or APT**](http://en.wikipedia.org/wiki/Advanced_Packaging_Tool) apt-get provides a simple way to install packages from the command line. Unlike dpkg, apt-get does not understand .deb files, it works with the packages proper name and can only install .deb archives from a source specified in /etc/apt/sources.list.  
Also take a look at [APT](http://wiki.linuxquestions.org/wiki/Apt) from
LinuxQuestions.org  
[Using the GPG signature checking with apt 0.6](http://www.debian-
administration.org/articles/174/print)  
**["APT HOWTO"**](http://www.debian.org/doc/manuals/apt-howto/index.en.html) Command Line package management HOWTO.  
  
**[Aptitude**](http://en.wikipedia.org/wiki/Aptitude) is a text-based interface to the Debian GNU/Linux package system. "It displays a list of software packages and allows the user to interactively pick packages to install or remove. Aptitude is based on the ncurses computer terminal library, with which it provides an interface that incorporates some elements commonly seen in graphical user interfaces (GUIs) (such as pull-down menus). It remembers which packages you deliberately installed and which packages were pulled in through dependencies; the latter packages are automatically de-installed by aptitude when they are no longer needed by any deliberately installed packages. It has advanced package-filtering features but these can be difficult to configure. [aptitude user's manual](http://doc2.inf.elte.hu/doc/aptitude/html/en/index.html)  
[ Using Aptitude together with Synaptic and Apt-
get](http://newbiedoc.berlios.de/wiki/Aptitude_-
_using_together_with_Synaptic_and_Apt-get)  
  
**[Wajig **](http://uclinux.info/wiki/index.php/Maintaining_a_Debian_box_with_Wajig) is an interface to many Debian administrative tasks. It consists of two interfaces: wajig is a command line interface and gjig is a [Gnome](http://www.gnome.org/) interface.  
  
**[apt-listbugs**](http://packages.debian.org/unstable/admin/apt-listbugs) is a tool which retrieves bug reports from the Debian Bug Tracking System and lists them. Especially, it is intended to be invoked before each upgrade/installation by apt in order to check whether the upgrade/installation is safe. Particularly useful if one is running Debian Unstable (Sid).  
      
  
**Graphical (GUI) Tools**  
  
**[Synaptic**](http://www.nongnu.org/synaptic/) is a graphical package management program for apt.  
 It provides the same features as the apt-get command line utility with a GUI
front-end based on Gtk+.  
    *  Install, remove, upgrade and downgrade single and multiple packages.  
    * Upgrade your whole system.  
    * Manage package repositories (sources.list).  
    * Find packages by name, description and several other attributes.  
    * Select packages by status, section, name or a custom filter.  
    * Sort packages by name, status, size or version.  
    * Browse all available online documentation related to a package.  
    * Download the latest changelog of a package.  
    * Lock packages to the current version.  
    * Force the installation of a specifc package version.  
    * Undo/Redo of selections.  
    * Built-in terminal emulator for the package manager.  
    * Debian only: Configure packages through the debconf system.  
  
**Gnome Package Manager** **[GDPM**](http://osx.freshmeat.net/projects/gdpm/)   
GDPM is a GNOME-based graphical manager for Debian packages. It aims to fully
replace the command-line tools apt-get, apt-cache, and dpkg by offering an
easy way to install, remove, upgrade, and browse Debian packages.  
  
**KDE Package Manager**  **[Kpackage**](http://packages.debian.org/stable/admin/kpackage)  
Kpackage is the KDE-based graphical frontend to both .rpm and .deb package
formats. It allows you to view currently installed packages, browse available
packages, and install/remove them.  
  
  
** Miscellaneous Tools**  
  
**[CheckInstall**](http://freshmeat.net/projects/checkinstall/) keeps track of all files installed by a "make install" or equivalent, creates a Slackware, RPM, or Debian package with those files, and adds it to the installed packages database, allowing for easy package removal or distribution.  
  
[gdebi](http://packages.debian.org/unstable/admin/gdebi) gdebi lets you
install local deb packages resolving and installing its dependencies. apt does
the same, but only for remote (http, ftp) located packages.  
  
**[Packagesearch**](http://packages.debian.org/stable/admin/packagesearch) This tool is aimed to help you search the packages you need. It should make the task of searching a pleasant experience. The new categorisation system "debtags" is supported. Search can be done by pattern, tags, files and installed status. Additionally a lot of information about the packages is displayed including the files belonging to them. The program is not meant to be a package managment tool like synaptic.  
  
**[Alien**](http://freshmeat.net/projects/alien/) converts between the rpm, deb, Stampede slp, and Slackware tgz file formats. If you want to use a package from another distribution than the one you have installed on your system, you can use alien to convert it to your preferred package format and install it.  
  
**[dselect**](http://www.debian.org/doc/FAQ/ch-pkgtools.en.html) \- This program is a menu-driven interface to the Debian package management system. It is particularly useful for first-time installations and large-scale upgrades.  
  
Another good place to look at how Debian Package Management works-
**[DebianWiki**](http://wiki.debian.net/?DebianPackageManagement)  
  
If you do not see a package that you want try searching **[apt-
get.org**](http://www.apt-get.org/). Once you find the package you are looking
for just add the repository to your source list at /etc/apt/sources.list. Run
apt-update or reload Synaptic and your all set.  
  
It is also a good idea to READ all of the
**[documentation**](http://www.debian.org/doc/) available from Debian.  
  
**_Helpful Debian GNU/Linux Websites_**  
[Window Managers for X](http://xwinman.org/)  
[The Debian Universe - installing, managing and running Debian
Gnu/Linux](http://www.debianuniverse.com/readonline/)  
[Debian/Ubuntu Tips & Tricks](http://www.debuntu.org/)  
[DebCentral - The Center for all things Debian based](http://debcentral.org/)  
[Debian - Not Just Another Pretty
Face](http://distrowatch.com/dwres.php?resource=review-debian2)  
[Unofficial #debian channel FAQ on freenode
(irc.debian.org)](http://www.linuks.mine.nu/debian-faq-wiki/)  
[Debian Planet - News for Debian](http://www.debianplanet.org/)  
[Debian GNU/Linux tips & tricks](http://www.linbyte.com/debian/)  
[Debian GNU/Linux Desktop Survival
Guide](http://www.togaware.com/linux/survivor/)  
[Unofficial "Debian Manual"](http://www.crazysquirrel.com/debian/index.php)  
[debiantutorials.org - A Debian GNU/Linux Desktop Tutorial
Site](http://www.debiantutorials.org/)  
[Learning Debian
GNU/Linux](http://www.oreilly.com/catalog/debian/chapter/book/index.html)  
[Debian - ArsLinuxWiki](http://wiki.arslinux.com/Debian)  
  
**Find packages not in official repositories at**  
[Apt-Get.org](http://www.apt-get.org)  
[Debian Backports](http://www.backports.org/)  
[Debian Unofficial Packages](http://debian-unofficial.org/)  
[Debian Project](http://debianlinux.net/debian.html)  
[os-cillation - XFCE Up-to date Debian Packages](http://www.os-
works.com/view/debian/)  
[Chris Marillat's Unofficial Debian Packages](http://www.debian-
multimedia.org/)  
[Unofficial Debian packages at kirya.net](http://packages.kirya.net/)  
[OpenOffice.org in Debian](http://openoffice.debian.net/)  
  
**_Official Debian Information_**  
[Debian -- The Universal Operating System](http://www.debian.org/)  
[Reasons to Choose Debian](http://www.debian.org/intro/why_debian)  
[Securing Debian Manual](http://www.debian.org/doc/manuals/securing-debian-
howto/)  
[Security Information](http://www.debian.org/security/) Keep up to date.  
[ Debian -- Mailing Lists](http://www.debian.org/MailingLists/) A great way to
stay in the loop  
[Debian GNU/Linux FAQ](http://www.debian.org/doc/user-manuals#faq)  
[Debian Documentation](http://www.debian.org/doc/)  
[Debian Weekly News](http://www.debian.org/News/weekly/)  
[Debian Developers' Corner](http://www.debian.org/devel/)  
  
**_HOWTos_**  
[Using Debconf to configure a
system](http://www.linux.com/article.pl?sid=06/05/26/1630200)  
[How to Install Debian From
Scratch](http://linux.suramya.com/tutorials/Install_DFS/)  
[Howto Debian- MadWifi -
Wireless](http://madwifi.org/wiki/UserDocs/Distro/Debian/MadWifi)  
[Installing Gnome](http://wiki.debian.net/?DebianGnome)  
[Installing KDE](http://wiki.debian.net/?KdeDebInstall)  
[The Debian KDE team ](http://pkg-kde.alioth.debian.org/docs/)  
[Debian GNOME package status ](http://pkg-gnome.alioth.debian.org/package-
status.html)  
[Debian Xfce Group](http://pkg-xfce.alioth.debian.org/)  
[Debian | ROX Desktop](http://rox.sourceforge.net/desktop/node/86)  
[ChatZilla on Debian
XULRunner](http://chatzilla.rdmsoft.com/xulrunner/debian/)  
[apt-build - Optimize Debian packages for your
system](http://julien.danjou.info/article-apt-build.html)  
[Creating custom kernels with Debian's kernel-package
system](http://newbiedoc.sourceforge.net/system/kernel-pkg.html)  
[Upgrading Debian GNU/Linux from Sarge to
Etch](http://wiki.debian.org/Sarge2EtchUpgrade)  
[How To Install XGL on Debian Etch by
sonique](http://sonique54.free.fr/xgl/xgl.htm)  
[ Getting Wine for a Debian System](http://www.sdconsult.no/linux/wine-doc
/getting-dist-debian.html)  
[TrueType Fonts on Debian XFree86 4.x
Systems](http://www.paulandlesley.org/linux/xfree4_tt.html)  
[AptPinning - DebianWiki](http://wiki.debian.net/index.cgi?AptPinning)  
[Apt-Pinning for Beginners](http://jaqque.sbih.org/kplug/apt-pinning.html)  
[FAI Guide (Fully Automatic Installation)](http://www.informatik.uni-
koeln.de/fai/fai-guide.html/index.html#contents)  
[Debian and Windows Shared Printing mini-
HOWTO](http://excess.org/docs/linux_windows_printing.html)  
[Debian Reference - Printing](http://www.debian.org/doc/manuals/reference/ch-
install.en.html#s-printer)  
[Debian GNU/Linux Reference Card](http://people.debian.org/~debacle/refcard/)
The 101 most important things when using Debian GNU/Linux.  
[Debian X Window System
FAQ](http://necrotic.deadbeast.net/xsf/XFree86/trunk/debian/local/FAQ.xhtml)  
[ How To Set Up A Debian Linux
Firewall](http://www.aboutdebian.com/firewall.htm)  
  
**_Browser plugins_**  
**Sun's Java is now available in the Official non-free repositories.**  
[TorOnDebian - How to install Tor in
Debian](http://wiki.noreply.org/noreply/TheOnionRouter/TorOnDebian)  
For detailed help with Firefox plugins see: [Firefox Tips for Windows and
GNU/Linux](http://www.geocities.com/reverendsky/firefoxtips.html)  
[Debian MPlayer How-To](http://www.princessleia.com/MPlayer.html)  
Flash and can be installed via apt and the "official" Debian repositories.  
Make sure you have contrib nonfree. apt-get install flashplugin-nonfree  
To install Adobe Reader add one of the Marillat repository then apt-get
install acroread  
RealPlayer can be installed by using apt-get realplayer  
# Marillat Repository mplayer, acroread, RealPlayer 10.0.4 ,acroread-plugin,
acroread-plugins,lame,mozilla-acroread  
# Use your release i.e. stable,testing,unstable  
#deb http://www.debian-multimedia.org  main  
#deb http://www.debian-multimedia.org  main  
# Experimental  
# deb http://www.debian-multimedia.org experimental main  
The easiest way to listen to multimedia online is by using either Mplayer and
mozilla-mplayer or Kaffeine and kaffeine-mozilla.  
  
**_Where to go for help/support_**  
[Debian -- Support](http://www.debian.org/support)  
[LinuxQuestions.org - Where Linux users come for
help](http://www.linuxquestions.org/)  
[debianHELP Militantly FREE software support](http://www.debianhelp.org/)  
[DebCentral - The Center for all things Debian based](http://debcentral.org/)  
[Debian User Forums](http://forums.debian.net/index.php)  
[Linux Forums - Where People Come For Linux Help
!](http://www.linuxforums.org/forum/)  
[ On-line Real Time Help Using IRC](http://www.debian.org/support#irc)  
Getting Help - [Debian And Linux
Resources](http://www.aboutdebian.com/resource.htm)  
[Linux Users Groups WorldWide](http://lugww.counter.li.org/index.cms)  
  
![My status](http://mystatus.skype.com/bigclassic/craigevil) **If you need
help feel free to skype me**  
** sidux gnu/linux ... giving choice to the neXt generation **  
  

Protect your freedom!](http://www.defectivebydesign.org/join/button)

  
My Favorite and recommended Browser: [My Firefox/Iceweasel
Info](http://www.geocities.com/reverendsky/infolister.html)  
[Check out Skype](http://share.skype.com/in/102/285947)  

