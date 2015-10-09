#! /bin/sh
# @(#) ingredients.sh 2004/05/01


tablify() {
    if [ "$1" ] ; then
	TOTAL=$1
	TITLE=$2
	echo "$1: :$TITLE" | tablify
	COL1="td"
	PFX="&nbsp;"
    else
	TOTAL=1
	COL1="th"
	PFX=
    fi
    awk -F: ' {   if ($1 > 0) {
		    printf "<tr><'$COL1'>'$PFX'%s %s<\/'$COL1'>", $3, $1;
		    if ( $2 == "P" ) {
		       percent = 100 * $1;
		       percent /= '"$TOTAL"';
		       printf "<th>%2.1f%%<\/th><\/tr>\n", percent;
		    }
		    else {
			print "<td>&nbsp;</td></tr>";
		    }
		}
	    }'
}

webpages() {
    echo `find . -name \*.html 2>/dev/null | wc -l` ": : static pages"
    echo `find . -type l 2>/dev/null | wc -l`       ": : symbolic links"
    echo `find . -name \*.asp 2>/dev/null | wc -l`  ": : scripts"
    echo `find . -name \*.css 2>/dev/null | wc -l`  ": : style sheets"
}


DATE=`date`

code128 1 "$DATE" > barcode.gif

cat - << EOF
<!doctype html public "-//W3C//DTD HTML 4.0 Transitional //EN">
<html>
<head>
   <meta name="Author" content="orc@pell.chi.il.us">
   <meta name="GENERATOR" content="ingredients.txt">
   <style type=text/css>
       @import url(/~orc/pages.css);
       #ingredients {
	    background: #fff;
	    font-family: arial, sans-serif;
	    border-right: 2px solid #000;
	    border-bottom: 1px solid #000;
	    margin-left:25%;
	    width:49%;
	    min-width:22em;
	    padding: 1em 1em 1em 1em;
	    text-align: center;
       }
       body { background: #aaa; }
       #ingredients hr { align: center; }
       #ingredients a { text-decoration: none; }
       #ingredients th,td { border-top: 1px dashed #000;
			 font-size: smaller;
			 text-align:left; }
   </style>
   <title>INGREDIENTS</title>
</head>
<body>
<div align="center" id="ingredients">
<img src="barcode.gif" />
<p align="left">
<b><i>Ingredients:</i></b>
Source code, images, html pages,
shell scripts,
<a href="http://www.cpan.org">perl</a> scripts,
<a href="http://www.w3c.org/Style/CSS">style sheets</a>.
<hr />
<p align="center"><font size="+1"><b>Nutrition Facts</b></font><br />
Serving size: 1 visit<br />
Servings per day: ~3000<br />
</p>
<hr>
<p>
<table width=100%>
<caption style="text-align:left">Amount per serving</caption>
<tr><td colspan=2 style="text-align:right"><font size=-1>% Daily Value</td></tr>
EOF

echo `find . -type f -print 2>/dev/null | wc -l` ": : Files" | tablify
webpages | tablify

cat - << EOF

</table></p>
<hr />
<p><b>Manufactured by
<a href="/~orc/">David Parsons</a>,<br />
Portland, OR 97202</b>
</p>
<p>Distributed by <a href="http://www.apache.org">Apache</a>
and <a href="http://www.freebsd.org">FreeBSD</a>.
</div>
</div>
</body>
</html>
EOF
exit 0
