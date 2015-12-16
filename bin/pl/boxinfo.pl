#!/usr/bin/env perl
# -*-mode:cperl; indent-tabs-mode: nil-*-

## Gather important information about a box
## Output in HTML or MediaWiki friendly format
##
## Greg Sabino Mullane <greg@endpoint.com>
## Copyright End Point Corporation 2008-2010
## BSD licensed
## See: http://bucardo.org/wiki/Boxinfo

use strict;
use 5.006001;
use warnings;
use Data::Dumper   qw{ Dumper     };
use Getopt::Long   qw{ GetOptions };
use File::Basename qw{ basename   };

our $VERSION = '1.4.0';

my $USAGE = "Usage: $0 <options>
 Important options:
 --verbose
 --skippgport=#
 --postgresonly
Set ENV{PG_CONFIG} if not in the path (or adjust your path!)

For complete help, please visit:
http://bucardo.org/wiki/Boxinfo

";

my %opt;
GetOptions(
    \%opt,
    'version',
    'verbose',
    'quiet',
    'help',
    'format=s',
    'os=s',
    'client=s',
    'skippgport=s',
    'postgresonly',
    'nopostgres',
    'postgresnohost',
    'nohost',
    'nomysql',
    'nosendmail',
    'useballoons',
    'timeout=i',
) or die $USAGE;

$opt{help} and die $USAGE;

if ($opt{version}) {
    print "$0 version $VERSION\n";
    exit 0;
}

my $OS           = $opt{os} || $^O;
my $quiet        = $opt{quiet} || 0;
my $verbose      = $opt{verbose} || 0;
my $use_balloons = exists $opt{useballoons} ? $opt{useballoons} : 1;
my $timeout      = exists $opt{timeout} ? $opt{timeout} : 10;
my $format       = $opt{format} || 'wiki';

$opt{use_su_postgres} = 0;

## Used to identify the version of programs and Perl modules
my $versionre = qr{\d+\.\d+(?:\S*)};

## Inline CSS
my $vtop = ' style="vertical-align: top"';

## For ease of writing the HTML later on
my $wrap = '<br />';

## What to print if we can't figure out what something is
my $UNKNOWN_VALUE = '?';
my $UNKNOWN_VERSION = '?';

## Dump the actual output of each command into a debug file
my $debugfile = 'boxinfo.debug';
open my $debugfh, '>', $debugfile or die qq{Could not write "$debugfile": $!\n};
printf {$debugfh} "PROGRAM: $0\nStart: %s\n", scalar localtime();

## When we leave for any reason, close the debug file and remove the temp file
END {
    defined $debugfh and (close $debugfh or die qq{Could not close "$debugfile": $!\n});
    !$quiet and defined $debugfile and print "Raw data is in $debugfile\n";
    unlink '/tmp/boxinfo.tmp';
}

## Output messages per language
my %msg = (
'en' => {
    'time-day'           => q{day},
    'time-days'          => q{days},
    'time-hour'          => q{hour},
    'time-hours'         => q{hours},
    'time-minute'        => q{minute},
    'time-minutes'       => q{minutes},
    'time-month'         => q{month},
    'time-months'        => q{months},
    'time-second'        => q{second},
    'time-seconds'       => q{seconds},
    'time-week'          => q{week},
    'time-weeks'         => q{weeks},
    'time-year'          => q{year},
    'time-years'         => q{years},
},
'fr' => {
    'time-day'           => q{jour},
    'time-days'          => q{jours},
    'time-hour'          => q{heure},
    'time-hours'         => q{heures},
    'time-minute'        => q{minute},
    'time-minutes'       => q{minutes},
    'time-month'         => q{mois},
    'time-months'        => q{mois},
    'time-second'        => q{seconde},
    'time-seconds'       => q{secondes},
    'time-week'          => q{semaine},
    'time-weeks'         => q{semaines},
    'time-year'          => q{année},
    'time-years'         => q{années},
},
'de' => {
},
'es' => {
},
);

## Figure out which language to use for output
our $lang = $ENV{LC_ALL} || $ENV{LC_MESSAGES} || $ENV{LANG} || 'en';
$lang = substr($lang,0,2);

## Figure out our hostname and the short version
my $hostname = qx{hostname};
chomp $hostname;
if (length $hostname) {
    print {$debugfh} "HOST: $hostname\n";
}
my $shorthost = $hostname;
if ($shorthost =~ m{^(\w+\d\.\w+)\.\w+\.\w+$}) {
    $shorthost = $1;
}
else {
    $shorthost =~ s/^(.+?)\..+/$1/;
}

## Pick a client name for use in the page title
my $clientname = 'ACME';
if ($opt{client}) {
    $clientname = $opt{client};
}
elsif ($hostname =~ m{([^\.]+)\.\w+$}) {
    $clientname = ucfirst lc $1;
}

## We put the current time at the top of the report
my $nowtime = qx{date};
chomp $nowtime;

my %data = (
    program_version => $VERSION,
    program_name    => basename ($0),
    program_start   => $nowtime,
    OS              => $OS,
    hostname        => $hostname,
    shorthost       => $shorthost,
    clientname      => $clientname,
);

my %distlist = (
    'redhat'    => ['redhat-release',    'Red Hat',   'release' ],
    'fedora'    => ['fedora-release',    'Fedora',    'release' ],
    'SuSE'      => ['SuSE-release',      'SuSE',      'release' ],
    'gentoo'    => ['gentoo-release',    'Gentoo',    'release' ],
    'debian'    => ['debian_version',    'Debian',    'version' ],
    'slackware' => ['slackware-release', 'Slackware', 'release' ],
    'mandrake'  => ['mandrake-release',  'Mandrake',  'release' ],
    'yellowdog' => ['yellowdog-release', 'Yellowdod', 'release' ],
);

## Gather versions of all kinds of programs (should be run first)
gather_versions();

if ($opt{postgresonly}) {
    ## Postgres information (generic)
    gather_postgresinfo();
    goto GATHERDONE;
}

## yum and apt-get : what's installed?
gather_package_info();

## Postgres information
gather_postgresinfo();

## MySQL information
gather_mysqlinfo();

## uname
gather_uname();

## lsb-release and redhat-release
gather_dist() if $OS eq 'linux';

## memory is very OS specific
gather_memory();

## Is it a VM?
gather_vminfo();

## RightScale information
gather_rightscale();

## Grab all cron information we can find
gather_croninfo();

## All information on disks and filesystems
gather_mounts();

## Detailed info on each disk
#gather_disk_settings();

## Size of disks
gather_disksize();

## User limits
gather_ulimits();

## Environment variables
gather_envs();

## Network interface (ethernet cards)
gather_interfaces();

## Network routing information
gather_routes();

## What is set to run on boot?
gather_chkconfig();

## CPU information
gather_cpuinfo();

## Gather Perl module versions and detailed Perl information
gather_perlinfo();

## Information on the uptime
gather_uptime();

## Puppet info
gather_puppet();

## Loaded modules
gather_lsmod();

## LifeKeeper information
gather_lifekeeper();

## Heartbeat (Linux HA information)
gather_heartbeat();

## Ruby gems (local)
gather_gems();

GATHERDONE:

## remove any temporary constructs from the hash
for (keys %data) {
    delete $data{$_} if $_ =~ /^tmp_/;
}

if ('wiki' eq $format or 'html' eq $format) {
    create_html_output();
}
else {
    die "Unknown format: must be 'html' or 'wiki'\n";
}

exit;


sub slurp_table_info {
    my $arg = shift or die;

    run_command($arg->{command},'tmp_slurp');
    my $slinfo = $data{tmp_slurp};
    if ($arg->{failregex} and $slinfo =~ /$arg->{failregex}/) {
        warn "$arg->{failregexmsg}\n";
        return;
    }
    return unless $slinfo =~ /\w/;
    my ($n,$v);
    my $currname = '';
    for my $line (split /\n/ => $slinfo) {
        next if $line !~ /^(\w+).*\| (.*)/o;
        ($n,$v) = (lc $1,$2||'');
        if ($n eq $arg->{pk}) {
            $currname = $v;
        }
        $arg->{var}{$currname}{$n} = $v;
    }

    return;

} ## end of slurp_table_info


sub gather_uname {

    if ($OS eq 'linux') {
        run_command('uname --kernel-name' => 'Kernel name');
        run_command('uname --nodename' => 'Node name');
        run_command('uname --kernel-release' => 'Kernel release');
        run_command('uname --kernel-version' => 'Kernel version');
        run_command('uname --machine' => 'Hardware name');
        run_command('uname --processor' => 'Processor');
        run_command('uname --hardware-platform' => 'Hardware platform');
    }
    elsif ($OS =~ /bsd/ or $OS =~ /darwin/) {
        run_command('uname -s' => 'Kernel name');
        run_command('uname -n' => 'Node name');
        run_command('uname -r' => 'Kernel release');
        run_command('uname -v' => 'Kernel version');
        run_command('uname -p' => 'Processor');
        run_command('uname -m' => 'Hardware platform');
    }
    else {
        $quiet or warn qq{Cannot gather uname information on OS "$OS"\n};
    }

    return;

} ## end of gather_uname


sub gather_dist {

    my $lsb1 = '/etc/lsb-release';
    my $lsb2 = '/usr/bin/lsb_release';
    if (-e $lsb1) {
        open my $fh, '<', $lsb1 or die qq{Could not open "$lsb1": $!\n};
        while (<$fh>) {
            if (/^DISTRIB_(.+?)=(.+)/) {
                my ($nam,$val) = ($1,$2);
                $val =~ s/^"(.+)"$/$1/;
                $data{lsb_release}{$nam} = $val;
            }
            elsif (/^LSB_VERSION="(\d[\.\d]*)"/) {
                $data{lsb_version} = $1;
            }
            else {
                $quiet or warn qq{Unknown line $. in $lsb1: $_\n};
            }
        }
        close $fh or die qq{Could not close "$lsb1": $!\n};
    }
    ## Check for lsb_release executable for the codename
    if (-e $lsb2) {
        run_command("$lsb2 -a", 'tmp_lsb');
        if ($data{tmp_lsb} =~ /Codename:\s+(.+)/) {
            $data{dist_codename} = $1;
        }
    }

    for my $dist (keys %distlist) {
        my $file = "/etc/$distlist{$dist}->[0]";
        if (-e $file) {
            open my $fh, '<', $file or die qq{Could not open "$file": $!\n};
            while (<$fh>) {
                chomp;
                $data{dist}{$dist} = $_;
                last;
            }
            close $fh or die qq{Could not close "$file": $!\n};
        }
    }

    return;

} ## end of gather_dist


sub gather_vminfo {

    $data{VM} = 'No';

    ## Check for a EC2 motd
    my $file = '/etc/motd';
    if (-e $file) {
        if (open my $fh, '<', $file) {
        my $slurp;
        { local $/; $slurp = <$fh>; }
        close $fh or warn qq{Could not close "$file": $!\n};
        if ($slurp =~ /eip:\s+(\S+)\ninstance id:\s+(\S+)\ntype:\s+(\S+)/) {
            ($data{EC2}{eip}, $data{EC2}{id}, $data{EC2}{type}) = ($1,$2,$3);
        }
        }
    }

    ## Find the EC2 ami version
    $file = '/usr/bin/ec2-ami-tools-version';
    if (-x $file) {
        run_command($file, 'tmp_ec2');
        if ($data{tmp_ec2} =~ /\d/) {
            $data{EC2}{ami} = $data{tmp_ec2};
        }

        ## Grab the rest of the EC2 information on the fly
        if (exists $data{version}{curl}) {
            my %meta;
            my $uri = 'http://169.254.169.254/latest/meta-data/';
            parse_ec2_uri(\%meta, $uri);
            sub parse_ec2_uri {
                my ($tempname, $tempurl) = @_;
                my $info = qx{curl -s $tempurl};
                for my $word (split /\n/ => $info) {
                    if ($word =~ m{/$}) {
                        $tempname->{$word} = {};
                        parse_ec2_uri($tempname->{$word}, "${tempurl}$word");
                    }
                    elsif ($word =~ /\w$/) {
                        my $uri = "${tempurl}$word";
                        $tempname->{$word} = qx{curl -s $uri};
                    }
                }
                return;
            }
            $data{EC2}{meta} = \%meta;
        }
    }

    if ($OS =~ /bsd/ or $OS =~ /darwin/) {
        run_command('ps -o stat', 'tmp_ps');
        if ($data{tmp_ps} =~ /J$/m) {
            $data{VM} = 'BSD jail';
            return;
        }
    }

    run_command('dmidecode', 'tmp_dmi');
    if ($data{tmp_dmi} =~ /VMware/) {
        $data{VM} = 'VMware';
        return;
    }

    if ($data{tmp_dmi} =~ /Manufacturer: Microsoft/) {
        $data{VM} = 'VirtualPC';
        return;
    }

    if (-e '/proc/xen/capabilities') {
        $data{VM} = sprintf 'Xen %s', -e '/proc/xen/grant' ? '3.x' : '2.x';
        return;
        ## Capture xm list?
    }

    return;

} ## end of gather_vminfo


sub gather_rightscale {


    ## If /etc/rightscale.d exists, we can be pretty sure this is a RightScale box

    my $dir = '/etc/rightscale.d';

    return if ! -d $dir;

    $data{RightScale} = {};

    ## What type of cloud?
    my $file = "$dir/cloud";
    if (open my $fh, '<', $file) {
        ## Simply grab the first line
        $data{RightScale}{cloud} = <$fh>;
        chomp $data{RightScale}{cloud};
        close $fh or warn qq{Could not close "$file": $!\n};
    }

    ## What version?
    $file = "$dir/rightscale-release";
    if (open my $fh, '<', $file) {
        ## Simply grab the first line
        $data{RightScale}{version} = <$fh>;
        chomp $data{RightScale}{version};
        close $fh or warn qq{Could not close "$file": $!\n};
    }

    return;

} ## end of gather_rightscale


sub gather_memory {

    if ($OS eq 'linux') {
        run_command('cat /proc/meminfo', 'tmp_meminfo');
        ## Extract ueful bits out and erase the main entry
        ## Seems to be all in kB
        my $info = $data{'tmp_meminfo'};
        my @memstuff = (
            ['Total',  'MemTotal'],
            ['Free',   'MemFree'],
            ['Cached', 'Cached'],
            ['Active', 'Active'],
            ['Inactive', 'Inactive|Inact_clean'],
            ['Swap Total', 'SwapTotal'],
            ['Swap Free', 'SwapFree'],
            );
        for (@memstuff) {
            my ($name,$olabel) = @$_;
            my $found = 0;
            for my $label (split /\s*\|\s*/ => $olabel) {
                if ($info =~ /$label:\s+(\d+) kB/) {
                    my $val = $1 * 1024;
                    $data{memory}{$name} = $val;
                    $data{memory}{pretty}{$name} = pretty_size($val);
                    $found = 1;
                    last;
                }
            }
            if (!$found) {
                $quiet or warn qq{Could not determin "$name" from meminfo output\n};
            }
        }
        ## Now shared memory settings
        for my $name (qw/shmmax shmmni shmall/) {
            run_command("cat /proc/sys/kernel/$name", 'tmp_shm');
            $data{memory}{$name} = delete $data{'tmp_shm'};
            if ($name !~ /i$/) {
                $data{memory}{pretty}{$name} = pretty_size($data{memory}{$name});
            }
        }
        run_command('ipcs -m', 'tmp_active_shared_memory');
        $data{memory}{active_shared} = ($data{tmp_active_shared_memory} =~ y/\n/\n/) - 3;
        $data{memory}{active_shared} = 0 if $data{tmp_active_shared_memory} !~ /\d/;

        run_command('ipcs -s', 'tmp_active_semaphores');
        $data{memory}{active_semaphores} = ($data{tmp_active_semaphores} =~ y/\n/\n/) - 3;
        $data{memory}{active_semaphores} = 0 if $data{tmp_active_semaphores} !~ /\d/;

        run_command('ipcs -q', 'tmp_active_message_queues');
        $data{memory}{active_messages} = ($data{tmp_active_message_queues} =~ y/\n/\n/) - 3;
        $data{memory}{active_messages} = 0 if $data{tmp_active_message_queues} !~ /\d/;

        run_command('ipcs -u', 'tmp_ipcs_summary');
        ## Future: parse the above

        ## Major VM tunables
        for my $vm (qw/swappiness dirty_ratio dirty_background_ratio/) {
            run_command("cat /proc/sys/vm/$vm", 'tmp_swap');
            if ($data{'tmp_swap'} =~ /\d/) {
                $data{vm}{$vm} = $data{'tmp_swap'};
            }
        }

    }
    elsif ($OS =~ /bsd/ or $OS =~ /darwin/) {
        exists $data{'tmp_sysctl'} or run_command('sysctl -a', 'tmp_sysctl');
        my $info = $data{'tmp_sysctl'};

        my @memstuff = (
            ['Total',   'hw.physmem'],
            ['User',    'hw.usermem'],
            ['Real',    'hw.realmem'],
            ['VM kmem', 'vm.kmem_size'],
            );
        for (@memstuff) {
            my ($name,$label) = @$_;
            if ($info =~ /$label\s*[=:]\s*(\d+)/) {
                my $val = $1;
                $data{memory}{$name} = $val;
                $data{memory}{pretty}{$name} = pretty_size($val);
            }
            elsif (!$quiet) {
                if ($OS !~ /darwin/ or $label !~ /realmem|kmem/) {
                    warn qq{Could not find "$label" in sysctl output\n};
                }
            }
        }
        run_command('ipcs -m', 'tmp_active_shared_memory');
        $data{memory}{active_shared} = ($data{tmp_active_shared_memory} =~ y/\n/\n/) - 3;
        $data{memory}{active_shared} = 0 if $data{tmp_active_shared_memory} !~ /\d/;

        run_command('ipcs -s', 'tmp_active_semaphores');
        $data{memory}{active_semaphores} = ($data{tmp_active_semaphores} =~ y/\n/\n/) - 3;
        $data{memory}{active_semaphores} = 0 if $data{tmp_active_semaphores} !~ /\d/;

        run_command('ipcs -q', 'tmp_active_message_queues');
        $data{memory}{active_message} = ($data{tmp_active_message_queues} =~ y/\n/\n/) - 3;
        $data{memory}{active_messages} = 0 if
            (! defined $data{memory}{active_messages} or $data{tmp_active_message_queues} !~ /\d/);

        run_command('ipcs -a', 'tmp_ipcs_all');
        run_command('ipcs -T', 'tmp_ipcs_T');
    }
    else {
        $quiet or warn qq{Do not know how to check OS "$OS" for memory\n};
    }

    return;

} ## end of gather_memory


sub gather_croninfo {

    if ($OS eq 'linux') {
        run_command('cat /etc/crontab', 'tmp_etc_crontab');
        my $info = $data{tmp_etc_crontab};
        for my $var (qw/d hourly daily weekly monthly/) {
            my $crondir = "/etc/cron.$var";
            if (opendir my $dirh, $crondir) {
                for my $file (grep { /^\w/ } readdir $dirh) {
                    run_command("cat $crondir/$file", 'tmp_cron');
                    $info = $data{tmp_cron};
                }
            }
        }
        my $crondir = '/var/spool/cron';
        if (opendir my $dirh, $crondir) {
            for my $file (grep { /^\w/ } readdir $dirh) {
                run_command("cat $crondir/$file", 'tmp_cron');
                $info = $data{tmp_cron};
            }
        }
    }
    elsif ($OS =~ /bsd/ or $OS =~ /darwin/) {
        run_command('cat /etc/crontab', 'tmp_crontab');
        my $info = $data{tmp_crontab};
    }
    else {
        $quiet or warn qq{Do not know how to find cron infomation on OS "$OS"\n};
    }

    return;

} ## end of gather_croninfo

sub gather_mounts {

    if ($OS eq 'linux') {
        run_command('mount -l -f', 'tmp_mount');
        for my $line (split /\n/ => $data{tmp_mount}) {
            if ($line =~ m{^(.+?) on (.+?) type (.+?) \((.+)\)\s*(.*)}) {
                my ($dev,$dir,$type,$options,$label) = ($1,$2,$3,$4,$5);
                $data{fs}{$dev} = {dir => $dir, type => $type, options => $options, readahead => '', scheduler => ''};
                if ($dev =~ m{^\/dev\/([a-z]+)\d*$}) {
                    my $name = $1;
                    if (! exists $data{block}{$name}) {
                        run_command("cat /sys/block/$name/queue/read_ahead_kb", 'tmp_readahead');
                        if ($data{tmp_readahead} =~ /(\d+)/) {
                            $data{block}{$name}{readahead} = (($1 * 512) / 1024) . ' KB';
                        }
                        else {
                            $data{block}{$name}{readahead} = '?';
                        }
                        run_command("cat /sys/block/$name/queue/scheduler", 'tmp_scheduler');
                        my $sc = $data{tmp_scheduler} || '?';
                        $data{block}{$name}{scheduler} = $sc =~ /^cat/ ? '?' : $sc;
                        ## shows all available
                    }
                }
                if ($label =~ s/\[(.+)\]/$1/) {
                    $data{fs}{$dev}{label} = $label;
                }
            }
            else {
                $quiet or warn qq{Do not know how to parse df line: $line\n};
            }
        }
        if (-f '/proc/mdstat') {
            run_command('cat /proc/mdstat', 'tmp_mdstat');
            if ($data{tmp_mdstat} =~ /Personalities : \S/) {
                $data{mdstat} = $data{tmp_mdstat};
            }
        }
    }
    elsif ($OS =~ /bsd/ or $OS =~ /darwin/) {
        run_command('mount -d -v', 'tmp_mount');
        for my $line (split /\n/ => $data{tmp_mount}) {
            ## Example: /dev/foo on / (ufs, local)
            if ($line =~ m{^(.+?) on (.+?)(?: \((.+?)\))*}) {
                my ($dev,$dir,$type,$options,$label) = ($1,$2,$3||'','','');
                my @options;
                ($type, @options) = split /, /, $type;
                $options = join ', ', @options;
                $data{fs}{$dev} = {dir => $dir, type => $type, options => $options};
                if ($label =~ s/\[(.+)\]/$1/) {
                    $data{fs}{$dev}{label} = $label;
                }
            }
            else {
                $quiet or warn qq{Do not know how to parse df line: $line\n};
            }
        }
    }
    else {
        $quiet or die qq{Do not know how to get mount information on OS "$OS"\n};
    }

    return;

}  ## end of gather_mounts


sub gather_disksize {

    if ($OS eq 'linux' or $OS =~ /bsd/ or $OS =~ /darwin/) {
        run_command('df -h -P', 'tmp_disk_space');
        run_command('df -i -P', 'tmp_disk_space_inodes');
        my $info = $data{tmp_disk_space};
        for my $line (split /\n/ => $info) {
            next if $line =~ /^Filesystem/;
            next unless $line =~ s{^(.+?)\s+(\d)}{$2};
            my $name = $1;
            my @info = split /\s+/ => $line;
            if ($OS eq 'linux') {
                $data{fs}{$name}{size} = $info[0];
                $data{fs}{$name}{used} = $info[1];
                $data{fs}{$name}{available} = $info[2];
                $data{fs}{$name}{capacity} = $info[3];
                $data{fs}{$name}{mounted} = $info[4];
            }
            else { ## BSD ... is not dead
                $data{fs}{$name}{size} = $info[1] + $info[2];
                $data{fs}{$name}{used} = $info[1];
                $data{fs}{$name}{available} = $info[2];
                $data{fs}{$name}{capacity} = $info[3];
                $data{fs}{$name}{mounted} = $info[4];
            }
        }
        $info = $data{tmp_disk_space_inodes};
        for my $line (split /\n/ => $info) {
            next if $line =~ /^Filesystem/;
            next unless $line =~ s{^(.+?)\s+(\d)}{$2};
            my $name = $1;
            my @info = split /\s+/ => $line;
            if ($OS eq 'linux') {
                $data{fs}{$name}{inodes} = $info[0];
                $data{fs}{$name}{inodes_used} = $info[1];
                $data{fs}{$name}{inodes_free} = $info[2];
                $data{fs}{$name}{inodes_usage} = $info[3];
            }
            else { ##BSD
                $data{fs}{$name}{inodes} = $info[4] + $info[5];
                $data{fs}{$name}{inodes_used} = $info[4];
                $data{fs}{$name}{inodes_free} = $info[5];
                $data{fs}{$name}{inodes_usage} = $info[6];
            }
        }
    }
    else {
        $quiet or die qq{Do not know how to get disk size information on OS "$OS"\n};
    }

    return;

}  ## end of gather_disksize


sub gather_ulimits {

    run_command(q{bash -c 'ulimit -a'}, 'tmp_ulimit');
    for my $line (split /\n/ => $data{tmp_ulimit}) {
        if ($line =~ /^(.+?)\s+\(.+\) (.+)/) {
            $data{ulimit}{$1} = $2;
        }
        else {
            $quiet or warn qq{Could not parse line of ulimit output: $line\n};
        }
    }

    return;

} ## end of gather_ulimits


sub gather_envs {

    for (keys %ENV) {
        $data{ENV}{$_} = $ENV{$_};
    }

    return;

} ## end of gather_envs


sub gather_interfaces {

    run_command('/sbin/ifconfig -v -a', 'tmp_ifconfig');
    my $int = '?';
    my $hwhex = qr{[a-fA-F0-9:\-]};
    my $ip = qr{[0-9]+\.\d+\.\d+\.\d+};
    for my $line (split /\n/ => $data{tmp_ifconfig}) {
        if ($line =~ /^([\w:]+)/) {
            $int = $1;
        }
        if ($line =~ /\s+HWaddr ($hwhex+)/) {
            $data{interface}{$int}{hardware_address} = $1;
        }
        if ($line =~ /\s+ether ($hwhex+)/) {
            $data{interface}{$int}{hardware_address} = $1;
        }
        if ($line =~ /\s+inet (?:addr:)?($ip)/) {
            $data{interface}{$int}{address} = $1;
        }
        if ($line =~ /\s+Bcast:($ip)/i) {
            $data{interface}{$int}{broadcast} = $1;
        }
        if ($line =~ /\s+Broadcast: ($ip)/i) {
            $data{interface}{$int}{broadcast} = $1;
        }
        if ($line =~ /\s+Mask:($ip)/) {
            $data{interface}{$int}{mask} = $1;
        }
        if ($line =~ /\s+netmask 0x(\S+)/) {
            $data{interface}{$int}{mask} = $1;
        }
        if ($line =~ /\s+inet6 addr: (\S+)/) {
            $data{interface}{$int}{inet6_address} = $1;
        }
        if ($line =~ /\bmtu[: ](\d+)/i) {
            $data{interface}{$int}{mtu} = $1;
            for my $opt (qw/UP BROADCAST RUNNING MULTICAST ALLMULTI PROMISC POINTOPOINT NOARP/) {
                if ($line =~ /\b$opt\b/) {
                    $data{interface}{$int}{$opt} = 1;
                }
            }
        }
        for my $opt ('collisions','txnqueuelen','RX bytes','TX bytes') {
            if ($line =~ /\s+$opt:(\d+)/) {
                $data{interface}{$int}{$opt} = $1;
            }

        }
        if ($line =~ /\s+([RT])X packets:(\d+)/) {
            my $x = lc $1;
            $data{interface}{$int}{"${x}x_packets"} = $2;
            for my $opt (qw/errors dropped overruns frame carrier/) {
                if ($line =~ /\b$opt:(\d+)/) {
                  $data{interface}{$int}{"${x}x_$opt"} = $1;
              }
            }
        }
        if ($line =~ /\boptions=/) {
            while ($line =~ /([A-Z_]+)/g) {
                $data{interface}{$int}{$1} = 1;
            }
        }
    }

    ## Check all hostnames for active interfaces, check the speed
    for my $int (keys %{$data{interface}}) {
        next if ! exists $data{interface}{$int}{UP};

        run_command("ethtool $int", 'tmp_ethtool');
        if ($data{tmp_ethtool} =~ /Speed: (\d+)(\S+)/) {
            $data{interface}{$int}{current_speed} = "$1$2";
            $data{interface}{$int}{nowspeed} = $1;
        }
        if ($data{tmp_ethtool} =~ /Duplex: (\S+)/) {
            $data{interface}{$int}{duplex} = $1;
        }

        if ($data{tmp_ethtool} =~ /Supported link modes: (.+?)Sup/ms) {
            my $sup = $1;
            my $maxspeed = 0;
            while ($sup =~ /(\d+)baseT/g) {
                $maxspeed = $1 if $1 > $maxspeed;
            }
            $data{interface}{$int}{maxspeed} = $maxspeed;
        }

        next if exists $data{interface}{$int}{NOARP};
        my $ip = $data{interface}{$int}{address};
        ip2hostname($ip);
    }

    return;

} ## end of gather_interfaces


sub gather_routes {

    if ($OS eq 'linux') {
        run_command('route -n', 'tmp_route');
        for my $line (split /\n/ => $data{tmp_route}) {
            next unless $line =~ /^\d/o;
            if ($line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\S+)/o) {
                my ($d,$gw,$m,$f,$mt,$ref,$use,$int) = ($1,$2,$3,$4,$5,$6,$7,$8);
                push @{$data{route}}, {dest=>$d,gateway=>$gw,mask=>$m,flags=>$f,metric=>$mt,ref=>$ref,use=>$use,int=>$int};
            }
            else {
                $quiet or warn "Could not parse line of route output: $line\n";
            }
        }
    }
    elsif ($OS =~ /bsd/ or $OS =~ /darwin/) {
        run_command('netstat -r', 'tmp_route');
    }
    else {
        $quiet or warn qq{Do not know how to determine routing information on OS "$OS"\n};
    }

    return;

} ## end of gather_routes


sub gather_versions {

    ## --version
    for my $prog (qw/
      apt-get aptitude autoconf awk bash cc check_postgres.pl chkconfig convert curl cvs dpkg dovecot
      elinks emacs emerge find gcc gdb geos-config git gnome-panel gpg gzip iconv initdb interchange
      knock konquerer links make mii-tool nano ntpd pdns_server perl pg_config pg_dump
      postgres psql puppet python rrdtool rsync ruby s3cmd
      screen sed service svn syslog syslog-ng tar tail_n_mail.pl tail_n_mail tcbmgr vi vim wget yum /) {
        my $maxtime = $timeout;
        if ('yum' eq $prog and 30 > $maxtime) {
            $maxtime = 30;
        }
        run_command("$prog --version", 'tmp_version', $maxtime);
        $data{version}{$prog} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }
    ## version
    for my $prog (qw/ openssl /) {
        run_command("$prog version", 'tmp_version');
        $data{version}{$prog} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }
    ## -version
    for my $prog (qw/ sqlite/) {
        run_command("$prog -version", 'tmp_version');
        $data{version}{$prog} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }
    ## -v
    for my $prog (qw/ lighttpd php rsyslogd slonik /) {
        run_command("$prog -v", 'tmp_version');
        $data{version}{$prog} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }
    ## -V
    for my $prog (qw/ nginx pgbouncer rcs sar ssh /) {
        run_command("$prog -V", 'tmp_version');
        $data{version}{$prog} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }
    ## -help
    for my $prog (qw/ zip /) {
        run_command("$prog -help", 'tmp_version');
        $data{version}{$prog} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }
    ## --help
    for my $prog (qw/ bzip2 ethtool nrpe 7zr /) {
        run_command("$prog --help", 'tmp_version');
        $data{version}{$prog} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }
    ## -h
    for my $prog (qw/ memcached /) {
        run_command("$prog -h", 'tmp_version');
        $data{version}{$prog} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }
    ## Special cases
    run_command('postconf mail_version', 'tmp_version');
    $data{version}{postfix} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;

    if (! $opt{nosendmail}) {
        run_command('echo \\\$Z | sendmail -bt -d0', 'tmp_version');
        $data{version}{sendmail} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;
    }

    run_command('exim -bV', 'tmp_version');
    $data{version}{exim} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;

    run_command('mysql --version', 'tmp_version');
    $data{version}{mysql} = ($data{tmp_version} =~ /($versionre) Distrib ([^,]+)/) ? "$2 ($1)" : $UNKNOWN_VERSION;

    run_command('vsftpd -v 0>&1', 'tmp_version');
    $data{version}{vsftpd} = ($data{tmp_version} =~ /($versionre)/) ? $1 : $UNKNOWN_VERSION;

    run_command('thrift -version', 'tmp_version');
    $data{version}{thrift} = ($data{tmp_version} =~ /(\d+)/) ? $1 : $UNKNOWN_VERSION;

    ## Sometimes we get a trailing comma: remove
    ## Also remove unmatched trailing parens
    for (keys %{$data{version}}) {
        $data{version}{$_} =~ s/,$//;
        $data{version}{$_} =~ s/\)$// if $data{version}{$_} !~ /\(/;
    }

    return;

} ## end of gather_versions


sub gather_package_info {

    ## Gather what's been installed via yum
    if ($data{version}{yum} =~ /\d/) {
        run_command('yum list installed', 'tmp_yumi');
        for my $line (split /\n/ => $data{tmp_yumi}) {
            next if $line !~ /(\S+)\s+(\S+)\s+(\S+)/o;
            my ($name,$ver,$type) = ($1,$2,$3);
            if ($type eq 'installed') {
                $data{yum}{installed}{$name} = $ver;
            }
        }
    }

    ## Gather what's been installed via apt-get / dpkg
    if ($data{version}{'apt-get'} =~ /\d/ and ! exists $data{tmp_yumi}) {
        run_command('aptitude search ~i', 'tmp_apti');
        for my $line (split /\n/ => $data{tmp_apti}) {
            next if $line !~ /^i(..) (\S+)\s+\- (.+)/o;
            my ($flag,$name,$desc) = ($1,$2,$3);
            $data{aptitude}{installed}{$name} = $flag =~ /A/ ? 1 : 0;
        }
    }

    return;

} ## end of gather_package_info


sub gather_chkconfig {

    my $runlevel = qx{runlevel 2>/dev/null} =~ /(\d)$/ ? $1 : 3;

    run_command(qq{chkconfig --list 2>/dev/null | grep '$runlevel:on'}, 'tmp_chkconfig');
    for my $line (split /\n/ => $data{tmp_chkconfig}) {
        if ($line =~ /^(\S+)/) {
            $data{chkconfig}{$1} = 1;
        }
        else {
            $quiet or warn qq{Could not parse line of chkconfig output: $line\n};
        }
    }

    return;

} ## end of gather_chkconfig


sub gather_cpuinfo {

    if ($OS eq 'linux') {
        run_command('cat /proc/cpuinfo', 'tmp_cpuinfo');
        my $info = $data{tmp_cpuinfo};
        my $cpu = 0;
        $data{numcpus} = 0;
        while ($info =~ /^(.+?)\s+: (.+)/gm) {
            my ($name,$value) = ($1,$2);
            if ($name eq 'processor') {
                $data{numcpus}++;
                $cpu = $value;
            }
            if ($name eq 'cpu MHz') {
                $data{cpuinfo}{$cpu}{speed} = (int $value) . ' MHz';
            }
            else {
                $data{cpuinfo}{$cpu}{$name} = $value;
            }
        }
    }
    elsif ($OS =~ /bsd/ or $OS =~ /darwin/) {
        exists $data{'tmp_sysctl'} or run_command('sysctl -a', 'tmp_sysctl');
        my $info = $data{'tmp_sysctl'};
        if ($info =~ /hw.model:\s+(.+)/ or $info =~ /machdep.cpu.brand_string:\s+(.+)/) {
            $data{cpuinfo}{0}{'model name'} = $1;
            if ($1 =~ / (.+GHz)/) {
                $data{cpuinfo}{0}{speed} = $1;
            }
        }
        if ($info =~ /hw.ncpu:\s+(.+)/) {
            $data{numcpus} = $1;
        }
    }
    else {
        $quiet or warn qq{Do not know how to gather CPU information for OS "$OS"\n};
    }

    return;

} ## end of gather_cpuinfo


sub gather_perlinfo {

    $data{perl}{INC} = \@INC;

    run_command('perl -V', 'tmp_perl');
    my $info = $data{tmp_perl};

    $data{perl}{multiplicity} = $UNKNOWN_VALUE;
    if ($info =~ /\busemultiplicity=(\w+)/) {
        my $val = $1;
        if ($val eq 'define') {
            $data{perl}{multiplicity} = 'Yes';
        }
        elsif ($val eq 'undef') {
            $data{perl}{multiplicity} = 'No';
        }
        else {
            $quiet or warn qq{Unknown perl multiplicity value: $val\n};
        }
    }

    $data{perl}{threads} = $UNKNOWN_VALUE;
    if ($info =~ /\busethreads=(\w+)/) {
        my $val = $1;
        if ($val eq 'define') {
            $data{perl}{threads} = 'Yes';
        }
        elsif ($val eq 'undef') {
            $data{perl}{threads} = 'No';
        }
        else {
            $quiet or warn qq{Unknown perl threads value: $val\n};
        }
    }

    $data{perl}{ithreads} = $UNKNOWN_VALUE;
    if ($info =~ /\buseithreads=(\w+)/) {
        my $val = $1;
        if ($val eq 'define') {
            $data{perl}{ithreads} = 'Yes';
        }
        elsif ($val eq 'undef') {
            $data{perl}{ithreads} = 'No';
        }
        else {
            $quiet or warn qq{Unknown perl ithreads value: $val\n};
        }
    }

    ## Modules of interest
    for my $mod (qw/DBI DBD::Pg DBD::Oracle DBD::Sqlite DBD::mysql Moose Mail::Sendmail Sys::Syslog
                    DBIx::Safe Time::HiRes Digest::MD5 YAML Net::SNMP/) {
        delete $data{tmp_module};
        my $COM = qq{perl -M$mod -e 'print \$${mod}::VERSION'};
        run_command($COM, 'tmp_module');
        if ($data{tmp_module} =~ /^($versionre)/) {
          $data{perlmodver}{$mod} = $1;
        }
    }

    return;

} ## end of gather_perlinfo


sub gather_uptime {

    run_command('uptime', 'tmp_uptime');
    my $info = $data{tmp_uptime};
    if ($info =~ / up (\d+ \w+)/) {
        $data{uptime} = $1;
    }
    if ($info =~ /(\d+) user/) {
        $data{users_logged_in} = $1;
    }
    if ($info =~ /load averages?: ([\d\.]+)/) {
        $data{load_average} = $1;
    }

    return;

} ## end of gather_uptime


sub gather_puppet {

    return if ! exists $data{version}{puppet} or $data{version}{puppet} eq $UNKNOWN_VERSION;

    run_command('puppet --genconfig', 'tmp_puppet');
    my $info = $data{tmp_puppet};

    if ($info !~ /^\s*classfile = (.+)/m) {
        warn qq{puppet --genconfig did not reveal a classfile!\n};
        return;
    }
    my $classfile = $1;
    if (! -e $classfile) {
        warn qq{puppet classfile "$classfile" does not exist!\n};
        return;
    }

    run_command("cat $classfile", 'tmp_puppet_classes');
    for my $line (split /\n/ => $data{tmp_puppet_classes}) {
        chomp $line;
        if ($line =~ /\w/) {
            push @{$data{puppet}{class}} => $line;
        }
    }

    return;

} ## end of gather_puppet


sub gather_lsmod {

    run_command('lsmod', 'tmp_lsmod');
    my $info = $data{tmp_lsmod};
    while ($info =~ /^(\S+)\s+(\d+)\s+(.+)/gm) {
        my ($mod,$size,$usedby) = ($1,$2,$3);
        $data{lsmod}{$mod} = {size => $size, usedby => $usedby};
    }

    return;

} ## end of gather_lsmod


sub gather_lifekeeper {

    run_command('lcdstatus -qu', 'tmp_lk');
    my $info = $data{tmp_lk};
    while ($info =~ /^(\S+)  (\S+).+?(\S+)\s+(\d+)\s+(\S+)$/gm) {
        $data{lifekeeper}{service}{$2} =
            {
             local   => $1,
             state   => $3,
             prio    => $4,
             primary => $5,
             };
    }
    while ($info =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\d+)$/gm) {
        $data{lifekeeper}{members}{"$1$3"} =
            {
             machine => $1,
             network => $2,
             address => $3,
             state   => 4,
             prio    => $5,
             };
    }

    return;

} ## end of gather_lifekeeper


sub gather_heartbeat {

    run_command('cl_status hbstatus', 'tmp_heartbeat');
    my $info = $data{tmp_heartbeat};
    if ($info =~ /Heartbeat is/) {
        $data{heartbeat}{active} = $info;
    }

    run_command('cl_status listnodes', 'tmp_heartbeat');
    $info = $data{tmp_heartbeat};
    if ($info =~ /\w/ and $info !~ /ERROR:/) {
        while ($info =~ /(\S+)/g) {
            push @{$data{heartbeat}{node}}, $1;
        }
    }

    for my $file (qw{ /etc/ha.cf /etc/ha.d/ha.cf }) {
        if (-e $file) {
            run_command("cat $file", 'tmp_heartbeat_config');
            if (exists $data{tmp_heartbeat_config}) {
                $data{heartbeat}{config} = $data{tmp_heartbeat_config};
                last;
            }
        }
    }

    my $dir = '/etc/ha.d/resource.d';
    if (-d $dir) {
    my $dh;
    if (opendir my $dh, $dir) {
      my @rlist = grep { -f "$dir/$_" } readdir $dh;
      closedir $dh;
          $data{heartbeat}{resources} = \@rlist;
        }
    }

    my $file = '/etc/ha.d/haresources';
    if (-e $file) {
      run_command("cat $file", 'tmp_heartbeat');
      my $info = $data{tmp_heartbeat};
      if ($info =~ /\w/) {
    chomp $info;
    $data{heartbeat}{haresources} = $info;
      }
    }

    return;

} ## end of gather_heartbeat


sub gather_gems {

    run_command('gem list --local', 'tmp_gems');
    my $info = $data{tmp_gems};

    return if $info !~ /\(\d+\.\d+/;

    while ($info =~ m{^(\w+) \((\d+\.\d+\.?\d*)\)}gsm) {
        $data{gems}{$1} = $2;
    }

    return;

} ## end of gather_gems


sub gather_postgresinfo {

    return if $opt{nopostgres};

    $ENV{PGUSER} ||= 'postgres';

    my $pg_config = $ENV{PG_CONFIG} || 'pg_config';

    run_command($pg_config, 'tmp_pgconfig');
    my $info = $data{tmp_pgconfig};
    if ($info !~ /BINDIR/) {
        $verbose and warn "Call to $pg_config failed: custom path?\n";
    }
    else {
        %{$data{postgres}{pgconfig}} = map { m/(.+?) = (.*)/; $1,$2; } split /\n/ => $info;
    }

    ## Only Linux, but we'll try all:
    run_command('netstat -anp', 'tmp_netstat');
    $info = $data{tmp_netstat};
    $info =~ s{\d+/postgres: pos \S+PGSQL}{SKIP_OLD_POSTGRES}g;
    $info =~ s{\d+/pgbouncer\s+\S+PGSQL\.\d}{SKIP_PGBOUNCER}g;

    my ($oldpguser, $oldpgdb) = ('','');

#unix  2      [ ACC ]     STREAM     LISTENING     568019   17851/postgres      socket/.s.PGSQL.5432

  PG: while ($info =~ /^(.+?)((\S+)\.s\.PGSQL\.(\d+))$/mg) {
        my ($extra,$cluster,$dir,$port) = ($1,$2,$3,$4);
        next if exists $data{postgres}{active_port}{$cluster};
        $data{postgres}{active_port}{$cluster} = { socketdir => $dir, port => $port, extra => $extra };
        my $c = $data{postgres}{active_port}{$cluster};
        my $pid = ($extra =~ /(\d+)\D+$/) ? $1 : '';

        ## Let's grab the user as well - they may not have created a 'postgres' user within the database
        run_command(qq{strings /proc/$pid/environ}, 'tmp_environ');
        if ($data{tmp_environ} =~ /USER=(\w+)/) {
            $c->{user} = $1;
        }

        ## Get the full path for this process
        run_command(qq{pwdx $pid}, 'tmp_pwdx');
        if ($data{tmp_pwdx} =~ m{\(deleted\)}) {
            #warn "DELETED: skipping\n";
            $c->{deleted} = 1;
            next PG;
        }
        if ($data{tmp_pwdx} =~ /^\d+: (\S+)/) {
            $c->{homedir} = $1;
        }

        ## If dir is relative, use the full path instead
        if ($dir !~ m{^/} and $c->{homedir}) {
            $dir = "$c->{homedir}/$dir";
            $c->{socketdir} = $dir;
        }

        ## In case we swapped out the connection information
        if ($oldpguser) {
            $ENV{PGUSER} = $oldpguser;
            $oldpguser = '';
        }
        if ($oldpgdb) {
            $ENV{PGDATABASE} = $oldpgdb;
            $oldpgdb = '';
        }

        ## Let's connect and get some information
        my $usedir = $opt{postgresnohost} ? '' : "-h $dir";
        my $PSQL = qq{psql -X -Ax -qt $usedir -p $port};

        run_command(qq{psql -X -x -t $usedir -p $port -c "\\l+"}, 'tmp_psql');
        my $pinfo = $data{tmp_psql};
        ## Need to figure out the problem, but we cannot set lc_messages first!
        my $problem = '';

        if ($pinfo =~ /FATAL:  Ident authentication failed for user "postgres"/ and 0 == $>) {
            $problem = 'ident';
        }
        elsif ($pinfo =~ /FATAL:  role.+does not exist/ and exists $c->{user}) {
            $problem = 'role';
        }
        elsif ($pinfo =~ /ERROR.+shobj_description/) {
            $problem = 'mismatch';
        }
        elsif ($pinfo =~ /FATAL.+postgres/) {
            $problem = 'ident role mismatch';
        }

      RERUN: {
            last if ! $problem;

            $opt{use_su_postgres} = 0;

            if ($problem =~ s/ident//) {
                warn "Direct psql call failed, trying su -l postgres\n";
                $opt{use_su_postgres} = 1;
                run_command(qq{psql -X -x -t $usedir -p $port -c "\\l+"}, 'tmp_psql');
                $pinfo = $data{tmp_psql};
            }
            elsif ($problem =~ s/role//) {
                warn qq{Failed to connect to Postgres, retrying as user "$c->{user}"\n};
                $ENV{PGUSER} = $c->{user};
                $ENV{PGDATABASE} = 'postgres';
                $opt{use_pg_user} = $c->{user};
                run_command(qq{psql -X -x -t $usedir -p $port -c "\\l+"}, 'tmp_psql');
                $pinfo = $data{tmp_psql};
            }
            elsif ($problem =~ s/mismatch//) {
                ## Mismatched psql version, but non-plussed should work
                run_command(qq{psql -X -x -t $usedir -p $port -c "\\l"}, 'tmp_psql');
                $pinfo = $data{tmp_psql};
            }
            else {
                warn "Unhandled problem: $problem\n";
                $problem = '';
            }

            ## If we still have ways left to try and we failed in certain ways, try again
            if ($problem =~ /\w/) {
                if ($pinfo =~ /FATAL/ or $pinfo eq '?') {
                    redo RERUN;
                }
            }
        }

        my $startupstring = 'database system is starting up';

        if ($pinfo =~ /$startupstring/) {
            warn "DB may be starting up, sleeping for a retry..\n";
            sleep 2;
            run_command(qq{psql -X x -t $usedir -p $port -c "\\l+"}, 'tmp_psql');
            $pinfo = $data{tmp_psql};
            if ($pinfo =~ /$startupstring/) {
                $c->{startingup} = 1;
                ## Can we check for a recovery.conf file?

                ## Make a good guess at the current data directory
                my $datadir = '';

                ## Figure out the PID
                if ($extra =~ m{(\d+)/postgres}) {
                    my $pid = $1;
                    run_command("ps -Afw | grep $pid", 'tmp_pid');
                    if ($data{tmp_pid} =~ /postgres -D (\S+)/) {
                    $datadir = $1;
                    }
                }
                if (! $datadir) {
                    run_command(q{grep postgres /etc/passwd | cut -d":" -f 6}, 'tmp_datadir');
                    if ($data{tmp_datadir} =~ m{^/}) {
                    $datadir = "$data{tmp_datadir}/data";
                    }
                }

                if ($datadir and -d $datadir) {
                    $c->{datadir} = $datadir;
                    my $recfile = "$datadir/recovery.conf";
                    if (-e $recfile) {
                        run_command("cat $recfile", 'tmp_recfile');
                        $c->{recfile} = $data{tmp_recfile};
                    }

                    my $verfile = "$datadir/PG_VERSION";
                    if (-e $verfile) {
                        run_command("cat $verfile", 'tmp_verfile');
                        $c->{version}{full} = $c->{version}{majmin} = $data{tmp_verfile};
                    }

                    for my $linkdir (qw/pg_xlog pg_log pg_clog/) {
                        my $xfile = "$datadir/$linkdir";
                        my $xlog = readlink($xfile);
                        if (defined $xlog and $xlog ne $xfile) {
                            $c->{symlink}{$linkdir} = $xlog;
                        }
                    }

                    my $conffile = "$datadir/postgresql.conf";
                    if (-e $conffile) {
                        run_command("cat $conffile", 'tmp_conffile');
                        my ($source, $unit) = ('File', '???');
                    for my $line (split /\n/ => $data{tmp_conffile}) {
                        $line =~ s/\s+$//;
                        next if ! length $line;
                        next if $line =~ /^\s*#/;
                        if ($line =~ /^\s*(\w+)\s*=\s*(\w+)/) {
                            $c->{setting}{$1} = { value => $2, source => $source, unit => $unit };
                        }
                        elsif ($line =~ /^\s*(\w+)\s*=\s*'(.*?)'/) {
                            $c->{setting}{$1} = { value => $2, source => $source, unit => $unit };
                        }
                        else {
                            warn ">>Could not parse postgresql.conf line: $line\n";
                        }
                    }
                    if (!exists $c->{setting}{data_directory}) {
                        $c->{setting}{data_directory} = { value => $datadir, source => 'Derived', unit => '' };
                    }
                    run_command("du -hs $datadir", 'tmp_ddsize');
                    if ($data{tmp_ddsize} =~ /^(\d+\S+)/) {
                        $c->{datadirsize}= $1;
                    }

                    }
                } ## end found the data

                ## Cause it to get skipped below:
                $pinfo = 'FATAL: SKIP';
            }
        }

        if (skip_pg_database($pinfo,$port,$dir)) {
            $opt{use_su_postgres} = 0;
            next PG;
        }

        ## If no match, see if we can get the complete socket
        if ($pinfo !~ /\|/ and $dir !~ m{^/}) {
            run_command("locate ${dir}.s.PGSQL.$port", 'tmp_psql');
            if ($data{tmp_psql} =~ /^(.*${dir})\.s\.PGSQL\.$port\b/) {
                my $newsock = $1;
                my $sdir = "$newsock.s.PGSQL.$port";
                if (-S $sdir) {
                    $dir = $c->{largesocketdir} = $newsock;
                    run_command(qq{psql -X -x -t -A $usedir -p $port -c "\\l+"}, 'tmp_psql');
                    $pinfo = $data{tmp_psql};
                    if ($pinfo !~ /\|/) {
                        ## Try as the user that owns the database
                        $oldpguser = $ENV{PGUSER} || 'postgres';
                        $oldpgdb = $ENV{PGDATABASE} || 'postgres';
                        run_command(qq{stat -c '\%U' $sdir}, 'tmp_stat');
                        if ($data{tmp_stat} =~ /(\w+)/) {
                            $ENV{PGUSER} = $1;
                            $ENV{PGDATABASE} = 'postgres';
                        }
                        run_command(qq{psql -X -x -t -A $usedir -p $port -c "\\l+"}, 'tmp_psql');
                        $pinfo = $data{tmp_psql};
                    }
                }
            }
        }
        if ($pinfo !~ /\|/) {
            warn "Could not find database at host $dir and port $port\n";
            $opt{use_su_postgres} = 0;
            next PG;
        }

        my ($n,$v);
        my $currname = '';

        for my $db (split /\n/ => $pinfo) {
            if ($db =~ /^(\w+).*\| (.*)/) {
                ($n,$v) = (lc $1,$2||'');
                if ($n eq 'name') {
                    $currname = $v;
                }
                $c->{db}{$currname}{$n} = $v;
            }
            elsif ($db =~ /^\-\-/) {
                ## EOR
            }
            elsif ($db =~ /^\s+[:\|] (.+)/) {
                $c->{db}{$currname}{$n} .= "\n$1";
            }
            else {
                die "Unknown line: $db";
            }
        }

        my $SQL = 'SELECT datname,datistemplate,datallowconn,datconnlimit,age(datfrozenxid),datacl,pg_database_size(oid) FROM pg_database';
        run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL"}, 'tmp_psql');
        $pinfo = $data{tmp_psql};
        if ($pinfo =~ /ERROR/ or $pinfo =~ /FATAL/) {
            warn "Could not connect to Postgres: $pinfo\n";
            $opt{use_su_postgres} = 0;
            next PG;
        }

        for my $db (split /\n/ => $pinfo) {
            my ($name,$template,$canconn,$limit,$age,$acl,$size) = split /\|/ => $db;
            my $info = $c->{db}{$name};
            $info->{template} = $template eq 't' ? 'Yes' : 'No';
            $info->{canconn} = $canconn eq 't' ? 'Yes' : 'No';
            $info->{limit} = $limit;
            $info->{acl} = $acl;
            $info->{age} = $age;
            $info->{size} = pretty_size($size,1);
            ($info->{quoted_db_name} = $name) =~ s/"/\\"/g;
        }

        ## Tablespace info
        $SQL = 'SELECT spcname, spcowner, spclocation, spcacl FROM pg_tablespace';
        run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL"}, 'tmp_psql');
        $pinfo = $data{tmp_psql};
        for my $db (split /\n/ => $pinfo) {
            my ($name,$owner,$location,$acl) = split /\|/ => $db;
            next if ($name eq 'pg_default' or $name eq 'pg_global') and $location !~ /\w/;
            my $info = $c->{dbtablespace}{$name} = [$location,$owner,$acl];
            $data{gottablespaces} = 1;
        }

        $SQL = 'SELECT version()';
        run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL"}, 'tmp_psql');
        $pinfo = $data{tmp_psql};
        die $pinfo if $pinfo !~ /PostgreSQL (\S+)/;
        my $ver = $1;
        $c->{version}{full} = $ver;
        ## May be something like: 8.4beta1
        $ver =~ /^(\d+)\.(\d+)(.+)/ or die "Could not determine Postgres version from: $ver\n";
        $c->{version}{major} = $1;
        $c->{version}{minor} = $2;
        $ver = $c->{version}{majmin} = "$1.$2";
        ($c->{version}{revision} = $3) =~ s/^\.//;

        $SQL = 'SELECT name,source,unit,setting FROM pg_settings';
        if ($ver < 8.2) {
            $SQL =~ s/unit/'?' AS unit/;
        }
        run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL"}, 'tmp_psql');
        $pinfo = $data{tmp_psql};
        die $pinfo if $pinfo =~ /ERROR/ or $pinfo =~ /FATAL/;
        for my $line (split /\n/ => $pinfo) {
            my ($name,$source,$unit,$setting) = split /\|/ => $line => 4;
            $c->{setting}{$name} = { value => $setting, source => $source, unit => $unit };
        }

        my $datadir = $c->{setting}{data_directory}{value};
        for my $linkdir (qw/pg_xlog pg_log pg_clog/) {
            my $xfile = "$datadir/$linkdir";
            my $xlog = readlink($xfile);
            if (defined $xlog and $xlog ne $xfile) {
                $c->{symlink}{$linkdir} = $xlog;
            }
        }

        ## Things individual to each database
        for my $db (sort keys %{$c->{db}}) {
            my $info = $c->{db}{$db};
            my $qdb = $info->{quoted_db_name};
            next if $info->{canconn} eq 'No';
            $SQL = 'SELECT relkind, count(*) FROM pg_class c JOIN pg_namespace n ON (n.oid = c.relnamespace) '.
                q{WHERE n.nspname !~ '^pg_' AND n.nspname <> 'information_schema' GROUP BY 1};
            run_command(qq{psql -X -t -A $usedir -p $port --dbname "$qdb" -c "$SQL"}, 'tmp_psql');
            $pinfo = $data{tmp_psql};
            die $pinfo if $pinfo =~ /ERROR/ or $pinfo =~ /FATAL/;
            for my $line (split /\n/ => $pinfo) {
                my ($relkind,$count) = split /\|/ => $line;
                $c->{db}{$db}{relcount}{$relkind} = $count;
            }

            ## Slony stuff
            $SQL = q{SELECT nspname FROM pg_attribute a }
                . q{JOIN pg_class c ON (c.oid = a.attrelid AND c.relname = 'sl_log_1') }
                . q{JOIN pg_namespace n ON (n.oid = c.relnamespace) }
                . q{WHERE attname = 'log_xid'};
            run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_slony');
            $pinfo = $data{tmp_slony};
            if ($pinfo =~ /\w/) {
                my $slonyschema = $info->{slony}{schema} = $pinfo;
                $data{gotslony}++;
                $c->{gotslony}++;

                $SQL = "SELECT pa_server || '-' || pa_client, pa_conninfo FROM $slonyschema.sl_path ORDER BY pa_server, pa_client";
                run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_slony');
                $pinfo = $data{tmp_slony};
                for my $line (split /\n/ => $pinfo) {
                    push @{$info->{slony}{paths}}, $line;
                }

                $SQL = "SELECT tab_nspname || '.' || tab_relname FROM $slonyschema.sl_table ORDER BY tab_id";
                run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_slony');
                $pinfo = $data{tmp_slony};
                for my $line (split /\n/ => $pinfo) {
                    push @{$info->{slony}{tables}}, $line;
                }

                $SQL = "SELECT seq_nspname || '.' || seq_relname FROM $slonyschema.sl_sequence ORDER BY seq_id";
                run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_slony');
                $pinfo = $data{tmp_slony};
                for my $line (split /\n/ => $pinfo) {
                    push @{$info->{slony}{sequences}}, $line;
                }
            } ## end Slony

            ## Bucardo stuff
          BUCARDO: {
            ## Is this a master Bucardo database?
            if ($qdb eq 'bucardo') {

                $data{gotbucardo}++;
                $c->{gotbucardo}++;

                ## Slurp in information from various bucardo tables
                ## Complain if the table does not exist
                my %bucardo_table = (
                    db             => 'name',
                    sync           => 'name',
                    goat           => 'id',
                    herd           => 'name',
                    bucardo_config => 'setting',
                );
                for my $tablename (sort keys %bucardo_table) {
                    $info->{bucardo}{$tablename} ||= {};
                    $SQL = qq{SELECT * FROM bucardo.$tablename};
                    slurp_table_info({
                        command      => qq{psql -X -x -t $usedir -p $port -c "$SQL" --dbname "$qdb"},
                        var          => $info->{bucardo}{$tablename},
                        pk           => $bucardo_table{$tablename},
                        failregex    => "bucardo.$tablename",
                        failregexmsg => "Odd - database named bucardo has no bucardo.$tablename table!",
                     });
                }

            } ## end if db named bucardo
            } ## end BUCARDO

            ## pg_autovacuum settings
            $SQL = q{SELECT * FROM pg_autovacuum};
            run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_slony');
            $pinfo = $data{tmp_autovac};

        } ## end each db

        $SQL = q{SELECT nspname FROM pg_catalog.pg_namespace WHERE nspname !~ '^pg_' AND nspname <> 'information_schema'};
        for my $db (sort keys %{$c->{db}}) {
            my $info = $c->{db}{$db};
            next if $info->{canconn} eq 'No';
            my $qdb = $info->{quoted_db_name};
            run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_psql');
            $pinfo = $data{tmp_psql};
            die $pinfo if $pinfo =~ /ERROR/ or $pinfo =~ /FATAL/;
            for my $line (split /\n/ => $pinfo) {
                next if $line !~ /\w/;
                $c->{db}{$db}{relcount}{schema}++;
                $c->{db}{$db}{schema}{$line} = 1;
            }
        }

        $SQL = 'SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON (n.oid = p.pronamespace) '.
            q{WHERE n.nspname !~ '^pg_' AND n.nspname <> 'information_schema'};
        for my $db (sort keys %{$c->{db}}) {
            my $info = $c->{db}{$db};
            next if $info->{canconn} eq 'No';
            my $qdb = $info->{quoted_db_name};
            run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_psql');
            $pinfo = $data{tmp_psql};
            die $pinfo if $pinfo =~ /ERROR/ or $pinfo =~ /FATAL/;
            for my $line (split /\n/ => $pinfo) {
                next unless $line =~ /(\d+)/;
                $c->{db}{$db}{relcount}{f} = $1;
            }
        }

        ## Languages
        $SQL = 'SELECT lanname FROM pg_language WHERE lanispl IS TRUE';
        for my $db (sort keys %{$c->{db}}) {
            my $info = $c->{db}{$db};
            next if $info->{canconn} eq 'No';
            my $qdb = $info->{quoted_db_name};
            run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_psql');
            $pinfo = $data{tmp_psql};
            die $pinfo if $pinfo =~ /ERROR/ or $pinfo =~ /FATAL/;
            for my $line (split /\n/ => $pinfo) {
                next unless $line =~ /(\w+)/;
                $c->{db}{$db}{language}{$1}++;
            }
        }

        ## Disabled triggers
        my $SQL82 = q{SELECT tgrelid::regclass, tgname, tgenabled FROM pg_trigger WHERE tgenabled IS NOT TRUE ORDER BY tgname};
        my $SQL83 = q{SELECT tgrelid::regclass, tgname, tgenabled FROM pg_trigger WHERE tgenabled = 'D' ORDER BY tgname};
        for my $db (sort keys %{$c->{db}}) {
            my $info = $c->{db}{$db};
            next if $info->{canconn} eq 'No';
            my $qdb = $info->{quoted_db_name};
            $SQL = $ver >= 8.3 ? $SQL83 : $SQL82;
            run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_psql');
            $pinfo = $data{tmp_psql};
            die $pinfo if $pinfo =~ /ERROR/ or $pinfo =~ /FATAL/;
            for my $line (split /\n/ => $pinfo) {
                if ($line !~ /(.+?)\|(.+?)\|(.+)/) {
                    warn "Invalid line for trigger checks: $line\n";
                    next;
                }
                push @{$c->{db}{$db}{disabled_triggers}}, [$1,$2,$3];
                $data{postgres}{problems}++;
                $c->{problems}++;
                $c->{db}{$db}{problems}++;
            }
        }

        ## Installed modules
        for my $db (sort keys %{$c->{db}}) {
            my $info = $c->{db}{$db};
            next if $info->{canconn} eq 'No';
            my $qdb = $info->{quoted_db_name};
            ## PostGIS
            $SQL = "SELECT 1 FROM pg_proc WHERE proname = 'postgis_full_version'";
            run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_psql');
            $pinfo = $data{tmp_psql};
            if ($pinfo =~ /1/) {
                for my $name (qw/postgis_full_version postgis_lib_build_date postgis_scripts_build_date/) {
                    $SQL = "SET lc_messages='C'; SELECT $name()";
                    run_command(qq{psql -X -t -A $usedir -p $port -c "$SQL" --dbname "$qdb"}, 'tmp_psql');
                    $pinfo = $data{tmp_psql};
                    if ($pinfo !~ /ERROR/) {
                        $info->{postgis}{$name} = $data{tmp_psql};
                        $c->{gotpostgis}++;
                        $data{gotpostgis}++;
                    }
                }
            }
            ## Others
          CNAME:
            my %contrib_modules = (
                'citext'          => ['F:citext_smaller',        ''],
                'cube'            => ['F:cube_distance',         ''],
                'dblink'          => ['F:dblink_connect',        ''],
                'earthdistance'   => ['F:earth_distance',        ''],
                'fuzzystrmatch'   => ['F:dmetaphone_alt',        ''],
                'hstore'          => ['F:hstore_out',            ''],
                'intarray'        => ['F:intarray_del_elem',     ''],
                'ltree'           => ['F:ltree2text',            ''],
                'pgcrypto'        => ['F:gen_salt',              ''],
                'pg_freespacemap' => ['F:pg_freespace',          ''],
                'pgstattuple'     => ['F:pgstattuple',           ''],
                'pg_trgm'         => ['F:show_trgm',             ''],
                'tablefunc'       => ['F:crosstab4',             ''],
                'tsearch2'        => ['F:to_tsvector',           '8.3'],
                'uuid'            => ['F:uuid_ns_x500',          ''],
            );

          CNAME: for my $cname (sort keys %contrib_modules) {
                my ($action,$version) = @{$contrib_modules{$cname}};
                if ($action =~ s/F://) {
                    $SQL = "SELECT count(*) FROM pg_proc WHERE proname = '$action'";
                    run_command(qq{$PSQL -c "$SQL" --dbname "$qdb"}, 'tmp_psql');
                    if ($data{tmp_psql} =~ /(\d+)/) {
                        my $num = $1;
                        if ($num) {
                            if ($version =~ /(\d+)\.(\d+)/) {
                                my ($maj,$min) = ($1,$2);
                                my ($Maj,$Min) = ($c->{version}{major},$c->{version}{minor});
                                next CNAME if $Maj > $maj or ($Maj==$maj and $Min >= $min);
                            }
                            $info->{contrib}{$cname} = 1;
                            $c->{hascontrib}++;
                        }
                    }
                }
                else {
                    die "Do not know how to handle action of $action for contrib module $cname!\n";
                }
            }
        }


        $opt{use_su_postgres} = 0;


    } ## end each active port

    return;

} ## end of gather_postgresinfo


sub gather_mysqlinfo {

    return if $opt{nomysql} or ! exists $data{version}{mysql} or $data{version}{mysql} eq $UNKNOWN_VERSION;

    run_command(q{mysqlshow --verbose}, 'tmp_mysqlshow');
    my $info = $data{tmp_mysqlshow};

    for my $line (split /\n/ => $info) {
        next unless $line =~ m{^\| (.+)\s+\|\s+(\d+) \|$};
        $data{mysql}{database}{$1} = {tables => $2};
    }

    run_command(q{mysql_config --port}, 'tmp_mysqlport');
    $data{mysql}{port} = $data{tmp_mysqlport} =~ /(\d+)/ ? $1 : '?';

    run_command(q{mysql_config --socket}, 'tmp_mysqlsocket');
    $data{mysql}{socket} = $data{tmp_mysqlsocket} || '?';

    run_command(q{mysqladmin status}, 'tmp_mysqladmin');
    if ($data{tmp_mysqladmin} =~ /Uptime/) {
        @{$data{mysql}{status}} = split /  / => $data{tmp_mysqladmin};
    }

    return;

} ## end of gather_mysqlinfo


sub skip_pg_database {

    ## Return true if we should skip this database
    ## Pass in the result from run_command

    my $msg = shift;

    return 0 if $msg !~ /ERROR/ and $msg !~ /FATAL/;

    return 1 if $msg =~ /FATAL: SKIP/;

    my $port = shift or die;
    my $socket = shift or die;

    if (exists $opt{skippgport}) {
        if ($opt{skippgport} =~ /\b$port\b/) {
            $verbose and warn "Skipping Postgres database port $port\n";
            return 1;
        }
    }

    my $line = (caller)[2];
    warn qq{(Line $line) Connection to port $port, socket $socket failed: $msg\n};
    warn qq{Perhaps skip this cluster with --skippgport=$port?\n};
    return 1;

} ## end of skip_pg_database


sub pretty_size {

    ## Transform number of bytes to a SI display similar to Postgres' format

    my $bytes = shift;

    return "$bytes bytes" if $bytes < 10240;

    my @unit = qw/kB MB GB TB PB EB YB ZB/;

    for my $p (1..@unit) {
        if ($bytes <= 1024**$p) {
            $bytes /= (1024**($p-1));
            my $final = sprintf '%.2f %s', $bytes, $unit[$p-2];
            $final =~ s/\.00 / /;
            return $final;
        }
    }

    return $bytes;

} ## end of pretty_size


sub pretty_conf {

    ## Transform ugly configuration values to something better

    my ($name,$val,$unit) = @_;

    my $newval = $val;

    return $newval if $unit eq '???';

    ## -1 is always 'off'
    if ('-1' eq $val) {
        if ($name eq 'autovacuum_vacuum_cost_delay') {
            $newval = '-1 (use vacuum_cost_delay)';
        }
        elsif ($name eq 'autovacuum_vacuum_cost_limit') {
            $newval = '-1 (use vacuum_cost_limit)';
        }
        else {
            $newval = '-1 (off)';
        }
    }
    ## 0 can have a special meaning, but never gets expanded per below
    elsif ('0' eq $val) {
        if ($name eq 'log_temp_files') {
            $newval = '0 (log all temporary files)';
        }
        elsif ($name eq 'log_min_duration_statement') {
            $newval = '0 (log all durations)';
        }
        elsif ($name eq 'log_autovacuum_min_duration') {
            $newval = '0 (log all autovac activity)';
        }
        elsif ($name eq 'archive_timeout' or $name eq 'checkpoint_warning') {
            $newval = '0 (off)';
        }
        elsif ($name eq 'log_rotation_size' or $name eq 'log_rotation_age') {
            $newval = '0 (no rotation)';
        }
        elsif ($name eq 'statement_timeout') {
            $newval = '0 (disabled)';
        }
        else {
            $newval = '0';
        }
    }
    elsif ($unit eq 's' or $unit eq 'ms' or $unit eq 'min') {
        if (0 == $val) {
            $newval = '0';
        }
        else {
            $newval = sprintf '%s (%s)', $val, pretty_time
                ($unit eq 's' ? $val : $unit eq 'ms' ? ($val/1000) : ($val*60));
        }
    }
    elsif ($unit eq '8kB') {
        $newval = !$val ? $val : sprintf "$val (%s)", pretty_size($val*8192);
    }
    elsif ($unit eq 'kB') {
        $newval = !$val ? $val : sprintf "$val (%s)", pretty_size($val*1024);
    }

    return $newval;

} ## end of pretty_conf


sub msg { ## no critic

    my $name = shift || '?';

    my $msg = '';

    if (exists $msg{$lang}{$name}) {
        $msg = $msg{$lang}{$name};
    }
    elsif (exists $msg{'en'}{$name}) {
        $msg = $msg{'en'}{$name};
    }
    else {
        my $line = (caller)[2];
        die qq{Invalid message "$name" from line $line\n};
    }

    my $x=1;
    {
        my $val = $_[$x-1];
        $val = '?' if ! defined $val;
        last unless $msg =~ s/\$$x/$val/g;
        $x++;
        redo;
    }
    return $msg;

} ## end of msg


sub pretty_time {

    ## Transform number of seconds to a more human-readable format
    ## First argument is number of seconds
    ## Second optional arg is highest transform: s,m,h,d,w
    ## If uppercase, it indicates to "round that one out"

    my $sec = shift;
    my $tweak = shift || '';

    ## Round to two decimal places, then trim the rest
    $sec = sprintf '%.2f', $sec;
    $sec =~ s/0+$//o;
    $sec =~ s/\.$//o;

    ## Just seconds (< 2:00)
    if ($sec < 120 or $tweak =~ /s/) {
        return sprintf "$sec %s", $sec==1 ? msg('time-second') : msg('time-seconds');
    }

    ## Minutes and seconds (< 60:00)
    if ($sec < 60*60 or $tweak =~ /m/) {
        my $min = int $sec / 60;
        $sec %= 60;
        my $ret = sprintf "$min %s", $min==1 ? msg('time-minute') : msg('time-minutes');
        $sec and $tweak !~ /S/ and $ret .= sprintf " $sec %s", $sec==1 ? msg('time-second') : msg('time-seconds');
        return $ret;
    }

    ## Hours, minutes, and seconds (< 48:00:00)
    if ($sec < 60*60*24*2 or $tweak =~ /h/) {
        my $hour = int $sec / (60*60);
        $sec -= ($hour*60*60);
        my $min = int $sec / 60;
        $sec -= ($min*60);
        my $ret = sprintf "$hour %s", $hour==1 ? msg('time-hour') : msg('time-hours');
        $min and $tweak !~ /M/ and $ret .= sprintf " $min %s", $min==1 ? msg('time-minute') : msg('time-minutes');
        $sec and $tweak !~ /[SM]/ and $ret .= sprintf " $sec %s", $sec==1 ? msg('time-second') : msg('time-seconds');
        return $ret;
    }

    ## Days, hours, minutes, and seconds (< 28 days)
    if ($sec < 60*60*24*28 or $tweak =~ /d/) {
        my $day = int $sec / (60*60*24);
        $sec -= ($day*60*60*24);
        my $our = int $sec / (60*60);
        $sec -= ($our*60*60);
        my $min = int $sec / 60;
        $sec -= ($min*60);
        my $ret = sprintf "$day %s", $day==1 ? msg('time-day') : msg('time-days');
        $our and $tweak !~ /H/     and $ret .= sprintf " $our %s", $our==1 ? msg('time-hour')   : msg('time-hours');
        $min and $tweak !~ /[HM]/  and $ret .= sprintf " $min %s", $min==1 ? msg('time-minute') : msg('time-minutes');
        $sec and $tweak !~ /[HMS]/ and $ret .= sprintf " $sec %s", $sec==1 ? msg('time-second') : msg('time-seconds');
        return $ret;
    }

    ## Weeks, days, hours, minutes, and seconds (< 28 days)
    my $week = int $sec / (60*60*24*7);
    $sec -= ($week*60*60*24*7);
    my $day = int $sec / (60*60*24);
    $sec -= ($day*60*60*24);
    my $our = int $sec / (60*60);
    $sec -= ($our*60*60);
    my $min = int $sec / 60;
    $sec -= ($min*60);
    my $ret = sprintf "$week %s", $week==1 ? msg('time-week') : msg('time-weeks');
    $day and $tweak !~ /D/      and $ret .= sprintf " $day %s", $day==1 ? msg('time-day')    : msg('time-days');
    $our and $tweak !~ /[DH]/   and $ret .= sprintf " $our %s", $our==1 ? msg('time-hour')   : msg('time-hours');
    $min and $tweak !~ /[DHM]/  and $ret .= sprintf " $min %s", $min==1 ? msg('time-minute') : msg('time-minutes');
    $sec and $tweak !~ /[DHMS]/ and $ret .= sprintf " $sec %s", $sec==1 ? msg('time-second') : msg('time-seconds');

    return $ret;

} ## end of pretty_time


sub ip2hostname {

    my $ip = shift || '';

    return if exists $data{ip}{$ip};

    return if $opt{nohost};

    if ($ip eq '127.0.0.1') {
        $data{ip}{$ip} = 'localhost';
        return;
    }

    run_command("host -r -t A $ip", "tmp_host_$ip");

    $data{ip}{$ip} = $data{"tmp_host_$ip"};

    if ($data{ip}{$ip} =~ /NXDOMAIN/) {
        $data{ip}{$ip} = '';
    }

    return;

} ## end of ip2hostname


sub run_command {

    ## Attempt to run a command and gather the input
    ## We store the raw input, and store pretty info in the main hash

    my $command = shift;
    my $name = shift or die "Need a name!\n";
    my $specifictimeout = shift || 0;

    if ($opt{use_su_postgres} and $command =~ /^psql/) {
        if ($command =~ s{-c "(.+?)"}{}) {
            my $innercom = $1;
            my $file = '/tmp/boxinfo.tmp';
            open my $fh, '>', $file or die qq{Could not open "$file": $!\n};
            print {$fh} $innercom;
            close $fh or warn qq{Could not close "$file": $!\n};
            $command = qq{su -l postgres --command "$command --file $file"};
            $verbose and warn "New command: $command\n";
        }
    }

    $verbose and warn "run_command $command => $name\n";

    printf {$debugfh} "\nCOMMAND: %s\nNAME: $name\nTIME: %s\nRESULT: ", $command, scalar localtime();

    local $ENV{LC_ALL} = 'C';

    my $result;
    my $madeit = 0;
    alarm 0;
    local $SIG{ALRM} = sub { die 'Timed out' };
    my $localtimeout = $specifictimeout || $timeout;
    eval {
        alarm $localtimeout;
        $result = qx{$command 2>&1};
        $madeit = 1;
    };
    if ($@) {
        if ($@ =~ /Timed out/o) {
            warn "Command timed out at $localtimeout seconds!\n";
            warn "Command: $command\n";
            $madeit = 0;
        }
    }
    alarm 0;
    if (!$madeit) {
        $data{$name} = '?';
        $data{failed_command}{$command} = $@;
        print {$debugfh} "FAIL ($@)\n";
        return;
    }
    if (! defined $result)  {
        $data{$name} = $UNKNOWN_VALUE;
        print {$debugfh} "UNDEFINED\n";
        return;
    }

    chomp $result;
    $data{$name} = $result;
    print {$debugfh} "OK $result\n";

    $verbose and warn "Command finished OK\n";

    return;

} ## end of run_command


sub create_html_output {

    my $file = 'boxinfo.html';
    open my $fh, '>', $file or die qq{Could not open "$file": $!\n};
    my $oldselect = select $fh;

    my @ip;
    for my $int (sort keys %{$data{interface}}) {
        my $d = $data{interface}{$int};
        next unless exists $d->{UP} and exists $d->{RUNNING} and exists $d->{address};
        my $ip = $d->{address};
        my $host = $data{ip}{$ip} || $UNKNOWN_VALUE;
        push @ip, qq{<b>$ip</b> $host};
    }
    my $iplist = join "<br />\n" => @ip;

    if ('html' eq $format) {
        print q{<style>
table.boxinfo th { color: #006600; vertical-align: top; padding-top: 7px; padding-bottom: 15px; text-align: left; padding-left: 5px; padding-right: 5px; }

table { empty-cells: show; margin-bottom: 20px; }

table.bottom { margin-bottom: 30px; }

table.boxinfo2 td { padding-left: 5px; padding-right: 5px; padding-top: 7px; padding-bottom: 15px; vertical-align: middle;}

table.boxinfo td { padding-left: 2px; padding-right: 2px; vertical-align: middle; font-weight: bold;}

table.boxinfo td.numbers { color: black; text-align: right; }

table.plain td { font-weight: normal; }

table.boxinfo td.activeip { color: black; font-weight: bolder; }

</style>};

    }

    if ('wiki' eq $format) {
        my $gotpg = exists $data{postgres}{active_port} ? 1 : 0;
        printf qq{[[Category:%s servers]]\n\n},
            $gotpg ? 'Postgres' : 'Client';
        printf qq{<h2>[[%s]] %s %s:</h2>\n\n},
            $data{clientname},
                $gotpg ? 'Postgres server' : 'server',
                    $data{shorthost};
    }

    my $cols = 1;
    print qq{<table class="boxinfo" style="border: solid black 2px">\n};

    print qq{<tr><th>Date gathered:</th><td><b>$data{program_start}</b></td></tr>\n};

    print qq{<tr><th>Program version:</th><td><b>$data{program_version}</b></td></tr>\n};

    print qq{<tr><th>Hostname:</th><td><b>$data{hostname}</b></td></tr>\n};

    print qq{<tr><th>OS:</th><td><b>$data{OS}</b></td></tr>\n};

    if ($opt{postgresonly}) {
        html_postgres();
        goto HTMLEND;
    }

    html_cpus();

    print qq{<tr><th>RAM:</th><td><b>$data{memory}{pretty}{Total}</b></td></tr>\n};

    html_vm();

    html_rightscale();

    html_ec2();

    html_uptime();

    html_lsb();

    html_dist();

    html_puppet();

    html_kernel();

    html_shared_memory();

    html_shared_active();

    html_lifekeeper();

    html_heartbeat();

    html_interfaces();

    html_routes();

    html_fs();

    html_queues();

    html_disk_settings();

    html_versions();

    html_perlinfo();

    html_perlmodules();

    html_gems();

    html_chkconfig();

    html_postgres();

    html_mysql();

    html_ulimits();

    html_envs();

    html_yum();

    html_aptitude();

    HTMLEND:

print q{
</table>
};

    select $oldselect;
    close $fh or die qq{Could not close "$file": $!\n};

    print "Wrote $file\n";

    return;

} ## end of create_html_output


sub html_postgres {
    html_postgres_active();
    html_postgres_recovery();
    html_postgres_problems();
    html_postgres_config();
    html_postgres_databases();
    html_postgres_tablespaces();
    html_postgres_slony();
    html_postgres_bucardo();
    html_postgres_postgis();
    html_postgres_pgconfig();
    return;
} ## end of html_postgres


sub html_cpus {

    return if ! exists $data{cpuinfo};

    ## CPUs may be different - if so, list individually
    ## If not, just say <number> x <info>

    my $allthesame = 1;
    my %cinfo;
  CPU: for my $cpu (values %{$data{cpuinfo}}) {
        for my $item ('model name', 'cache size', 'speed', 'cpu cores') {
            next if ! exists $cpu->{$item};
            $cpu->{$item} =~ s/\s+/ /g;
            if (! exists $cinfo{$item}) {
                $cinfo{$item} = $cpu->{$item};
            }
            elsif ($cpu->{$item} ne $cinfo{$item}) {
                $allthesame=0;
                last CPU;
            }
        }
    }


    if ($allthesame) {
        my $cache = exists $cinfo{'cache size'} ? " Cache size: $cinfo{'cache size'}" : '';
        print qq{<tr><th>CPU:</th><td><b>$data{numcpus} x $cinfo{'model name'} ($cinfo{speed})$cache</b></td></tr>\n};
        return;
    }

    my @cpulist;
    for my $num (sort { $a <=> $b } keys %{$data{cpuinfo}}) {
        my $cpu = $data{cpuinfo}{$num};
        my $cache = exists $cpu->{'cache size'} ? " Cache size: $cpu->{'cache size'}" : '';
        push @cpulist => "CPU $num: $cpu->{'model name'} ($cpu->{speed})$cache";
    }
    my $cpulist = join '<br />' => @cpulist;
    print qq{<tr><th>CPUs:</th><td><b>$cpulist</b></td></tr>\n};

    return;

} ## end of html_cpus


sub html_vm {

    return if ! exists $data{VM};

    print qq{<tr><th>VM:</th><td><b>$data{VM}</b></td></tr>\n\n};

    return;

} ## end of html_vm


sub html_rightscale {

    return if ! exists $data{RightScale};

    ## We assume a version is always provided
    ## The cloud, however, may not be there
    print qq{<tr><th>RightScale:</th><td>Release <b>$data{RightScale}{version}</b>};

    if (exists $data{RightScale}{cloud}) {
        printf ' Cloud: %s',
            (defined $data{RightScale}{cloud} and length $data{RightScale}{cloud})
            ? "<b>$data{RightScale}{cloud}</b>" : '?';
    }
    print qq{</td></tr>\n\n};

    return;

} ## end of html_rightscale

sub html_ec2 {

    return if ! exists $data{EC2};

    print qq{<tr><th$vtop>${wrap}EC2:</th><td><br /><table border="1" style="border: black solid 1px">};
    for my $name (sort keys %{$data{EC2}}) {
        next if $name eq 'meta';
        print qq{<tr><td>$name: </td><td><b>$data{EC2}{$name}</b></td></tr>\n};
    }
    if (exists $data{EC2}{meta}) {
        for my $name (sort keys %{$data{EC2}{meta}}) {
            my $value = $data{EC2}{meta}{$name};
            if (ref $value eq 'HASH') {
                $value = join '<br />'
                       => map { "$_ = $data{EC2}{meta}{$name}{$_}" }
                       sort keys %{$data{EC2}{meta}{$name}};
                $name =~ s{/$}{};
            }
            else {
                $value =~ s{\n}{<br />\n}g;
            }
        print qq{<tr><td>$name: </td><td><b>$value</b></td></tr>\n};
        }
    }

    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_ec2


sub html_uptime {

    if (exists $data{uptime}) {
        print qq{<tr><th>Uptime:</th><td><b>$data{uptime}</b></td></tr>\n\n};
    }

    if (exists $data{users_logged_in}) {
        print qq{<tr><th>Users:</th><td><b>$data{users_logged_in}</b></td></tr>\n\n};
    }

    if (exists $data{load_average}) {
        print qq{<tr><th>Load average:</th><td><b>$data{load_average}</b></td></tr>\n\n};
    }

    return;

} ## end of html_uptime


sub html_lsb {

    return if ! exists $data{lsb_release};

    print qq{<tr><th$vtop>${wrap}LSB info:</th><td><br /><table border="1" style="border: black solid 1px">};
    for my $name (sort keys %{$data{lsb_release}}) {
        print qq{<tr><td>$name: </td><td><b>$data{lsb_release}{$name}</b></td></tr>\n};
    }
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_lsb


sub html_dist {

    for my $dist (keys %distlist) {
        next if ! exists $data{dist}{$dist};
        my $ver = $data{dist}{$dist};
        next if $dist eq 'redhat' and exists $data{dist}{fedora} and $ver =~ /Fedora/;
        if ($distlist{$dist}->[2] eq 'version' and exists $data{dist_codename}) {
            $ver .= " ($data{dist_codename})";
        }
        printf qq{<tr><th>%s %s:</th><td><b>%s</b></td></tr>\n\n},
            $distlist{$dist}->[1], $distlist{$dist}->[2], $ver;
    }

    return;

} ## end of html_dist


sub html_puppet {

    return if ! exists $data{puppet};

    print q{<tr><th>Puppet classes:</th><td><br /><table border="1" style="border: black solid 1px">};
    for my $name (@{$data{puppet}{class}}) {
        print qq{<tr><td><b>$name</b></td></tr>\n};
    }
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_puppet


sub html_kernel {

    return if !exists $data{'Kernel name'};

    print qq{<tr><th$vtop>${wrap}Kernel info:</th><td><br /><table border="1">};
    for my $name ('Kernel name', 'Kernel release', 'Kernel version', 'Hardware name', 'Processor', 'Hardware platform') {
        next if ! exists $data{$name} or $data{$name} eq 'unknown' or $data{$name} =~ /--help/;
        print qq{<tr><td>$name: </td><td><b>$data{$name}</b></td></tr>};
    }
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_kernel


sub html_shared_memory {

    return if ! exists $data{memory}{shmmax};

    print qq{<tr><th$vtop>${wrap}Memory:</th><td><br /><table border="1">};
    print qq{<tr><td>shmmax: </td><td style="text-align: right"><b>$data{memory}{pretty}{shmmax}</b></td></tr>\n};
    print qq{<tr><td>shmmni: </td><td style="text-align: right"><b>$data{memory}{shmmni}</b></td></tr>\n};
    print qq{<tr><td>shmall: </td><td style="text-align: right"><b>$data{memory}{pretty}{shmall}</b></td></tr>\n};

    for my $vm ('swappiness','dirty_ratio','dirty_background_ratio') {
        if (exists $data{vm}{$vm}) {
            print qq{<tr><td>$vm: </td><td style="text-align: right"><b>$data{vm}{$vm}</b></td></tr>\n};
        }
    }

    for my $m ('Free', 'Cached', 'Active', 'Swap Total') {
        print qq{<tr><td>$m: </td><td style="text-align: right"><b>$data{memory}{pretty}{$m}</b></td></tr>\n};
    }
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_shared_memory


sub html_shared_active {

    return if !exists $data{memory}{active_shared};

    print qq{<tr><th$vtop>${wrap}Active shared mem:</th><td><br /><table border="1">};
    print qq{<tr><td>Active segments: </td><td style="text-align: right"><b>$data{memory}{active_shared}</b></td>\n};
    print qq{<td>Active semaphores: </td><td style="text-align: right"><b>$data{memory}{active_semaphores}</b></td>\n};
    print qq{<td>Active messages: </td><td style="text-align: right"><b>$data{memory}{active_messages}</b></td></tr>\n};
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_shared_active


sub html_lifekeeper {

    return if !exists $data{lifekeeper};

    print qq{<tr><th$vtop>${wrap}Lifekeeper services:</th><td><br /><table border="1">\n};
    print qq{<tr><th>Service</th><th>Primary host</th><th>State</th></tr>\n};
    my $s = $data{lifekeeper}{service};
    for my $row (sort { $s->{$b}{prio} <=> $s->{$a}{prio} } keys %$s) {
        printf "<tr><td><b>$row</b></td><td>%s</td><td>%s</td></tr>\n",
            $s->{$row}{primary}, $s->{$row}{state};
    }
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_lifekeeper


sub html_heartbeat {

    return if !exists $data{heartbeat};

    print qq{<tr><th$vtop>${wrap}Linux HA:</th><td><br /><table border="1">\n};

    if (exists $data{heartbeat}{active}) {
        print qq{<tr><th colspan="2">$data{heartbeat}{active}</tr>\n};
    }

    if (exists $data{heartbeat}{haresources}) {
    my $har = escape_html($data{heartbeat}{haresources});
        print qq{<tr><td>haresources:</td><td>$har</td></tr>\n};
    }

    if (exists $data{heartbeat}{node}) {
        print q{<tr><td>Nodes:</td><td><b>};
        print join '<br />' => @{$data{heartbeat}{node}};
        print qq{</b></td></tr>\n};
    }

    if (exists $data{heartbeat}{config}) {
        my $config = $data{heartbeat}{config};
        $config =~ s/\s*$//gm;
        print qq{<tr><td>Config:</td><td><pre>$config</pre></td></tr>\n};
    }

    if (exists $data{heartbeat}{resources}) {
        my $reslist = join '<br />' => sort @{$data{heartbeat}{resources}};
        print qq{<tr><td>Resources:</td><td>$reslist</td></tr>\n};
    }

    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_heartbeat


sub html_interfaces {

    return if ! exists $data{interface};

    my $gotnotes = 0;
    for my $int (keys %{$data{interface}}) {
        $gotnotes = 1 if exists $data{interface}{$int}{POINTOPOINT};
    }

    print qq{<tr><th$vtop>${wrap}Interfaces:</th><td><br /><table border="1">\n};
    printf q{<tr><th>Name</th><th>IP</th><th>Status</th><th>Speed</th>%s</tr>},
        $gotnotes ? q{<th>Notes</th>} : '';
    my $x;
    for my $int (map { $_->[0] }
                 sort { $b->[1] <=> $a->[1] or $b->[2] cmp $a->[2] or $a->[0] cmp $b->[0] }
                 map { $x=$data{interface}{$_}; [$_, exists $x->{RUNNING} ? 1 : 0, $x->{address} || 0] }
                 keys %{$data{interface}}) {
        my $d = $data{interface}{$int};
        my $ip = $d->{RUNNING} ? ($d->{address} || $d->{inet6_address} || '-') : 'N/A';
        printf q{<tr><td%s>%s</td><td>%s</td><td>%s</td>},
            exists $d->{RUNNING} ? q{ class='activeip'} : '',
                exists $d->{RUNNING} ? qq{<b>$int</b>} : $int,
                    $ip,
                        exists $d->{RUNNING} ? 'Active' : 'Inactive';
        printf '<td>%s',
            exists $d->{current_speed} ? "$d->{current_speed} $d->{duplex}" : exists $d->{RUNNING} ?
                $int =~ /^lo|tun|bond/ ? 'N/A' : $UNKNOWN_VALUE : 'N/A';
        if (exists $d->{nowspeed} and exists $d->{maxspeed} and $d->{maxspeed} and ($d->{nowspeed} < $d->{maxspeed})) {
            print " <b>(but max is $d->{maxspeed})</b>";
        }
        print '</td>';
        if ($gotnotes) {
            printf '<td>%s</td>',
                exists $d->{POINTOPOINT} ? 'point to point' : ' &nbsp;';
        }
        print "</tr>\n";
    }
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_interfaces


sub html_routes {

    return if ! exists $data{route};

    print qq{<tr><th$vtop>${wrap}Routes:</th><td><br /><table border="1">\n};
    print q{<tr><th>Destination</th><th>Gateway</th><th>Genmask</th><th>Interface</th></tr>};
    for my $r (@{$data{route}}) {
        print qq{<tr><td>$r->{dest}</td><td>$r->{gateway}</td><td>$r->{mask}</td><td>$r->{int}</td></tr>\n};
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_routes


sub html_fs {

    return if ! exists $data{fs};

    print qq{<tr><th$vtop>${wrap}Mounting info:</th><td><br /><table border="1">\n};
    print q{<tr><th>Name</th><th>Mount</th><th>Size/Used %</th><th>Inode %</th><th>Filesystem (options)</th></tr>};
    for my $fs (sort keys %{$data{fs}}) {
        my $d = $data{fs}{$fs};
        next if ! defined $d->{mounted};
        next if $fs eq 'none';
        (my $ffs = escape_html($fs)) =~ s{(.+/)([\w\-]{20,})$}{$1<br />$2};
        $ffs =~ s{^([^:]{15,}:)(.+)}{$1<br />$2};
        print qq{<tr><td>$ffs</td><td><b>$d->{mounted}</b></td><td>$d->{size}/$d->{capacity}</td>};
        print qq{<td>$d->{inodes_usage}</td>\n};
        $d->{options} = '' if ! exists $d->{options};
        my $options = $d->{options};
        if (length $options > 20) {
            $options =~ s{,}{,<br />}g;
        }
        printf qq{<td>%s%s</td></tr>\n},
            defined $d->{type} ? $d->{type} : '?',
            $options ? " ($options)" : '';
    }

    if (exists $data{mdstat}) {
        printf q{<tr><td>mdstat:</td><td colspan='4'>%s</td></tr>},
            escape_html($data{mdstat});
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_fs


sub html_queues {

    return if ! exists $data{block};

    print qq{<tr><th$vtop>${wrap}Kernel queue info:</th><td><br /><table border="1">\n};
    print q{<tr><th>Block</th><th>Read ahead size</th><th>Scheduler</th></tr>};
    for my $name (sort keys %{$data{block}}) {
        my $q = $data{block}{$name};
        $q->{scheduler} =~ s{(\[\w+\])}{<b>$1</b>};
        print qq{<tr><td>$name</td><td>$q->{readahead}</td><td>$q->{scheduler}</td></tr>\n};
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_queues


sub html_disk_settings {

    return if ! exists $data{disk};

    print qq{<tr><th$vtop>${wrap}Disk information:</th><td><br /><table border="1">\n};
    print q{<tr><th>Name</th><th>Read ahead size</th><th>Scheduler</th></tr>};
    for my $fs (sort keys %{$data{fs}}) {
        my $d = $data{fs}{$fs};
        next if ! defined $d->{mounted};
        next if $fs eq 'none';
        print qq{<tr><td>$fs</td><td><b>$d->{mounted}</b></td><td>$d->{size}/$d->{capacity}</td>};
        print qq{<td>$d->{inodes_usage}</td>\n};
        print qq{<td>$d->{readahead}</td>\n};
        print qq{<td>$d->{scheduler}</td>\n};
        print qq{<td>$d->{type} ($d->{options})</td></tr>\n};
    }

    if (exists $data{mdstat}) {
        print q{<tr><td>mdstat:</td><td colspan=5>%s</td></tr>},
            escape_html($data{mdstat});
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_disk_settings


sub html_versions {

    return if ! exists $data{version};

    my $TWOWRAP = 15;
    my $THREEWRAP = 30;

    my $count = 0;
    for my $v (keys %{$data{version}}) {
        $count++ if $data{version}{$v} ne '?';
    }
    return if ! $count;

    print qq{<tr><th$vtop>${wrap}Program versions:</th><td><br /><table border="1">\n};
    print q{<tr><th>Name</th><th>Version</th>};
    if ($count >= $TWOWRAP) {
        print q{<th>Name</th><th>Version</th>};
    }
    if ($count >= $THREEWRAP) {
        print q{<th>Name</th><th>Version</th>};
    }
    print qq{</tr>\n};

    my $offset = 0;
    for my $prog (sort keys %{$data{version}}) {
        my $v = $data{version}{$prog};
        next if $v eq '?';
        if ($count < $TWOWRAP) {
            printf qq{<tr><td>$prog</td><td>%s</td></tr>\n},
                $v eq '?' ? $UNKNOWN_VALUE : qq{<b>$v</b>};
        }
        elsif (!$offset) {
            printf qq{<tr><td>$prog</td><td>%s</td>},
                $v eq '?' ? $UNKNOWN_VALUE : qq{<b>$v</b>&nbsp;};
            $offset = 1;
        }
        elsif ($count >= $THREEWRAP and $offset < 2) {
            printf qq{<td>$prog</td><td>%s</td>},
                $v eq '?' ? $UNKNOWN_VALUE : qq{<b>$v</b>&nbsp;};
            $offset = 2;
        }
        else {
            printf qq{<td>$prog</td><td>%s</td></tr>},
                $v eq '?' ? $UNKNOWN_VALUE : qq{<b>$v</b>};
            $offset = 0;
        }
    }
    if ($offset) {
        print q{<td>&nbsp;</td><td>&nbsp;</td>};
        $offset==1 and $count >= $THREEWRAP and print q{<td>&nbsp;</td><td>&nbsp;</td>};
        print qq{</tr>\n};
    }
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_versions


sub html_perlinfo {

    return if ! exists $data{perl};

    ## Where installed?

    print qq{<tr><th$vtop>${wrap}Perl info:</th><td><br /><table border="1">\n};
    print qq{<tr><td>Version:</td><td><b>$data{version}{perl}</b></td></tr>\n};
    ## Only one of these is needed
    (my $pver = $data{version}{perl}) =~ s/^(\d+\.\d+)\..*/$1/e;
    if ($pver < 5.10) {
        print qq{<tr><td>Threads:</td><td><b>$data{perl}{threads}</b></td></tr>\n};
    }
    else {
        print qq{<tr><td>IThreads:</td><td><b>$data{perl}{ithreads}</b></td></tr>\n};
    }
    print qq{<tr><td>Multiplicity:</td><td><b>$data{perl}{multiplicity}</b></td></tr>\n};
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_perlinfo


sub html_perlmodules {

    return if ! exists $data{perlmodver};

    print qq{<tr><th$vtop>${wrap}Perl modules:</th><td><br /><table border="1">\n};
    print q{<tr><th>Module</th><th>Version</th></tr>};
    my $BASE = 'http://search.cpan.org/dist';
    for my $mod (sort keys %{$data{perlmodver}}) {
        my $v = $data{perlmodver}{$mod};
        (my $safename = $mod) =~ s/::/-/g;
        my $url = "$BASE/$safename";
        if ('wiki' eq $format) {
            printf qq{<tr><td>[$url $mod]</td><td>%s</td></tr>\n},
            $v eq '?' ? $UNKNOWN_VALUE : qq{<b>$v</b>};
        }
        else {
            printf qq{<tr><td><a href="$url">$mod</a></td><td>%s</td></tr>\n},
                $v eq '?' ? $UNKNOWN_VALUE : qq{<b>$v</b>};
        }
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_perlmodules


sub html_chkconfig {

    return if ! exists $data{chkconfig};

    my $TWOWRAP = 10;
    my $THREEWRAP = 20;

    print qq{<tr><th$vtop>${wrap}Started via chkconfig:</th><td><br /><table border="1">\n};
    my $count = keys %{$data{chkconfig}};
    my $offset = 0;
    for my $prog (sort keys %{$data{chkconfig}}) {
        if ($count < $TWOWRAP) {
            print qq{<tr><td>$prog</td></tr>\n};
        }
        elsif (!$offset) {
            print qq{<tr><td>$prog</td>};
            $offset = 1;
        }
        elsif ($count >= $THREEWRAP and $offset < 2) {
            print qq{<td>$prog</td>};
            $offset = 2;
        }
        else {
            print qq{<td>$prog</td></tr>\n};
            $offset = 0;
        }
    }
    if ($offset) {
        print q{<td>&nbsp;</td>};
        $offset==1 and $count >= $THREEWRAP and print q{<td>&nbsp;</td>};
        print qq{</tr>\n};
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_chkconfig


sub html_postgres_active {

    ## Show active Postgres cluster ports, socket dirs, and version

    return if ! exists $data{postgres} or ! exists $data{postgres}{active_port};

    print qq{<tr><th$vtop>${wrap}Active Postgres clusters:</th><td><br /><table border="1">\n};

    my ($extrasym, $extranotes) = (0,0);
    for my $cluster (keys %{$data{postgres}{active_port}}) {
        if (exists $data{postgres}{active_port}{$cluster}{symlink}) {
            $extrasym = 1;
        }
        if (exists $data{postgres}{active_port}{$cluster}{recfile}
            or exists $data{postgres}{active_port}{$cluster}{startingup}) {
            $extranotes = 1;
        }
    }

    print q{<tr><th>Port</th><th>Socket dir</th><th>Version</th>};
    $extrasym and print q{<th>Symlinks</th>};
    $extranotes and print q{<th>Notes</th>};
    print qq{</tr>\n};
    for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $c = $data{postgres}{active_port}{$cluster};
        next if $c->{deleted};
        my $port = $c->{port};
        my $dir = $c->{largesocketdir} || $c->{socketdir};
        my $ver = $c->{setting}{server_version}{value} || $c->{version}{full} || '?';
        if ($ver =~ /^\d+\.\d+$/ and exists $data{version}{psql}) {
            $ver .= "<br />(probably $data{version}{psql})";
        }
        print qq{<tr><td><b>$port</b></td><td><b>$dir</b></td><td><b>$ver</b></td>};
        if ($extrasym) {
            my $info = '&nbsp;';
            if (exists $c->{symlink}) {
                $info = join '<br />' =>
                    map { "$_ -> $c->{symlink}{$_}" }
                    sort
                    keys %{$c->{symlink}};
            }
            print "<td>$info</td>";
        }
        if ($extranotes) {
            my $info = '&nbsp;';
            if (exists $c->{recfile}) {
                $info = 'In recovery mode';
            }
            elsif (exists $c->{startingup}) {
                $info = 'Starting up';
            }
            if (exists $c->{datadirsize}) {
                $info .= "<br />DB size: $c->{datadirsize}";
            }
            print "<td>$info</td>";
        }
        print "</tr>\n";
    }
    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_postgres_active


sub html_postgres_config {

    ## Show active cluster configuration settings (interesting ones only)

    return if ! exists $data{postgres} or ! exists $data{postgres}{active_port};

    ## Make sure we have at least one (may not due to warm standby servers, etc.)
    my $found = 0;
    for my $cluster (keys %{$data{postgres}{active_port}}) {
        if (exists $data{postgres}{active_port}{$cluster}{setting}{lc_time}) {
            $found = 1;
            last;
        }
    }
    return if !$found;

    print qq{<tr><th$vtop>${wrap}&rarr; Postgres config:</th><td><br /><table border="1" class="plain">\n};

    ## We don't want to report on all config values, just interesting ones
    ## A = always show
    ## D = show only if different
    ## S = skip it

my $pg_settings = q{
D add_missing_from                | off               
D allow_system_table_mods         | off               
S application_name                |                   
D archive_command                 | (disabled)        
D archive_mode                    | off               
D archive_timeout                 | 0                 
D array_nulls                     | on                
D authentication_timeout          | 60                
A autovacuum                      |                   
D autovacuum_analyze_scale_factor | 0.1               
D autovacuum_analyze_threshold    | 50                
D autovacuum_freeze_max_age       | 200000000         
D autovacuum_max_workers          | 3                 
D autovacuum_naptime              | 60                
D autovacuum_vacuum_cost_delay    | 20                
D autovacuum_vacuum_cost_limit    | -1                
D autovacuum_vacuum_scale_factor  | 0.2               
D autovacuum_vacuum_threshold     | 50                
D backslash_quote                 | safe_encoding     
D bgwriter_delay                  | 200               
D bgwriter_lru_maxpages           | 100               
D bgwriter_lru_multiplier         | 2                 
D block_size                      | 8192              
D bounjour                        | off               
D bonjour_name                    |                   
D bytea_output                    | hex               
D check_function_bodies           | on                
D checkpoint_completion_target    | 0.5               
A checkpoint_segments             | 3                 
D checkpoint_timeout              | 300               
D checkpoint_warning              | 30                
A client_encoding                 | UTF8              
D client_min_messages             | notice            
D commit_delay                    | 0                 
D commit_siblings                 | 5                 
A config_file                     |                   
D constraint_exclusion            | off               
D cpu_index_tuple_cost            | 0.005             
D cpu_operator_cost               | 0.0025            
D cpu_tuple_cost                  | 0.01              
D cursor_tuple_fraction           | 0.1               
D custom_variable_classes         |                   
A data_directory                  |                   
D DateStyle                       | ISO, MDY          
D db_user_namespace               | off               
D deadlock_timeout                | 1000              
D debug_assertions                | off               
D debug_pretty_print              | off               
D debug_print_parse               | off               
D debug_print_plan                | off               
D debug_print_rewritten           | off               
A default_statistics_target       | 10 or 100         
D default_tablespace              |                   
D default_text_search_config      | pg_catalog.english
D default_transaction_isolation   | read committed    
D default_transaction_read_only   | off               
D default_with_oids               | off               
D dynamic_library_path            | $libdir           
A effective_cache_size            |                   
D effective_io_concurrency        | 1                 
D enable_bitmapscan               | on                
D enable_hashagg                  | on                
D enable_hashjoin                 | on                
D enable_indexscan                | on                
D enable_material                 | on
D enable_mergejoin                | on                
D enable_nestloop                 | on                
D enable_seqscan                  | on                
D enable_sort                     | on                
D enable_tidscan                  | on                
D escape_string_warning           | on                
D exit_on_error                   | off
D explain_pretty_print            | on                
D external_pid_file               |                   
D extra_float_digits              | 0                 
D from_collapse_limit             | 8                 
D fsync                           | on                
D full_page_writes                | on                
D geqo                            | on                
D geqo_effort                     | 5                 
D geqo_generations                | 0                 
D geqo_pool_size                  | 0                 
D geqo_seed                       | 0                 
D geqo_selection_bias             | 2                 
D geqo_threshold                  | 12                
D gin_fuzzy_search_limit          | 0                 
A hba_file                        |    
D hot_standby                     | off
D hot_standby_feedback            | off              
A ident_file                      |                   
D ignore_system_indexes           | off               
A integer_datetimes               | on               
D IntervalStyle                   | postgres          
D join_collapse_limit             | 8                 
S krb_caseins_users               | off               
S krb_realm                       |                   
S krb_server_hostname             |                   
S krb_server_keyfile              |                   
S krb_srvname                     | postgres          
S lc_collate                      |                   
S lc_ctype                        |                   
S lc_messages                     |                   
S lc_monetary                     |                   
S lc_numeric                      |                   
S lc_time                         |                   
D listen_addresses                | *                 
D lo_compat_privileges            | off               
D local_preload_libraries         |                   
D log_autovacuum_min_duration     | -1                
D log_checkpoints                 | off               
D log_connections                 | off               
A log_destination                 | stderr            
D log_directory                   | pg_log            
D log_disconnections              | off               
D log_duration                    | off               
D log_error_verbosity             | default           
D log_executor_stats              | off               
D log_file_mode                   | 0600                   
A log_filename                    |                   
D log_hostname                    | off               
D log_line_prefix                 |                   
D log_lock_waits                  | off               
A log_min_duration_statement      | -1                
D log_min_error_statement         | error             
D log_min_messages                | warning           
D log_parser_stats                | off               
D log_planner_stats               | off               
D log_rotation_age                | 1440              
D log_rotation_size               | 10240             
D log_statement                   | none              
D log_statement_stats             | off               
D log_temp_files                  | -1                
D log_timezone                    | US/Eastern        
D log_truncate_on_rotation        | off               
A logging_collector               | off               
A maintenance_work_mem            | 16384             
A max_connections                 |                   
D max_files_per_process           | 1000              
A max_fsm_pages                   |                   
D max_fsm_relations               | 1000              
D max_function_args               | 100               
D max_identifier_length           | 63                
D max_index_keys                  | 32                
D max_locks_per_transaction       | 64                
D max_pred_locks_per_transaction  | 64                
A max_prepared_transactions       | 5                 
D max_stack_depth                 | 2048              
D max_standby_archive_delay       | 30000                
D max_standby_streaming_delay     | 30000
A max_wal_senders                 | 0                
D password_encryption             | on                
D port                            | 5432              
D post_auth_delay                 | 0                 
D pre_auth_delay                  | 0                 
D quote_all_identifiers           | off 
A random_page_cost                |                   
D replication_timeout             | 60000
D restart_after_crash             | on
D regex_flavor                    | advanced          
D search_path                     | "$user",public    
D segment_size                    | 131072            
D seq_page_cost                   | 1                 
A server_encoding                 | UTF8              
S server_version                  | 8.something       
S server_version_num              | 80303             
D session_replication_role        | origin            
A shared_buffers                  | 3072              
D shared_preload_libraries        |                   
D silent_mode                     | off               
D sql_inheritance                 | on                
D ssl                             | off               
S ssl_ciphers                     |                
S ssl_renegotiation_limit         | 524288               
D standard_conforming_strings     | off               
D statement_timeout               | 0                 
D stats_temp_directory            | pg_stat_tmp       
D superuser_reserved_connections  | 3                 
D synchronize_seqscans            | on                
D synchronous_commit              | on 
D synchronous_standby_names       |                
D syslog_facility                 | LOCAL0            
D syslog_ident                    | postgres          
D tcp_keepalives_count            | 0                 
D tcp_keepalives_idle             | 0                 
D tcp_keepalives_interval         | 0                 
D temp_buffers                    | 1024              
D temp_tablespaces                |                   
S TimeZone                        | US/Eastern        
D timezone_abbreviations          | Default           
D trace_notify                    | off               
D trace_recovery_messages         | debug1            
D trace_sort                      | off               
D track_activities                | on                
D track_activity_query_size       | 1024              
D track_counts                    | on                
D track_functions                 | none 
D transaction_defferable          | off              
D transaction_isolation           | read committed    
D transaction_read_only           | off               
D transform_null_equals           | off               
D unix_socket_directory           | /tmp              
D unix_socket_group               |                   
D unix_socket_permissions         | 511               
D update_process_title            | on                
D vacuum_cost_delay               | 0                 
D vacuum_cost_limit               | 200               
D vacuum_cost_page_dirty          | 20                
D vacuum_cost_page_hit            | 1                 
D vacuum_cost_page_miss           | 10                
D vacuum_defer_cleanup_age        | 0                 
D vacuum_freeze_min_age           | 100000000         
D vacuum_freeze_table_age         | 150000000         
D wal_block_size                  | 8192              
D wal_buffers                     | 8   
D wal_debug                       | off               
D wal_keep_segments               | 0              
A wal_level                       | minimal  
D wal_receiver_status_interval    | 10            
D wal_segment_size                | 2048              
D wal_sender_delay                | 200              
A wal_sync_method                 | fdatasync         
D wal_writer_delay                | 200               
A work_mem                        |                   
D xmlbinary                       | base64            
D xmloption                       | content           
D zero_damaged_pages              | off               
};

    my %pgs;
    for my $line (split /\n/ => $pg_settings) {
        next unless $line =~ /^([ASD]) (\w+)\s+\|\s*(.+?)\s*$/o;
        my ($type,$name,$val) = ($1,$2,$3);
        $pgs{$name} = {type => $type, value => $val};
    }

    print qq{<tr><th>Cluster</th><th>Config</th><th>Value</th><th>Source</th></tr>\n};
    for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $info = $data{postgres}{active_port}{$cluster};
        my $port = $info->{port} || '';
        next if ! defined $info->{setting}{data_directory};
        next if exists $opt{skippgport} and $opt{skippgport} =~ /\b$port\b/;
        my $socketdir = $info->{socketdir};
        my $set = $info->{setting};
        my @var;
        for my $var (sort { lc($a) cmp lc($b) } keys %pgs) {
            my $type = $pgs{$var}->{type};
            next if $type eq 'S';
            next if ! exists $set->{$var};
            my $source = $set->{$var}{source};
            my $unit = $set->{$var}{unit} || '';
            $source = 'Conf' if $source eq 'configuration file';
            $source = '<b>User</b>' if $source eq 'user';
            $source = 'Set' if $source eq 'override';
            $source = 'Def' if $source eq 'default';

            my $value = $set->{$var}{value};
            my $orig = $pgs{$var}->{value};
            $orig =~ s/\s+$//;
            next if $source eq 'Def' and ($var =~ /autovac/ or $var eq 'archive_command' or $var =~ /bgwriter/);
            next if $source eq 'Def' and $var eq 'unix_socket_directory' and $value !~ /\w/;
            next if $source eq 'Def' and $value eq 'unset'; ## old style
            if ($set->{$var}{source} ne 'default') {
                my $def = $pgs{$var}->{value};
                $def =~ s/\n/ /g;
                $def = '(empty string)' if $def =~ /^\s*$/;
                if ($use_balloons) {
                    $source = "<balloon title='Default is: $def'>$source</balloon>";
                }
            }
            if ($type eq 'A' or $value ne $orig) {
                push @var, [$var,$value,$source,$unit];
            }
        }
        my $number = @var;
        my $firstrow = 1;
        print qq{<tr><th rowspan="$number">$port<br >$socketdir</th>};
        for my $var (@var) {
            printf qq{%s<td>$var->[0]</td><td><b>%s</b></td><td>$var->[2]</td></tr>\n},
                $firstrow ? '' : '<tr>',
                pretty_conf($var->[0],$var->[1],$var->[3]);
            $firstrow and $firstrow = 0;
        }
    }

    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_postgres_config


sub html_postgres_recovery {

    ## Show information for warm-standby clusters (in recovery mode)

    return if ! exists $data{postgres} or ! exists $data{postgres}{active_port};

    ## Make sure we have at least one in recovery mode
    my $found = 0;
    for my $cluster (keys %{$data{postgres}{active_port}}) {
        if (exists $data{postgres}{active_port}{$cluster}{recfile}) {
            $found = 1;
            last;
        }
    }
    return if !$found;

    print qq{<tr><th$vtop>${wrap}&rarr; Postgres recovery.conf:</th><td><br /><table border="1" class="plain">\n};

    print q{<tr><th>Cluster</th><th>recovery.conf</th></tr>};
    for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $c = $data{postgres}{active_port}{$cluster};
        next if ! exists $c->{recfile};
        my $port = $c->{port} || '';
        next if exists $opt{skippgport} and $opt{skippgport} =~ /\b$port\b/;
        my $socketdir = $c->{socketdir};
        my $recfile = $c->{recfile};
        $recfile =~ s/ +/ /g;
        $recfile =~ s{\n}{<br />\n};
        print qq{<tr><th>$port<br >$socketdir</th><td>$recfile</td></tr>\n};
    }

    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_postgres_recovery


sub html_postgres_problems {

    ## Show any known problems that don't fit elsewhere

    return if ! exists $data{postgres} or ! exists $data{postgres}{problems};

    print qq{<tr><th$vtop>${wrap}&rarr; Postgres potential problems:</th><td><br /><table border="1" class="plain">\n};

    print q{<tr><th>Cluster/<br />Database</th><th>Problem</th></tr>};
    for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $c = $data{postgres}{active_port}{$cluster};
        next if ! exists $c->{problems};
        my $port = $c->{port} || '';
        next if exists $opt{skippgport} and $opt{skippgport} =~ /\b$port\b/;
        my $socketdir = $c->{socketdir};
        for my $db (keys %{$c->{db}}) {
            my $info = $c->{db}{$db};
            next if ! exists $info->{problems};
            my $problems = '';
            if ($info->{disabled_triggers}) {
                $problems .= "<b>DISABLED TRIGGERS:</b><ul>\n";
                for my $t (@{$info->{disabled_triggers}}) {
                    my ($table,$trigger,$type) = @$t;
                    $problems .= "<li>$trigger on table $table ($type)</li>\n";
                }
                $problems .= "</ul>\n";
            }
            print qq{<tr><th>$port<br >$socketdir<br />$db</th><td>$problems</td></tr>\n};
        }
    }

    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_postgres_recovery


sub html_postgres_pgconfig {

    ## Show the output of pg_config

    return if ! exists $data{postgres} or ! exists $data{postgres}{pgconfig};

    print qq{<tr><th$vtop>${wrap}&rarr; pg_config info</th><td><br /><table border="1" class="plain">\n};
    for my $row (sort keys %{$data{postgres}{pgconfig}}) {
        print qq{<tr><th>$row</th>\n};
        print qq{<td>$data{postgres}{pgconfig}{$row}</td>\n};
        print qq{</tr>\n};
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_postgres_pgconfig


sub html_postgres_databases {

    ## Show active cluster database information

    return if ! exists $data{postgres} or ! exists $data{postgres}{active_port};

    C: for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $cinfo = $data{postgres}{active_port}{$cluster};
        my $port = $cinfo->{port} || '';
        next if exists $opt{skippgport} and $opt{skippgport} =~ /\b$port\b/;
        next if exists $cinfo->{startingup};
        next if ! exists $cinfo->{setting}{data_directory};
        my $socketdir = $cinfo->{socketdir};
        print qq{<tr><th$vtop>${wrap}&rarr; PG DBs<br />$port<br />$socketdir</th><td><br /><table border="1" class="plain">\n};

        my ($usets,$useds,$usesl,$usebc) = (0,0,0,0);
        for my $db (keys %{$cinfo->{db}}) {
            my $dinfo = $cinfo->{db}{$db};
            next if $db eq 'template1';
            if (defined $dinfo->{tablespace} and length $dinfo->{tablespace} and $dinfo->{tablespace} ne 'pg_default') {
                $usets = 1;
            }
            if (defined $dinfo->{description} and length $dinfo->{description}) {
                $useds = 1;
            }
            if (exists $dinfo->{slony}) {
                $usesl = 1;
            }
        }

        print qq{<tr><th>Name</th>\n};
        print q{<th>Encoding/<br />Owner</th>};
        print q{<th>Template/<br />Connectable/<br />Age</th>};
        print q{<th>Size</th>};
        print q{<th>Schemas/<br />Tables/<br />Functions</th>};
        print q{<th>Languages</th>};
        $cinfo->{hascontrib} and print q{<th>Contrib</th>};
        $usesl and print q{<th>Slony</th>};
        $usets and print q{<th>Tablespace</th>};
        $useds and print q{<th>Description</th>};
        print qq{</tr>\n};

        for my $db (sort keys %{$data{postgres}{active_port}{$cluster}{db}}) {
            my $dinfo = $data{postgres}{active_port}{$cluster}{db}{$db};
            my $enc = qq{<b>$dinfo->{encoding}</b>};
            my $owner = $dinfo->{owner};
            my $istemplate = $dinfo->{template} eq 'Yes' ? '<b>Yes</b>' : 'No';
            my $canconn = $dinfo->{canconn} eq 'No' ? '<b>No</b>' : 'Yes';
            my $age = $dinfo->{age};
            my $size = qq{<b>$dinfo->{size}</b>};
            my $schemas = $dinfo->{relcount}{'schema'} || 0;
            my $tables = $dinfo->{relcount}{'r'} || 0;
            my $indexes = $dinfo->{relcount}{'i'} || 0;
            my $views = $dinfo->{relcount}{'v'} || 0;
            my $sequences = $dinfo->{relcount}{'S'} || 0;
            my $funcs = $dinfo->{relcount}{'f'} || 0;
            if ($dinfo->{canconn} eq 'No') {
                $schemas = $tables = $indexes = $views = $sequences = $funcs = $UNKNOWN_VALUE;
            }

            my $stf = "$schemas<br />$tables<br />$funcs";
            if ($db eq 'template0' and $dinfo->{canconn} eq 'No') {
                $stf = 'N/A';
            }

            my $languages = join '<br />' => sort keys %{$dinfo->{language}};
            $languages ||= '&nbsp;';

            my $tablespace = $dinfo->{tablespace};
            my $description = $dinfo->{tablespace};
            print qq{<tr><td><b>$db</b></td><td>$enc<br />$owner</td>};
            print qq{<td>$istemplate<br />$canconn<br />$age</td><td>$size</td>};
            print qq{<td>$stf</td>};
            print qq{<td><b>$languages</b></td>};
            if ($cinfo->{hascontrib}) {
                my $contribs = '&nbsp;';
                if (exists $dinfo->{contrib}) {
                    $contribs = '<ul>';
                    for my $cname (sort keys %{$dinfo->{contrib}}) {
                        $contribs .= "<li>$cname</li>";
                    }
                    $contribs .= '</ul>';
                }
                print qq{<td>$contribs</td>};
            }
            printf qq{%s%s%s</tr>\n},
            $usets ? qq{<td>$dinfo->{tablespace}</td>} : '',
            $useds ? qq{<td>$dinfo->{description}</td>} : '',
            $usesl ? (sprintf q{<td>%s</td>}, exists $dinfo->{slony} ? 'Yes' : 'No') : '',
        }
        print "</table></td></tr>\n\n";
    }

    return;

} ## end of html_postgres_databases


sub html_postgres_tablespaces {

    ## Show any non-standard tablespaces

    return if ! exists $data{gottablespaces};

    C: for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $info = $data{postgres}{active_port}{$cluster};
        next if ! exists $info->{dbtablespace};
        my $port = $info->{port} || '';
        my $socketdir = $info->{socketdir};

        print qq{<tr><th$vtop>${wrap}&rarr; Tablespace info<br />$port<br />$socketdir</th><td><br /><table border="1" class="plain">\n};
        print qq{<tr><th>Name</th><th>Path</th></tr>\n};
        for my $name (sort keys %{$info->{dbtablespace}}) {
            my $path = $info->{dbtablespace}{$name}[0];
            print qq{<tr><td>$name</td><td><b>$path</b></td></tr>\n};
        }
        print "</table></td></tr>\n\n";
    }

    return;

} ## end of html_postgres_tablespaces


sub html_postgres_slony {

    ## Show Slony information for each cluster and database that uses it

    return if ! exists $data{gotslony};

    C: for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $info = $data{postgres}{active_port}{$cluster};
        next if ! exists $info->{gotslony};
        my $port = $info->{port} || '';
        my $socketdir = $info->{socketdir};

        for my $db (sort keys %{$data{postgres}{active_port}{$cluster}{db}}) {
            my $info = $data{postgres}{active_port}{$cluster}{db}{$db};
            next if ! exists $info->{slony};
            print qq{<tr><th$vtop>${wrap}&rarr; Slony info<br />$port<br />$socketdir<br />$db</th><td><br /><table border="1" class="plain">\n};
            my $paths = join '<br />' => @{$info->{slony}{paths}};
            my $tables = 'NONE!';
            if (defined $info->{slony}{tables}) {
                $tables = join '<br />' => @{$info->{slony}{tables}};
            }
            my $seqs = 'NONE!';
            if (defined $info->{slony}{sequences}) {
                $seqs = exists $info->{slony}{sequences}
                    ? (join '<br />' => @{$info->{slony}{sequences}})
                    : 'none';
            }
            print qq{<tr><td>Schema:</td><td><b>$info->{slony}{schema}</b></td></tr>\n};
            print qq{<tr><td>Paths:</td><td><b>$paths</b></td></tr>\n};
            print qq{<tr><td>Tables:</td><td><b>$tables</b></td></tr>\n};
            print qq{<tr><td>Sequences:</td><td><b>$seqs</b></td></tr>\n};
            print "</table></td></tr>\n\n";
        }
    }

    return;

} ## end of html_postgres_slony


sub html_postgres_bucardo {

    ## Show Bucardo information

    return if ! exists $data{gotbucardo};

    C: for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $info = $data{postgres}{active_port}{$cluster};
        next if ! exists $info->{gotbucardo};
        my $port = $info->{port} || '';
        my $socketdir = $info->{socketdir};

        for my $db (sort keys %{$data{postgres}{active_port}{$cluster}{db}}) {
            my $info = $data{postgres}{active_port}{$cluster}{db}{$db};
            next if ! exists $info->{bucardo};
            print qq{<tr><th$vtop>${wrap}&rarr; Bucardo info<br />$port<br />$socketdir<br />$db</th><td><br /><table border="1" class="plain">\n};

            my $bc = $info->{bucardo};

            my $dbs = '';
            if (keys %{$bc->{db}}) {
                $dbs = '';
                for my $name (sort keys %{$bc->{db}}) {
                    my $i = $bc->{db}{$name};
                    $dbs .= sprintf '%s: %s %s dbname=%s',
                        $name,
                        ($i->{dbhost} ? "dbhost=$i->{dbhost}" : ''),
                        ($i->{dbport}==5432 ? '' : "dbport=$i->{dbport}"),
                        $i->{dbname};
                    $i->{sourcelimit} and $dbs .= " sourcelimit=$i->{sourcelimit}";
                    $i->{targetlimit} and $dbs .= " targetlimit=$i->{targetlimit}";
                    if (exists $i->{server_side_prepares} and $i->{server_side_prepares} ne 't') {
                        $dbs .= ' ssp=FALSE';
                    }
                    if (exists $i->{makedelta} and $i->{makedelta} eq 'on') {
                        $dbs .= ' makedelta=ON';
                    }
                    $dbs .= '<br />';
                }
            }
            $dbs ||= 'NONE';

            ## Only the intereting ones in the future
            my $configs = 'NONE?!';
            if (keys %{$bc->{bucardo_config}}) {
                $configs = join '<br />', map { "$_: $bc->{bucardo_config}{$_}{value}" }
                    sort keys %{$bc->{bucardo_config}};
            }

            my $tables = '';
            if (keys %{$bc->{goat}}) {
                $tables = join '<br />',
                    sort
                    map { "$db $bc->{goat}{$_}{schemaname}.$bc->{goat}{$_}{tablename}" }
                    grep { $bc->{goat}{$_}{reltype} eq 'table' }
                    keys %{$bc->{goat}};
            }
            $tables ||= 'NONE';

            my $sequences = '';
            if (keys %{$bc->{goat}}) {
                $sequences = join '<br />',
                    sort
                    map { "$bc->{goat}{$_}{schemaname}.$bc->{goat}{$_}{tablename}" }
                    grep { $bc->{goat}{$_}{reltype} eq 'sequence' }
                    keys %{$bc->{goat}};
            }
            $sequences ||= 'NONE';

            my $syncs = '';
            if (keys %{$bc->{sync}}) {
                for my $name (sort keys %{$bc->{sync}}) {
                    my $s = $bc->{sync}{$name};
                    my $target = $s->{targetdb} ? "DB $s->{targetdb}"
                        : "DBGROUP $s->{targetgroup}";
                    $syncs .= "$name $s->{synctype} $s->{source} => $target";
                    for my $zero (qw/limitdbs onetimecopy maxkicks rebuild_index/) {
                        $s->{$zero} and $syncs .= " $zero=$s->{$zero}";
                    }
                    $s->{checktime} and $syncs .= " checktime=$s->{checktime}";
                    $syncs .= '<br />';
                }
            }
            $syncs ||= 'NONE';

            print qq{<tr><td>Config:</td><td><b>$configs</b></td></tr>\n};
            print qq{<tr><td>Databases:</td><td><b>$dbs</b></td></tr>\n};
            print qq{<tr><td>Tables:</td><td><b>$tables</b></td></tr>\n};
            print qq{<tr><td>Sequences:</td><td><b>$sequences</b></td></tr>\n};
            print qq{<tr><td>Syncs:</td><td><b>$syncs</b></td></tr>\n};
            print "</table></td></tr>\n\n";
        }
    }

    return;

} ## end of html_postgres_bucardo


sub html_postgres_postgis {

    ## Show some simple Postgis information for each cluster and database that uses it

    return if ! exists $data{gotpostgis};

    C: for my $cluster (sort { $a cmp $b } keys %{$data{postgres}{active_port}}) {
        my $info = $data{postgres}{active_port}{$cluster};
        next if ! exists $info->{gotpostgis};
        my $port = $info->{port} || '';
        my $socketdir = $info->{socketdir};

        for my $db (sort keys %{$data{postgres}{active_port}{$cluster}{db}}) {
            my $info = $data{postgres}{active_port}{$cluster}{db}{$db};
            next if ! exists $info->{postgis} or ! exists $info->{postgis}{postgis_full_version};
            print qq{<tr><th$vtop>${wrap}&rarr; PostGIS<br />$port<br />$socketdir<br />$db</th><td><br /><table border="1" class="plain">\n};
            print qq{<tr><td>Version:</td><td><b>$info->{postgis}{postgis_full_version}</b></td></tr>\n};
            print "</table></td></tr>\n\n";
        }
    }

    return;

} ## end of html_postgres_postgis


sub html_mysql {

    ## Show MySQL information

    return if ! exists $data{mysql};

    print qq{<tr><th$vtop>MySQL:</th><td><br /><table border="1" class="plain">\n};

    print qq{<tr><td>Version:</td><td><b>$data{version}{mysql}</b></td></tr>\n};
    print qq{<tr><td>Port:</td><td><b>$data{mysql}{port}</b></td></tr>\n};
    print qq{<tr><td>Socket:</td><td><b>$data{mysql}{socket}</b></td></tr>\n};
    if ($data{mysql}{status}) {
        my $stat = join '<br />' => @{$data{mysql}{status}};
        print qq{<tr><td>Status:</td><td>$stat</td></tr>\n};
    }

    my $dbs = join '<br />' => map { "<b>$_</b> ($data{mysql}{database}{$_}{tables} tables)" }
        sort keys %{$data{mysql}{database}};

    print qq{<tr><td>Databases:</td><td>$dbs</td></tr>\n};

    print qq{</table></td></tr>\n\n};

    return;

} ## end of html_mysql


sub html_ulimits {

    return if ! exists $data{ulimit};

    print qq{<tr><th$vtop>${wrap}User limits:</th><td><br /><table border="1">\n};
    print q{<tr><th>Name</th><th>Limit</th></tr>};
    for my $name (sort keys %{$data{ulimit}}) {
        my $limit = $data{ulimit}{$name};
        print qq{<tr><td>$name</td><td><b>$limit</b></td></tr>\n};
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_ulimits


sub html_envs {

    return if ! exists $data{ENV};

    print qq{<tr><th$vtop>${wrap}ENVs:</th><td><br /><table border="1">\n};
    print qq{<tr><th>Name</th><th>Value</th></tr>\n};

    my $skipnames = join '|' =>
        qw/COLORTERM DISPLAY G_BROKEN_FILENAMES LS_COLORS OLDPWD PGUSER PWD SHLVL STY TERM TERMCAP XAUTHORITY GCC_SPECS PS1/;
    my $skipre = qr{\b(?:$skipnames)\b};

    for my $e (sort { $a cmp $b } keys %{$data{ENV}}) {
        next if $e =~ $skipre;
        next if $e =~ /^SSH_/;
        my $val = $data{ENV}{$e} || '&nbsp;';
        if ($e =~ /PATH$/ or $e =~ /_DIRS$/ or $e eq 'TEXINPUTS' or $e eq 'INFODIR') {
            $val =~ s/^://;
            $val =~ s{:}{:<br />}g;
        }
        if ($e =~ /^CONFIG_PROTECT/) {
            $val =~ s{ }{<br />}g;
        }
        print qq{<tr><td>$e</td><td>$val</td></tr>\n};
    }
    print "</table></td></tr>\n\n";

    return;

} ## end of html_envs


sub html_yum {

    return if ! exists $data{yum};

    print qq{<tr><th$vtop>${wrap}yum installs:</th><td><br /><table border="1">\n};
    print qq{<tr><th>Name</th><th>Version</th>\n};
    print qq{<th>Name</th><th>Version</th></tr>\n};

    my $set = 1;
    for my $name (sort { $a cmp $b } keys %{$data{yum}{installed}}) {
        my $ver = $data{yum}{installed}{$name};
        if (1==$set) {
            print qq{<tr><td>$name</td><td>$ver</td>\n};
            $set = 2;
        }
        else {
            print qq{<td>$name</td><td>$ver</td></tr>\n};
            $set = 1;
        }
    }
    2==$set and print '<td>&nbsp;</td></tr>';
    print "</table></td></tr>\n\n";

    return;

} ## end of html_yum


sub html_aptitude {

    return if ! exists $data{aptitude};

    print qq{<tr><th$vtop>${wrap}apt-get installs:</th><td><br /><table border="1">\n};
    print qq{<tr><th>Name</th><th>Automatic?</th>\n};
    print qq{<th>Name</th><th>Automatic</th></tr>\n};

    my $set = 1;
    for my $name (sort { $a cmp $b } keys %{$data{aptitude}{installed}}) {
        my $auto = $data{aptitude}{installed}{$name} ? 'Yes' : 'No';
        if (1==$set) {
            print qq{<tr><td>$name</td><td>$auto</td>\n};
            $set = 2;
        }
        else {
            print qq{<td>$name</td><td>$auto</td></tr>\n};
            $set = 1;
        }
    }
    2==$set and print '<td>&nbsp;</td></tr>';
    print "</table></td></tr>\n\n";

    return;

} ## end of html_aptitude


sub html_gems {

    return if ! exists $data{gems};

    print qq{<tr><th$vtop>${wrap}Ruby local gems:</th><td><br /><table border="1">\n};

    my $table = make_table(
        {
            header => ['Gem','Version'],
            data   => $data{gems},
            onecol => 10,
        });

    print $table;

    print "</table></td></tr>\n\n";

    return;

} ## end of html_gems


sub escape_html {

  my $string = shift;

  $string =~ s{<}{&lt;}g;
  $string =~ s{>}{&gt;}g;
  $string =~ s{\n}{<br />}g;

  return $string;

} ## end of escape_html


sub make_table {

    my $arg = shift;

    my $header = $arg->{header} or die;
    my $data = $arg->{data} or die;
    my $numitems = keys %$data;

    ## How many items before we go to multiple columns?
    my $onecol = $arg->{onecol} || 15;

    ## How many columns?
    my $cols = $numitems <= $onecol ? 1
        : $numitems <= $onecol*2 ? 2
        : 3;

    my $table = q{<tr>};
    for (1..$cols) {
        $table .= join '' => map { "<th>$_</th>" } @$header;
    }
    $table .= qq{</tr>\n};

    my $pos = 0;
    for my $name (sort keys %$data) {
        $pos++;
        my $val = $data->{$name};
        $table .= sprintf q{%s<td>%s</td><td>%s</td>%s},
            1==$pos ? '<tr>' : '',
            $name,
            $val,
            $pos==$cols ? "</tr>\n" : '';
        if ($pos >= $cols) {
            $pos = 0;
        }
    }

    if ($pos and $pos < $cols) {
        for ($pos .. $cols-1) {
            $table .= '<td> &nbsp; </td>';
        }
        $table .= "</tr>\n";
    }

    return $table;

} ## end of make_table

