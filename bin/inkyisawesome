#!/bin/sh
#This was before auto-meme a). changed address and b). got a real API
#meme (){ wget http://lolwut.boxofjunk.net/raw?0 -qO - -o /dev/null | sed 's/<\/\?em>/*/g'; }
meme () { wget http://meme.boxofjunk.ws/moar.txt?lines=1 -qO -; }
if [ -f ~/.nextmeme ]; then
    meme="$(cat ~/.nextmeme)"
    rm -f ~/.nextmeme # yes I know this is a race condition. I'm lazy.
else
    meme="$(meme)"
fi
echo "$meme"

{ newmeme=$(meme); echo "$newmeme" > ~/.nextmeme; } &
