#!/usr/bin/python

"""

Based on the code that
Lyle Scott, III wrote.
lyle@digitalfoo.net

Watches the output of a command in a
scrollable curses window.

UnixWatchCommandOutput
======================

Allows the user to input a program and watch the output.

This is pretty much the same as watch except that it allows scrolling output.

usage:
pwatch command [command args]

examples:

pwatch tree -v

pwatch grep "stuff" *

To exit, ctrl-c or ESC.

Right now, this program will refresh every 1 second, and it is not configurable.
I might update this in the future to be configurable.


Requirements:

python 2.7.2

"""
import curses
import sys
import random
import locale
import threading
import subprocess
import time
locale.setlocale(locale.LC_ALL,"")

class UnixWatchCommand:
    DOWN = 1
    UP = -1
    SPACE_KEY = 32
    ESC_KEY = 27

    PREFIX_SELECTED = '-'
    PREFIX_DESELECTED = ''

    outputLines = []
    screen = None

    def __init__(self, command):
        self.stop = threading.Event()
        self.timer=threading.Thread(target=self.display)
        self.command = ' '.join(command)
        self.screen = curses.initscr()
        curses.noecho()
        curses.cbreak()
        self.screen.keypad(1)
        self.screen.border(0)
        self.topLineNum = 0
        self.highlightLineNum = 0
        self.markedLineNums = []
        self.getOutputLines()
        self.timer.start()
        self.run()
        self.timer.join()

    def display(self):
        while not self.stop.is_set():
            try:
                self.displayScreen()
                time.sleep(1)
            except:
                break

    def run(self):
        while True:
            try:
                self.displayScreen()
                # get user command
                c = self.screen.getch()
                if c == curses.KEY_UP:
                    self.updown(self.UP)
                elif c == curses.KEY_DOWN:
                    self.updown(self.DOWN)
                elif c == self.SPACE_KEY:
                    self.markLine()
                elif c == self.ESC_KEY:
                    self.stop.set()
                    break
            except:
                self.stop.set()
                break


    def markLine(self):
        linenum = self.topLineNum + self.highlightLineNum
        if linenum in self.markedLineNums:
            self.markedLineNums.remove(linenum)
        else:
            self.markedLineNums.append(linenum)

    def check_output(self, command):

        process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE,
                                   stderr=subprocess.STDOUT,
                                   universal_newlines=True)
        output,stderr = process.communicate()
        retcode = process.poll()

        if retcode:
                self.stop.set()
                self.restoreScreen()
                raise subprocess.CalledProcessError(retcode, command,
                                                    output=output[0])
        return output.splitlines()

    def getOutputLines(self):
        self.outputLines = self.check_output(self.command)
        self.nOutputLines = len(self.outputLines)

    def displayScreen(self):
        # clear screen
        self.screen.clear()
        self.getOutputLines()
        # now paint the rows
        top = self.topLineNum
        bottom = self.topLineNum+curses.LINES
        for (index,line,) in enumerate(self.outputLines[top:bottom]):
            linenum = self.topLineNum + index
            if linenum in self.markedLineNums:
                prefix = self.PREFIX_SELECTED
            else:
                prefix = self.PREFIX_DESELECTED

            #line = '%s %s' % (prefix, line,)
            # highlight current line
            if index != self.highlightLineNum:
                self.screen.addstr(index, 0, line)
            else:
                self.screen.addstr(index, 0, line, curses.A_BOLD)
        self.screen.refresh()

    # move highlight up/down one line
    def updown(self, increment):
        nextLineNum = self.highlightLineNum + increment

        # paging
        if increment == self.UP and self.highlightLineNum == 0\
           and self.topLineNum != 0:
            self.topLineNum += self.UP
            return
        elif increment == self.DOWN and nextLineNum == curses.LINES\
             and (self.topLineNum+curses.LINES) != self.nOutputLines:
            self.topLineNum += self.DOWN
            return

        # scroll highlight line
        if increment == self.UP and (self.topLineNum != 0 or\
                                     self.highlightLineNum != 0):
            self.highlightLineNum = nextLineNum
        elif increment == self.DOWN and\
             (self.topLineNum+self.highlightLineNum+1) != self.nOutputLines\
             and self.highlightLineNum != curses.LINES:
            self.highlightLineNum = nextLineNum

    def restoreScreen(self):
        curses.initscr()
        curses.nocbreak()
        curses.echo()
        curses.endwin()

    # catch any weird termination situations
    def __del__(self):
        self.restoreScreen()


if __name__ == '__main__':
    ih = UnixWatchCommand(sys.argv[1:])
