#!/bin/bash
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
# Copyright (C) 2015 Under <under@tripchan.org> Sun <solaire@tfwno.gf>
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.

ART=(a360 blow dance nightcall tea tits stun wall)

a360() {
echo -e "ｶﾞ━━━(ﾟДﾟ;)━(　ﾟД)━(　　ﾟ)━(　　 )━(ﾟ;　 )━(Дﾟ; )━(ﾟДﾟ;)━━━ﾝ!!!!!"
}

blow() {
echo -e "(# ')3')▃▃▃▅▆▇▉ﾌﾞｫｫｵボ！ﾌﾞｫｫｵボ"
}

dance() {
echo -e "☀ヽ(◕ω ◕｀ヽ)ｵﾊ♪(ﾉ◕ ω◕｀)ﾉﾖｳ♪ヽ(｀◕ ω ◕)ﾉｻﾝ♪☀"
}

nightcall() {
echo -e "　　　　　   /＼＿＿_／ヽ"
echo -e "　　　 ／''''''　　　'''''':::::::＼　　 ／￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
echo -e "　　 . |（●）,　　　､（●）      ､.:|　　＜　Tell me what makes you cry~"
echo -e "　　　  |   ,,ﾉ(､_, )ヽ､,, 　  .::::|　　＼＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿＿"
echo -e "　. 　 |　　 ｀-=ﾆ=- '　   .:::::::|"
echo -e "￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣￣"
}

rage() {
echo -e "���ಥ益ಥ）ﾉ ┻━┻"
}

tea() {
echo -e " ∧＿∧"
echo -e "( ´･ω･)"
echo -e "( つ旦O　 ∫∫"
echo -e "と＿)＿)　旦"
}

tits() {
echo -e "　 _ 　∩"
echo -e "(　ﾟ∀ﾟ)彡　BOOBIES! BOOBIES!"
echo -e "　 ⊂彡"
}

stun() {
echo -e "　  　∧  ∧"
echo -e "　  (,, ﾟДﾟ) ＜　Simply stunning, to say the least!"
echo -e "  　⊂ 　　⊃ "
echo -e "  ～| 　　| "
echo -e "　　 し'Ｊ"
}

show_help() {
echo -e 'Usage: \e[36m./art.sh \e[31m<art>'
echo -e '     \e[36m-l or --list:  \e[39mlist all available ART'
echo -e '     \e[36m-h or --help:  \e[39mshow this help. '
echo -e '     \e[36m-c or --copy:  \e[39mcopy the ART to your clipboard'
}

if [[ $# -eq 0 ]] ; then
    show_help
    exit 0
fi

case "$1" in
    -h|--help)
        show_help
        ;;
    -l|--list)
        echo -e '\e[36mAvailable art:\e[39m'
        printf -- '%s\n' "${ART[@]}"
        exit 0
        ;;
    -c|--copy)
        command -v xclip >/dev/null 2>&1 || { echo "You need to have xclip installed in order to use this." >&2; exit 0; }
        $2
        $2 | xclip -selection c
        ;;
    *)
        $1
        ;;
esac