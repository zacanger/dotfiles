#!/bin/bash
# based on bbgallery by Dave Crouse (Copyright 2010 crouse@usalug.net, GPL3)
# ...loosely based. We'll get there.

clear
echo "OKAY NOW LET'S MAKE A GALLERY, HOW ABOUT IT?"
echo ______________________________________________
echo " "
echo " "
echo "Remember, we need to be running from the"
echo "directory where your images are, and it'd"
echo "probably be a good idea to make sure they're"
echo "all jpg files. All good? Okay."
echo " "
echo " "
# This'll be the header.
read -p "Please enter a name for the gallery: " galleryname
echo " "
echo " "
echo "Okay, get your colours ready. We need three:"
echo "One for the background, one for the borders,"
echo "and one for the labels. Hex codes with the hash, please."
echo "And remember, the labels will be the names of the images,"
echo "so make sure they're not awkward."
echo " "
echo " "
read -p "Background colour? " backgroundcolor
read -p "Border colour? " bordercolor
read -p "Text colour? " textcolor
echo " "
echo " "
# thumbnails
echo "Makin' deh thumbnails."
mkdir thumbnails
sleep 1
echo "Well, so far, just the directory."
sleep 1
for i in *[.jpg,.JPG] ;
do convert -size 120x120 ${i} -resize 120x120 -quality 100 tn_${i};
mv tn_${i} thumbnails/${i} ;
echo "Creating thumbnail ${i} " ;
done
echo " "
echo " "
echo "Woot woot, thumbnails are done!"
echo " "
echo " "
echo "Putting some fancy borders around yo pics."
cd thumbnails
for i in *[.jpg,.JPG] ;
do convert -bordercolor ${bordercolor} -border 2x2 ${i} ${i}
echo "Border put on image ${i} " ;
done
echo " "
echo " "
echo "Cool beans, got those borders all set."
cd ..
echo " "
echo " "
# index
echo "Making that index file for ya now."
echo "<html>" >> index.html
echo "<head>" >> index.html
echo "<title>${galleryname}</title>" >> index.html
echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">" >> index.html
echo "<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">" >> index.html
echo "   <script language=\"Javascript\">" >> index.html
echo "   function BBgalleryPic(BBPicURL) {" >> index.html
echo "     window.open(\"show.html?\"+BBPicURL, \"\", " >> index.html 
echo "     \"resizable=1,HEIGHT=200,WIDTH=200\");" >> index.html
echo "   }" >> index.html
echo "   </script> " >> index.html
echo "</head>" >> index.html
echo "<body bgcolor='${backgroundcolor}' link='${textcolor}' vlink='${textcolor}' text='${textcolor}'><center>" >> index.html
echo "<br>" >> index.html
echo "<h3>${galleryname}</h3>"  >> index.html
echo "<table cellpadding='3' cellspacing='5'>" >> index.html
echo "<tr>" >> index.html

# table
count=0
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
echo "   <a href=\"javascript:BBgalleryPic('${badname}')\"><img style='padding:2px' src='thumbnails/${badname}' border='0'></a>" >> index.html 
echo "   <br>" >> index.html
echo "<font size=-3>${rename}</font>" >> index.html
done
echo "</td>"  >> index.html
echo "</tr>"  >> index.html
echo "</table>"  >> index.html
echo "<br>" >> index.html
echo "<br>" >> index.html
echo "<br>" >> index.html
echo "<font size=-5>Gallery created on " >> index.html;  date '+%D' >> index.html
echo "</font></center>" >> index.html
echo "</body>" >> index.html
echo " "
echo " "

# popup
echo "<HTML>" >> show.html
echo "<HEAD>" >> show.html
echo " <TITLE>${galleryname}</TITLE>" >> show.html
echo " <script language='javascript'>" >> show.html
echo "   var arrTemp=self.location.href.split(\"?\");" >> show.html
echo "   var BBpicUrl = (arrTemp.length>0)?arrTemp[1]:\"\";" >> show.html
echo "   var NS = (navigator.appName==\"Netscape\")?true:false;" >> show.html
echo " " >> show.html
echo "     function BBresizePic() {" >> show.html
echo "       iWidth = (NS)?window.innerWidth:document.body.clientWidth;" >> show.html
echo "       iHeight = (NS)?window.innerHeight:document.body.clientHeight;" >> show.html
echo "       iWidth = document.images[0].width - iWidth;" >> show.html
echo "       iHeight = document.images[0].height - iHeight;" >> show.html
echo "       window.resizeBy(iWidth, iHeight);" >> show.html
echo "       self.focus();" >> show.html
echo "     };" >> show.html
echo " </script>" >> show.html
echo "</HEAD>" >> show.html
echo "<BODY bgcolor='${backgroundcolor}' onload='BBresizePic();' topmargin=\"0\"  " >> show.html
echo "marginheight=\"0\" leftmargin=\"0\" marginwidth=\"0\">" >> show.html
echo " <script language='javascript'>" >> show.html
echo " document.write( \"<img src='\" + BBpicUrl + \"' border=0>\" );" >> show.html
echo " </script>" >> show.html
echo "</BODY>" >> show.html
echo "</HTML>" >> show.html
echo "Sweeeeeeet. All done. Almost painless, wasn't it?"
echo " "
echo " "
echo " "
echo " "
echo " "
echo "I'll go ahead and pull this up so you can see it: " ;sleep 5;
x-www-browser index.html
chmod 755 index.html show.html;chmod -R 755 thumbnails/
exit 0