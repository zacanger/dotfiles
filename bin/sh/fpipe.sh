#!/usr/bin/env bash

# pipe text to program that doesn't read from stdin (using tempfile)

tmpfile=`mktemp`
cat >$tmpfile
$@ $tmpfile
rm $tmpfile

