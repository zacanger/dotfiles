#!/usr/bin/env bash

# Source: https://github.com/rhysd/ghci-color/blob/master/ghci-color

GREEN=`echo '\033[92m'`
RED=`echo '\033[91m'`
CYAN=`echo '\033[96m'`
BLUE=`echo '\033[94m'`
YELLOW=`echo '\033[93m'`
PURPLE=`echo '\033[95m'`
RESET=`echo '\033[0m'`

load_failed="s/^Failed, modules loaded:/$RED&$RESET/;"
load_done="s/done./$GREEN&$RESET/g;"
double_colon="s/::/$PURPLE&$RESET/g;"
right_arrow="s/\->/$PURPLE&$RESET/g;"
right_arrow2="s/=>/$PURPLE&$RESET/g;"
calc_operators="s/[+\-\/*]/$PURPLE&$RESET/g;"
string="s/\"[^\"]*\"/$RED&$RESET/g;"
parenthesis="s/[{}()]/$BLUE&$RESET/g;"
left_blacket="s/\[\([^09]\)/$BLUE[$RESET\1/g;"
right_blacket="s/\]/$BLUE&$RESET/g;"
no_instance="s/^\s*No instance/$RED&$RESET/g;"
interactive="s/^<[^>]*>/$RED&$RESET/g;"

exec "`which ghc`" --interactive -v0 ${1+"$@"} 2>&1 |\
    sed "$load_failed\
         $load_done\
         $no_instance\
         $interactive\
         $double_colon\
         $right_arrow\
         $right_arrow2\
         $parenthesis\
         $left_blacket\
         $right_blacket\
         $double_colon\
         $calc_operators\
         $string"
