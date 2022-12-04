#!/usr/bin/env bash
set -e

ND=$HOME/.config/ninit # ninit dir -- set this to whereever you keep these files
DN="${PWD##*/}" # current directory (like basename $(pwd))

# make these files in wherever you specified $ND
cp "$ND/.editorconfig" .editorconfig
cp "$ND/pyproject.toml" pyproject.toml
cp "$ND/.gitignore" .gitignore
cp "$ND/.gitattributes" .gitattributes
cp "$ND/LICENSE.md" LICENSE.md
cp "$ND/.npmrc" .npmrc
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
    \"license\": \"MIT\",
    \"main\": \"index.js\",
    \"scripts\": {
        \"test\": \"npm run test:lint && npm run test:tape\",
        \"test:tape\": \"tape test.js\",
        \"test:lint\": \"standard\",
        \"preversion\": \"npm t && sortpack\"
    },
    \"engines\": {
        \"node\": \">=16.0.0\"
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
    \"license\": \"MIT\",
    \"main\": \"index.js\",
    \"scripts\": {
        \"test\": \"npm run test:lint && npm run test:tape\",
        \"test:tape\": \"tape test.js\",
        \"test:lint\": \"standard\",
        \"preversion\": \"npm t && sortpack\"
    },
    \"engines\": {
        \"node\": \">=16.0.0\"
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
    }
}"

echo "# $DN

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
npm i -D standard sortpack tape
npx sortpack
git add -A
git commit -m 'Init'
