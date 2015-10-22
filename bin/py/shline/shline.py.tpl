# -*- coding: utf-8 -*-
# vim: set filetype=python :


import argparse
import os
import sys


class Shline(object):
    symbols = {
        'patched': {
            'branch': u'\uE0A0',
            'lock': u'\uE0A2',
            'network': u'SSH',
            'separator': u'\uE0B0',
        },
        'flat': {
            'branch': '',
            'lock': 'RO',
            'network': 'SSH',
            'separator': '',
        },
    }

    color_template = '\\[\\e%s\\]'

    def __init__(self, args):
        if os.getenv('SSH_CLIENT') or os.getenv('SSH_CONNECTION'):
            args.mode = 'flat'
        self.args = args
        self.cwd = self._get_cwd()
        self.reset = self.color_template % '[0m'
        self.branch = Shline.symbols[args.mode]['branch']
        self.lock = Shline.symbols[args.mode]['lock']
        self.network = Shline.symbols[args.mode]['network']
        self.separator = Shline.symbols[args.mode]['separator']
        self.segments = []

    def _get_cwd(self):
        """ We check if the current working directory is valid or not. Typically
            happens when you checkout a different branch on git that doesn't have
            this directory.
            We return the original cwd because the shell still considers that to be
            the working directory, so returning our guess will confuse people
        """
        try:
            cwd = os.getcwd()
        except OSError:
            cwd = os.getenv('PWD')  # This is where the OS thinks we are
            parts = cwd.split(os.sep)
            up = cwd
            while parts and not os.path.exists(up):
                parts.pop()
                up = os.sep.join(parts)
            try:
                os.chdir(up)
            except OSError:
                sys.stderr.write("Your current directory is invalid.")
                sys.exit(1)
            sys.stderr.write("Your current directory is invalid. Lowest valid directory: %s" % up)
        return cwd

    def color(self, prefix, code):
        if code is None:
            return ''
        else:
            return self.color_template % ('[%s;5;%sm' % (prefix, code))

    def fgcolor(self, code):
        return self.color('38', code)

    def bgcolor(self, code):
        return self.color('48', code)

    def append(self, content, fg, bg, separator=None):
        self.segments.append((content, fg, bg, separator or self.separator))

    def draw(self):
        segments = ''.join(self.draw_segment(i) for i in range(len(self.segments)))
        return (self.reset + segments + self.reset).encode('utf-8') + ' '

    def draw_segment(self, idx):
        segment = self.segments[idx]
        next_segment = self.segments[idx + 1] if idx < len(self.segments)-1 else None

        segment_content, segment_fg, segment_bg, segment_separator = segment
        if next_segment is not None:
            next_segment_content, next_segment_fg, next_segment_bg, next_segment_separator = next_segment
        else:
            next_segment_content = next_segment_fg = next_segment_bg = next_segment_separator = None

        return ''.join((
            self.fgcolor(segment_fg),
            self.bgcolor(segment_bg),
            segment_content,
            self.bgcolor(next_segment_bg) if next_segment_bg is not None else self.reset,
            self.fgcolor(segment_bg),
            segment_separator if segment_separator != 'skip' else '',
        ))


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument('--cwd-max-depth', action='store', type=int,
            default=5, help='Maximum number of directories to show in path')
    arg_parser.add_argument('--mode', action='store', default='patched',
            help='The characters used to make separators between segments',
            choices=['patched', 'flat'])
    arg_parser.add_argument('--prev-error', action='store', type=int,
            help='Error code returned by the last command')
    arg_parser.add_argument('--jobs', action='store', type=int,
            help='Number of running jobs')
    args = arg_parser.parse_args()

    shline = Shline(args)

