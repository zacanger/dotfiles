#!/usr/bin/python
#
# Exercises terminal abilities to help diagnose terminal color
# problems.
#
# Placed in the public domain by Mark Schreiber <mark7@alumni.cmu.edu>

import getopt
import curses
import os
import sys

g_valid_tests = ["term", "terminfo", "curses", "grid16", "grid256",
                 "gridtrue"]
g_tests = []

# Pad a string with trailing spaces to the specified length
def pad_string(string, length):
    padlen = length - len(string)
    return string + (padlen * " ")

# Get number used to set 8 color terminal
def get_8color_string(color, bold, fg):
    if fg:
        colorcode=30
    else:
        colorcode=40
    colorcode += color
    if bold:
        return "[%d;1m" % colorcode
    else:
        return "[%dm" % colorcode

# Set 8 color terminal to bold or non-bold, foreground or background
def set_8color(color, bold, fg):
    colorstring = get_8color_string(color, bold, fg)
    sys.stdout.write("\x1b%s" % colorstring)

def set_color_normal():
    sys.stdout.write("\x1b[0m")
    
def print_16color_grid():
    print "Background | Foreground colors"
    for bg in range(0, 8):
        for bd in [False, True]:
            if (not bd):
                sys.stdout.write("%s       |"
                                 % get_8color_string(bg, False, False))
            else:
                sys.stdout.write("           |")
            set_8color(bg, False, False)
            for fg in range(0, 8):
                set_8color(fg, bd, True)
                sys.stdout.write("%s" % pad_string(
                        get_8color_string(fg, bd, True), 7))
            set_color_normal()
            sys.stdout.write("\n")
        print "-" * 68

def prompt():
    sys.stdout.write("\nHit enter to continue...")
    sys.stdin.readline()
    print

def add_test(testname):
    global g_tests, g_valid_tests
    valid_tests = dict(zip(g_valid_tests, g_valid_tests))
    if testname == "all":
        g_tests += g_valid_tests
    else:
        if testname in valid_tests:
            g_tests.append(testname)
        else:
            print >>sys.stderr, "Error: unknown test '%s'" % testname
            exit(1)

def test_term():
    print("""Normally, your terminal's characteristics should be
indicated by the contents of the environment variable TERM.  On your
system, this is currently:\n\n '%s'""" % os.environ['TERM'])

    print("""\nFor terminals that support 256 colors, at the time of
this writing, this often 'xterm-256color'.""")

def test_terminfo():
    print("""We will try using the terminfo database, which relies on TERM,
to make this text:\n""")

    rc=os.system("tput setaf 1")

    print("  red")

    os.system("tput sgr0")

    if (rc == 0):
        print("""\nThis succeeded, which means that your system's terminfo
database probably understands that your TERM type supports 16 colors.""")
    else:
        print("""\nThis failed, which means that your system's
terminfo database may not understand that your TERM type supports 16
colors.""")

def test_curses():
    print("""Curses is a commonly-used library that relies on
terminfo.  Many applications will not be able to use color if curses
cannot display color.  This may clear your terminal.  Checking
whether curses believes that this terminal supports color:""")

    prompt()

    try:
        curses.initscr()

        curses_can_change = curses.can_change_color()

        curses.endwin()
    except:
        curses_can_change = False

    if (curses_can_change):
        print("Curses supports changing color on this terminal")
    else:
        print("Curses does not support changing color on this terminal")

def test_grid16():
    print("""We will now attempt to display a 16 color grid of escape
sequences to let you see what each combination of foreground and
background color look like.  This will ignore the terminfo database.
If your terminal supports 16 colors, this should still show colors,
even if TERM is not set correctly:\n""")

    print_16color_grid()

def set256color(i):
    sys.stdout.write("\x1b[48;5;%dm" % i)

def test_grid256():
    print("""We will now display all 256 colors using an xterm
extension.  This test ignores terminfo, so should work even if TERM is
not set correctly:\n""")
    print("Old-style colors:")
    for i in range(0, 16):
        set256color(i)
        sys.stdout.write(" ")
    set_color_normal()
    
    print("\nAdditional colors:")
    for i in range(0, 6):
        for j in range(0, 6):
            for k in range(0, 6):
                set256color(16 + i * 36 + j * 6 + k)
                sys.stdout.write("  ")
            set_color_normal()
            sys.stdout.write(" ")
        print

    print ("Grayscale ramp:")
    for i in range(232, 256):
        set256color(i)
        sys.stdout.write(" ")
    set_color_normal()
    print

def set_truecolor(r, g, b):
    sys.stdout.write("\x1b[48;2;%d;%d;%dm" % (r, g, b))

def show_truecolor_bar(r_on, g_on, b_on, array):
    for i in array:
        set_truecolor(r_on * i, g_on * i, b_on * i)
        sys.stdout.write(" ")
    set_color_normal()
    print

def show_truecolor_multiline_bar(r_on, g_on, b_on):
    show_truecolor_bar(r_on, g_on, b_on, range(0, 64, 1))
    show_truecolor_bar(r_on, g_on, b_on, range(127, 63, -1))
    show_truecolor_bar(r_on, g_on, b_on, range(128, 192, 1))
    show_truecolor_bar(r_on, g_on, b_on, range(255, 191, -1))

def test_gridtrue():
    print("""We will now display three gradients using TrueColor
(24-bit) color using a konsole extension.  This test ignores terminfo,
so should work even if TERM is not set correctly:\n""")

    show_truecolor_multiline_bar(True, False, False)
    show_truecolor_multiline_bar(False, True, False)
    show_truecolor_multiline_bar(False, False, True)
            
def run_tests():
    global g_tests
    globs = globals().copy()
    first_test = True
    for testname in g_tests:
        if not first_test:
            prompt()
        first_test = False
        func = globs.get("test_%s" % testname)
        func()

def print_help():
    print "Usage: terminalexercise [--help|-h] [-t <test1>] [-t <test2> ]"
    print "Shows a terminal's color capabilities in action.  This is useful " \
        "for diagnosing color problems.\n"
    print "Test names supported by -t: %s\n" % (", ".join(g_valid_tests))
    print "By default, runs all available tests."

def main():
    global g_tests
    try:
        opts, args = getopt.getopt(sys.argv[1:], "ht:", ["help"])
    except getopt.error, msg:
        print msg
        print "for help use --help"
        sys.exit(1)
    # process options
    for o, a in opts:
        if o in ("-h", "--help"):
            print_help()
            sys.exit(0)
        if o in ("-t"):
            add_test(a)

    if (len(g_tests) == 0):
        add_test("all")

    run_tests()

if __name__ == "__main__":
    main()
