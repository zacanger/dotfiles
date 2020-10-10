#!/usr/bin/env python3

# Based on https://github.com/sgtpep/pmenu (GPL 3.0, see license
# in that repo). Modified to be a general fuzzy finder for whatever
# purpose, and to remove the caching-related stuff.

import argparse
import curses
import curses.ascii
import fileinput
import io
import os
import re
import shlex
import shutil
import signal
import subprocess
import sys

__version__ = '0.3.3'

required_version = (3, 3)
if sys.version_info < required_version:
    sys.exit("Python {}.{} or newer is required.".format(*required_version))

def get_args():
    parser = argparse.ArgumentParser(usage="pipe newline-separated menu items to stdin and/or pass them as positional arguments")
    parser.add_argument('item', nargs='*', help="the menu item text")
    parser.add_argument('-c', '--command', help="the shell command which output will populate the menu items on every keystroke ({} will be replaced by the current input text)")
    parser.add_argument('-n', '--name', help="the cache file name with the most recently used items")
    parser.add_argument('-p', '--prompt', help="the prompt text")
    parser.add_argument('-v', '--version', action='version', version="%(prog)s " + __version__)

    args = parser.parse_args()
    if args.prompt is None:
        args.prompt = "> "
        if args.name:
            args.prompt = args.name + args.prompt

    return args

def get_mru_path():
    if not args.name:
        return

    cache_dir = os.environ.get('XDG_CACHE_HOME', os.path.join(os.path.expanduser('~'), '.cache'))
    mru_dir = os.path.join(cache_dir, 'pmenu')
    os.makedirs(mru_dir, exist_ok=True)

    return os.path.join(mru_dir, args.name)

def get_input_items():
    input_items = []
    if not sys.stdin.isatty():
        stdin = io.TextIOWrapper(sys.stdin.buffer, 'utf8', 'replace')
        input_items += stdin.read().splitlines()
    input_items += args.item
    input_items = filter(None, input_items)

    return list(input_items)

def get_command_items():
    if not args.command:
        return []

    command_argument = shlex.quote(query_text)
    command = args.command.replace('{}', command_argument)
    command_output = subprocess.check_output(command, shell=True, stderr=subprocess.DEVNULL)
    command_output = command_output.decode('utf8', 'replace')
    command_items = command_output.splitlines()
    command_items = filter(None, command_items)

    return list(command_items)

def get_mru_items(mru_path, input_items):
    if not mru_path or not os.path.exists(mru_path):
        return []

    input_items += get_command_items()

    mru_file = open(mru_path, encoding='utf8', errors='replace')
    mru_items = mru_file.read().splitlines()
    mru_items = [i for i in mru_items if i in input_items]
    mru_items.reverse()

    input_items[:] = [i for i in input_items if i not in mru_items]

    return mru_items

def redirect_stdio(func):
    try:
        prev_stdin = os.dup(0)
        prev_stdout = os.dup(1)
        stdin = open("/dev/tty")
        stdout = open("/dev/tty", 'w')
        os.dup2(stdin.fileno(), 0)
        os.dup2(stdout.fileno(), 1)

        return func()
    finally:
        os.dup2(prev_stdin, 0)
        os.dup2(prev_stdout, 1)

def curses_wrapper(func):
    if 'ESCDELAY' not in os.environ:
        os.environ['ESCDELAY'] = '0'

    is_vim = os.environ.get('VIM')
    if is_vim:
        sys.stdout.write("\033[m")
        sys.stdout.flush()

    try:
        screen = curses.initscr()
        curses.noecho()
        curses.cbreak()
        screen.keypad(True)

        if is_vim:
            curses.curs_set(1)

        return func(screen)
    finally:
        if 'screen' in locals():
            screen.keypad(False)
            curses.echo()
            try:
                curses.nocbreak()
            except curses.error:
                pass

            if not is_vim:
                curses.endwin()

def get_filtered_items():
    if not query_text:
        filtered_items = mru_items + input_items
    else:
        filtered_items = []
        word_regexes = [re.escape(i) for i in re.split(r"\s+", query_text.strip()) if i]
        exact_regexes = [re.compile(r"\b{}\b".format(i), re.I) for i in word_regexes]
        prefix_regexes = [re.compile(r"\b{}".format(i), re.I) for i in word_regexes]
        substring_regexes = [re.compile(i, re.I) for i in word_regexes]
        for items in (mru_items, input_items):
            exact_items = []
            prefix_items = []
            substring_items = []
            for item in items:
                if not all(re.search(i, item) for i in substring_regexes):
                    continue
                elif all(re.search(i, item) for i in exact_regexes):
                    exact_items.append(item)
                elif all(re.search(i, item) for i in prefix_regexes):
                    prefix_items.append(item)
                else:
                    substring_items.append(item)
            filtered_items += exact_items + prefix_items + substring_items

    filtered_items += get_command_items()

    return filtered_items

def redraw(screen):
    try:
        screen.erase()

        items = filtered_items[:curses.LINES - 1]
        for i, item in enumerate(items):
            item_attr = curses.A_REVERSE if i == selection_index else curses.A_NORMAL
            screen.insstr(i + 1, 0, item[:curses.COLS - 1], item_attr)

        top_line_text = args.prompt + query_text
        top_line_offset = len(top_line_text) - (curses.COLS - 1)
        if top_line_offset < 0:
            top_line_offset = 0
        screen.addstr(0, 0, top_line_text[top_line_offset:])

        screen.refresh()
    except curses.error:
        pass

def main(screen):
    global selection_index, filtered_items, query_text

    selection_index = 0

    def on_sigwinch(*args):
        columns, lines = shutil.get_terminal_size()
        curses.resizeterm(lines, columns)
        selection_index = 0
        redraw(screen)
    signal.signal(signal.SIGWINCH, on_sigwinch)

    while True:
        filtered_items = get_filtered_items()
        redraw(screen)

        try:
            char = screen.get_wch()
        except KeyboardInterrupt:
            return
        except curses.error:
            continue
        char_code = isinstance(char, str) and ord(char)

        # see https://en.wikipedia.org/wiki/C0_and_C1_control_codes
        # ^[, ^G, Esc
        if char_code in (curses.ascii.ESC, curses.ascii.BEL):
            return

        # ^D
        elif char_code == curses.ascii.EOT:
            return False, query_text

        # ^H, Backspace
        elif char_code in (curses.ascii.BS, curses.ascii.DEL) or char == curses.KEY_BACKSPACE:
            query_text = query_text[:-1]

        # ^I, Tab
        elif char_code == curses.ascii.TAB:
            if filtered_items:
                query_text = filtered_items[selection_index]

        # ^J, ^M, Enter
        elif char_code == curses.ascii.NL:
            if filtered_items:
                return True, filtered_items[selection_index]
            else:
                return False, query_text

        # ^N, Down
        elif char_code == curses.ascii.SO or char == curses.KEY_DOWN:
            if selection_index < min(len(filtered_items), curses.LINES - 1) - 1:
                selection_index += 1
            redraw(screen)

            continue

        # ^P, Up
        elif char_code == curses.ascii.DLE or char == curses.KEY_UP:
            if selection_index > 0:
                selection_index -= 1
            redraw(screen)

            continue

        # ^U
        elif char_code == curses.ascii.NAK:
            query_text = ''

        # ^W
        elif char_code == curses.ascii.ETB:
            query_text = re.sub(r"\w*[^\w]*$", '', query_text)

        elif isinstance(char, str) and not curses.ascii.isctrl(char):
            query_text += char

        selection_index = 0

def add_mru_text(mru_path, mru_text):
    if not mru_path:
        return

    if os.path.exists(mru_path):
        with fileinput.input(mru_path, inplace=True) as mru_file:
            for mru_line in mru_file:
                mru_line_text = mru_line.rstrip("\n\r")
                if mru_line_text != mru_text:
                    print(mru_line_text)

    with open(mru_path, 'a') as mru_file:
        mru_file.write(mru_text)

if __name__ == '__main__':
    args = get_args()
    query_text = ''
    input_items = get_input_items()
    mru_path = get_mru_path()
    mru_items = get_mru_items(mru_path, input_items)

    result = redirect_stdio(lambda: curses_wrapper(main))
    if not result:
        sys.exit(130)

    is_existing_item, result_text = result
    if is_existing_item:
        add_mru_text(mru_path, result_text)
    print(result_text)