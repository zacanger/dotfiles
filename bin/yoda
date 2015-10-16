#!/usr/bin/perl

# Attempt at a yoda filter. Still needs work.

sub SwitchTwo { my @words=@_;
	if ($#words> 0) {
		$a=int(rand(1+$#words));
		$b=int(rand(1+$#words));
		if ($a ne $b) {
			($words[$a],$words[$b])=($words[$b],$words[$a]);
		}
	}	
	return @words;
}

srand($$ ^ time);
while (<>) {
	$collect.=$_;
	while ($collect=~m/(.*?)([.?!,]+)(.*)/s) {
		$collect=$3;
		$sep=$2;
		$phrase=$1;
		@words=split(/\s+/,$phrase);
		for (1..(int(rand($#words/4))+2)) {
			@words=SwitchTwo(@words);
		}
		print "@words$sep";
		if ($collect eq "\n") { 
			print $collect;
			undef $collect;
		}
	}
}
print $collect;
