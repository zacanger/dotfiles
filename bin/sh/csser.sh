#!/bin/bash
ls /usr/local/share/console_colors/
echo "Which theme to use (without extension)?"
read THEME
TMPCSS=~/$THEME.css
FULLPATH=~/console_colors/$THEME
BG=$(grep background $FULLPATH | cut -d":" -f2)
FG=$(grep foreground $FULLPATH | cut -d":" -f2)
COL0=$(grep color0 $FULLPATH | cut -d":" -f2)
COL1=$(grep color1 $FULLPATH | cut -d":" -f2)
COL2=$(grep color2 $FULLPATH | cut -d":" -f2)
COL3=$(grep color3 $FULLPATH | cut -d":" -f2)
COL4=$(grep color4 $FULLPATH | cut -d":" -f2)
COL5=$(grep color5 $FULLPATH | cut -d":" -f2)
COL6=$(grep color6 $FULLPATH | cut -d":" -f2)
COL7=$(grep color7 $FULLPATH | cut -d":" -f2)
COL8=$(grep color8 $FULLPATH | cut -d":" -f2)
COL9=$(grep color9 $FULLPATH | cut -d":" -f2)
COL10=$(grep color10 $FULLPATH | cut -d":" -f2)
COL11=$(grep color11 $FULLPATH | cut -d":" -f2)
COL12=$(grep color12 $FULLPATH | cut -d":" -f2)
COL13=$(grep color13 $FULLPATH | cut -d":" -f2)
COL14=$(grep color14 $FULLPATH | cut -d":" -f2)
COL15=$(grep color15 $FULLPATH | cut -d":" -f2)

#create a custom CSS anyway
cat << EOF > $TMPCSS

code
{
background-color: $COL0 !important;
color: $COL15 !important;
}

tr
{
background-color:$BG !important;
color:$COL15 !important;
}

td
{
background-color:$BG !important;
color:$COL15 !important;
}

head
{
background-color:$BG !important;
color:$COL15 !important;
}

div, span
{
background-color:$BG !important;
color:$COL15 !important;
}

table
{
border: 1px solid $BG !important;
background-color:$BG !important;
color:$COL15 !important;
}


ol
{
background-color:$BG !important;
color:$COL15 !important;
}


ul
{
background-color:$BG !important;
color:$COL15 !important;
}

a
{
background-color:$BG !important;
color:$COL16 !important;
}
a:link
{
background-color:$BG !important;
color:$COL14 !important;
}
a:visited
{
background-color:$BG !important;
color:$COL11 !important;
}
a:active
{
background-color:$BG !important;
color:$COL12 !important;
}
a:hover
{
background-color:$BG !important;
color:$COL13 !important;
}

h1
{
background-color:$BG !important;
color:$COL8 !important;
}
h2
{
background-color:$BG !important;
color:$COL8 !important;
}
h3
{
background-color:$BG !important;
color:$COL8 !important;
}

form
{
background-color:$FG !important;
color:$BG !important;
}

span
{
background-color:$BG !important;
color:$COL15 !important;
}

body
{
background-color:$BG !important;
color:$FG !important;
}

p
{
background-color:$BG !important;
color:$COL15 !important;
}

EOF

read -n1 -p "Use it now? (y/N)"
if [ $REPLY = 'y' ]; then
cp $TMPCSS ~/.config/chromium/Default/User\ StyleSheets/Custom.css
fi
echo
echo Saved as $TMPCSS

