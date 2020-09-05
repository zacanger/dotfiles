#!/usr/bin/env bash

ND=$HOME/.config/ninit # ninit dir -- set this to whereever you keep these files
DN="${PWD##*/}" # current directory (like basename $(pwd))

# make these files in wherever you specified $ND
cp "$ND/.editorconfig" .editorconfig
cp "$ND/.gitignore" .gitignore
cp "$ND/.gitattributes" .gitattributes
cp "$ND/LICENSE.md" LICENSE.md
cp "$ND/.npmrc" .npmrc
cp "$ND/.eslintrc.json" .eslintrc.json
cp "$ND/.prettierrc.js" .prettierrc.js
cp -R "$ND/.github" .github

WITHOUTG="{
  \"name\": \"$DN\",
  \"description\": \"$DN\",
  \"version\": \"0.0.1\",
  \"author\": {
    \"name\": \"Zac Anger\",
    \"email\": \"zac@zacanger.com\",
    \"url\": \"https://zacanger.com\"
  },
  \"license\": \"LGPL-3.0\",
  \"main\": \"index.js\",
  \"scripts\": {
    \"test\": \"npm run test:lint && npm run test:tape\",
    \"test:tape\": \"tape test.js\",
    \"test:lint\": \"eslint\",
    \"preversion\": \"npm t\"
  },
  \"engines\": {
    \"node\": \">=10.0.0\"
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
  \"devDependencies\": {},
  \"funding\": {
    \"type\": \"ko-fi\",
    \"url\": \"https://ko-fi.com/zacanger\"
  },
  \"lint-staged\": {
    \"*.js\": [
      \"prettier --write\"
    ],
    \"package.json\": [
      \"sortpack\"
    ]
  },
  \"husky\": {
    \"hooks\": {
      \"pre-commit\": \"lint-staged\"
    }
  }
}"

WITHG="{
  \"name\": \"$DN\",
  \"description\": \"$DN\",
  \"version\": \"0.0.1\",
  \"author\": {
    \"name\": \"Zac Anger\",
    \"email\": \"zac@zacanger.com\",
    \"url\": \"https://zacanger.com\"
  },
  \"license\": \"LGPL-3.0\",
  \"main\": \"index.js\",
  \"scripts\": {
    \"test\": \"npm run test:lint && npm run test:tape\",
    \"test:tape\": \"tape test.js\",
    \"test:lint\": \"eslint\",
    \"preversion\": \"npm t\"
  },
  \"engines\": {
    \"node\": \">=10.0.0\"
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
  \"devDependencies\": {},
  \"funding\": {
    \"type\": \"ko-fi\",
    \"url\": \"https://ko-fi.com/zacanger\"
  },
  \"lint-staged\": {
    \"*.js\": [
      \"prettier --write\"
    ],
    \"package.json\": [
      \"sortpack\"
    ]
  },
  \"husky\": {
    \"hooks\": {
      \"pre-commit\": \"lint-staged\"
    }
  }
}"

echo "# $DN

[![Support with PayPal](https://img.shields.io/badge/paypal-donate-yellow.png)](https://paypal.me/zacanger) [![Patreon](https://img.shields.io/badge/patreon-donate-yellow.svg)](https://www.patreon.com/zacanger) [![ko-fi](https://img.shields.io/badge/donate-KoFi-yellow.svg)](https://ko-fi.com/U7U2110VB)

--------

## Installation

## Usage

[LICENSE](./LICENSE.md)" > README.md

if [ "$1" == "-g" ] ; then
  echo "$WITHG" > package.json
  cp "$ND/global.js" index.js
else
  echo "$WITHOUTG" > package.json
  cp "$ND/module.js" index.js
fi

git init
npm i -D eslint eslint-plugin-zacanger prettier sortpack tape husky lint-staged
npx sortpack
git add -A
git commit -m 'Init'
