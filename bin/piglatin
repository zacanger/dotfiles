#!/usr/bin/perl -p

# The only tricky bit is here. Y is not a vowel when looking for vowels,
# but neither is it a consonant when looking for consonants. Also, "qu"
# is a consonant.
my $vowel=qr/[aeiou]/i;
my $consonant=qr/(?:[^aeiouy]|qu)/i;

sub doword {
	$_=shift;

	return $_ if /^$consonant+$/;
	
	$ucfirst=(/^[A-Z]/);
	$scream=(/^[A-Z]+$/ && length > 1);
	$_=lc($_);
	
	if (/^($vowel)(.*)/) {
		$_="$1$2yay";
	}
	# Special case Y in as a consonant at the start of a word.
	elsif (/^(y$consonant*|$consonant+)(.*)/) {
		$_="$2$1ay";
	}
	if ($ucfirst) {
		return ucfirst($_);
	}
	elsif ($scream) {
		y/a-z/A-Z/;
		return $_
	}
	else {
		return $_;
	}
}

s/\b([A-Za-z]+)\b/doword($1)/eg;
