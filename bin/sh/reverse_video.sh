#!/bin/bash

#######################
#Check for requirments#
#######################
zenity=$(which zenity)
if [ "$zenity" == "" ]; then
    echo "You must have zenity installed"
    exit 1
fi
#avconv=$(which avconv)
#if [ "$avconv" == ""]; then
#    zenity --error --text="You must have avconv installed"
#    exit 1 
#fi

avconv=$(which avconv)
if [ "$avconv" == "" ]; then
    echo "You must have avconv installed"
    exit 1
fi
##################################
#Spawn frames into images/ folder#
##################################
mkdir images
cd images
#avconv -i ../$1 %d.jpg
avconv -i ../$1 %d.jpg

##############
#Count images#
##############
images=0

for i in $(ls | grep .jpg); do
    let images=images+1
done
#####################################
#Rename images in the opposite order#
#####################################
i=1
factor=0
while [ $factor -lt $images ]; do
    new_name=$((images-factor))
    echo $new_name
    mv $i.jpg image$new_name.jpg
    let factor=factor+1
    let i=i+1
done
###############################################
#Finally convert newly named images into video#
###############################################
#avconv -f image2 -i image%d.jpg -vcodec mpeg4 ../$2
avconv -f image2 -i image%d.jpg -vcodec mpeg4 ../$2


#######################
#Remove temporal files#
#######################
rm *.jpg
