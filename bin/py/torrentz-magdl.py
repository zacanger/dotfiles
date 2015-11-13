#!/usr/bin/env python
# encoding: utf-8
# torrentz-dl.py - command-line downloader for Torrentz resources

import re
import sys
import urllib
import urllib2
import webbrowser

try:
    # pip install blessings
    from blessings import Terminal
except ImportError:
    # fallback
    class Terminal(object):
        def __getattr__(self, name):
            def _missing(*args, **kwargs):
                return ''.join(args) or None
            return _missing

try:
    # pip install lxml
    import lxml.html
    def parse_torrentz(html, item_limit=10):
        results = []
        domtree = lxml.html.fromstring(html)
        for item in domtree.cssselect('dl'):
            try:
                a = item.cssselect('dt a')[0]
                dd = item.cssselect('dd')[0]
                results.append(dict(
                    sha1=re.findall(r'^/(?P<sha1>[0-9a-f]+)$', a.get('href'))[0],
                    title=''.join(list(a.itertext())),
                    date=''.join(list(dd.cssselect('span.a')[0].itertext())),
                    size=dd.cssselect('span.s')[0].text,
                    seed=dd.cssselect('span.u')[0].text,
                    peer=dd.cssselect('span.d')[0].text))
            except IndexError:
                next
        return results[:item_limit]
except ImportError:
    # fallback
    from HTMLParser import HTMLParser
    h = HTMLParser()
    def parse_torrentz(html, item_limit=10):
        items = [m.groupdict() for m in re.finditer(r'<dl><dt><a href="/(?P<sha1>[0-9a-f]+)">(?P<title>.*)</a>', html)]
        dates = re.findall(r'<span class="a"><span title="[^"]+">(.*)</span></span>', html)
        metas = re.findall(r'<span class="[sud]+">([^<]*)</span>', html) # [size, seeds, peers]
        results = []
        for idx, item in enumerate(items[:item_limit]):
            title = h.unescape(re.sub(r'</?b>', '', item['title']))
            results.append(dict(
                sha1=item['sha1'],
                title=title,
                date=dates[idx],
                size=metas[idx*3],
                seed=metas[idx*3+1],
                peer=metas[idx*3+2]))
        return results


def query(keyword, limit=10):
    url = 'https://torrentz.eu/search'
    params = urllib.urlencode(dict(f=keyword))
    request = '%s?%s' % (url, params)
    response = urllib2.urlopen(request)
    html = response.read()

    items = parse_torrentz(html, item_limit=limit)
    return items


def ask(choices):
    t = Terminal()
    for idx, item in enumerate(choices):
        num = t.red(str(idx+1).rjust(2))
        title = item['title'].decode('utf-8')
        title = t.white((title[:80] + (title[80:] and '..')).ljust(82)) # truncate
        date = t.yellow(item['date'].rjust(10))
        size = t.cyan(item['size'].rjust(10))
        seed = t.blue(item['seed'].rjust(6))
        peer = t.green(item['peer'].rjust(6))
        print '%s. %s %s %s %s %s' % (num, title, date, size, seed, peer)
    answers = raw_input('What items do you want? (seperated by commas) [1] ')
    if answers: return map(lambda x: int(x)-1, answers.split(r','))
    else: return[0]


def download(items):
    def _build_magnet_uri(item):
        # retrieve tracker list from Torrentz
        url = 'https://torrentz.eu/%s' % item['sha1']
        html = urllib2.urlopen(url).read()
        trackers = re.findall(r'<a[^<>]*href="/tracker[^<>]*"[^<>]*>(?P<tracker>[^<>]*)</a>', html)

        # build magnet links
        dn = urllib.urlencode(dict(dn=item['title']))
        trs = '&'.join(map(lambda t: urllib.urlencode(dict(tr=t)), trackers))
        uri = 'magnet:?xt=urn:btih:%s&%s&%s' % (item['sha1'], dn, trs)
        return uri

    for item in items:
        print 'Downloading... %s' % (item['title'])
        uri = _build_magnet_uri(item)
        webbrowser.open(uri)


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print 'Usage: %s <keyword>' % sys.argv[0]
        print "Example: %s 'The Big Bang Theory S07E01'" % sys.argv[0]
        sys.exit(1)
    keyword = sys.argv[1]
    choices = query(keyword)
    chosen_ids = ask(choices)
    chosens = map(lambda idx: choices[idx], chosen_ids)
    download(chosens)
