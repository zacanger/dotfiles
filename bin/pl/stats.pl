#!/usr/bin/perl
 
# This program generates a profile of the system, including hardware and
# software, and creates a set of HTML pages based upon that information.
#
# Created by Robert Sullivan for Feather Linux
 
sub gen_html_header {
my $title = shift @_;
my $heading = shift @_;
my $header = "<HTML><HEAD><TITLE>$title</TITLE></HEAD><BODY><H1><U>$heading</U></H1><BR>";
return $header;
}
 
sub gen_html_end {
my $date = localtime;
my $end = "<HR><I>Generated at $date</I></BODY></HTML>";
return $end;
}
 
# Make temporary directory for file structure
mkdir "/tmp/stat";
 
### CPU page
$input = `cat /proc/cpuinfo`;
my @cpu = split("\n", $input);
 
foreach $elem (@cpu) {
substr($elem, 0, 11) = "";
$elem=~s/://;
}
open(FH, ">/tmp/stat/cpu.html");
print FH gen_html_header("CPU information", "CPU");
print FH "<B>Megahertz:</B> &nbsp; <I>$cpu[6]Mhz</I> <BR>";
print FH "<B>Model: </B> &nbsp; <I>$cpu[4]</I><BR>";
print FH "<B>Cache size:</B> &nbsp; <I>$cpu[7]</I><BR>";
print FH "<B>Vendor ID:</B> &nbsp; <I>$cpu[1]</I><BR>";
print FH "<B>Bogomips:</B> &nbsp; <I>$cpu[17]</I><BR>";
print FH gen_html_end;
close (FH);
  
### Memory page
$input = `cat /proc/meminfo`;
my @mem = split("\n", $input);
 
foreach $elem (@mem) {
substr($elem, 0, 11) = "";
$elem=~s/ //;
$elem=~s/kB//;
}
# Calculate free memory properly
$mem[4] += $mem[6] + $mem[7];
 
open(FH, ">/tmp/stat/mem.html");
print FH gen_html_header("Memory information", "Memory");
print FH "<B>Total:</B> &nbsp; <I>$mem[3] kB</I><BR>";
print FH "<B>Free:</B> &nbsp; <I>$mem[4] kB</I><BR>";
print FH "<B>Shared:</B> &nbsp; <I>$mem[5] kB</I><BR>";
print FH "<B>Buffers:</B> &nbsp; <I>$mem[6] kB</I><BR>";
print FH "<B>Cached:</B> &nbsp; <I>$mem[7] kB</I><BR>";
print FH "<B>Active:</B> &nbsp; <I>$mem[9] kB</I><BR>";
print FH "<B>Inactive:</B> &nbsp; <I>$mem[10] kB</I><BR>";
print FH gen_html_end;
close (FH);
 
### Net page
 
# First, get information on interfaces via ifconfig
$input = `ifconfig`;
my @net = split("\n", $input);
my @interface;
for ($i=0;$i<=$#net;$i++) {
@interface[$i] = substr($net[$i], 0, 7);
@interface[$i] =~s/ //;
}
 
$input = `cat /etc/sysconfig/netcard`;
@net = split("\n", $input);
$net[0]=~s/\"//g;
$net[1]=~s/\"//g;
 
open (FH, ">/tmp/stat/net.html");
print FH gen_html_header("Network information", "Network");
 
print FH "<B>Network card:</B> &nbsp; <I>". substr($net[0],9,20) ."</I><BR>";
print FH "<B>Driver:</B> &nbsp; <I>". substr($net[1],7,20) ."</I><BR>";
print FH "<B>Hostname</B> &nbsp; <I>" . `hostname` . "</I><BR>";
 
foreach $elem (@interface) {
if ($elem=~/\w/) {
    print FH "<H2><B>" . $elem  ."</B></H2>";
    $input = `ifconfig $elem`;
    if ($input =~ /inet addr:*([0-9|'.']+)/i) {
        print FH "<B>Address:</B> &nbsp; <I>$1</I><BR>";
    }
        if ($input =~ /Bcast:*([0-9|'.']+)/i) {
                print FH "<B>Broadcast address:</B> &nbsp; <I>$1</I><BR>";
        }
    if ($input =~ /Mask:*([0-9|'.']+)/i) {
        print FH "<B>Netmask:</B> &nbsp; <I>$1</I><BR><BR>";
    }
    if ($input =~ /HWaddr *([A-Z0-9|:]+)/i) {
        print FH "<B>HW address:</B> &nbsp; <I>$1</I><BR>";
    }
    if ($input =~ /MTU:*([0-9]+)/i) {
        print FH "<B>MTU:</B> &nbsp; <I>$1</I><BR>";
    }
    if ($input =~ /Interrupt:*([0-9]+)/i) {
        print FH "<B>Interrupt:</B> &nbsp; <I>$1</I><BR>";
    }
    if ($input =~ /Base address:*([0-9|'x']+)/i) {
        print FH "<B>Base address:</B> &nbsp; <I>$1</I><BR>";
    }   
}
}
print FH gen_html_end;
close (FH);
 
### Processes page
 
@net = split("\n",`ps ax`);
 
open (FH, ">/tmp/stat/processes.html");
print FH gen_html_header("Process information", "Processes");
print FH "<PRE>\n";
foreach $elem (@net) {
    if ($elem=~/betaftpd|pss|monkey|sshd|utelnetd/) {
    print FH "<font color=blue>$elem</font>\n";
    }
    elsif ($elem=~/ash|pump|automount|swapd|init/) {
    print FH "<font color=red>$elem</font>\n";
    }
    else {
    print FH "$elem\n";
    }
}
print FH gen_html_end;
close (FH);
 
### Graphics and display page
 
@net = split("\n", `cat /etc/sysconfig/xserver`);
$g_card = substr($net[2],7,length($net[2])-7);
$g_card=~s/\"//;
$g_card=~s/\|/ - /;
 
@net = split("\n", `fbset`);
$net[3]=~s/geometry//;
$net[3]=~s/\s*//;
if ($net[3]=~ /(\d+)\s*(\d+)\s*(\d+)\s*(\d+)\s*(\d+)/) 
{
$x_res = "$1" . 'x' . "$2";
$y_res = "$3" . 'x' . "$4";
$depth = $5;
}
if ($net[2]=~ /H: *([0-9.]+)/) {
$h_ref = $1;
}
if ($net[2]=~ /V: *([0-9.]+)/) {
$v_ref = $1;
}
@net = split("\n", `cat /home/knoppix/.xserverrc 2>/dev/null`);
if ($net[1]=~ /screen *([0-9x]+)/) {
    $res = $1;
}
    else {
    $res = $x_res;
}
 
open (FH, ">/tmp/stat/graphics.html");
print FH gen_html_header("Graphics and display information", "Graphics and Display");
print FH "<B>Graphics card:</B> &nbsp; <I>$g_card</I><BR>";
print FH "<B>Resolution:</B> &nbsp; <I>$res</I><BR>";
print FH "<BR><B>Framebuffer X-resolution: </B> &nbsp; <I>$x_res</I><BR>";
print FH "<B>Framebuffer Y-resolution: </B> &nbsp; <I>$y_res</I><BR>";
print FH "<B>Framebuffer depth: </B> &nbsp; <I>$depth</I><BR>";
print FH "<B>Horizontal framebuffer refresh rate: </B> &nbsp; <I>$h_ref kHz</I><BR>";
print FH "<B>Vertical framebuffer refresh rate: </B> &nbsp; <I>$v_ref kHz</I><BR>";
print FH gen_html_end;
close (FH);
 
### Kernel page
 
$input = `dmesg`;
open (FH, ">/tmp/stat/dmesg.html");
print FH gen_html_header ("dmesg", "dmesg output");
print FH "<PRE>" . $input . "</PRE>";
print FH gen_html_end;
close (FH);
 
$input = `cat /proc/modules`;
open (FH, ">/tmp/stat/modules.html");
print FH gen_html_header ("Module information", "Modules loaded");
print FH "<PRE>" . $input . "</PRE>";
print FH gen_html_end;
close (FH);
 
$input = `sysctl -a`;
open (FH, ">/tmp/stat/sysctl.html");
print FH gen_html_header ("Sysctl", "Output from sysctl");
print FH "<PRE>" . $input . "</PRE>";
print FH gen_html_end;
close (FH);
 
open (FH, ">/tmp/stat/kernel.html");
print FH gen_html_header("Kernel information", "Kernel");
print FH "<A HREF=\"/tmp/stat/dmesg.html\">Output from dmesg</A><BR>";
print FH "<A HREF=\"/tmp/stat/sysctl.html\">Output from sysctl</A><BR>";
print FH "<A HREF=\"/tmp/stat/modules.html\">Currently loaded modules</A><BR><BR>";
print FH "<B>Kernel release:</B> &nbsp; <I>" . `uname -r` . "</I><BR>";
print FH "<B>Kernel name:</B> &nbsp; <I>" . `uname -s` . "</I><BR><BR>";
print FH "<B>Kernel version:</B> &nbsp; <I>" . `uname -v` . "</I><BR>";
print FH "<B>Machine hardware name:</B> &nbsp; <I>".`uname -m`."</I><BR>";
print FH gen_html_end;
close (FH);
 
### Hard drive and mounts page
 
@net = split("\n", `mount`);
@hd_input = split("\n",`fdisk -l`);
foreach $elem (@hd_input) {
    if ($elem =~ /Disk *([\w\/]+)/) {
    push @hd_list, $1;
    }
}
 
open (FH, ">/tmp/stat/mounts.html");
print FH gen_html_header("Mounts and hard drive information", "Hard drives and mounts");
foreach $elem (@hd_list) {
    $short_dev = $elem;
    $short_dev =~s/\/dev//;
    print FH "<H2><B><A HREF=\"/tmp/stat/$short_dev.html\">$elem</A></B></H2>";
    @hd_input = split("\n",`fdisk -l $elem`);
    if ($hd_input[1]=~ /: *([\w\s.]+)/) {
        print FH "<B>Size:</B> &nbsp; <I>$1</I><BR>";
    }
    if ($hd_input[2]=~ /^(\d+) heads/) {
        print FH "<B>Heads:</B> &nbsp; <I>$1</I><BR>";
    }
    if ($hd_input[2]=~ /sectors\/track, *(\d+)/) {
        print FH "<B>Cylinders:</B> &nbsp; <I>$1</I><BR>";
    }
    if ($hd_input[2]=~ /(\d+) sectors\/track/) {
        print FH "<B>Sectors per track:</B> &nbsp; <I>$1</I><BR>";
    }
    open (FH2, ">/tmp/stat/$short_dev.html");
    print FH2 gen_html_header($elem, $elem);
    print FH2 "<PRE>" . join("\n", @hd_input) . "</PRE>";
    print FH2 gen_html_end;
    close (FH2);
}
print FH "<TABLE align=\"center\" cellspacing=\"20\"><CAPTION><B>Mounts:</B></CAPTION><TR><TH>Device<TH>Mount point<TH>Filesystem type";
foreach $elem (@net) {
    if ($elem=~ /^([\w\/]+)/) {
        $device = $1;
    }
    if ($elem=~ /on *([\w\/]+)/) {
        $mount_point = $1;
    }
    if ($elem=~ /type *(\w+)/) {
        $type = $1;
    }
    print FH "<TR><TD><B>$device</B><TD>$mount_point<TD>$type";
}
print FH "</TABLE>";
print FH gen_html_end;
close (FH);
 
### Summary page
 
open (FH, ">/tmp/stat/index.html");
print FH "<HTML><HEAD><TITLE>System Status</TITLE>";
print FH "</HEAD><BODY bgcolor=\"#FFFFFF\">";
print FH "<H1>Feather Linux System Status</H1><BR><H2>";
print FH "<A HREF=\"/tmp/stat/cpu.html\">CPU:</A> &nbsp; $cpu[6] Mhz<BR>"; 
print FH "<A HREF=\"/tmp/stat/mem.html\">Memory:</A> &nbsp; $mem[3] kB<BR>";
print FH "<A HREF=\"/tmp/stat/net.html\">Network</A> interface: &nbsp; $interface[0]<BR>"; 
print FH "<A HREF=\"/tmp/stat/graphics.html\">Graphics</A> card: &nbsp; $g_card<BR>";
print FH "<A HREF=\"/tmp/stat/kernel.html\">Kernel</A> release: &nbsp; " . `uname -r` . "<BR>";
print FH "<A HREF=\"/tmp/stat/processes.html\">Processes</A><BR>";
print FH "<A HREF=\"/tmp/stat/mounts.html\">Hard drive and mounts</A><BR>";
print FH "</H2>" . gen_html_end;
close (FH);
 
### system("dillo /tmp/stat/index.html&");