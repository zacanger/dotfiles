#!/bin/bash 
INPUT=/tmp/menu.sh.$$
socks=127.0.0.1:9050 
swfsize=927444 
swfhash=6c1be1765187eae0bc9af07d858fae59a0effd3c5b803d08db261ced2c5512bb 
vlcpath=/usr/bin/mplayer 
dialog --backtitle "BBQtv" --title "Live TV Stations" --menu "" 20 55 15 \
	A ARD \
	B ZDF \
	C ZDFneo \
	D SF1 \
	E SF2 \
	F "SF info" \
	G "ORF1" \
	H "ORF 2" \
	I 3sat \
	J arte \
	K "arte F" \
	L KiKa \
	M Pro7 \
	N RTL \
	O RTL2 \
	P RTL9 \
	Q SuperRTL \
	R "Sat.1" \
	S vox \
	T "kabel 1" \
	U "dasVierte" \
	V sixx \
	W dmax \
	X ntv \
	Y Nick \
	Z VIVA \
	a sport1 \
	b "Star TV" \
	c TeleZuri \
	d Eurosport \
	e France2 \
	f France3 \
	g France5 \
	h TSR1 \
	i TSR2 \
	j TV5monde \
	k tf1 \
	l m6 \
	m VIVA1 \
	n Euronews \
	o CNN \
	p BBCworld \
	q Rusiya \
	r joiz \
	s rsila1 \
	t rsila2 \
	u RAI1 \
	v RougeTV \
	y "schoener-fernsehen" \
	x "Exit BBQtv" 2>"${INPUT}"
menuitem=$(<"${INPUT}")
case $menuitem in
	 A) sender=rtmp://cp108475.live.edgefcs.net/live/ard_1_800@15782; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null ;;
	 B) sender=rtmp://cp108477.live.edgefcs.net/live/zdf_1_300@45509; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 C) sender=rtmp://cp108475.live.edgefcs.net/live/zdfneo_1_800@44504; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 D) sender=rtmp://cp108341.live.edgefcs.net/live/sf1_1_800@43046; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 E) sender=rtmp://cp108341.live.edgefcs.net/live/sf2_1_800@43048; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 F) sender=rtmp://cp108477.live.edgefcs.net/live/sfinfo_1_300@45505; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 G) sender=rtmp://cp108341.live.edgefcs.net/live/orf1_1_800@43059; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 H) sender=rtmp://cp108476.live.edgefcs.net/live/orf2_1_800@45502; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 I) sender=rtmp://cp108475.live.edgefcs.net/live/3sat_1_800@45493; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 J) sender=rtmp://cp108476.live.edgefcs.net/live/arte_1_800@45495; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 K) sender=rtmp://cp108478.live.edgefcs.net/live/arte_fr_1_800@45512; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 L) sender=rtmp://cp108476.live.edgefcs.net/live/kika_1_800@45500; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 M) sender=rtmp://cp108341.live.edgefcs.net/live/pro7_1_800@43051; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 N) sender=rtmp://cp108341.live.edgefcs.net/live/rtl_1_800@43050; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 O) sender=rtmp://cp108341.live.edgefcs.net/live/rtl2_1_800@43053; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 P) sender=rtmp://cp108477.live.edgefcs.net/live/rtl9_1_300@45503; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 Q) sender=rtmp://cp108475.live.edgefcs.net/live/superrtl_1_800@44489; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 R) sender=rtmp://cp108475.live.edgefcs.net/live//sat1_1_800@44490; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 S) sender=rtmp://cp108341.live.edgefcs.net/live/vox_1_800@43052; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 T) sender=rtmp://cp108341.live.edgefcs.net/live/kabel1_1_800@43055; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 U) sender=rtmp://cp108477.live.edgefcs.net/live/dasvierte_1_300@45510; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 V) sender=rtmp://cp108478.live.edgefcs.net/live/sixx_1_800@45516; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 W) sender=rtmp://cp108476.live.edgefcs.net/live/dmax_1_800@45498; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 X) sender=rtmp://cp115491.live.edgefcs.net/live/ntv_1_800@45520; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 Y) sender=rtmp://cp108478.live.edgefcs.net/live/nick_cc_1_800@45519; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 Z) sender=rtmp://cp108477.live.edgefcs.net/live/nick_viva_1_800@45507; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 a) sender=rtmp://cp108478.live.edgefcs.net/live/sport1_1_800@45517; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 b) sender=rtmp://cp115491.live.edgefcs.net/live/startv_1_800@45526; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 c) sender=rtmp://cp108475.live.edgefcs.net/live/telezueri_1_800@44503; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 d) sender=rtmp://cp108478.live.edgefcs.net/live/eurosport_1_800@45515; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 e) sender=rtmp://cp108476.live.edgefcs.net/live/france2_1_800@45496; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 f) sender=rtmp://cp108476.live.edgefcs.net/live/france3_1_800@45499; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 g) sender=rtmp://cp108476.live.edgefcs.net/live/france5_1_800@45501; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 h) sender=rtmp://cp115491.live.edgefcs.net/live/tsr1_1_800@45522; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 i) sender=rtmp://cp115491.live.edgefcs.net/live/tsr2_1_800@45523; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 j) sender=rtmp://cp108478.live.edgefcs.net/live/tv5monde_1_800@45511; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 k) sender=rtmp://cp108477.live.edgefcs.net/live/tf1_1_800@45504; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 l) sender=rtmp://cp108477.live.edgefcs.net/live/m6_1_300@45506; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 m) sender=rtmp://cp115491.live.edgefcs.net/live/viva_1_800@46087; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 n) sender=rtmp://cp115491.live.edgefcs.net/live/euronews_1_800@45525; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 o) sender=rtmp://cp108476.live.edgefcs.net/live/cnn_1_800@45497; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 p) sender=rtmp://cp108477.live.edgefcs.net/live/bbcworld_1_300@45508; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 q) sender=rtmp://cp115491.live.edgefcs.net/live/rusiya_1_800@45521; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 r) sender=rtmp://cp108475.live.edgefcs.net/live/joiz_1_800@52728; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 s) sender=rtmp://cp108478.live.edgefcs.net/live/rsila1_1_800@45513; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 t) sender=rtmp://cp108478.live.edgefcs.net/live/rsila2_2_800@45514; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 u) sender=rtmp://cp108475.live.edgefcs.net/live/rai1_1_800@44470; (rtmpdump -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 v) sender=rtmp://cp108477.live.edgefcs.net/live/rougetv_1_300@57040; (rtmpdump -S $socks -v -r $sender --swfsize $swfsize --swfhash $swfhash -q | $vlcpath -) 2> /dev/null;;
	 y) bbqtv ;;
	 x) 	exit ;;
esac
exit
