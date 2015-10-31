#!/usr/bin/perl

# Provides a running estimate of when a long-running file-based process will complete,
# by watching how quickly a file/directory/other is growing or shrinking.
#
# Example:
#
#   In one window, 'sftp' is running, downloading system_backup.tgz from another computer.
#
#   In another window, run:
#           eta 2.5gb ./system_backup.tgz
#   
#   eta will then provide a time estimate of how long until the file grows to 2.5gb.


    use strict;
    use warnings;

    use Time::HiRes qw(time);
    use POSIX qw(strftime);

    use Data::Dumper;
    #use Devel::Comments;           # uncomment this during development to enable the ### debugging statements

    use constant {LATEST => -1, EARLIER => 0, TIME => 0, MEAS => 1};



    # For development, a simple way to test this is to:
    # 
    #       eta  500 "perl -le 'print time-$(perl -le 'print time')'|"
    #
    #       eta -500 "perl -le 'print $(perl -le 'print time')-time'|"


## process the cmdline
@ARGV >= 2       or die <DATA>;
my $target = parse_size(shift @ARGV);
my $measure_string = shift @ARGV;        ## what/how to measure
my $measure;
my $moving_average_window = shift @ARGV || 10;      ## number of seconds to include in the moving average
if ($measure_string =~ s/\|$//s) {
    $measure = sub {firstnum(readpipe $measure_string)};
} elsif (-f $measure_string) {
    $measure = sub {-s $measure_string};
} elsif (-d $measure_string) {
    $measure = sub {sum(map{-s}grep{-f}glob"$measure_string/*")};
} else {
    warn "Unrecognized measure:  '$measure_string'\n\n";
    die <DATA>;
}


## main loop -- estimate how long until completion
my @meas = ([time, $measure->()]);      # recent measurements
sleep(1);
while (1) {
    push @meas,   [time, my $current = $measure->()];
    ## only keep the most recent 10.0 seconds of measurements
    @meas = grep {$meas[-1][0] - $_->[0] < $moving_average_window} @meas;
    #print "\t", join(" ", map {$_->[MEAS]} @meas), "\n";       
    ## bytes per second
    my $bps = ($meas[LATEST][MEAS] - $meas[EARLIER][MEAS]) / ($meas[LATEST][TIME] - $meas[EARLIER][TIME]);
    printf "currently: %-20s", commify($current);
    if ($bps > 0.1 || $bps < -0.1) {
        my $eta = ($target - $current) / $bps;
        printf "rate: %-20s", human_readable_rate($bps);
        printf "remaining:  %s%d:%02d:%02d:%02d (DAY:HH:MM:SS)\n",
            sign_str($eta), abs($eta)/86400, abs($eta)/3600 % 24, (abs($eta)/60) % 60, abs($eta) % 60;
    } else {
        print "(stalled)\n";
    }
    $| = 1;
    sleep 2;
}


use constant UNIT => {
    k => 1024 ** 1,
    m => 1024 ** 2,
    g => 1024 ** 3,
    t => 1024 ** 4,
    p => 1024 ** 5,
    e => 1024 ** 6,
};
sub parse_size {
    my ($string) = @_;
    
    # remove commas
    if ($string =~ /^(-?[0-9\.,]+)(.*)/s) {
        my ($nums, $suffix) = ($1, $2);
        $nums =~ s/,//sg;
        $string = $nums . $suffix;
    }

    if ($string =~ /^-?[0-9\.]+$/ && $string =~ /\d/) {
        return int($string);
    } elsif ($string =~ /^(-?[0-9\.]+)\s*([kmgt])b?$/si) {
        return int($1 * UNIT->{lc($2)});
    } else {
        #return undef;
        die "Unable to parse number: $string\n";
    }
}


sub human_readable_rate {
    my $bps = shift;

    if (abs($bps) > 5 * 1024) {
        if (abs($bps) > 5 * 1024 * 1024) {
            return sprintf('%d mBps', $bps/(1024*1024));
        } else {
            return sprintf('%d kBps', $bps/1024);
        }
    } elsif (abs($bps) < 1)  {
        return sprintf('%.5f Bps', $bps);
    } else {
        return sprintf('%d Bps', $bps);
    }
}



# takes a string, and returns the number at the start of the string
sub firstnum { $_[0] =~ /^\s*([-+]?[\d\.,]*)/ && return $1 }

# add commas to a number
sub commify {(my$text=reverse$_[0])=~s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;scalar reverse$text}

# trim spaces
sub trim {my@a=map{(my$s=$_)=~s/^[\s\n\r]+|[\s\n\r]+$//gs;$s}@_;wantarray?@a:$a[0]}

# List::Util
{no strict; sub reduce(&@) {$s=shift;@_>1||return$_[0];$c=caller;local(*{$c."::a"})=\my$a;local(*{$c."::b"})=\my$b;$a=shift;for(@_){$b=$_;$a=&{$s}()}$a}}
sub sum (@) { reduce { $a + $b } @_ }
sub min (@) { reduce { $a < $b ? $a : $b } @_ }
sub max (@) { reduce { $a > $b ? $a : $b } @_ }
sub minstr (@) { reduce { $a lt $b ? $a : $b } @_ }
sub maxstr (@) { reduce { $a gt $b ? $a : $b } @_ }

# display a string to the user, via `xxd`
sub xxd {open my$xxd,"|xxd"or die$!;print$xxd $_[0];close$xxd}

sub sign {$_[0]==0?0:$_[0]<0?-1:1}
sub sign_str {$_[0]<0?"-":""}



() = <<'#DEVNULL';

        # unit-test parse_size()
        foreach my $test (map {s/^\s+|\s+$//;$_}  split /[\n\r]+/s, <<'EOF') {
                chicken
                46tb
                5mb
                5m
                5M
                5.4M
                5.4 m
                .
                4.0
                5,412 mb
EOF
            print "$test\n\t";
            my $parsed = parse_size($test);
            if (defined($parsed)) {
                print commify($parsed), "\n";
            } else {
                print "(undef)\n";
            }
        }
#DEVNULL


__DATA__
Usage:  eta <target_size>  <measure>    [<moving_avg_window>]

Estimates when a long-running file-based operation will be complete,
by measuring how quickly a file/directory/other is growing (or shrinking).

target_size
        Size can be specified in bytes, or other formats like:
                3.2 tb
                5,412 mb

measure
        Specifies the thing that will be periodically measured, to indicate the
        'current file size'.
        Can be one of three things:
            - a filename
            - a directory name
            - a shell command that will get run periodically, that outputs
              the current file size
    
        if a directory is specified, this tool will add up the size of all
        files in that directory only -- subdirectories are not included.
        
        To indicate a shell command, append a pipe character ('|') to the end
        of the command.

        For example, to estismate the time until a file system runs out of space, using df:

                eta 0kb "df -B 1 /var | awk 'NR==2 {print \$4}' |"

moving average window
        The number of seconds of recent data to use, for calculating the estimate.
        Defaults to 10 seconds, but you may want to go much longer if the process you're
        estimating lasts for hours or days.
