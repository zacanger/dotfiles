#!/usr/bin/env python
# -*- coding: utf-8 -*-

import argparse
import re
import httplib
import urllib
from pyquery import PyQuery as pq

parser = argparse.ArgumentParser(
        description='Download video resource from tudou.com',
        epilog="Parse the url to video address using flvcd.com")
parser.add_argument('-q', '--quality',
        default=4, type=int, dest='quality',
        help="""Quality of source to download,
        values in 0(256P),1(360P),2(480P),3(720P),4(REAL).
        REAL by default.
        Note:
        If the specific resolution is not avaliable the lower nearest will be downloaded""")
parser.add_argument('-o', '--output-pattern',
        default='%{n}%-{x}', dest='pattern',
        help="""Define the output filename format(%%n by default):
        %%{n} - Video name section.
        %%{x} - Clip index of the video.
        e.g. %{n}%-{x} will produce filename-0001.vod or filename.vod
        """)
parser.add_argument('-w', '--wait',
        default=2, type=int, dest='wait',
        help="Set the time to wait between start next task(in second, default 2).")
parser.add_argument('-D', '--debug',
        default=False, dest='debug', action='store_true',
        help="Run command in debug mode")
parser.add_argument('-d', '--new-directory',
        default=False, dest='mkdir', action='store_true',
        help="Create new directory for the download")
parser.add_argument('-c', '--clean',
        default=False, dest='clean', action='store_true',
        help="Clean old file before start(for sites unavaliable for partial)")
parser.add_argument('-m', '--merge-split',
        default=False, dest='merge', action='store_true',
        help="Auto merge videos together(Not Implemented)")
parser.add_argument('-s', '--spider',
        default=False, dest='detect', action='store_true',
        help="Only detect for video information but not download.")
parser.add_argument('-U', '--user-agent',
        default=r"Mozilla/5.0 (X11; Linux x86_64; rv:7.0.1) Gecko/20100101 Firefox/7.0.1",
        dest='ua',
        help="Specific the User-Agent.")
parser.add_argument('-O', '--wget-options',
        default="",
        dest='wgetopt',
        help="Specific the wget Parameter.")
parser.add_argument('url', help='The URL of the video')

#arguments here
global args
args = parser.parse_args()

resolution = [
        ('normal'    , 'Normal'),
        ('high'      , '360P'),
        ('super'     , '480P'),
        ('super2'    , '720P'),
        ('real'      , 'REAL(DEFAULT)')
        ]

print "Video address to parse:"
print "\t%s" % (args.url)
print "Quality:", resolution[args.quality][1]
print "Pattern:", args.pattern, "+ *ext*"
print "User-Agent:"
print "\t%s" % (args.ua)

if args.debug:
    print "Debug:", args.debug
    print "New Dir.:", args.mkdir

def parse(url, ua, fmt):
    http = httplib.HTTP("www.flvcd.com")
    http.putrequest("GET", "/parse.php?format=%s&kw=%s" % (fmt,
        urllib.quote(url)))
    http.putheader("User-Agent", ua)
    http.putheader("Host", "www.flvcd.com")
    http.putheader("Accept", "*/*")
    http.endheaders()
    errcode, errmsg, headers = http.getreply()
    print "Status:", errcode, errmsg
    if errcode!=200:
        print "Error encountered while parsing url"
        return -1
    res = http.getfile()
    print 'Parsing video address...'
    html = ''
    data = res.read(512)
    while data != '':
        html += data
        data = res.read(512)
    html = html.decode('gbk')
    return html

html = parse(args.url, args.ua, resolution[args.quality][0])

if html == -1:
    exit(1)

q = pq(html)

# Address Parsing Procedure

form = q('form[name="mform"]')

file_a = form.parent('td').parent('tr').prev().children().children('a')
filelist = []
for i in file_a:
    a = pq(i)
    filelist.append(a.attr('href'))

filename = form('input[name="name"]').val()

formats = form.parent().children('a')

if not filename:
    print """
    Video is not available for download.
    Check http://www.flvcd.com/url.php for available sites.
    Or the video is protected from playing by guests.
    """
    exit(0)

print "Video Title:"
print "\t%s" % (filename)
print

if args.debug:
    print "Download Address:"
    for i in filelist:
        print i
    print

if len(formats) > 0:
    print "Optional format:"

    for i in formats:
        f = pq(i)
        href = f.attr('href')
        text = f.text()
        for i in xrange(len(resolution)):
            k, v = resolution[i]
            if href.find(k) != -1:
                print "\t%d - %s[%s]" % (i, v, text)
                break
    print

if args.detect:
    exit(0)

filepath = filename.replace("/", "_").encode('utf8')

print "Found %d video clip(s) to download" % len(filelist)
print

import os, time

if args.mkdir:
    print 'Creating new dir:', filepath
    os.system('mkdir "%s" 2>/dev/null 1>/dev/null' % filepath)
    os.chdir(filepath)

print 'Current directory:'
print "\t", os.getcwd()
os.system('''echo "#!/bin/bash
%s -q%s -O=\\"%s\\" \\"%s\\" \$@" > "%s.to" && chmod +x "%s.to"
        ''' % \
        (__file__,args.quality,args.wgetopt,args.url,
            filepath,filepath))
print

def getFileExt(u):
    if u.find('f4v')!=-1:
        return '.f4v'
    if u.find('mp4')!=-1:
        return '.mp4'
    if u.find('flv')!=-1:
        return '.flv'
    if u.find('hlv')!=-1:
        return '.flv'
    return ".video"

fSuccess = True

def sformat(string, symbol, value):
    tokens = string.split('%')
    filtered = []
    for s in tokens:
        if s.find('{' + symbol + '}') < 0:
            filtered.append(s)
        else:
            if value:
                filtered.append(s.replace('{' + symbol + '}', value))
    return '%'.join(filtered)

for i in xrange(len(filelist)):
    url = filelist[i]

    local = args.pattern
    local = sformat(local, 'n', filepath)
    if len(filelist) > 1:
        local = sformat(local, 'x', '%04d' % (i + 1))
    else:
        local = sformat(local, 'x', None)
    local = local.replace('%',"").replace('/',"_") + getFileExt(url)

    print "Download", local, "..."

    if os.path.exists(local):
        print "Target already exists, skip to next file!"
        continue

    rmcmd = "rm -f %s 1>/dev/null 2>/dev/null" % (local+" ."+local)

    if args.clean:
        print "Before we start, clean the unfinished file"
        os.system(rmcmd)

    syscmd = 'wget -c ' + args.wgetopt + ' "' + url + '" -U "' + args.ua + '" -O ".' + local + '"'
    if args.debug:
        print syscmd
        continue

    rtn = os.system(syscmd)
    mvcmd = 'mv "%s" "%s" 1>/dev/null 2>/dev/null' % ('.' + local, local)
    if rtn == 0:
        os.system(mvcmd)
    elif rtn == 2048:
        # Server issued an error response.
        print "Server Error detected, remove part file and retry."
        os.system(rmcmd)
        rtn = os.system(syscmd)
        if rtn == 0:
            os.system(mvcmd)
        else:
            fSuccess = False;
        if rtn == 2048:
            print "Server error again, address may be expired."
            if args.clean:
                os.system(rmcmd)
            continue
    else:
        fSuccess = False;
    time.sleep(args.wait + 0.1)

if fSuccess:
    os.system('rm "%s.to"' % (filepath))

print "All tasks completed."
exit(0)
