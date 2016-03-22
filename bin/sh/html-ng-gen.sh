#!/usr/bin/env bash

set -e

# generates an index
# touches an app.js, svc.js, and ctrl.js; also a css.css
# links up angular and ui-router from a cdn

echo "generating your html"
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
  printf "  <script type=\"text/javascript\" src=\"https://code.angularjs.org/1.5.0/angular.min.js\"></script>\n"
  printf "  <script type=\"text/javascript\" src=\"https://cdnjs.cloudflare.com/ajax/libs/angular-ui-router/0.2.18/angular-ui-router.min.js\"></script>\n"
  printf "  <script type=\"text/javascript\" src=\"./app.js\"></script>\n"
  printf "  <script type=\"text/javascript\" src=\"./ctrl.js\"></script>\n"
  printf "  <script type=\"text/javascript\" src=\"./svc.js\"></script>\n"
  printf "</body>\n"
  printf "</html>\n"
} > index.html

echo "generating some javascript for you"
{
  printf "angular.module('app', ['ui.router'])\n"
  printf ".config(function(\$stateProvider, \$urlRouterProvider){\n"
  printf "  \$urlRouterProvider.otherwise('/')\n"
  printf "})\n"
} > app.js

{
  printf "angular.module('app')\n"
  printf ".controller('mainCtrl', function(\$scope){\n"
  printf "  \$scope.test = 'test'\n"
  printf "})\n"
} > ctrl.js

{
  printf "angular.module('app')\n"
  printf ".service('mainSvc', function(\$http){\n"
  printf "\n"
  printf "})\n"
} > svc.js

echo "generating a css reset"
{
  printf "html,body{height:100%%;width:100%%;}\n"
  printf "html,body,ul,ol,li,form,fieldset,legend{margin:0;padding:0;}\n"
  printf "h1,h2,h3,h4,h5,h6,p{margin-top:0;}\n"
  printf "fieldset,img{border:0;}\n"
  printf "legend{color:#000;}\n"
  printf "li{list-style: none;}\n"
  printf "sup{vertical-align:text-top;}\n"
  printf "sub{vertical-align:text-bottom;}\n"
  printf "table{border-collapse:collapse;border-spacing:0;}\n"
  printf "caption,th,td{text-align:left;vertical-align:top;font-weight:normal;}\n"
  printf "input,textarea,select{font-size:110%%;line-height:1.1;}\n"
  printf "abbr,acronym{border-bottom:.1em dotted;cursor:help;}\n"
} > css.css

echo
echo "done!"
echo

