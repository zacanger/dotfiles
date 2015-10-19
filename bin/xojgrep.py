#!/usr/bin/python3
# vim: set fileencoding=utf-8 ts=4 sts=4 sw=4 tw=80 expandtab :

# Copyright (C) 2012 Florian Bruhin <xojgrep@the-compiler.org>

# xojgrep is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# xojgrep is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with xojgrep.  If not, see <http://www.gnu.org/licenses/>.

import sys
import os
import argparse
import gzip
import lxml.etree
import pyPdf

def main():
    options = parseargs()


def istextfile(filename, blocksize=512):
    """ Uses heuristics to guess whether the given file is text or binary,
    by reading a single block of bytes from the file.
    If more than 30% of the chars in the block are non-text, or there are NUL
    ('\x00') bytes in the block, assume this is a binary file.

    Based on http://s.cmpl.cc/n
    """
    _text_characters = (
        b''.join(bytes((i,)) for i in range(32, 127)) + # Printable ASCII chars
        b'\n\r\t\f\b' # Control chars commonly used in text
    )
    with open(filename, 'rb') as f:
        block = f.read(blocksize)
    if b'\x00' in block:
        # Files with null bytes are binary
        return False
    elif not block:
        # An empty file is considered a valid text file
        return True
    # Use translate's 'deletechars' argument to efficiently remove all
    # occurrences of _text_characters from the block
    nontext = block.translate(None,  _text_characters)
    return float(len(nontext)) / len(block) <= 0.30


def getfilelist(path):
    filelist = []  
    for root, dirnames, filenames in os.walk(path):
        filelist.append(os.path.join(root, filename))
    return filelist


def parseargs():
    """ Parses the command-line arguments """
    parser = argparse.ArgumentParser(
        description='Grep xoj, text and pdf files from one tool.',
        epilog='FIXME',
    )
    parser.add_argument('file', nargs='+', default=None, help='File name')
    options = parser.parse_args()
    return options


class XOJFile:
    def __init__(self, filename):
        with gzip.open(filename) as f:
            # FIXME check for invalid files
            try:
                self.tree = lxml.etree.parse(f)
            except lxml.etree.XMLSyntaxError:
                self.tree = None
                raise # FIXME output error

    def getcontent(self):
        content = []
        # TODO check if that works with a xournal file without texts
        pagecount = len(self.tree.xpath('/xournal/page'))
        for pn in range(1, pagecount + 1):
            texts = self.tree.xpath('/xournal/page[{}]//text'.format(pn))
            for text in texts:
                for line in text.split('\n'):
                    content.append((pn, line))
        return content


class PDFFile:
    def __init__(self, filename):
        self.pdffile = open(filename, 'rb')
        self.doc = pyPdf.PdfFileReader(self.pdffile)

    def __del__(self):
        self.pdffile.close()

    def getcontent(self):
        pagecount = self.doc.numPages
        content = []
        for pn in range(0, pagecount):
            page = self.doc.getPage(pn)
            text = page.extractText()
            for line in text.split('\n'):
                content.append((pn + 1, text))
        return content


class TXTFile:
    def __init__(self, filename):
        self.txtfile = open(filename, 'r')

    def __del__(self):
        self.txtfile.close()

    def getcontent(self):
        content = []
        for (ln, line) in enumerate(self.txtfile, 1):
            content.append((ln, line.rstrip('\n')))
        return content


if __name__ == '__main__':
    sys.exit(main())
