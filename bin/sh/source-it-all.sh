#!/usr/bin/env bash

#If you want to just source one file with all of the shit in one place
#then just run this script in the root of the repostitory and source 
#the resulting util.sh file

find . -name "*.sh" ! -name "whole_shebang.sh" ! -name "util.sh" -exec cat {} + > util.sh
