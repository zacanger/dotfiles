#!/usr/bin/python
import curses
import sys
sys.stdout.write("\x1b]2;Chords!\x07") # set the terminal window title

myscreen = curses.initscr()
#myscreen.box()
myscreen.keypad(1)
myscreen.refresh()

maxheight,maxwidth = myscreen.getmaxyx()
#myscreen.addstr(1,1,str(maxwidth)) # debug
#myscreen.addstr(2,1,str(maxheight)) # debug

curses.start_color()
curses.use_default_colors()
curses.noecho()
curses.cbreak()
curses.curs_set(0)
curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_WHITE)
curses.init_pair(2, curses.COLOR_WHITE, curses.COLOR_BLACK)

# DEFINE DICTIONARIES
pianokeys_1 = { # pianokeys_layout = 1
1: 'C', 2: 'C#', 3: 'D', 4: 'D#', 5: 'E', 6: 'F', 7: 'F#', 8: 'G', 9: 'G#',
10: 'A', 11: 'A#', 12: 'B'}

pianokeys_2 = { # pianokeys_layout = 2
1: 'C', 2: 'Db', 3: 'D', 4: 'Eb', 5: 'E', 6: 'F', 7: 'Gb', 8: 'G', 9: 'Ab',
10: 'A', 11: 'Bb', 12: 'B'}

pckeys = {
1: 'z', 2: 's', 3: 'x', 4: 'd', 5: 'c', 6: 'v', 7: 'g', 8: 'b', 9: 'h',
10: 'n', 11: 'j', 12: 'm'}

subnotes = { # display this, this is purely for the display of the chord-name
1: 'M(ajor)', 2: 'm(inor)', 3: 'M6', 4: 'm6', 5: '7',
6: 'M7', 7: 'm7', 8: 'mM7', 9: '9', 10: 'M9', 11: 'm9',
12: 'mM9', 13: 'M11', 14: 'm11', 15: 'mM11',
16: 'M13', 17: 'm13', 18: 'mM13',
19: 'M-add9', 20: 'm-add9', 21: 'M6-add9', 22: 'm6-add9',
23: 'dom7', 24: 'dom9', 25: 'dom11', 26: 'dom13',
27: 'sus2', 28: 'sus4', 29: '6-sus4', 30: '7-sus4', 31: 'm7-sus4',
32: '9-sus4', 33: 'm9-sus4', 34: '7b5', 35: 'm7b5', 36: '7#5', 37: 'm7#5',
38: '7b9', 39: 'm7b9', 40: '7#9', 41: '7#5b9', 42: '9#11', 43: '9b13',
44: 'dim', 45: 'dim7', 46: 'add2', 47: 'add4', 48: '7-add4',
49: '5', 50: 'aug'}

chord_formulas = { # use these, these are for calculating the chords
1: [1,3,5], 2: [1,'b3',5], 3: [1,3,5,6], 4: [1,'b3',5,6], 5: [1,3,5,'b7'],
6: [1,3,5,7], 7: [1,'b3',5,'b7'], 8: [1,'b3',5,7], 9: [1,3,5,'b7',9], 10: [1,3,5,7,9], 11: [1,'b3',5,'b7',9],
12: [1,'b3',5,7,9], 13: [1,3,5,7,9,11], 14: [1,'b3',5,'b7',9,11], 15: [1,'b3',5,7,9,11],
16: [1,5,7,9,11,13], 17: [1,'b3',5,'b7',9,11,13], 18: [1,'b3',5,7,9,11,13],
19: [1,3,5,9], 20: [1,'b3',5,9], 21: [1,3,5,6,9], 22: [1,'b3',5,6,9],
23: [1,3,5,'b7'], 24: [1,3,5,'b7',9], 25: [1,3,5,'b7',9,11], 26: [1,3,5,'b7',9,11,13],
27: [1,2,5], 28: [1,4,5], 29: [1,4,5,6], 30: [1,4,5,'b7'], 31: [1,4,5,7],
32: [1,4,5,'b7',9], 33: [1,4,5,7,9], 34: [1,3,'b5',7], 35: [1,'b3','b5','b7'],
36: [1,3,'#5','b7'], 37: [1,'b3','#5','b7'], 38: [1,3,5,'b7','b9'],
39: [1,'b3',5,'b7','b9'], 40: [1,3,5,'b7','#9'], 41: [1,3,'#5','b7','b9'],
42: [1,3,5,'b7',9,'#11'], 43: [1,3,5,'b7',9,'b13'], 44: [1,'b3','b5'],
45: [1,'b3','b5',6], 46: [1,2,3,5], 47: [1,3,4,5], 48: [1,3,4,5,'b7'],
49: [1,5], 50: [1,3,'#5']}

# SET DEFAULTS
current_window = 1 # default to notes_section
ns_cursor_vpos = 1 # notes_section cursor vertical position
ns_cursor_hpos = 1 # notes_section cursor horizontal position
ss_cursor_vpos = 1 # subnotes_section cursor vertical position
ss_cursor_hpos = 1 # subnotes_section cursor horizontal position
pianokeys = pianokeys_1 # default to pianokeys layout 1
current_note = 1 # default to first note
current_subnote = 1 # default to first subnote
major_minor = 1 # default to major scale
bkeys_active = []
wkeys_active = []

# THE PIANO:
piano_show_what = 0 # default to showing no pianokeys/pckeys
piano_pikeys_layout = 0 # default to note-type A#
piano_width = 46
piano_hpos = (maxwidth - 46) / 2
piano = curses.newwin(7,46,1,piano_hpos)
piano.box()
piano.refresh()

def piano_draw_whitekeys(show_what,wkeys_a):
   w_hpos = 0
   wkey_hpos = {1: 2, 2: 6, 3: 6, 4: 6, 5: 6, 6: 6, 7: 6}
   wkeys = {1: 'w1_key', 2: 'w2_key', 3: 'w3_key', 4: 'w4_key', 5: 'w5_key', 6: 'w6_key', 7: 'w7_key'}
   wfields = {1: 'w1_field', 2: 'w2_field', 3: 'w3_field', 4: 'w4_field', 5: 'w5_field', 6: 'w6_field', 7: 'w7_field'}
   wpckeys = {1: 'z', 2: 'x', 3: 'c', 4: 'v', 5: 'b', 6: 'n', 7: 'm'}
   wpikeys = {1: 'C', 2: 'D', 3: 'E', 4: 'F', 5: 'G', 6: 'A', 7: 'B'}
   wpikeys_translate = {1: 1, 3: 2, 5: 3, 6: 4, 8: 5, 10: 6, 12: 7} # translation for printed keyboard to actual key-positions in dict
   for w in range(1, 8):
      w_hpos = w_hpos + wkey_hpos[w]
      wfields[w] = piano.derwin(6,6,0,w_hpos)
      wfields[w].box()
      wfields[w].refresh()
      wkeys[w] = wfields[w].derwin(4,4,1,1)
      wkeys[w].bkgd(curses.color_pair(1))
      
      if show_what == 0:
         wkeys[w].addstr(1,1,"  ")
      elif show_what == 1:
         wkeys[w].addstr(1,1,wpikeys[w])
      elif show_what == 2:
         wkeys[w].addstr(1,1,wpckeys[w])

      wkeys[w].refresh()
      
   for x in wkeys_a:
      wkey_activate = wpikeys_translate[x]
      wfields[wkey_activate].addstr(5,2,'XX',curses.A_BOLD)
      wfields[wkey_activate].refresh()

def piano_draw_blackkeys(show_what,show_pikeys_layout,bkeys_a):
   b_hpos = 0
   bkey_hpos = {1: 6, 2: 6, 3: 12, 4: 6, 5: 6}
   bkeys = {1: 'b1_key', 2: 'b2_key', 3: 'b3_key', 4: 'b4_key', 5: 'b5_key'}
   bfields = {1: 'b1_field', 2: 'b2_field', 3: 'b3_field', 4: 'b4_field', 5: 'b5_field'}
   bpckeys = {1: 's', 2: 'd', 3: 'g', 4: 'h', 5: 'j'}
   bpikeys_1 = {1: 'C#', 2: 'D#', 3: 'F#', 4: 'G#', 5: 'A#'}
   bpikeys_2 = {1: 'Db', 2: 'Eb', 3: 'Gb', 4: 'Ab', 5: 'Bb'}
   bpikeys_translate = {2: 1, 4: 2, 7: 3, 9: 4, 11: 5}
   for b in range(1, 6):
      b_hpos = b_hpos + bkey_hpos[b]
      bfields[b] = piano.derwin(4,4,0,b_hpos)
      bfields[b].box()
      bfields[b].refresh()
      bkeys[b] = bfields[b].derwin(3,3,1,1)
      bkeys[b].bkgd(curses.color_pair(2))
      bkeys[b].addstr(1,0,"  ")

      if show_pikeys_layout == 1:
         bpikeys = bpikeys_2
      elif show_pikeys_layout == 0:
         bpikeys = bpikeys_1

      if show_what == 0:
         bkeys[b].addstr(0,0,"  ")
      elif show_what == 1:
         bkeys[b].addstr(0,0,bpikeys[b])
      elif show_what == 2:
         bkeys[b].addstr(0,0,bpckeys[b] + ' ')

      bkeys[b].refresh()

   for x in bkeys_a:
      bkey_activate = bpikeys_translate[x]
      bfields[bkey_activate].addstr(3,1,'XX',curses.A_BOLD)
      bfields[bkey_activate].refresh()

def draw_piano(the_id,key,bkeys_a,wkeys_a):
   piano.clear()
   global piano_pikeys_layout
   global piano_show_what
   if the_id == 2: #F2-switch for pianokeys layout
      if key == 0:
         piano_pikeys_layout = 1
         send_return = 1
      elif key == 1:
         piano_pikeys_layout = 0
         send_return = 0
   if the_id == 3: #F3-switch for display pckeys/pianokeys
      if key == 0:
         piano_show_what = 1
         send_return = 1
      if key == 1:
         piano_show_what = 2
         send_return = 2
      elif key == 2:
         piano_show_what = 0
         send_return = 0
   if the_id == 4: #F4-switch for display pianokeys on/off
      if key == 0:
         piano_show_pikeys = 1
         send_return = 1
      elif key == 1:
         piano_show_pikeys = 0
         send_return = 0
   if the_id == 0: # default
      send_return = 0
   
   piano_draw_whitekeys(piano_show_what,wkeys_a) # draw white keys
   piano_draw_blackkeys(piano_show_what,piano_pikeys_layout,bkeys_a) # draw black keys
   return send_return # send changed value

draw_piano(0,0,bkeys_active,wkeys_active) # initialize the piano with values of 0
# END OF THE PIANO

# NOTES SECTION
def print_notes():
   notes = {}
   x = 1
   while (x <= 12):
      notes[x] = pianokeys[x]
      x = x + 1
   
   notes_section.clear()
   
   note_hpos = 1
   for i in notes:
      notes_section.addstr(1,note_hpos,notes[i])
      note_hpos = note_hpos + len(notes[i]) + 2
   
   notes_section.refresh()

notes_section_hpos = (maxwidth - 46) / 2 + 2
notes_section = myscreen.derwin(3,46,8,notes_section_hpos)
print_notes()
myscreen.addstr(9,(notes_section_hpos - 9),'[Notes]',curses.A_BOLD)
notes_section.chgat(1,1,2,curses.A_REVERSE)
notes_section.refresh()
# END OF NOTES SECTION

# SUBNOTES SECTION
def print_subnotes():
   column_width = 15
   subnote_hpos = 1 
   subnote_vpos = 1
   sn = 1
   while (sn <= 50):
      sn_len = len(subnotes[sn])
      if subnote_vpos == (11): # if too high,
         subnote_hpos = subnote_hpos + column_width  # jump to the right
         subnote_vpos = 1 # and start over at the top
      subnotes_section.addstr(subnote_vpos,subnote_hpos,subnotes[sn])
      subnote_vpos = subnote_vpos + 1
      sn = sn + 1

   subnotes_section.box()
   subnotes_section.addstr(0,5,'[Subnotes]')

# determine horizontal position of the subnotes_section
if maxwidth <= 75:
   subnotes_section_hpos = 3
elif maxwidth > 75:
   subnotes_section_hpos = (maxwidth - 75) / 2

subnotes_section = myscreen.derwin(12,75,11,subnotes_section_hpos)
# END OF SUBNOTES SECTION

# SCALE SECTION
def build_scale(root,m):
   scale = {1: pianokeys[root]}
   index = root
   scale_formula = [2,2,1,2,2,2,1,2,2,1,2,2,2] # Major scale 
   if m == 1: # Major scale
      mjn = 'Major'
      scale_formula = [2,2,1,2,2,2,1,2,2,1,2,2,2]
   elif m == 2: # Natural Minor scale
      mjn = 'Natural Minor'
      scale_formula = [2,1,2,2,1,2,2,2,1,2,2,1,2]
   elif m == 3: # Harmonic Minor scale
      mjn = 'Harmonic Minor'
      scale_formula = [2,1,2,2,1,3,1,2,1,2,2,1,3]
   elif m == 4: # Melodic Minor scale
      mjn = 'Melodic Minor'
      scale_formula = [2,1,2,2,2,2,1,2,1,2,2,2,2]
   
   scaletext = mjn + ' scale of ' + scale[1] + ': '
   
   num = 2
   for i in scale_formula:
      if (index + i) <= len(pianokeys):
         index = index + i
      else:
         index = (index + i) - len(pianokeys)
      scale[num] = pianokeys[index] # add to dictionary
      num = num + 1

   scale_section.clear() # erase the content of the scale section
   scale_hpos = len(scaletext) + 1 # start printing the scale
   count = 0
   for x in scale:
      if count < 7:
         scale_section.addstr(1,scale_hpos,scale[x])
         scale_hpos = scale_hpos + len(scale[x]) + 1
         count = count + 1

   scale_section.addstr(1,1,scaletext)
   #scale_section.box()
   scale_section.refresh()

scale_section = myscreen.derwin(3,75,22,subnotes_section_hpos)

def build_major_scale(root):
   scale = {1: pianokeys[root]}
   key_reference = {1: root} # keeps a reference of the relation of scale-position to keyboard-position
   index = root
   scale_formula = [2,2,1,2,2,2,1,2,2,1,2,2,2] # Major scale

   num = 2
   for i in scale_formula:
      if (index + i) <= len(pianokeys):
         index = index + i
      else:
         index = (index + i) - len(pianokeys)
      scale[num] = pianokeys[index] # add to dictionary
      key_reference[num] = index
      num = num + 1    

   return scale,key_reference

build_scale(current_note,major_minor)
# END OF SCALE SECTION

# CHORD SECTION
def build_chord(root,chordtype):
   chord = []
   pckeys_chord = []
   chord_formula = chord_formulas[chordtype]
   scale,key_reference = build_major_scale(root)
   global bkeys_active
   bkeys_active = []
   global wkeys_active
   wkeys_active = []

   for z in chord_formula:
      if isinstance(z, int) == True: # if the formula holds an integer, fine
         chord.append(scale[z])
         pckeys_chord.append(pckeys[key_reference[z]])
         if len(scale[z]) == 1:
            wkeys_active.append(key_reference[z])
         else:
            bkeys_active.append(key_reference[z])
      elif z[0] == 'b': # if the formula holds a 'b'-note, get 1 pianokey below that note in the scale
         key = int(z[1])
         if key_reference[key] > 1:
            note = str(pianokeys[key_reference[key] - 1])
            pckey = str(pckeys[key_reference[key] - 1])
            if len(note) == 1:
               wkeys_active.append(key_reference[key] - 1)
            else:
               bkeys_active.append(key_reference[key] - 1)
         elif key_reference[key] == 1: # 1-1=12 (go back around)
            note = str(pianokeys[12])
            pckey = str(pckeys[12])
            wkeys_active.append(12) # in this case it is always a B (so white key)

         chord.append(note)
         pckeys_chord.append(pckey)

      elif z[0] == '#': # if the formula has a '#'-note, get 1 pianokey above that note in the scale
         key = int(z[1])
         if key_reference[key] < 12:
            note = str(pianokeys[key_reference[key] + 1])
            pckey = str(pckeys[key_reference[key] + 1])
            if len(note) == 1:
               wkeys_active.append(key_reference[key] + 1)
            else:
               bkeys_active.append(key_reference[key] + 1)            
         elif key_reference[key] == 12: # 12+1=1 (go back around)
            note = str(pianokeys[1])
            pckey = str(pckeys[1])
            wkeys_active.append(1) # always a C (so white key)

         chord.append(note)
         pckeys_chord.append(pckey)

   chord_section.clear() 
   
   chord_hpos = 2
   pckey_hpos = 2
   count = 0
   for y in chord:
      chord_space = (len(pianokeys[root]) + len(subnotes[chordtype]) + 1)
      chord_section.addstr(1,1,pianokeys[root] + ' ' + subnotes[chordtype] + ': ')
      chord_section.addstr(1,(1 + chord_space + chord_hpos),y)
      chord_hpos = chord_hpos + len(y) + 1
      if piano_show_what == 2:
         key_space = chord_space - 3
         chord_section.addstr(2,key_space,'keys: ')
         chord_section.addstr(2,(key_space + 4 + pckey_hpos),pckeys_chord[count])
         pckey_hpos = pckey_hpos + len(y) + 1
         count = count + 1

   #chord_section.box()
   chord_section.refresh()
   print_subnotes()
   draw_piano(0,0,bkeys_active,wkeys_active)

chord_section = myscreen.derwin(4,75,24,subnotes_section_hpos)
build_chord(current_note,current_subnote)
print_subnotes()
subnotes_section.chgat(1,1,13,curses.A_REVERSE)
subnotes_section.refresh()
# END OF CHORD SECTION

# NAVIGATION
def tab(win,vpos,hpos): # function for tabbing between notes and subnotes sections
   if win == 1: # current window = notes_section
      subnotes_section.chgat(vpos,hpos,13,curses.A_REVERSE)
      subnotes_section.addstr(0,5,'[Subnotes]',curses.A_BOLD) # bold title
      myscreen.addstr(9,(notes_section_hpos - 9),'[Notes]',curses.A_NORMAL) # unbold title
      notes_section.refresh()
      subnotes_section.refresh()
      return 2
   elif win == 2: # current window = subnotes_section
      notes_section.chgat(vpos,hpos,2,curses.A_REVERSE)
      subnotes_section.addstr(0,5,'[Subnotes]',curses.A_NORMAL) # unbold title
      myscreen.addstr(9,(notes_section_hpos - 9),'[Notes]',curses.A_BOLD) # bold title
      notes_section.refresh()
      subnotes_section.refresh()
      return 1

def navigate_notes_section(vpos,hpos,note,key):
   if key == 'up' or key == 'down':
      () # can't go up or down from the notes section
   elif key == 'right':
      if note < 12:
         hpos = hpos + 2 + len(pianokeys[note])
         note = note + 1
      else:
         note = 1
         hpos = 1
   elif key == 'left':
      if note > 1:
         note = note - 1
         hpos = hpos - 2 - len(pianokeys[note])
      else:
         note = 12
         hpos = 39

   notes_section.clrtoeol() # erase the content, then redraw it 
   print_notes()
   notes_section.chgat(vpos,hpos,2,curses.A_REVERSE)
   notes_section.refresh()
   return vpos,hpos,note

def navigate_subnotes_section(vpos,hpos,subnote,key): # function for moving between values
   attr = curses.A_BOLD
   if key == 'up':
      if vpos > 1: # if we can still go up
         vpos = vpos - 1 # go up
         subnote = subnote - 1 # go one subnote back
      else: # if we cannot go up
         vpos = 10 # go to column bottom...
         if hpos > 15: # check to see if we're in the 1st column
            hpos = hpos - 15 # move a column back
            subnote = subnote - 1 # move a subnote back
         else: # if we're in the first column
            hpos = 61 # jump to last column
            subnote = 50 # jump to last subnote
   elif key == 'down':
      if vpos < 10: # if we can still go down
         vpos = vpos + 1 # go down
         subnote = subnote + 1 # go one subnote forward
      else: # if we cannot go down
         vpos = 1 # go to column top
         if hpos < 61: # if we're note in the last column
            hpos = hpos + 15 # move a column forward
            subnote = subnote + 1 # move a subnote forward
         else: # if we're in the last column
            hpos = 1 # jump to first column
            subnote = 1 # jump to first subnote
   elif key == 'left':
      if hpos > 15: # if we're not in the first column
         hpos = hpos - 15 # move a column back
         subnote = subnote - 10
      else: # if we're in the first column
         hpos = 61 # jump to last column
         subnote = subnote + 40 # jump to last subnote in last column
   elif key == 'right':
      if hpos < 61: # if we're not in the last column
         hpos = hpos + 15 # move a column to the right
         subnote = subnote + 10
      else:
         hpos = 1 # jump to first column
         subnote = subnote - 40 # jump to first subnote         
   elif key == 'refresh':
      if current_window == 1:
         attr = curses.A_NORMAL
      else:
         attr = curses.A_BOLD

   subnotes_section.clrtobot() # erase the content, then redraw it
   print_subnotes()
   subnotes_section.addstr(0,5,'[Subnotes]',attr)
   subnotes_section.chgat(vpos,hpos,13,curses.A_REVERSE)
   subnotes_section.refresh()
   return vpos,hpos,subnote
# END OF NAVIGATION

# CAPTURE KEYPRESSES
while True:
   key = myscreen.getch()
   if key == ord('q'): break # 'q' = quit
   elif key == ord('\t'): # TAB: move between notes_section and subnotes_section
      if current_window == 1:
         current_window = tab(current_window,ss_cursor_vpos,ss_cursor_hpos)
      elif current_window == 2:
         current_window = tab(current_window,ns_cursor_vpos,ns_cursor_hpos)
   elif key == curses.KEY_UP:
      if current_window == 1:
         ns_cursor_vpos,ns_cursor_hpos,current_note = navigate_notes_section(ns_cursor_vpos,ns_cursor_hpos,current_note,'up')
      elif current_window == 2:
         ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'up')
   elif key == curses.KEY_DOWN:
      if current_window == 1:
         ns_cursor_vpos,ns_cursor_hpos,current_note = navigate_notes_section(ns_cursor_vpos,ns_cursor_hpos,current_note,'down')
      elif current_window == 2:
         ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'down')
   elif key == curses.KEY_LEFT:
      if current_window == 1:
         ns_cursor_vpos,ns_cursor_hpos,current_note = navigate_notes_section(ns_cursor_vpos,ns_cursor_hpos,current_note,'left')
      elif current_window == 2:
         ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'left')
   elif key == curses.KEY_RIGHT:
      if current_window == 1:
         ns_cursor_vpos,ns_cursor_hpos,current_note = navigate_notes_section(ns_cursor_vpos,ns_cursor_hpos,current_note,'right')
      elif current_window == 2:
         ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'right')
   elif key == ord('\n'): # ENTER
      build_chord(current_note,current_subnote)
      build_scale(current_note,major_minor)
      ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'refresh')
   elif key == curses.KEY_F1: # F1: major/minor(3) switch
      if major_minor < 4:
         major_minor = major_minor + 1
         build_scale(current_note,major_minor)
         ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'refresh')
      else:
         major_minor = 1
         build_scale(current_note,major_minor)
         ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'refresh')
   elif key == curses.KEY_F2: # F2: switch pianokeys layout
      caller_id = 2 # the caller-id for this function
      if pianokeys == pianokeys_1:
         piano_pikeys_layout = draw_piano(caller_id,0,bkeys_active,wkeys_active)
         pianokeys = pianokeys_2
      elif pianokeys == pianokeys_2:
         piano_pikeys_layout = draw_piano(caller_id,1,bkeys_active,wkeys_active)
         pianokeys = pianokeys_1
      print_notes()
      navigate_notes_section(ns_cursor_vpos,ns_cursor_hpos,current_note,'up') # to refresh the notes section
      build_scale(current_note,major_minor)
      build_chord(current_note,current_subnote)
      ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'refresh')
   elif key == curses.KEY_F3: # F3: display of pianokeys/pckeys switch
      caller_id = 3 # the caller-id for this function
      piano_show_what = draw_piano(caller_id,piano_show_what,bkeys_active,wkeys_active)
      build_chord(current_note,current_subnote)
      ss_cursor_vpos,ss_cursor_hpos,current_subnote = navigate_subnotes_section(ss_cursor_vpos,ss_cursor_hpos,current_subnote,'refresh')

# _TODO: make it resizable.
curses.endwin()

