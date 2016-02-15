#!/usr/bin/env bash

# creates directory (argument passed, or just asks for it if none)
# grabs latest (as of feb 2016) bootstrap, jquery, & jquery mobile css & js
# puts empty styles.css and scripts.js in there
# throws in an index.html already linked up for you
# wtfpl/dbad license, gh:zacanger

if [ "$1" = "" ]
then
  echo "what is this project called?"
  read dir
else
  dir="$1"
fi

echo "Creating Directories for $dir"
mkdir -p "$dir/js"
mkdir -p "$dir/css"

echo "getting your javascript libs"
wget "https://cdnjs.cloudflare.com/ajax/libs/jquery/2.2.0/jquery.min.js" -O "$dir/js/jquery.min.js"
wget "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" -O "$dir/js/bootstrap.min.js"
wget "https://cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.4.5/jquery.mobile.min.js" -O "$dir/js/jquery.mobile.min.js"

echo "getting your css libs"
wget "https://cdnjs.cloudflare.com/ajax/libs/jquery-mobile/1.4.5/jquery.mobile.min.css" -O "$dir/css/jquery.mobile.min.css"
wget "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" -O "$dir/css/bootstrap.min.css"
wget "https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" -O "$dir/css/bootstrap-theme.min.css"

clear

touch $dir/js/scripts.js
touch $dir/css/styles.css

echo "creating your html"
cat << EOF >> "$dir/index.html"
<!DOCTYPE html>
<html lang="en">
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" type="text/css" href="css/jquery.mobile.min.css">
  <link rel="stylesheet" type="text/css" href="css/bootstrap.min.css">
  <link rel="stylesheet" type="text/css" href="css/bootstrap-theme.min.css">
  <link rel="stylesheet" type="text/css" href="css/styles.css">
  <script type="text/javascript">
  \$(document).ready(function(){
  })
  </script>
</head>
<body>
  <div>foo</div>
  <script type="text/javascript" src="js/jquery.min.js"></script>
  <script type="text/javascript" src="js/bootstrap.min.js"></script>
  <script type="text/javascript" src="js/jquery.mobile.min.js"></script>
  <script type="text/javascript" src="js/scripts.js"></script>
</body>
</html>
EOF

