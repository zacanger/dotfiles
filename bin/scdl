#!/bin/bash
# Author: FlyinGrub
# Check my github : https://github.com/flyingrub
# Share it if you like ;)
##############################################################

echo ' *---------------------------------------------------------------------------*'
echo '|               SoundcloudMusicDownloader           |   FlyinGrub rework      |'
echo ' *---------------------------------------------------------------------------*'

function CURL(){ # Just a code shortcut
    curl -L -s --user-agent 'Mozilla/5.0' "$1"
}

function log() { # Logging function
	local level
	level="$1"; shift
	if [[ "$level" -le "$logVerbosity" ]] ; then
		case "$level" in
			0)
				;;
			1)
				echo -n "[e]"; ;;
			2)
				echo -n "[w]"; ;;
			3)
				echo -n "[i]"; ;;
			4)
				echo -n "[d]"; ;;
		esac
		echo " $@";
	fi
}

function settags() { # Set the mp3 tags
    local artist=$1
    local title=$2
    local filename=$3
    local genre=$4
    local imageurl=$5
    local album=$6

    curl -s -L --user-agent 'Mozilla/5.0' "$imageurl" -o "/tmp/1.jpg"

    if [ "$writags" = "1" ] ; then
        eyeD3 --remove-all "$filename" &>/dev/null
        eyeD3 --add-image="/tmp/1.jpg:ILLUSTRATION" \
            --add-image="/tmp/1.jpg:OTHER" \
            --add-image="/tmp/1.jpg:MEDIA" \
            --add-image="/tmp/1.jpg:ICON" \
            --add-image="/tmp/1.jpg:MEDIA" \
            --add-image="/tmp/1.jpg:OTHER_ICON" \
            --add-image="/tmp/1.jpg:FRONT_COVER" \
            --artist="$artist" -Y $(date +%Y) --genre="$genre" \
            --title="$title" --album="$album" --v2 "$filename" &>/dev/null

        log 3 "Setting tags finished!"
    else
        log 3 "Setting tags skipped (please install eyeD3)"
    fi
}

function downsong() { # Parse json for one song
    url="$1"
    log 3 "Grabbing artists page"
    log 4 "https://api.soundcloud.com/resolve.json?url=$url&client_id=$clientID"
    songID=$(CURL "https://api.soundcloud.com/resolve.json?url=$url&client_id=$clientID" | tr "," "\n" | sed -n "2p" | cut -d ':' -f 2)
    log 4 "songID is : $songID"
    fromjsontomp3 "$songID" "$clientID"
}

function fromjsontomp3 { # use the json to download info and mp3
    clientID="$2"
    songID="$1"
    log 4 "https://api.soundcloud.com/tracks/$songID.json?client_id=$clientID"
    songinfo=$(CURL "https://api.soundcloud.com/tracks/$songID.json?client_id=$clientID" | tr "," "\n")
    title=$(printf "%s\n" "$songinfo" | grep '"title"' | cut -c 10- | rev | cut -c 2- | rev | tr '\/:*?|<>' '________' )
    songurl=$(echo -e "$songinfo" | grep "stream_url" | cut -d '"' -f 4)
    realsongurl=$(echo -e "$songurl?client_id=$clientID")
    artist=$(echo -e "$songinfo" | grep "username" | cut -d '"' -f 4)
    if [[ $title =~ "$artist" ]] ; then 
        filename=$(printf "%s.mp3" "$title")
    else
        filename=$(printf "%s - %s.mp3" "$artist" "$title")
    fi
    imageurl=$(echo -e "$songinfo" | grep "artwork_url" | cut -d '"' -f 4 | sed 's/large/t500x500/g')
    genre=$(echo -e "$songinfo" | grep "genre" | cut -d '"' -f 4)
    songpermalink=$(echo -e "$songinfo" | grep -m2 "permalink_url" | tail -n1 | cut -d '"' -f 4)
	log 4 "Track permalink_url : $songpermalink"

    if [ -e "$filename" ]; then
        log 1 "The song $filename has already been downloaded..."  && $cont
    else
        echo "[-] Downloading $title..."
        curl -# -L --user-agent 'Mozilla/5.0' -o "`echo -e "$filename"`" "$realsongurl"
        settags "$artist" "$title" "$filename" "$genre" "$imageurl"
        echo -e "[i] Downloading of $filename finished"
    fi
}

function downlike()  { # Parse json for all user's like
    log 3 "Grabbing artist's likes page"
    artistnm=$(echo "$1" | cut -d '/' -f 4)
    likeurl=$(echo "https://soundcloud.com/$artistnm")
    log 4 "https://api.soundcloud.com/resolve.json?url=$likeurl&client_id=$clientID"
    artistID=$(CURL "https://api.soundcloud.com/resolve.json?url=$likeurl&client_id=$clientID" | tr "," "\n" | sed -n "1p" | cut -d ':' -f 2)
    log 4 "artistID is : $artistID"
    offset=$default_offset
    likepage=$(CURL "https://api.soundcloud.com/users/$artistID/favorites.json?client_id=$clientID&limit=1&offset=$offset")
    while [[ $(echo "$likepage" | grep 'id') != '' ]]
    do
        log 4 "https://api.soundcloud.com/users/$artistID/favorites.json?client_id=$clientID&limit=1&offset=$offset"
        setsongID=$(echo "$likepage" | tr "," "\n" | grep '"uri"' | grep 'tracks' | cut -d '"' -f 4 | cut -d '/' -f 5)
        ((offset++))
        echo ""
        log 3 "Song liked n°$offset by $artistnm"
        fromjsontomp3 "$setsongID" "$clientID"
        likepage=$(CURL "https://api.soundcloud.com/users/$artistID/favorites.json?client_id=$clientID&limit=1&offset=$offset")
    done
    echo ""
    log 3 "There was $offset songs."
}

function downset() { # Parse json for one user's set
    log 4 "https://api.soundcloud.com/playlists/$playlistID.json?limit=1&offset=$setOffset&client_id=$clientID"
    log 3 "Grabbing set page"
    url="$1"
    setpage=$(CURL $url)
    log 4 "https://api.soundcloud.com/resolve.json?url=$url&client_id=$clientID"
    playlistID=$(CURL "https://api.soundcloud.com/resolve.json?url=$url&client_id=$clientID" | tr "," "\n" | grep 'https://api.soundcloud.com/playlists' | cut -d '/' -f 5)
    log 4 "playlistID is : $playlistID"

    setOffset=0
    setpage=$(CURL "https://api.soundcloud.com/playlists/$playlistID.json?limit=1&offset=$setOffset&client_id=$clientID")
    setTitle=$(echo "$setpage" | tr "{" "\n" | grep '"playlist"' | tr "," "\n" | grep '"title"' | cut -d '"' -f 4)
    trackExist=$(echo "$setpage" | tr "," "\n" | grep '"tracks"' | cut -d ':' -f 2)
    while [[ "$trackExist" != '[]' && "$trackExist" != '' ]]
    do
        setsongID=$(echo "$setpage" | tr "," "\n" | grep '"uri"' | grep 'tracks' | cut -d '"' -f 4 | cut -d '/' -f 5)
        ((setOffset++))
        echo ""
        log 3 "Song n°$setOffset from the Set : $setTitle"
        fromjsontomp3 "$setsongID" "$clientID"
        setpage=$(CURL "https://api.soundcloud.com/playlists/$playlistID.json?limit=1&offset=$setOffset&client_id=$clientID")
        trackExist=$(echo "$setpage" | tr "," "\n" | grep '"tracks"' | cut -d ':' -f 2)
    done
    echo ""
    log 3 "There was $setOffset songs in the set $setTitle."
}

function downallsongs() { # Parse json for all user's songs
    url="$1"
    log 3 "Grabbing artists page"
    page=$(CURL $url)
    artistID=$(CURL "https://api.soundcloud.com/resolve.json?url=$url&client_id=$clientID" | tr "," "\n" | sed -n "1p" | cut -d ':' -f 2)
    echo ""

    offset=$default_offset
    artistpage=$(CURL "https://api.sndcdn.com/e1/users/$artistID/sounds.json?limit=1&offset=$offset&client_id=$clientID")
    while [[ $(echo "$artistpage" | grep 'id') != '' ]]
    do
        playlist=$(echo "$artistpage" | tr "," "\n" | grep '"playlist"' | cut -c 14-)
        ((offset++))
        if [[ "$playlist" != "null" ]]; then
            log 3 "The n°$offset is a playlist"
            thisset=$(echo "$artistpage" | tr "," "\n" | grep '"permalink_url"' | sed -n 1p | cut -d '"' -f 4)
            downset "$thisset"
        else
            echo ""
            log 3 "Song n°$offset"
            typesong=$(echo "$artistpage" | tr "," "\n" | grep '"type"' | cut -d '"' -f 4)
            if [[ "$typesong" == "track" ]] && [[ "$onlyrepost" == "0" ]] ; then
                artistsongurl=$(echo "$artistpage" | tr "," "\n" | grep 'permalink_url' | sed '1d' | cut -d '"' -f 4)
                downsong "$artistsongurl"
            elif [[ "$typesong" == "playlist" ]] && [[ "$onlyrepost" == "0" ]]; then
                artistsongurl=$(echo "$artistpage" | tr "," "\n" | grep 'permalink_url' | cut -d '"' -f 4)
                downset "$artistsongurl"
            elif [[ "$typesong" == "playlist_repost" ]]; then
                artistsongurl=$(echo "$artistpage" | tr "," "\n" | grep 'permalink_url' | cut -d '"' -f 4)
                downset "$artistsongurl"
            elif [[ "$typesong" == "track_repost" ]]; then
                artistsongurl=$(echo "$artistpage" | tr "," "\n" | grep 'permalink_url' | sed '1d' | cut -d '"' -f 4)
                downsong "$artistsongurl"
            fi
        fi
        artistpage=$(CURL "https://api.sndcdn.com/e1/users/$artistID/sounds.json?limit=1&offset=$offset&client_id=$clientID")
    done
    echo ""
    log 3 "There was $offset songs/sets."
}

function downallsets() { # Parse json for all user's sets
    artistnm=$(echo "$1" | cut -d '/' -f 4)
    seturl=$(echo "https://soundcloud.com/$artistnm")
    log 3 "Grabbing artist's set page"
    page=$(CURL $seturl)

    log 4 "https://api.soundcloud.com/resolve.json?url=$seturl&client_id=$clientID"
    artistID=$(CURL "https://api.soundcloud.com/resolve.json?url=$seturl&client_id=$clientID"  | tr "," "\n" | sed -n "1p" | cut -d ':' -f 2)
    log 4 "artistID is : $artistID"
    all_offset=0
    allsetpage=$(CURL "https://api.soundcloud.com/users/$artistID/playlists.json?limit=1&offset=$all_offset&client_id=$clientID")
    while [[ $(echo "$allsetpage" | grep 'id') != '' ]]
    do
        thisset=$(echo "$allsetpage" | tr "," "\n" | grep '"permalink_url"'  | sed -n 1p | cut -d '"' -f 4)
        ((all_offset++))
        echo ""
        log 3 "Set n°$all_offset from $artistnm"
        downset "$thisset"
        log 3 "Set n°$all_offset from $artistnm downloaded"
        allsetpage=$(CURL "https://api.soundcloud.com/users/$artistID/playlists.json?limit=1&offset=$all_offset&client_id=$clientID")
    done
    echo ""
    log 3 "There was $all_offset sets."
}

function downgroup() { # Parse json for a group
    groupurl="$1"
    log 3 "Grabbing group page"
    groupage=$(CURL "$groupurl")
    groupid=$(echo "$groupage" | grep "html5-code-groups" | tr " " "\n" | grep "html5-code-groups-" | cut -d '"' -f 2 | sed '2d' | cut -d '-' -f 4)
    trackspage=$(CURL "https://api.soundcloud.com/groups/$groupid/tracks.json?client_id=$clientID" | tr "}" "\n")
    trackspage=$(echo "$trackspage" | tr "," "\n" | grep 'permalink_url' | sed '1d' | sed -n '1~2p')
    songcount=$(echo "$trackspage" | wc -l)
    log 3 "Found $songcount songs!"
    for (( i=1; i <= $songcount; i++ ))
    do
        echo -e "\n---------- Downloading Song n°$i ----------"
        thisongurl=$(echo "$trackspage" | sed -n "$i"p | cut -d '"' -f 4)
        downsong "$thisongurl"
        echo "----- Downloading Song n°$i finished ------"
    done
}

function show_help() { # Display some help
    all=$1
    echo ""
    log 3 "Usage: scdl [OPTION] -l [URL]"
    echo "    With url like :"
    echo "        https://soundcloud.com/user (Download all of one user's songs)"
    echo "        https://soundcloud.com/user/song-name (Download one single song)"
    echo "        https://soundcloud.com/user/sets (Download all of one user's sets)"
    echo "        https://soundcloud.com/user/sets/set-name (Download one single set)"
    if [[ "$all" == "full" ]]; then
        echo ""
        echo ""
        echo "OPTION :"
        echo ""
        echo "  -l [URL]        Use this Url. (Necessary) "
        echo "  -o [OFFSET]     Begin the download with a custom offset."
        echo "  -p [PATH]       Use a custom path for this time."
        echo "  -c              Script will continue if a sound as already been downloaded."
        echo "  -r              Download only the repost."
        echo "  -d              Debug."
        echo "  -q              Quiet, only warnings and errors."
        echo "  -h              Show this help."
    else
        echo ""
        echo "Try « scdl -h » for more information."
    fi
}

function get_arg() { # Parse arguments
    while getopts "cro:l:p:hdq" opt
    do
        case $opt in
            h)
                show_help full; exit 1
                ;;
            c)
                cont=":"
                continue_info='continue'
                ;;
            r)
                onlyrepost=1
                ;;
            o) # Need argument
                default_offset=$OPTARG
                if ! [[ $default_offset =~ $number ]] ; then
                    log 1 "Offset should be a number"; exit 1
                fi
                ;;
            l) # Need argument
                userLink=$OPTARG
                ;;
            p) # Need argument
                if [ -d "$OPTARG" ]; then
                    pathtomusic="$OPTARG"
                else
                    log 1 "Directory specified does not exist."; show_help; exit 1
                fi
                ;;
            d) # debug
                logVerbosity=4
                ;;
            q) # quiet
                logVerbosity=2
                ;;
            \?)
                show_help; exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))
    [[ "$userLink" == '' ]] && log 1 "You need to specify the URL" && show_help && exit 1
}

function config() { # Check for the path where download music
    if [ -f "/$HOME/.scdl.cfg" ]; then
        source "/$HOME/.scdl.cfg"
    else
        log 1 "The config file does not exist..."
        log 1 "Please run the Installer first or add the sample config file"
        exit
    fi
}

function init() { # Init some variable
    writags=1
    default_offset=0
    onlyrepost=0
    cont=exit
    continue_info='exit'
    number='^[0-9]+$'
	logVerbosity=3
}

function check_sys() { # Check system for curl & eyed3
    command -v curl &>/dev/null || { log 1 "cURL needs to be installed in order to run the script."; log 1 "The script will exit..."; exit 1; }
    command -v eyeD3 &>/dev/null || { log 1 "eyeD3 needs to be installed to write tags into mp3 file."; log 2 "The script will skip this part..."; writags=0; }
    log 4 "Using" `curl -V` | cut -c-21
}

# Launch function
init
config
get_arg $@
check_sys

# Go to path
cd "$pathtomusic"

# Play with the soundcloud url
soundurl=$(echo "$userLink" | sed 's-.*soundcloud.com/-https://soundcloud.com/-' | cut -d "?" -f 1)
log 3 "Using URL : $soundurl"
d1="$(echo "$soundurl" | cut -d "/" -f 4)"
d2="$(echo "$soundurl" | cut -d "/" -f 5)"
d3="$(echo "$soundurl" | cut -d "/" -f 6)"

# Display info of the current configuration
log 3 "Path where i will download music : $pathtomusic"
log 3 "I will $continue_info if i found a file that already exist"
[[ "$onlyrepost" == '1' ]] && log 3 "I will only download reposted sound"
[[ "$default_offset" != '0' ]] && log 3 "I will begin the download at $default_offset sound"
log 4 "Using clientID : $clientID"
log 4 "Using "`eyeD3 --version  2>&1 | grep -m1 eye | cut -d " " -f -2`

# Choose the right URL type
if [[ "$d1" == "" ]] ; then
    log 1 "Bad URL!"
    show_help
    exit 1
elif [[ "$d1" == "groups" ]] ; then
    log 3 "Detected download type : All song of the group"
    downgroup "$soundurl"
elif [[ "$d2" == "likes" ]] ; then
    log 3 "Detected download type : All of one user's like"
    downlike "$soundurl"
elif [[ "$d2" == "" ]] ; then
    log 3 "Detected download type : All of one user's songs"
    [[ "$onlyrepost" == 1 ]] && log 3 "Only the repost will be downloaded"
    downallsongs "$soundurl"
elif [[ "$d2" == "sets" ]] && [[ "$d3" == "" ]] ; then
    log 3 "Detected download type : All of one user's sets"
    downallsets "$soundurl"
elif [[ "$d2" == "sets" ]] ; then
    log 3 "Detected download type : One single set"
    downset "$soundurl"
else
    log 3 "Detected download type : One single song"
    downsong "$soundurl"
fi
