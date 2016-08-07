#!/usr/bin/env bash

set -e

echo "
<!doctype html>\n
<html lang=\"en\">\n
<head>\n
	<meta charset=\"utf-8\">\n
	<meta name=\"author\" content=\"Zac Anger\">\n
	<title>foo</title>\n
	<link rel=\"stylesheet\" type=\"text/css\" href=\"./css.css\">\n
</head>\n
<body>\n
	<div id=\"root\"></div>\n
  <script type=\"text/javascript\" src=\"./bundle.js\"></script>\n
</body>\n
</html>\n
" > index.html
