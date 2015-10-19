#!/usr/bin/perl
#
# This makes su actually run the the sudo command, if sudo is present.

# Make this file if I don't want to be able to su for a while.
if (-e "$ENV{HOME}/.nosu") {
	print STDERR "Sorry, su not currently allowed.\n";
	system "cat ~/.nosu";
	exit 100;
}

exec "/bin/su",@ARGV unless -x '/usr/bin/sudo';

foreach (@ARGV) {
	if (/-/) {
		# run proper su
		exec "/bin/su",@ARGV;
	}
}

while ($_=shift(@ARGV)) {
	$command.="-u $_ ";
}

if (!$prog) { $command.=$ENV{SHELL} }

exec "sudo -H $command";
