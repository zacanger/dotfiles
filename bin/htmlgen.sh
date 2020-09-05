#!/usr/bin/env bash

set -e

printf '<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="author" content="Zac Anger">
  <title>foo</title>
  <link rel="stylesheet" type="text/css" href="/css.css">
</head>
<body>
  <div id="root"></div>
  <script type="text/javascript" src="/bundle.js"></script>
</body>
</html>
' > index.html
