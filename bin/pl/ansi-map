#!/usr/bin/env perl

use strict;
use warnings;
use List::Util qw( max );

my %attr = (
    Reset           => 0,
    Bold            => 1,
    Faint           => 2,
    Italic          => 3,
    UnderlineSingle => 4,
    BlinkSlow       => 5,
    BlinkRapid      => 6,
    ImageNegative   => 7,
    Conceal         => 8,
    UnderlineDouble => 21,
    IntensityNormal => 22,
    UnderlineOff    => 24,
    BlinkOff        => 25,
    ImagePositive   => 27,
    Reveal          => 28,
);

my %colbase = (
    Foreground  => 30,
    Background  => 40,
    ForeIntense => 90,
    BackIntense => 100,
);

my %colour = (
    Black   => 0,
    Red     => 1,
    Green   => 2,
    Yellow  => 3,
    Blue    => 4,
    Magenta => 5,
    Cyan    => 6,
    White   => 7,
    Reset   => 9,
);

my @colname = ();

while ( my ( $cbn, $cbv ) = each %colbase ) {
    while ( my ( $cn, $cv ) = each %colour ) {
        push @colname, $cbn . $cn;
        $attr{ $cbn . $cn } = $cbv + $cv;
    }
}

sub esc {
    "\e[" . join( ';', map { /^\d+$/ ? $_ : $attr{$_} } @_ ) . 'm';
}

sub centre {
    my ( $w, $str ) = @_;
    my $pad = $w - length $str;
    return $str if $pad <= 0;
    return ( ' ' x int( $pad / 2 ) ) . $str
      . ( ' ' x int( ( $pad + 1 ) / 2 ) );
}

sub colourtab {
    my ( $hdr, @pfx ) = @_;
    my @real = sort    { $attr{$a} <=> $attr{$b} } @colname;
    my @rows = grep    { /^Fore/ } @real;
    my @cols = grep    { /^Back/ } @real;
    my $len  = max map { length } @real;
    my $colw = 5;
    $_ = ' ' x ( $len - length $_ ) . $_ for @rows, @cols;

    # Header rows
    if ( $hdr ) {
        my @hdr = map { [ split // ] } @cols;
        for ( 1 .. $len ) {
            print ' ' x $len, ' ';
            for ( @hdr ) {
                print centre( $colw, shift @$_ );
            }
            print "\n";
        }
        print "\n";
    }

    for my $rc ( @rows ) {
        print "$rc ";
        ( my $rcn = $rc ) =~ s/^\s*//;
        for my $cc ( @cols ) {
            ( my $ccn = $cc ) =~ s/^\s*//;
            print esc( @pfx, $rcn, $ccn ), ' abc ';
        }
        print esc( 'Reset' );
        print "\n";
    }
}

sub alltab {
    my @others = sort { $attr{$a} <=> $attr{$b} }
      grep { $attr{$_} > 0 && $attr{$_} < 30 } keys %attr;
    my $hdr = 1;
    for my $pfx ( @others ) {
        print "=== $pfx ===\n";
        colourtab( $hdr, $pfx );
        $hdr = 0;
    }
}

alltab();
