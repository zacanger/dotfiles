#! /bin/bash
#usage: ./autoprogramselector [view|edit|exec] filename

text_editor="xterm -e vim"
browser="dillo"
video="mplayer"
audio="mplayer"
pdf="mupdf"
image="viewnior"
doc="abiword"
sheet="gnumeric"

if [ $1 = help -o $1 = "-h" -o $1 = "--help" ]; then grep -E '^(#|view|edit|exec)' $0; exit 0; fi
if   [ $# -eq 1 ]; then 
    mode="view"; name="$1";
elif [ $# -eq 2 ]; then
    mode="$1";   name="$2";
else
    echo "wrong usage"; exit 1;
fi

#source 
if [[ $name =~ \.([ch]|txt|sh|s)$ ]]; then
view="$text_editor"
edit="$text_editor"
exec=""

#man     
elif [[ $name =~ \.[0-9](\.gz)?$ ]]; then
view="xman"
edit="$text_editor"
exec="xman"

#archive 
elif [[ $name =~ \.(tar|gz|rar|zip|7z|lha|bz2|tgz)$ ]]; then
view="atool -l"
edit=""
exec="atool -x"

#video 
elif [[ $name =~ \.(mkv|mpe?g|avi|mp4|wmv|rmvb|as[fx]|divx|vob|ogm|ra?m|flv|part|iso)$ ]]; then
view="$video"
edit=""
exec="$video"

#audio 
elif [[ $name =~ \.(mp3|wav|ogg)$ ]]; then
view="$audio"
edit=""
exec="$audio"

#torrent 
elif [[ $name =~ \.torrent ]]; then
view=""
edit=""
exec=""

#pdf     
elif [[ $name =~ \.(pdf|ps|PDF|PS)$ ]]; then
view="$pdf"
edit=""
exec="$pdf"

#image 
elif [[ $name =~ \.(jpe?g|png|gif|tiff|bmp|icon)$ ]]; then
view="$image"
edit="mtpaint"
exec="$image"

#html     
elif [[ $name =~ \.(html?|swf)$ ]]; then
view="$browser"
edit="$text_editor"
exec="$browser"

#document 
elif [[ $name =~ \.(doc|rtf)$ ]]; then
view="$doc"
edit="$doc"
exec="$doc"

#spreadsheet
elif [[ $name =~ \.(xls|cvs)$ ]]; then
view="$sheet"
edit="$sheet"
exec="$sheet"

#windows 
elif [[ $name =~ \.exe$ ]]; then
view=""
edit=""
exec="wine"

#regular file
else
view="$text_editor"
edit="$text_editor"
exec="$text_editor"
fi

#executable (overrides)
if [ -x "$name" ]; then
exec="exec"
fi

#make it so
if [ -n "${!mode} $name" ]; then
setsid setsid ${!mode} "$name"
fi
