#!/usr/bin/env python
'''
  %prog [-v] [-f FILE] [-i ID/URL] [SEARCH TERMS]

  A youtube jukebox. Because most every tune is on youtube. Prompts for search,
  pick from a list of choices. Repeat.

  Search prompt:
    Mode shown in [] in prompt.
    Special commands:
       + - Append mode. New choices are appended to a playlist (default).
       - - Play mode. New choices play immediately and override pending choices.
       ! - Command mode. Pass commands directly to mplayer.
      :w - Write playlist file suitable for use with -f to playlist.yt.
      :q - Quit.
     :wq - Write playlist and quit.

  Choose prompt:
    Space delimit multiple choices.
'''

import htmllib, os, re, urllib
from subprocess import Popen, PIPE

try:
    import readline
    readline.parse_and_bind('tab: complete')
    readline.set_completer_delims('')
except:
    pass

log = []

def directvid(url):
    ''' take a watch url or ID and return a video url '''
    if not url:
        return
    log.append(url)
    if not url.startswith('http://'):
        url = 'http://www.youtube.com/watch?v=%s' % url
    w = urllib.urlopen(url).readlines()
    t, video_id, q = '', '', ''

    for line in w:
        if 'PLAYER_CONFIG' in line:
            line = line.split(',')
            for i in line:
                if i.strip().startswith('"t":'):
                    t = i.split('"')[3]
                if i.strip().startswith('"video_id":'):
                    video_id = i.split('"')[3]
                if i.strip().startswith('"fmt_list":'):
                    q = i.split('"')[3]
                    q = q.split('\/')[0]
    if t and video_id and q:
        fmt = 'http://www.youtube.com/get_video?t=%s&video_id=%s&fmt=%s&asv=2'
        fnd = fmt % (t, video_id, q)
        print fnd
        return fnd

def search(srch):
    ''' given a search string, return a list of tuples (title, url) '''
    def unescape(s):
        p = htmllib.HTMLParser(None)
        p.save_bgn()
        p.feed(s)
        return p.save_end()
    if not srch:
        return
    print srch
    url = 'http://www.youtube.com/results?search_query=%s'
    vidurl = 'http://www.youtube.com%s'
    res = urllib.urlopen(url % urllib.quote_plus(srch)).readlines()
    vids = []
    for line in res:
        if 'href="/watch?' in line:
            attrs = re.findall('[a-z]+=\"[^\"]*\"', line)
            attrs = [i.split("=",1) for i in attrs]
            d = {}
            for i in attrs:
                d[i[0]] = i[1][1:-1]
            try:
                # dunno why it's escaped twice
                vid = (unescape(unescape(d['title'])), vidurl % d['href'])
            except:
                pass
            if vid not in vids:
                vids.append(vid)
    return vids

def choose(items):
    ''' pick item(s) by description out of a list of (description, item) '''
    if not items:
        return False
    for i, item in enumerate(items):
        print '%3s\t%s' % (i, item[0])
    r = raw_input(' choose: ').split(' ')
    choices = []
    for i in r:
        try:
            choices.append(items[int(i)][1])
        except:
            pass
    for choice in choices:
        print choice
    return choices

def juke(m):
    thing = m.add
    flag = '+'
    while True:
        cmd = raw_input(' search[%s] ' % flag)
        if cmd == ':q':
            break
        if cmd == ':w' or cmd == ':wq':
            fh = open('playlist.yt', 'w')
            fh.write('%s\n' % os.linesep.join(log))
            fh.close()
            print 'playlist written to playlist.yt'
            if cmd == ':wq':
                break
            continue
        if cmd == '+':
            thing = m.add
            flag = '+'
            continue
        if cmd == '-':
            thing = m.load
            flag = '-'
            continue
        if cmd == '!':
            flag = '!'
            continue
        if flag == '!':
            if not m.command(cmd):
                break
            continue
        vids = choose(search(cmd))
        if not vids:
            continue
        for vid in vids:
            if not thing(directvid(vid)):
                break

class Mplayer(object):
    ''' a wrapper around mplayer we can pass commands to '''

    def __init__(self, video=False, fifo=False):
        self.fifo = fifo
        cmd = ['mplayer', '-slave', '-idle', '-quiet']
        if not video:
            cmd += ['-vo', 'null']
        if self.fifo:
            os.mkfifo('yts.fifo')
            stdin = open('yts.fifo', 'r+')
        else:
            stdin = PIPE
        self.player = Popen(cmd, stdin=stdin, stdout=PIPE, stderr=PIPE, bufsize=1)
        self.log = []

    def command(self, cmd):
        # pass in a generic command
        if self.player.poll() is not None:
            print 'mplayer process lost, exiting'
            return False
        self.player.stdin.write('%s\n' % cmd)
        self.log.append(cmd)
        return True

    def load(self, vid):
        # load a new file
        return self.command('loadfile "%s"' % vid)

    def add(self, vid):
        # as a new file to the queue
        return self.command('loadfile "%s" 1' % vid)

    def __del__(self):
        try:
            self.player.stdin.write('quit\n')
        except IOError:
            pass
        if self.fifo:
            os.unlink('yts.fifo')

if __name__ == '__main__':
    from optparse import OptionParser

    parser = OptionParser(usage=__doc__)
    parser.add_option('-f', '--file',
                      help='play a list of IDs/URLs from FILE')
    parser.add_option('-i', '--id', action='append',
                      help='directly play an ID or URL')
    parser.add_option('-p', '--pipe', action='store_true', default=False,
                      help='get commands from a pipe.')
    parser.add_option('-v', '--video', action='store_true', default=False,
                      help='play video too (default is audio only)')
    opts, args = parser.parse_args()

    m = Mplayer(opts.video, opts.pipe)

    if opts.file and os.path.exists(opts.file):
        for vid in open(opts.file).readlines():
            m.add(directvid(vid))
    if opts.id:
        for vid in opts.id:
            m.add(directvid(vid))
    if args:
        vids = choose(search(' '.join(args)))
        if vids:
            for vid in vids:
                m.add(directvid(vid))
    try:
        juke(m)
    except KeyboardInterrupt:
        print

    for item in log:
        print item