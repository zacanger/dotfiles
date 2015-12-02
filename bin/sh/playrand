:
##########################################################################
# Shellscript:	playrand - play random file
# Author     :	Heiner Steven <heiner.steven@odn.de>
# Date       :	2001-04-09
# Requires   :	mpg123, mp3info, shuffle, sum, [xtitle]
# Category   :	Music
# SCCS-Id.   :	@(#) playrand	2.9 11/07/26
##########################################################################
# Description
#    o  "playrand Cranberries" only plays songs having
#	"Cranberries" in path name
#    o	Maintains multiple play lists for different song directories
#	
# Notes
#    o	Directories with whitespace characters in the MP3PATH are not
#       handled correctly
##########################################################################

PN=`basename "$0"`			# Program name
VER='2.9'

: ${MP3PATH:=/usr/local/share/mp3}
: ${PLAYLISTDIR:=$HOME/.$PN}

# MP3 player
player=mpg123
playerflags=
maxlistcnt=10
findargs="-type f -follow -name '*.mp*'"

Usage () {
    echo >&2 "$PN - play random MP3 files, $VER
usage: $PN [-Fl] [-d dirs] [-f playlist] [-m idtag=value [...]] [pattern ...]
    -d: directories with MP3 files (default: MP3PATH=$MP3PATH)
    -f: name of file with MP3 songs to play
    -F: force re-creation of playlist
    -l: list matching mp3 path names (do not play them)
    -m: MP3 ID tag criteria, e.g. \"genre=pop\"

Example:
    $PN -m genre=pop -m year=200[0-3]"
    exit 1
}

Msg () { echo >&2 "$PN: $*"; }
Fatal () { Msg "$@"; exit 1; }

# string2hash - create a unique "hash" value for a string
string2hash ()
{
    echo "$@" | sum | sed 's/[^0-9][^0-9]*/_/g'
}

addfilter ()
{
    for expr
    do
    	case "$expr" in
	    file=*)		fmt="%f";;
	    path=*)		fmt="%F";;
	    size=*)		fmt="%k";;
	    artist=*)		fmt="%a";;
	    comment=*)		fmt="%c";;
	    genre=*)		fmt="%g";;
	    genrenumber=*)	fmt="%G";;
	    album=*)		fmt="%l";;
	    tracknumber=*)	fmt="%n";;
	    title=*)		fmt="%t";;
	    year=*)		fmt="%y";;
	    stereo=*)		fmt="%o";;
	    bitrate=*)		fmt="%r";;
	    frequency=*)	fmt="%Q";;
	    *)
	    	Fatal "invalid filter expression: $expr"
	esac
	value=`echo "$expr" | cut -d= -f2-`
	case "$value" in
	    *%*)	Fatal "invalid character: %"
	esac
	fmtstring=${fmtstring:+$fmtstring/}$fmt
	matchstring=${matchstring:+$matchstring/}$value
    done
    #echo >&2 "DEBUG: fmtstring=<$fmtstring>"
    #echo >&2 "DEBUG: matchstring=<$matchstring>"
}

Mp3Path=
Playlist=
ForceCreate=false
ListOnly=false
while [ $# -gt 0 ]
do
    case "$1" in
	-d)	Mp3Path=$2; shift;;
	-F)	ForceCreate=true;;
	-f)	Playlist=$2; shift;;
	-l)	ListOnly=true;;
	-m)	addfilter "$2"; shift;;
	--)	shift; break;;
	-h)	Usage;;
	-*)	Usage;;
	*)	break;;			# First file name
    esac
    shift
done

[ $# -lt 1 ] && set -- '.*'

# Silently create directory for the playlists
[ -d "$PLAYLISTDIR" ] || mkdir -p "$PLAYLISTDIR" ||
	Fatal "cannot create directory: $PLAYLISTDIR"

if [ -n "$DISPLAY$WINDOWID" ]
then
    isxwindows=:		# true
    oldtitle=`xtitle -g w`
else
    isxwindows=false
fi

##########################################################################

if [ -z "$Playlist" ]
then
    # The user either has to specify directory(s) containing MP3 files,
    # or set the MP3PATH environment variable.

    searchpath=`echo "${Mp3Path:-$MP3PATH}" | tr : ' '`
    [ -n "$searchpath" ] ||
    	Fatal "specify MP3 search path either by using -d or by setting the
	MP3PATH environment variable"

    hashval=`string2hash "$searchpath"`
    [ -n "$hashval" ] || Fatal "cannot create unique id: $searchpath"

    Playlist=$PLAYLISTDIR/$hashval
    if [ -s "$Playlist" ] && [ $ForceCreate = false ]
    then
        Msg "using existing playlist: $Playlist"
    else
    	Msg "Song directory(s): $searchpath"	\
		"creating playlist $Playlist; please be patient"

	# We do not want partial playlists:
	trap 'rm -f "$Playlist" >/dev/null 2>&1' 1 2 3 13 15
	eval find $searchpath $findargs -print > "$Playlist" ||
		Fatal "could not create file list: $Playlist"
	trap 1 2 3 13 15
    fi
    if [ -s "$Playlist" ]
    then Msg "list contains" `wc -l < "$Playlist"` "audio files"
    else Fatal "found no songs: $searchpath"
    fi
fi

#echo >&2 "DEBUG: Playlist=<$Playlist>"
#ls -ld "$Playlist" >&2

[ -s "$Playlist" ] ||
	Fatal "play list does not exist or is empty: $Playlist"

##########################################################################

# Pre-process our playlist if the user specified mp3 filters based
# on ID tags.

if [ -n "$matchstring" ]
then
    hashval=`string2hash ":$matchstring:$MP3PATH"`
    newlist=$PLAYLISTDIR/$hashval

    if [ -s "$newlist" ] && [ $ForceCreate = false ]
    then
    	Msg "MP3 selection criteria playlist: $newlist"
    else
	Msg "preparing playlist for MP3 selection criteria..."
	Msg "(list will be saved for faster startup)"

	trap 'rm -f "$newlist" >/dev/null 2>&1' 0

	while read path
	do
	    mp3info -p "$fmtstring%%%F\n" "$path" 2>/dev/null
	done < "$Playlist" |
	    egrep -i "^$matchstring%" |
	    cut -d% -f2- > "$newlist"
    fi

    if [ -s "$newlist" ]
    then
	trap 0
	Msg "playlist is ready;" `wc -l < "$newlist"` "files"
	Playlist="$newlist"
    else
    	Fatal "found no matching files"
    fi
fi

if [ "$ListOnly" = "true" ]
then
    exec egrep -i "$*" "$Playlist"
fi

# The interrupt (trap) handling is complicated by having to deal
# with both ksh and the Bourne shell (sh).
#  o  ksh runs the "while read file" loop in the current process, and
#     therefore changing a variable from within the loop has an effect
#     on the surrounding loop, too.
#  o  the Bourne shell runs the "while" loop in a subshell, and changing
#     environment interrupts cannot terminate the surrounding "until"
#     loop.
# Instead of variables, we therefore use signals to let the inner loop
# terminate the outer one.

stopreading=false		# inner loop was terminated by a signal
interrupted=false		# outer loop should terminate
until $interrupted
do
    # Ignore SIGHUP SIGINT SIGQUIT. We will receive SIGTERM (15)
    # from the inner loop to notify us that the user wishes to terminate
    # the program.

    trap '' 1 2 3
    trap "interrupted=true" 15

    $interrupted && break

    egrep -i "$*" "$Playlist" |
    	    {
	    	egrep . || { Msg "no matching files: $*"; kill -15 $$; }
	    } |
	    shuffle |
	    while read file
	    do
	    	trap "stopreading=true" 1 2 3
		sleep 1
		$stopreading && { kill -15 $$; break; }

		[ -n "$file" ] || Fatal "cannot find song matching \"$*\""

		if [ -f "$file" ]
		then
		    $isxwindows && xtitle "`basename \"$file\"`"

		    # Relay all interrupts to the $player program, but
		    # continue execution nevertheless.  Note that "mpg123"
		    # catches two interrupts: the first terminates the song,
		    # the second terminates the program. A user therefore
		    # has to enter three interrupts to leave this script.
		    trap : 1 2 3
		    #player=echo
		    "$player" $playerflags "$file" || exit $?
		fi
	    done
done

trap 1 2 3 15			# Restore default trap handling

##########################################################################

# So the user really let us get here. Take advantage of that rare event
# and use it to clean up old playlists.

exitvalue=$?				# save return code

Msg "cleaning up..."
xtitle "$oldtitle"
cd "$PLAYLISTDIR" || exit $exitvalue

# Keep the $maxlistcnt most recent files, remove the rest.
# We do not use "| xargs rm -f" because this would not handle whitespace
# within file names.

ls -t | sed "1,${maxlistcnt}d" |
	while read path
	do rm -f "$path" >/dev/null 2>&1 || break
	done

exit $exitvalue