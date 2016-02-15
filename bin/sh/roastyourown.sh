#!/usr/bin/env bash
[ "root" != "$USER" ] && exec sudo $0 "$@"
: ${AGI=apt-get install -y -q=1}
: ${NFO=dialog --infobox "Installing $menuitem..." 5 45 --}
INPUT=/tmp/menu.sh.$$
dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Application Installer" --msgbox "Welcome to the Grill! This script lets you choose and install base applications. After setting up the system, you can create a redistributable ISO or boot into your new setup. Happy roasting, you're now one of us! Hit Enter to continue..." 10 55
dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Checking Internet Connection" --infobox "Please wait..." 7 45
if ping -c 1 8.8.8.8 > /dev/null 2>&1 ; then
	sleep 1s ; dialog --clear
else
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Check your network" --msgbox "Starting Ceni to configure network" 7 35; ceni ;
fi
dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Syncing Package Database"  --yesno "Start update? (It is definitely recommended)" 5 55
if [ "$?" != "0" ]; then
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Attention" --msgbox "Don't shoot me, I'm just the messenger..." 7 55
else
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Syncing Package Database" --infobox "Please wait..." 5 35
	apt-get update -q=2
fi

function display_output(){
	local h=${1-10}			# box height default 10
	local w=${2-41} 		# box width default 41
	local t=${3-Output} 	# box title 
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "${t}" --clear --msgbox "$(<$OUTPUT)" ${h} ${w}
}

function dman(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --nocancel --title "Display Manager" --menu "Note: Some DMs need manual editing of their configurations file." 20 60 15 \
	A lightdm \
	b "lightdm-kde" \
	c "lightdm-razorqt" \
	B slim \
	C xdm \
	D kdm \
	E qingy \
	G nodm \
	H choosewm \
	8 "Back to Main"  2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI lightdm lightdm-gtk-greeter ;;
	b) $AGI lightdm lightdm-kde-greeter ;;
	c) $AGI lightdm lightdm-razorqt-greeter ;;
	B) $AGI slim ;;
	C) $AGI xdm ;;
	D) $AGI kdm ;;
	E) $AGI qingy ;;
	G) $AGI nodm ;;
	H) $AGI choosewm ;;
	8) mainmenu;;
esac
}

function de_wm(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --nocancel --title "Desktop Environments and Window Managers" --menu "Scroll down for panel and system monitors. Note: Some WMs need a manual startup entry for the Xsessions file." 20 60 15 \
	A aewm  \
	B aewm_plusplus  \
	C amiwm  \
	D awesome  \
	E blackbox  \
	F clfswm  \
	G compiz  \
	H ctwm  \
	I dwm  \
	J e17  \
	K fluxbox  \
	L flwm  \
	M fvwm1  \
	N fvwm-crystal  \
	O "GNOME minimal session"  \
	P herbstluftwm  \
	Q i3  \
	R icewm  \
	S jwm  \
	T "KDE4 desktop"  \
	U larswm  \
	V lwm  \
	W LXDE  \
	X matchbox  \
	Y marco  \
	Z MATE  \
	a metacity  \
	b muffin  \
	c mutter  \
	d 9wm  \
	e notion  \
	f openbox  \
	g olwm  \
	h oroborus  \
	i pekwm  \
	j ratpoison  \
	k sapphire  \
	l sawfish  \
	m spectrwm  \
	n stumpwm  \
	o subtle  \
	p tinywm  \
	q twm  \
	r tritium  \
	s vtwm  \
	t w9wm  \
	u windowlab  \
	v wm2  \
	w wmaker  \
	x wmii  \
	y Xfce4  \
	z razorqt  \
	9 xmonad  \
	7 "tint2 panel"  \
	6 LXpanel  \
	5 "dzen2 panel"  \
	4 "gkrellm system monitor"  \
	3 "Conky system monitor"  \
	8 "Back to Main"  2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
		A) $AGI aewm ;;
		B) $AGI aewm++ ;;
		C) $AGI amiwm ;;
		D) $AGI awesome awesome-extra;;
		E) $AGI blackbox;;
		F) $AGI clfswm;;
		G) $AGI compiz compiz-gtk compiz-plugins;;
		H) $AGI ctwm;;
		I) $AGI dwm;;
		J) $AGI e17;;
		K) $AGI fluxbox fbautostart fbdesk fbpager;;
		L) $AGI flwm;;
		M) $AGI fvwm1;;
		N) $AGI fvwm-crystal fvwm-icons;;
		O) $AGI gnome-session ;;
		P) $AGI herbstluftwm ;;
		Q) $AGI i3;;
		R) $AGI icewm-experimental icewm-themes;;
		S) $AGI jwm ;;
		T) $AGI kdebase-workspace lightdm-kde-greeter;;
		U) $AGI larswm;;
		V) $AGI lwm;;
		W) $AGI lxde lxappearance-obconf;;
		X) $AGI matchbox matchbox-panel matchbox-panel-manager matchbox-window-manager matchbox-desktop;;
		Y) $AGI marco;;
		Z) $AGI mate-desktop-environment;;
		a) $AGI metacity metacity-themes;;
		b) $AGI muffin;;
		c) $AGI mutter ;;
		d) $AGI 9wm 9menu;;
		e) $AGI notion;;
		f) $AGI openbox obconf obmenu;;
		g) $AGI olwm;;
		h) $AGI oroborus;;
		i) $AGI pekwm;;
		j) $AGI ratpoison ratmenu;;
		k) $AGI sapphire;;
		l) $AGI sawfish sawfish-themes sawfish-merlin-ugliness fspanel;;
		m) $AGI spectrwm;;
		n) $AGI stumpwm;;
		p) $AGI tinywm;;
		q) $AGI twm ;;
		r) $AGI tritium;;
		s) $AGI vtwm ;;
		t) $AGI w9wm;;
		o) $AGI subtle;;
		u) $AGI windowlab;;
		v) $AGI wm2;;
		w) $AGI wmaker wmbattery wmbiff wmcalclock wmcdplay wmcpuload wmforkplop wmifs wmmemload wmmixer wmmoonclock wmnet wmrack wmwork;;
		x) $AGI wmii;;
		y) $AGI xfce4 xfwm4-themes ;;
		z) $AGI razorqt ;;
		9) $AGI xmonad xmobar ;;
		8) mainmenu;;
		7) $AGI tint2;;
		6) $AGI lxpanel;;
		5) $AGI dzen2;;
		4) $AGI gkrellm gkrellm-mailwatch gkrellm-reminder gkrellm-volume gkrellm-x86info gkrellm-xkb gkrellmoon gkrellmwireless gkrellshoot gkrelltop gkrellweather gkrellm-ibam;;
	esac
}

function termin(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Terminal Emulator" --menu "Select your default terminal. xterm is already provided." 20 60 15 \
	A aterm \
	B eterm \
	C evilvte \
	D fbterm \
	E guake \
	F konsole \
	G kterm \
	H lxterminal \
	I mlterm \
	J mrxvt \
	K roxterm \
	L rxvt \
	M "rxvt-ml" \
	N "rxvt-unicode" \
	O "rxvt-unicode-256color" \
	P "rxvt-unicode-lite" \
	Q "rxvt-beta" \
	R sakura \
	S stterm \
	T terminator \
	U termit \
	V tilda \
	W "xfce4-terminal" \
	X xvt \
	Y qterm \
	Z tmux \
	a byobu \
	b "GNU screen" \
	8 "Back to Main" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI aterm;;
	B) $AGI eterm;;
	C) $AGI evilvte;;
	D) $AGI fbterm;;
	E) $AGI guake;;
	F) $AGI konsole;;
	G) $AGI kterm;;
	H) $AGI lxterminal;;
	I) $AGI mlterm;;
	J) $AGI mrxvt;;
	K) $AGI roxterm;;
	L) $AGI rxvt;;
	M) $AGI rxvt-ml;;
	N) $AGI rxvt-unicode;;
	O) $AGI rxvt-unicode-256color;;
	P) $AGI rxvt-unicode-lite;;
	Q) $AGI rxvt-beta;;
	R) $AGI sakura;;
	S) $AGI stterm;;
	T) $AGI terminator;;
	U) $AGI termit;;
	V) $AGI tilda;;
	W) $AGI xfce4-terminal;;
	X) $AGI xvt;;
	Y) $AGI qterm;;
	Z) $AGI tmux;;
	a) $AGI byobu;;
	b) $AGI screen;;
	8) mainmenu;;
esac
}

function brows(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Web Browser" --menu "Select your Web Browser. Roaster and links2 are already provided. Some lightweight browsers need a manual entry in your root menu." 20 60 15 \
	A arora \
	B chromium \
	C conkeror \
	D dwb \
	E edbrowse \
	F elinks \
	G epiphany \
	H iceweasel \
	I "iceape suite" \
	J luakit \
	K midori \
	L netrik \
	M netsurf \
	N rekonq \
	O surf \
	P hv3 \
	Q w3m \
	R xxxterm \
	S qupzilla \
	T lynx \
	U uzbl \
	8 "Back to Main"  2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI arora;;
	B) $AGI chromium chromium-codecs-ffmpeg chromium-l10n;;
	C) $AGI conkeror;;
	D) $AGI dwb;;
	E) $AGI edbrowse;;
	F) $AGI elinks;;
	G) $AGI epiphany;;
	H) $AGI iceweasel xul-ext-adblock-plus xul-ext-adblock-element-hiding-helper;;
	I) $AGI iceape;;
	J) $AGI luakit;;
	K) $AGI midori;;
	L) $AGI netrik;;
	M) $AGI netsurf;;
	N) $AGI rekonq;;
	O) $AGI surf;;
	P) $AGI hv3;;
	Q) $AGI w3m;;
	R) $AGI xxxterm;;
	S) $AGI qupzilla;;
	T) $AGI lynx;;
	U) $AGI uzbl;;
	8) mainmenu;;
esac
}

function fileman(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "File Manager" --menu "Pick a file manager. Ranger and MC are already provided." 20 60 15 \
	A andromeda \
	B bsc \
	C gentoo \
	D "gnome-commander" \
	E "gpe-filemanager" \
	F "rox-filer" \
	G thunar \
	H nautilus \
	I konqueror \
	J dolphin \
	K xfe \
	L xfm \
	M worker \
	N pcmanfm \
	O spacefm \
	P qtfm \
	R vifm \
	8 "Back to Main"  2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI andromeda ;;
	B) $AGI bsc ;;
	C) $AGI gentoo ;;
	D) $AGI gnome-commander ;;
	E) $AGI gpe-filemanager ;;
	F) $AGI rox-filer ;;
	G) $AGI thunar thunar-media-tags-plugin thunar-archive-plugin thunar-vcs-plugin thunar-volman ;;
	H) $AGI nautilus nautilus-actions nautilus-image-converter nautilus-sendto nautilus-share nautilus-emblems ;;
	I) $AGI konqueror konq-plugins ;;
	J) $AGI dolphin konq-plugins ;;
	K) $AGI xfe xfe-i18n xfe-themes ;;
	L) $AGI xfm ;;
	M) $AGI worker ;;
	N) $AGI pcmanfm ;;
	O) $AGI libudev-dev && wget -c http://linuxbbq.org/incoming/udevil.deb && wget -c http://linuxbbq.org/incoming/spacefm.deb && dpkg -i udevil.deb && dpkg -i spacefm.deb && rm udevil.deb && rm spacefm.deb && gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor && gtk-update-icon-cache -q -t -f /usr/share/icons/Faenza ;;
	P) $AGI qtfm ;;
	R) $AGI vifm ;;
	8) mainmenu;;
esac 
}

function texted(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Text Editors and IDE" --menu "Pick an editor. nano, mcedit and leafpad are already provided." 20 60 15 \
	A emacs \
	B vim \
	C scite \
	D ted \
	E geany \
	F mousepad \
	G medit \
	H nedit \
	I levee \
	J xjed \
	K joe \
	L jupp \
	M jed \
	e jedit \
	N kate \
	O kwrite \
	P gwrite \
	R gedit \
	S fte \
	T ed \
	U cream \
	V elvis \
	W efte \
	X editra \
	Y juffed \
	Z ne \
	7 scribes \
	6 tea \
	5 vile \
	4 xvile \
	3 x2 \
	a axe \
	b yudit \
	c pyroom \
	d focuswriter \
	8 "Back to Main"  2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI emacs ;;
	B) $AGI vim ;;
	C) $AGI scite ;;
	D) $AGI ted ;;
	E) $AGI geany ;;
	F) $AGI mousepad ;;
	G) $AGI medit ;;
	H) $AGI nedit ;;
	I) $AGI levee ;;
	J) $AGI xjed ;;
	K) $AGI joe ;;
	L) $AGI jupp ;;
	M) $AGI jed ;;
	N) $AGI kate ;;
	O) $AGI kwrite ;;
	P) $AGI gwrite ;;
	R) $AGI gedit ;;
	S) $AGI fte ;;
	T) $AGI ed ;;
	U) $AGI cream ;;
	V) $AGI elvis ;;
	W) $AGI efte ;;
	X) $AGI editra ;;
	Y) $AGI juffed ;;
	Z) $AGI ne ;;
	e) $AGI jedit;;
	7) $AGI scribes ;;
	6) $AGI tea ;;
	5) $AGI vile ;;
	4) $AGI xvile ;;
	3) $AGI x2 ;;
	a) $AGI axe ;;
	b) $AGI yudit ;;
	c) $AGI pyroom ;;
	d) $AGI focuswriter ;;
	8) mainmenu;;
esac 
}

function office(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Office Applications" --menu "Here you can select a word processor or spreadsheet app. For LibreOffice please add l10n localization if needed." 20 60 15 \
	A abiword \
	B gnumeric \
	C lyx \
	D "libreoffice-writer" \
	E "libreoffice-calc" \
	F "libreoffice full suite" \
	G calligra \
	H "texlive-full" \
	I luatex \
	J zim \
	K texworks \
	L texmaker \
	M texstudio \
	N rubber \
	O latexila \
	P kile \
	Q gummi \
	R pdfviewer \
	S zathura \
	T xpdf \
	U mupdf \
	V okular \
	W calibre \
	X epdfview \
	Y evince \
	Z katarakt \
	a scribus \
	b "scribus-ng" \
	c jscribble \
	d xournal \
	8 "Back to Main" 2>"${INPUT}"
	menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI abiword ;;
	B) $AGI gnumeric ;;
	C) $AGI lyx ;;
	D) $AGI libreoffice-writer ;;
	E) $AGI libreoffice-calc ;; 
	F) $AGI libreoffice full suite ;;
	G) $AGI calligra ;;
	H) $AGI texlive-full ;;
	I) $AGI luatex ;;
	J) $AGI zim ;;
	K) $AGI texworks ;;
	L) $AGI texmaker ;;
	M) $AGI texstudio ;;
	N) $AGI rubber ;;
	O) $AGI latexila ;;
	P) $AGI kile ;;
	Q) $AGI gummi ;;
	R) $AGI pdfviewer ;;
	S) $AGI zathura ;;
	T) $AGI xpdf ;;
	U) $AGI mupdf ;;
	V) $AGI okular ;;
	W) $AGI calibre ;;
	X) $AGI epdfview ;;
	Y) $AGI evince ;;
	Z) $AGI katarakt ;;
	a) $AGI scribus ;;
	b) $AGI scribus-ng ;;
	c) $AGI jscribble ;;
	d) $AGI xournal ;;
	8) mainmenu;;
esac
}


function graphics_photo(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Graphics and Photo Editing" --menu "Here you can select image viewers and editors." 20 60 15 \
	a darktable \
	A gimp \
	B inkscape \
	C fotoxx \
	D shotwell \
	E mirage \
	F geeqie \
	G showfoto \
	H ristretto \
	I gpicview \
	J xpaint \
	K gthumb \
	L gpaint \
	M digikam \
	N "f-spot" \
	8 "Back to Main"  2>"${INPUT}"
	menuitem=$(<"${INPUT}")
case $menuitem in
	a) $AGI darktable ;;
	A) $AGI gimp ;;
	B) $AGI inkscape ;;
	C) $AGI fotoxx ;;
	D) $AGI shotwell ;;
	E) $AGI mirage ;;
	F) $AGI geeqie ;;
	G) $AGI showfoto ;;
	H) $AGI ristretto ;;
	I) $AGI gpicview ;;
	J) $AGI xpaint ;;
	K) $AGI gthumb ;;
	L) $AGI gpaint ;;
	M) $AGI digikam ;;
	N) $AGI f-spot ;;
	8) mainmenu ;;
esac
}

function defshell(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Shells" --menu "You are using $SHELL" 20 60 15 \
	a zsh \
	A ksh \
	B mksh \
	C yash \
	D csh \
	E "git-sh" \
	F "switch-sh" \
	G aptsh \
	H dsh \
	I fish \
	J fizsh \
	K ssh \
	L posh \
	M sash \
	N rush \
	8 "Back to Main"  2>"${INPUT}"
	menuitem=$(<"${INPUT}")
case $menuitem in
	a) $AGI zsh ; chsh;;
	A) $AGI ksh ; chsh;;
	B) $AGI mksh ; chsh;;
	C) $AGI yash ; chsh;;
	D) $AGI csh ; chsh;;
	E) $AGI git-sh ; chsh;;
	F) $AGI switch-sh ; chsh;;
	G) $AGI aptsh ; chsh;;
	H) $AGI dsh ; chsh;;
	I) $AGI fish ; chsh;;
	J) $AGI fizsh ; chsh;;
	K) $AGI ssh ; chsh;;
	L) $AGI posh ; chsh;;
	M) $AGI sash ; chsh;;
	N) $AGI rush ; chsh;;
	8) mainmenu ;;
esac
}

function sound_video(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Sound and Video" --menu "Pick your sound system and media players. mplayer2 and moc are already provided." 20 60 15 \
	A "ALSA only" \
	B pulseaudio \
	C amarok \
	D "ario + mpd" \
	E audacious \
	F bangarang \
	G banshee \
	H cmus \
	I exaile \
	J freetuxtv \
	K gmerlin \
	L "gnome-mplayer" \
	M gxine \
	N gst123 \
	O kaffeine \
	P juk \
	Q dragonplayer \
	R ffmpeg \
	S minirok \
	T "ncmpcpp + mpd" \
	U mencoder \
	V parole \
	W totem \
	X vlc \
	Y xmms2 \
	a xnoise \
	b guayadeque \
	c "cantata + mpd" \
	d clementine \
	e radiotray \
	f "qmpdclient + mpd" \
	g plait \
	h "pygmy + mpd" \
	i musique \
	j "mpc + mpd" \
	k lxmusic \
	l juke \
	m "gimmix + mpd" \
	n bluemindo \
	o aqualung \
	p kdenlive \
	q openshot \
	r kino \
	s flowblade \
	t betaradio \
	8 "Back to Main" 2>"${INPUT}"
	menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI  alsaplayer-alsa alsa-tools alsa-base alsa-firmware-loaders;;
	B) $AGI  pulseaudio pulseaudio-utils pavumeter pavucontrol paman paprefs;;
	C) $AGI  amarok ;;
	D) $AGI  ario + mpd ;;
	E) $AGI  audacious ;;
	F) $AGI  bangarang ;;
	G) $AGI  banshee ;;
	H) $AGI  cmus ;;
	I) $AGI  exaile ;;
	J) $AGI  freetuxtv ;;
	K) $AGI  gmerlin ;;
	L) $AGI  gnome-mplayer ;;
	M) $AGI  gxine ;;
	N) $AGI  gst123 ;;
	O) $AGI  kaffeine ;;
	P) $AGI  juk ;;
	Q) $AGI  dragonplayer ;;
	R) $AGI  ffmpeg ;;
	S) $AGI  minirok ;;
	T) $AGI  ncmpcpp mpd ;;
	U) $AGI  mencoder ;;
	V) $AGI  parole ;;
	W) $AGI  totem ;;
	X) $AGI  vlc ;;
	Y) $AGI  xmms2 ;;
	a) $AGI  xnoise ;;
	b) $AGI  guayadeque ;;
	c) $AGI  cantata mpd ;;	
	d) $AGI  clementine ;;
	e) $AGI  radiotray ;;
	f) $AGI  qmpdclient mpd ;;
	g) $AGI  plait ;;
	h) $AGI  pygmy mpd ;;
	i) $AGI  musique ;;
	j) $AGI  mpc mpd ;;
	k) $AGI  lxmusic ;;
	l) $AGI  juke ;;
	m) $AGI  gimmix mpd ;;
	n) $AGI  bluemindo ;;
	o) $AGI  aqualung ;;
	p) $AGI  kdenlive ;;
	q) $AGI  openshot ;;
	r) $AGI  kino ;;
	s) $AGI  flowblade ;;
	t) $AGI  betaradio ;;
	8) mainmenu;;
esac
}

function lamp_stack(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "LAMP Stack" --yesno "Would you like to install Apache2 webserver with PHP
	scripting support and MySQL database server? If you choose to do this, the following packages will be installed:

      apache2 mysql-server php5 php-pear php5-gd 
      php5-mysql php5-imagick php5-curl curl 
      phpmyadmin rsync cronolog

Note: additional packages listed as dependencies may also be installed." 20 60;

if [ "$?" = "0" ]; then
    $AGI apache2 mysql-server php5 php-pear php5-gd php5-mysql php5-imagick php5-curl curl phpmyadmin rsync cronolog

    #Enable modrewrite - does this work?
    if [ -d /etc/apache2/sites-available ]; then
        A2D="/etc/apache2/sites-available"
        if [ -f "$A2D/default" ]; then
            sudo touch $A2D/default2
            sudo chown $USER:$USER $A2D/default2
            sudo chown $USER:$USER $A2D/default
            sudo cat $A2D/default | sed '9,14 s/AllowOverride None/AllowOverride All/' >$A2D/default2
            sudo mv -f $A2D/default2 $A2D/default
            sudo chown root:root $A2D/default
            sudo a2enmod rewrite
            sudo /etc/init.d/apache2 restart
        fi
    fi
     
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "LAMP Stack" --yesno "  Would you like to create a symlink within Apache's 
	document root directory to a directory within your home directory? If you do this, you will be able to access 
	your web development documents from the address:

      http://localhost/$USER/

The file path will be: /home/$USER/htdocs

  Note: if this system is used by multiple users, you may want to consider using apache2's 'userdir' module instead." 20 60; 

    if [ "$?" = "0" ]; then
        if [ ! -d "/home/$USER/htdocs" ]; then
            mkdir /home/$USER/htdocs
        fi
        sudo ln -s /home/$USER/htdocs /var/www/$USER
    fi

fi
mainmenu
}

function printing(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "CUPS Printing System" --yesno "Install the CUPS printing system?" 20 60; 
if [ "$?" = "0" ]; then
	$AGI cups cups-pdf system-config-printer printer-driver-hpijs
fi
mainmenu
}

function devel_tools(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Tools for Developers" --yesno "Would you like to install development tools? If you choose Yes, following packages will be installed: 
	
	openssh-server openssh-server git git git-gui git-gui git-svn git-svn git-email git-email mercurial mercurial subversion subversion subversion-tools subversion-tools bzr bzr bzrtools bzrtools cvs cvs thunar-vcs-plugin thunar-vcs-plugin build-essential build-essential debhelper debhelper cdbs cdbs dh-make dh-make diffutils diffutils patch patch gnupg gnupg fakeroot fakeroot lintian lintian devscripts devscripts dpatch dpatch dput dput" 20 60;
	
if [ "$?" = "0" ]; then
	$AGI openssh-server openssh-server git git git-gui git-gui git-svn git-svn git-email git-email mercurial mercurial subversion subversion subversion-tools subversion-tools bzr bzr bzrtools bzrtools cvs cvs thunar-vcs-plugin thunar-vcs-plugin build-essential build-essential debhelper debhelper cdbs cdbs dh-make dh-make diffutils diffutils patch patch gnupg gnupg fakeroot fakeroot lintian lintian devscripts devscripts dpatch dpatch dput dput
fi
mainmenu
}

function emulat(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Emulators and virtual machines" --menu "Pick your poison." 20 60 15 \
	A wine \
	B playonlinux \
	C virtualbox \
	D qemu \
	E virtualbricks \
	F bochs \
	G dosbox \
	8 "Back to Main"  2>"${INPUT}"
	menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI wine winetricks ;;
	B) $AGI playonlinux ;;
	C) $AGI virtualbox virtualbox-dkms virtualbox-qt virtualbox-source virtualbox-guest-additions-iso ;;
	D) $AGI qemu qemu-keymaps qemu-system qemu-user qemu-utils qemu-launcher qemuctl ;;
	E) $AGI virtualbricks ;;
	F) $AGI bochs bochs-sdl bochs-svga bochs-term bochs-x bochsbios sb16ctrl-bochs vga-bios ;;
	G) $AGI dosbox ;;
	8) mainmenu;;
esac
}

function communic(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Communication and Chat Tools" --menu "Select your IM and IRC client." 20 60 15 \
	A pidgin \
	B empathy \
	C kopete \
	D quassel \
	E konversation \
	F mcabber \
	G irssi \
	H weechat \
	I swift-im \
	J psi \
	K prosody \
	L finch \
	M emesene \
	N amsn \
	I centerim \
	J bitlbee \
	K ayttm \
	L barnowl \
	M coccinella \
	N ekg2 \
	O jitsi \
	8 "Back to Main"  2>"${INPUT}"
	menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI  pidgin ;;
	B) $AGI  empathy ;;
	C) $AGI  kopete ;;
	D) $AGI  quassel ;;
	E) $AGI  konversation ;;
	F) $AGI  mcabber ;;
	G) $AGI  irssi ;;
	H) $AGI  weechat ;;
	I) $AGI  swift-im ;;
	J) $AGI  psi ;;
	K) $AGI  prosody ;;
	L) $AGI  finch ;;
	M) $AGI  emesene ;;
	N) $AGI  amsn ;;
	I) $AGI  centerim ;;
	J) $AGI  bitlbee ;;
	K) $AGI  ayttm ;;
	L) $AGI  barnowl ;;
	M) $AGI  coccinella ;;
	N) $AGI  ekg2 ;;	
	O) $AGI jitsi ;; 
	8) mainmenu;;
esac
}


function netman(){
	dialog --backtitle "LinuxBBQ - Roast Your Own" --title "Network Management" --menu "Select your network manager and additional services." 20 60 15 \
	A wicd \
	a "wicd-cli" \
	B "network-manager" \
	C "network-manager-gnome" \
	D vpnc \
	d "pptp-linux" \
	E openswan \
	F strongswan \
	G "l2tp-ipsec" \
	H kvpnc \
	I "ipsec-tools" \
	J openconnect \
	K "network-manager-gnome full set" \
	L openvpn \
	M openssl \
	8 "Back to Main"  2>"${INPUT}"
	menuitem=$(<"${INPUT}")
case $menuitem in
	A) $AGI  wicd ;;
	a) $AGI wicd-cli wicd-curses ;;
	B) $AGI network-manager ;;
	K) $AGI network-manager network-manager-gnome network-manager-vpnc-gnome network-manager-iodine-gnome network-manager-openvpn-gnome network-manager-pptp-gnome network-manager-strongswan-gnome network-manager-openconnect-gnome;;
	D) $AGI vpnc ;;
	d) $AGI pptp-linux ;;
	E) $AGI openswan ;;
	F) $AGI  strongswan ;;
	G) $AGI  l2tp-ipsec-vpn ;;
	H) $AGI  kvpn ;;
	I) $AGI  ipsec-tools ;;
	J) $AGI  openconnect ;;
	C) $AGI  network-manager-gnome network-manager-gnome  ;;
	L) $AGI  openvpn ;;
	M) $AGI  openssl ;;
	8) mainmenu;;
esac
}

function mainmenu(){
while true
do
dialog --clear --backtitle "LinuxBBQ - Roast Your Own" --title "Base Applications Installer" --menu "Choose the Package Group" 21 50 17 \
a "Display Manager" \
c "Edit .xinitrc" \
b "Shell" \
A "Window Managers and Desktop" \
B "Terminal Emulator" \
C "File Manager" \
D "Web Browser" \
E "Text Editor" \
F "Office Apps" \
G "Graphics and Photo" \
H "Sound and Video" \
I "LAMP Stack" \
J "CUPS Printing System" \
K "Development Tools" \
L "Emulation" \
M "Communication" \
N "Network Management" \
W "Create ISO from Install" \
8 "Exit to the shell" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	a) dman;;
	c) nano /home/$USER/.xinitrc ;;
	b) defshell;;
	A) de_wm;;
	B) termin;;
	C) fileman;;
	D) brows;;
	E) texted;;
	F) office;;
	G) graphics_photo;;
	H) sound_video;;
	I) lamp_stack;;
	J) printing;;
	K) devel_tools;;
	L) emulat;;
	M) communic;;
	N) netman;;
	W) bbqsnapshot ;;
	8) cp /home/$USER/.profile_good /home/$USER/.profile ; clear ; echo "Run me anytime with   roastyourown" ; exit 0 ;;
esac

# The copying of profile.good to profile is to prevent roastyourown being
# started after every boot. 
 
done
} 

[ -f $INPUT ] && rm $INPUT

mainmenu
