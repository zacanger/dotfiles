#!/bin/bash
# Author: FlyinGrub
# Check my github : https://github.com/flyingrub/soundcloud-dl
# Share it if you like ;)
##############################################################

echo ''
echo ' *---------------------------------------------------------------------------*'
echo '|      SoundcloudMusicDownloader(cURL/Wget version) |   FlyinGrub rework      |'
echo ' *---------------------------------------------------------------------------*'

function settags() {
    artist=$1
    title=$2
    filename=$3
    genre=$4
    imageurl=$5
    album=$6
    if $curlinstalled; then
        curl -s -L --user-agent 'Mozilla/5.0' "$imageurl" -o "/tmp/1.jpg"
    else
        wget --max-redirect=1000 --trust-server-names -U 'Mozilla/5.0' -O "/tmp/1.jpg" "$imageurl"
    fi
    if [ "$writags" = "1" ] ; then
        eyeD3 --remove-all "$filename" &>/dev/null
        eyeD3 --add-image="/tmp/1.jpg:ILLUSTRATION" --add-image="/tmp/1.jpg:ICON" -a "$artist" -Y $(date +%Y) -G "$genre" -t "$title" -A "$album" -2 --force-update "$filename" &>/dev/null
        echo '[i] Setting tags finished!'
    else
        echo "[i] Setting tags skipped (please install eyeD3)"
    fi
}

function downsong() { #Done!
    # Grab Info
    url="$1"
    echo "[i] Grabbing song page"
    if $curlinstalled; then
        page=$(curl -s -L --user-agent 'Mozilla/5.0' "$url")
    else
        page=$(wget --max-redirect=1000 --trust-server-names --progress=bar -U -O- 'Mozilla/5.0' "$url")
    fi
    id=$(echo "$page" | grep -v "small" | grep -oE "data-sc-track=.[0-9]*" | grep -oE "[0-9]*" | sort | uniq)
    title=$(echo -e "$page" | grep -A1 "<em itemprop=\"name\">" | tail -n1 | sed 's/\\u0026/\&/g' | recode html..u8)
    filename=$(echo "$title".mp3 | tr '*/\?"<>|' '+       ' )
    songurl=$(curl -s -L --user-agent 'Mozilla/5.0' "https://api.sndcdn.com/i1/tracks/$id/streams?client_id=$clientID" | cut -d '"' -f 4 | sed 's/\\u0026/\&/g')
    artist=$(echo "$page" | grep byArtist | sed 's/.*itemprop="name">\([^<]*\)<.*/\1/g' | recode html..u8)
    imageurl=$(echo "$page" | tr ">" "\n" | grep -A1 '<div class="artwork-download-link"' | cut -d '"' -f 2 | tr " " "\n" | grep 'http' | sed 's/original/t500x500/g' | sed 's/png/jpg/g' )
    genre=$(echo "$page" | tr ">" "\n" | grep -A1 '<span class="genre search-deprecation-notification" data="/tags/' | tr ' ' "\n" | grep '</span' | cut -d "<" -f 1 | recode html..u8)
    # DL
    echo ""
    if [ -e "$filename" ]; then
        echo "[!] The song $filename has already been downloaded..."  && exit
    else
        echo "[-] Downloading $title..."
    fi
    if $curlinstalled; then
        curl -# -L --user-agent 'Mozilla/5.0' -o "`echo -e "$filename"`" "$songurl";
    else
        wget --max-redirect=1000 --trust-server-names -U 'Mozilla/5.0' -O "`echo -e "$filename"`" "$songurl";
    fi
    settags "$artist" "$title" "$filename" "$genre" "$imageurl"
    echo "[i] Downloading of $filename finished"
    echo ''
}

function downallsongs() {
    # Grab Info
    url="$1"
    echo "[i] Grabbing artists page"
    if $curlinstalled; then
        page=$(curl -L -s --user-agent 'Mozilla/5.0' $url)
    else
        page=$(wget --max-redirect=1000 --trust-server-names -q -U 'Mozilla/5.0' $url)
    fi
    clientID=$(echo "$page" | grep "clientID" | tr "," "\n" | grep "clientID" | cut -d '"' -f 4)
    artistID=$(echo "$page" | tr "," "\n" | grep "trackOwnerId" | head -n 1 | cut -d ":" -f 2) 
    echo "[i] Grabbing all song info"
    if $curlinstalled; then
        songs=$(curl -s -L --user-agent 'Mozilla/5.0' "https://api.sndcdn.com/e1/users/$artistID/sounds?limit=256&offset=0&linked_partitioning=1&client_id=$clientID" | tr -d "\n" | sed 's/<stream-item>/\n/g' | sed '1d' )
    else 
        songs=$(wget -q --max-redirect=1000 --trust-server-names -O- -U 'Mozilla/5.0' "https://api.sndcdn.com/e1/users/$artistID/sounds?limit=256&offset=0&linked_partitioning=1&client_id=$clientID" | tr -d "\n" | sed 's/<stream-item>/\n/g' | sed '1d')
    fi
    songcount=$(echo "$songs" | wc -l)
    echo "[i] Found $songcount songs! (200 is max)"
    if [ -z "$songs" ]; then
        echo "[!] No songs found at $1" && exit
    fi
    echo ""
    for (( i=1; i <= $songcount; i++ ))
    do
        playlist=$(echo -e "$songs"| sed -n "$i"p | tr ">" "\n" | grep "</kind" | cut -d "<" -f 1 | grep playlist)
        if [ "$playlist" = "playlist" ] ; then 
            playlisturl=$(echo -e "$songs" | sed -n "$i"p | tr ">" "\n" | grep "</permalink-url" | cut -d "<" -f 1 | head -n 1 | recode html..u8)
            echo "[i] *--------Donwloading a set----------*"
            downset $playlisturl
            echo "[i] *-------- Set Downloaded -----------*"
            echo ''
        else
            title=$(echo -e "$songs" | sed -n "$i"p | tr ">" "\n" | grep "</title" | cut -d "<" -f 1 | recode html..u8)
            filename=$(echo "$title".mp3 | tr '*/\?"<>|' '+       ' )
            if [ -e "$filename" ]; then
                echo "[!] The song $filename has already been downloaded..."  && exit
            fi
            artist=$(echo "$songs" | sed -n "$i"p | tr ">" "\n" | grep "</username" | cut -d "<" -f 1 | recode html..u8)
            genre=$(echo "$songs" | sed -n "$i"p | tr ">" "\n" | grep "</genre" | cut -d "<" -f 1 | recode html..u8)
            imageurl=$(echo "$songs" | sed -n "$i"p | tr ">" "\n" | grep "</artwork-url" | cut -d "<" -f 1 | sed 's/large/t500x500/g')
            songID=$(echo "$songs" | sed -n "$i"p | tr " " "\n" | grep "</id>" | head -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1)
            # DL
            echo "[-] Downloading the song $title..."
            if $curlinstalled; then
               songurl=$(curl -s -L --user-agent 'Mozilla/5.0' "https://api.sndcdn.com/i1/tracks/$songID/streams?client_id=$clientID" | cut -d '"' -f 4 | sed 's/\\u0026/\&/g')
            else
                songurl=$(wget -q --max-redirect=1000 --trust-server-names -O- -U 'Mozilla/5.0' "https://api.sndcdn.com/i1/tracks/$songID/streams?client_id=$clientID" | cut -d '"' -f 4 | sed 's/\\u0026/\&/g')
            fi
            if $curlinstalled; then
                curl -# -L --user-agent 'Mozilla/5.0' -o "`echo -e "$filename"`" "$songurl";
            else
                wget --max-redirect=1000 --trust-server-names -U 'Mozilla/5.0' -O "`echo -e "$filename"`" "$songurl";
            fi
            settags "$artist" "$title" "$filename" "$genre" "$imageurl"
            echo "[i] Downloading of $filename finished"
            echo ''
        fi
    done
}

function downgroup() {
    groupurl="$1"
    echo "[i] Grabbing group page"
    if $curlinstalled; then
        groupage=$(curl -L -s --user-agent 'Mozilla/5.0' "$groupurl")
    else
        groupage=$(wget --max-redirect=1000 --trust-server-names --progress=bar -U -O- 'Mozilla/5.0' "$groupurl")
    fi
    groupid=$(echo "$groupage" | grep "html5-code-groups" | tr " " "\n" | grep "html5-code-groups-" | cut -d '"' -f 2 | sed '2d' | cut -d '-' -f 4)
    clientID=$(echo "$groupage" | grep "clientID" | tr "," "\n" | grep "clientID" | cut -d '"' -f 4)
    trackspage=$(curl -L -s --user-agent 'Mozilla/5.0' "http://api.soundcloud.com/groups/$groupid/tracks.json?client_id=$clientID" | tr "}" "\n")
    trackspage=$(echo "$trackspage" | tr "," "\n" | grep '"permalink_url":' | sed '1d' | sed -n '1~2p')
    songcount=$(echo "$trackspage" | wc -l)
    echo "[i] Found $songcount songs!"
    for (( i=1; i <= $songcount; i++ ))
    do
        echo ''
        echo "---------- Downloading Song n°$i ----------"
        thisongurl=$(echo "$trackspage" | sed -n "$i"p | cut -d '"' -f 4)
        downsong "$thisongurl"
        echo "----- Downloading Song n°$i finished ------"
    done
}

function downset() {
    # Grab Info
    echo "[i] Grabbing set page"
    url="$1"
    if $curlinstalled; then
        page=$(curl -L -s --user-agent 'Mozilla/5.0' $url)
    else
        page=$(wget --max-redirect=1000 --trust-server-names --progress=bar -U -O- 'Mozilla/5.0' "$url")
    fi
    settitle=$(echo -e "$page" | grep -A1 "<em itemprop=\"name\">" | tail -n1) 
    setsongs=$(echo "$page" | grep -oE "data-sc-track=.[0-9]*" | grep -oE "[0-9]*" | sort | uniq) 
    echo "[i] Found set "$settitle""
    if [ -z "$setsongs" ]; then
        echo "[!] No songs found"
        exit 1
    fi
    songcountset=$(echo "$setsongs" | wc -l)
    echo "[i] Found $songcountset songs"
    echo ""
    for (( numcursong=1; numcursong <= $songcountset; numcursong++ ))
    do
        id=$(echo "$setsongs" | sed -n "$numcursong"p)
        title=$(echo -e "$page" | grep data-sc-track | grep $id | grep -oE 'rel=.nofollow.>[^<]*' | sed 's/rel="nofollow">//' | sed 's/\\u0026/\&/g' | recode html..u8)
        if [[ "$title" == "Play" ]] ; then
        title=$(echo -e "$page" | grep $id | grep id | grep -oE "\"title\":\"[^\"]*" | sed 's/"title":"//' | sed 's/\\u0026/\&/g' | recode html..u8)
        fi
        artist=$(echo "$page" | grep -A3 $id | grep byArtist | cut -d"\"" -f2 | recode html..u8)
        filename=$(echo "$title".mp3 | tr '*/\?"<>|' '+       ' )      
        if [ -e "$filename" ]; then
            echo "[!] The song $filename has already been downloaded..."  && exit
        else
            echo "[-] Downloading $title..."
        fi
        #----------settags-------#
        pageurl=$(echo "$page" | grep -A3 $id | grep url | cut -d"\"" -f2)
        if $curlinstalled; then
        songpage=$(curl -s -L --user-agent 'Mozilla/5.0' "$pageurl")
        else
        songpage=$(wget --max-redirect=1000 --trust-server-names --progress=bar -U -O- 'Mozilla/5.0' "$pageurl")
        fi
        imageurl=$(echo "$songpage" | tr ">" "\n" | grep -A1 '<div class="artwork-download-link"' | cut -d '"' -f 2 | tr " " "\n" | grep 'http' | sed 's/original/t500x500/g' | sed 's/png/jpg/g' )
        genre=$(echo "$songpage" | tr ">" "\n" | grep -A1 '<span class="genre search-deprecation-notification" data="/tags/' | tr ' ' "\n" | grep '</span' | cut -d "<" -f 1 | recode html..u8)
        album=$(echo "$page" | sed s/'<meta content='/\n/g | grep 'property="og:title"' | cut -d '=' -f 4 | cut -d '"' -f 4 | recode html..u8)
        #------------------------#
        # DL
        if $curlinstalled; then
            songurl=$(curl -s -L --user-agent 'Mozilla/5.0' "https://api.sndcdn.com/i1/tracks/$id/streams?client_id=$clientID" | cut -d '"' -f 4 | sed 's/\\u0026/\&/g')
        else
            songurl=$(wget -q --max-redirect=1000 --trust-server-names -U -O- 'Mozilla/5.0' "https://api.sndcdn.com/i1/tracks/$id/streams?client_id=$clientID" | cut -d '"' -f 4 | sed 's/\\u0026/\&/g')
        fi
        if $curlinstalled; then
            curl -# -L --user-agent 'Mozilla/5.0' -o "`echo -e "$filename"`" "$songurl";
        else
            wget --max-redirect=1000 --trust-server-names -U 'Mozilla/5.0' -O "`echo -e "$filename"`" "$songurl";
        fi
        settags "$artist" "$title" "$filename" "$genre" "$imageurl" "$album"
        echo "[i] Downloading of $filename finished"
        echo ''
    done
}

function downallsets() {
    allsetsurl="$1"
    echo "[i] Grabbing user sets page"
    if $curlinstalled; then
        allsetspage=$(curl -L -s --user-agent 'Mozilla/5.0' "$allsetsurl")
    else
        allsetspage=$(wget --max-redirect=1000 --trust-server-names --progress=bar -U -O- 'Mozilla/5.0' "$allsetsurl")
    fi
    allsetsnumpages=$(echo "$allsetspage" | grep '<li class="set">' | wc -l)
    echo "[i] $allsetsnumpages sets pages found"
    for (( allsetsnumcurpage=1; allsetsnumcurpage <= $allsetsnumpages; allsetsnumcurpage++ ))
    do
        echo "   [i] Grabbing user sets page $allsetsnumcurpage"
        if $curlinstalled; then
            allsetspage=$(curl -L --user-agent 'Mozilla/5.0' "$allsetsurl?page=$allsetsnumcurpage")
        else
            allsetspage=$(wget --max-redirect=1000 --trust-server-names --progress=bar -U -O- 'Mozilla/5.0' "$allsetsurl?page=$allsetsnumcurpage")
        fi
        allsetssets=$(echo "$allsetspage" | grep -A1 "li class=\"set\"" | grep "<h3>" | sed 's/.*href="\([^"]*\)">.*/\1/g')
        if [ -z "$allsetssets" ]; then
            echo "[!] No sets found on user sets page $allsetsnumcurpage"
            continue
        fi
        allsetssetscount=$(echo "$allsetssets" | wc -l)
        echo "[i] Found $allsetssetscount set(s) on user sets page $allsetsnumcurpage"
        for (( allsetsnumcurset=1; allsetsnumcurset <= $allsetssetscount; allsetsnumcurset++ ))
        do
            allsetsseturl=$(echo "$allsetssets" | sed -n "$allsetsnumcurset"p)
            echo "*-------- Downloading set n°$allsetsnumcurset ----------*"
            downset "http://soundcloud.com$allsetsseturl"
            echo "*-------- Set n°$allsetsnumcurset Downloaded -----------*"
        done
    done
}

function show_help() {
    echo ""
    echo "[i] Usage: `basename $0` [url]"
    echo "    With url like :"
    echo "        http://soundcloud.com/user (Download all of one user's songs)"
    echo "        http://soundcloud.com/user/song-name (Download one single song)"
    echo "        http://soundcloud.com/user/sets (Download all of one user's sets)"
    echo "        http://soundcloud.com/user/sets/set-name (Download one single set)"
    echo ""
    echo "   Downloaded file names like : "title.mp3""
    echo ""
}

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
    show_help
    exit 1
fi

clientID="b45b1aa10f1ac2941910a7f0d10f8e28"
writags=1
curlinstalled=`command -V curl &>/dev/null`
wgetinstalled=`command -V wget &>/dev/null`

if $curlinstalled; then
  echo "[i] Using" `curl -V` | cut -c-21
elif $wgetinstalled; then
  echo "[i] Using" `wget -V` | cut -c-24
  echo "[i] cURL is preferred" 
else
  echo "[!] cURL or Wget need to be installed."; exit 1;
fi

command -v recode &>/dev/null || { echo "[!] Recode needs to be installed."; exit 1; }
command -v eyeD3 &>/dev/null || { echo "[!] eyeD3 needs to be installed to write tags into mp3 file."; echo "[!] The script will skip this part..."; writags=0; }

soundurl=$(echo "$1" | sed 's-.*soundcloud.com/-http://soundcloud.com/-' | cut -d "?" -f 1 | grep 'soundcloud.com')

echo "[i] Using URL $soundurl"

if [[ "$(echo "$soundurl" | cut -d "/" -f 4)" == "" ]] ; then
    echo "[!] Bad URL!"
    show_help 
    exit 1
elif [[ "$(echo "$soundurl" | cut -d "/" -f 4)" == "groups" ]] ; then
    echo "[i] Detected download type : All song of the group"
    downgroup "$soundurl"
elif [[ "$(echo "$soundurl" | cut -d "/" -f 5)" == "" ]] ; then
    echo "[i] Detected download type : All of one user's songs"
    downallsongs "$soundurl"
elif [[ "$(echo "$soundurl" | cut -d "/" -f 5)" == "sets" ]] && [[ "$(echo "$soundurl" | cut -d "/" -f 6)" == "" ]] ; then
    echo "[i] Detected download type : All of one user's sets"
    downallsets "$soundurl"
elif [[ "$(echo "$soundurl" | cut -d "/" -f 5)" == "sets" ]] ; then
    echo "[i] Detected download type : One single set"
    downset "$soundurl"
else
    echo "[i] Detected download type : One single song"
    downsong "$soundurl"
fi
