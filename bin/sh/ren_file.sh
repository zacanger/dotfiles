#!/usr/bin/env bash 
#set -x 
#############################################################################
###########################################################################
### Created by Adam Danischewski (c) 2014 v1.01
### Issues: If you find any issues emai1 me at my <first name> dot 
###         <my last name> at gmail dot com.  
### This program handles the following known filename problems: 
         ###  Spaces anywhere incl the begin/end of filenames ==> _'s 
         ###  Newlines embedded filenames               ==> RANDOM hexchar a-f0-9
         ###  Multibyte Characters of any encoding type ==> RANDOM hexchar a-f0-9 
         ###  Backslashes are replaced                  ==> RANDOM hexchar a-f0-9  
         ###  Other special characters in filenames     ==> RANDOM hexchar a-f0-9
              ### Although leading dashes are technically legal they 
              ### can cause a lot of problems if you don't expect them 
         ###  Leading dashes in filenames               ==> RANDOM hexchar a-f0-9                
    ##This program is free software: you can redistribute it and/or modify
    ##it under the terms of the GNU General Public License as published by
    ##the Free Software Foundation, either version 3 of the License, or
    ##(at your option) any later version.

    ##This program is distributed in the hope that it will be useful,
    ##but WITHOUT ANY WARRANTY; without even the implied warranty of
    ##MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    ##GNU General Public License for more details.

    ##You should have received a copy of the GNU General Public License
    ##along with this program.  If not, see <http://www.gnu.org/licenses/>.
###########################################################################
#############################################################################

declare -r  DATE_PREFIX=$(date +%Y%m%d)
declare -r  RENAME_BSH=".rename_${DATE_PREFIX}_$$.bsh"   
declare -r  UNRENAME_BSH=".unrename_${DATE_PREFIX}_$$.bsh"   
declare -i  MAXBADCHRS=150 
declare -i  WROTE_ENTRIES=0
declare -r  VIEWLOGPROG="$(which geany || echo 'cat')"
declare -i  AUTOVIEWLOG=1
declare -i  AUTOEXECUTE=0
declare -r  DEFPERM=400 
declare -i  QUIETMODE=0 
declare -i  DEBUGMODE=0
declare     MVOPTIONS="-nv"  
declare     CPOPTIONS="-nv"  
declare     SENTINELS=""
#declare -r  ECHOCMD="stdbuf -o0 echo"
#declare -r  ECHOCMD="unbuffer echo"

function usage() {
cat <<EOF
Usage: ${0##*/} <-h> <-v=[on|off]> <-t|d|x|q|s> <-c=[numchars]>

OPTIONS:
      -h           Show this message
      -d           Turn on debug mode 
      -v=<on|off>  Turn on/off auto review of rename file. <default is on> 
      -t           Automatically tests the functionality on known troubly 
                   named files and reports if this program is working properly.  
      -q|-s        Quiet/Silent mode - don't report much if anything
      -c=<num>     Sets the max number of bad characters to replace (default=150)           
      -x           "eXpert/eXpress/eXecute" mode -- it will chmod +x and 
                   automatically execute the generated rename script. 
                   This option is not recommended for sensitive data areas.
EOF
} 
 
function help() {
cat <<EOF
Description: ${0##*/}

This program will create scripts to rename all files with special 
characters in the directory where it is run. It replaces spaces with 
_'s and really bad characters with random characters. 

The scripts by default are named: .rename_<date>_<pid>.bsh and
.unrename_<date>_<pid>.bsh. It is recommended that you review them both
to make sure everything is okay and reversible before you run them. The
default permissions set are 400 so you usually need to chmod the files
before running them (e.g. chmod +x ./.rename_<date>_<pid>.bsh) 
EOF

usage 

cat <<EOF
  E.g.
      \$cd /directory/where/bad/files/live 
      \$${0##*/} 
      \$chmod + .rename_<date>_<pid>.bsh
           ... review files ...  
      \$bash ./.rename_<date>_<pid>.bsh 
EOF
exit 0 
}

function fail_test() { 
 echo "$2" 
 #echo -en "$2" | tee >(cat - >&2) 1>/dev/null
 echo "Unit Testing of ${0##*/} FAILED.. " 
 echo "It is not recommended to use this program until you find out why.. " 
 exit $1 
} 

  ## <arg 1> string - string to build random chr from 
function get_random_chr() { 
 local    BUILDSTR="$1"
 local    MD5STR="$(md5sum <<< "$BUILDSTR")" 
 local -i INDEX=$(($RANDOM%9))
 echo "${MD5STR:$INDEX:1}"
}  

  ## <arg 1> string - string to build random chr from 
function get_random_sentinel() { 
 local    BUILDSTR="$1"
 local    MD5STR="$(md5sum <<< "$BUILDSTR")" 
 local -i INDEX=$(($RANDOM%9))
 local    TMPSENTINEL="${MD5STR:$INDEX:3}"
   ### Loop until we know the string is a unique sentinel for our string
 while :; do 
  CHCK="$(grep -o "$TMPSENTINEL" <<< "${BUILDSTR}${SENTINELS}")"
  if [[ -z "$CHCK" ]]; then 
    break;
  else 
    MD5STR="$(md5sum <<< "$(get_random_chr "${MD5STR}")${MD5STR}")" 
    TMPSENTINEL="${MD5STR:$INDEX:3}" 
  fi 
 done 
 echo "${TMPSENTINEL}" 
}  

  #arg <1> string - a filename to test 
function unit_test() {   
 #set -x 
 local FILENAMEFROMHELL="$1" 
 local OK=1 
 TESTDIR="/tmp/_${0##*/}_test_$$_" 
 mkdir -p "$TESTDIR" 
 if [[ -d "$TESTDIR" ]]; then 
    cd "$TESTDIR"
 else 
    echo "Test directory does not exist.. " 
    fail_test -3 
 fi    
 touch "${FILENAMEFROMHELL}"  
 [[ ! -f "$FILENAMEFROMHELL" ]] && fail_test -4 "Cant find test file.. " 
 ${0##./} -v=off -x 
 ((! ! $?)) && fail_test -7 "Cant find this prog from test loc, put this prog in your path or use a FQN (/abs/toprog).. " 
 chmod +x ./.*name*
 [[ -f "$FILENAMEFROMHELL" ]] && fail_test -5 "Test file not renamed.. "
 echo "Successfully renamed trouble file ... " 
 ./.unrename*
 [[ ! -f "$FILENAMEFROMHELL" ]] && fail_test -6 "Test file not unrenamed.. " 
 echo "Successfully unrenamed trouble file ... " 
 cd - 
 rm -f "${TESTDIR}/."* 2>/dev/null 
 rm -f "${TESTDIR}/"* 2>/dev/null 
 rmdir "${TESTDIR}"
 ((! ! $?)) && fail_test -8 "Could not delete test directory ${TESTDIR}"  
 echo "Testing of ${0##*/} Successful!! " 
 return 0 
}

function test_fire() { 
  ## leading $'s, multiple backslashes, multiple newlines, multiple multibyte characters and trailing spaces
FNHORROR1=$(echo '$$th\\\\\\SSS\\#$(*&@isNNN # is !#\\\\#!$SSS#@*()&这NNN个程序\\\\\\是体SSS面^$%a NNNfile \\\\\  ' | sed "s/NNN/\xa/g" | sed "s/SSS/\'/")	
unit_test "$FNHORROR1" 
  ## leading space, multiple backslashes, multibyte characters and newlines with a trailing backslash 
FNHORROR2=$(echo ' \$$th\\\\\\SSS\\#$(*&@isNNN # is !#\\\\#!$\SSS#@*()&这NNN个程序\\\\\\是体SSS面^$%a NNNfile \\\\\ BACK' | sed "s/NNN/\xa/g" | sed "s/SSS/\'/" | sed "s/BACK/\x5c/")	
unit_test "$FNHORROR2" 
echo "This program should work as expected (at least where it was run).. " 
exit 0 
} 

function process_options() { 
local OPTIND OPTARG OPTION h t v q s d c
#read -p "inside process options OPTARG is $OPTARG " -u 1 bbbb
while getopts “:htqsdc:xv:” OPTION "$@"; 
 do
     case "$OPTION" in
         h)
             help
             ;;
         c)
             OPTVAL="${OPTARG##*=}"
             if [[ ! -z "$(echo "$OPTVAL" | grep "^[0-9]*$")" ]]; then 
               MAXBADCHRS=$OPTVAL 
             else 
               usage
               echo "${0##*/} -c=<num> option $OPTARG is invalid, must be an integer > 0."
               exit 0               
             fi  
             ;;
         t)
             test_fire
             ;;
         x)
             AUTOEXECUTE=1
             ;;
         d)
             DEBUGMODE=1
             ;;
         s)
             :
             ;&
         q)             
             MVOPTIONS="-n"  
             CPOPTIONS="-n"  
             AUTOVIEWLOG=0
             QUIETMODE=1
             ;; 
         v)
             if [ "$OPTARG" == "=off" ]; then 
               AUTOVIEWLOG=0 
             elif [ "$OPTARG" == "=on" ]; then 
               AUTOVIEWLOG=1 
             else 
               echo "${0##*/} -v option $OPTARG is invalid";  
               usage
               exit 0
             fi  
             ;;
         ?)
             usage
             exit 0
             ;;
     esac
done
(($DEBUGMODE)) && set -xuo pipefail
} 

process_options "$@"
 
if [[ ! -f "$RENAME_BSH" ]]; then 
 echo "#!/usr/bin/env bash" > "$RENAME_BSH"
 echo "##### This script was automatically generated by ${0##*/}. #####" >> "$RENAME_BSH" 
 echo "## If the data is sensitive you should review this script for " >> "$RENAME_BSH" 
 echo "## accuracy prior to execution." >> "$RENAME_BSH" 
 echo "## And it is recommended that you keep a copy of this script and the sister"  >> "$RENAME_BSH" 
 echo "## unrename script for your records." >> "$RENAME_BSH" 
 echo "## Commented mv commands are only for readability, they will break so don't use them.." >> "$RENAME_BSH" 
else   
 echo "File already exists $RENAME_BSH not clobbering.. "
 exit -1
fi  

if [[ ! -f "$UNRENAME_BSH" ]]; then 
 echo "#!/usr/bin/env bash" > "$UNRENAME_BSH"
 echo "##### This script was automatically generated by ${0##*/}. #####" >> "$UNRENAME_BSH" 
 echo "## If the data is sensitive you should review this script for " >> "$UNRENAME_BSH" 
 echo "## accuracy prior to execution." >> "$UNRENAME_BSH" 
 echo "## And it is recommended that you keep a copy of this script and its brother"  >> "$UNRENAME_BSH" 
 echo "## rename script for your records." >> "$UNRENAME_BSH" 
 echo "## Commented mv commands are only for readability, they will break so don't use them.." >> "$UNRENAME_BSH" 
else 
 echo "File already exists $UNRENAME_BSH not clobbering.. " 
exit -1  
fi 

while IFS= read -r -d '' a; do 
 ((!$QUIETMODE)) && echo  "Processing $a ..."         
 TMP="$a"
 CHANGED=0 
 for b in $(eval echo "{1..${MAXBADCHRS}}"); do 
    OLDHASH=$(echo "$TMP" | md5sum) 
      ## probably should include way to include wider range of random replacements or a mapping.. switch 
    TMP=$(echo "$TMP" | sed "s/ /_/g;s/[^0-9A-Za-z._-]/$(get_random_chr "${TMP}")/"|tr "\n" "$(get_random_chr "${TMP}")"|sed "s/^[^a-Z0-9._]/$(get_random_chr "${TMP}")/"|sed 's/.$/\n/' | LANG=C sed "s/[\x80-\xFF]/$(get_random_chr "${TMP}")/")           
    NEWHASH=$(echo "$TMP" | md5sum) 
    [ "$OLDHASH" == "$NEWHASH" ] && break; 
    CHANGED=1
 done 
 if (($CHANGED)); then   
  WROTE_ENTRIES=1 
  BACKSLASH="$(get_random_sentinel "$a")"
  SENTINELS="${SENTINELS}${BACKSLASH}" 
  NEWLINE="$(get_random_sentinel "$a")"
  SENTINELS="${SENTINELS}${NEWLINE}" 
  SINGLEQUOTE="$(get_random_sentinel "$a")"
  SENTINELS="${SENTINELS}${SINGLEQUOTE}" 
  NEWFILE=$(sed "s/\x5c\x5c/${BACKSLASH}/g" <<< "$a")
  NEWFILE=$(echo -en "$NEWFILE" | sed ":a;N;\$!ba;s/\n/${NEWLINE}/g" | sed "s/\x27/${SINGLEQUOTE}/g") 
  echo  "##mv ${MVOPTIONS} -- '${NEWFILE}' '${TMP}'"        >> "$RENAME_BSH" 
  echo  "NEWFILE=\$(echo -n '${NEWFILE}'|sed \"s/${NEWLINE}/\xa/g\"|sed \"s/${BACKSLASH}/\x5c/g\"|sed \"s/${SINGLEQUOTE}/\x27/g\")"  >> "$RENAME_BSH" 
  echo  "mv ${MVOPTIONS} -- \"\$NEWFILE\" '${TMP}'"         >> "$RENAME_BSH" 
  echo  "##mv ${MVOPTIONS} -- '${TMP}' '${NEWFILE}'"        >> "$UNRENAME_BSH" 
  echo  "NEWFILE=\$(echo -n '${NEWFILE}'|sed \"s/${NEWLINE}/\xa/g\"|sed \"s/${BACKSLASH}/\x5c/g\"|sed \"s/${SINGLEQUOTE}/\x27/g\")"   >> "$UNRENAME_BSH" 
  echo  "mv ${MVOPTIONS} -- '${TMP}' \"\$NEWFILE\""         >> "$UNRENAME_BSH" 
 fi 
SENTINELS=
done < <(find . -maxdepth 1 ! -name ".rename*" -a ! -name ".unrename*" -a ! -path . -printf "%f\0")

if [[ -f "$UNRENAME_BSH" ]] && [[ -f "$RENAME_BSH" ]] && (($WROTE_ENTRIES)); then 
 chmod ${DEFPERM} "$UNRENAME_BSH" "$RENAME_BSH" 
 ((!$QUIETMODE)) && echo "Done building scripts.. " 
 if ((! $AUTOEXECUTE)); then 
  ((!$QUIETMODE)) && echo "Review $RENAME_BSH and if it looks sane enough, chmod +x and run it" 
     ## Check to see if the filesystem where the scripts are generated is mounted noexec 
  ((!$QUIETMODE)) && mount | awk "\$0 ~ \"$(df . | sed '1d' | awk '{print $1}')\"{if(\$0 ~ "noexec") print \"The filesystem where the rename scripts are located looks like it is\n mounted noexec.\nYou may have to run the scripts by prefixing bash prior to the script.\n  E.g. chmod +x ${RENAME_BSH}; bash ./${RENAME_BSH}\" }"
  (($AUTOVIEWLOG)) && $VIEWLOGPROG "$RENAME_BSH"
 else 
  ((!$QUIETMODE)) && echo "Executing $RENAME_BSH .. " 
  chmod -f +x "$RENAME_BSH"
  bash "$RENAME_BSH" ## call the interpreter outside the script to avoid noexec mounts causing failure to execute
  ((!$QUIETMODE)) && echo "Done!!" 
 fi 
else 
 rm "$UNRENAME_BSH" "$RENAME_BSH" 
 ((!$QUIETMODE)) && echo "Checked files and directories, looks like nothing needs renaming .. " 
fi  

exit 0 
