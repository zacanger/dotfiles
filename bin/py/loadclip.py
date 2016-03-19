#!/usr/bin/env python3
"""Load a saved item into your clipboard."""

import json
import pyperclip
import collections
import argparse
import tkinter
from tkinter import ttk
from os.path import expanduser


_CONFIG = expanduser('~/.loadclip.json')


class Expander(collections.UserDict):

    def __init__(self, config):
        """Create an expander, passing in a JSON configuration file."""
        self._config = config
        self.reload()

    def reload(self):
        """Load expansions from the configuration file again."""
        with open(self._config) as f:
            self.data = json.load(f)

    def save(self):
        """Save any updated exansions."""
        with open(self._config, 'w') as f:
            json.dump(self.data, f)

    def copy(self, key):
        """Load clipboard with the given key."""
        text = self.data.get(key)
        if text:
            pyperclip.copy(text)
        else:
            pyperclip.copy(key)

    def popup_copy(self):
        root = tkinter.Tk()
        root.title('Enter Key')
        key_entry = tkinter.ttk.Entry(root, width=20)
        key_entry.grid()
        key_entry.focus_set()
        root.bind('<Return>', lambda _: root.quit())
        root.mainloop()
        self.copy(key_entry.get())


def main():
    parser = argparse.ArgumentParser(description='Quickly copy text')
    parser.add_argument('key', nargs='?')
    parser.add_argument('--new-key', action='store_true')
    parser.add_argument('--popup', action='store_true')
    args = parser.parse_args()

    ex = Expander(_CONFIG)
    if args.key:
        ex.copy(args.key)
    if args.new_key:
        key = input('Key: ')
        val = input('Value: ')
        ex[key] = val
        ex.save()
    if args.popup:
        ex.popup_copy()


if __name__ == '__main__':
    main()
