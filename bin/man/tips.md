====== Tips and Tricks ======

You have a tip you think might be useful for other grml-users? Please document it! **Don't forget to add your contact information so we can contact you if we think your tip might be useful for integration into official documents!** Sonu 09255164555

===== grml-tips =====

Starting with grml 0.6 and grml-small 0.2 a script named 'grml-tips' is available on the live-CD. Just run 'grml-tips $KEYWORD' to get tips, tricks and useful hints on $KEYWORD.


===== Switch language/keyboard =====

If you want to change the keyboard layout (default is us) use the bootparam "lang". For example boot with "grml lang=de" to activate german keyboard and settings ($LANG, $LC_...). If you have a running grml-system and want to switch between german and english use "grml-lang", for example "grml-lang de" to switch to german settings. Take a look at the [[http://grml.org/faq/#language|language section in the FAQ]] for more details.

If you want to change the default keyboard layout, you just have to append (really append it! Does not work if it is the first argument in the APPEND-Line!) "lang=de" to the APPEND line in syslinux.cfg/isolinux.cfg 


===== Boot grml via floppy disk =====

Your computer can not boot from CD-ROM but provides a floppy disk? Take a look at [[http://ubcd4win.com/faq.htm#floppy|ubcd4win]], [[http://linux.simple.be/tools/sbm|Smart Boot Manager]] or [[http://www.plop.at/en/bootmanager.html|Plop Boot Manager]], they provide support for booting from CD-ROM via a special floppy disk.

===== Mount USB-stick =====

If your **usb-stick** has a partition like /dev/sda1 just use 'mount /mnt/external1' to mount it. 'mount /mnt/external' corresponds to /dev/sda. [Tip by [[http://grml.org/team/|mika]]]

===== Install (plain) Debian via Grml =====

It is possible to install a plain(!) Debian system via Grml. This might be useful for example if Debian does not boot on your hardware but Grml does. This is possible via running [[http://grml.org/grml-debootstrap/|grml-debootstrap]]. [Tip by [[http://grml.org/team/|mika]]]

===== grml as AFS client =====

With the next three lines you could activate the OpenAFS functions within grml 0.6. The krb5 is needed for the cells with krb5-auth. The krb5 is NOT fully integrated, e.g. no krb5-capable ssh.
First create the afs cache as a ramdisk. After this you configure the krb5 realm and after that you configure OpenAFS with your cell name and your databaseservers for that cell. Please activate the freelancer mode, it makes accessing other cells easier.

<code>
prepare_ramdisk.sh /var/cache/openafs start
dpkg-reconfigure krb5-config
dpkg-reconfigure openafs-client
</code>

After this two steps you should be able to obtain valid krb5 tickets and should be able to access various afs cells. Maybe a aklog tells you it can't find the correct cell. 

<code>
aklog -d -cell cell.name.tld -k KRB5.REALM.TLD
</code>

Is the correct term for aklog to obtain a valid OpenAFS-token after obtaining a valid krb5-ticket.

Notice: grml 0.7 ships the openafs kernel module named libafs as used by upstream (reason: Debian kernel source package wasn't useable for kernel 2.6.16 at time of release). A symlink lets you use 'modprobe openafs' as well as 'modprobe libafs', but the kernel module registers itself as 'libafs' so you have to run 'rmmod libafs' to remove it.

===== grml and vmware =====

Probing of IDE-devices by the kernel might last long (tested with vmware 5.0.0), see relevant output of dmesg:

<code>
ide1: BM-DMA at 0x1458-0x145f, BIOS settings: hdc:DMA, hdd:pio
Probing IDE interface ide1...
hdc: VMware Virtual IDE CDROM Drive, ATAPI CD/DVD-ROM drive
ide1 at 0x170-0x177,0x376 on irq 15
Probing IDE interface ide0...
Probing IDE interface ide2...
Probing IDE interface ide3...
Probing IDE interface ide4...
Probing IDE interface ide5...
hdc: ATAPI 1X CD-ROM drive, 32kb Cache, UDMA(33)
</code>

So in this case only ide is relevant. Let's skip probing of the other ide-devices via kerneloption ide?=noprobe. Usage example:

grml ide0=noprobe ide2=noprobe ide3=noprobe ide4=noprobe ide5=noprobe

[Tip by [[http://grml.org/team/|mika]]]

===== Boot grml without CD =====

Besides the possibilities to boot grml from CD, USB/Firewire device or via network using [[http://grml.org/terminalserver/|grml-terminalserver]] you can boot a grml-ISO from your harddisk as well.

* Copy the grml-ISO to a partition on your harddisk (e.g. hda5):
<code>
grml tohd=/dev/hda5
</code>

* Reboot to your Linux box and create a directory named grml in /boot of your linux partition ('mkdir /boot/grml').

* Copy the files "linux26" and "minirt26.gz" from grml_CD/boot/isolinux to /boot/grml/.

* Adjust your bootloader.

  * Example for Grub: add an entry for grml to /boot/grub/menu.lst:
<code>
# this entry boots grml from iso_image  on /dev/hda5
title   Grml
root  (hd0,4)
kernel  /boot/grml/linux26 fromhd=/dev/hda5 ramdisk=100000
initrd  /boot/grml/minirt26.gz
</code>

  * Example for /etc/lilo.conf:
<code>
image=/boot/grml/linux26
  append="fromhd=/dev/hda5 ramdisk=100000"
  label=Grml
  initrd=/boot/grml/minirt26.gz
</code>

* That's it. Reboot and pick Grml from the bootloader.

[Tip by boulhian and [[http://grml.org/team/|mika]]]

===== Reinstall all packages =====

For example on the heavily stripped down grml-small it might be useful to reinstall all (already installed) packages. Just start aptitude, get the cursor over the "Installed Packages" category and press Shift-L and run update/upgrade afterwards. [Tip by [[http://grml.org/team/|mika]]]

===== System recovery =====

**ddrescue:** Probably you already know 'dd' for copying files. ddrescue is an improved version of dd which 'tries to read and if it fails it will go on with the next sectors, where tools like dd will fail.' (manpage of ddrescue). Use this tool if a filesystem/partition is quite broken and you want to restore some data anyway. [Tip by [[http://grml.org/team/|mika]]]

**NTFS:** problems with an NTFS partition? Take a look at the packages salvage-ntfs and scrounge-ntfs. If you want to **resize** a NTFS-partition use ntfsresize (part of ntfsprogs). [Tip by [[http://grml.org/team/|mika]]]






===== Texttools =====

**mutt**/**mutt-ng**: You don't know how to configure the console mailclient? Just run grml-mutt/grml-muttng! [Tip by [[http://grml.org/team/|mika]]]


**slrn**: You don't know how to configure the console newsreader? Just run grml-slrn! [Tip by [[http://grml.org/team/|mika]]]



===== Sysadmin =====

**grml-hwinfo**: Run grml-hwinfo to collect hardware-information. You will get a file info.tar.bz2 which contains all relevant files. Run grml-hwinfo as user root (or via 'sudo grml-hwinfo') to get even more information. [Tip by [[http://grml.org/team/|mika]]]

===== Hauppauge PVR150/250/350/500 =====

Notice: Applies to grml 0.5-6, please report feedback if you've tested it!
To use the Hauppauge PVR250 with grml just download the firmware from http://xs.qapla.org/ivtv/ivtv-fw.tar.bz2 and extract it to /lib/modules/:

<code>
# dmesg | grep tveeprom
</code>

should output something like 

<code>
ivtv0: i2c attach to card #0 ok [client=tveeprom, addr=50]
tveeprom 0-0050: Hauppauge model 48134, rev J342, serial# 6564630
tveeprom 0-0050: tuner model is Temic 4009FR5 (idx 42, type 20)
tveeprom 0-0050: TV standards PAL(B/G) (eeprom 0x04)
tveeprom 0-0050: audio processor is MSP4418 (idx 25)
tveeprom 0-0050: decoder processor is SAA7115 (idx 19)
tveeprom 0-0050: has radio, has IR remote
</code>

the interesting part is the line "tuner model is ...". note the tuner type, you'll need it later.

To set up ivtv write the following to /etc/modutils/ivtv:

<code>
   alias char-major-81 videodev
   alias char-major-81-0 ivtv
   options ivtv ivtv-debug=0 mpg_buffers=90
   options tuner type=$tunermodel
   options msp3400 once=1 simple=1 debug=0
   add below ivtv msp3400 saa7115 tuner
</code>

With $tunermodel= the number you got from dmesg earlier.

For the pvr500 or multiple other cards, you'll need more than one of this blocks. See docs on www.ivtvdriver.org

<code>
# rmmod tveeprom
# rmmod ivtv
# wget http://xs.qapla.org/ivtv/ivtv-fw.tar.bz2 && tar -C /lib/firmware/ -p -xjf ivtv-fw.tar.bz2
# cd /lib/firmware
# mv ivtv-fw-enc.bin v4l-cx2341x-enc.fw
# mv ivtv-fw-dec.bin v4l-cx2341x-dec.fw
# modprobe ivtv
% mplayer /dev/video0
</code>

You can use ptune to change the channel. 

<code>
# ptune --freqtable pal-europe --tuner-num 0 --input /dev/video0 --channel SE1
</code>

More information (especially for the firmware-stuff) available on: http://home.comcast.net/~alf_park/mythtv.html

Even more informnation is in the wiki on the Homepage of ivtv at www.ivtvdriver.org

[Tip by Christian Scheucher]
[Updated by Spida]

===== Packages which might be useful on a harddisk installation =====

  * cppunit
  * doc-linux-html + doc-linux-nonfree-html
  * dpkg-www + dwww
  * dvdrip
  * emacs-goodies-el
  * foomatic-db + foomatic-db-engine foomatic-filers python-foomatic + foomatic-filters-ppds + foomatic-db-hpijs + foomatic-gui
  * gimp + gimp-help-de + grokking-the-gimp + libgimp-perl + libgtk2-perl
  * gnus-bonus-el
  * graphviz
  * gxine
  * heartbeat
  * libaudiofile-dev libxpm-dev libglib2.0-dev libssl-dev
  * lmodern
  * lsh-client lsh-server
  * luma
  * manpages-posix-dev
  * mew     
  * msttcorefonts
  * [[http://www.venge.net/monotone/|monotone]]
  * openswan
  * oprofile
  * osirisd + osirismd
  * php4-cli
  * printconf
  * samhain
  * spikeproxy
  * svk
  * svn-arch-mirror
  * systemimager-...
  * transcode
  * w32codecs + libdvdcss / libdvdcss2

[Tip by [[http://grml.org/team/|mika]]]

===== How to add your own files to a second session on a grml cd =====

This is only useful with grml-small since it's the only flavor which has space left on the cd.
<code>
  * Get the grml iso 
    e.g.: "wget http://mirror.inode.at/data/grml/grml_small_0.2.iso"
  * Burn the first session
    e.g.: "cdrecord dev=4,0,0 -v -multi -tao grml_small_0.2.iso"
  * Create a directory to store your files
    e.g.: "mkdir mydata"
    (This directory will be located in /cdrom after burning the second session.)
  * Add all your files you want to have on the cd
    e.g.: "cp -r /home/jimmy/.ssh mydata/"
    "mkdir mydata/files"
    "cp /home/jimmy/files/*.txt mydata/files/"
  * Create the second sessions containing theses files
    e.g.: "mkisofs -M grml_small_0.2.iso -C `cdrecord -msinfo dev=4,0,0` -R -o 2nd_session.iso mydata"
  * Append the second session to the cd
    e.g.: "cdrecord dev=4,0,0 -v -multi -tao 2nd_session.iso
  * Boot from your new personalized grml cd.
</code>
[Tip by [[http://grml.org/team/|jimmy]]]

If both sessions contain identical paths, the file from the second session takes precedence. This does not hold for files that are needed before the actual boot, such as isolinux.cfg, since isolinux only sees the first session.


===== How to make an audio file out of a DVD track =====

There are some ways to do that but one way that I like does not involve mencoder and so can be used with a GRML-live cd. It uses special files called named pipes. These are files like pipes but with a name and functioning like a first-in first-out batch, thus the name. So one program puts something in this special file and one program waits on the other end to do something with it.

  * First you create a named pipe with
<code>
mkfifo /tmp/fifo.wav
</code>

  * Then let one sound encoder sit on one side with (mppenc [musepack] is a very excellent program to encode your music, though sadly not widely known):

<code>
mppenc /tmp/fifo.wav track04.mpc&
</code>

  * On the other side you put a dvd-player like mplayer with
<code> 
mplayer -af resample=44100 -vc null -vo null -ao pcm:fast:file=/tmp/fifo.wav -chapter 4-4 dvd://1
</code>

  * It's sensible to use 44.1 khz for the output file and "vc null -vo null" does tell mplayer to not display video at all which makes it faster to encode.

[Tip by [[http://grml.org/team/|Matthias Kopfermann]]]


===== How to make a fully automatic rescue disk with fixed configuration =====

Sometimes, one is in charge of a remote system where no linux-savvy local admins are around. In this case, it is a good idea to have a CD on site which allows the system to boot in case the locally installed Linux system is broken.

While the "debnet" boot option does a good job in locating the network configuration of a Debian installation on the local disk, taking the data found there to configure the network, there might be cases where the local system is completely broken and /etc/network/interface cannot be found. In this case, a specially crafted grml can be used to

  * configure the network according to a configuration hard-coded on the CD
  * set a password for the grml user which is hard-coded on the CD
  * start an ssh daemon

In short, with this CD, the system will come up with the network configured and ready for remote administration. The local admin only needs to boot from the CD, the rest is automated.

To do this, you can either
  * Put the additional files on a second session on the GRML CD or
  * remaster grml. No change to the squashfs is necessary.

Remastering grml has the advantage that you can edit the isolinux boot message file to say that this is a specially crafted grml, and that the result is a single .iso file which can be sent over the internet and burned to a CD-R with any CD burner software including Windows software.

  * Create 'bootparams/bootparams' on the GRML CD with the contents 'nodhcp scripts'. This will disable DHCP IP address configuration and allows scripts/grml.sh to be executed.
  * Modify boot/isolinux/boot.msg and/or boot/isolinux/isolinux.cfg to your needs. If you need to modify isolinux.cfg, you can't take the multisession approach and need to remaster grml.
  * Create 'scripts/grml.sh' with the following contents

<code>
#!/bin/bash

ip link set dev eth0 up
ip addr add dev eth0 <address>/<prefix> brd +
ip route add default via <gateway>
echo "grml:<password>" | chpasswd
/etc/init.d/ssh start
</code>

Substitute address, prefix, gateway and password with your values. If you don't want to use the plain text password here, use chpasswd --encrypted and pass a crypt(1)ed password.

[Tip by Marc 'Zugschlus' Haber]


===== Transparent Debian Proxy =====

While apt-proxy might have some cool features, apt-cacher turned out to be the perfect solution for me, because it can be used transparently on a router:

Install of apt-cacher, the default config will do:
<code>
apt-get install apt-cacher
</code>

Usually you would now edit the clients sources.list to use apt-cacher. However, i wanted to force the clients to use apt-cacher without clientside modification. I found out that this can be done the same way like a transparent squid. You just have to decide for which debian mirrors you want to enforce the transparent proxying.

Find out the ip's of the debian mirrors.
For example: ftp.de.debian.org is 141.76.2.4 and ftp.at.debian.org is 213.129.232.18. Then add this to your firewall script:
<code>
DEBIAN_MIRRORS="141.76.2.4 213.129.232.18"

for ip in ${DEBIAN_MIRRORS} ; do
  ${IPTABLES} -t nat -A PREROUTING -s $subnet -d $ip -p tcp --dport 80 -j REDIRECT --to-port 3142
done
</code>
( where ${IPTABLES} is the location of your iptables binary and $subnet is your internal subnet )

Voila, everybody in your subnet who does access either ftp.de.debian.org or ftp.at.debian.org will actually access your apt-cacher

To use apt-cacher on the router itself, you add this to your /etc/apt/apt.conf:

<code>
Acquire::http::Proxy "http://localhost:3142/";
</code>

===== Remastering grml with out-of-tree NIC drivers and zfsonlinux =====

Some Intel network cards have out-of-tree drivers at http://sourceforge.net/projects/e1000/ which often support recent NICs better than the in-kernel drivers.

In some cases, the in-kernel driver works very poorly or not at all. If you have a box that's affected, running (especially netbooting) grml on it is a pain.

This tip explains how to create your custom grml iso that includes these NIC drivers (with zfsonlinux thrown in as a bonus).

1. grab some tarballs from http://sourceforge.net/projects/e1000/, e.g.:

<code>
-rw-r--r-- 1 root root   269997 Sep  5 16:25 e1000e-2.5.4.tar.gz
-rw-r--r-- 1 root root   303648 Sep 17 02:23 igb-5.0.6.tar.gz
-rw-r--r-- 1 root root   362747 Sep 30 23:21 ixgbe-3.18.7.tar.gz
-rw-r--r-- 1 root root   140096 Sep 30 23:31 ixgbevf-2.11.3.tar.gz
</code>

2. Extract them.

3. In each resulting directory, create a dkms.conf file; this will allow you to package up the module source as a .deb. I only have a superficial understanding of dkms, so what I did is probably not the best possible approach, but it seemed to mostly work (with the exception of e1000e, which appeared to build correctly but whose module was not installed by dkms for some reason; corrections welcome).

3.1. Move the contents of src/ to "." (see below for a possible way of avoiding this).

3.2. Create a dkms.conf saying (I'll use igb-5.0.6 as the example here):

<code>
AUTOINSTALL="yes"
BUILT_MODULE_NAME[0]="igb"
CLEAN="make clean"
DEST_MODULE_LOCATION="/updates"
DEST_MODULE_NAME[0]="igb"
PACKAGE_NAME="igb"
PACKAGE_VERSION="5.0.6-1"
</code>

I have not tried, but I think you should be able to avoid moving the source files from src/ to . by using a slightly different dkms.conf, such as:

<code>
AUTOINSTALL="yes"
BUILT_MODULE_NAME[0]="igb"
CLEAN="'make' -C src/ clean"
MAKE="'make' -C src/ all"
BUILT_MODULE_LOCATION="src/"
DEST_MODULE_LOCATION="/updates"
DEST_MODULE_NAME[0]="igb"
PACKAGE_NAME="igb"
PACKAGE_VERSION="5.0.6-1"
</code>

3.3. Make sure the Makefiles of the modules get the kernel version to build for from the KERNELRELEASE environment variable instead of e.g. BUILD_KERNEL (which the Intel drivers use by default), because that's what dkms sets:

<code>
sed -i 's/BUILD_KERNEL/KERNELRELEASE/g' Makefile
</code>

3.4. Optional: if you're using a custom kernel (not the grml default kernel), you may want to change the module source to use #ifdef CONFIG_PM instead of #ifdef CONFIG_PM_SLEEP as per https://sourceforge.net/p/e1000/patches/24/.

3.5. In each module directory, do (again, using igb-5.0.6 as an example; modify as necessary):

<code>
dkms add -m igb -v 5.0.6           
dkms mkdeb -m foo -v 5.0.6 --source-only
</code>

The second command will create a .deb and dump it somewhere under /var/lib/dkms/.

4. Import the .debs into your private repository (I manage mine using reprepro, fwiw). I suppose you can skip this step and instead use a different mechanism to inject the .debs into the grml build.

5. Install grml-live.

5.1. Create a new FAI "class" called e.g. EXTRANIC (and one called ZFSONLINUX, if you want). This involves creating the following files:

/etc/grml/fai/config/hooks/instsoft.EXTRANIC (mode 755):

<code>
#!/bin/bash
set -u
set -e
. "$GRML_LIVE_CONFIG"
$ROOTCMD apt-get --yes --force-yes install \
	dkms build-essential linux-headers-3.10-1-grml-amd64
</code>

(You'll note this is inelegant because it hardcodes the kernel version; the point here is to make sure the kernel-headers are already installed by the time the driver packages are installed.)

/etc/grml/fai/config/scripts/EXTRANIC/50-dkms (mode 755):

<code>
#!/bin/zsh
set -u
set -e
. "$GRML_LIVE_CONFIG"
for kernelversion in $(${=ROOTCMD} sh -c 'ls -1 /boot/vmlinuz-*' \
	| sed 's@.*boot/vmlinuz-@@'); do
		echo "Building dkms modules for kernel $kernelversion."
		${=ROOTCMD} /etc/kernel/postinst.d/dkms "$kernelversion"
done
</code>

(This may not be necessary. It attempts to build all dkms modules once more, after all requested packages have been installed.)

/etc/grml/fai/config/package_config/EXTRANIC:

<code>
e1000e-dkms
igb-dkms
ixgbe-dkms
ixgbevf-dkms
broadcom-sta-dkms
r8168-dkms
</code>

(Some of these are from stock Debian; the first four are the ones I built in step 3.)

Optional: /etc/grml/fai/config/package_config/ZFSONLINUX:

<code>
spl-dkms
zfs-dkms
zfsutils
libnvpair1
libzfs1
libzpool1
libuutil1
</code>

/etc/grml/fai/config/files/etc/apt/sources.list.d/myrepo.list/EXTRANIC:

(Contains the deb http://... line for your repository.)

/etc/grml/fai/config/package_config/EXTRANIC.asc:

(Contains the public key of the repository signing key; I'm not sure this is
really the correct way of injecting it in the build process.)

Optional: also create a ZFSONLINUX.asc with the zfsonlinux signing key inside. As of 2013-10, you can obtain it by running

<code>
gpg --keyserver subkeys.pgp.net --recv-keys 9A55B33CA71C1E00
gpg --armor --export 9A55B33CA71C1E00 >/etc/grml/fai/config/package_config/ZFSONLINUX.asc
</code>

6. Configure grml-live. In /etc/grml/grml-live.local, I have:

<code>
OUTPUT=/tmp/grml/grml-live
SUITE="sid"
FAI_DEBOOTSTRAP="sid http://cdn.debian.net/debian"
VERSION=$(date +%F)
RELEASENAME="grml64-extranic+zfs"
GRML_NAME="grml64-extranic+zfs"
HOSTNAME="grml-extranic+zfs"
ARCH="amd64"
DISTRI_NAME="grml-extranic+zfs"
NO_ADDONS_BSD4GRML='1'
EXIT_ON_MISSING_PACKAGES='1'
DEFAULT_BOOTOPTIONS="ssh=sekrit" # Be sure you understand what this does before using it
</code>

7. Build your iso.

<code>
echo 'y\nn\ny\ny'\
	| env -u TMPDIR -u TMP \
	nice -n 20 \
	grml-live -A -u -e /path/to/grml64-full_sid_20131001.iso \
	-c DEBORPHAN,GRMLBASE,GRML_FULL,RELEASE,AMD64,IGNORE,EXTRANIC,ZFSONLINUX
</code>

(Obviously omit ",ZFSONLINUX" if you don't want it.)

The resulting image is larger than regular grml as it includes build-essential and its dependencies; if that's a problem, I suppose you can add a script after 50-dkms that purges now-unneeded packages.

[Tip by András Korn]
