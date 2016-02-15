#!/usr/bin/env perl

use strict;
use warnings;

use Digest::MD5;
use File::Find::Rule      ();
use File::Find::Rule::VCS ();
use Getopt::Long;

select STDERR;
$| = 1;
select STDOUT;
$| = 1;

my %opt = (
  link    => 0,
  strict  => 0,
  vcs     => 0,
  verbose => 0,
);

GetOptions(
  'link'    => \$opt{link},
  'strict'  => \$opt{strict},
  'V|vcs'   => \$opt{vcs},
  'verbose' => \$opt{verbose},
) or die "Bad options\n";

@ARGV = ( '.' ) unless @ARGV;
my @dups = finddups( @ARGV );
if ( $opt{link} ) {
  make_links( @dups );
}
else {
  for my $set ( @dups ) {
    print "$_\n" for @$set;
    print "\n";
  }
}

sub mention(@) {
  return unless $opt{verbose};
  print STDERR "$_\n" for split /\n/, join '', @_;
}

sub filter_set {
  my @files = @_;

  my $cb        = pop @files;
  my $func      = pop @files;
  my %by_digest = ();

  for my $file ( @files ) {
    my $digest = $func->( $file );
    push @{ $by_digest{$digest} }, $file
     if defined $digest;
  }
  while ( my ( $dig, $set ) = each %by_digest ) {
    eval { $cb->( $dig, @$set ) if @$set > 1 };
    warn $@ if $@;
  }
}

sub finddups {
  my @dirs    = @_;
  my %by_size = ();
  my %dup     = ();

  my $ff = File::Find::Rule->new;
  $ff->ignore_vcs unless $opt{vcs};
  $ff->size( ">=64ki" );

  my @statfields = $opt{strict} ? ( 2, 4, 5, 7 ) : ( 7 );
  my %seen_inode = ();

  my $hash_part = sub {
    my $obj = shift;
    mention "Partial Hashing $obj";
    open my $fh, '<', $obj or die "Can't read $obj: $!\n";
    defined sysread $fh, my $buf, 2048
     or die "Read error on $obj: $!\n";
    return Digest::MD5->new->add( $buf )->hexdigest;
  };

  my $hash_full = sub {
    my $obj = shift;
    mention "Full Hashing $obj";
    open my $fh, '<', $obj or die "Can't read $obj: $!\n";
    return Digest::MD5->new->addfile( $fh )->hexdigest;
  };

  my @dups = ();

  my $keep = sub {
    my ( $digest, @set ) = @_;
    push @dups, \@set;
  };

  filter_set(
    $ff->file->in( @dirs ),
    sub {
      my $obj = shift;
      mention "Checking $obj";
      my @st = lstat $obj;
      return if $seen_inode{ join '-', @st[ 0, 1 ] }++;
      return join ' ', @st[@statfields];
    },
    sub {
      my ( $digest, @set ) = @_;
      my @st = split / /, $digest;
      if ( $st[-1] >= 65536 ) {
        filter_set( @set, $hash_part,
          sub { shift; filter_set( @_, $hash_full, $keep ) } );
      }
      else {
        filter_set( @set, $hash_full, $keep );
      }
    }
  );

  return grep { @$_ > 1 } @dups;
}

sub make_links {
  my @sets  = @_;
  my $suf   = 'AAAAA';
  my $saved = 0;
  for my $set ( @dups ) {
    my $first = shift @$set;
    my @fst   = lstat $first;
    for my $obj ( @$set ) {
      my @ost = lstat $obj;
      next if $ost[0] == $fst[0] && $ost[1] == $fst[1];
      my $tmp = "$obj.$suf";
      while ( -e $tmp ) {
        $suf++;
        $tmp = "$obj.$suf";
      }
      mention "Linking $first to $obj";
      eval {
        link $first, $tmp or die "Can't link $first to $tmp: $!\n";
        rename $tmp, $obj or die "Can't rename $tmp to $obj: $!\n";
        $saved += $ost[7];
      };
      warn $@ if $@;
    }
  }
  mention "Saved $saved bytes";
}

# vim:ts=2:sw=2:sts=2:et:ft=perl

