#!/bin/bash

# One grep to rule them all.
# One grep to find them.
# One grep to bring them all,
# and figure out why shit is fucked.

if [ -t 1 ]; then
    color="always"
else
    color="never"
fi

exclusions=(
    # Exclude minified directories.
    --exclude-dir='minified'
    --exclude-dir='combined'
    # Exclude minified JS files.
    --exclude='*.*.js'
    --exclude='*combined*.js'
    # Exclude JS files we probably do not care about.
    --exclude='*jquery*.js'
    --exclude='*bootstrap*.js'
    --exclude='jstz.js'
    --exclude-dir='bootstrap'
    --exclude-dir='bootstrap-*-*-*'
    --exclude-dir='font-awesome'
    --exclude-dir='ckeditor'
    --exclude='knockout.js'
    --exclude='underscore.js'
    --exclude='highcharts.js'
    --exclude='analytics.js'
    --exclude-dir='select2'
    --exclude='es5.js'
    # Exclude minified CSS files.
    --exclude='*.*.css'
    --exclude='*combined*.css'
    # Exclude plaintext files.
    --exclude='*.txt'
    --exclude='*.xml'
    --exclude='*.md'
    --exclude='*.rst'
    --exclude='*.svg'
    --exclude='*.po'
    --exclude='*license*'
    --exclude='README*'
    --exclude='readme*'
    --exclude='VERSION*'
    --exclude='INSTALL*'
    --exclude='LICENSE*'
    --exclude='CREDITS*'
    --exclude='COPYING*'
    --exclude='MAINTAINERS*'
    --exclude='RELEASE*'
    --exclude='Changelog'
    --exclude-dir='documentation'
    --exclude-dir='docs'
    --exclude='*.types'
    # SSH files
    --exclude='*.cert'
    --exclude='*.crt'
    --exclude='*.key'
    --exclude='*.pem'
    --exclude='*.pub'
    # Exclude build files
    --exclude-dir='bin'
    --exclude='Makefile'
    --exclude='configure'
    --exclude='*.mak'
    --exclude='*.ini'
    --exclude='*.cmd'
    --exclude='*.bat'
    --exclude='build.sh'
    --exclude='travis-ci.sh'
    --exclude='*.apib'
    --exclude='*.pp'
    --exclude='*.pip'
    --exclude='run-*.sh'
    # Qt generated CPP files.
    --exclude='moc_*.cpp'
    # Exclude special source control directories.
    --exclude-dir='.git'
    --exclude-dir='.svn'
    # Exclude common virtualenv names.
    --exclude-dir='env'
    --exclude-dir='ve'
    # Exclude Django migration files.
    --exclude='0*.py'
    # Exclude Python settings files.
    --exclude='*settings*.py'
    # Exclude common configuration files.
    --exclude='*.jshintrc'
    --exclude='*.cfg'
    --exclude='.*project'
    --exclude='*.pro'
    --exclude='.gitattributes'
    --exclude='.gitignore'
    --exclude='.editorconfig'
    --exclude='.directory'
    --exclude='.travis.yml'
    # DUB files.
    --exclude='package.json'
    --exclude='dub.json'
    --exclude='dub.selections.json'
    # Exclude sockets
    --exclude='*.sock'
    # Exclude backup files
    --exclude='*.bak'
    --exclude='*.orig'
)

grep -PrI --color="$color" "${exclusions[@]}" "$@"