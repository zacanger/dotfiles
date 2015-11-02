#!/usr/bin/env python

# Copyright (C) 2007 Christophe Kibleur <kib2@free.fr>
#
# This file is part of reSTinPeace (http://kib2.alwaysdata.net).
#
# reSTinPeace is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# reSTinPeace is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

from docutils import nodes
from docutils.parsers.rst import directives
from docutils.core import publish_cmdline, publish_file, Publisher, default_description

## Pygments
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import HtmlFormatter
from pygments.styles import STYLE_MAP
from pygments.styles import get_style_by_name
from pygments.token import Keyword, Name, Comment, String, Error, \
     Number, Operator, Generic, Whitespace

PYGMENTS_FORMATTER = HtmlFormatter(option='nowrap')
def pygments_directive(name, arguments, options, content, lineno,
                      content_offset, block_text, state, state_machine):
    try:
        lexer = get_lexer_by_name(arguments[0])
    except ValueError:
        # no lexer found
        lexer = get_lexer_by_name('text')
    parsed = highlight(u'\n'.join(content), lexer, PYGMENTS_FORMATTER)
    return [nodes.raw('', parsed, format='html')]
pygments_directive.arguments = (1, 0, 1)
pygments_directive.content = 1
directives.register_directive('sourcecode', pygments_directive)

import locale
try:
    locale.setlocale(locale.LC_ALL, '')
except:
    pass

if __name__ == "__main__":
    import docutils.core
    publish_string(writer_name='html')
