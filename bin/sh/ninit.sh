#!/usr/bin/env bash

ND=$HOME/.ninit # ninit dir
DN="${PWD##*/}"

cp $ND/.editorconfig .editorconfig
cp $ND/.gitignore .gitignore
cp $ND/.gitattributes .gitattributes
cp $ND/.eslintrc.json .eslintrc.json
cp $ND/LICENSE.md LICENSE.md

WITHOUTG="{
  \"name\": \"$DN\",
  \"description\": \"$DN\",
  \"version\": \"0.0.1\",
  \"author\": {
    \"name\": \"Zac Anger\",
    \"email\": \"zac@zacanger.com\",
    \"url\": \"http://zacanger.com\"
  },
  \"license\": \"WTFPL\",
  \"main\": \"index.js\",
  \"scripts\": {
    \"start\": \"node index\",
    \"test\": \"\"
  },
  \"engines\": {
    \"node\": \">=6.0.0\"
  },
  \"homepage\": \"https://github.com/zacanger/$DN#readme\",
  \"repository\": {
    \"type\": \"git\",
    \"url\": \"https://github.com/zacanger/$DN.git\"
  },
  \"bugs\": \"https://github.com/zacanger/$DN/issues\",
  \"keywords\": [
    \"$DN\",
    \"\"
  ],
  \"dependencies\": {},
  \"devDependencies\": {}
}"

WITHG="{
  \"name\": \"$DN\",
  \"description\": \"$DN\",
  \"version\": \"0.0.1\",
  \"author\": {
    \"name\": \"Zac Anger\",
    \"email\": \"zac@zacanger.com\",
    \"url\": \"http://zacanger.com\"
  },
  \"license\": \"WTFPL\",
  \"main\": \"index.js\",
  \"scripts\": {
    \"start\": \"node index\",
    \"test\": \"\"
  },
  \"engines\": {
    \"node\": \">=6.0.0\"
  },
  \"preferGlobal\": true,
  \"bin\": \"./index.js\",
  \"homepage\": \"https://github.com/zacanger/$DN#readme\",
  \"repository\": {
    \"type\": \"git\",
    \"url\": \"https://github.com/zacanger/$DN.git\"
  },
  \"bugs\": \"https://github.com/zacanger/$DN/issues\",
  \"keywords\": [
    \"$DN\",
    \"\"
  ],
  \"dependencies\": {},
  \"devDependencies\": {}
}"

echo "# $DN

--------

## Installation:

## Usage:

## License:

WTFPL" > README.md

if [ "$1" == "-g" ] ; then
  echo $WITHG > package.json
else
  echo $WITHOUTG > package.json
fi

fixpack
git init
git add -A
git commit -am 'first'
