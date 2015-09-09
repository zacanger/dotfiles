#!/usr/bin/env perl

use strict;
use warnings;
use Encode qw/decode/;
use Gtk2 -init;
use Pod::Usage qw/pod2usage/;

my $encoding = 'utf8';
my $data = decode $encoding, do { local $/; <STDIN> } || '';

&main();exit;

sub main() {
    my $clip = Gtk2::Clipboard->get(Gtk2::Gdk->SELECTION_CLIPBOARD);
    $clip->set_text($data);
    $clip->store;
    Gtk2->main_iteration_do(1) if $^O eq 'MSWin32';
}