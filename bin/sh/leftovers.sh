#! /bin/sh

for i in {/usr,~/.local}/share/applications/*.desktop; do which $(grep -Poh '(?<=Exec=).*?( |$)' $i) > /dev/null || echo $i; done