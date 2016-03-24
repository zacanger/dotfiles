#!/usr/bin/env bash

# loosely based on bbgallery by Dave Crouse (Copyright 2010 crouse@usalug.net, GPL3)

clear
# intro
echo "                                                 "
echo " _____  _____  _____  _____  _____  _____  __    "
echo "| __  ||  _  ||   __||  |  ||   __||  _  ||  |   "
echo "| __ -||     ||__   ||     ||  |  ||     ||  |__ "
echo "|_____||__|__||_____||__|__||_____||__|__||_____|"
echo "                                                 "
echo ___________________________________________________
echo
echo
echo "Remember, we need to be running from the directory"
echo "where your images are, and they should all be jpg"
echo "files. The labels for your images will be their"
echo "filenames. Now would be a good time to double-check"
echo "those. Hit Ctrl-C to cancel building the gallery."
echo
sleep 2
echo "All good? Okay."
echo

# galleryname is used for the title and header
read -p "Please enter a name for the gallery: " galleryname
echo
echo "Okay, get your colours ready. We need three:"
echo "one each for the background, borders, and labels."
echo "Hex codes, with hash, please."
echo
read -p "Background colour? " backgroundcolor
read -p "Border colour? " bordercolor
read -p "Text colour? " textcolor
echo

# gallery generation starts
echo "Okay, here we go!"
echo

# thumbnails
echo "Generating thumbnails."
mkdir thumbnails
sleep 1
for i in *[.jpg,.JPG] ;
do convert -size 120x120 ${i} -resize 120x120 -quality 100 tn_${i};
mv tn_${i} thumbnails/${i} ;
echo "Creating thumbnail ${i} " ;
done
echo
echo "Thumbnails done."
echo

# borders
echo "Putting borders around your pics."
echo
cd thumbnails
for i in *[.jpg,.JPG] ;
do convert -bordercolor ${bordercolor} -border 2x2 ${i} ${i}
echo "Border put on image ${i} " ;
done
echo
echo "Borders are finished."
cd ..
echo

# index.html
echo "Generating the index."
echo "<doctype html>" >> index.html
echo "<html lang=\"en\">" >> index.html
echo "<head>" >> index.html
echo "<title>${galleryname}</title>" >> index.html
echo "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">" >> index.html
echo "<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">" >> index.html
echo "   <script language=\"javascript\">" >> index.html
echo "     function galleryPic(PicURL) {" >> index.html
echo "       window.open(\"show.html?\"+PicURL, \"\", " >> index.html
echo "     \"resizable=1,HEIGHT=200,WIDTH=200\")" >> index.html
echo "     }" >> index.html
echo "   </script> " >> index.html
echo "</head>" >> index.html
echo "<body bgcolor='${backgroundcolor}' link='${textcolor}' vlink='${textcolor}' text='${textcolor}'><center>" >> index.html
echo "  <br>" >> index.html
echo "  <h3>${galleryname}</h3>" >> index.html
echo "  <table cellpadding=\"3\" cellspacing=\"5\">" >> index.html
echo "    <tr>" >> index.html

# table
count=0
for badname in *[.jpg,.JPG] ;
do
  if [ $count -eq 5 ] ; then
    echo "    </td>" >> index.html
    echo "    </tr>" >> index.html
echo >> index.html
    echo "    <tr>" >> index.html
    echo "    <td align='center'>" >> index.html
    count=1
  else
    echo "    </td>" >> index.html
    echo "    <td align=\"center\">" >> index.html
    count=$(( $count + 1 ))
  fi
rename="$(echo ${badname} | sed 's/.jpg//;s/-/ /g')"
echo "   <a href=\"javascript:galleryPic('${badname}')\"><img style=\"padding:2px\" src='thumbnails/${badname}' border=\"0\"></a>" >> index.html
echo "   <br>" >> index.html
echo "    <font size=-3>${rename}</font>" >> index.html
done
echo "    </td>"  >> index.html
echo "    </tr>"  >> index.html
echo "  </table>" >> index.html
echo "  <br>" >> index.html
echo "  <br>" >> index.html
echo "  <br>" >> index.html
echo "  <font size=-5>Gallery created on " >> index.html
date '  +%D' >> index.html
echo "</font></center>" >> index.html
echo "</body>" >> index.html
echo "</html>" >> index.html
echo >> index.html
echo

# popup
echo "Generating the popup."
echo "<!doctype html>" >> show.html
echo "<html lang=\"en\">" >> show.html
echo "<head>" >> show.html
echo "  <title>${galleryname}</title>" >> show.html
echo "  <script type=\"text/javascript\">" >> show.html
echo "   var arrTemp=self.location.href.split(\"?\")" >> show.html
echo "   var picUrl = (arrTemp.length>0)?arrTemp[1]:\"\"" >> show.html
echo "   var NS = (navigator.appName==\"Netscape\")?true:false" >> show.html
echo "     function resizePic() {" >> show.html
echo "       iWidth = (NS)?window.innerWidth:document.body.clientWidth" >> show.html
echo "       iHeight = (NS)?window.innerHeight:document.body.clientHeight" >> show.html
echo "       iWidth = document.images[0].width - iWidth" >> show.html
echo "       iHeight = document.images[0].height - iHeight" >> show.html
echo "       window.resizeBy(iWidth, iHeight)" >> show.html
echo "       self.focus()" >> show.html
echo "     }" >> show.html
echo "  </script>" >> show.html
echo "</head>" >> show.html
echo "<body bgcolor=\"${backgroundcolor}\" onload=\"resizePic()\" topmargin=\"0\"  " >> show.html
echo "marginheight=\"0\" leftmargin=\"0\" marginwidth=\"0\">" >> show.html
echo "  <script type=\"text/javascript\">" >> show.html
echo "    document.write(\"<img src='\" + picUrl + \"' border=0>\")" >> show.html
echo "  </script>" >> show.html
echo "</body>" >> show.html
echo "</html>" >> show.html
echo >> show.html
echo
echo "All done!"
echo

# setting all to 644, then changing thumbnail dir to 755
chmod 644 index.html show.html thumbnails/*
chmod 755 thumbnails/

# opening up in default browser; should be cross-platform
echo "Opening in your default browser."
sleep 2
for opener in xdg-open open cygstart "start"; {
  if command -v $opener; then
    open=$opener;
    break;
  fi
}
$open index.html

exit 0

