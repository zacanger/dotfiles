#!/usr/bin/env perl
#########################################################################
# Copyright (C) 2012  Wojciech Siewierski                               #
#                                                                       #
# This program is free software: you can redistribute it and/or modify  #
# it under the terms of the GNU General Public License as published by  #
# the Free Software Foundation, either version 3 of the License, or     #
# (at your option) any later version.                                   #
#                                                                       #
# This program is distributed in the hope that it will be useful,       #
# but WITHOUT ANY WARRANTY; without even the implied warranty of        #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
# GNU General Public License for more details.                          #
#                                                                       #
# You should have received a copy of the GNU General Public License     #
# along with this program.  If not, see <http://www.gnu.org/licenses/>. #
#########################################################################

use warnings;
use strict;
use Pod::Usage;

unless (@ARGV == 0) {
    pod2usage({ -verbose => 2 }) if $ARGV[0] eq "--help"
                                 or $ARGV[0] eq "-h";
}

=head1 NAME

One - a unified interface for apt, dpkg etc.

=head1 SYNOPSIS

B<one> B<command> [ I<command_arguments> ... ]

B<one> [ -- ] I<packages_to_install> ...

=head1 DESCRIPTION

    One Tool to manage them all, One Tool to find them,
    One Tool to install them all and in the darkness run them

One provides a unified interface for Debian package manager which is quite
fragmented (I<dpkg>, I<aptitude>, I<apt-get>, I<apt-cache>,
I<apt-file>...). Just one simple extensible tool combining the most frequently
used functions of the mentioned tools. The available functions are fully
customizable - One can even be adjusted to a completely different package
manager.

=head1 GOALS

=over 4

=item * a single central program to run each command (no need to remember when
we should use I<apt-get> instead of I<aptitude>)

=item * simple and flexible configuration

=item * as little overhead as possible - no output parsing etc., just a simple exec

=item * no custom commands by default - uses only the well-tested standard
Debian commands

=item * short commands inspired by the I<equery> tool in Gentoo

=back

=head1 OPTIONS

=over 4

=item B<(blank)> I<packages>

Install the specified packages.

Command: sudo aptitude install

=item B<b> I<package>

Install build-dependencies of a package.

Command: sudo aptitude build-dep

=item B<src> I<package>

Download the source code of a package.

Command: apt-get source

=item B<s> I<search_term>

Search in the package database.

Command: aptitude search

=item B<i> I<package>

Show the package details.

Command: aptitude show

=item B<f> I<search_term>

Search for packages containing matching files.

Command: apt-file search

=item B<F> I<regex>

Search for packages containing matching files.

Command: apt-file search -x

=item B<l> I<package>

List files owned by the package (which must be installed).

Command: dpkg -L

=item B<L> I<package>

List files owned by the package (which must B<not> be installed).

Command: apt-file list

=item B<o> I<file>

Show which package owns the file.

Command: dpkg -S

=item B<w> I<package>

Show why the package was installed.

Command: aptitude why

=item B<u>

Perform system upgrade.

Command: sudo aptitude update && sudo aptitude upgrade

=item B<uu>

Perform full system upgrade.

Command: sudo aptitude update && sudo aptitude full-upgrade

=item B<rm> I<packeges>

Remove the specified packages.

Command: sudo aptitude purge

=back

=cut

my %commands = (
                TUI  => "aptitude",
                "--" => "sudo aptitude install",
                b    => "sudo aptitude build-dep",
                src  => "apt-get source",
                s    => "aptitude search",
                i    => "aptitude show",
                f    => "apt-file search",
                F    => "apt-file search -x",
                l    => "dpkg -L",
                L    => "apt-file list",
                o    => "dpkg -S",
                w    => "aptitude why",
                u    => "sudo aptitude update && sudo aptitude upgrade",
                uu   => "sudo aptitude update && sudo aptitude full-upgrade",
                rm   => "sudo aptitude purge",
                moo  => <<EOF,
echo '
                     @@@@@@ @
                   @@@@     @@
                  @@@@ =   =  @@
                 @@@ @ _   _   @@
                 @@@ @(0)|(0)  @@
                @@@@   ~ | ~   @@
                @@@ @  (o1o)    @@
               @@@    #######    @
               @@@   ##{+++}##   @@
              @@@@@ ## ##### ## @@@@
              @@@@@#############@@@@
             @@@@@@@###########@@@@@@
            @@@@@@@#############@@@@@
            @@@@@@@### ## ### ###@@@@
             @ @  @              @  @
               @                    @
...."Have you GNUed today?"...'
EOF
               );

=head1 CONFIG

The config file F<~/.onerc> has a very simple syntax:

    name arbitrary_command_to_run
    # comment

For the default "s" option it would be

    s aptitude search

The separator between I<name> and I<arbitrary_command_to_run> can be any
whitespace character.

The existing commands can be overridden but keep in mind there are two special
commands: "--" which is used for the blank command (package install by default)
and "TUI" which is used when One is run without any arguments (interactive
aptitude interface by default).

=cut

if (-r "$ENV{HOME}/.onerc") {
    open(my $config, '<', "$ENV{HOME}/.onerc");
    my $line = 0;
    while (<$config>) {
        ++$line;
        next if /^#|^\s*$/;     # omit comments and empty lines
        (my ($arg, $command) = /^
                                (\S+)   # argument
                                \s+     # separator
                                (.+)    # command
                                $/x) or die "invalid syntax in line $line: $_";
        $commands{$arg} = $command;
    }
    close $config;
}

exec $commands{TUI} if @ARGV == 0; # no arguments, just run TUI aptitude

my $arg = shift;
my $cmd = $commands{$arg} //
          (unshift(@ARGV, $arg) && $commands{"--"}); # oops, the arg was not an arg
                                                     # recover the package name

$_ = "'$_'" for @ARGV;          # quote arguments

exec "$cmd @ARGV";
