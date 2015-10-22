#!/bin/bash

#gets user input
url="$1"
#create uniq file name for this search
searched="$(date +%s).lst"
touch $searched
echo "Saving to $searched"

function crawl(){
    url="$1"

    #s will be used to check if url has already been searched
    s=0

    #check searched file for current url
    grep "$url" $searched && s=1 || s=0

    #if current url has been search skip it
    if [[ $s == 0 ]];
    then
        #add current url to searched list
        echo "$url" >> $searched
        echo "Crawling ${url}..."
        #get all urls on page
        lynx --dump "$url"|\
            sed 's/http/\nhttp/g'|\
            grep -e "^http:" -e "^https:"|\
            sed 's/%3A%2F%2F/:\/\//g'|\
            sort -u| while read line
                do
                    #crawl through each url
                    crawl "$line"
                done
    else
        #reset searched check
        s=0
    fi
}

#calls crawl function
crawl "$url"