#!/usr/bin/env bash

set -e

# generates an index
# touches an app.js, svc.js, and ctrl.js; also a css.css
# links up angular and ui-router from a cdn

{
  printf "<!DOCTYPE html>\n"
  printf "<html lang=\"en\">\n"
  printf "<head>\n"
  printf "  <meta charset=\"utf-8\">\n"
  printf "  <meta name=\"author\" content=\"your name\">\n"
  printf "  <title>ui-router thing</title>\n"
  printf "  <link rel=\"stylesheet\" type=\"text/css\" href=\"./css.css\">\n"
  printf "</head>\n"
  printf "<body ng-app=\"app\">\n"
  printf "  <ui-view></ui-view>\n"
  printf "  <script type=\"text/javascript\" src=\"https://code.angularjs.org/1.5.0-beta.0/angular.min.js\"></script>\n"
  printf "  <script type=\"text/javascript\" src=\"https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/0.2.18/angular-ui-router.min.js\"></script>\n"
  printf "  <script type=\"text/javascript\" src=\"./app.js\"></script>\n"
  printf "  <script type=\"text/javascript\" src=\"./ctrl.js\"></script>\n"
  printf "  <script type=\"text/javascript\" src=\"./svc.js\"></script>\n"
  printf "</body>\n"
  printf "</html>\n"
} > index.html

touch app.js
touch svc.js
touch ctrl.js
touch css.css
echo "done!"
echo
