#!/usr/bin/perl
#Tries to absolute perfectlyjustify file. Otherwise, makes best fit.
#Algorythm sucks, not optomized. Oh, well..

while (<>) {
		chomp;
		$line.=$_.' ';
}
$line=~tr/\t/ /s;
$line=~tr/ / /s;
$line=~s/^ //;
$line=~s/ $//;
(@words)=split(/ /,$line);
$c=0;
foreach(@words) {
	$lengths[$c++]=length($_);
}

$ok='';
$margin=1;
while ((!$ok) && ($margin<10)) {
$x=80;
while ((!$ok) && ($x>0)) {
		$try=1;
		$currword=0;
		$string='';
		$rlines=0;
		while ($try) {
				$string.=$words[$currword++].' ';
				$cnt=length($string);
				if (abs($x-$cnt)<$margin) {
						@result[$rlines++]="$string\n";
						$string='';
 				} 
				elsif ($cnt>$x) {
						$try='';
            $rlines=0;
						$string='';
				} 
				elsif ($currword>$#words) {
            @result[$rlines++]="$string\n";
            $try='';
            $ok=1;
        }
		}
		$x--;
}
	$margin++;
}
if ($ok) { foreach (0..$rlines-1) { print $result[$_] } }
print ($margin-1);
print "\n";
