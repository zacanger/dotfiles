#!/usr/bin/env python3

import sys
from math import log2

A4 = 440


def hz_to_note(freq):
    C0 = A4 * pow(2, -4.75)
    notes = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    h = round(12 * log2(freq / C0))
    octave = h // 12
    n = h % 12
    return notes[n] + str(octave)


def note_to_hz(note):
    nt = note.upper()
    notes = ["A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"]
    octave = int(nt[2]) if len(nt) == 3 else int(nt[1])
    key_number = notes.index(nt[0:-1])
    if key_number < 3:
        key_number = key_number + 12 + ((octave - 1) * 12) + 1
    else:
        key_number = key_number + ((octave - 1) * 12) + 1

    return A4 * 2 ** ((key_number - 49) / 12)


def main(the_note):
    if the_note == 1:
        inp = float(input("Enter hz: "))
        res = hz_to_note(inp)
        print(res)
    elif the_note == 2:
        inp = input("Enter note: ")
        res = note_to_hz(inp)
        print(res)
    else:
        print("Invalid input")
        sys.exit(1)


if __name__ == "__main__":
    which = int(input("Enter 1 for hz to note, 2 for note to hz: "))
    main(which)
