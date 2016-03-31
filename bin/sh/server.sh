#!/usr/bin/env bash

# add the following to /etc/inetd.conf (where server.sh is this file)
# www stream tcp nowait nobody /usr/local/bin/server.sh server.sh

dynamic_request() {
  export QUERY_STRING="$query"
  echo -e "HTTP/1.1 200 OK\r"
  "$filename"
  echo -e "\r"
  exit 0
}

static_request() {
  echo -e "HTTP/1.1 200 OK\r"
  echo -e "Content-Type: `/usr/bin/file -bi \"$filename\"`\r"
  echo -e "\r"
  cat "$filename"
  echo -e "\r"
}

dir_list() {
  echo -e "HTTP/1.1 200 OK\r"
  echo -e "Content-Type: text/html\r"
  echo -e "\r"
  echo -e "Listing of $url\r"
  echo -e "<br>"
  echo -e "Details Name\r"
  echo -e "<br>"
  ( cd "$filename"
  for f in `ls`; do
    desc=`ls -ld "$f"`
    desc=${desc% $f}
    href="${url%/}/$f"
    echo -e "$desc
    $f\r"
    echo -e "<br>"
  done
  )
  echo -e "\r"
  echo -e "\r"
  echo -e "\r"
}

404_page() {
  echo -e "HTTP/1.1 404 Not Found\r"
  echo -e "Content-Type: text/html\r"
  echo -e "\r"
  echo -e "404 Not Found\r"
  echo -e "Not Found
  The requested resource was not found\r"
  echo -e "\r"
}

base=/var/www

read request

while /bin/true; do
  read header
  [ "$header" == $'\r' ] && break;
done

url="${request#GET }"
url="${url% HTTP/*}"
query="${url#*\?}"
url="${url%%\?*}"
filename="$base$url"

if [ "$query" != "$url" -a -x "$filename" ]; then
  dynamic_request;
fi

if [ -f "$filename" ]; then
  if [ -x "$filename" ]; then
    dynamic_request;
  fi
  static_request;
else
  if [ -d "$filename" ]; then
    if [ -f "$filename/index.html" ]; then
      filename="${filename}/index.html"
      if [ -x "$filename" ]; then
        dynamic_request;
      fi
      static_request;
    else
      dir_list;
    fi
  else
    404_page;
  fi
fi

