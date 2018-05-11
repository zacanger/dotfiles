#!/usr/bin/env python2

from gtk import Window, ColorSelection, main

window = Window()
window.add(ColorSelection())
window.show_all()

main()
