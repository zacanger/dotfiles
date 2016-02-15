#!/bin/bash

# Recursive Line Count
# Counts lines in the files with the specified extension; recurses into subdirectories

if [ -z $1 ]; then 
    echo -e "\n\tRecursive Line Count (by file extension)\n\t----\n"
    echo -e "\tCounts lines in the files in the current directory with the specified extension."
    echo -e "\tRecurses into subdirectories and prints total at the end."
    echo -e "\n\tUsage: recursive-line-count java\n"
    exit 1
fi

pattern=$1
list=$( find . -type f \( -name "*.$pattern" ! -iname ".*" \) )

if [ -z $list ]; then { echo "No files with that extension were found."; exit 1; }; fi

wc -l $list
