#!/usr/bin/env python
from __future__ import print_function
# Pyperclip v1.3
# A cross-platform clipboard module for Python. (only handles plain text for now)
# By Al Sweigart al@coffeeghost.net

# Usage:
#   import pyperclip
#   pyperclip.copy('The text to be copied to the clipboard.')
#   spam = pyperclip.paste()

# On Mac, this module makes use of the pbcopy and pbpaste commands, which should come with the os.
# On Linux, this module makes use of the xclip command, which should come with the os. Otherwise run "sudo apt-get install xclip"


# Copyright (c) 2010, Albert Sweigart
# All rights reserved.
#
# BSD-style license:
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the pyperclip nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY Albert Sweigart "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL Albert Sweigart BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Change Log:
# 1.2 Use the platform module to help determine OS.
# 1.3 Changed ctypes.windll.user32.OpenClipboard(None) to ctypes.windll.user32.OpenClipboard(0), after some people ran into some TypeError
# 1.4 Use python-which library instead of os.system, removing a bunch of noise
# 1.5 add Cygwin support, command line interface & cleaned up command usage

import platform, os, subprocess, sys, re

def winGetClipboard():
    ctypes.windll.user32.OpenClipboard(0)
    pcontents = ctypes.windll.user32.GetClipboardData(1) # 1 is CF_TEXT
    data = ctypes.c_char_p(pcontents).value
    #ctypes.windll.kernel32.GlobalUnlock(pcontents)
    ctypes.windll.user32.CloseClipboard()
    return data

def winSetClipboard(text):
    GMEM_DDESHARE = 0x2000
    ctypes.windll.user32.OpenClipboard(0)
    ctypes.windll.user32.EmptyClipboard()
    try:
        # works on Python 2 (bytes() only takes one argument)
        hCd = ctypes.windll.kernel32.GlobalAlloc(GMEM_DDESHARE, len(bytes(text))+1)
    except TypeError:
        # works on Python 3 (bytes() requires an encoding)
        hCd = ctypes.windll.kernel32.GlobalAlloc(GMEM_DDESHARE, len(bytes(text, 'ascii'))+1)
    pchData = ctypes.windll.kernel32.GlobalLock(hCd)
    try:
        # works on Python 2 (bytes() only takes one argument)
        ctypes.cdll.msvcrt.strcpy(ctypes.c_char_p(pchData), bytes(text))
    except TypeError:
        # works on Python 3 (bytes() requires an encoding)
        ctypes.cdll.msvcrt.strcpy(ctypes.c_char_p(pchData), bytes(text, 'ascii'))
    ctypes.windll.kernel32.GlobalUnlock(hCd)
    ctypes.windll.user32.SetClipboardData(1,hCd)
    ctypes.windll.user32.CloseClipboard()

def gtkGetClipboard():
    return gtk.Clipboard().wait_for_text()

def gtkSetClipboard(text):
    cb = gtk.Clipboard()
    cb.set_text(text)
    cb.store()

def qtGetClipboard():
    return str(cb.text())

def qtSetClipboard(text):
    cb.setText(text)

def has_command(cmd):
    from which import which, WhichError
    try:
        which(cmd)
        return True
    except WhichError as e:
        return False

class CommandClipboard(object):
    def __init__(self, copy, paste):
        self._copy = copy
        self._paste = paste
        self.required_cmds = set([copy[0], paste[0]])

    @property
    def available(self):
        return all(map(has_command, self.required_cmds))

    def copy(self, data):
        p = subprocess.Popen(self._copy, stdin=subprocess.PIPE)
        if sys.version_info > (3,):
            data = data.encode('utf-8')
        out, err = p.communicate(data)
        assert p.returncode == 0

    def paste(self):
        p = subprocess.Popen(self._paste, stdout=subprocess.PIPE)
        out, err = p.communicate()
        assert p.returncode == 0
        if sys.version_info > (3,):
            out = out.decode('utf-8')
        return out

    def use(self):
        global getcb, setcb
        getcb = self.paste
        setcb = self.copy

if os.name == 'nt' or platform.system() == 'Windows':
    import ctypes
    getcb = winGetClipboard
    setcb = winSetClipboard
elif os.name == 'mac' or platform.system() == 'Darwin':
    CommandClipboard(copy=['pbcopy'],paste=['pbpaste']).use()
else:
    possible_impls = [
        CommandClipboard(copy=['putclip'], paste=['getclip']), # cygwin
        CommandClipboard(copy=['xsel','-ib'], paste=['xsel','-b']),
        CommandClipboard(copy=['xclip', '-selection', 'clipboard','-i'],
                         paste=['xclip', '-selection', 'clipboard', '-o'])
    ]

    for impl in possible_impls:
        if impl.available:
            impl.use()
            break
    else:
        try:
            import gtk
            getcb = gtkGetClipboard
            setcb = gtkSetClipboard
        except ImportError:
            try:
                import PyQt4.QtCore
                import PyQt4.QtGui
                cb = PyQt4.QtGui.QApplication.clipboard()
                getcb = qtGetClipboard
                setcb = qtSetClipboard
            except ImportError:
                raise ImportError('Pyperclip requires the gtk or PyQt4 module installed, or some sort of xclip / xsel / getclip command.')

copy = setcb
paste = getcb

if __name__ == '__main__':
    from optparse import OptionParser
    p = OptionParser()
    p.add_option('-i','--copy', action='store_const', const=copy, dest='action', default=paste)
    p.add_option('-o','--paste', action='store_const', const=paste, dest='action')
    opts, args = p.parse_args()
    assert len(args) == 0
    args = []
    if opts.action is copy:
        data = sys.stdin.read()
        data = re.sub('\r?\n?$', '', data) # trim trailing NL
        args.append(data)
    ret = opts.action(*args)
    if ret is not None:
        print(ret)
