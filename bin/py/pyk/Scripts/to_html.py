#!/usr/bin/env python

# A utiliser par exemple comme ceci
# python kib.py --stylesheet-path="default.css" --language=fr pyqt4.rst newpyqt4.html

from docutils import nodes
from docutils.parsers.rst import directives
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import HtmlFormatter
from docutils.core import publish_cmdline, publish_parts, Publisher, default_description

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

description = ('Generates (X)HTML documents from standalone reStructuredText '
               'sources.  ' + default_description)

if __name__ == "__main__":
    import docutils.core
    publish_cmdline(writer_name='html', description=description)
