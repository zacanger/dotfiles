#!/usr/bin/env python2

import curses
import signal
import traceback
import time

import getopt, sys

DIGIT_WIDTH = 5
DIGIT_HEIGHT = 5
DIGIT_SPACING = 2

'''
_0_0_._0_0_0_
'''

width = 7*DIGIT_SPACING + 6*DIGIT_WIDTH 
height = 2*DIGIT_SPACING + DIGIT_HEIGHT


# numbers, list of coords in (y,x)

digits = [
    [
        "#####",
        "#   #",
        "#   #",
        "#   #",
        "#####"
        ],
    [
        "  #  ",
        " ##  ",
        "  #  ",
        "  #  ",
        " ### ",
        ],
    [
        "#####",
        "    #",
        "#####",
        "#    ",
        "#####",
        ],
    [
        "#####",
        "    #",
        " ####",
        "    #",
        "#####",
        ],
    [
        "#   #",
        "#   #",
        "#####",
        "    #",
        "    #",
        ],
    [
        "#####",
        "#    ",
        "#####",
        "    #",
        "#####",
        ],
    [
        "#####",
        "#    ",
        "#####",
        "#   #",
        "#####",
        ],
    [
        "#####",
        "    #",
        "    #",
        "    #",
        "    #",
        ],
    [
        "#####",
        "#   #",
        "#####",
        "#   #",
        "#####",
        ],
    [
        "#####",
        "#   #",
        "#####",
        "    #",
        "    #",
        ],
    [
        "",
        "",
        "",
        "",
        "  # ",
        ],
]

def draw_digit(win, digit, y, x):
    sections = digits[digit]
    position = 0
    for section in sections:
        xpos = x
        for char in section:
            if char == ' ':
                win.addstr(position+y, xpos, ' ', curses.color_pair(0))
            else:
                win.addstr(position+y, xpos, ' ', curses.color_pair(1))
            xpos += 1
        position += 1

def draw_time(win, digits):
    h,w = win.getmaxyx()
    x_pos = (w - width) / 2
    y_pos = (h - height) / 2
    x_pos += DIGIT_SPACING
    y_pos += 1
    digits.insert(2, 10) #add in the point
    for d in digits:
        draw_digit(win, d, y_pos, x_pos)
        x_pos += (DIGIT_SPACING + DIGIT_WIDTH)

def tick(win):
    tm = time.localtime()
    t = ks = tm.tm_hour*3600 + tm.tm_min*60 + tm.tm_sec
    a = ks/10000; ks -= a*10000
    b = ks/1000; ks -= b*1000
    c = ks/100; ks -= c*100
    d = ks/10; ks -= d*10
    e = ks
    draw_time(win, [a,b,c,d,e])
    return t
    
def draw_dots(win):
    h,w = win.getmaxyx()
    x_pos = (w - width) / 2
    y_pos = (h - height) / 2
    win.hline(y_pos,x_pos,curses.ACS_BULLET, width, curses.color_pair(2))
    win.hline(y_pos+DIGIT_HEIGHT+1,x_pos,curses.ACS_BULLET, width, curses.color_pair(2))
    win.vline(y_pos+1,x_pos,curses.ACS_BULLET, DIGIT_HEIGHT, curses.color_pair(2))
    win.vline(y_pos+1,x_pos+width-1,curses.ACS_BULLET, DIGIT_HEIGHT, curses.color_pair(2))


def init_screen():
    screen = curses.initscr()
    curses.noecho()
    curses.cbreak()
    screen.clear()
   
def main(screen, fg, bg):
    curses.curs_set(0) #hide cursor
    screen.nodelay(1) # don't wait for input

    curses.use_default_colors()

    curses.init_pair(1, fg, fg)
    curses.init_pair(2, fg, bg)

    screen.bkgd(' ', curses.color_pair(2))

    def screen_resize(*args):
        while 1:
            try: curses.endwin(); break
            except: time.sleep(1)
        screen.erase()
        draw_dots(screen)
        screen.refresh()

    signal.signal(signal.SIGWINCH, screen_resize)

    draw_dots(screen)


    t = None
    while True:
        newtime = tick(screen)
        if t != newtime:
            screen.refresh()
        t = newtime

        c = screen.getch()
        if c == ord('q'):
            break
        
        time.sleep(0.5)


def usage():
    print '''curses_clock.py [OPTION]

  -h, --help displays this help
  -f, --fg=COLORCODE sets the foreground color to COLORCODE
  -b, --bg=COLORCODE sets the background color to COLORCODE


Color codes available:
  default term fg/bg -1
  black   0
  red     1
  green   2
  yellow  3
  blue    4
  magenta 5
  cyan    6
  white   7
'''



if __name__ == '__main__':
    bg = 0
    fg = 7

    def do_color(arg):
        try:
            color = int(arg)
        except:
            color = -1
        if not -1 <= color <= 7:
            print "Color code not in correct range"
            usage()
            sys.exit(2)
        else:
            return color
            

    try:
        opts, args = getopt.getopt(sys.argv[1:], "hf:b:", ["help", "fg=", "bg="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit()
        elif opt in ("-f", "--fg"):
            fg = do_color(arg)
        elif opt in ("-b", "--bg"):
            bg = do_color(arg)


    curses.wrapper(main, fg, bg)

