#!/bin/bash
# FILE : bbgallery
# Function: Creates a photogallery of .jpg images in the directory.
# Copyright (C) 2006-2009 Dave Crouse <crouse@usalug.net>

Create_Gallery ()
{
clear
echo "    __    __    _
   / /_  / /_  (_)___  _____
  / __ \/ __ \/ / __ \/ ___/
/ /_/ / /_/ / / /_/ (__  )
/_.___/_.___/_/ .___/____/
             /_/
"
echo "----------------------------------"
echo "Bash Batch Image Processing Script"
echo "Image Gallery Creation Function"

echo "----------------------------------"

# Input the gallery name that will be displayed on the webpage.
read -p "Please enter a name for the gallery: " galleryname
echo " "
echo " "
echo "Now we need information regarding color scheme"
echo "We will need color for the background of the webpage"
echo "and the color of the borders around the images,"
echo "and text underneath the images."
echo " "
read -p "Please enter a color for the webpage background: " backgroundcolor
read -p "Please enter a color for the borders around the images: " bordercolor
read -p "Please enter a color for the text underneath the images: " textcolor
echo " "
echo " "
echo " "
# Create thumbnail gallery
echo "Thumbnail creation starting"
mkdir thumbnails
sleep 1
echo "Thumbnail directory has been created"
sleep 1
#for i in *.JPG ;
#changed to next line for various image types
#for i in *.* ;
# change [.jpg,.JPG] to something else if you want to work with some other image formats
for i in *[.jpg,.JPG] ;
do convert -size 120x120 ${i} -resize 120x120 -quality 100 tn_${i};
mv tn_${i} thumbnails/${i} ;
echo "Creating thumbnail ${i} " ;
done
echo "All thumbnails created"
echo " "
# Create white borders on images in thumbnail gallery
echo "Creating borders on all images"
echo " "
cd thumbnails
# for i in *.* ;
# change [.jpg,.JPG] to something else if you want to work with some other image formats
for i in *[.jpg,.JPG] ;
do convert -bordercolor ${bordercolor} -border 2x2 ${i} ${i}
echo "Border put on image ${i} " ;
done
echo " "
echo "Borders created on all images"
cd ..

# need check to see if an index file already exists ......
# if we are rerunning the script... the next line removes the previous version of the index file.
# rm index.html

# Create the html header
echo " "
echo "Creating index file"
# Below is the start of the html file. You can change the meta tags to reflect YOUR information if you wish.
# Spceifically the description and keywords sections.
echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">" >> index.html
echo "<html>" >> index.html
echo "<head>" >> index.html
echo "<title>${galleryname} ................ Image gallery created using bbips version ${bbips_version} </title>" >> index.html
echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">" >> index.html
echo "<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">" >> index.html
echo "<meta name=\"Author\" content=\"http://www.bbips.org\">" >> index.html
echo "<meta name=\"generator\" content=\"Created by the Bash Batch Image Processing Script\">" >> index.html
echo "<meta name=\"robots\" content=\"all\">" >> index.html
echo "<meta name=\"revisit-after\" content=\"15 days\">" >> index.html
echo "<meta name=\"MSSmartTagsPreventParsing\" content=\"true\">" >> index.html
echo "<meta name=\"description\" content=\"BBIPS - a Bash Batch Image ProcessingScript.\">" >> index.html
echo "<meta name=\"keywords\" content=\"USA, LUG, Forum, usalug, Linux, bbips, bash, bashscripts.org, bbips.org, usalug.org \
">" >> index.html
echo "</head>" >> index.html

echo "<body bgcolor='${backgroundcolor}' link='${textcolor}' vlink='${textcolor}' text='${textcolor}'><center>" >> index.html
echo "<br>" >> index.html
echo "<h3>${galleryname}</h3>"  >> index.html
echo "<table cellpadding='3' cellspacing='5'>"  >> index.html
echo "<tr>"  >> index.html

# Create the table of images
count=0
# for badname in *jpg
# change [.jpg,.JPG] to something else if you want to work with some other image formats
for badname in *[.jpg,.JPG] ;
do
  if [ $count -eq 5 ] ; then
    echo "</td>"  >> index.html
    echo "</tr>"  >> index.html
echo " "  >> index.html
    echo "<tr>"  >> index.html
    echo "<td align='center'>"  >> index.html
    count=1
  else
    echo "</td>"  >> index.html
    echo "<td align='center'>"  >> index.html
    count=$(( $count + 1 ))
  fi

  rename="$(echo ${badname} | sed 's/.jpg//;s/-/ /g')"

  echo "   <a href='${badname}' target=_new><img style='padding:2px' src='thumbnails/${badname}' border='0'></a>"  >> index.html
  echo "   <br>"  >> index.html
  echo "   <font size=-3>${rename}</font>"  >> index.html
done

echo "</td>"  >> index.html
echo "</tr>"  >> index.html
echo "</table>"  >> index.html
echo "<br>" >> index.html
echo "<br>" >> index.html
echo "<br>" >> index.html
echo "<font size=-5>Gallery created on " >> index.html;  date '+%D' >> index.html
echo "<br>" >> index.html
echo " using <a href=\"http://usalug.org/\">BBGALLERY</a> version 1.0" >> index.html
echo "</font></center>"  >> index.html
echo "</body>"  >> index.html
echo " "
echo " "
echo "";
}

Create_Gallery
#sleep 2
#sed 's/<\/td>/ /' index.html > index2.html
#mv index2.html index.html
echo "Image Gallery Created Successfully"
exit 0