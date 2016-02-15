#!/usr/bin/perl
use YAML::Syck;
use List::Util qw[min max];
use File::MimeInfo::Magic;
use File::Which;
use HTTP::Cookies;
use LWP::Simple;
use LWP::UserAgent;
use URI::Escape;

our %settings = ("searches" => [], "shortcuts" => [], "mimetypes" => [], "protocols" => []);

# Append a settings file to the settings hash
sub appendconfig {
	if (-e "$_[0]") {
		my $newsettings = YAML::Syck::LoadFile($_[0]);
		if ($newsettings->{default_search}) {
			$settings{default_search} = $newsettings->{default_search}
		}
		foreach my $section (keys %$newsettings) {
			if (ref($newsettings->{$section}) eq "ARRAY") {
				foreach my $i (keys $newsettings->{$section}) {
					$setting = (keys $newsettings->{$section}[$i])[0];
					$value = $newsettings->{$section}[$i]{$setting};
					if ($section eq "searches" &&
						  $settings{default_search} &&
							$settings{default_search} eq $setting) {
						$settings{default_search} = $value;
					}
					my $hsh = {$setting => $value};
					push(@{$settings{$section}}, $hsh);
				}
			} elsif (!$newsettings->{default_search}) {
				$settings{$section} = $newsettings->{$section};
}}}}

# Launch a browser given a URI
sub launchuri {
	my $proto = $_[0];
	$proto =~ s/^([[:alpha:]][[:alnum:]\+\.\-]*)\:\/\/.*/$1/;
	foreach my $pair (@{$settings{protocols}}) {
		my $protocol = (keys $pair)[0];
		if ($proto =~ /$protocol/) {
			my $perc_s = $_[0];
			(my $str = (values $pair)[0]) =~ s/%s/\'$perc_s\'/g;
			exec "$str";
	}}
	die "No protocol handler for protocol " . $proto;
}

# Search default engine given a string
sub search {
	if (exists $settings{default_search}) {
		my $perc_S = $_[0];
		my $perc_s = uri_escape($_[0]);
		for ($str = $settings{default_search}) {
			s/%S/$perc_S/g;
			s/%s/$perc_s/g;
		}
		launchuri($str);
	} else {
		die "No default search engine defined!";
}}

sub expand {
	my @arr = (split(' ', $_[0]));
	if (`type "$arr[0]" >/dev/null 2>\&1; echo \$?` == "0") {
		if (which($arr[0])) {
			return which($arr[0]) . ' ' . join(' ', @arr[1..$#arr]);
		} else {
			return "/bin/sh -c '$_[0]'";
		}
	} else {
		return $_[0];
	}
}

# Print help.
if ("@ARGV" eq '') {
	print "Usage: $0 <query>\n";
	exit;
}

# Read config files.
my $str = "@ARGV";
appendconfig("/etc/launchrc");
appendconfig("$ENV{'HOME'}/.launchrc");
if ($str =~ /(^| )-c .*/) {
	my $index = 0;
	++$index until $ARGV[$index] eq "-c" or $index > $#ARGV;
	my $file = $ARGV[$index + 1];
	$str =~ s/(^| )?-c[ \t]+$file( |$)?//;
	appendconfig("$file");
}
if ("$str" eq "-p") {
	$str = `xclip -o`
}

# Handle shortcuts.
foreach my $pair (@{$settings{shortcuts}}) {
  my $shortcut = (keys $pair)[0];
	if ($str =~ s/^$shortcut$//) {
		$str = expand((values $pair)[0]);
		break;
}}

# Handle searches.
foreach my $pair (@{$settings{searches}}) {
  my $search = (keys $pair)[0];
	if ($str =~ s/(^| )$search( |$)/ /) {
		$str =~ s/(^\s+|\s+$)//;
		my $perc_S = $str;
		my $perc_s = uri_escape($str);
		for ($str = (values $pair)[0]) {
			s/%S/$perc_S/g;
			s/%s/$perc_s/g;
		}
		$str = expand($str);
		break;
}}

# Try to exec.
my @list = split(' ', $str);
if ((-x $list[0]) && !(-d $list[0])) {
	exec "$str";

# Check for valid local file.
} elsif (-e "$str") {
	foreach my $pair (@{$settings{mimetypes}}) {
	my $type = (keys $pair)[0];
	my $ft = mimetype("$str");
	if ($ft =~ /$type/) {
		my $perc_s = "$str";
		($str = (values $pair)[0]) =~ s/%s/\'$perc_s\'/g;
		exec "$str";
	}}
	die "No MIME handler for MIME type " .$ft;

# Browse if a protocol exists.
} elsif ($str =~ /^([[:alpha:]][[:alnum:]\+\.\-]*)\:\/\/.*/) {
	launchuri($str)

# Check for responsive URI.
} else {
	my $uri;
	if ($str =~ /^[[:alpha:]][[:alnum:]\+\.\-]*\:\/\//) {
		$uri = $str;
	} else {
		$uri = "http://$str";
	}
	my $ua = LWP::UserAgent->new;
	if (exists $settings{cookies}) {
		my $cookie_jar = HTTP::Cookies->new(
			file => $settings{cookies},
		);
		$ua->cookie_jar($cookie_jar);
	}
	if ($ua->get($uri)->is_success) {
		launchuri($uri);

		# Fallback on search.
	} else {
		search($str)
}}

