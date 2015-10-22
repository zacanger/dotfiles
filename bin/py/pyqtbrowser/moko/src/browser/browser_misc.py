#!/usr/bin/env python

#############################################################################
## Copyright 2007-2008 Openmoko, Inc.
## Authored by Erin Yueh <erin_yueh@openmoko.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
#############################################################################


import Xlib.display
import Xlib.protocol

class misc(object):

    def __init__(self):

          self.display = Xlib.display.Display()
          self.screen = self.display.screen()
          self.root = self.screen.root
          self.input_focus = self.display.get_input_focus()
          self.window = self.input_focus._data["focus"];
          self.msg_type = self.display.get_atom("_MTP_IM_INVOKER_COMMAND")

    def send_event(self, value):
        
        event = Xlib.protocol.event.ClientMessage(
                    window = self.root,
                    client_type = self.msg_type,
                    data = value)
        print "send"
        self.window.send_event(event)
        self.display.sync()

    def keyboard_show(self):
        data = (32, "\1\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
        self.status = "show"
        self.send_event(data)

    def keyboard_hide(self):
        data = (32, "\2\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")
        self.status = "hide"
        self.send_event(data)
        
    def keyboard_status_get(self):
        return self.status
        
if __name__ == "__main__": 
    misc = misc()
    misc.keyboard_show()
