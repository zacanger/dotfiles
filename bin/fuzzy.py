#!/usr/bin/env python3

# Based on https://github.com/sgtpep/pmenu (GPL 3.0, see license
# in that repo). Modified to remove the cache, remove some options,
# remove some keybinds, and generally just do less.

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


def get_args():
    parser = argparse.ArgumentParser(
        usage="Pipe newline-separated items or pass as args"
    )
    parser.add_argument("item", nargs="*", help="the menu item text")
    args = parser.parse_args()
    return args


def get_input_items():
    input_items = []
    if not sys.stdin.isatty():
        stdin = io.TextIOWrapper(sys.stdin.buffer, "utf8", "replace")
        input_items += stdin.read().splitlines()
    input_items += args.item
    input_items = filter(None, input_items)
    return list(input_items)


def redirect_stdio(func):
    try:
        prev_stdin = os.dup(0)
        prev_stdout = os.dup(1)
        stdin = open("/dev/tty")
        stdout = open("/dev/tty", "w")
        os.dup2(stdin.fileno(), 0)
        os.dup2(stdout.fileno(), 1)
        return func()
    finally:
        os.dup2(prev_stdin, 0)
        os.dup2(prev_stdout, 1)


def curses_wrapper(func):
    if "ESCDELAY" not in os.environ:
        os.environ["ESCDELAY"] = "0"

    is_vim = os.environ.get("VIM")
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
        if "screen" in locals():
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
        filtered_items = input_items
    else:
        filtered_items = []
        word_regexes = [
            re.escape(i) for i in re.split(r"\s+", query_text.strip()) if i
        ]
        exact_regexes = [
            re.compile(r"\b{}\b".format(i), re.I) for i in word_regexes
        ]
        prefix_regexes = [
            re.compile(r"\b{}".format(i), re.I) for i in word_regexes
        ]
        substring_regexes = [re.compile(i, re.I) for i in word_regexes]
        for items in (input_items,):
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

    return filtered_items


def redraw(screen):
    try:
        screen.erase()

        items = filtered_items[: curses.LINES - 1]
        for i, item in enumerate(items):
            item_attr = (
                curses.A_REVERSE if i == selection_index else curses.A_NORMAL
            )
            screen.insstr(i + 1, 0, item[: curses.COLS - 1], item_attr)

        prompt = "-> "
        top_line_text = prompt + query_text
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
        elif (
            char_code in (curses.ascii.BS, curses.ascii.DEL)
            or char == curses.KEY_BACKSPACE
        ):
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
            if (
                selection_index
                < min(len(filtered_items), curses.LINES - 1) - 1
            ):
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
            query_text = ""

        # ^W
        elif char_code == curses.ascii.ETB:
            query_text = re.sub(r"\w*[^\w]*$", "", query_text)

        elif isinstance(char, str) and not curses.ascii.isctrl(char):
            query_text += char

        selection_index = 0


if __name__ == "__main__":
    args = get_args()
    query_text = ""
    input_items = get_input_items()

    result = redirect_stdio(lambda: curses_wrapper(main))
    if not result:
        sys.exit(130)

    is_existing_item, result_text = result
    print(result_text)
