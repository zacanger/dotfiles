====== Debian basics ======

We noticed that not only Debian-users like Grml but also people coming from the BSD-section, Gentoo-Linux and so on. You don't need any Debian knowledge to use Grml, but if you would like to use the package management you should know some basics. The following table provides a comparison of the package management of Debian compared with some other well known package management systems:    

===== Package management of *nix =====

^ Action ^ Debian ^ Gentoo ^ RPM ^ OpenBSD ^ BSD Ports ^
| useful tools | ''apt-file'' | ''app-portage/esearch, app-portage/portage-utils, app-portage/gentoolkit, app-portage/eix'' | yum, rpmbuild | ... | ... |
| search for foobar | ''apt-cache search foobar'' | ''emerge search foobar or esearch foobar'' | ''yum search foobar'' | ''grep foobar index.txt'' | ''cd /usr/ports/ && make search key=foobar'' |
| show all packages that match 'pattern' | ''dpkg -S pattern'' | ''qfile pattern or equery b(elongs) pattern'' | ''yum whatprovides pattern or repoquery ––whatprovides pattern'' | ''grep foobar index.txt'' | ''cd /usr/ports/ && make search key=foobar'' |
| list files in installed $package | ''dpkg -L $package'' | ''qlist $package or equery f(iles) $package'' | ''rpm -q --list $package'' | ''pkg_info -L $package'' | ... |
| list files in local $package | ''dpkg -c $package.deb'' | ... | ''rpm -qpl $package.rpm'' | ... | ... |
| show description of $package |''apt-cache show $package'' | eix -S $package | ''rpm -qpi $package'' | ''pkg_info $package'' | ... |
| show dependencies of $package |''apt-cache depends $package'' | ''emerge -pv $package'' | ''rpm -qpR $package'' | ''pkg_info -r $package '' | ... |
| show reverse dependencies of $package| ''apt-cache rdepends $package'' | ''equery d(epends) $package (1) or qdepends -a $package'' | ... | ''pkg_info -k $package'' | ... |
| show policy for $package | ''apt-cache policy $package'' | ''emerge search $package'' | ... | ''pkg_info $package'' | ... |
| update list of packages (/etc/apt/sources.list) | ''apt-get update'' | ''emerge sync (or esync, also rebuilds index for esearch)'' | ''rpm --rebuilddb'' | ''wget ftp://ftp.openbsd.org/release/packages/`arch`/index.txt'' | ... |
| upgrade software | ''apt-get upgrade'' | ''emerge -u foobar'' | ''rpm -U $package'' | ''pkg_add -r $package'' | ... |
| simulate upgrade | ''apt-get -s upgrade'' | ''emerge -pvut foobar'' | ... | ''(before replacing, it is always simulated)'' | ... |
| simulate installation of package | ''dpkg -i --no-act $package.deb'' | emerge -pv $package | ''rpm -i --test $package.rpm'' | ... | ... |
| upgrade the distribution (including dependencies) | ''apt-get dist-upgrade'' | ''emerge -uD world'' | ... | ''run install ISO or Download all Install sets to the local HDD and move the new "bsd.rd" to /bsd. After the reboot choose "upgrade" and install the install sets from HDD. After the installation use pkg_add -u to upgrade your installed software too.'' | ... |
| install $package | ''apt-get install $package'' | ''emerge $package'' | ''rpm -i $package'' | ''pkg_add $package''  | ''cd /usr/ports/<category>/<package> && make install [clean]'' |
| install a specific version of $package | ''apt-get install $package=version'' | ''emerge =$package-version'' | ... | ''version info is contained in package name'' | ... |
| install $package from specific release | ''apt-get -t release install $package'' | ''edit /etc/portage/package.keywords'' | ... | ''fetch another index.txt from a different release (it is NOT recommented to use Versions for another release)'' | ... |
| remove $package | ''apt-get remove $package'' | ''emerge -C $package'' | ''rpm -e $package'' | ''pkg_delete $package'' | ... |
| remove $package and purge configuration files | ''apt-get --purge remove $package'' | ''CONFIG_PROTECT="" emerge -C $package'' | ... | ''that is the default'' | ... |
| reinstall $package | ''apt-get --reinstall install $package'' | ''emerge $package'' | ''rpm -U --force $package'' | ''pkg_add -r $package'' | ... |
| download .deb files of $package | ''apt-get --download-only install $package'' | ... | ... | ''wget `grep pkgname index.txt`'' | ... |
| download source of $package | ''apt-get source $package'' | ''emerge -f $package'' | ... | ''cd /usr/ports/<category>/<package> && make fetch'' | ... |
| install debian package | ''dpkg -i $package.deb'' | ... | ''rpm -i $package'' | ''pkg_add $package'' | ... |
| show installed and removed packages | ''dpkg -l'' | ''qlist -I -v'' | ''rpm -qa'' | ''ls /var/db/pkg/'' | ... |
| show status of $package | ''dpkg -l $package'' | eix $package | ... | ''pkg_info $package'' | ... |
| show all packages that match 'pattern' | ''dpkg -S pattern'' | ''emerge search foo or qsearch foo or esearch foo'' | ''rpm -qa PIPE grep pattern'' | ''grep pattern index.txt'' | ... |
| re-run the configuration for $package | ''dpkg-reconfigure $package'' | ... | ... | ''vi /usr/local/etc/<package>.conf'' | ... |
| show update status | ''apt-get [dist-]upgrade'' | ... | ... | ''pkg_version $package'' | ... |

(1) list all direct dependencies matching pkgspec

Another frontend and easy to handle system to the debian package management is the ncurses based 'aptitude'. 'aptitude' can also be used in a console-oriented way (like apt-get). Just replace 'apt-get' in the above commands with 'aptitude'. As of Debian Sarge this is even the prefered way to install and upgrade packages, as 'aptitude' is better in handling dependencies.

For handling /etc/apt/sources.list take a look at the [[http://www.debian.org/doc/manuals/apt-howto/ch-basico.en.html|apt-howto basics]], for further information on package management read [[http://www.debian.org/doc/manuals/apt-howto/ch-apt-get.en.html|chapter 3 of apt-howto]].



===== Using the grml-repository =====

See [[http://grml.org/files/|grml.org/files/]] for instructions how to use the grml-repository. You can use the grml-repos even if you don't use a grml-system but any other Debian system. With introduction of [[http://www.debian.org/doc/manuals/securing-debian-howto/ch7.en.html#s-apt-0.6|apt-0.6]] it's possible to check integrity of the packages. The following warnings will disappear then:

<code>
W: GPG error: http://deb.grml.org grml-stable Release:
The following signatures couldn't be verified because the public key is not available: NO_PUBKEY F61E2E7CECDEA787
WARNING: The following packages cannot be authenticated!
</code>

For the grml-repository just run:

<code>
apt-get --allow-unauthenticated install grml-debian-keyring
</code>

or:

<code>
gpg --keyserver subkeys.pgp.net --recv-keys F61E2E7CECDEA787
gpg --export F61E2E7CECDEA787 > /etc/apt/grml.key
apt-key add /etc/apt/grml.key
</code>

Or if you do not want to store the key in a file:

<code>
gpg --keyserver subkeys.pgp.net --recv-keys F61E2E7CECDEA787
gpg --export F61E2E7CECDEA787 | apt-key add -
</code>

Or even simpler, in one line:

<code>
apt-key adv --keyserver subkeys.pgp.net --recv-keys F61E2E7CECDEA787
</code>

===== Links/Resources =====

==== General ====
  * [[http://www.debian.org/|Debian.org]]
  * [[http://www.apt-get.org/|apt-get.org]]   
  * [[http://www.backports.org/|backports.org]]
  * [[http://snapshot.debian.net/|snapshot.debian.net]]
  * [[https://alioth.debian.org/|alioth.debian.org]]
  * [[http://debaday.debian.net/|debaday]]

  * [[http://planet.debian.net/|planet.debian.net]]
  * [[http://www.debianplanet.org/|debianplanet.org]]
  * [[http://www.debianhelp.co.uk/|debianhelp.co.uk]]
  * [[http://www.debian-administration.org/|debian-administration.org]]

==== Getting help ====
  * [[http://channel.debian.de/faq/index.html|#debian.de FAQ]]
  * [[http://debianforum.de|debianforum.de]] -- German Forum
  * [[http://dugfaq.sylence.net/|dugfaq]]   
  * [[http://www.debianhelp.org/|debianhelp.org]]
  * [[http://lists.debian.org/|mailinglists]]

==== Packages/Bugs ====
  * [[http://packages.debian.org/|packages.debian.org]]
  * [[http://www.debian.org/distrib/packages|Debian-Pkg.]]
  * [[http://dehs.alioth.debian.org/|Health Status]]
  * [[http://packages.qa.debian.org/common/index.html|Package Tracking System]]
  * [[http://bugs.debian.org/|Bug Tracking System]]
  * [[http://bugs.debian.org/release-critical/|critical bugs]]
  * [[http://bugs.debian.org/cgi-bin/pkgreport.cgi?severity=serious|serious bugs]]
  * [[http://bugs.debian.org/cgi-bin/pkgreport.cgi?severity=grave|grave bugs]]

==== Developers ====
  * [[http://www.debian.org/devel/|Debian Developers' Corner]]
  * [[http://www.debian.org/doc/manuals/maint-guide/index.en.html|Debian New Maintainers' Guide]]
  * [[http://www.debian.org/doc/manuals/reference/reference.de.html|Debian Reference]]
  * [[http://www.debianhowto.de/|DebianHowto.de (german)]]