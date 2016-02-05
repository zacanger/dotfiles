#!/bin/bash

awk '{ print $1 != "sudo" ? $1 : $2 }' ~/.bash_history |
sort |
uniq -c |
sort -rn |
grep -E --color=never '^ *[0-9]{2,}' |
less -FX
