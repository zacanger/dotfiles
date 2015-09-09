#!/usr/bin/python
#
# Generate a HTML directory listing of a local directory.
# (c) 2009, Mason Larobina <mason.larobina@gmail.com>
#
# Usage:
#   @on_event LOAD_ERROR spawn @scripts_dir/gendirlist.py %1
 
import sys
from os import path, listdir
from os.path import isdir, realpath, join
from urllib import quote
from base64 import b64encode as encode
import time
 
# Debugging.
import pprint
pprint.pprint(list(enumerate(sys.argv)))
 
# uri setting and HTML encoding function
def set_html(html):
    return "set uri = data:text/html;base64,%s" % encode(html)
 
ESCAPES = {'<': '&lt;', '>': '&gt;'}
def escape(html):
    for (old, new) in ESCAPES.items():
        html = html.replace(old, new)
 
    return html
 
fifo, uri = sys.argv[4], sys.argv[8]
 
if uri.startswith("file://"):
    uri = uri[7:]
 
elif uri.startswith('http://') or uri.startswith('https://'):
    sys.exit(0)
 
dir = realpath(uri)
if not isdir(dir):
    sys.exit(0)
 
def send(cmd):
    fh = open(fifo, 'w')
    print "<--", cmd
    fh.write('%s\n' % cmd)
    fh.close()
 
links = []
link = links.append
 
ld = [f for f in listdir(dir) if not f.startswith('.')]
ld = sorted([(not isdir(join(dir, f)), f) for f in ['..']+ld])
 
LINK_FORMAT = '[%3s] <a href="javascript:void()" local="file://%s">%s</a>'
for (isfile, f) in ld:
    fp = join(dir, f)
    link(LINK_FORMAT % ('' if isfile else "DIR", quote(fp), escape(f)))
 
HTML_FORMAT = '''
<html><head>
<title>Directory listing for: %s</title>
</head><body><pre>
%s
</pre></body></html>'''
 
send(set_html(HTML_FORMAT % (escape(dir), '<br>'.join(links))))
 
time.sleep(0.1)
 
send("js %s" % ' '.join(filter(None, map(str.strip, '''
var last_links = 0;
var count = 0;
var run = Uzbl.run;
function set(k,v) { run('set '+k+' = '+v) };
 
function fix_links() {
    var links = document.links;
    for (var i = 0; i < links.length; i++) {
        links[i].onclick = function () {
            set('uri', this.getAttribute('local'));
        };
    };
    if(!last_links || last_links != links.length) {
        last_links = links.length;
        count++;
        setTimeout(fix_links, 500);
    };
};
 
fix_links();
'''.split('\n')))))
 
send('event LOAD_PROGRESS 100')