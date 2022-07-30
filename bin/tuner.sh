#!/usr/bin/env bash
set -e

# this requires sox

# my guitars are usually tuned to dadgad
# my bass is a 6-string, and i tune it b-b (like a baritone guitar down an
# octave)

dadgad='D2 A2 D3 G3 A3 D4'
standard='E2 A2 D3 G3 B3 E4'
bass='B0 E1 A1 D2 F#2 B2'

tuning="$dadgad"
while getopts dsb opt; do
    case $opt in
        d) tuning="$dadgad";;
        s) tuning="$standard";;
        b) tuning="$bass";;
        *) echo '-d, -s, or -b for dadgad, standard, or bass!'; exit 1;;
    esac
done

echo "$tuning"

for n in $tuning; do
    play -n synth 4 pluck "$n" repeat 3
done
