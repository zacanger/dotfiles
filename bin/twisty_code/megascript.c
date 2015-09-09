
#ifdef _not_defined
#\
"exit`[ -z $BASH ] && t=sh; [ -z $BASH ] || t=$(basename $BASH); echo Hello, World from $t > /dev/tty;`";
"[puts {Hello, World from Tcl}; {exit}]";
from operator import concat;
exec concat(concat(concat(chr(109),chr(61)),chr(39)),chr(39));
m,""" ";/,;s/;//;
#else
#include <stdio.h>
#define BEGIN int main(int nargs,char** args)
#define print(a) printf("%s","Hello, World from C\n")
#ifdef __cplusplus
#undef print
#define print(a) printf("%s","Hello, World from C++\n")
#endif
#define exit return 0
BEGIN {
#ifdef _still_not_defined
   $crap = " from Perl";
   $0 = "Hello, World$crap\n";
   $NF = "World from awk";
#endif
   print($0);
   exit;
}
#endif
#ifdef _i_wont_define_it_so_stop_asking
# """; print "Hello, World from Python" # "
#endif
