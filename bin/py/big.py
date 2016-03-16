#!/usr/bin/env python
# encoding: utf-8

import logging
import markdown2
from optparse import OptionParser
import re
import sys
import urllib2

logging.basicConfig(format="%(message)s",level=logging.INFO)


def main():
    # Options parsing
    parser = OptionParser()
    parser.add_option("-s", "--slides",
        dest="filename",
        help="markdown file holding your slides!",
        default='slides.md',
        metavar="SLIDES.md")

    parser.add_option("-c", "--css",
        dest="css_filename",
        help="big stylesheet",
        default='big.css',
        metavar="big.css")

    parser.add_option("-j", "--js",
        dest="js_filename",
        help="big javascript",
        default='big.js',
        metavar="big.js")

    parser.add_option("-m", "--mode",
        dest="mode",
        default="remote",
        help="mode: remote, local"
        "[default: %default]")

    parser.add_option("-t", "--template_mode",
                      default="allinone",
                      help="template mode: allinone, light "
                           "[default: %default]")
    (options, args) = parser.parse_args()

    #Open and handle files
    logging.info('Attempting to open slide file: '+options.filename)
    try:
        f = open(options.filename, 'r')
        slides = f.read()
    except:
        logging.info('Error opening slide file: '+options.filename)
        sys.exit()

    slide_filename = options.filename.replace('.md','.html')

    #grab the big css/js files
    if options.mode == 'local':
        logging.info('Local css/js selected')
        try:
            css = open(options.css_filename, 'r').read()
        except:
            logging.info('Error opening css file: '+options.css_filename)
            sys.exit()

        try:
            js = open(options.js_filename, 'r').read()
        except:
            logging.info('Error opening js file: '+options.js_filename)
            sys.exit()
    elif options.mode == 'remote':
        logging.info('Remote css/js selected')
        options.js_filename = "https://raw.github.com/tmcw/big/gh-pages/big.js"
        options.css_filename = "https://raw.github.com/tmcw/big/gh-pages/big.css"

        try:
            logging.info('Pulling css from: '+options.css_filename)
            css = urllib2.urlopen(urllib2.Request(options.css_filename)).read()
        except:
            logging.info('Error opening js url: '+options.css_filename)
            sys.exit()
        try:
            logging.info('Pulling js from: '+options.js_filename)
            js = urllib2.urlopen(urllib2.Request(options.js_filename)).read()
        except:
            logging.info('Error opening js url: '+options.js_filename)
            sys.exit()

    #parse the markdown file
    logging.info('Parsing markdown file')
    head_matter, new_slides =  re.split('(% .*\n.*\n.*\n\n)', slides)[1:]
    title, author, date = head_matter.replace('% ','%').replace('\n','').split("%")[1:]
    logging.info('\tTitle: '+title)
    logging.info('\tAuthor: '+author)
    logging.info('\tDate: '+date)

    slides = new_slides.split('#')[1:]
    logging.info('\tNumber of slides: '+str(len(slides)))

    #define templates
    allinone_header = u"""<!DOCTYPE html><html><head><title>"""+title+"""</title><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" /><style type='text/css'>"""+css+"""</style><script type='text/javascript'>"""+js+"""</script></head><body>"""
    light_header = u"""<!DOCTYPE html><html><head><title>"""+title+"""</title><meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=0" /><link href='"""+options.css_filename+"""' rel='stylesheet' type='text/css' /><script src='"""+options.js_filename+"""'></script></head><body>"""

    slide_html = []
    #generate html from markdown
    for s in slides:
        slide_html.append(u"<div>" + markdown2.markdown(s).replace('<p>','').replace('\n','').replace('</p>','') +"</div>")

    #generate html
    html = u""
    if options.template_mode == 'allinone':
        logging.info('Allinone template mode ')

        html = html + allinone_header
    elif options.template_mode == 'light':
        logging.info('Light template mode ')
        html = html + light_header

    html = html + "\n".join(slide_html)

    logging.info('Writing HTML: '+slide_filename)
    f = open(slide_filename, 'w')
    f.write(html.encode('utf8'))
    f.close()


if __name__ == '__main__':
    main()
