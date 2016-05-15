#!/usr/bin/env bash

set -e

{
	printf "<!doctype html>\n"
	printf "<html lang=\"en\">\n"
	printf "<head>\n"
	printf "  <meta charset=\"utf-8\">\n"
	printf "  <meta name=\"author\" content=\"Zac Anger\">\n"
	printf "  <title>foo</title>\n"
	printf "  <link rel=\"stylesheet\" type=\"text/css\" href=\"./css.css\">\n"
	printf "</head>\n"
	printf "<body>\n"
	printf "  <div>\n"
#	markdown README.md | sed -e 's/\/CHANGES.md/changes.html/' -e 's/\/LICENSE.md/license.html/' -e 's/LICENSE.md/the license/'
	printf "  </div>\n"
  printf "  <script type=\"text/javascript\" src=\"./js.js\"></script>\n"
	printf "</body>\n"
	printf "</html>\n"
} > index.html

