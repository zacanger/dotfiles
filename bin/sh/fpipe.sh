#!/bin/bash

# Pipe text to a program which does not read from stdin (using a tempfile
# argument)

tmpfile=`mktemp`
cat >$tmpfile
$@ $tmpfile
rm $tmpfile
