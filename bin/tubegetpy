#!/usr/bin/python

import sys,os,re

re_generic_url = re.compile('(http[:\s\/\w\.]*(flv|mp4))')
re_kv_url = re.compile('(?<=file=)(http[:\s\/\w\.]*(flv|mp4))')

if len(sys.argv) > 1:
    os.chdir(sys.argv[1])

while True:
    line = sys.stdin.readline().strip()
    if len(line) == 0:
        continue

    source_url = line
    domain = re.search('(http[:\s\/]*[^\/]*)', line).group(1)
    page = os.popen('curl -s %s' % line).read()

    video = re.search('(http[:\s\/\w\.]*(flv|mp4))[\"]', page)
    if not video:
        player_config_url = re.search('([:\/\w\.]*playerConfig.php[^"]*)', page)

        if not player_config_url:
            video = re_kv_url.search(page)
            #print video

            if not video:
                video = re_generic_url.search(page)
                #print video

        else:
            #print player_config_url
            video = re_kv_url.search(page)
            if not video:
                video = re_generic_url.search(page)

        #print player_config_url

    if video:
        video = video.group(0)

    #print video

    has_domain = re.search('(http[:\s\/]*[^\/]*)', video) 

    if not has_domain:
        video = "%s/%s" % (domain, video)

    print video
    options = " ".join([
        '--no-use-server-timestamps',
        '--header="Referer: %s"' % source_url,
        '--user-agent="Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:30.0) Gecko/20100101 Firefox/41.0"',
        video
    ])

    os.popen('wget %s &' % options)

    with open("tube-get.sources-list.txt", "a") as log:
        log.write("%s -> %s" %( source_url, video ))

