#!/bin/sh
version=1.4.0

#HTML-colours: ---------------------------------------------------------------

BG=black       #background
DIR=blue       #dir-links
FILE=cyan      #file-links
HR=olive       #seperators
LAST=green     #last check was on ...
LAST2=magenta  # ... date_string ...
LAST3=magenta  # ... time since
LESS=lime      #smaller files
MORE=red       #bigger files
NEW=yellow     #new files
PC=darkred     #percent
SIZE=purple    #sizes
SUM=white      #dir-size
TEXT=grey      #plaintext

#needed binaries: ------------------------------------------------------------

unset missing
which which &> /dev/null || { echo "ERROR: 'which' not found"; exit; }
for bin in cat cp date du grep gzip head ls mkdir mv rm sed sort tee touch; do
  [ "$(which "$bin")" ] || missing="$missing $bin"
done; [ "$missing" ] && {
  echo "binaries are missing:"
  echo " $missing"
  exit
}

BROWSER=$(which "$GT5_BROWSER" links links2 elinks lynx w3m 2> /dev/null | head -n1)
AWK=$(which "$GT5_AWK" "$AWK" gawk awk 2> /dev/null | head -n1)
[ "$AWK" ] || { echo "No awk-clone found, please install one."; exit; }

[ "$BROWSER" ] || {
  echo "No textbrowser found, please install one."
  echo "HINT: see http://gt5.sf.net/browsers.html"
  exit
}

#does sort work? (broken in busybox 1.4.[01])
TEST_IN="$(echo -e "1 b\n2 a")"
TEST_OUT="$(echo "$TEST_IN" | sort -k1 -k2)"
[ "$TEST_IN" != "$TEST_OUT" ] && {
  echo  "ERROR: sort is broken, sorry"
  exit
}

#some functions: -------------------------------------------------------------

gt5_replace() {
  #replace: ${s/a/b}, args: string from to
  echo "$1" | "$AWK" '{sub(a,b); print}' a="$2" b="$3"
}

gt5_replace_all() {
  #replace: ${s//a/b}, args: string from to
  echo "$1" | "$AWK" '{gsub(a,b); print}' a="$2" b="$3"
}

gt5_substr() {
  #replace: ${s:0:1}, args: string start [end]
  echo "$1" | "$AWK" -F"\n" "{print(substr(\$1,$2${3:+,$3}))}"
}

gt5_substr_After() {
  #replace: ${s##*/}, args: string return_s_after
  echo "$1" | "$AWK" '{sub(s,""); print}' s=".*$2"
}

gt5_substr_before() {
  #replace: ${s%/*}, args: string return_s_before
  echo "$1" | "$AWK" '{
    for (i=length($0); i; i--) {
      if (index(substr($0,i), s)) {
        print(substr($0,1,i-1))
        exit
      }
    }
    print
  }' s="$2"
}

gt5_substr_Before() {
  #replace: ${s%%/*}, args: string return_s_before
  echo "$1" | "$AWK" '{sub(s,""); print}' s="$2.*"
}

#initial stuff: --------------------------------------------------------------

umask 077
unset BIN CD CONFIGURE_OPTS CUT DATE F1 F2 LINK_FILES SAVE SAVE_DU_AS SINCE

TMP=$( #there may be systems without mktemp
  mktemp -d -q /tmp/gt5.$$.XXXXXXXX || {
    dir="/tmp/gt5.$$.$RANDOM"
    mkdir "$dir" || exit
    echo "$dir"
  }
)
ESCAPED_TMP=$(gt5_replace_all "$TMP" "\"" "\\\"")
trap "rm -rf \"$ESCAPED_TMP\"" 0 15

SPACE="_escaped_${RANDOM}_space_"
TAB="_escaped_${RANDOM}_tab_"
DATA=$TMP/gt5.html
DDIR=~/.gt5-diffs
CUT_AT="0.1"
MAX_DEPTH=5
SAVE_DU=1
ML=10000
DIFFS=1
X=x

#online help: ----------------------------------------------------------------

gt5_help() {

  echo "Syntax: gt5 [ dir | file | dir file | file file2 ] [options]"
  echo "     dir           the directory you want to check for space used"
  echo "     file/file2    existing du-logs (du -akx \$DIR #gz/bz2/plain)"
  echo "   --cut-at float  don't show files below 'float'% of its parent,"
  echo "                   default is $CUT_AT, use values between 0.01 and 30"
  echo "   --diff-dir d    use dir d to store diffs between runs [$(gt5_replace "$DDIR" "$HOME/" "~/")]"
  echo "   --discard       do not save this one for diffs, discard it"
  echo "   --link-files    insert links to files for direct access"
  echo "   --max-depth i   ignore anything deeper than i directories [$MAX_DEPTH]"
  echo "   --max-lines i   only consider the i biggest files [$ML]"
  echo "   --no-diffs      use this if you really do not want diffs"
  echo "   --save-as file  DEPRECATED, use 'du', see manpage"
  echo "   --save-state    overwrite a previous '--discard'"
  echo "   --with-mounts   also look below mountpoints"
  exit

}

#parse Options: --------------------------------------------------------------

while [ "$1" ]; do

  case "$1" in

    --cut-at)
      case "$2" in
        [0-9]|[0-9].[0-9]|[0-9].[0-9][1-9]);;
        [1-3][0-9]|[1-3][0-9].[0-9]|[1-3][0-9].[0-9][1-9]);;
        *) echo "bad cut-at-arg \"$2\", use values between 0.01 and 30"; exit;;
      esac
      CUT_AT=$2
      shift
      ;;

    --diff-dir) DDIR="$2"; shift;;

    --discard) unset SAVE_DU;;

    --get-awk|--get-gawk) install_pkg gawk;;
    --get-links) install_pkg links;;
    --get-links2) install_pkg links2;;
    --get-elinks) install_pkg elinks;;

    --link-files) LINK_FILES=true;;

    --max-depth)
      case "$2" in
        [0-9]|[1-9][0-9]);;
        *) echo "bad max-depth-arg \"$2\", valid is 0-99"; exit;;
      esac
      MAX_DEPTH=$2
      shift
      ;;

    --max-lines)
      case "$2" in
        [1-9][0-9][0-9][0-9][0-9]|[1-9][0-9][0-9][0-9][0-9][0-9]);;
        *) echo "bad max-lines-arg \"$2\", valid is 10000-999999"; exit;;
      esac
      ML=$2
      shift
      ;;

    --no-diffs) DIFFS=0; unset SAVE_DU;;

    --save-du-as) SAVE_DU_AS="$2"; shift;;

    --save-as|--keep-as)
      [ "$2" ] || gt5_help
      touch "$2" || exit
      [ -f "$2" ] || { echo "\"$2\" is not a file."; exit; }
      [ "$(gt5_substr "$2" 1 1)" == "/" ] && SAVE="$2" || SAVE="$PWD/$2"
      shift
      ;;

    --save-state) SAVE_DU=1;;

    --version) echo gt5 v$version; exit;;

    --with-mounts) unset X;;

    *) #dirs/files to show:
      unset VALID
      [ -d "$1" ] && {
        [ "$CD$F2" ] && gt5_help
        cd "$1" || exit
        cd "$OLDPWD"
        CD="$OLDPWD"
        VALID=1
      }
      [ -f "$1" ] && {
        H="$(gt5_substr "$1" 1 1)"
        [ "$F2" ] && gt5_help
        [ "$F1" -a "$CD" ] && gt5_help
        [ -r "$1" ] || { echo "ERROR: cannot read \"$1\""; exit; }
        [ "$H" != "~" -a "$H" != "/" ] && H="$PWD/" || unset H
        [ "$F1" ] && F2="$H$1" || F1="$H$1"
        VALID=1
      }
      [ "$VALID" ] || gt5_help
      ;;

  esac
  shift

done

[ "$CD" ] && cd "$OLDPWD"

[ "$SAVE_DU_AS" ] && {
  du -ak$X 2> /dev/null | grep -v ^0 | gzip > "$SAVE_DU_AS-$(date +%y%m%d-%H%M).gz"
  exit
}

GENERIC_STORE=$(gt5_replace_all "$PWD" "_" "__").gz
GENERIC_STORE="$DDIR/$(gt5_replace_all "$GENERIC_STORE" "/" "_,")"
[ -d "$DDIR" ] || mkdir "$DDIR" || exit

[ "$F1" ] && unset SAVE_DU || {

  [ "$CD" ] || CD=$PWD

  unset H
  F1="$(gt5_replace_all "$CD" "_" "__")"
  F1="$DDIR/$(gt5_replace_all "$F1" "/" "_,")"
  while [ ! -f "$F1.gz" -a "$F1" != "$DDIR/" ]; do
    H="/$(gt5_substr_After "$F1" "_,")$H"
    F1=$(gt5_substr_before "$F1" "_,")
  done

  [ "$F1" == "$DDIR/" ] && F1="$DDIR/_,"

  [ -f "$F1.gz" ] && { CUT="$H"; F1="$F1.gz"; } || unset F1

}

[ "$F1" ] && { DATE=$(date -r "$F1"); SINCE=$(date -r "$F1" +%s); }
[ "$CD" ] && P="$HOSTNAME:$PWD" || P="file: $F1"
[ -z "$CD$F2" -o -z "$F1" ] && DIFFS=0
[ "$CD" ] || unset LINK_FILES SAVE_DU

#can du handle depths?
DEPTH="$(du --help 2>&1 | "$AWK" '
  /depth/{sub(/^[^-]*/,""); sub(/[N ].*/,""); print; exit}
')$((MAX_DEPTH+1))"

{

  ID=0
  [ "$CD" ] && { SECONDS=0
    echo -n "processing \"$(gt5_replace "$PWD" "$HOME/" "~/")\", please be patient ... " 1>&2
    du -ak$X $DEPTH 2> /dev/null | grep -v ^0 | tee "$TMP/this" | sed "s,^,$ID ,"
    ID=$((ID+1)); echo "done ${SAVE:+[${SECONDS}s]}" 1>&2
  }

  for f in "$F1" "$F2"; do

    [ -f "$f" ] || continue

    case "$f" in *gz) CAT="gzip -cd";; *bz2) CAT="bzip2 -cd";; *) CAT=cat;; esac

    [ "$f" -a $ID -le $DIFFS ] && { SECONDS=0
      echo -n "processing \"$(gt5_replace "$f" "$HOME/" "~/")\" ... " 1>&2
      $CAT "$f" | sort -k1nr -k2 | "$AWK" 'NR==1{sub(/\/$/,"");P="	"$2"'"$CUT"'"}
        $1&&/'"$(gt5_replace_all "$CUT" "/" "\\\/")"'/{sub(/^/,"'$ID' ");sub(P,"	.");sub(/\/$/,""); print}'
      ID=$((ID+1)); echo "done ${SAVE:+[${SECONDS}s]}" 1>&2
    }

  done

  #cannot set SECONDS to ZERO here :-(
  echo -n "generating HTML-file ... " 1>&2

} | sed 's, ,'"$SPACE"',g;s,'"$SPACE"', ,;s,	,'"$TAB"',g;s,'"$TAB"', ,' |

#gt5's magic starts here:
sort -k3 -k1,1nr |
"$AWK" '{
  if (!$1) {printf("%s %s %s\n", $2, (on==$3?os:-1), $3)}
  else {os=$2; on=$3} on=$3
}' | sort -k1,1nr -k3 | "$AWK" '
  NR>'"$ML"'{exit}
  {
    if (NR==1) {printf("%s %s\n",$0,$0)}
    me=$3; size[me]=$1; osize[me]=$2
    e=0; while (i=index(substr(me,e+1),"/")) e+=i
    if (e) {p=substr(me,1,e-1); printf("%s %s %s %s\n",size[p],osize[p],p,$0)}
  }
' | sort -k1,1n -k3,3r -k4,4n | "$AWK" '
  BEGIN{
    H='$(date +%s)'-'${SINCE:-0}'
    print "</pre></body></html>"
    s=H%60; H/=60; m=H%60; H/=60; h=H%24; d=H/24
    timespan=sprintf("%id, %02i:%02i:%02i",d,h,m,s)
  }
  function i2h(i) {
    E="K"; i+=0 #forcing i being a number ...
    if (i>999) { i/=1024; E="M" }
    if (i>999) { i/=1024; E="G" }
    if (i>999) { i/=1024; E="T" }
    if (i<9.95) return sprintf("%.1f%cB",i,E);
    else return sprintf("%.0f%cB",i,E);
  }
  function directory (p,ps,pos,pf) {
    if (!p) return #no parent on first call
    printf "\n%s/:   [<font color='$SUM'>%s",p,i2h(ps)
    printf "</font> in "children[p]" files or directories]  "
    if ('$DIFFS') {
      if (pos==-1) printf "<font color='$NEW'>new</font>"; else {
        if (ps<pos) printf "<font color='$LESS'>-%s</font>",i2h(pos-ps)
        if (ps>pos) printf "<font color='$MORE'>+%s</font>",i2h(ps-pos)
      }
    }
    print "\n<font color='$HR'><hr></font></a>"
    if ('$DIFFS' && "'"$F2"'"=="") {
      printf "<font color='$LAST'> last check was on <font"
      printf " color='$LAST2'>'"$DATE"'</font> (i.e. <font color="
      printf "'$LAST3'>"timespan"</font> ago)</font>\n"
    }
    printf "<a name=\""(nr[p]=x++)"\">gt5 v'"$version</a> ($P)"':   [cut:"
    print '$CUT_AT'"% depth:"'$MAX_DEPTH'" lines:"'$ML'"]"
    if (pf) for (i=0; i<16; ++i) print "\n\n\n\n\n\n\n\n"
  }
  $1>0{ #division by zero ...
    if (op!=$3) directory(op,ops,opos,1)
    ops=$1; opos=$2; op=$3; pz=100*$4/ops
    e=0; while (j=index(substr($6,e+1),"/")) e+=j; s=substr($6,e+1)
    children[$3]++; if (children[$6]) s="<a href=\"#"nr[$6]"\">"s"</a>/"
    else if ("'"$LINK_FILES"'") {
      h="<a href=\"'"${PWD}"'"substr($6,2)
      s=h"\"><font color='$FILE'>"s"</font></a>"
    }
    if (pz>='"$CUT_AT"' && $6!=".") {
      printf "<font color='$SIZE'>%6s</font> ",i2h($4)
      printf "[<font color='$PC'>%5.2f%%</font>] ./%s  ",pz,s
      if ('$DIFFS') {
        if ($5==-1) printf "<font color='$NEW'>new</font>"; else {
          if ($4<$5) printf "<font color='$LESS'>-%s</font>",i2h($5-$4)
          if ($4>$5) printf "<font color='$MORE'>+%s</font>",i2h($4-$5)
        }
      }; printf "\n"
    }
  }
  END{
    directory(op,ops,opos)
    if (!x) print "     directory seems to be empty\n\n\ngt5 v'"$version ($P)"'"
    printf "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html;"
    printf " charset='${GT5_CHARSET:-$LANG}'\"></head><body bgcolor='$BG'"
    print " text='$TEXT' link='$DIR'><pre>"
  }
' | awk '
  {gsub(/'"$SPACE"'/, " "); gsub(/'"$TAB"'/, "	"); b[NR]=$0}
  END{for (i=NR; i; --i) print(b[i])}
' > $DATA

echo "done (size: $(gt5_substr_before "$(ls -sh "$DATA")" " "))" 1>&2

[ "$SAVE_DU" ] && {

  SECONDS=0
  touch "${GENERIC_STORE}.$$.tmp" || exit
  gzip < "$TMP/this" > "${GENERIC_STORE}.$$.tmp" &
  ESCAPED_GS=$(gt5_replace_all "${GENERIC_STORE}.$$.tmp" "\"" "\\\"")
  trap "rm -rf \"${ESCAPED_TMP}\" \"${ESCAPED_GS}\"" 0 15
  echo  -n "saving state information ... " 1>&2

  [ "$SAVE" ] && {
    wait; echo "done ${SAVE:+[${SECONDS}s]}" 1>&2
    mv "${GENERIC_STORE}.$$.tmp" "$GENERIC_STORE"
  } || echo "(background)" 1>&2

}

[ "$SAVE" ] && {

  cat $DATA > "$SAVE" || exit
  echo -e "\nYour data was successfully saved as \"$SAVE\"."
  echo "WARNING: \"--save-as\" is deprecated, see manpage."

} || {

  echo "starting browser ($(gt5_replace "$BROWSER" "$HOME/" "~/")) ... " 1>&2
  cp -l $DATA ~/.gt5.html 2> /dev/null || cp $DATA ~/.gt5.html || exit
  $BROWSER $DATA

  [ "$SAVE_DU" ] && {
    wait # for $TMP/this beeing packed ...
    mv "${GENERIC_STORE}.$$.tmp" "$GENERIC_STORE"
  }

}

