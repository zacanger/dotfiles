#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright © 2011 Nicolas Paris <nicolas.caen@gmail.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import re
import sys
import urllib

class DownForEveryone(object):
    base_url = 'http://www.downforeveryoneorjustme.com/'

    def __init__(self):
        self.parse_url()
        self.is_url()
        self.get_answer(
            urllib.urlopen(self.base_url+self.url).read()
        )

    def parse_url(self):
        try:
            self.url = sys.argv[1]
        except IndexError:
            self.usage()

    def is_url(self):
        url_regex = 'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+'
        resp = re.findall(url_regex, self.url)
        if len(resp) != 1:
            print 'The argument does not seems to be an URL'
            self.usage()

    def get_answer(self, response):
        up = 'It\'s just you.'
        down ='It\'s not just you!'
        if up in response:
            print '\033[1;32m{} {} {}\033[1;m'.format(up, self.url, 'is up.')
        elif down in response:
            print '\033[1;31m{} {} {}\033[1;m'.format(down, self.url, 'looks down from here.')
        else:
            print 'Error to find the answer'

    def usage(self):
        print 'Usage:'
        print '   {} http://www.example.com'.format(sys.argv[0])
        sys.exit(0)

if __name__ == '__main__':
    DownForEveryone()