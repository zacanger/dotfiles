#!/bin/bash

# wathces the passed directory every second and show files in order of latest modified

watch -n 1 "find $1 -type f -printf \"%TY-%Tm-%Td %TT %p\n\" | sort -r"


