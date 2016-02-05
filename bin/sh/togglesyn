#!/usr/bin/env bash

cmd='synclient TouchpadOff='

[[ $(
    synclient |
    grep '^\s*TouchpadOff' |
    awk '{print $3}'
) == 0 ]] &&
${cmd}1 ||
${cmd}0

