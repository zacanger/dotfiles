#!/bin/bash

# Counts how often do you repeat a word. Counts words from STDIN. 
# The first and only argument is the word to be counted.

command -v awk >/dev/null 2>&1 || { echo "AWK not found. Please install it and try again"; exit 1; }

if [ -z $1 ]; then
    echo "Usage: repeats [word] <file>"
    echo "  [word] - word to be counted"
    echo "  <file> - file you want to count the occurrences of word in"
    echo "           If not specified, expects STDIN input"
    exit 1
fi

if [ -z $2 ]; then file=""; else file="$2"; fi

awk -v w=$1 '{for (i=1;i<=NF;i++) if ($i==w) n++} END {print n+0}' $file
