#!/usr/bin/perl
############################################################
#
#  copyright 2005,2006 Jaromir Mrazek
#   address:     Jaromir Mrazek, NPI Rez, 25068 Rez, Czech Republic
#                mirozbiro @ seznam.cz
#  this program is distributed under the terms 
#     of GNU General Public Licence
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
# 
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
############################################################

print `echo -e  "\\033]0;calc.pl\\a\\c"`; # make term title "calc.pl" 
$SIG{INT}=\&catchupsig;



######################  #######################################
#               CONSTANTS   -   user can redefine
######################  #######################################
$offs=32;  # offset to display a result
$magnl=3;  # go to expon. form when less then 1E-3
$magnh=5;  # go to expon when more then 9.999E+5
$precis=8; # number of valid decimal places

$switchcomma=0; # ==0:Use decimal point(.dec.numbers) and comma(,fields)
$switchcomma=0; # ==1:Comma(,for decimal numbers) and a semicolon(; for fields)


$e=2.71828182845904523536;
$pi=3.141592653589;
$hbar=6.581E-22;  # MeV.s
$ec=1.602E-19;    # Coulomb
$hbarc=197;       # Mev.fm


@history=qw();
%fieldvar;

###########--------------  common debug switch: 0,1,2
my $debug=0;
my  $Warning="";







##############################################
# command  prompt
###############################################

sub get_cmdstr{
    my @history=@_;
    my $s="";
    my $pos=0;
    my $buf="";
    my $hispos=$#history+1;
 open(TTY, "+</dev/tty") or die "no tty: $!";
 system "stty  cbreak </dev/tty >/dev/null 2>/dev/null &";

 while(1==1){
 my $arr="";
 my $key = getc(TTY);
 # print "\b\b \b\b";
  if ($debug>1){print ":character=$key   length=",length($key),"  ord=",ord($key) ,"\n"; }

 # esc, [, ABCD are arrows ......................................

  if  ( ord($key)==1){ $arr="j1";print "\b \b"}# jumps Ctrl-A,D,E
  if  ( ord($key)==4){ $arr="de";print "\b \b"}# ctrl-D
  if  ( ord($key)==5){ $arr="j2";print "\b \b"}# ctrl-E, sometimes "xterm"?
  if  ( ord($key)==18){ $arr="j2";print "\b \b"}  # ctrl R as alternative to E
### 21 22   UV
  if  ( ord($key)==21){ $arr="up";print "\b \b"} # U
  if  ( ord($key)==22){ $arr="do";print "\b \b"} # V
  if  ( ord($key)==10){ $arr="en";}#  enter
  #---- variant bksp=8 in icewm
  if  ( ord($key)==8){ $arr="bk";print "\b \b"}
  if  ( ord($key)==127){ $arr="bk";print "\b \b"}
  if  ( ord($key)==11){ $arr="ck";print "\b \b"} # Ctrl-K


#======================================================
  if ( ord($key)==27){    #---esc
      print "\b\b  \b\b";
      $key = getc(TTY);
  if ($debug>1){ print ":character=$key   length=",length($key),"  ord=",ord($key) ,"\n";}

#------------   key 79 at redhat 8.0
    if ( ord($key)==91 ||  ord($key)==79){  #--arrows (and insert..
       print "\b \b";
       $key = getc(TTY);
       print "\b \b";
  if ($debug>1){ print ":character=$key   length=",length($key),"  ord=",ord($key) ,"\n";}
       if ( ord($key)==65){$arr="up";}
       if ( ord($key)==66){$arr="do";}
       if ( ord($key)==67){$arr="ri";}
       if ( ord($key)==68){$arr="le";}
        # delete key
       if ( ord($key)==51){
          print "\b \b";$key = getc(TTY);if ( ord($key)==126){$arr="de";}}
        #insert
       if ( ord($key)==50){   
          print "\b \b";$key = getc(TTY);if ( ord($key)==126){$arr="in";}}
        #home
       if ( ord($key)==72){print "\b \b";$arr="j1";}
       #end 
       if ( ord($key)==70){print "\b \b";$arr="j2";}
       
    } #arr

#----------
    if ( ord($key)==79){  #--home end on kde
       print "\b \b";
       $key = getc(TTY);
       print "\b \b";
  if ($debug>1){ print ":character=$key   length=",length($key),"  ord=",ord($key) ,"\n";}
        #home 
       if ( ord($key)==72){    print "\b \b";$arr="j1";}
        #end 
       if ( ord($key)==70){    print "\b \b";$arr="j2";}
       
    } #homend kde
       
#----------==================================--------
  } #esc 
  else{ print "\b \b"}
 #.............................................................


###################################" PERFORM OPERATIONS on cmdline ######
 #---------------------------------------------
  if ( $arr ne ""  ){
  #  print "arrow $arr\n";
    CASE:{
        if($arr eq "j1"){$pos=0;print "\r$s\r";last CASE}
        if($arr eq "j2"){$pos=length($s);print "\r$s";last CASE}
        if($arr eq "en"){last CASE}
        if($arr eq "le"){
              if ($pos>0){$pos--;print "\r$s\r",substr($s,0,$pos);}
               else{print "\r$s\r";}
            last CASE}
        if($arr eq "ri"){
            $pos++;
	    print "\r$s\r",substr($s,0,$pos);
	    last CASE}
        if($arr eq "up"){
	    if ($buff eq ""){$buff=$s;}
	    print "\r"," "x length($s);
	    if ($hispos>0){$hispos--}
	    $s=$history[$hispos];
            $pos=length($s);
	    print "\r$s";
	    last CASE}
        if($arr eq "do"){
	    print "\r"," "x length($s);
	    if ($hispos<$#history){$hispos++;
	        $s=$history[$hispos];
                }else{$s=$buff;$buff="";
		      if ($hispos<=$#history){$hispos++;}
                }
            $pos=length($s);
	    print "\r$s";
	    last CASE}
        if($arr eq "de"){
            print "\b \b";
            $s=substr($s,0,$pos).substr($s,$pos+1,length($s));
	    print "\r$s \r",substr($s,0,$pos);
	    last CASE}
        if($arr eq "ck"){ # Ctrl-K
            print "\b \b";
            print " "x length($s);$s=substr($s,0,$pos); 
	    print "\r$s \r",substr($s,0,$pos);
	    last CASE}
        if($arr eq "bk"){
            if ($pos>0){
            print "\b \b";
            my $ss=substr($s,0,$pos-1).substr($s,$pos,length($s));
            $s=$ss;
            $pos--;
	    print "\r$s \r",substr($s,0,$pos);
	    last CASE;
	    }
        }
    }
  }else{
    if ($pos==length($s)){
        print $key;
        $s.=$key;
    }else{
	$s=substr($s,0,$pos).$key.substr($s,$pos,length($s));
        #print $key,substr($s,$pos+1,length($s));
        print "\r$s \r",substr($s,0,$pos+1);
    }
      $pos++;
 }
 # print "\b";
 if($arr eq "en"){last;}
 }# while....
 close TTY;
 system "stty  -cbreak   </dev/tty >/dev/tty 2>&1"; 
 return $s;
}#.......... end of routine............





#print "velkyosle";
#print ">",&get_cmdstr,"<\n";
#exit;http://mathomatic.orgserve.de/math/feedback.html





$Helpv="
-----------------------------------------------------------
OUTPUT/INPUT FORMATING
    offs = 32 # offset to display a result
   magnl = 3  # go to exponential form when less then 1E-3
   magnh = 5  # go to exponential when more then 9.999E+5
  precis = 8  # number of displayed decimal places

  switchcomma = 0; # 0:decimal point; 1:decimal comma(+semicolon; for fields)

predefined PHYSICAL CONSTANTS
    e = 2.71828182845904523536  # euler constant
   pi = 3.141592653589          # PI
 hbar = 6.581E-22               # MeV.s   planck constant/2PI
   ec = 1.602E-19               # Coulomb - electron charge
hbarc = 197                     # MeV.fm
-----------------------------------------------------------
";


$Helpfyz="
PHYS    | ------------------------------------------------------------
  conv B| Time <=> red.tr.prob. 
        |     bb2t12(keV, B[eb],sigL)   ... eb   -> partial level lifetime
        |     bw2t12(keV, B[wu],sigL,A) ... w.u. -> partial level lifetime
        |     t122bb(keV, T12,  sigL) ...  partial level lifetime -> eb 
        | Reduced.transition.probabilities. in different units:
        |     b2b( Bvalue,  sigmaL, conversion, A): 
        |       eg. b2b(101,E2,FW,77)
        |       conv: BF BW FB FW WB WF  (uppercase to avoid collision)
        |       A if not supplied, taken from var a. e.g.a=32 (just W.U.)
        |     btw:
        |      B(E2,0->2,A=46)=196e2fm4=20wu.  B(E2 2->0)=1/5(0->2)=4wu
        |      B(E2,0->2,A=44)=0.0314e2b2=34wu.B(E2 2->0)=1/5(0->2)=6.8wu
        |      delta=sqrt(   bw2t12(ene,bm1,M1,a)/ ( bw2t12(ene,be2,E2,a) )  )
        |
        | Neutron tof <=> Energy_n:
        |     tof2e(tof,distance,A), e2tof(E,dist,A)..
        |     neutron tof in ns, dist in meters, A-mother nucleus
        |
";

$Helpf="
-----------------------------------------------------------
      financ: |find final amount 
              |  GETINTER(interest (1%=0.01),#months,init \$, monthly savs, ys)
              |find time in months to save aim
              |  SOLVEINTERM(aim \$, interest (1%=0.01), ini\$, monthly\$,yrly\$)
              |find what must be an interest to save the aim
              |  SOLVEINTERI( aim\$, #months, initialy \$, m\$,y\$ )
              | 
          mat:|  p0,p2,p4(legendre pol.)... usually used as p2(cos(45)) 
              |
 stat(FIELDS):|  TO COME !!!
-----------------------------------------------------------
";


$Help="
-----------------------------------------------------------
numbers:      |  as usual    0.34   1.2E+6     etc.
              |  hours:minutes         ... transformed directly to minutes
              |  hours:minutes:seconds ... transformed directly to seconds
operations    |     +,-,*,/,**,^,sqrt
              |     :,:: (conversion to hours:minutes,hms)
              |          -3+5 is operation on the last result!!
              |          BUT (-1)*3+5 is 2 or _-3+5 is 2 (_ stands for blank)
functions:    |  not case sensitive.!! (always autotransformed to uppercase)
              |  sin,cos,tan,asin,acos,atan,exp,ln,log  .... etc
               ==>>  for help on special functions:   ### helpf ###
              |
switches:     |    deg,rad        ... operates in degrees, radians(default)
              |    \"default operation mode 1\": +<enter>  ,-<enter> 
              |    \"default op. mode 2\": +++number<enter>  (or ***,---,///)
              |    clear \"default op.mode\"        <enter>
              |    
Variables:    |  lowercase ONLY!! NO numbers in the name!!  ### helpv ###
              |  var=3+3,  var=, =var (to keep the last result),  
              |  (a,b,c)=(10+1,4.4*2.5+1,44/4+2) ... multiple assignement
              |  var (prints the value)
              |  predefined variables:   pi, e, offs ... offset of printout
--------------------------------------------
        to switch to DECIMAL COMMA from decimal point do  switchcomma=1
                   or change the value in the program - line 39
more help: helpv helpf(func.) helpfyz(physfunc) helpm(mathomatic) helpcatch
";



$Helpcatch="
--------------------------------------------
Functions: use <enter> as a reference to previous result 
          (eg. sin<enter> makes sin(previous result)
              15-<enter> makes 15-previous result
              0-<enter>  changes the sign previous result
Problems and catches: 
   *)     -3 is operation, <space>-3 is negative number
   *)    Cannot solve equations: e.g.  =a+3  or   a+1=, but a=3+4 is ok.
-------
Mathomatic call included :),   call >mat<   
         ==>> for help:  ### helpm ###
-----------------------------------------------------------
";
#2do:  ...,  interpolation,...vectors...




$Help_mat="
------------- http://mathomatic.orgserve.de/math/am.htm -------------
clear all        :----  solving eq:
a^2=b^2+c^2
a                         solves for a
derivative b              (deri) makes da/db
simplify                  (simp, simp quick, simp poly)
optimize                  repeating parts moved to buffer..
integrate                 (inte) dumb integration
: ------  
e=f+f^2*pi+e#^2         : e=2.71, pi=3.14, 
sensitivity e           : (sens) tests how var changes...
: ----    elimination, calc, output
f=x+1                 : 4=3+1
f=x^2-5               : 4=3^2-5
elim x                : eliminate x
f                     : quadratic result (sign op.)
calc                  : prints out the results for f (calculate)
#1                    : recall (select) equation f=x+1
x                     : x=f-1
replace f with 4      : the result for x
code 2                : output eq. 2 in  C syntax
list export  [all]    : exports in reasonable format (for tex??)
: ---   extrema
y=(x^3) + (x^2) - x
extrema x                 (extr) finds extremas
calc                       evaluates nonnumeric solutions
: ----   taylor expansion
y=x^3+x^2+x
tayl x
: ---
quit  :--------- can do imaginary, laplace, limits etc.., fact, unfact
----------------------------------------------
";





#----- REAL CODE -----------#----- REAL CODE -----------#----- REAL CODE
#--- REAL CODE --------#----- REAL CODE ---------#----- REAL CODE
#----- REAL CODE -----------#----- REAL CODE -----------#----- REAL CODE


if ($ARGV[0]=~/^\-h/i){print $Help;exit 0;}
if ($ARGV[0]=~/^\-hf/i){print $Helpf;exit 0;}
if ($ARGV[0]=~/^\-hm/i){print $Help_mat;exit 0;}
#print "                ....calc.pl 050315: type help to get short help\n";
#print "                ....calc.pl 060112: type help to get short help\n";
#print "                ....calc.pl 060816: emited type help to get short help\n";
#print "                ....calc.pl 060817: vectors alphaversion type help to get short help\n";
#print "                ....calc.pl 060817: vectors alphaversion, stats. type help to get short help\n";
#print "                ....calc.pl 060828: vectors alphaversion, stats, switchcomma-locale\n";
print "                ....calc.pl 061107: fields not released yet, few bugs fixed\n";

     open IN,"$ENV{HOME}/.calc.pl";
        while (<IN>){ chop($_);push @history,$_;}
     close IN;


$Defoperat="";
$R2dc=1; # radians default



########################################################
########################################################
###        THE MAIN LOOP
########################################################
########################################################
while(1==1){

  $Warning="";



 $_=&get_cmdstr(@history); 
#### $_="e2tof(0.421,1.22,17)";
 if ($debug>=1){print "input line:$_\n";}
# if ($debug>=2){print "input line:$_\n";}

 push @history, $_;
 $xXx=$_;
 if ($DO>0) {print " "x$offs,">$xXx<\n";}

 #-----------------  vyrad nebezpecne prikazy!!!
 #-----------------  vyrad nebezpecne prikazy!!!
 if  ($xXx=~/(?:exec|system|unlink|open|close|delete|\`|sub|char|ord|\$|\\|\@|\{|\}|\[|\])/){$xXx="0";$Warning="..forbiden word or character";}


 $xXx=~s/\^/\*\*/g;   # change ^ to **

 $xXx=~s/\"//g;   #  remove ", '
 $xXx=~s/\'//g;   #  remove ", '


  if ( $switchcomma==1 ){
      $xXx=~s/,/\./g; 
      $xXx=~s/;/,/g; 
  }

#------IMMEDIATELY REPLACE FUNCTIONS with UPPERCASE
#         sqrt,exp,log....  jen sranda, aby se nepouzily jmena fci
#------  !!! ORDER is important !!!!!!
 @functions=qw(
sqrt exp log ln  
atan asin acos
sin cos tan 
p0 p1 p2 p3 p4 
pow
getinter solveinterm solveinteri
bb2t12   bw2t12   t122bb 
rerate fluxap fluxpa rho t2gcm gcm2t
b2b
rad deg
tof2e  e2tof
mat  helpcatch helpm helpv helpfyz helpf help  quit
avg median sum 
readf writef printf latexf showf sortrevf sortf);

########################################
# 1) all to lowercase;
# 2) functions to uppercase
# 3)
#
#
########################################
 if ($debug>=1){print "input line after processin1:$xXx\n";}

 $xXx=~s/([A-Z])/lc($1)/ge;    # Everything uppecase to lowercase! NOW!
 
 if ($debug>=1){print "input line after processin1.5:$xXx\n";}
 
 my $Ff;
 foreach $Ff (@functions){ # CHANGE FUNCTIONS TO UPPERCASE
     my $f2=uc($Ff);
     $xXx=~s/($Ff)/"&".$f2/ge;
 }
 if ($debug>=1){print "input line after processin2:$xXx\n";}





#############   letters as arguments ______ tricky ______#######
       if ($xXx=~/RHO/){  # element as argument
            $nfields=0;
	    my ($qq)=( $xXx=~/RHO\((\w+)\)/ );
	    $qq=uc($qq);
            $xXx=~s/RHO\((\w+)\)/RHO($qq)/g; 
      }# if xxx=~/


#----------  exponential   aE+-b   ---  change to uppercase...
#         but should be already done ??? obsolete...
 $xXx=~s/(^[\d\.]+)e([\+\-][\d]+)/$1E$2/g;  
 $xXx=~s/([\W][\d\.]+)e([\+\-][\d]+)/$1E$2/g;  







#--------- field =>   '@' =============############################## vectors
#--------- field =>   '@' =============############################## vectors
#--------- field =>   '@' =============############################## vectors
#                                  INPUT NEW FIELD, add to the list

#__________________ diplay status _______________________
#     foreach (keys %fieldvar){#______ DISPLAY STATUS ______
#	$,=" "; # !!! maters with the line cmd!!!
#        print " "x 10,"field $_ contains (",@{$fieldvar{$_}},")\n";
#	$,=""; # !!! maters with the line cmd!!!
#     }
#          T O   D O    T O   M A K E   I T     R E A S O N A B L E 
# 1st -  treat correctly lowercase and uppercase.
#   initiate fields : basic creation; in-operation creation
# 2nd  swap for $FLDNAME[$index]
# 3rd  run with index 0..max
#################################################################



#''''''''' field count, check FUNCTIONS ''''''''''''''''''''''''''
 #======== out of field..........READF prepare new fields
       if ($xXx=~/READF/){  
            $nfields=0;
	    my ($defp)=$xXx=~/READF\(\s*(\w[\w\,\s\.\d]*)\)/;
	    my $defpu=uc($defp); $xXx=~s/$defp/$defpu/;
	    $defpu=~s/\s+//g;  # clean the spaces before hash key definition!
#	    print "defined befor readf : $defp\n";
	    my @nfld=split/[\,]+/,$defpu;
  	    foreach (@nfld){ 
 		uc($_);
		if ($nfld[0] eq $_){next;}
              	if (exists $fieldvar{$_}){delete $fieldvar{$_}; }
               $fieldvar{$_}=qw(0);#print "FL=$_, ";
            } # define field
#            $xXx=~s/READF\(\s*(\w[\w\,\s\.\d]*)\)/READF('$1')/; 
            $xXx=~s/READF\(\s*(\w[\w\,\s\.\d]*)\)/READF('$defpu')/; 
#	    print "substituted: $xXx\n";
      }# if xxx=~/ STAT

#========================== standalone # of fields ===============
  $nfields=0; #FIND HOW MANY FIELDS ARE IN THE EXPR:determines the context
  foreach $Ff (keys %fieldvar){ #FIND HOW MANY FIELDS ARE IN THE EXPR
     my $myxxx=$xXx; $myxxx=~s/[a-z]+\=//i;
     my $lff=lc($Ff);
     if (  $myxxx=~/[\W\D]$lff[\W\D]/ or
	   $myxxx=~/[\W\D]$lff$/ or
	   $myxxx=~/^$lff[\W\D]/ or 
	   $myxxx=~/^$lff$/ 
     ){ $nfields++;}
#     print "$nfields fields\n";
 }#foreach



#=================== PROTECT FIELD-DEDICATED FUNCTIONS ===============
 
#=================== Prepeare arguments for dedicated functions ======
  if ( $nfields>0){
       $Warning.=" $nfields-flds ";
       if ($xXx=~/AVG/){  # ONE-number Field Functions redefine HERE
            $nfields=0;
            $xXx=~s/AVG\(\s*(\w[\w\d]*)\)/AVG('$1')/g; 
      }# if xxx=~/AVG
       if ($xXx=~/MEDIAN/){  
            $nfields=0;
            $xXx=~s/MEDIAN\(\s*(\w[\w\d]*)\)/MEDIAN('$1')/g; 
      }# if xxx=~/MEDIAN
       if ($xXx=~/SUM/){  
            $nfields=0;
            $xXx=~s/SUM\(\s*(\w[\w\d]*)\)/SUM('$1')/g; 
      }# if xxx=~/ STAT
       if ($xXx=~/READF/){  
            $nfields=0;# DONT DO OTHER FIELD OPERATIONS
      }# if xxx=~/ STAT
       if ($xXx=~/WRITEF/){  
            $nfields=0;# DONT DO OTHER FIELD OPERATIONS
	    my ($defp)=$xXx=~/WRITEF\(\s*([\w\,\s\.\d]+)\)/;
	    my $defpu=uc($defp); $xXx=~s/$defp/$defpu/;
#	    print "defined befor printf : $defp\n";
#            $xXx=~s/WRITEF\(\s*([\w\,\s\.]+)\)/WRITEF('$1')/; 
            $xXx=~s/WRITEF\(\s*([\w\,\s\.]+)\)/WRITEF('$defpu')/; 
	    if ($defpu eq ""){$xXx="0";$Warning.=" Err ";}
      }# if xxx=~/ STAT
       if ($xXx=~/PRINTF/){  
            $nfields=0;# DONT DO OTHER FIELD OPERATIONS
	    my ($defp)=$xXx=~/PRINTF\(\s*(\w[\w\,\s\.\d]*)\)/;
	    my $defpu=uc($defp); $xXx=~s/$defp/$defpu/;
#	    print "defined befor printf : $defp\n";
            $xXx=~s/PRINTF\(\s*(\w[\w\,\s\.\d]*)\)/PRINTF('$defpu')/;
	    if ($defpu eq ""){$xXx="0";$Warning.=" Err ";}
      }# if xxx=~/ STAT
       if ($xXx=~/LATEXF/){  
            $nfields=0;# DONT DO OTHER FIELD OPERATIONS
	    my ($defp)=$xXx=~/LATEXF\(\s*([\w\,\s\.\d]+)\)/;
	    my $defpu=uc($defp); $xXx=~s/$defp/$defpu/;
#	    print "defined befor latexf : $defp\n";
            $xXx=~s/LATEXF\(\s*([\w\,\s\.]+)\)/LATEXF('$defpu')/; 
	    if ($defpu eq ""){$xXx="0";$Warning.=" Err ";}
      }# if xxx=~/ STAT
       if ($xXx=~/SORTF/){  
            $nfields=0;# DONT DO OTHER FIELD OPERATIONS
	    my ($defp)=$xXx=~/SORTF\(\s*(\w[\w\,\s\.]*)\)/;
	    my $defpu=uc($defp); $xXx=~s/$defp/$defpu/;
#	    print "defined befor sortf : $defp\n";
            $xXx=~s/SORTF\(\s*([\w\,\s\.]*)\)/SORTF('$defpu')/; 
	    if ($defpu eq ""){$xXx="0";$Warning.=" Err ";}
      }# if xxx=~/ STAT
       if ($xXx=~/SORTREVF/){  
            $nfields=0;# DONT DO OTHER FIELD OPERATIONS
	    my ($defp)=$xXx=~/SORTREVF\(\s*(\w[\w\,\s\.]*)\)/;
	    my $defpu=uc($defp); $xXx=~s/$defp/$defpu/;
#	    print "defined befor sortf : $defp\n";
            $xXx=~s/SORTREVF\(\s*(\w[\w\,\s\.]*)\)/SORTREVF('$defpu')/; 
	    if ($defpu eq ""){$xXx="0";$Warning.=" Err ";}
      }# if xxx=~/ STAT
  }# field present, check stat functions




 if ($debug>=1){print "input line after processin2.5=FLD:$xXx\n";}




#''''''''''''''''''''' basic field assignement  '''''like ff=(1,2,3,4)
#''''''''''''''''''''' basic field assignement  '''''like ff=(1,2,3,4)
#''''''''''''''''''''' basic field assignement  '''''like ff=(1,2,3,4)
 $OUTPUTFIELD="";  $OUTPUTDIM=0;  ## Globals

 if ($xXx=~/\s*[a-z][\w\d]*\s*\=\s*\([\d\,\.\-\sE]+\)$/){ #    f = ( 1,2 )
     $Warning.=" .smpl fld ass. ";
     my ($a,$b)=( $xXx=~/\s*([a-z][\w\d]*)\s*\=\s*\(([\d\,\.\-\sE]+)\)/);
     $b=~s/^\s+//;   $b=~s/\s+$//;  $b=~s/\s+//g; my @b=split/[\,]+/,$b;
     #     if (exists $fieldvar{uc($a)})  { delete $fieldvar{uc($a)};}
     if ($a ne ""){ # variable name
         $a=uc($a); 
	 if (exists $fieldvar{$a}){delete $fieldvar{$a}; }
         $fieldvar{$a}=\@b;
     }
	$,=" "; # !!! maters with the line cmd!!!
        print " "x 10,"field $a contains (",@{$fieldvar{$a}},") smpas\n";
	$,=""; # !!! maters with the line cmd!!!
     $xXx=$#{$fieldvar{$a}}+1; #MANDATORY - beware KEY!
     $nfields=0;
 }# END  if there is a simple field  assignement .... 
 #======---------------  field assign by operation -------------
 #======---------------  field assign by operation -------------
elsif( ($xXx=~/[a-z][\w\d]*\s*\=/ ) and ($nfields>0) ){#  F2F assignement!!!!
     $Warning.=" .fld assign.";
     my ($a)=( $xXx=~/\s*([a-z][\w\d]*)\s*=/) ;
     $OUTPUTFIELD=uc($a);
     $xXx=~s/\s*[a-z][\w\d]*\s*=//i;# remove assignment if there is an =assignment=
     print "       new field <", lc($OUTPUTFIELD),"> defined by opearation\n";
 #     $xXx=$#{$fieldvar{uc($a)}}+1; #MANDATORY beware KEY!
 }# field assign operation
# END ''''''''''''''''''''' basic field assignement  ''''''''''''''
#         now, field or assigned or the key waits, 
#              $fieldvar{ key } ; key is uppercase






#'''''''''''''' something like loop to replace the field name ''''''''
#                               FLD=>access to elements=  @{$fieldvar{$Ff}}
#                               one element :  ${fieldvar{$Ff}}[0].
 if ($nfields>0){
   my $backxxx=$xXx; 
   my $maxlen_=0;my $len_=0; $xXx=" ".$xXx;#add space
  foreach $Ff (keys %fieldvar){ #UPPERCASE,LENGTHMAX
     my $lff=lc($Ff); 
     $xXx=~s/(\b)$lff(\b)/\1$Ff\2/g; # change to upper
#     print "conversion to one element:$xXx\n";
     if ( $xXx=~/$Ff/){
       $len_=$#{$fieldvar{$Ff}}+1; if ($len_>$maxlen_){$maxlen_=$len_;}
     }
  }#all keys ucase, max length
  $OUTPUTDIM=$maxlen_;
 }#end of eval fieldop....................NFIELDS >0    => act
##############################  Fields now uppercased ##############



#        &process_field_via_map; # should be suppressed.......
#         &display_fields;   # DEBUG

#------------==================#################################### FIELDEND
#------------==================#################################### FIELDEND
#------------==================#################################### FIELDEND













#--------- variables   '$' ============= prepend $ to connect it to PERL
#--------- variables   '$' ============= prepend $ to connect it to PERL
#--------- variables   '$' ============= prepend $ to connect it to PERL
# $xXx=~s/([a-z][a-z\d]*[^_])/\$$1/g;

 if ($debug>=1){print "input line after processin2.7(var):$xXx\n";}
 
  $xXx=" ".$xXx." "; # dirty trick to avoid the startofthelines
$xXx=~s/([^\w\d])([a-z][a-z\d]*)/$1\$$2/g;
  $xXx=~s/^ //;
  $xXx=~s/ $//;

#if ($xXx=~/^[a-z][a-z\d]*[\W\D]/){$xXx=~s/^([a-z][a-z\d]*[\W\D])/\$$1/g;}

#if ($xXx=~/^[a-z][a-z\d]*$/){  $xXx=~s/^([a-z][a-z\d]*)$/\$$1/g;}

#if ($xXx=~/[\W\D][a-z][a-z\d]*[\W\D]/){$xXx=~s/[\W\D]([a-z][a-z\d]*)[\W\D]/\$$1/g;}
#if ($xXx=~/[\W\D][a-z][a-z\d]*$/){$xXx=~s/([\W\D][a-z][a-z\d]*)$/\$$1/g;}


 if ($debug>=1){print "input line after processin3(var):$xXx\n";}





#-- zkusim hodiny:minuty:vteriny ------ 060808 conversion back   ok
 if ($xXx eq ":"){
     my $h=int($Res/60); my $m=$Res % 60; 
     $xXx=sprintf("%02d:%02d",$h,$m); printf("%s%5s\n"," "x($offs-1),$xXx);
 }
 if ($xXx eq "::"){
     my $h=int($Res/3600); my $m=$Res % 3600; 
     my $m2=$m/60; my $s=$m % 60;
     $xXx=sprintf("%02d:%02d:%02d",$h,$m2,$s); printf("%s%8s\n"," "x($offs-1),$xXx);
 }
#-- zkusim hodiny:minuty:vteriny ------ 050505    ok
 $xXx=~s/(\d+)(\:)(\d+)(\:)(\d+)/($1*3600+$3*60+$5)/ge;
 $xXx=~s/(\d+)(\:)(\d+)/($1*60+$3)/ge;


 if ($debug>=1){print "input line after processin4:$xXx\n";}

 &process_field; # FIELD PROCESS !!!!!!!!


 if ($debug>=1){print "input line after processin5+res:$xXx; $Res\n";}




 if ($DO>0){  print " "x$offs,">$xXx<\n";}

#============== DEFAULT OPERATION==== and COMMANDS =====
 if ($xXx eq "+"){$Defoperat="+";$xXx="DOD";&dod;}
 if ($xXx eq "-"){$Defoperat="-";$xXx="DOD";&dod;}
 if ($xXx eq "*"){$Defoperat="*";$xXx="DOD";&dod;}

 if ($xXx=~/[\+\-\*\/]{3}/){$Defoperat=$xXx;$xXx="DOD";&dod;}

 if ($xXx=~/^\-/){$Warning.="\t\t...!substaction..";}


#================== COMMANDS==========================
 if ($xXx eq "&DEG"){$xXx="DOD";
          print "goniometric in degrees\n"; $R2dc=3.1415926/180;}
 if ($xXx eq "&RAD"){$xXx="DOD";
          print "goniometric in radians\n"; $R2dc=1;}

 if ($xXx eq "&HELP"){$xXx="DOD";
          print "$Help";}
 if ($xXx eq "&HELPCATCH"){$xXx="DOD";
          print "$Helpcatch";}
 if ($xXx eq "&HELPF"){$xXx="DOD";
          print "$Helpf\navailable funcions:  @functions\n";}
 if ($xXx eq "&HELPFYZ"){$xXx="DOD";
          print "$Helpfyz\navailable funcions:  @functions\n";}
 if ($xXx eq "&HELPM"){$xXx="DOD";
          print "$Help_mat\n\n";}
 if ($xXx eq "&HELPV"){$xXx="DOD";
          print "$Helpv\n\n";}
 if ($xXx eq "&MAT"){$xXx="DOD";
          print "type  quit to quit\n";
          system("mathomatic");
#          system("echo Slepice spi.> ");
 }
 if ($xXx eq "&QUIT"){$xXx="DOD";
          print "Good bye...\n"; exit 0;}
 if ($xXx eq "&SHOWF"){$xXx="DOD";
          print "_________displaying fields________\n"; &display_fields;}
#         &display_fields;   # DEBUG





 if ($debug>=1){print "input line after processin6(if # only)+res:$xXx, $Res\n";}

#============== CO KDYZ JENOM CISLO



 if ($xXx ne "DOD"){  ###############  skip if DOD ######
#============== change LINE mark -,=   and reset
 if (($Line=~/\-\-/)and($xXx eq "")){
   $Linemark="="; $Res="0";
 }elsif(($Line=~/\=\=/)and($xXx eq "")){ # .........save .calc.pl
     &exit_with_history;
 }else{
   $Linemark="-"
 }# if ------ line ------ ===========


 if ($debug>=1){print "input line after processin7(if # only)+res:$xXx, $Res\n";}



 #------ if begins with =, placed at the end // assign to variable via =
 if ($xXx=~/^\=/){
    $xXx=substr($xXx,1,length($xXx)-1)."=";
 }


#===================== pokud koncime znakem .. znamena to operaci na minulem
#===================== ending with +-/* etc ==> operation on the last result
 if ($xXx=~/[\+\-\*\/\=]$/){
   if ((substr($xXx,length($xXx)-1,1) eq "-")and(substr($Res,0,1) eq "-")){
       $xXx=substr($xXx,0,length($xXx)-1)."+";
       $Res=substr($Res,1,length($Res)-1);
   }
   $xXx=$xXx."$Res";
}#====END======= ending by oper.
 elsif ($xXx=~/^[\+\-\*\/\=]/){#===== beginning by operator
   $xXx="($Res)".$xXx;  # eg. (-45)**2
 }




# if ($debug>=1){print "input line after processin7.5(if # only)+res:$xXx, $Res\n";}



#=========  NO ARGUMENT - TRANSLATE TO THE LAST RESULT= ARGUMENT
#=========  pokud je jenom tohle, ber argument z vysledku
 if ($xXx eq "&SQRT"){   $xXx="&SQRT($Res)"; }
 if ($xXx eq "&EXP"){    $xXx="&EXP($Res)"; }
 if ($xXx eq "&LN"){     $xXx="&LN($Res)"; }
 if ($xXx eq "&LOG"){    $xXx="&LOG($Res)"; }
 if ($xXx eq "&SIN"){    $xXx="&SIN($Res)"; }
 if ($xXx eq "&COS"){    $xXx="&COS($Res)"; }
 if ($xXx eq "&TAN"){    $xXx="&TAN($Res)";}
 if ($xXx eq "&ATAN"){   $xXx="&ATAN($Res)"; }
 if ($xXx eq "&ASIN"){   $xXx="&ASIN($Res)"; }
 if ($xXx eq "&ACOS"){   $xXx="&ACOS($Res)"; }

 if ($xXx eq "&P0"){  $xXx="&P0($Res)"; }
 if ($xXx eq "&P2"){  $xXx="&P2($Res)"; }
 if ($xXx eq "&P4"){  $xXx="&P4($Res)"; }

 if ($xXx eq "&POW"){  $xXx="&POW($Res)"; }

#-------  financial
 if ($xXx eq "&GETINTER"){  $xXx="&GETINTER($Res)"; }
 if ($xXx eq "&SOLVEINTERM"){  $xXx="&SOLVEINTERM($Res)"; }
 if ($xXx eq "&SOLVEINTERI"){  $xXx="&SOLVEINTERI($Res)"; }


#------- conversions
 if ($xXx eq "&BB2T12"){  $xXx="&BB2T12($Res)"; }
 if ($xXx eq "&BW2T12"){  $xXx="&BW2T12($Res)"; }
 if ($xXx eq "&T122BB"){  $xXx="&T122BB($Res)"; }
 if ($xXx eq "&B2B"){  $xXx="&B2B($Res)"; }

 if ($xXx eq "&TOF2E"){  $xXx="&TOF2E($Res)"; }
 if ($xXx eq "&E2TOF"){  $xXx="&E2TOF($Res)"; }


#-- nonsense
 if ($xXx eq "&AVG"){  $xXx="&AVG($Res)"; }
 if ($xXx eq "&MEDIAN"){  $xXx="&MEDIAN($Res)"; }
 if ($xXx eq "&SUM"){  $xXx="&SUM($Res)"; }

#print $xXx,"\n";
# if ($xXx eq "sqrt"){   $xXx="sqrt($Res)"; }



 #====================  clear default operation
 if (($Defoperat ne "")and($xXx eq "")){
   print "default operation cleared\n";
   $Defoperat="";
 }
 
#==================   make default operation!!!
 #==================   make default operation!!!
 # print "x=$xXx   res=$Res  dop=$Defoperat \n";
 if (($Defoperat ne "")and($xXx ne "")){
     if (length($Defoperat)>1){ 
         # if trityp (+++2 or ///1.5  or ***8) DO (currline) opnum' 
	 my $Defoperatqqq=substr($Defoperat,2,length($Defoperat)-2);
	 $xXx="($xXx)$Defoperatqqq";
     }else{
    $xXx="$Res$Defoperat($xXx)";  #this makes:  res op (currline) e.g. 2+1
     } # DOD as length==1 (is it 1?)
 }
# print "x=$xXx   res=$Res  dop=$Defoperat \n";
#==== dobre - operace na minulem ok



if ($debug>=1){print "input line after processin7.5+res:$xXx, $Res\n";}




$Line="";
#========================= eval if not CRLF
 if (length($xXx)<=0) {
   while (length($Line)<=$offs){      $Line.=$Linemark;   }
 }else{ ################   EVAL !!!!!!!###############
        ################   EVAL !!!!!!!###############
        ################   EVAL !!!!!!!###############
     my $att=0;
    if ($xXx=~/[\D]0+[1-9]+\./ or $xXx=~/^0+[1-9]+\./ ) 
#          { $att=1; $Warning.="WARNING:bug due to perl EVAL may appear!!\n";}
            { $att=1; $Warning.="WARNING:bug 001.234 !!";}
    $Res=eval($xXx) if ($xXx ne ""); 
     if ($att==1 and $Res!~/\./){ $Warning.=" YES!!!";}
    
#   @res=eval($xXx) if ($xXx ne ""); # Why?
        ################   EVAL !!!!!!!###############
        ################   EVAL !!!!!!!###############
 }

 if ($debug>=1){print "input line after processin8(displ)+res:$xXx; $Res\n";}

  &display($Res);#<<<<<========================  DISPLAY THE RESULT

 if ($debug>=1){print "input line after processin9(displ)+res:$xXx, $Res\n";}


 }###### skip if DOD ########

}##########################################WHILE





sub EXP{my $a=shift;$a=eval($a);return exp($a);}
sub SQRT{my $a=shift;$a=eval($a);return sqrt($a);}
###sub SQRT{my $a=shift;$a=eval($a);return ;}

sub LOG{my $a=shift;$a=eval($a);return log($a)/log(10);}
sub LN{my $a=shift;$a=eval($a);return log($a);}


sub SIN{my $a=shift;$a=$R2dc*eval($a);return sin($a);}
#sub COS{my $a=shift;$a=$R2dc*eval($a);return sqrt(1-sin($a)*sin($a));}
sub COS{my $a=shift;$a=$R2dc*eval($a);return cos($a);}
sub TAN{my $a=shift;$a=$R2dc*eval($a);  my $sig;
	if (cos($a)<0){$sig=-1;}else{$sig=1;}
    return $sig*sin($a)/sqrt(1-sin($a)*sin($a));
}

sub ATAN{my $a=shift;$a=eval($a);return atan2($a,1)/$R2dc;}
sub ASIN{my $a=shift;$a=eval($a);return atan2($a, sqrt(1 - $a * $a))/$R2dc;}
sub ACOS{my $a=shift;$a=eval($a);return  atan2( sqrt(1-$a*$a), $a)/$R2dc;}
#--- legendovy polynomy
sub P0{my $a=shift;return  1;}
sub P2{my $a=shift;$a=eval($a);return  0.5*(3*$a*$a-1);}
sub P4{my $a=shift;$a=eval($a);return  1/8*(35*$a*$a*$a*$a-30*$a*$a+3);}

sub POW{
  my ($a,$b)=@_; 
  $a=eval($a);
  $b=eval($b);
  return $a**$b;
}

# ----- conversions
#?#####--- nerekurzivni funkce ######## NONRECURSIVE FUNCTIONS ##########
sub T122BB{
  my ($E,$t12,$sL)=@_;
  my $C,$L;  ($L)=($sL=~/(\d)$/); 
 SWITCH:{
   if($sL eq "E1"){$C=4.4E-9;  last SWITCH;}
   if($sL eq "E2"){$C=5.63E+1; last SWITCH;}
   if($sL eq "E3"){$C=1.21E+12;last SWITCH;}
   if($sL eq "M1"){$C=3.96E-5; last SWITCH;}
   if($sL eq "M2"){$C=5.12E+5; last SWITCH;}
   if($sL eq "M3"){$C=1.09E+16;last SWITCH;}
 }
 $E=eval($E);   $t12=eval($t12);
  print "input: energy in kev,  halflife in sec,  multipolarity\n";
  print "C=$C   E=$E keV   L=$L    T12=$t12 s  ->  e2b^$L\n";
  return $C/(  $E**(2*$L+1) * $t12  );
}


sub T122BW{
  my ($E,$t12,$sL,$A)=@_;
  my $C,$L;  ($L)=($sL=~/(\d)$/); 
 SWITCH:{
   if($sL eq "E1"){$C=4.4E-9;  last SWITCH;}
   if($sL eq "E2"){$C=5.63E+1; last SWITCH;}
   if($sL eq "E3"){$C=1.21E+12;last SWITCH;}
   if($sL eq "M1"){$C=3.96E-5; last SWITCH;}
   if($sL eq "M2"){$C=5.12E+5; last SWITCH;}
   if($sL eq "M3"){$C=1.09E+16;last SWITCH;}
 }
 $E=eval($E);   $t12=eval($t12);
  print "input: energy in kev; halflife in sec;  multipol.; A-nucl\n";
  print "C=$C   E=$E keV   L=$L    T12=$t12 s  ->  e2b^$L\n";
  my $B=$C/(  $E**(2*$L+1) * $t12  );
  $B=B2B($B,$sL,BW,$A); # intermediate conversion  
  return $B;
}


sub BB2T12{
  my ($E,$B,$sL)=@_;
  my $C,$L;  ($L)=($sL=~/(\d)$/); 
 SWITCH:{
   if($sL eq "E1"){$C=4.4E-9;  last SWITCH;}
   if($sL eq "E2"){$C=5.63E+1; last SWITCH;}
   if($sL eq "E3"){$C=1.21E+12;last SWITCH;}
   if($sL eq "M1"){$C=3.96E-5; last SWITCH;}
   if($sL eq "M2"){$C=5.12E+5; last SWITCH;}
   if($sL eq "M3"){$C=1.09E+16;last SWITCH;}
 }
 $E=eval($E);   $B=eval($B);
  print "input: energy in kev; value of B in e.b^N;  multipolarity  \n";
  print "C=$C   E=$E keV   L=$L    B=$B eb^$L  -> sec\n";
  return $C/(  $E**(2*$L+1) * $B  );
}

sub BW2T12{
  my ($E,$B,$sL,$A)=@_;
  $B=B2B($B,$sL,WB,$A); # intermediate conversion
  my $C,$L;  ($L)=($sL=~/(\d)$/); 
  my $oval;
 SWITCH:{
   if($sL eq "E1"){$C=4.4E-9;  last SWITCH;}
   if($sL eq "E2"){$C=5.63E+1; last SWITCH;}
   if($sL eq "E3"){$C=1.21E+12;last SWITCH;}
   if($sL eq "M1"){$C=3.96E-5; last SWITCH;}
   if($sL eq "M2"){$C=5.12E+5; last SWITCH;}
   if($sL eq "M3"){$C=1.09E+16;last SWITCH;}
 }
 $E=eval($E);   $B=eval($B);
  print "input B2T: energy in kev; value of B in w.u.; multipol.; A-nucl  \n";
  $oval= $C/(  $E**(2*$L+1) * $B  );
  print "C=$C   E=$E keV   L=$L    B=$B eb^$L  -> $oval sec\n";
  return $oval;
}


sub B2B{
  my ($B,$sL,$ctyp)=@_; 
  my $AA=@_[3] || eval($a) || 0;
  my $L,$sig;  ($L)=($sL=~/(\d)$/); ($sig)=($sL=~/^(\D)/); 
  my $out, $wu1,$ct2; ($ct2)=($ctyp=~/(.)$/); 
  $B=eval($B);
  $AA=eval($AA);
  print " input B2B: B-value;  multipol.(e.g.E2); conver.(e.g.BW,FW..); A-nucl\n";
  print " B=$B sigL=$sL   sig=$sig  L=$L  A=$AA convtyp=$ctyp ";
#---------------  final UNIT
  if ($sig eq "E"  and  $ct2 eq "B"){$out="e^2 b^$L";}
  if ($sig eq "E"  and  $ct2 eq "F"){$out="e^2 fm^".(2*$L);}
  if ($sig eq "E"  and  $ct2 eq "W"){$out="wu";}
  if ($sig eq "M"  and  $ct2 eq "B"){$out="muN^2 b^".($L-1);}
  if ($sig eq "M"  and  $ct2 eq "F"){$out="e^2 fm^".(2*$L-2);}
  if ($sig eq "M"  and  $ct2 eq "W"){$out="wu";}
#---------------  1wu in e2bL, muN2bL-1
 SWITCH:{
   if($sL eq "E1"){$wu1=6.45E-4*$AA**(2/3); last SWITCH;}
   if($sL eq "E2"){$wu1=5.94E-6*$AA**(4/3); last SWITCH;}
   if($sL eq "E3"){$wu1=6.0E-8*$AA**(2);    last SWITCH;}
   if($sL eq "M1"){$wu1=1.79;              last SWITCH;}
   if($sL eq "M2"){$wu1=1.66E-2*$AA**(2/3); last SWITCH;}
   if($sL eq "M3"){$wu1=1.66E-4*$AA**(4/3); last SWITCH;}
 }

 SWITCH1:{
   if($sig eq "E" and $ctyp eq "BF"){$B=$B*10**(2*$L);last SWITCH1;}
   if($sig eq "E" and $ctyp eq "FB"){$B=$B/10**(2*$L);last SWITCH1;}
   if($sig eq "E" and $ctyp eq "FW"){$B=$B/10**(2*$L)/$wu1;last SWITCH1;}
   if($sig eq "E" and $ctyp eq "WF"){$B=$B*10**(2*$L)*$wu1;last SWITCH1;}

   if($ctyp eq "BW"){$B=$B/$wu1;last SWITCH1;}
   if($ctyp eq "WB"){$B=$B*$wu1;last SWITCH1;}

   if($sig eq "M" and $ctyp eq "BF"){$B=$B*10**(2*$L-2);last SWITCH1;}
   if($sig eq "M" and $ctyp eq "FB"){$B=$B/10**(2*$L-2);last SWITCH1;}
   if($sig eq "M" and $ctyp eq "FW"){$B=$B/10**(2*$L-2)/$wu1;last SWITCH1;}
   if($sig eq "M" and $ctyp eq "WF"){$B=$B*10**(2*$L-2)*$wu1;last SWITCH1;}
 }
  print "  ->$B  $out\n";
  return $B;
}



sub TOF2E{
    my ($t, $l ,$A)=@_;
    $t=eval($t);
    $l=eval($l);
    $A=eval($A);
    print "  t=$t ns, dist=$l m, mother A=$A;    result in MeV\n";
    my $vc=$l/ $t/1e-9/1e+8/3;  # (v/c) time in ns; c=3e+8
    my $m=939.565330;
    my $gamma=1/sqrt((1-($vc)**2));
    my $pc=$gamma*$m*$vc;
    my $E=sqrt($pc**2 + $m**2) - $m;
#    print "Neutron energy            = $E\n";
    $E=$E*($A/($A-1));  #  recoil correction... Eexc=En*Amother/(Amother-1)
 return $E;
}
sub E2TOF{
    my ($E, $l ,$A)=@_;
    $E=eval($E);
    $l=eval($l);
    $A=eval($A);
    print "  E=$E MeV, dist=$l m, mother A=$A;   result in ns\n";
    $E=$E/($A/($A-1)); # En = less then Eexc because of recoil
    my $m=939.565330;
    my $pc=sqrt( ($E+$m)**2  -  $m**2);
    my $vc=sqrt(   ($pc/$m)**2 / (($pc/$m)**2 + 1)    );
    my $t=$l/$vc/3e+8 * 1e+9;
    return $t;
}




 sub GETINTER{
    my ($ur,$months,$start,$momonthly,$moyearly, $quiet)=@_;
    if ($quiet!=111){
    print "interest=",$ur*100,"% yearly   #-months=$months  bias=$start\$  each-month=$momonthly\$  each-year=$moyearly\$\n"; }

    my $n;
    $ur+=1;
    $ur=$ur**(1/12); # monthly interst
    my $tot=$start;
    my $totinv=$tot;

    foreach ($n=1;$n<=$months;$n++){
      $tot=$tot*$ur+$momonthly;
      $totinv+=$momonthly;
      if ($n%12 == 0){$tot+=$moyearly;$totinv+=$moyearly;}
  #     print "$n        $tot\n";
    }
  #  print "$tot        $totinv    \n";
    return $tot;
 }



 sub SOLVEINTERM{
    my ($aim,$ur,$start,$momonthly,$moyearly)=@_;
    print "aim=$aim\$  interest=",$ur*100,"% yearly    bias=$start\$  each-month=$momonthly\$  each-year=$moyearly\$\n";
    my $montlo=0;my $monthi=50*12;  my $mont; my $to;
   my $tolo=&GETINTER($ur,$montlo,$start,$momonthly,$moyearly ,111);
   my $tohi=&GETINTER($ur,$monthi,$start,$momonthly,$moyearly ,111);
   if ($aim<$tolo or $aim>$tohi){
       print " time to save $aim\$ is out of 0-50*12 months ($tolo, $tohi,)\n"; return;
   }
   foreach (1..10){
    $mont=int(($monthi+$montlo)/2);
    $to=&GETINTER($ur,$mont,$start,$momonthly,$moyearly, 111);
    if ($to>$aim){$tohi=$to;$monthi=$mont;}else
    {$tolo=$to;$montlo=$mont;}
   }
   my $dmont=($montlo - $monthi )/2;
   my $mont=$montlo+$dmont;
   print " $mont  +- $dmont months to save for $aim \$\n";
   return $mont;
 }


 #_____________________________solve for interest
 sub SOLVEINTERI{
    my ($aim,$months,$start,$momonthly,$moyearly)=@_;
    print "aim=$aim\$  #-months=$months   bias=$start\$  each-month=$momonthly\$  each-year=$moyearly\$\n";
   my $urlo=0;my $urhi=2;  my $mont; my $to;
   my $tolo=&GETINTER($urlo, $months,$start,$momonthly,$moyearly ,111);
   my $tohi=&GETINTER($urhi, $months,$start,$momonthly,$moyearly ,111);
   if ($aim<$tolo or $aim>$tohi){
       print "out of 0-100% interest\n"; return;
   }
   foreach (1..20){
    $ur=($urhi+$urlo)/2;
    $to=&GETINTER($ur,$months,$start,$momonthly,$moyearly , 111);
    if ($to>$aim){$tohi=$to;$urhi=$ur;}else
    {$tolo=$to;$urlo=$ur;}
    #print "$to\n";
   }
   my $dint=($urlo - $urhi )/2;
   my $int=$urlo+$dint;
    $int*=100;
    $dint*=100;
   printf(" estim. interest to achieve %f\$ is %.3f +- %.3f \%\n",$aim, $int, $dint);
   return $int/100;
 }



sub RHO{
    my($el)=@_;    my $i;my $ii;
#    print "$el\n";
 my @element=qw(n H He Li Be B C N O F Ne   
              Na Mg Al Si P S Cl Ar
              K Ca Sc Ti V Cr Mn Fe Co Ni Cu Zn 
	      Ga Ge As Se Br Kr
              Rb Sr Y Zr Nb Mo Tc Ru Rh Pd Ag Cd In Sn Sb Te I Xe
              Cs Ba
              La Ce Pr Nd Pm Sm Eu Gd Tb Dy Ho Er Tm Yb
              Lu Hf Ta W Re Os Ir Pt Au Hg Tl Pb Bi Po At Rn
              Fr Ra Ac Th Pa U Np Pu Am Cm Bk Cf Es Fm Md No
              Lr Rf Db Sg Bh Hs Mt Ds 111 112 113 114 115 116 117 118);
# density
my @den=qw( 
0 0.00008988 0.0001785 0.534  1.85 2.34  2.267  0.0012506   0.001429  0.001696  0.0008999
0.971  1.738 2.698 2.3296 1.82  2.067   0.003214 0.0017837 
0.862  1.54  2.989      4.540   6.0     7.15    7.21    7.86   8.9   8.908     8.96    7.14
5.91
  	    );
# molar weight
my @MM=qw(1 1.0079 4.0026  6.941 9.01218 10.811 12.0107 14.0067 15.9994 18.998 20.1797
22.98977 24.305 26.9815 28.0855 30.97376 32.065 35.453 39.948
39.0983 40.078  44.9559  47.867  50.9415 51.996 54.938 55.845  58.933 58.693 63.546   65.409
69.723
           );
    my $den;
    $el=~s/^(\w)/uc($1)/e;
    if (length($el)>1){$el=~s/^(\w)(\w+)/"$1".lc($2)/e;}
    for (my $i=0;$i<=$#element; $i++){
        if ( $el eq $element[$i] ){ $den=$den[$i];$ii=$i; $mm=$MM[$i];}
    }
    print "                   density of $el = $den g/cm3, Z=$ii, MM=$mm g/mol\n";
    return $den;
}

sub T2GCM{
    my ($a,$den)=@_; $a=eval($a);$den=eval($den);
    if ($den eq ""){    print " thicknes in cm -> g/cm2 : input cm,density RHO   cm*RHO=g/cm2\n";}
    printf("                  thickness=%f mm, dens=%f g/cm3, => %f g/cm2\n",$a*10,$den,$a/$den);
    return $a*$den;
}
sub GCM2T{
    my ($a,$den)=@_; $a=eval($a);$den=eval($den);
    if ($den eq ""){    print "  thickness in g/cm2 -> cm : input g/cm2,density RHO   cm*RHO=g/cm2\n";}
    printf("                  thickness=%f g/cm2, dens=%f g/cm3, => %f mm\n",$a,$den,$a/$den*10);
    return $a/$den;
}

sub RERATE{
 # N/sec,  Crosssect, Mn target, depths in g/cm2
  my ($flux, $sigma, $Mn, $dep)=@_;
#  print "   input: flux p/s,sigma barn,Molarweigth g/mol, depth g/cm2\n";
  if ($dep eq ""){print "reaction rate:INPUT flux(part/s),sigma(barn),MM,thickness(g/cm2)\n";}

  $flux=eval($flux);# evaluate the inside
  $sigma=eval($sigma);# evaluate the inside
  $Mn=eval($Mn);# evaluate the inside
  $dep=eval($dep);# evaluate the inside
#                 sigma in cm2    g/cm2   Na(mol)     g/mol
  my $R=  $flux*  $sigma*1E-24*   $dep*   6.02*1E+23/ $Mn;
  printf("          RR:flux=%.2e p/s, sigma=%.2e barn, \n",$flux,$sigma,$dep,$R);
  printf("                T=%.2e g/cm2, RATE=%.3e/s\n",$dep,$R);
  return $R;
}

sub FLUXAP{
  my ($flux,$chrg)=@_;
  if ($chrg eq ""){print "beam intensity:current->particles. Input current(A),charge,\n";}
  $flux=eval($flux);# evaluate the inside
  $chrg=eval($chrg);# evaluate the inside
  my $R=  $flux/$chrg/1.602E-19;
  printf("        flux=%.2e euA, Q+=%d =%.2e =>part/s\n",$flux*1000000,$chrg,$R);
  return $R;
}
sub FLUXPA{
  my ($flux,$chrg)=@_;
  if ($chrg eq ""){print "beam intensity:current<-particles. Input p/s,charge\n";}
  $flux=eval($flux);# evaluate the inside
  $chrg=eval($chrg);# evaluate the inside
  my $R=  $flux*$chrg*1.602E-19;
  printf("        flux=%.2e part/s, Q+=%d => %.2e euA\n",$flux,$chrg,$R*1000000);
  return $R;
}

##############################################"" STATISTICAL
##############################################"" STATISTICAL
##############################################"" STATISTICAL

sub AVG{
    my $OUD=shift;
    $OUD=~s/\$//;   $OUD= uc($OUD);  my $i,$sum=0,$n=0,$av;
    if ($OUD=~/[\,\.]/){print "   one field ONLY\n";return 0;}
#   foreach (keys %fieldvar){print "key $_ , hash= $fieldvar{$OUD}\n";}
#    print   " AVG: outputfield=$OUD; hash= @{$fieldvar{$OUD}} \n";

    foreach $i ( @{$fieldvar{$OUD}} ){
	$sum+=$i; $n++;
    }# each
    $av= $sum/$n;  $sum=0;
    foreach $i ( @{$fieldvar{$OUD}} ){
	$sum+=($i-$av)**2; 
    }# each
	printf("%s AVG=%f +- %f\n"," "x $offs, $av, sqrt($sum/($n-1)) );
    return $av;
}

sub MEDIAN{
    my $OUD=shift;
    $OUD=~s/\$//;   $OUD= uc($OUD);  my $i,$sum=0,$n=0,$av;
    if ($OUD=~/[\,\.]/){print "   one field ONLY\n";return 0;}
#   foreach (keys %fieldvar){print "key $_ , hash= $fieldvar{$OUD}\n";}
#    print   " AVG: outputfield=$OUD; hash= @{$fieldvar{$OUD}} \n";
    my @a= @{$fieldvar{$OUD}}; 
    @a=sort{$a <=> $b} @a;
#    print "  SORTED = @a\n";
    if ($#a % 2==0){ 
	$av=$a[$#a/2];
    }else{	
        $av= ($a[$#a/2-0.5]+$a[$#a/2+0.5])/2;
    }
#	printf("%s MEDIAN=%f \n"," "x $offs, $av );
    return $av; 
}




sub SUM{
    my $OUD=shift;
    $OUD=~s/\$//;   $OUD= uc($OUD);  my $i,$sum=0,$n=0,$av;
    if ($OUD=~/[\,\.]/){print "   one field ONLY\n";return 0;}
    my @a= @{$fieldvar{$OUD}}; 

      foreach $i ( @{$fieldvar{$OUD}} ){
	$sum+=$i; $n++;
    }# each
    return $sum; 
}




sub READF{
    my $OUD=shift;
#    if ($OUD=~/^\s/){$OUD=shift;}
    $OUD=~s/\$//;   $OUD= uc($OUD);  $OUD=~s/\s+//g;
#    $OUD=~s/^\s+//; $OUD=~s/\s+$//;
    
#   foreach (keys %fieldvar){print "key $_ , hash= $fieldvar{$OUD}\n";}
#    print   " READF : outputfield=$OUD; hash= @{$fieldvar{$OUD}} \n";
    my @ff=split/[\s\,]+/,$OUD;
    $ff[0]=lc($ff[0]); # FILE lowercase :(
    for (my $ii=1;$ii<=$#ff; $ii++){ @fieldvar{$ff[$ii]}=qw(); }
    print "opening file=$ff[0],  # fields to read=$#ff (@ff[1..$#ff]) \n ";

    open IINN,"$ff[0]" ||  print "file $ff[0] doesnot exist !!!!\n";
    if ($#ff>=1){#print "reading columns\n";
    while (<IINN>){   #	print "$_ ... ";
  	 next if ($_=~/^[\#\;cC\*\/]/); # COMMENT CHARACTERS
	 $_=~s/^[\s]+//;  #remove spaces at begining
#	 $_=~s/^[\W\-]+//; # removes minus!!!
#	 split/[\s,]/
	 my @nums=split/[^\.\-\deE\+]+/,$_;
 	 print "@nums\n";
	 for (my $ii=1;$ii<=$#ff; $ii++){
#             print "inc $ff[$ii] by $nums[$ii-1] ";
	     push @{$fieldvar{$ff[$ii]}},$nums[$ii-1];
#	     print "$ff[$ii]:$nums[$ii-1]  ";
         }
#	 print "\n";
    }
    }#reading columns
####    else{print "reading row (NOT DONE)\n"; }
    close IINN;
    print "file closed\n";
#    print " $ff[1], @{$fieldvar{$ff[1]}} \n";
#    print " $ff[2], @{$fieldvar{$ff[2]}} \n";
 #    for (my $ii=1;$ii<=$#ff; $ii++){
#	     print "$ff[$ii]: @{$fieldvar{$ff[$ii]}}\n";
  #       }
    return $#ff; 
}









sub WRITEF{
    my $OUD=shift;
    $OUD=~s/\$//;   $OUD=~s/^\s+//;  $OUD=~s/\s+$//; $OUD=~s/\s+//;
    $OUD= uc($OUD); 
#   foreach (keys %fieldvar){print "key $_ , hash= $fieldvar{$OUD}\n";}
#    print   " WRITEF : outputfield=$OUD;  \n";
    my @ff=split/[\s\,]+/,$OUD;
    $ff[0]=lc($ff[0]); # FILE lowercase :(
    my $name=lc($ff[0]).".calcpl";
#    for (my $ii=1;$ii<=$#ff; $ii++){ @fieldvar{$ff[$ii]}=qw(); }
    print "opening file=<$name>,  # fields to WRITE=$#ff (@ff[1..$#ff])\n";

    my @ff=split/[\s\,]+/,$OUD;
    open OOUT,">$name";
    for (my $j=0;$j<=$#{$fieldvar{$ff[1]}}; $j++){ 
     for (my $ii=0;$ii<=$#ff-1; $ii++){ 
	 my $prfstrF="%10".".".$precis."f\t";
         printf OOUT $prfstrF,$fieldvar{$ff[$ii+1]}[$j]; 
#         print  $prfstrF,$fieldvar{$ff[$ii+1]}[$j]; 
     }
     print OOUT "\n";
    }
    close OOUT;

    print "file closed\n";
 #    for (my $ii=1;$ii<=$#ff; $ii++){
#	     print "$ff[$ii]: @{$fieldvar{$ff[$ii]}}\n";
  #       }
    return $#ff; 
}





sub PRINTF{
    my $OUD=shift; $OUD=~s/^\s//; $OUD=~s/\s$//;
    $OUD=~s/\$//;   $OUD= uc($OUD); 
#   foreach (keys %fieldvar){print "key $_ , hash= $fieldvar{$OUD}\n";}
    print   " PRINTF : outputfield=$OUD;  \n";
    my @ff=split/[\s\,]+/,$OUD;
    for (my $j=0;$j<=$#{$fieldvar{$ff[0]}}; $j++){ 
     for (my $ii=0;$ii<=$#ff; $ii++){ 
	 my $prfstrF="%10".".".$precis."f\t";
         printf($prfstrF,$fieldvar{$ff[$ii]}[$j]); 
     }
     print "\n";
    }
    return $#ff; 
}



sub LATEXF{
    my $OUD=shift;
    $OUD=~s/\$//; $OUD=~s/\s+//;  $OUD= uc($OUD); 
#   foreach (keys %fieldvar){print "key $_ , hash= $fieldvar{$OUD}\n";}
#    print   " LATEXF : outputfield=$OUD; hash= @{$fieldvar{$OUD}} \n";
    print   " LATEXF : set precis=2  if you want \n";
    my @ff=split/[\s\,]+/,$OUD;    my $tab;

    printf("\\begin{table}[!ht]
\\centering{\\begin{tabular}{*{%d}{|c}|}
 \\hline\n", $#ff+1 );
    for (my $j=0;$j<=$#{$fieldvar{$ff[0]}}; $j++){ 
     for (my $ii=0;$ii<=$#ff; $ii++){ 
         my $prfstrF;
	 if ($precis>0){ $prfstrF="%10".".".$precis."f  ";}
                    else{$prfstrF="%f  ";}
	 if ( $ii==$#ff){$tab="  \\\\  \\hline"}else{$tab=" & ";}
         printf($prfstrF.$tab,$fieldvar{$ff[$ii]}[$j]); 
     }
     print "\n";
    }
     print "\\end{tabular}
\\caption{Table exported by calc.pl\\label{label} }
}
\\end{table}\n";
    return $#ff; 
}





sub SORTF{
    my $OUD=shift;  my $k;
    $OUD=~s/\$//;   $OUD= uc($OUD); 
#   foreach (keys %fieldvar){print "key $_ , hash= $fieldvar{$OUD}\n";}
#    print   " SORTF : outputfield=$OUD; hash= @{$fieldvar{$OUD}} \n";
    print   " SORTF : outputfield=$OUD;  \n";
    my @ff=split/[\s\,]+/,$OUD;
   

    for (my $j=0;$j<=$#{$fieldvar{$ff[0]}}; $j++){ # this goes to maxn
    for (my $k=$j;$k<=$#{$fieldvar{$ff[0]}}; $k++){ # this goes to maxn
	if  ($fieldvar{$ff[0]}[$j] > $fieldvar{$ff[0]}[$k]){

     for (my $ii=0;$ii<=$#ff; $ii++){ 
	 ( $fieldvar{$ff[$ii]}[$j], $fieldvar{$ff[$ii]}[$k] )= 
         ( $fieldvar{$ff[$ii]}[$k], $fieldvar{$ff[$ii]}[$j] );
     }

	}#if
   }}#for for
    return $#ff; 
}

sub SORTREVF{
    my $OUD=shift;  my $k;
    $OUD=~s/\$//;   $OUD= uc($OUD); 
#   foreach (keys %fieldvar){print "key $_ , hash= $fieldvar{$OUD}\n";}
    print   " SORTREVF : outputfield=$OUD;  \n";
    my @ff=split/[\s\,]+/,$OUD;
   

    for (my $j=0;$j<=$#{$fieldvar{$ff[0]}}; $j++){ # this goes to maxn
    for (my $k=$j;$k<=$#{$fieldvar{$ff[0]}}; $k++){ # this goes to maxn
	if  ($fieldvar{$ff[0]}[$j] < $fieldvar{$ff[0]}[$k]){

     for (my $ii=0;$ii<=$#ff; $ii++){ 
	 ( $fieldvar{$ff[$ii]}[$j], $fieldvar{$ff[$ii]}[$k] )= 
         ( $fieldvar{$ff[$ii]}[$k], $fieldvar{$ff[$ii]}[$j] );
     }

	}#if
   }}#for for
    return $#ff; 
}






############################################# END OF FUNCTIONS
############################################# END OF FUNCTIONS
############################################# END OF FUNCTIONS
############################################# END OF FUNCTIONS
############################################# END OF FUNCTIONS







###############################################
#      E N D       O F     C O D E
##############################################






########################################################
########################################################
#
# It is much better when it is structured
#          SO - lets start with procedures HERE
#
########################################################
########################################################


 sub dod{ 
print "default operation defined: $Defoperat (-x is operation!, not a negative number)\n";}


################################################# DISPLAY
################################################# DISPLAY
################################################# DISPLAY




sub display{
    my $Res=shift;
    my $nowar=shift || 0; # if 1==> no warning
#======================  find decimal point.
 $sres=sprintf("%f",$Res);
 $len=length($sres);
 $ppos=index($sres,'.');

# print "$sres .. $len .. $ppos ,,";
 $spa="";
# while (length($spa)<$offs+$len) {$spa.=" ";}
#-----------=========-------   add spaces
 while (length($spa)+$ppos<$offs) {$spa.=" ";}

#--==============----------- print result//////////////

#  dostri == string after the result = Warning string (DO, substract, ...)
#  spa (see above) is just space to put before
 if ($Defoperat ne ""){$dostri="\t\t..DO";}else{$dostri="";}
 if  ($nowar!=1){ $dostri.=$Warning;}



#-------  if line IS ---------- OR ============ only
 if ($Line=~/[=\-]/){
   if ($Linemark eq "="){ $Res=0; $Line.=" AC"; }  # IN CASE OF ==== line ... ZERO xxx
   printf("%s\n",$Line);


 }else{ #---- ok, line is NOT --------- nor ==============

     #_________ play with precision ____ PREPARE DISPLAY FORMAT
         $prfstrE="%s%.".$precis."e %s\n";
         $prfstrF="%s%.".$precis."f %s\n";
#       print "E=$prfstrE\n";       print "F=$prfstrF\n";
     #______________  go to the exponential format ______
#     $magnl=3; $magnh=5; # DEFINED in the begining......
     my $magnlx="1E-".$magnl; my $magnhx="9.999E+".$magnh;
     if (abs($Res)<$magnlx ||  abs($Res)>$magnhx){ 
	 #   play with alignment ..... dec .6 = offs-1
#       printf("%s%.6e %s\n"," "x ($offs-1), $Res,$dostri); # !!! TO REDO 5->variable
       printf($prfstrE," "x ($offs-1), $Res,$dostri); # DISPLAY EXPON
     }else{
#       printf("%s%.8f %s\n",$spa,$Res,$dostri);
       printf($prfstrF,$spa,$Res,$dostri); #DISPLAY FLOAT
     }
   if ($debug>0){print "debug defoperat,DO: $Defoperat,   $DO,\n";}
 }

}# end of DISPLAY ##############################################












sub display_fields{
#__________________ diplay status _______________________
 print "\n";
     foreach (keys %fieldvar){#______ DISPLAY STATUS ______
	$,=" "; # !!! maters with the line cmd!!!
        print " "x 10,"field $_ contains (",@{$fieldvar{$_}},")\n";
	$,=""; # !!! maters with the line cmd!!!
     }
}# display fields DEBUG  routine







sub process_field_via_map{
 #___________________ PROCESS 1 field-VARIABLE ______ via MAP ______
     if ($nfields>1){ print "  $ff.. sorry, I cannot handle  $nfields fields in one expression\n";}

 if ($nfields==1){
 #print "  $ff..  I can handle  $nfields fields in one expression\n";
  if ($OUTPUTFIELD ne ""){ # remove assignment if there is an =assignment=
     $xXx=~s/[a-z]+=//i;
  }
 foreach $Ff (keys %fieldvar){
     if ($xXx=~/$Ff\s*=\s*\([\d\,\.\-\sE]+\)$/i ){  ## contains  assignment 
#	 $Warning.=" fld-asgn ";
	 $xXx=$#{$fieldvar{$Ff}}+1;#MANDATORY beware KEY!
     }elsif($nfields>1){ # too many for now
     }elsif($xXx=~/$Ff/i){ # contains operation
       $Warning.=" = #elms ";
       $xXx=~s/($Ff)/\$\_/gi;   #---prepare for map with $_
       # here was a problem... must redo it...
       @res=map {eval($xXx)} @{$fieldvar{$Ff}};
    #   print "source:",@{$fieldvar{$Ff}},"  expres: $xXx result=@res\n";

#============= DISPLAY ================
       print " "x 10,"(@res)\n"; my $rror;
       my @tmp=qw();
       foreach $rror (@res){
	   my $Warning1=$Warning; $Warning="";
	   &display($rror);
	   $Warning=$Warning1;
	   push @tmp,$rror;
       }
           if ($OUTPUTFIELD ne ""){
#	       if (exists $fieldvar{$OUTPUTFIELD})
#                    { delete $fieldvar{$OUTPUTFIELD};}
             $fieldvar{$OUTPUTFIELD}=\@tmp;
           }
   	   print($spa."-------\n");
           $xXx=$#res+1;
     }# elsif contains operation_______________
#  print " changed fields ... $xXx";
     }# for keys %
 }# if nfields==1
}#end process field via map==================





######################"" key procedure to process the field
sub process_field{
    my ($Ff,$i_elem,$sds_);
 if ($nfields>0){
  my $backxXx=$xXx; 
  foreach $Ff (keys %fieldvar){ #====> replace with reference to element
     $xXx=~s/(\b)$Ff(\b)/\1\$\{\$fieldvar\{$Ff\}\}[\$i_elem]\2/g;
#     print "conversion to one element:$xXx\n";
 }# all keys conv to element

 my @tmp=qw(); 
                 # to say display, that the last result was something
  $Linemark="";  $Line="";
 for ($i_elem=0; $i_elem<$OUTPUTDIM;$i_elem++){# go through it
              #  $xXx='${$fieldvar{F}}[$i_elem] + ${$fieldvar{D}}[$i_elem]'; 
   $sds_=eval($xXx);
   $tmp[$i_elem]=$sds_; #print "outfield=$OUTPUTFIELD ..temp=@tmp\n\n";
#   print "i=$i_elem ....$xXx....$sds_\n";

 if ($debug>=1){print "input line after processin4.1(pfdisp):$xXx\n";}
   &display($sds_, 1); # each field element, 1== no warning!
 if ($debug>=1){print "input line after processin4.2(pfdisp):$xXx\n";}
 }# EVAL for
 #================= Bring to assigned field
           if ($OUTPUTFIELD ne ""){
       #    print "HEY! outfield=$OUTPUTFIELD ..temp=@tmp\n";
             $fieldvar{$OUTPUTFIELD}=\@tmp;
           }
   	   print($spa."-------\n");
           $xXx=$OUTPUTDIM;
           # $xXx= $backxXx;
 }#end of eval fieldop....................NFIELDS >0    => act

}


sub exit_with_history{
    my $q=shift @_ || 1; # 1==exit 
     open OUT,">$ENV{HOME}/.calc.pl" || die ".calc.pl not opened..";
     my $hicount=0;
     foreach (@history) {$hicount++;
              if ($_=~/\S/ and ($#history-$hicount)<50){print OUT "$_\n";}}
     close OUT;
    if ($q==1){
     print "exiting, history written...\n";
     print `echo -e  "\\033]0;Terminal\\a\\c"`; # make term title "calc.pl" 
     exit 0;}
}


sub catchupsig{ my $sig=shift; 
 print `echo -e  "\\033]0;xterm\\a\\c"`; # make term title "calc.pl" 
 &exit_with_history(-1);
 die "quiting via SIG:$sig...\n";
}# End correctly with C-c




##########################################################
##########################################################
#
# 061004 - bug in cos theta  for theta > 90 deg
# 061005 - bug in tan > 180 deg
#          bug in hash definition, now - deleted first
# 061026 - terminal name removed even when Ctrl-c via $SIG{INT}
# 061103 - numbers in field's names, BUG "eval 01.12" found
#          most of lowercase internal vars renamed
#          better readf, writef, "_"  possible
#          bug with not always lowercase [A-Z]
#
#
##########################################################
##########################################################
