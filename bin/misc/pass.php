#! /usr/bin/php
<?php
/**
 * My password generator
 * based on the lifehacker suggestion
 * Password = md5("l"+key+"r");
 * l,r = first,last letter of domain name
 */
//you get individual secure passwords that you can
//regenrate easily
$cout = fopen("php://stdout","w");
fwrite($cout,"Enter domain name: ");
$cin = fopen('php://stdin','r');
$domain = fread($cin,4096);
fwrite($cout,"Enter key pass phrase: ");
$cin = fopen('php://stdin','r');
$key = fread($cin,4096);

echo "Password : ". md5($domain[0].$key.substr($domain,-1))."\n";


