#!/usr/bin/python

import curses
import random

stdscr = curses.initscr()
curses.noecho()
curses.cbreak()
stdscr.keypad(1)
curses.halfdelay(1)


bg_frame = 'QlpoOTFBWSZTWbQ7eg8AAMr7gH/doChY84AQAATAAAAFMAF5QmDQEaEj00I0AyETaJqA9RoAGgCQkRoQjJoYEycRcmNn8JgkdWl1b9yeX1arHCrZQdpdJIGxJB6aEgzYB7ruc8VmVYsQ9WxWrvWPhlxxEqvBsyvw4iTxZwwNiD5QrmDIxRGKLWGUbmaaXxlps9c8t402JqzLay7FleFPkDSzMQg1thxMocVSOoYGvY3DYqWlms3MrxqgwBwjcJ0rQdy4RfmROTTYlz1Y8fJQ07dGkQ4F/F5dtrSQRxtXR3e4t3o338YtLd9vNYnGs754BlgKMk+bGH9JuYnrtylI7gS0NTGA0IyZmt+u6oiSqmdA1mEhp5IqGAYExHK0HIQaAsXtcyUig5VsziVGAHrbKalM/riEKj+SlgWsVJAy5oYEzxjJDNHH4u5IpwoSFodvQeA='.decode('base64').decode('bz2')
main_dec = []
minor_decs = []
for y, bg_line in enumerate(bg_frame.split('\n')):
  for x, bg_char in enumerate(bg_line):
    if bg_char in '~*':
      minor_decs.append((y, x, bg_char))
    if y > 7: continue
    if bg_char in '()':
      if bg_char is '(' and bg_line[x+2] is not ')':
        main_dec.append((y, x, bg_char))
      if bg_char is ')' and bg_line[x-2] is not '(':
        main_dec.append((y, x, bg_char))

stdscr.addstr(0, 0, bg_frame)
stdscr.refresh()
denominator = 3
finalized = False
keyin = stdscr.getch()
while keyin is -1 or not finalized:
  if keyin is not -1:
    finalized = True
  random.shuffle(main_dec)
  random.shuffle(minor_decs)
  for index, dec in enumerate(main_dec[:len(main_dec)/denominator]):
    if not finalized:
      main_dec[index] = (dec[0], dec[1], '()'.strip(dec[2]))
    else:
      main_dec[index] = (dec[0], dec[1], ',')
    stdscr.addstr(dec[0], dec[1], main_dec[index][2])
  for index, minor_dec in enumerate(minor_decs[:len(minor_decs)/denominator]):
    minor_decs[index] = (minor_dec[0], minor_dec[1], '*~'.strip(minor_dec[2]))
    stdscr.addstr(minor_dec[0], minor_dec[1], minor_decs[index][2])
  stdscr.move(0, 0)
  stdscr.refresh()
  keyin = stdscr.getch()


curses.nocbreak()
stdscr.keypad(0)
curses.echo()
curses.endwin()