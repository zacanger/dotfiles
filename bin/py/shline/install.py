#!/usr/bin/env python2

import errno
import os
import shutil
import sys

try:
    import config
except ImportError:
    print 'Created personal config.py for your customizations'
    shutil.copyfile('config.py.dist', 'config.py')
    import config

TEMPLATE_FILE = 'shline.py.tpl'
OUTPUT_FILE = os.path.expanduser('~/.shline/shline.py')
SEGMENTS_DIR = 'segments'
THEMES_DIR = 'themes'


def load_source(srcfile):
    try:
        with open(srcfile) as f:
            return f.read() + '\n\n'
    except IOError:
        print 'Could not open', srcfile
        return ''


def makedirs(path, mode=0o755):
    try:
        os.makedirs(path, mode)
    except OSError as e:
        if e.args[0] != errno.EEXIST:
            raise


if __name__ == "__main__":
    source = load_source(TEMPLATE_FILE)
    source += load_source(os.path.join(THEMES_DIR, 'default.py'))
    source += load_source(os.path.join(THEMES_DIR, config.THEME + '.py'))
    for segment in config.SEGMENTS:
        source += load_source(os.path.join(SEGMENTS_DIR, segment + '.py'))
    source += 'sys.stdout.write(shline.draw())\n'

    try:
        makedirs(os.path.dirname(OUTPUT_FILE))
        with open(OUTPUT_FILE, 'w') as f:
            f.write(source)
        print OUTPUT_FILE, 'saved successfully'
    except IOError:
        print 'ERROR: Could not write to shline.py. Make sure it is writable'
        sys.exit(1)

