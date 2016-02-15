#!/bin/bash

# Prepend a meta tag to some arbitrary text to instruct browsers to render it
# as HTML

metatag='<meta http-equiv="Content-Type" content="text/html">'

cat <(echo $metatag) -
