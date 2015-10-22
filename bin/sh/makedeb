#!/bin/bash
#creates a basic deb package for script file

echo "what is your email address?"
read mail
export DEBEMAIL="$mail"

echo "what is your name"
read name
export DEBFULLNAME="$name"

echo "What is your package name?"
read package

echo "What is the version?"
read ver

echo "What License do you want to use(example: gpl3)?"
read license

folder="$package-$ver"

mkdir "$folder"
cd "$folder"
dh_make --createorig --copyright $license --indep # this will prompt you to hit enter
mkdir essentials
mv debian/{changelog,compat,rules,control} essentials
rm -r debian
mv essentials debian
echo './example-src/* ./' > debian/$package.install
mkdir -p example-src/usr/bin

echo "What is the name of your script?"
read script
vim example-src/usr/bin/$script # create the empty file to be installed
chmod +x example-src/usr/bin/$script

vim debian/control

echo "Press 'Enter' to package now."
read

dpkg-buildpackage -uc -tc -rfakeroot
dpkg --contents ../$package_$ver_all.deb # inspect the resulting Debian package

