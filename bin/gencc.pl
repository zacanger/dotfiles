#!/usr/bin/perl
# gencc.pl - 2006 Jason Hill - http://qbfreak.net/twiki/Programs/GenccProg

# This little script will generate a credit card number with a valid
#   check-digit. Note that it is currently hard coded to generate a 16-digit
#   visa number. See http://www.beachnet.com/~hstiles/cardtype.html for more
#   information.

my $ccnum = 4;
my $chk = chkval(4);
my $flag = 0;
my $digit;

sub chkval {
    my $cdig = shift;
    if ( length($cdig) > 1) {
        return -1;
    }
    $cdig = $cdig * 2;
    if ( length($cdig) > 1) {
        $cdig = substr($cdig, 1, 1) + 1;
    }
    return $cdig;
}

for ($i=0;$i<14;$i++){
    $digit = (0..9)[rand 10];
    $ccnum .= $digit;
    if ($flag) {
        $flag = 0;
        $chk = $chk + chkval($digit);
    } else {
        $flag = 1;
        $chk = $chk + $digit;
    }
}

$ccnum .= (10 - ($chk % 10));

print "$ccnum\n";
