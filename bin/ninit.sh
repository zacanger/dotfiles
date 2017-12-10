#!/usr/bin/env bash

ND=$HOME/.ninit # ninit dir -- set this to whereever you keep these files
DN="${PWD##*/}" # current directory (like basename `pwd`)

# make these files in wherever you specified $ND
cp $ND/.editorconfig .editorconfig
cp $ND/.gitignore .gitignore
cp $ND/.gitattributes .gitattributes
cp $ND/.eslintrc.json .eslintrc.json
cp $ND/.tern-project .tern-project
cp $ND/LICENSE.md LICENSE.md
cp $ND/.npmrc .npmrc

WITHOUTG="{
  \"name\": \"$DN\",
  \"description\": \"$DN\",
  \"version\": \"0.0.1\",
  \"author\": {
    \"name\": \"Zac Anger\",
    \"email\": \"zac@zacanger.com\",
    \"url\": \"http://zacanger.com\"
  },
  \"license\": \"MIT\",
  \"main\": \"index.js\",
  \"scripts\": {
    \"start\": \"node index\",
    \"test\": \"\"
  },
  \"engines\": {
    \"node\": \">=8.0.0\"
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
  \"license\": \"MIT\",
  \"main\": \"index.js\",
  \"scripts\": {
    \"start\": \"node index\",
    \"test\": \"\"
  },
  \"engines\": {
    \"node\": \">=8.0.0\"
  },
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

## Installation

## Usage

## License

[MIT](./LICENSE.md)" > README.md

if [ "$1" == "-g" ] ; then
  echo $WITHG > package.json
  cp $ND/global.js index.js
else
  echo $WITHOUTG > package.json
  cp $ND/module.js index.js
fi

fixpack # `npm i -g fixpack, and make a ~/.fixpackrc`
git init
git add -A
git commit -m 'Boom!'
