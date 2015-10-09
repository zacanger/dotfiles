#!/usr/local/bin/python

##Inital prep
import curses
import os
import sys
import time
#import posixpath
import random
from copy import deepcopy

##Initialize curses window
stdscr = curses.initscr()
curses.noecho()  # turns off echoing of keys to the screen
curses.cbreak()  # read keys without requiring Enter key
stdscr.keypad(1)  # Enable keypad mode (read special keys)
windowSize = stdscr.getmaxyx()  # GRABS SIZE of CURRENT TERMINAL WINDOW
(HEIGHT, WIDTH) = windowSize  # split into height and width

HEIGHT = HEIGHT - 1
WIDTH = WIDTH - 1

win = curses.newwin(HEIGHT, WIDTH, 0, 0)  # 0,0 is start position

##Determine os
systemInfo = os.uname()
if "Linux" in systemInfo:
    OperatingSystem = "Linux"
elif "Darwin" in systemInfo or "Macintosh" in systemInfo:
    OperatingSystem = "Macintosh"
else:
    OperatingSystem = "Other"

##Set Variables
mytime = time
breakNow = False
continue_down = 0
continue_up = 0

continue_right = 0
continue_left = 0
old_time = time.time()
HEADER = 2
ROWSIZE = WIDTH - 6
no_bold = False

spaceChar = "_"
settings = {}
settings["default_load_sort"] = "name"  # Had to define these here to fix bug
settings["default_load_reverse"] = False
settings["default_load_invisibles"] = False
backupSettings = {}
colors = {}
status = {}

savepath = False
program_message = ""
print_at_row = 0
clipboard = []
saved_since_edit = False
text_entered = False
reset_needed = False

CHAR_DICT = {32: ' ', 33: '!', 34: '"', 35: '#', 36: '$', 37: '%', 38: '&',
    39: "'", 40: '(', 41: ')', 42: '*', 43: '+', 44: ',', 45: '-', 46: '.',
    47: '/', 48: '0', 49: '1', 50: '2', 51: '3', 52: '4', 53: '5', 54: '6',
    55: '7', 56: '8', 57: '9', 58: ':', 59: ';', 60: '<', 61: '=', 62: '>', 63: '?',
    64: '@', 65: 'A', 66: 'B', 67: 'C', 68: 'D', 69: 'E', 70: 'F', 71: 'G',
    72: 'H', 73: 'I', 74: 'J', 75: 'K', 76: 'L', 77: 'M', 78: 'N', 79: 'O', 80: 'P',
    81: 'Q', 82: 'R', 83: 'S', 84: 'T', 85: 'U', 86: 'V', 87: 'W', 88: 'X', 89: 'Y',
    90: 'Z', 91: '[', 92: '\\', 93: ']', 94: '^', 95: '_', 96: '`', 97: 'a',
    98: 'b', 99: 'c', 100: 'd', 101: 'e', 102: 'f', 103: 'g', 104: 'h',
        105: 'i', 106: 'j', 107: 'k', 108: 'l', 109: 'm', 110: 'n',
            111: 'o', 112: 'p', 113: 'q', 114: 'r', 115: 's', 116: 't',
                117: 'u', 118: 'v', 119: 'w', 120: 'x', 121: 'y', 122: 'z',
                    123: '{', 124: '|', 125: '}', 126: '~'}

COMMANDS = ["print", "class", "def", "if", "elif", "else", "else:", "try:",
    "except:", "for", "while", "return", "try", "except", "break", "pass",
    "continue", "del", "and", "or", "global", "import", "from", "yield",
    "raise", "lambda", "assert", "exec", "finally", "in", "is", "not"]

EXECUTABLES = ["color","indent","unindent","delete","comment","uncomment","show","hide","mark","unmark","find",
"whitespace","syntax","entry","run","split","splitscreen","quit","load","replace","formatting","replace",
"new","save","saveas","revert","copy","paste", "collapse","uncollapse","undo","expand","debug","cut",
"cut ", "goto", "color default", "protect", "protect with ", "commands","isave", "setcolor", "timestamp",
"live","read", "prev", "saveprefs", "select", "deselect", "strip", "help", "previous", "guide", "pageguide",
"invert", "setcolors", "acceleration", "accelerate","tab","tabs"]

EXEC_ABREVIATED = ["col","ind","uni","del","com","sho","hid","mar","unm","fin","whi","syn","ent","run","spl","spl",
"qui","loa","rep", "new","sav","rev","cop","pas", "col","unc","und","exp","deb","cut","got", "rea", "pro", "isa",
"set", "tim", "for", "liv","pre","hel","pag","gui","sel", "inv"]

##Set Help Guide text
HELP_GUIDE = ["####################################################################:",
"##################################################### Warrior-IDE HELP",
"####################################################################:",
"",
"#####################################################################",
"####################### KEYBOARD NAVIGATION #########################",
"#####################################################################",
"arrow keys      Navigate document",
"---------------------------------------------------------------------",
"tab key         Indent (tab = 4 spaces)",
"---------------------------------------------------------------------",
"control 'w'     Launch SAVE WINDOW, an alternate way to save document",
"---------------------------------------------------------------------",
"control 'e'     Launch ENTRY WINDOW, alternate way to enter commands",
"---------------------------------------------------------------------",
"control 'd'     If debug mode is on, move to next line with an error",
"---------------------------------------------------------------------",
"control 'f'     Launches a search window",
"---------------------------------------------------------------------",
"control 'g'     If 'find' has been used, find again (next match)",
"---------------------------------------------------------------------",
"control 'n'     Moves to next 'marked' line",
"---------------------------------------------------------------------",
"control 'b'     Moves back to previous 'marked' line",
"---------------------------------------------------------------------",
"control 'a'     Deselect ALL lines",
"---------------------------------------------------------------------",
"control 'p'     Move down ~ 1 page, or one line in splitscreen mode",
"---------------------------------------------------------------------",
"control 'u'     Move up ~ 1 page, or one line in splitscreen mode",
"",

"#####################################################################",
"###################### ABOUT INLINE COMMANDS ########################",
"#####################################################################",
"Execute commands by typing them on a blank line in the editor and",
"pressing 'enter'. If there are no blank lines, press the down arrow",
"and one will be created at the end of the document.",
"",
"Commands can optionally be 'protected' with a text string to safeguard",
"against accidental execution. While protection is on, the protect",
"string is displayed in the top right corner of the terminal screen.",
"",
"                Example: ##::save myfile.txt",
"",
"#####################################################################",
"######################### COMMANDS (MAIN) ###########################",
"#####################################################################",
"quit        Quits warrior-ide",
"---------------------------------------------------------------------",
"new         Create empty document",
"---------------------------------------------------------------------",
"load [file]",
"",
"            Loads file. If file name not given, file can be chosen",
"            from a selection screen.",
"---------------------------------------------------------------------",
"read [file]",
"   ",
"            Loads file in 'read only' mode, editing not allowed. If",
"            file name not given, file can be chosen from a selection",
"            screen.",
"---------------------------------------------------------------------",
"save [file]",
"",
"            Saves file. Assumes current directory if not specified",
"---------------------------------------------------------------------",
"saveas      Opens confirmation window so filepath/name can be edited",
"---------------------------------------------------------------------",
"isave       Increments filename & saves (+1 to number before .ext)",
"---------------------------------------------------------------------",
"revert      Reverts file to last saved version",
"---------------------------------------------------------------------",
"saveprefs   Saves current settings",
"---------------------------------------------------------------------",
"help [module] or [class] or [function]",
"",
"            When no arguments given, opens HELP GUIDE. Otherwise",
"            shows help or doc-string for given item.",
"---------------------------------------------------------------------",
"run         Attempts to run your python code in a separate window.",
"            *Currently,this feature only works in Linux with",
"            the GNOME TERMINAL.",
"",
"#####################################################################",
"######################## COMMANDS (EDITING) #########################",

"NOTE: most editing commands allow you to act on a single line number,",
"multiple lines, a range of lines, selected lines only, marked lines",
"only, or the current line if executed from the ENTRY WINDOW",
"(control 'e').",
"",
"    examples:",
"        To copy line 10                            ##copy 10",
"        To copy multiple lines                     ##copy 10,15,20",
"        To copy range                              ##copy 10-20",
"        To copy marked lines                       ##copy marked",
"        To copy selection (from ENTRY WINDOW)      ##copy selection",
"        To copy selection (inline command only)    ##copy",
"        To copy current line (ENTRY WINDOW only)   ##copy",
"---------------------------------------------------------------------",
"select [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or [function/class name] or ['all'] or ['up'] or ['down']",
"",
"            Select lines by line numbers, by function/class name,",
"            or marked lines only.",
"",
"            Select up/down automatically selects all lines above",
"            or below the current line, stopping when a blank line",
"            is reached.",
"",
"            NOTE: using select automatically deselects the current",
"            selection. You can not add to a selection.",
"---------------------------------------------------------------------",
"deselect [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or [function/class name] or ['all']",
"",
"            Deselect specified line(s)",
"---------------------------------------------------------------------",
"invert      Inverts selection",
"---------------------------------------------------------------------",
"copy [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or ['selection']",
"",
"            Copies line(s) into memory.",
"---------------------------------------------------------------------",
"paste [line]",
"",
"            Pastes previously copied text into document.",
"            With no arguments, paste occurs at current line.",
"            If line is given, paste occurs there (line inserted).",
"            From ENTRY WINDOW, text is appended to current line.",
"",
"                example: ##paste 20",
"---------------------------------------------------------------------",
"delete [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or ['selection']",
"",
"            Deletes specified line(s)",
"---------------------------------------------------------------------",
"cut [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or ['selection']",
"",
"            Combines copy and delete into one operation.",
"---------------------------------------------------------------------",
"comment [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or ['selection']",
"",
"            Comments specified line(s)",
"---------------------------------------------------------------------",
"uncomment [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or ['selection']",
"",
"            Uncomments specified line(s)",
"---------------------------------------------------------------------",
"indent [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or ['selection']",
"",
"            Indents specified line(s)",
"---------------------------------------------------------------------",
"unindent [line] or [line1,line2,line3] or [start-end] or ['marked']",
"or ['selection']",
"",
"            Unindents specified line(s)",
"---------------------------------------------------------------------",
"replace ['marked']['selected'] text1 with text2",
"",
"            Replaces occurrences of 'text1' with 'text2'. Can act on",
"            all lines in document or marked/selected lines only",
"",
"                examples:",
"                    ##replace cout with print",
"                    ##replace marked true with True",
"                    ##replace selected false with False",
"---------------------------------------------------------------------",
"timestamp   Appends current time & date to current line",
"---------------------------------------------------------------------",
"strip       Removes trailing whitespace from ALL lines",
"---------------------------------------------------------------------",
"undo        Rudimentary undo feature with 1 undo level",
"",

"#####################################################################",
"######################## COMMANDS (NAVIGATION) ######################",
"#####################################################################",
"goto [line] or ['start'] or ['end'] or [function/class name]",
"",
"            Move to specified line number or function definition",
"---------------------------------------------------------------------",
"prev        Returns to previous line (no args)",
"---------------------------------------------------------------------",
"find [text]",
"",
"            Find specified text string and move to line containing it",
"---------------------------------------------------------------------",
"mark [line] or [line1,line2,line3] or [start-end] or [text]",
"",
"            Marks/hilights lines with specified text or specified",
"            line numbers.",
"---------------------------------------------------------------------",
"unmark [line] or [line1,line2,line3] or [start-end] or [text] or [all]",
"",
"            Unmarks line(s) that are marked. Use 'unmark all' to",
"            unmark the entire document.",
"---------------------------------------------------------------------",
"collapse [line] or [line1,line2,line3] or [start-end] or ['functions']",
"         or ['all'] or ['tab' number] or ['marked'] or ['selection']",
"",
"            Collapses lines with greater indentation than specified",
"            line(s). Simplifies navigation by hiding the details.",
"            It can even collapse lines with a specified indentation.",
"                example: ##collapse tab 2",
"---------------------------------------------------------------------",
"expand [line] or [line1,line2,line3] or [start-end] or ['all'] or",
"        ['marked'] or ['selection']",
"",
"            Expands (uncollapses) specified line(s). Use 'expand all'",
"            to expand all lines.",
"",

"#####################################################################",
"###################### COMMANDS (SETTINGS) ##########################",
"#####################################################################",
"NOTE: Changes not saved to settings file until 'saveprefs' is used!",
"      Some settings can alternatively be changed by using the",
"      commands 'show' & 'hide'.",
"---------------------------------------------------------------------",
"syntax [on/off]",
"(show/hide syntax)",
"",
"            Toggles syntax hilighting",
"---------------------------------------------------------------------",
"debug [on/off]",
"(show/hide bugs)",
"",
"            Toggles debug mode. Lines with errors marked with ##!",
"---------------------------------------------------------------------",
"formatting [on/off]",
"(show/hide formatting)",
"",
"            Toggles comment formatting",
"---------------------------------------------------------------------",
"whitespace [on/off]",
"(show/hide whitespace)",
"",
"           Toggles visible whitespace",
"---------------------------------------------------------------------",
"tabs [on/off]",
"(show/hide tabs)",
"",
"           Toggles visible indentation (tabs)",
"---------------------------------------------------------------------",
"entry [on/off]",
"(show/hide entry)",
"",
"           Toggles entry hilighting (hilights the current line being",
"           edited)",
"---------------------------------------------------------------------",
"live [on/off]",
"(show/hide live)",
"",
"           Toggles live (real-time) syntax hilighting on entry line",
"---------------------------------------------------------------------",
"split [on/off] or [line]",
"(show/hide splitscreen)",
"",
"           Toggles splitscreen. If a line number is the argument,",
"           splitscreen display begins at that line",
"---------------------------------------------------------------------",
"pageguide [on/off] or [number]",
"(show/hide guide)",
"",
"              Toggles page guide. If a number is the argument,",
"              guide occurs after that number of characters.",
"              The default page guide is 80 characters wide.",
"",
"              NOTE: Terminal width must be at least 88 characters",
"              to view 80 character page guide!",
"---------------------------------------------------------------------",
"protect [on/off] or ['with' text]",
"",
"           Toggles command protection and can optionally change",
"           protect string.",
"",
"                example: ##protect with ::",
"---------------------------------------------------------------------",
"commands [on/off]",
"",
"            Toggles inline (live) commands.",
"            When off, ENTRY WINDOW is the ONLY way to enter commands.",
"---------------------------------------------------------------------",
"auto [on/off]",
"",
"            Toggles automation of settings. When on, automatically",
"            adjusts settings to match file type.",
"            '.py' - debug mode on, syntax hilighting on, protect off",
"            other - debug off, syntax hilighting off, protect on",
"---------------------------------------------------------------------",
"acceleration [on/off]",
"",
"            Toggles cursor acceleration. While on, cursor speed",
"            increases over time as you hold down the arrow keys.",
"---------------------------------------------------------------------",
"color on    Manually start color if supported by your terminal",
"---------------------------------------------------------------------",
"color default",
"",
"            Set colors to their default values",
"---------------------------------------------------------------------",
"setcolors   Opens selection screen to allow you to set colors used",
"            with syntax hilighting",
"",

"#####################################################################",
"######################## SPECIAL FEATURES ###########################",
"#####################################################################",
"HELP",
"    Similar to the help() feature in the python interpreter, attempts",
"    to show the help file/doc string for given module, class, or",
"    function. Can only show help for imported modules and classes &",
"    functions defined within your code.",
"",
"    Navigate up/down using up and down arrow keys, or the 'b' key",
"    and spacebar. Left & right arrows will change 'pages'.",
"    Press 's' to go to the start of the document.",
"    Press 'e' to go to the end.",
"    Press 'q' to quit (or any key if help is less than one page).",
"",
"    example:",
"            ##import os",
"            ##help os",
"            ##help os.path.exists",
"---------------------------------------------------------------------",
"DEBUG MODE",
"    Realtime python debugging. While it won't catch all errors, it",
"    should flag simple errors such as incorrect use of the comparison",
"    operator '==' or forgetting to indent when necessary.",
"",
"    DEBUG MODE (as well as syntax highlighting) can be processor",
"    intensive and should be turned off on older machines to improve",
"    performance.",
"---------------------------------------------------------------------",
"COMMENT FORMATTING",
"    When on, '#' is a regular comment, '##' is a formatted comment.",
"    Formats:",
"        '##TEXT' - Left Justified",
"##Hello World",
"        '###TEXT' - Right Justified",
"###Hello World",
"        '##TEXT##' - Centered",
"##Hello World##",
"        '##='  - Separator (fills line with last character)",
"##=",
"        '##' - empty (same color as centered)",
"###",
"        '....##TEXT' - Comment Block (after indent or other characters)",
"    ##BLOCK OF TEXT",
"---------------------------------------------------------------------",
"READ MODE",
"    In Read Mode, file can be viewed but not edited. Debugging and",
"    syntax hilighting (save for comment formatting) are turned off.",
"    Navigate up/down using up and down arrow keys, or the 'b' key",
"    and spacebar. Left & right arrows will change 'pages'.",
"    Press 's' to go to the start of the document.",
"    Press 'e' to go to the end.",
"    Press 'q' to quit.",
"---------------------------------------------------------------------",
"ENCRYPTION",
"    When saving, you can choose to save a password protected file with",
"    basic encryption (in theory, the longer the password the better",
"    the encryption). Simply save with the extension '.pwe', short for",
"    'warrior-ide encryption'.",
"",
"        NOTE: It is recommended that you save a non-encrypted version",
"        of your file first. If you forget your password or something",
"        goes wrong during the encryption process, your file will not",
"        be recoverable! No guarantees are made as to the strength of",
"        the encryption, ##USE AT YOUR OWN RISK!",
"",

"#####################################################################",
"############################## FLAGS ################################",
"#####################################################################",
"warrior-ide [OPTIONS] [FILENAME]",
"",
"-t, --text      Open in text mode with protection on",
"-s, --string    Sets protection string (and turns protection on)",
"-p, --python    Open in python mode with syntax and debugging on",
"-c, --color     Open in color mode with default colors",
"-m, --mono      Open in monochrome mode",
"-i, --inverted  Open in monochrome mode with inverted display",
"-n, --nobold    Turns off bold text",
"-r, --read      Opens specified file in 'read only' mode",
"-h, --help      Display Help Guide",
"",
"        example:",
"            ##warrior-ide --text --string '::' ~/Desktop/myfile.txt",
"",
"####################### Last edited on 07/22/08 01:05:49 PM (Tuesday)"]

################################################################~#
############################## CLASSES ###########################
################################################################~#
class line(object):
    """This class represents an individual line of text/code"""
    db = {}
    number = 0
    total = 0
    locked = False
    def __init__(self, text = ""):
        line.total = len(line.db) + 1
        self.number = line.total
        line.db[self.number] = self
        self.__text = text
        self.calcRows()
        self.splitRows()
        self.calcCursor()
        self.__y = 0
        self.__x = self.end_x
        self.end_y = 0 - self.number_of_rows + 1
        self.length = len(text)
        self.syntax = {}
        self.listing = []
        self.executable = False
        self.collapsed = False
        self.indent_required = False
        self.error = False
        self.indentation = len(self.__text)-len(self.__text.lstrip())
        self.marked = False
        self.selected = False
        self.continue_quoting = False
        self.equal_continues = False
        self.if_continues = False

        for character in text: self.listing.append(character)

    def __str__(self):
        return self.__text
    def __int__(self):
        return self.db
    def __add__(self, char):
        newText = self.__text + char
        self.setText(newText)
    def calcRows(self, width = ROWSIZE):
        """Calculates the number of rows required to print line"""
        number_of_lines = int(len(self.__text)/width + 1)
        self.number_of_rows = number_of_lines

    def checkExecutable(self):
        """Checks text to see if it contains an executable command"""
        if not settings["inline_commands"]: return
        if not settings["hilight_commands"]: return
        if not self.text:
            self.executable = False
            return
        for item in (" ", "#", "run ", "strip ", "prev ", "new ", "quit ", "revert ", "timestamp ", "undo ", "saveprefs ", "setcolor ", "setcolors ", "previous "):
            if self.text.startswith(item):
                self.executable = False
                return
        word1 = ""
        word2 = ""
        temp_list = self.text.split()
        if temp_list: word1 = temp_list[0]
        if len(temp_list) >= 2: word2 = temp_list[1]
        if settings["inline_commands"] == "protected":
            p_string = settings["protect_string"]
            if not word1.startswith(p_string): return
            word1 = word1.replace(p_string, "", 1)

        if word1 and word1 in EXECUTABLES and word1 == EXECUTABLES[EXECUTABLES.index(word1)]:
            if word1 in ("replace", "protect") and " with " in self.text:
                self.executable = True
            elif len(temp_list) > 1 and word2 and word2[0] in ("=","+","-","*","/","%","(","[","{"):
                if word1 in ("save", "saveas","load") and word2[0] == "/": pass
                else: self.executable = False
            elif word1 in ("syntax","entry","live","formatting", "tab","tabs","whitespace","show", "hide","goto","color", "help", "debug", "split", "guide", "pageguide") and self.text.count(" ") > 1:
                self.executable = False
            elif word1 in ("replace", "protect") and self.text.count(" ") > 3 and " with" not in self.text and "|" not in self.text:
                self.executable = False
                return

            elif word1 not in ("replace", "protect", "find", "save", "saveas", "load", "mark") and self.text.count(" ") - 1 > self.text.count(",") + (2 * self.text.count("-")):
                self.executable = False
                return
            elif word1 not in ("replace", "protect", "find", "save", "saveas", "load", "mark") and self.text.count("-") > 1:
                self.executable = False
                return
            elif word1 not in ("replace", "protect", "find", "save", "saveas", "load","mark") and "-" in self.text and "," in self.text:
                self.executable = False
                return
            else:
                self.executable = True
        else:
            self.executable = False

    def splitRows(self, width = ROWSIZE):
        """This funcion creates a dictionary with strings of proper size"""
        self.row = {}
        for i in range(0,self.number_of_rows):
            self.row[i] = self.__text[(width*i):(width*i+width)]

    def addSyntax(self, width = ROWSIZE):
        """This function creates a dictionary with added syntax"""
        self.syntax = {}
        self.continue_quoting = False
        doublequote = False; singlequote = False; triplequote = False; comment = False; command = False; numberChar = False; operator = False; function = False; seperator = False; backslash = False; markOn = False; myclass = False; negative = False; negative = False

        quotenumber = 0
        marknum = 1

        if self.number > 1 and line.db[self.number-1].continue_quoting: triplequote = True
        ##New section to fix multi-line quoting (with '\')
        elif self.number > 1 and "_!DQT!_" in str(line.db[self.number-1].syntax.values()) and "_!OFF!_" not in str(line.db[self.number-1].syntax.values()) and line.db[self.number-1].text.endswith('\\'):
            doublequote = True
        elif self.number > 1 and "_!SQT!_" in str(line.db[self.number-1].syntax.values()) and "_!OFF!_" not in str(line.db[self.number-1].syntax.values()) and line.db[self.number-1].text.endswith('\\'):
            singlequote = True

        try:
            if self.text and self.text[self.indentation] == "#": triplequote = False
        except:
            pass

        count = 0

        for key in range(0, len(self.row)):
            templist = []
            word = ""
            phrase = ""
            oldletter = ""

            for j in range(0, len(self.row[key])):
                letter = self.row[key][j]
                try:
                    nextLetter = self.row[key][j+1]
                except:
                    nextLetter = ""

                word += letter

                varFound = False #This bit used to determine when a number is part of variable
                if len(word) > 1:
                    if word[1].isalpha(): varFound = True
                    elif word[0].isalpha(): varFound = True
                elif len(word) == 1:
                    if word[0].isalpha(): varFound = True

                if markOn: marknum += 1

                if self.marked and self.marked != True and self.marked in self.row[key]:
                    try:
                        if self.row[key][j:j+len(self.marked)] == self.marked:
                            templist.append("_!MAR!_")
                            markOn = True
                    except:
                        pass

                if not backslash and not singlequote and not doublequote and not triplequote:
                    try:
                        threesome = self.row[key][j:j+3]
                        if threesome == '"""':
                            triplequote = True
                            templist.append("_!TQT!_")
                            templist.append(letter)
                            word = ""
                            continue
                    except:
                        pass

                if letter == '"': quotenumber +=1 #trying to fix triple quotes broken by line break
                else: quotenumber = 0

                if not backslash and letter == "\\":
                    if singlequote or doublequote or triplequote:
                        backslash = True
                        templist.append(letter)
                        continue

                if backslash and letter in ('"',"'","\\","n","t","a","r","f","b"): #added 'r', 'f' and 'b'
                    backslash = False
                    templist.append(letter)
                    continue

                if triplequote and not templist:
                    templist.append("_!TQT!_")
                elif doublequote and not templist:
                    templist.append("_!DQT!_")
                elif singlequote and not templist:
                    templist.append("_!SQT!_")

                if numberChar and letter not in ("0123456789"):
                    numberChar = False
                    templist.append("_!NOF!_")

                if operator and letter not in ("+-*/%=><![](){}"):
                    operator = False
                    templist.append("_!OOF!_")

                if settings["show_indent"] and letter == " " and count < self.indentation:
                    templist.append("_!IND!_")
                    count += 1
                elif settings["showSpaces"] and letter == " " and not command and not function and not myclass:
                    templist.append("_!SPA!_")

                if seperator and not templist:  #comment lines that wrap across rows
                    templist.append("_!SEP!_")

                if comment and not templist:  #comment lines that wrap across rows
                    templist.append("_!CMT!_")
                    templist.append(letter)

                elif word in ("def","def:") and not doublequote and not singlequote and not triplequote and not command and not function and not myclass and not comment and not seperator and nextLetter in (" ", ""):
                    templist.insert(-len(word)+1,"_!FUN!_")
                    function = True
                    word = ""
                    templist.append(letter)

                elif word in ("class","class:") and not doublequote and not singlequote and not triplequote and not command and not function and not myclass and not comment and not seperator and nextLetter in (" ", ""):
                    templist.insert(-len(word)+1,"_!CLA!_")
                    myclass = True
                    word = ""
                    templist.append(letter)

                elif word.endswith("False") and not word[word.rfind("False")-1:].isalnum() and not doublequote and not singlequote and not triplequote and not comment and not seperator and not function and nextLetter in (" ","",")",",",";","]","}",":"):
                    templist.insert(-len("False")+1,"_!NEG!_")
                    negative = True
                    word = ""
                    templist.append(letter)
                    templist.append("_!NEO!_")

                elif word[word.rfind("(")+1:] in ("not", "False", "False,", "False)", ", False)", "False:") and not doublequote and not singlequote and not triplequote and not comment and not seperator and not function and nextLetter in (" ","",")",",",";","]","}",":"):
                    if "(" in word:
                        templist.insert(-len(word[word.rfind("(")+1:])+1,"_!NEG!_")
                    elif ":" in word:
                        templist.insert(-len(word[word.find(":")+1:])+1,"_!NEG!_")
                    else:
                        templist.insert(-len(word)+1,"_!NEG!_")
                    negative = True
                    word = ""
                    templist.append(letter)
                    templist.append("_!NEO!_")

                elif word.endswith("True") and not word[word.rfind("True")-1:].isalnum() and not doublequote and not singlequote and not triplequote and not comment and not seperator and not function and not nextLetter.isalnum():
                    templist.insert(-len("True")+1,"_!POS!_")
                    positive = True
                    word = ""
                    templist.append(letter)
                    templist.append("_!POO!_")

                elif word[word.rfind("(")+1:] in ("True", "True,", "True)", ",True)", "True:") and not doublequote and not singlequote and not triplequote and not comment and not seperator and not function and nextLetter in (" ","",")",",",";","]","}",":"):
                    if "(" in word:
                        templist.insert(-len(word[word.rfind("(")+1:])+1,"_!POS!_")
                    elif ":" in word:
                        templist.insert(-len(word[word.find(":")+1:])+1,"_!POS!_")
                    else:
                        templist.insert(-len(word)+1,"_!POS!_")
                    positive = True
                    word = ""
                    templist.append(letter)
                    templist.append("_!POO!_")

                # New bit for CONSTANT variables
                elif not nextLetter.isalnum() and nextLetter != "_"  and not singlequote and not doublequote and not triplequote and not comment and not seperator and word[word.rfind("(")+1:].isupper() and "'" not in word and '"' not in word and len(word[word.rfind("(")+1:]) > 2 and word[word.rfind("(")+1].isalpha() and "+" not in word and "-" not in word and "*" not in word and "/" not in word:
                    if "(" in word:
                        templist.insert(-len(word[word.rfind("(")+1:])+1,"_!CON!_")
                    else:
                        templist.insert(-len(word)+1,"_!CON!_")
                    word = ""
                    templist.append(letter)
                    templist.append("_!COO!_")

                # New bit for CONSTANT variables (handling ':')
                elif not nextLetter.isalnum() and nextLetter != "_"  and not singlequote and not doublequote and not triplequote and not comment and not seperator and word[word.rfind(":")+1:].isupper() and "'" not in word and '"' not in word and len(word[word.rfind(":")+1:]) > 2 and word[word.rfind(":")+1].isalpha() and "+" not in word and "-" not in word and "*" not in word and "/" not in word:
                    if ":" in word:
                        templist.insert(-len(word[word.rfind(":")+1:])+1,"_!CON!_")
                    else:
                        templist.insert(-len(word)+1,"_!CON!_")
                    word = ""
                    templist.append(letter)
                    templist.append("_!COO!_")

                # New bit for CONSTANT variables (handling '[')
                elif not nextLetter.isalnum() and nextLetter != "_"  and not singlequote and not doublequote and not triplequote and not comment and not seperator and word[word.rfind("[")+1:].isupper() and "'" not in word and '"' not in word and len(word[word.rfind("[")+1:]) > 2 and word[word.rfind("[")+1].isalpha() and "+" not in word and "-" not in word and "*" not in word and "/" not in word:
                    if "[" in word:
                        templist.insert(-len(word[word.rfind("[")+1:])+1,"_!CON!_")
                    else:
                        templist.insert(-len(word)+1,"_!CON!_")
                    word = ""
                    templist.append(letter)
                    templist.append("_!COO!_")

                elif word in COMMANDS and not doublequote and not singlequote and not triplequote and not command and not function and not myclass and not comment and not seperator and nextLetter in (" ", "", ",", ";"):
                    templist.insert(-len(word)+1,"_!CMD!_")
                    command = True
                    word = "" #changed from one space
                    templist.append(letter)

                elif function == True and letter in (" :=<>.()[]abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):
                    function = False
                    templist.append("_!FOF!_")
                    if letter == " " and settings["showSpaces"]:
                        templist.append("_!SPA!_")
                    templist.append(letter)

                elif myclass == True and letter in (" :=<>.()[]abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):
                    myclass = False
                    templist.append("_!FOF!_")
                    if letter == " " and settings["showSpaces"]:
                        templist.append("_!SPA!_")
                    templist.append(letter)

                elif command == True and letter in (" :=<>.()[]abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):
                    command = False
                    templist.append("_!NOC!_")
                    if letter == " " and settings["showSpaces"]:
                        templist.append("_!SPA!_")
                    templist.append(letter)
                # New part to check for triplequotes
                elif letter == '"' and '"""' in word and not backslash and not singlequote:
                    if triplequote and "\\" in word:
                        try:
                            threesome = self.row[key][j-2:j+1]
                            fourago = self.row[key][j-3]
                            if threesome == '"""' and fourago != "\\":
                                triplequote = False
                                templist.append(letter)
                                templist.append("_!OFF!_")
                                word = ""
                                self.continue_quoting = False
                            else:
                                templist.append(letter)
                        except:
                            pass

                    elif triplequote:
                        triplequote = False
                        templist.append(letter)
                        templist.append("_!OFF!_")
                        word = ""
                        self.continue_quoting = False
                    else:
                        triplequote = True
                        templist.append("_!TQT!_")
                        templist.append(letter)
                        word = ""
                elif letter == '"' and not backslash and triplequote and quotenumber == 3: #new bit to fix triple quotes broken by line break
                    triplequote = False
                    templist.append(letter)
                    templist.append("_!OFF!_")
                    word = ""
                    self.continue_quoting = False

                elif letter == '"' and not backslash and not triplequote and not doublequote and not singlequote and not comment and not seperator:
                    doublequote = True
                    templist.append("_!DQT!_")
                    templist.append(letter)
                elif letter == "'" and not backslash and not triplequote and not doublequote and not singlequote and not comment and not seperator:
                    singlequote = True
                    templist.append("_!SQT!_")
                    templist.append(letter)
                elif letter == '"' and doublequote and not backslash:
                    doublequote = False
                    templist.append(letter)
                    templist.append("_!OFF!_")
                elif letter == "'" and singlequote and not backslash:
                    singlequote = False
                    templist.append(letter)
                    templist.append("_!OFF!_")


                elif letter == "#" and not doublequote and not singlequote and not triplequote and not seperator:
                    if nextLetter == "#":
                        seperator = True
                        templist.append("_!SEP!_")
                    else:
                        comment = True
                        templist.append("_!CMT!_")
                    templist.append(letter)

                ##new number check
                elif letter.isdigit() and not varFound and not numberChar and not doublequote and not singlequote and not triplequote and not comment and not seperator:
                    numberChar = True
                    templist.append("_!NUM!_")
                    templist.append(letter)

                elif letter.isdigit() and not numberChar and numLeftOf(word, len(word)) and not oldletter.isalpha() and not doublequote and not singlequote and not triplequote and not comment and not seperator:
                    numberChar = True
                    templist.append("_!NUM!_")
                    templist.append(letter)

                elif letter in ("01234567890") and not numberChar and j == 0 and not doublequote and not singlequote and not triplequote and not comment and not seperator:
                    numberChar = True
                    templist.append("_!NUM!_")
                    templist.append(letter)

                elif letter in ("+-*/%=><![](){}") and not numberChar and not doublequote and not singlequote and not triplequote and not comment and not seperator:
                    operator = True
                    templist.append("_!OPE!_")
                    templist.append(letter)

                else:
                    templist.append(letter)
                if letter == " " or letter == "    ": word = ""

                if markOn and marknum == len(self.marked):
                    templist.append("_!MOF!_")
                    markOn = False
                    marknum = 1

                oldletter = letter

            self.syntax[key] = templist
        if triplequote: self.continue_quoting = True

    def setText(self, text):
        """Changes line text and updates other attributes"""
        if line.locked: return # don't allow editing if locked
        old_len = len(self.__text)
        self.__text = text
        self.calcRows()
        self.splitRows()
        self.calcCursor()
        self.length = len(text)
        self.listing = []
        for character in text: self.listing.append(character)
        self.end_y = 0 - self.number_of_rows + 1
        self.indentation = len(self.__text)-len(self.__text.lstrip())
        self.checkExecutable()
        ##Add syntax if line other than current line is edited (fix acceleration bug)
        if settings["syntax_hilighting"] and self.number != currentNum:
            self.addSyntax()

    def getText(self):
        return self.__text
    def setx(self, num):
        self.__x = num
        if self.__x < 6 and self.__y >= self.end_y:
            self.__x = WIDTH - 1
            self.__y -= 1
            if self.__y < self.end_y:
                self.__y = 0
                self.__x = self.end_x
        elif self.__x < 6 and self.__y != 0:
            self.__x = WIDTH - 1
        elif self.__x < 6:
            self.__x = self.end_x
        elif self.__x > WIDTH - 1 and self.__y < 0:
            self.__x = 6
            self.__y += 1
        elif self.__x > self.end_x and self.__y == 0:
            self.__y = self.end_y
            self.__x = 6
    def sety(self, num):
        self.__y = num
        if self.__y < self.end_y: self.__y = 0
        elif self.__y > 0: self.__y = 0
    def getx(self):
        return self.__x
    def gety(self):
        return self.__y
    def swap(self, obj):
        temptext = self.__text
        self.setText(obj.__text)
        obj.setText(temptext)
    def renum(self):
        """Renumber lines"""
        current_Num = 1
        for key, value in line.db.items():
            temp = value
            line.db[current_Num] = value
            line.db[current_Num].number = current_Num #new bit

            if value.number > current_Num:
                del line.db[key]
                line.db[1].recalcTotal()
            current_Num += 1

    def calcCursor(self):
        self.end_x = len(self.row[(self.number_of_rows - 1)]) + 6
    text = property(getText, setText)
    x = property(getx, setx)
    y = property(gety, sety)

    def recalcTotal(self):
        line.total = len(line.db)

####################################################~#
####################### FUNCTIONS ####################
####################################################~#
def load(mypath, readOnly = False):
    """Loads file and creates line objects for each line"""
    global currentNum, program_message, savepath, saved_since_edit, text_edited, prev_line
    global undo_list, undo_text_que, undo_state_que, undo_state, undo_mark_que, undo_mark
    extension = ""

    if "'" in mypath: mypath = mypath.replace("'","")
    if '"' in mypath: mypath = mypath.replace('"','')
    if "~" in mypath: mypath = mypath.replace("~", os.path.expanduser("~"))

    if reset_needed: resetLine()

    try:
        if mypath.endswith(".pwe"): ##load encrypted file
            (temp_lines, extension) = loadEncrypted(mypath)
            if not temp_lines: ##End function if encyption fails
                program_message = " Unencrypt failed! "
                return
            program_message = " File load and decode successful "
            encrypted = True
        elif os.path.exists(mypath): ##if path exists, attempt to load file
            if not os.access(mypath, os.R_OK): ##Display error message if you don't have read access
                if WIDTH >= 69: getConfirmation("You don't have permission to access this file!", True)
                else: getConfirmation("Access not allowed!", True)
                program_message = " Load failed! "
                return
            rawsize = os.path.getsize(mypath)/1024.00 #get size and convert to kilobytes
            if rawsize > 8000 and not getConfirmation("  Excessive file size! Continue? (y/n)  "):
                program_message = " Load aborted "
                return

            myfile = open(mypath)
            temp_lines = myfile.readlines()
            myfile.close()
            encrypted = False
            if not temp_lines: ##stop loading if file is empty
                getConfirmation("Load failed, file empty!", True)
                program_message = " Load failed! "
                return
        else: ##Display message if path doesn't exist
            getConfirmation("Error - file/path does not exist!", True)
            program_message = " Load failed! "
            return
    except:
        getConfirmation("Error - file/path does not exist!", True)
        program_message = " Load failed! "
        return
    try:
        if line.db:
            del line.db
            line.db = {}
    except:
        pass

    if temp_lines[-1] not in ("\n","\r",""): temp_lines.append("") #edited to stop multiple empty lines at end of file
    # Set lines to line class
    count = 0
    length = len(temp_lines)

    if readOnly: ##adjust settings if read Only
        copySettings()
        settings["debug"] = False
        settings["show_indent"] = False
        settings["entry_hilighting"] = False
        settings["syntax_hilighting"] = True
        settings["format_comments"] = True
        settings["live_syntax"] = True
        settings["showSpaces"] = False
        settings["splitscreen"] = False

    if settings["auto"] and not readOnly: ##Auto adjust settings based on file format
        if mypath.endswith(".py") or extension == ".py":
            settings["syntax_hilighting"] = True
            settings["entry_hilighting"] = True
            settings["live_syntax"] = True
            settings["debug"] = True
            settings["format_comments"] = True
            settings["show_indent"] = True
            settings["inline_commands"] = True
        else:
            settings["syntax_hilighting"] = False
            settings["live_syntax"] = False
            settings["debug"] = False
            settings["format_comments"] = False
            settings["show_indent"] = False
            settings["show_whitespace"] = False
            settings["inline_commands"] = "protected" ##protect commands with protect string

    if length > 9999: ##Turn off special features if document is huge (speed optimization)
        settings["syntax_hilighting"] = False
        settings["live_syntax"] = False
        settings["debug"] = False

    if length > 500: ##Show status message
        stdscr.addstr(0,0, " " * (WIDTH - 13), settings["color_header"])
        stdscr.addstr(0,0, "Loading...",settings["color_warning"])
        stdscr.addstr(0,WIDTH, " ", settings["color_header"]) #new bit to stop random character from appearing
        stdscr.refresh()

    currentNum = 0
    total_rows = 0
    for string in temp_lines:
        count += 1
        string = string.replace("\t","    ")
        string = string.replace("    ","    ")
        string = string.replace("\n","")
        string = string.replace("\r","")
        string = string.replace("\f", "") #form feed character, apparently used as seperator?

        l = line(string)

        if count in (1,2,3,10,100): ##check to see if encoding understood
            try:
                stdscr.addstr(0, 0, l.text[0:WIDTH])  #Tests output
                stdscr.addstr(0, 0, (" " * WIDTH))  #clears line
            except:
                getConfirmation("Error, can't read file encoding!", True)
                newDoc()
                return

        if length > 500 and count/100.0 == int(count/100.0):
            statusMessage("Loading: ", (100/(length * 1.0/count)), True)

        if settings["syntax_hilighting"] or settings["debug"]:
            l.addSyntax()
            errorTest(l.number)

        #This part checks number of rows so doc is opened properly in 'read' mode
        total_rows += (l.number_of_rows - 1)
        if l.number <= (HEIGHT -2) and currentNum + total_rows < (HEIGHT - 2): currentNum += 1

    currentNum -= 1 #adjustment to fix bug
    if currentNum > (HEIGHT - 2): currentNum = (HEIGHT - 2)
    if currentNum < 1: currentNum = 1

    prev_line = currentNum

    if settings["collapse_functions"]: collapse_functions()
    if not encrypted: program_message = " File loaded successfully "
    if not encrypted: savepath = mypath
    else:
        if extension and extension != ".???":
            savepath = mypath.replace(".pwe", "") + extension
        else:
            savepath = mypath.replace(".pwe", "")
    if "/" not in savepath: savepath = os.path.abspath(savepath)
    saved_since_edit = True
    if readOnly: line.locked = True
    else: currentNum = line.total #goto end of line if not readOnly mode
    undo_list = []; undo_text_que = []; undo_state_que = []; undo_state = []; undo_mark_que = []; undo_mark = []

def save(mypath = False):
    """Saves file"""
    global savepath, program_message, saved_since_edit
    oldPath = savepath
    try:

        if not mypath:
            mypath = promptUser("ENTER FILENAME:",(os.getcwd()+"/"))
            if not mypath:
                program_message = " Save aborted! "
                return
        if "~" in mypath: mypath = mypath.replace("~", os.path.expanduser("~")) #changes tilde to full pathname
        if "/" not in mypath and savepath and "/" in savepath:
            part1 = os.path.split(savepath)[0]
            part2 = mypath
            tempPath = part1 + "/" + part2
            mypath = promptUser("Save this file?",tempPath)
            if not mypath:
                program_message = " Save aborted! "
                return

        elif "/" not in mypath:mypath = os.path.abspath(mypath)
        elif "../" in mypath:
            (fullpath, filename) = os.path.split(savepath)
            mypath = os.path.abspath((fullpath + "/" + mypath))

        if mypath.endswith(".pwe"): ##Save encrypted file
            saveEncrypted(mypath)
            return

        if os.path.isdir(mypath): ##stop save process if path is directory
            getConfirmation(" You can't overwrite a directory! ", True)
            program_message = " Save failed! "
            return

        if os.path.exists(mypath) and not os.access(mypath, os.W_OK):
            getConfirmation("Error, file is READ only. Use 'saveas'", True)
            program_message = (" Save failed! ")
            return

        if mypath != savepath and os.path.exists(mypath) and not getConfirmation(" File exists, overwrite? (y/n) "):
            program_message = " Save aborted! "
            return

        savepath = mypath
        text_file = open(savepath, "w")
        for key in line.db:
            thisText = (line.db[key].text + "\n")
            text_file.write(thisText)
        text_file.close()
        program_message = " File saved succesfully "
        saved_since_edit = True
    except:
        getConfirmation("ERROR - check path, file not saved", True)
        program_message = (" Save failed! ")
        savepath = oldPath

def saveSettings():
    """Save program settings"""
    global program_message
    if reset_needed: resetLine()
    userpath = os.path.expanduser("~")
    if OperatingSystem == "Macintosh":
        settingsPath = userpath + "/Library/Preferences/warrior-ide"
    else:
        settingsPath = userpath + "/.warrior-ide"
    settings_list = []
    text_file = open(settingsPath, "w")
    for key, value in settings.items():
        line_of_text = text_string = "%s = %s" %(str(key), str(value)) + "\n"
        settings_list.append(line_of_text)
    settings_list.sort()
    for item in settings_list:
        text_file.write(item)
    program_message = " Settings saved "

def loadSettings():
    """Load user settings"""
    userpath = os.path.expanduser("~")
    if OperatingSystem == "Macintosh":
        settingsPath = userpath + "/Library/Preferences/warrior-ide"
    else:
        settingsPath = userpath + "/.warrior-ide"
    if os.path.exists(settingsPath):
        myfile = open(settingsPath)
        prefList = myfile.readlines()
        myfile.close()
        for i in range (0, len(prefList)):
            item = prefList[i]
            item = item.replace(" = ", "=")
            item = item.replace("\n","")
            (key, value) = item.split("=")
            try:
                value = int(value) #convert value to number if possible
            except:
                pass
            if value == "True": value = True
            elif value == "False": value = False
            settings[key] = value
        return True
    else: return False

def printSyntax(templist, x = 6, y = HEIGHT - 2, collapsed = False, entry_line = False):
    """Prints a line of code with syntax hilighting"""
    global print_at_row
    command = False; comment = False; doublequote = False; singlequote = False; triplequote = False; space = False; indent = False; numberChar = False; operator = False; function = False; seperator = False; marked = False; firstPrinted = False; myclass = False; negative = False; positive = False; constant = False
    indentnum = 0
    if settings["live_syntax"] and entry_line and not line.locked:
        realtime = True
        completeString = ""
        for txt in templist: completeString += txt

    else: realtime = False

    if settings["inline_commands"] == "protected":
        p_string = settings["protect_string"]
        p_len = len(p_string)
    else:
        p_string = ""; p_len = 0

    itemString = ""

    for item in templist:
        itemString += item
        ##Hilighting commands is now handled by different part of program!
        #try:
        if settings["format_comments"] and item == "_!SEP!_" and not realtime:
            commentstring = ""
            for t in templist: commentstring += t
            commentstring = commentstring.replace("_!SEP!_","")
            commentstring = commentstring.replace("_!SPA!_","")
            commentstring = commentstring.replace("_!MAR!_","")
            commentstring = commentstring.replace("_!MOF!_","")
            commentstring = commentstring.replace("_!IND!_","")
            if commentstring[0:2] == "##" and formattedComments(commentstring):
                formattedText = formattedComments(commentstring)
                if formattedText.strip() == "**DEBUG**":
                    stdscr.addstr(y, x, formattedText, settings["color_warning"])
                elif commentstring[-1] == "#": #centered
                    stdscr.addstr(y, x, formattedText, settings["color_comment_centered"])
                elif commentstring[0:3] == "###" and len(commentstring.replace("#","")) > 1: #right justified
                    stdscr.addstr(y, x, formattedText, settings["color_comment_rightjust"])
                elif len(commentstring.replace("#","")) ==  1: #seperator
                    stdscr.addstr(y, x, formattedText, settings["color_comment_seperator"])
                else:
                    stdscr.addstr(y, x, formattedText, settings["color_comment_leftjust"])
                return

            else:
                if "##" in commentstring: commentText = commentstring[commentstring.find("##")+2:]
                else: commentText = commentstring
                stdscr.addstr(y, x, commentText, settings["color_comment_block"])
                return

        #except:
            #pass

        if item == "_!MAR!_": marked = True
        elif item == "_!SPA!_": space = True
        elif item == "_!MOF!_": marked = False
        elif item == "_!IND!_": indent = True; indentnum += 1
        elif item == "_!FUN!_": function = True
        elif item == "_!CLA!_": myclass = True
        elif item == "_!FOF!_": function = False; myclass = False
        elif item == "_!CMD!_": command = True
        elif item == "_!NOC!_": command = False; firstPrinted = True
        elif item == "_!SEP!_": seperator = True
        elif item == "_!CMT!_": comment = True
        elif item == "_!NUM!_": numberChar = True
        elif item == "_!NEG!_": negative = True
        elif item == "_!NEO!_": negative = False
        elif item == "_!POS!_": positive = True
        elif item == "_!POO!_": positive = False
        elif item == "_!CON!_": constant = True
        elif item == "_!COO!_": constant = False
        elif item == "_!OPE!_": operator = True
        elif item == "_!NOF!_": numberChar = False
        elif item == "_!OOF!_": operator = False
        elif item == "_!TQT!_": triplequote = True
        elif item == "_!DQT!_": doublequote = True
        elif item == "_!SQT!_": singlequote = True
        elif item == "_!OFF!_": doublequote = False; singlequote = False; triplequote = False

        elif marked:
            stdscr.addstr(y, x, item, settings["color_mark"])
            x += len(item)

        elif line.locked:
            stdscr.addstr(y, x, item, settings["color_normal"])
            x += len(item)

        elif seperator:
            if realtime and settings["entry_hilighting"]:
                stdscr.addstr(y, x, item, settings["color_entry_comment"])
                x += len(item)
            elif entry_line:
                stdscr.addstr(y, x, item, settings["color_comment"])
                x += len(item)
            else:
                if settings["format_comments"]: #fixed this so comment block could be turned off
                    commentText = item.replace("#","")
                    stdscr.addstr(y, x, commentText, settings["color_comment_block"])
                    if item != "#": x += len(item)
                else:
                    stdscr.addstr(y, x, item, settings["color_comment"])
                    x += len(item)

        elif settings["showSpaces"] and space:
            stdscr.addstr(y, x, spaceChar, settings["color_whitespace"])
            x += len(spaceChar)
        elif settings["showSpaces"] and settings["show_indent"] and indent:
            stdscr.addstr(y, x, ".", settings["color_whitespace"])
            x += 1
        elif settings["show_indent"] and indent:
            if realtime and settings["entry_hilighting"]:
                if OperatingSystem == "Linux": stdscr.hline(y,x,curses.ACS_BULLET,1,settings["color_entry_dim"])
                else: stdscr.addstr(y, x, ".", settings["color_entry_dim"])
            else:
                if indentnum > 8: indentnum = 1
                if indentnum > 4:
                    if OperatingSystem == "Linux": stdscr.hline(y,x,curses.ACS_BULLET,1,settings["color_tab_even"])
                    else: stdscr.addstr(y, x, ".", settings["color_tab_even"])  #Prints "tab
                else:
                    if OperatingSystem == "Linux": stdscr.hline(y,x,curses.ACS_BULLET,1,settings["color_tab_odd"])
                    else: stdscr.addstr(y, x, ".", settings["color_tab_odd"])  #Prints "tab"
            x += 1

        elif function and collapsed:
            if realtime and settings["entry_hilighting"]:
               stdscr.addstr(y, x, item, settings["color_entry_functions"])
            else:
                stdscr.addstr(y, x, item, settings["color_functions_reversed"])
            x += len(item)
        elif function:
            if realtime and settings["entry_hilighting"]:
               stdscr.addstr(y, x, item, settings["color_entry_functions"])
            else:
                stdscr.addstr(y, x, item, settings["color_functions"])
            x += len(item)

        elif myclass and collapsed:
            if realtime and settings["entry_hilighting"]:
               stdscr.addstr(y, x, item, settings["color_entry_class"])
            else:
                stdscr.addstr(y, x, item, settings["color_class_reversed"])
            x += len(item)
        elif myclass:
            if realtime and settings["entry_hilighting"]:
               stdscr.addstr(y, x, item, settings["color_entry_class"])
            else:
                stdscr.addstr(y, x, item, settings["color_class"])
            x += len(item)

        elif command and collapsed and not firstPrinted:
            if realtime and settings["entry_hilighting"]:
                stdscr.addstr(y, x, item, settings["color_entry_command"])
            else:
                stdscr.addstr(y, x, item, settings["color_commands_reversed"])
            x += len(item)

        elif command:
            if realtime and settings["entry_hilighting"]:
                stdscr.addstr(y, x, item, settings["color_entry_command"])
            else:
                stdscr.addstr(y, x, item, settings["color_commands"])
            x += len(item)

        elif negative:
            if realtime and settings["entry_hilighting"]:
                stdscr.addstr(y, x, item, settings["color_entry_negative"])
            else:
                stdscr.addstr(y, x, item, settings["color_negative"])
            x += len(item)

        elif positive:
            if realtime and settings["entry_hilighting"]:
                stdscr.addstr(y, x, item, settings["color_entry_positive"])
            else:
                stdscr.addstr(y, x, item, settings["color_positive"])
            x += len(item)

        elif constant:
            if realtime and settings["entry_hilighting"]:
                stdscr.addstr(y, x, item, settings["color_entry_constant"])
            else:
                stdscr.addstr(y, x, item, settings["color_constant"])
            x += len(item)

        elif numberChar:
            if realtime and settings["entry_hilighting"]:
               stdscr.addstr(y, x, item, settings["color_entry_number"])
            else:
                stdscr.addstr(y, x, item, settings["color_number"])
            x += len(item)
        elif operator:
            if realtime and settings["entry_hilighting"]:
               stdscr.addstr(y, x, item, settings["color_entry_dim"])
            else:
                stdscr.addstr(y, x, item, settings["color_operator"])
            x += len(item)

        elif comment:
            if realtime and settings["entry_hilighting"]:
               stdscr.addstr(y, x, item, settings["color_entry_comment"])
            else:
                stdscr.addstr(y, x, item, settings["color_comment"])
            x += len(item)
        elif triplequote:
            if realtime and settings["entry_hilighting"]:
               stdscr.addstr(y, x, item, settings["color_entry_quote_triple"])
            else:
                stdscr.addstr(y, x, item, settings["color_quote_triple"])
            x += len(item)
        elif doublequote:
            if realtime and settings["entry_hilighting"]:
                stdscr.addstr(y, x, item, settings["color_entry_quote"])
            else:
                stdscr.addstr(y, x, item, settings["color_quote_double"])
            x += len(item)

        elif singlequote: #new bit that seperates single and double quotes
            if realtime and settings["entry_hilighting"]:
                stdscr.addstr(y, x, item, settings["color_entry_quote"])
            else:
                stdscr.addstr(y, x, item, settings["color_quote_single"])
            x += len(item)

        elif entry_line and settings["entry_hilighting"]: #Was 'realtime', changed to fix bug
            stdscr.addstr(y, x, item, settings["color_entry"])
            x += len(item)
        else:
            stdscr.addstr(y, x, item, settings["color_normal"])
            x += len(item)

        if item != "_!SPA!_": space = False
        if item != "_!IND!_": indent = False

def printHeader():
    """Prints header to curses screen"""
    if saved_since_edit: save_info = ""
    else: save_info = "*"
    if program_message:
        #Print info message
        stdscr.addstr(0,0,(" " * (WIDTH)), settings["color_header"]) #this was commented out, not sure why
        stdscr.addstr(0,0, program_message, settings["color_message"])
    else:
        stdscr.addstr(0,0,(" " * (WIDTH)), settings["color_header"]) #print empty line
        if not savepath:
            stdscr.addstr(0,0,"file/not/saved", settings["color_header"]) # print file/not/saved
        elif len(savepath) > WIDTH - 14:
            temptext = os.path.split(savepath)[1]
            stdscr.addstr(0,0,"%s%s" %(temptext,save_info), settings["color_header"]) # print filename only
        else: stdscr.addstr(0,0,"%s%s" %(savepath,save_info), settings["color_header"]) #print directory and filename

    temp_text = "%i" %line.total
    lines_text = temp_text.rjust(11)
    if settings["inline_commands"] == "protected":
        protect_string = str(settings["protect_string"])
        stdscr.addstr(0,WIDTH-12 - len(protect_string) -1,lines_text, settings["color_header"])
        stdscr.addstr(0,WIDTH - len(protect_string) -1, protect_string, settings["color_message"])
    else:
        stdscr.addstr(0,WIDTH-12,lines_text, settings["color_header"])

    stdscr.hline(1,0,curses.ACS_HLINE,WIDTH, settings["color_bar"])

def printCurrentLine():
    """Prints current line"""
    global print_at_row, currentNum, current_line, c, startRow
    print_at_row = HEIGHT - 2

    collapseNumber = 0
    while (1): # This part handles collapsed lines
        try:
            if not current_line.collapsed: break # leave while loop if line not collapsed
            if c == curses.KEY_DOWN: currentNum += 1
            else: currentNum -= 1
            current_line = line.db[currentNum]
        except:
            if currentNum < 1: currentNum = 1
            elif currentNum > line.total: currentNum = line.total
            break

    try:
        if current_line.number_of_rows < HEIGHT - 4:
            if line.locked:
                stdscr.addstr((print_at_row + 1 - current_line.number_of_rows),0,str(current_line.number), settings["color_line_numbers"]) # Prints current line number
            else:
                stdscr.addstr((print_at_row + 1 - current_line.number_of_rows),0,"     ", settings["color_line_num_reversed"]) # Prints blank line number block
                stdscr.addstr((print_at_row + 1 - current_line.number_of_rows),0,str(current_line.number), settings["color_line_num_reversed"]) # Prints current line number

            if current_line.selected:
                stdscr.addstr((print_at_row + 1 - current_line.number_of_rows),6,(" " * (WIDTH - 6)),settings["color_selection"]) #Prints selected
                stdscr.addstr((print_at_row + 1 - current_line.number_of_rows),WIDTH,"<",settings["color_quote_double"]) #Prints selected

            if current_line.marked and current_line.error and settings["debug"]:
                stdscr.hline((print_at_row + 1 - current_line.number_of_rows),5,curses.ACS_DIAMOND,1,settings["color_warning"])
            elif current_line.error and settings["debug"]:
                stdscr.addstr((print_at_row + 1 - current_line.number_of_rows),5,"!",settings["color_warning"]) # Prints ERROR

            elif current_line.marked and not line.locked:
                stdscr.hline((print_at_row + 1 - current_line.number_of_rows),5,curses.ACS_DIAMOND,1,settings["color_quote_double"])
    except:
        pass

    if settings["live_syntax"] and current_line.number_of_rows < (HEIGHT -4): current_line.addSyntax()

    if len(current_line.row) > HEIGHT - 4:
        start = len(current_line.row)-1 + current_line.y
        end = max(-1,start - (HEIGHT - 4))
    else:
        start = len(current_line.row) - 1
        end = - 1
    for i in range (start, end, -1):
        if settings["entry_hilighting"]:
            if settings["page_guide"] and settings["page_guide"] > 20 and not current_line.selected:
                stdscr.addstr(print_at_row,6," " * settings["page_guide"],settings["color_entry"]) # prints blank line
            else:
                if current_line.selected:
                    stdscr.addstr(print_at_row,6," " * (ROWSIZE),settings["color_selection_reversed"]) # prints blank line
                else:
                    stdscr.addstr(print_at_row,6," " * (ROWSIZE),settings["color_entry"]) # prints blank line

            if settings["page_guide"] and settings["page_guide"] <= 20:
                stdscr.vline(print_at_row, (settings["page_guide"] + 6), curses.ACS_VLINE, (1), settings["color_entry"]) #prints vertical line
        else:
            if settings["page_guide"]:
                stdscr.vline(print_at_row, (settings["page_guide"] + 6), curses.ACS_VLINE, (1), settings["color_bar"]) #prints vertical line

        if current_line.selected:
            stdscr.addstr(print_at_row,6,current_line.row[i],settings["color_selection_reversed"])  #Prints current line
            stdscr.addstr((print_at_row),WIDTH,"<",settings["color_quote_double"]) #Prints selected
        elif settings["syntax_hilighting"] and settings["live_syntax"] and current_line.number_of_rows < (HEIGHT -4):
            templist = current_line.syntax[i]
            printSyntax(templist, 6, print_at_row,False,True)
        elif settings["entry_hilighting"]:
            stdscr.addstr(print_at_row,6,current_line.row[i], settings["color_entry"])  #Added to fix bug
        else:
            stdscr.addstr(print_at_row,6,current_line.row[i],settings["color_normal"])  #Prints current line

        print_at_row -= 1

        if print_at_row < 2: print_at_row = 2
    if len(current_line.row) > HEIGHT - 4 and start > (HEIGHT - 5):
        for r in range(3, HEIGHT-2): ##print vertical line
            stdscr.hline(r, 2, curses.ACS_VLINE,1,settings["color_quote_triple"])
        stdscr.hline(4, 2, curses.ACS_UARROW,1,settings["color_quote_triple"])
        if current_line.y != 0: stdscr.hline(HEIGHT-2,2,curses.ACS_DARROW,1,settings["color_quote_triple"])
        else: stdscr.hline(HEIGHT-2,2,curses.ACS_DIAMOND,1,settings["color_commands"])
        stdscr.addstr(3, 0,"    ", settings["color_entry"]) # Prints blank line number block
        stdscr.addstr(3, 0,str(current_line.number), settings["color_line_num_reversed"]) # Prints current line number
        stdscr.addstr(3, 6, ". . . ", settings["color_line_num_reversed"])
    elif len(current_line.row) > HEIGHT - 4: ##print vertical line
        for r in range(print_at_row+1, HEIGHT-2):
            stdscr.hline(r, 2, curses.ACS_VLINE,1,settings["color_quote_triple"])
        stdscr.hline(HEIGHT-2, 2, curses.ACS_DARROW,1,settings["color_quote_triple"])
        stdscr.addstr(print_at_row + 1, 0,"    ", settings["color_line_num_reversed"]) # Prints blank line number block
        stdscr.addstr(print_at_row + 1, 0,str(current_line.number), settings["color_line_num_reversed"]) # Prints current line number

def printPreviousLines():
    """Prints previous lines"""
    global currentNum, print_at_row
    collapseNumber = 0
    marked = False
    error = False
    master_indent = 0
    for z in range(currentNum - 1, 0, -1):
        if print_at_row < HEADER: break

        if line.db[z].number_of_rows > (HEIGHT - 4): #If terminal too small to display line
            stdscr.addstr(print_at_row,0,str(line.db[z].number), settings["color_line_numbers"]) # Prints line number
            if line.db[z].selected:
                stdscr.addstr((print_at_row ),WIDTH,"<",settings["color_quote_double"]) #Prints selected
            if line.db[z].marked and not line.locked:
                stdscr.hline(print_at_row,5,curses.ACS_DIAMOND,1,settings["color_quote_double"]) #Prints Marked
            if line.db[z].selected:
                stdscr.addstr(print_at_row,6,line.db[z].row[0][0:ROWSIZE-4], settings["color_selection"]) #Prints Selected Text
            if line.db[z].selected:
                stdscr.addstr(print_at_row,6,line.db[z].row[0][0:ROWSIZE-4], settings["color_selection"])
            elif settings["syntax_hilighting"]:
                if not line.db[z].syntax: line.db[z].addSyntax()
                templist = line.db[z].syntax[0]
                printSyntax(templist, 6, print_at_row, False)
            else:
                stdscr.addstr(print_at_row,6,line.db[z].row[0][0:ROWSIZE-4], settings["color_normal"])
            stdscr.hline(print_at_row, WIDTH - 1, curses.ACS_RARROW,1, settings["color_quote_triple"])
            stdscr.hline(print_at_row, WIDTH - 3, curses.ACS_HLINE,2, settings["color_quote_triple"])
            stdscr.addstr(print_at_row, WIDTH - 4, " ", settings["color_normal"])
            print_at_row -= 1
            continue

        if line.db[z].collapsed:
            master_indent = line.db[z].indent_required
            if line.db[z].error: error = True
            if line.db[z].marked: marked = True
            if line.db[z].selected: selected = True
            if collapseNumber == 0:
                stdscr.hline(print_at_row,7 + master_indent,curses.ACS_LLCORNER,1, settings["color_bar"])
                stdscr.hline(print_at_row,8 + master_indent,curses.ACS_HLINE,(ROWSIZE -14 -master_indent), settings["color_bar"])
                print_at_row -= 1
            collapseNumber += 1

            if line.db[z].selected:
                stdscr.addstr((print_at_row + 1),6,(" " * (WIDTH - 6)),settings["color_selection"]) #Prints selected
                stdscr.addstr((print_at_row + 1),WIDTH,"<",settings["color_quote_double"]) #Prints selected

            if marked and error and settings["debug"]:
                stdscr.hline((print_at_row + 1),5,curses.ACS_DIAMOND,1,settings["color_warning"]) #Prints both
            elif marked and not line.locked:
                stdscr.hline((print_at_row + 1),5,curses.ACS_DIAMOND,1,settings["color_quote_double"]) #Prints Marked
            elif error and settings["debug"]:
                stdscr.addstr((print_at_row + 1),5,"!",settings["color_warning"]) # Prints ERROR

            stdscr.addstr(print_at_row + 1,WIDTH - 10, "%i lines" %collapseNumber, settings["color_dim"])
            continue
        collapseNumber = 0
        marked = False
        error = False

        if print_at_row - line.db[z].number_of_rows >= HEADER - 1:
            stdscr.addstr((print_at_row - line.db[z].number_of_rows  + 1),0,str(line.db[z].number), settings["color_line_numbers"]) # Prints line number

            if line.db[z].selected:
                stdscr.addstr((print_at_row - line.db[z].number_of_rows + 1),6,(" " * (WIDTH -6)),settings["color_selection"]) #Prints selected
                stdscr.addstr((print_at_row - line.db[z].number_of_rows + 1),WIDTH,"<",settings["color_quote_double"]) #Prints selected
            if line.db[z].marked and line.db[z].error and settings["debug"]:
                stdscr.hline((print_at_row - line.db[z].number_of_rows  + 1),5,curses.ACS_DIAMOND,1,settings["color_warning"])

            elif line.db[z].error and settings["debug"]:
                stdscr.addstr((print_at_row - line.db[z].number_of_rows  + 1),5,"!",settings["color_warning"]) # Prints ERROR

            elif line.db[z].marked and not line.locked:
                stdscr.hline((print_at_row - line.db[z].number_of_rows  + 1),5,curses.ACS_DIAMOND,1,settings["color_quote_double"])
        else:
            stdscr.addstr(2,0,str(line.db[z].number), settings["color_line_numbers"]) # Prints line number

        for i in range (len(line.db[z].row) - 1, -1, -1):
            if print_at_row < 2:

                stdscr.hline(2,5, curses.ACS_LARROW,1, settings["color_quote_double"])
                stdscr.hline(2,6, curses.ACS_HLINE,2, settings["color_quote_double"])
                stdscr.addstr(2,8, " ",settings["color_normal"])

                break # break out of loop if line is in Header
            if line.db[z].selected:
                stdscr.addstr((print_at_row),6,(" " * (WIDTH - 6)),settings["color_selection"]) #Prints selected
                stdscr.addstr(print_at_row,6,line.db[z].row[i], settings["color_selection"]) #Prints Selected Text
                stdscr.addstr((print_at_row),WIDTH,"<",settings["color_quote_double"]) #Prints selected
            elif settings["syntax_hilighting"]:
                if not line.db[z].syntax: line.db[z].addSyntax()
                templist = line.db[z].syntax[i]
                try:
                    status = line.db[z+1].collapsed
                except:
                    status = False
                printSyntax(templist, 6, print_at_row, status)
            else:
                stdscr.addstr(print_at_row,6,line.db[z].row[i], settings["color_normal"])

            print_at_row -= 1

def printNextLine():
    """Prints line after current line, if applicable"""
    if currentNum == line.total: return

    try:
        if line.db[currentNum+1].selected:
            stdscr.addstr((HEIGHT - 1),6,(" " * (WIDTH - 6)),settings["color_selection"]) #Prints selected
            stdscr.addstr((HEIGHT - 1),WIDTH,"<",settings["color_quote_double"]) #Prints selected
            next_line = line.db[currentNum+1].row[0]
            stdscr.addstr(HEIGHT-1, 6, next_line, settings["color_selection"])  #Prints next line
        elif settings["syntax_hilighting"]:
            if not line.db[currentNum+1].syntax: line.db[currentNum+1].addSyntax()
            templist = line.db[currentNum+1].syntax[0]
            printSyntax(templist, 6, HEIGHT - 1)
        else:
            next_line = line.db[currentNum+1].row[0]
            stdscr.addstr(HEIGHT-1, 6, next_line, settings["color_normal"])  #Prints next line
        if line.db[currentNum+1].length > ROWSIZE and line.db[currentNum+1].number_of_rows > (HEIGHT-4):
            stdscr.addstr(HEIGHT-1, WIDTH - 4, " ", settings["color_normal"])
            stdscr.hline(HEIGHT-1, WIDTH - 3,curses.ACS_HLINE,2, settings["color_quote_triple"])
            stdscr.hline(HEIGHT-1, WIDTH - 1,curses.ACS_RARROW,1, settings["color_quote_triple"])
        elif line.db[currentNum+1].length > ROWSIZE:
            stdscr.addstr(HEIGHT-1, WIDTH - 4, " ", settings["color_normal"])
            stdscr.hline(HEIGHT-1, WIDTH - 3,curses.ACS_HLINE,2, settings["color_quote_double"])
            stdscr.hline(HEIGHT-1, WIDTH - 1,curses.ACS_RARROW,1, settings["color_quote_double"])

        stdscr.addstr(HEIGHT-1, 0, str(line.db[currentNum+1].number), settings["color_line_numbers"])  #Prints next line numbers

        if line.db[currentNum+1].marked and line.db[currentNum+1].error and settings["debug"]:
            stdscr.hline(HEIGHT-1,5,curses.ACS_DIAMOND,1,settings["color_warning"]) #MARKED

        elif line.db[currentNum+1].error and settings["debug"]:
            stdscr.addstr(HEIGHT-1,5,"!",settings["color_warning"]) # Prints ERROR

        elif line.db[currentNum+1].marked and not line.locked:
            stdscr.hline(HEIGHT-1,5,curses.ACS_DIAMOND,1,settings["color_quote_double"]) #MARKED
    except:
        pass

    if currentNum > line.total-2: return ##This is a temp line, for debug purposes

    try:
        if line.db[currentNum+2].selected:
            stdscr.addstr((HEIGHT),6,(" " * (WIDTH - 6)),settings["color_selection"]) #Prints selected
            stdscr.vline(HEIGHT, WIDTH, "<", (1), settings["color_quote_double"]) #prints vertical line
            next_line = line.db[currentNum+2].row[0]
            stdscr.addstr(HEIGHT, 6, next_line, settings["color_selection"])  #Prints next line
        elif settings["syntax_hilighting"]:
            if not line.db[currentNum+2].syntax: line.db[currentNum+2].addSyntax()
            templist = line.db[currentNum+2].syntax[0]
            printSyntax(templist, 6, HEIGHT)
        else:
            next_line = line.db[currentNum+2].row[0]
            stdscr.addstr(HEIGHT, 6, next_line, settings["color_normal"])  #Prints next line
        if line.db[currentNum+2].length > ROWSIZE and line.db[currentNum+2].number_of_rows > (HEIGHT-4):
            stdscr.addstr(HEIGHT, WIDTH - 4, " ", settings["color_normal"])
            stdscr.hline(HEIGHT, WIDTH - 3,curses.ACS_HLINE,2, settings["color_quote_triple"])
            stdscr.hline(HEIGHT, WIDTH - 1,curses.ACS_RARROW,1, settings["color_quote_triple"])
        elif line.db[currentNum+2].length > ROWSIZE:
            stdscr.addstr(HEIGHT, WIDTH - 4, " ", settings["color_normal"])
            stdscr.hline(HEIGHT, WIDTH - 3,curses.ACS_HLINE,2, settings["color_quote_double"])
            stdscr.hline(HEIGHT, WIDTH - 1,curses.ACS_RARROW,1, settings["color_quote_double"])

        stdscr.addstr(HEIGHT, 0, str(line.db[currentNum+2].number), settings["color_line_numbers"])  #Prints next line numbers
        if line.db[currentNum+2].marked and line.db[currentNum+2].error and settings["debug"]:
            stdscr.hline(HEIGHT,5,curses.ACS_DIAMOND,1,settings["color_warning"]) #MARKED and ERROR
        elif line.db[currentNum+2].error and settings["debug"]:
            stdscr.addstr(HEIGHT,5,"!",settings["color_warning"]) # Prints ERROR
        elif line.db[currentNum+2].marked and not line.locked:
            stdscr.hline(HEIGHT,5,curses.ACS_DIAMOND,1,settings["color_quote_double"]) #MARKED
    except:
        pass

def splitScreen():
    """Display splitscreen"""
    if not settings["splitscreen"]: return

    number = settings["splitscreen"]
    maxrow = int(HEIGHT/2 + 1)
    print_row = HEADER
    text = " " * (WIDTH)

    for j in range(2, maxrow):
        stdscr.addstr(j, 0, text, settings["color_normal"]) # Clears screen
        stdscr.addstr(j, 0, "     ", settings["color_line_numbers"]) # draws line number background

    if settings["page_guide"]:
        drawPageGuide(end_pos = maxrow, hline_pos = maxrow) #Draws page guide

    for z in range(number, number + maxrow):

        if z <= 0 or z > line.total: break
        if print_row > maxrow - 1: break

        stdscr.addstr(print_row, 0, "     ", settings["color_line_numbers"])  #Prints block
        stdscr.addstr(print_row, 0, str(line.db[z].number), settings["color_line_numbers"])  #Prints next line numbers

        if line.db[z].marked and line.db[z].error and settings["debug"]:
            stdscr.hline(print_row,5,curses.ACS_DIAMOND,1,settings["color_warning"]) #MARKED & ERROR

        elif line.db[z].error and settings["debug"]:
            stdscr.addstr(print_row,4,"!",settings["color_warning"]) # Prints ERROR

        elif line.db[z].marked and not line.locked:
            stdscr.hline(print_row,5,curses.ACS_DIAMOND,1,settings["color_quote_double"]) #MARKED & ERROR

        for i in range (0, len(line.db[z].row)):
            if i != 0 and line.db[z].number_of_rows > HEIGHT - 4:
                break
            if print_row > maxrow - 1:
                try:
                    stdscr.addstr(print_row - 1, WIDTH - 4, " -->", settings["color_quote_double"])
                except:
                    pass
                break

            next_line = line.db[z].row[i]

            if line.db[z].selected:
                stdscr.addstr(print_row,6,(" " * (WIDTH - 6)),settings["color_selection"]) #Prints selected
                stdscr.addstr(print_row,WIDTH,"<",settings["color_quote_double"]) #Prints selected
                stdscr.addstr(print_row,6,next_line, settings["color_selection"]) #Prints Selected Text
            elif settings["syntax_hilighting"]:
                if not line.db[z].syntax: line.db[z].addSyntax()
                templist = line.db[z].syntax[i]
                printSyntax(templist, 6, print_row)
            else:
                stdscr.addstr(print_row, 6, next_line, settings["color_normal"])  #Prints next line
            if i == 0 and line.db[z].number_of_rows > HEIGHT - 4:
                stdscr.addstr(print_row, WIDTH - 4, " -->", settings["color_quote_triple"])
            print_row += 1

    stdscr.hline(maxrow, 0, curses.ACS_HLINE,WIDTH, settings["color_bar"])

def moveUp():
    """program specific function that moves up one line"""
    global currentNum, program_message, saved_since_edit, continue_down, continue_up

    program_message = ""
    continue_down = 0; continue_left = 0; continue_right = 0

    if settings["syntax_hilighting"]: line.db[currentNum].addSyntax() ##update syntax BEFORE leaving line

    if current_line.text and current_line.number == line.total:
        l = line() #create emtpy line

    if text_entered:
        update_undo()
        update_que("text entry")
        saved_since_edit = False

    if current_line.number_of_rows > 1 and current_line.y == 0 and current_line.x == current_line.end_x and not line.locked:
        currentNum -= 1
        if currentNum < 1: currentNum = 1
        line.db[currentNum].y = 0
        line.db[currentNum].x = line.db[currentNum].end_x
    elif current_line.number_of_rows > 1 and current_line.y > current_line.end_y: #deal with large lines
        prev_y = current_line.y
        if current_line.x >= 6: current_line.y -= 1
        if prev_y == 0 and current_line.x == current_line.end_x: current_line.x = WIDTH - 1
    else: # deal with normal lines
        if settings["cursor_acceleration"]: move_rate = min(settings["cursor_max_vertical_speed"], int(continue_up/10.0)+1)
        else: move_rate = 1
        currentNum -= move_rate
        continue_up += 1

        if currentNum < 1: currentNum = 1

        line.db[currentNum].y = 0
        line.db[currentNum].x = line.db[currentNum].end_x

    if settings["syntax_hilighting"]: line.db[currentNum].addSyntax() ##added to speed up program
    if settings["debug"]: debugVisible()

def moveDown():
    """program specific function that moves down one line"""
    global currentNum, program_message, saved_since_edit, continue_down, continue_up
    program_message = ""
    continue_up = 0; continue_left = 0; continue_right = 0
    if settings["syntax_hilighting"]: line.db[currentNum].addSyntax() ##update syntax BEFORE leaving line

    if current_line.text and current_line.number == line.total:
        l = line() #create emtpy line

    if text_entered:
        update_undo()
        update_que("text entry")
        saved_since_edit = False

    if current_line.number_of_rows > 1 and current_line.y != 0: #deal with large lines
        prev_y = current_line.y
        prev_x = current_line.x
        current_line.y += 1
        if current_line.y == 0 and prev_x == WIDTH - 1: current_line.x = current_line.end_x
        elif current_line.y == 0 and prev_x > current_line.end_x: current_line.x = current_line.end_x
        elif prev_y == current_line.end_y and current_line.x == WIDTH -1 : current_line.x = WIDTH - 1

    else: # deal with normal lines
        if settings["cursor_acceleration"]: move_rate = min(settings["cursor_max_vertical_speed"], int(continue_down/10.0)+1)
        else: move_rate = 1
        currentNum += move_rate
        continue_down += 1

        if currentNum > line.total: currentNum = line.total

        if line.db[currentNum].number_of_rows > (HEIGHT-4) and line.locked:
            line.db[currentNum].y = line.db[currentNum].end_y + (HEIGHT - 5)
        elif current_line.y != 0:
            line.db[currentNum].y = line.db[currentNum].end_y #changed
            line.db[currentNum].x = WIDTH - 1
        else:
            line.db[currentNum].x = line.db[currentNum].end_x
            line.db[currentNum].y = 0

    if settings["syntax_hilighting"]: line.db[currentNum].addSyntax()  ##added to speed up program
    if settings["debug"]: debugVisible()

def moveLeft():
    """program specific function that moves left one space"""
    global continue_up, continue_down, continue_right, continue_left
    continue_up = 0; continue_down = 0; continue_right = 0
    if current_line.text and current_line.number == line.total:
        l = line() #create emtpy line

    try: #if tab, move 4 spaces
        if current_line.x-6 <= current_line.indentation and current_line.text[current_line.x-6-4:current_line.x-6] == "    " and current_line.y == current_line.end_y:
            current_line.x -= 4
            return
    except:
        pass
    if settings["cursor_acceleration"]: move_rate = min(settings["cursor_max_horizontal_speed"], int(continue_left/10.0)+1)
    else: move_rate = 1
    continue_left += 1
    current_line.x -= move_rate

def moveRight():
    """program specific function that moves right one space"""
    global continue_up, continue_down, continue_right, continue_left
    continue_up = 0; continue_down = 0; continue_left = 0
    if current_line.text and current_line.number == line.total:
        l = line() #create emtpy line

    try: #if tab, move 4 spaces
        if current_line.x-6 < current_line.indentation and current_line.text[current_line.x-6:current_line.x-6+4] == "    " and current_line.y == current_line.end_y:
            current_line.x += 4
            return
    except:
        pass

    if settings["cursor_acceleration"]: move_rate = min(settings["cursor_max_horizontal_speed"], int(continue_right/10.0)+1)
    else: move_rate = 1
    continue_right += 1
    current_line.x += move_rate

def addCharacter(char):
    """program specific function that adds character to line"""
    global current_line, text_entered, program_message, saved_since_edit, continue_down, continue_up
    continue_down = 0; continue_up = 0
    #if len(current_line.text) > 4: saved_since_edit = False # Updated so 'new', 'run', 'save', or 'load' won't count as an edit.
    program_message = ""

    if not text_entered: text_entered = True

    old_number_of_rows = current_line.number_of_rows
    old_x = current_line.x
    templist = current_line.listing
    if current_line.y == 0 and current_line.x == current_line.end_x:
        templist.append(char)
    else:
        position = ROWSIZE * (current_line.number_of_rows - 1 - abs(current_line.y)) + current_line.x - 6
        templist.insert(position, char)
    tempstring = ""
    for item in templist:
        tempstring += item
    current_line.text = tempstring
    current_line.x += 1

    if settings["live_syntax"] and current_line.number_of_rows < (HEIGHT -4): current_line.addSyntax() ##added 'live' check to speed up program
    if old_number_of_rows != current_line.number_of_rows:
        if current_line.y !=0: current_line.y -= 1
        if current_line.y == 0:
            current_line.y -= 1
            current_line.x = old_x + 1

def keyBackspace():
    """This function determines what happens when delete/backspace key pressed"""
    global current_line, currentNum, saved_since_edit, text_entered, continue_up, continue_down
    continue_down = 0; continue_up = 0
    saved_since_edit = False
    if not text_entered and len(current_line.text) > 4: text_entered = True

    if not current_line.text and current_line.number == line.total:
        l = line() #create emtpy line

    if not line.db[currentNum].text: #delete line if empty
        delete(currentNum)
        text_entered = True
        return

    if (currentNum - 1) in line.db and line.db[currentNum].text and current_line.x == 6 and current_line.y == current_line.end_y: #end_y added to fix bug

        part1 = line.db[currentNum-1].text
        part2 = line.db[currentNum].text
        combineLines(currentNum, part1, part2)
        text_entered = True
        return

    old_number_of_rows = current_line.number_of_rows
    templist = current_line.listing

    if current_line.y == 0 and current_line.x == current_line.end_x: #delete last character on line
        del templist[-1]
    else:
        position = ROWSIZE * (current_line.number_of_rows - 1 - abs(current_line.y)) + current_line.x - 6
        try:
            if position <= current_line.indentation and current_line.text[position-3:position+1] and current_line.indentation/4.0 == int(current_line.indentation/4.0): #delete tab
                del templist[position-4:position]
                current_line.x -= 3 #move cursor position 3 spaces, final one below
            else:
                del templist[position-1] #delete position
        except:
            del templist[position-1] #delete position

    tempstring = ""
    for item in templist:
        tempstring += item
    current_line.text = tempstring
    current_line.x -= 1
    if settings["syntax_hilighting"]: current_line.addSyntax()
    if old_number_of_rows != current_line.number_of_rows:
        current_line.y += 1
        if current_line.number_of_rows == 1 and current_line.x == 6: current_line.x = current_line.end_x

def collapseThese(num):
    """Helper function to process redundant text checks in collapse function"""
    item = line.db[num]
    if item.text.endswith(":") or endColon(item.text): collapse_line(num)

def collapse(mytext):
    """Function that attempts to collapse lines"""
    global program_message
    program_message = " Collapsed lines "
    selection = False
    funcTotal = 0
    if mytext == "collapse":
        selection,item_count = getSelected()
        if selection:
            mytext = "collapse %s" %selection
    temptext = mytext
    if reset_needed: resetLine()

    try:
        if len(temptext) > 9 and temptext[9].isalpha() and getArgs(temptext) not in ("function","functions","class","classes"): ##Search for function or class
            search_string = temptext[9:]
            findfunction = "def " + search_string + "("
            findclass = "class " + search_string + "("
            for i in range(1, len(line.db)+1):
                item = line.db[i]
                if item.text.strip().startswith(findfunction) or item.text.strip().startswith(findclass):
                    if item.text.strip().startswith("def"): item_found = "function"
                    elif item.text.strip().startswith("class"): item_found = "class"
                    temptext = "collapse %i" %i
                    funcTotal += 1
                    break
            if not funcTotal:
                program_message = " Specified function/class not found! "
                return

        if getArgs(temptext) in ("function","functions","class","classes"):
            #settings["collapse_functions"] = True
            collapse_functions()
        elif "tab" in temptext or "indent" in temptext:
            indentnum = int(getArgs(temptext)[1])
            program_message = " Collapsed lines with indent of %i " %indentnum
            for i in range(1, len(line.db)+1):
                statusMessage("Processing: ", (100/(line.total * 1.0/i)))
                item = line.db[i]
                try:
                    next = line.db[i+1]
                except:
                    return
                if next.indentation >= indentnum*4:
                    collapseThese(i)
        elif "-" in temptext:
            tempList = getArgs(temptext," ","-")
            start = max (1, int(tempList[0]))
            end = min (line.total, int(tempList[1]))
            program_message = " Collapsed lines between %i and %i " %(start, end)
            for i in range(start, end + 1):
                statusMessage("Processing: ", (100/((end-start) * 1.0/i)))
                collapseThese(i)
        elif "," in temptext:
            tempList = getArgs(temptext," ",",")
            program_message = " Collapsed %i lines " %len(tempList)
            for i in range (0, len(tempList)):
                num = int(tempList[i])
                collapseThese(num)
        else:
            argList = getArgs(temptext)
            if 'str' in str(type(argList)):
                num = int(argList)
                collapseThese(num)
            else:
                for i in range (0, len(argList)):
                    num = int(argList[i])
                    collapseThese(num)
            program_message = " Collapsed line number %i " %num
        if selection: program_message = " Selection collapsed "
        elif funcTotal: program_message = " Collapsed %s '%s' " %(item_found, search_string)
    except:
        program_message = " Error, collapse failed! "

def collapse_functions():
    """Collapses all function and class definitions"""
    global program_message
    for i in range(2, len(line.db)+1):
        statusMessage("Processing: ", (100/(line.total * 1.0/i)))
        prev_item = line.db[i-1]
        item = line.db[i]
        if not prev_item.collapsed:
            if prev_item.text[prev_item.indentation:(prev_item.indentation + 4)] == "def ":
                item.collapsed = True
                item.indent_required = prev_item.indentation
            elif prev_item.text[prev_item.indentation:(prev_item.indentation + 6)] == "class ":
                item.collapsed = True
                item.indent_required = prev_item.indentation
        elif prev_item.collapsed:
            if not item.text:
                item.collapsed = True
                item.indent_required = prev_item.indent_required
            elif item.indentation <= prev_item.indent_required:
                item.collapsed = False
            else:
                item.collapsed = True
                item.indent_required = prev_item.indent_required
        program_message = " Functions & classes collapsed "

def collapse_line(number):
    """Attempt to collapse line number"""
    for i in range(number + 1, len(line.db)):
        item = line.db[i]
        if item.indentation > line.db[number].indentation or not item.text:
            if item.collapsed:
                item.indent_required = min(item.indent_required, line.db[number].indentation)
            else:
                item.indent_required = line.db[number].indentation
            item.collapsed = True
        else:
            return

def expand(mytext):
    """Processes 'expand' command"""
    global program_message
    selection = False
    funcTotal = 0
    if mytext == "expand":
        selection,item_count = getSelected()
        if selection:
            mytext = "expand %s" %selection

    if reset_needed: resetLine()
    try:

        if len(mytext) > 7 and mytext[7].isalpha(): ##Search for function or class
            search_string = mytext[7:]
            findfunction = "def " + search_string + "("
            findclass = "class " + search_string + "("
            for i in range(1, len(line.db)+1):
                item = line.db[i]
                if item.text.strip().startswith(findfunction) or item.text.strip().startswith(findclass):
                    if item.text.strip().startswith("def"): item_found = "function"
                    elif item.text.strip().startswith("class"): item_found = "class"
                    mytext = "collapse %i" %i
                    funcTotal += 1
                    break
            if not funcTotal:
                program_message = " Specified function/class not found! "
                return

        if "expand all" in mytext:
            expandAll()
            program_message = " Expanded all lines "
        elif "-" in mytext: #expand range of lines
            tempList = getArgs(mytext," ","-")
            start = max (1, int(tempList[0]))
            end = min (line.total, int(tempList[1]))
            program_message = " Expanded lines %i to %i " %(start,end)
            for i in range(start, end + 1):
                expand_line(i)
        elif "," in mytext: #expand list of lines
            tempList = getArgs(mytext," ",",")
            program_message = " Expanded %i lines " %len(tempList)
            for i in range (0, len(tempList)):
                num = int(tempList[i])
                expand_line(num)
        elif "functions" in mytext: #expand functions
            program_message = " Expanded functions & classes "
            for i in range(1, len(line.db)+1):
                item = line.db[i]
                if item.text[item.indentation:(item.indentation + 4)] == "def ":
                    expand_line(i)
                elif item.text[item.indentation:(item.indentation + 6)] == "class ":
                    expand_line(i)
        else: #expand line number
            argList = getArgs(mytext)
            if 'str' in str(type(argList)):
                num = int(argList)
                expand_line(num)
            else:
                for i in range (0, len(argList)):
                    num = int(argList[i])
                    expand_line(num)
            program_message = " Expanded line number %i " %num
        if selection: program_message = " Selection expanded "
        elif funcTotal: program_message = " Expanded %s '%s' " %(item_found, search_string)
    except:
        program_message = " Error, expand failed! "

def expand_line(number):
    """Attempt to expand line number"""
    if line.db[number].collapsed: return
    for i in range(number + 1, len(line.db) + 1):
        item = line.db[i]
        if item.indentation > line.db[number].indentation or not item.text:
            item.collapsed = False
        elif item.indentation <= line.db[number].indentation:
            return

def expandAll():
    """Expand all lines"""
    global program_message
    program_message = " Expanded all lines "
    for i in range(1, len(line.db)+1):
        line.db[i].collapsed = False

def errorTest(number_of_line):
    """looks for errors in string"""
    # This is version 2. Version 1 worked, but the code was much, much, uglier.
    item = line.db[number_of_line]

    item.equal_continues = False
    item.if_continues = False

    if not item.text:
        return # don't process if line is empty
    if item.text.strip().startswith("exec "):
        item.error = False
        return

    try:
        if item.text.isspace(): return #don't process if line whitespace
        if item.text[item.indentation] == "#": return # don't process if line is commented
        if item.text[item.indentation:].startswith("from"): return # don't process if line begins with from
        if item.text[item.indentation:].startswith("import"): return #don't process if line begins with import
        if item.text[item.indentation:].startswith("return"): return #don't process if line begins with return
        if item.text[item.indentation:].startswith("raise"): return #don't process if line begins with raise
        if item.text[item.indentation:].startswith("except") and item.text.endswith(":"): return #don't process if line begins with except
        if not item.text[item.indentation].isalpha(): return #don't process if line begins with '(', '[', '{'
    except:
        pass

    # initialize flags & other variables
    if_status = False; def_status = False; class_status = False; while_status = False; double_quote = False; single_quote = False; triple_quote = False; equal_status = False; return_status = False; print_status = False; for_status = False; print_num = 0; paren_num = 0; brack_num = 0; curly_status = False; else_status = False; try_status = False; except_status = False; global_status = False; dual_equality = False; prev_comma = False

    if item.number > 1 and line.db[item.number - 1].continue_quoting: triple_quote = True

    ADDENDUM = ("else:", "try:", "except:", "in")
    OP_LIST = ("=","==",">=","<=","+=", "-=","(",")","()","[","]","{","}",":")
    OVER_LIST = ("+-/*%^<>=:")
    oldword = ""; oldchar = ""

    prev_item = False
    previous_ending = ""

    # Check indentation levels
    try:
        if number_of_line > 1:
            prev_item = line.db[number_of_line - 1]
            if prev_item.text[prev_item.indentation] != "#" and not prev_item.text.endswith(",") and not prev_item.text.endswith("\\") and endColon(prev_item.text) and not triple_quote:
                if prev_item.indentation >= item.indentation:
                    item.error = "need additional indentation"
                    return
            elif item.text[item.indentation] != "#" and prev_item.text[-1] not in (":","{",",","#") and prev_item.text[prev_item.indentation:prev_item.indentation+3] not in ("if ", "def", "try", "for") and prev_item.text[prev_item.indentation:prev_item.indentation+4] not in ("elif", "else") and prev_item.text[prev_item.indentation:prev_item.indentation+6] not in ("while ","except", "class ") and not prev_item.text.endswith(",") and not prev_item.text.endswith("\\"):
                if prev_item.indentation < item.indentation and not prev_item.text.strip().startswith("#") and not triple_quote:
                    item.error = "need less indentation"
                    return
            if prev_item.text: previous_ending = prev_item.text[-1]
    except:
        pass

    # check for syntax errors

    if prev_item and prev_item.equal_continues: equal_status = True # This bit allows multi-line equality operations

    if prev_item and prev_item.if_continues: if_status = True
    if prev_item and prev_item.text.endswith(","): prev_comma = True
    elif prev_item and prev_item.text.endswith("\\"): prev_comma = True

    if len(item.text.split()) == 1 and not equal_status:
        tempword = item.text.split()[0]
        if tempword and tempword not in COMMANDS and tempword not in ADDENDUM and not ItemMember(tempword, OP_LIST) and not ItemMember(OVER_LIST, tempword) and '"""' not in tempword and not triple_quote and previous_ending != "\\":
            item.error = "check syntax for '%s'" %item.text[0:int(WIDTH /2) -2]

    if ", " in item.text and " = " in item.text: #attempt to stop false error: a, b = c, d
        dual_equality = True

    for word in item.text.split():
        if '"""' in word and "'\"\"\"'" not in word:
            if not triple_quote and word.count('"""') != 2:
                triple_quote = True
                continue
            else:
                triple_quote = False
                if word[-1] == ":": #Added this section to fix minor bug
                    if brack_num < 1: if_status = False
                    def_status = False
                    class_status = False
                    while_status = False
                    for_status = False
                    else_status = False
                    try_status = False
                    except_status = False
                continue
        elif not single_quote and not double_quote and not triple_quote:
            if word == "#" or word[0] == "#": break
            if word == "if" or word == "elif": if_status = True
            elif word == "def": def_status = True
            elif word == "class": class_status = True
            elif word == "while": while_status = True
            elif word == "print": print_status = True
            elif word == "return": return_status = True
            elif word == "for": for_status = True
            elif word == "else" or word == "else:": else_status = True
            elif word == "try" or word == "try:": try_status = True
            elif word == "except" or word == "except:": except_status = True
            elif word == "global": global_status = True

            elif not if_status and not def_status and not class_status and not while_status and not for_status and not print_status and not equal_status and oldword and oldword not in COMMANDS and oldword not in ADDENDUM and oldword not in OP_LIST and word not in OP_LIST and "(" not in word and word != ":" and ":" not in oldword and ";" not in oldword and paren_num == 0 and not global_status and "=" not in word and not item.equal_continues and word[word.count(" ")] != "{" and item.text[-1] != "," and not dual_equality and not prev_comma:
                if ";" in oldword or oldchar == ";":
                    item.error = "check syntax for '%s'" %word[0:int(WIDTH /2) -2]
                else:
                    item.error = "check syntax for '%s'" %oldword[0:int(WIDTH /2) -2]
        charSoFar = ""
        for char in word:
            charSoFar += char
            if not single_quote and not double_quote and not triple_quote:

                if if_status and char == "=" and "==" not in word and "!=" not in word and ">=" not in word and "<=" not in word:
                    item.error = "missing comparison operator, '=='"
                elif while_status and char == "=" and "==" not in word and "!=" not in word and ">=" not in word and "<=" not in word:
                    item.error = "missing comparison operator, '=='"
                elif not if_status and not while_status and char == "=" and "==" in word and '"=="' not in word and "'=='" not in word and word.count("=") != 3:
                    if prev_item and prev_item.text and prev_item.text[-1] == "\\":
                        pass #may need to set if_status here (or maybe not... seems to be working)
                    else:
                        item.error = "improper use of comparison operator, '=='"

                if char == "#": return # new bit to stop false syntax errors when there isn't a space before comment character
                if char == "'" and oldchar != "\\": single_quote = True
                elif char == '"' and oldchar != "\\": double_quote = True
                elif char == "(": paren_num += 1
                elif char == ")": paren_num -= 1

                elif char == "[": brack_num += 1
                elif char == "]": brack_num -= 1
                elif char == "{": curly_status = True
                #elif char == "}": equal_status = False  ## ????? Looks like an error!

                elif not if_status and char == "=": equal_status = True
                elif char == ":":
                    if brack_num < 1: if_status = False
                    def_status = False
                    class_status = False
                    while_status = False
                    for_status = False
                    else_status = False
                    try_status = False
                    except_status = False
                    comp_continues = False
                elif char == ";":
                    print_status = False
                    equal_status = False
                    global_status = False
            else: ##(if quote status)
                if single_quote and char == "'" and oldchar != "\\": single_quote = False
                elif single_quote and char == "'" and charSoFar.endswith("\\\\'"): single_quote = False
                elif double_quote and char == '"' and oldchar != "\\": double_quote = False
                elif double_quote and char == '"' and charSoFar.endswith('\\\\"'): double_quote = False
                #new bits (testing)

            oldchar = char
        oldword = word

    if double_quote and not item.text.endswith("\\") and previous_ending != "\\":
        item.error = "missing double quote"
    elif single_quote and not item.text.endswith("\\") and previous_ending != "\\":
        item.error = "missing single quote"
    elif if_status or def_status or class_status or while_status or for_status or else_status or try_status or except_status:
        if not item.text.endswith("\\"):
            item.error = "missing end colon, ':'"
        else:
            item.if_continues = True

    elif equal_status and brack_num >= 0 and item.text[-1] in (",", "\\"): # equal continues to next line
        item.equal_continues = True
    elif equal_status and paren_num >= 0 and item.text[-1] in (",", "\\"): # equal continues to next line
        item.equal_continues = True

    elif brack_num < 0:
        if prev_item and prev_item.text and prev_item.text[-1] in (",", "\\"):
            pass #No error if prev_item equals ","
        else:
            item.error = "missing lead bracket, '['"
    elif brack_num > 0:
        if item.text and item.text[-1] in (",", "\\", "["):
            pass #No error if item ends wtih ","
        else:
            item.error = "missing end bracket, ']'"
    elif paren_num < 0:
        if prev_item and prev_item.text and prev_item.text[-1] in (",", "\\"):
            pass #No error if prev_item equals ","
        else:
            item.error = "missing lead parenthesis, '('"
    elif paren_num > 0:
        if item.text and item.text[-1] in (",", "\\", "("):
            pass #No error if item ends wtih ","
        else:
            item.error = "missing end parenthesis, ')'"

def tabKey():
    """program specific function that handles 'tab'"""
    char = " "
    global current_line, continue_down, continue_up
    continue_down = 0; continue_up = 0
    for i in range(0,4):
        old_number_of_rows = current_line.number_of_rows
        old_x = current_line.x
        templist = current_line.listing
        if current_line.y == 0 and current_line.x == current_line.end_x:
            templist.append(char)
        else:
            position = ROWSIZE * (current_line.number_of_rows - 1 - abs(current_line.y)) + current_line.x - 6
            templist.insert(position, char)
        tempstring = ""
        for item in templist:
            tempstring += item
        current_line.text = tempstring
        current_line.x += 1

        if old_number_of_rows != current_line.number_of_rows:
            if current_line.y !=0: current_line.y -= 1
            if current_line.y == 0:
                current_line.y -= 1
                current_line.x = old_x + 1

def returnKey():
    """Function that handles return/enter key"""
    global currentNum, text_entered, program_message, saved_since_edit

    program_message = ""
    saved_since_edit = False

    #new section to deal with undo
    if text_entered:
        update_undo()
        update_que("text entry")

    if settings["syntax_hilighting"]: syntaxVisible()

    if current_line.number ==  line.total and current_line.x != 6:
        l = line("")
        currentNum += 1

    elif current_line.text and current_line.number_of_rows == 1 and current_line.x > 6 and current_line.x < current_line.end_x: #split line in two
        part1 = current_line.text[:current_line.x-6]
        part2 = current_line.text[current_line.x-6:]
        splitLine(currentNum, part1, part2)


    elif current_line.text and current_line.number_of_rows > 1 and current_line.y > -(current_line.number_of_rows -1) or current_line.x > 6: #split line in two
        prevPart = ""; afterPart = ""

        currentLine1 = current_line.row[current_line.y+current_line.number_of_rows - 1][:current_line.x-6]
        currentLine2 = current_line.row[current_line.y+current_line.number_of_rows - 1][current_line.x-6:]

        for i in range(0, -(current_line.number_of_rows), -1):
            r = i + current_line.number_of_rows - 1

            if current_line.y > i:
                prevPart = current_line.row[r] + prevPart
            elif current_line.y < i:
                afterPart = current_line.row[r] + afterPart

        part1 = prevPart + currentLine1
        part2 = currentLine2 + afterPart

        splitLine(currentNum, part1, part2)

    elif not current_line.text:
        insert(current_line.number) #new bit, inserts line
        currentNum += 1
    elif current_line.x == current_line.end_x:
        currentNum += 1
        line.db[currentNum].x = 6
        line.db[currentNum].y = line.db[currentNum].end_y
    elif current_line.x == 6:
        insert(current_line.number) #new bit, inserts line
        currentNum += 1
    else:
        pass
    debugVisible()

def find(mytext):
    """Search feature
            'find keyword' moves to first instance of 'keyword'
            'find' moves to next match"""
    global currentNum, last_search, program_message, prev_line
    prev_line = currentNum #set previous line to current line
    collapsed_lines = False
    count = 0
    findthis = "$!*_foobar"
    show_message = False

    if reset_needed: resetLine()

    if len(mytext) > 5 and last_search != findthis:
        findthis = mytext[5:]
        last_search = findthis
        for i in range(1, len(line.db)+1):
            item = line.db[i]
            if findthis in item.text or findthis == item.text: count += item.text.count(findthis)
        show_message = True
    else: findthis = last_search

    if currentNum != len(line.db):
        for i in range(currentNum+1, len(line.db)+1):
            item = line.db[i]
            if item.collapsed:  ##skip lines that are collapsed (don't search in collapsed lines)
                collapsed_lines = True
                continue
            if findthis in item.text or findthis == item.text:
                currentNum =  i
                line.db[currentNum].x = line.db[currentNum].end_x ##update cursor position
                if show_message: program_message = " %i matches found " %count
                syntaxVisible()
                return

    for i in range(1, len(line.db)+1):
        item = line.db[i]
        if item.collapsed:  ##skip lines that are collapsed (don't search in collapsed lines)
            collapsed_lines = True
            continue
        if findthis in item.text or findthis == item.text:
            currentNum =  i
            line.db[currentNum].x = line.db[currentNum].end_x ##update cursor position
            if show_message: program_message = " %i matches found " %count
            syntaxVisible()
            return

    if collapsed_lines: program_message = " Item not found; collapsed lines not searched! "
    else: program_message = " Item not found! "

def selectup(mytext):
    """Function that selects lines upward till blank line reached"""
    global program_message
    selectTotal = 0
    if reset_needed: resetLine()
    for i in range(1, len(line.db)+1): ##Deselect all
        line.db[i].selected = False
    if currentNum == 1:
        program_message = " Error, no lines to select! "
        return
    for i in range(currentNum-1, 0, -1):
        if not line.db[i].text.strip(): break
        selectTotal += 1
    for i in range(currentNum-1, 0, -1):
        if not line.db[i].text.strip(): break
        line.db[i].selected = True
    program_message = " Selected %i lines " %selectTotal

def selectdown(mytext):
    """Function that selects lines downward till blank line reached"""
    global program_message
    selectTotal = 0
    if reset_needed: resetLine()
    for i in range(1, len(line.db)+1): ##Deselect all
        line.db[i].selected = False
    if currentNum == line.total:
        program_message = " Error, no lines to select! "
        return
    for i in range(currentNum + 1, line.total + 1):
        if not line.db[i].text.strip(): break
        selectTotal += 1
    for i in range(currentNum + 1, line.total + 1):
        if not line.db[i].text.strip(): break
        line.db[i].selected = True
    program_message = " Selected %i lines " %selectTotal

def mark(mytext):
    """Function that flags lines as 'marked'.

    Can mark line numbers or lines containing text string

        ex: mark myFunction()
            mark 1-10
            mark 16,33"""

    global program_message, currentNum
    isNumber = False
    markTotal = 0
    lineTotal = 0

    if reset_needed: resetLine()

    if len(mytext) <= 5: # if no arguments, mark current line and return
        line.db[currentNum].marked = True
        program_message = " Marked line number %i " %currentNum
        return

    temptext = mytext[5:]

    try:
        if temptext.replace(" ","").replace("-","").replace(",","").isdigit(): isNumber = True
    except:
        isNumber = False

    try:
        if isNumber:
            if "," in mytext:
                argList = getArgs(mytext," ",",")
                for i in range(len(argList)-1, -1, -1):
                    num = int(argList[i])
                    line.db[num].marked = True
                    if settings["syntax_hilighting"]: line.db[num].addSyntax()
                    lineTotal += 1
                    if len(argList) > 200 and line.total > 500 and num/10.0 == int(num/10.0): statusMessage("Processing: ", (100/((len(argList)+1) * 1.0/(num+1))))
            elif "-" in mytext:
                argList = getArgs(mytext," ","-")
                start = max(1, int(argList[0]))
                end = min(len(line.db), int(argList[1]))
                for i in range(end, start - 1, - 1):
                    line.db[i].marked = True
                    if settings["syntax_hilighting"]: line.db[i].addSyntax()
                    lineTotal += 1

                    if (end - start) > 200 and line.total > 500 and i/10.0 == int(i/10.0):
                        statusMessage("Processing: ", (100/((end - start) * 1.0/lineTotal)))

            else:
                argList = getArgs(mytext)
                if 'str' in str(type(argList)):
                    num = int(argList)
                else:
                    num = int(argList[0])
                line.db[num].marked = True
                if settings["syntax_hilighting"]: line.db[num].addSyntax()
                program_message = " Marked line number %i " %num
                lineTotal += 1

        else: ##if not number, search for text
            findthis = temptext
            for i in range(1, len(line.db)+1):
                item = line.db[i]
                if line.total > 500 and i/10.0 == int(i/10.0): statusMessage("Processing: ", (100/((len(line.db)+1) * 1.0/(i+1))))
                if findthis in item.text or findthis == item.text:
                    item.marked = findthis
                    markTotal += item.text.count(findthis)
                    lineTotal += 1
                    if settings["syntax_hilighting"]: item.addSyntax()

        if markTotal > 1: program_message = " Marked %i lines (%i items) " %(lineTotal, markTotal)
        elif lineTotal > 1 and not program_message: program_message = " Marked %i lines " %lineTotal
        elif lineTotal == 1 and not program_message: program_message = " Marked 1 line "
        elif not program_message: program_message = " No items found! "
    except:
        program_message = " Error, mark failed! "

def select(mytext):
    """Function that flags lines as 'selected'.

    Can select function name, line numbers, or marked items

        ex: select myFunction()
            select 1-10
            select 16,33"""

    global program_message, currentNum
    isNumber = False
    selectTotal = 0
    lineTotal = 0

    if reset_needed: resetLine()

    for i in range(1, len(line.db)+1): ##Deselect all
        line.db[i].selected = False

    if len(mytext) <= 7: # if no arguments, select current line and return
        line.db[currentNum].selected = True
        program_message = " Selected line number %i " %currentNum
        return

    if mytext == "select all": mytext = "select 1-%i" %(line.total) #handle 'select all'
    temptext = mytext[7:]

    try:
        if temptext.replace(" ","").replace("-","").replace(",","").isdigit(): isNumber = True
    except:
        isNumber = False

    try:
        if isNumber:
            if "," in mytext:
                argList = getArgs(mytext," ",",")
                for i in range(len(argList)-1, -1, -1):
                    num = int(argList[i])
                    line.db[num].selected = True
                    lineTotal += 1
            elif "-" in mytext:
                argList = getArgs(mytext," ","-")
                start = max(1, int(argList[0]))
                end = min(len(line.db), int(argList[1]))
                for i in range(end, start - 1, - 1):
                    line.db[i].selected = True
                    lineTotal += 1
            else:
                argList = getArgs(mytext)
                if 'str' in str(type(argList)):
                    num = int(argList)
                else:
                    num = int(argList[0])
                line.db[num].selected = True
                program_message = " Selected line number %i " %num
                lineTotal += 1

        else:
            if mytext == "select marked":
                for i in range(1, len(line.db) + 1):
                    if line.db[i].marked:
                        line.db[i].selected = True
                        lineTotal += 1
                if lineTotal < 1: program_message = " Nothing selected, no lines marked! "

            else: ##Search for function or class
                findfunction = "def " + temptext + "("
                findclass = "class " + temptext + "("
                for i in range(1, len(line.db)+1):
                    item = line.db[i]
                    if item.text.strip().startswith(findfunction) or item.text.strip().startswith(findclass):
                        if item.text.strip().startswith("def"): item_found = "function"
                        elif item.text.strip().startswith("class"): item_found = "class"
                        item.selected = True
                        lineTotal = 1
                        indent_needed = item.indentation
                        start_num = i + 1
                        break
                if not lineTotal:
                    program_message = " Specified function/class not found! "
                    return

                for i in range (start_num, line.total):
                    if line.db[i].text and line.db[i].indentation <= indent_needed: break
                    line.db[i].selected = True
                    lineTotal += 1
                program_message = " Selected %s '%s' (%i lines) " %(item_found, temptext,  lineTotal)

        if settings["syntax_hilighting"]: syntaxVisible()
        if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()

        if lineTotal > 1 and not program_message: program_message = " Selected %i lines " %lineTotal
        elif lineTotal == 1 and not program_message: program_message = " Selected 1 line "
        elif not program_message: program_message = " No items found! "
    except:
        program_message = " Error, select failed! "

def unmark(mytext):
    """Function that flags lines as 'unmarked'."""
    global program_message
    isNumber = False
    markTotal = 0

    if reset_needed: resetLine()

    if len(mytext) <= 7: # if no arguments, unmark current line and return
        line.db[currentNum].marked = False
        if settings["syntax_hilighting"]: line.db[currentNum].addSyntax()
        program_message = " Unmarked line number %i " %currentNum
        return

    temptext = mytext[7:]

    try:
        if temptext.replace(" ","").replace("-","").replace(",","").isdigit(): isNumber = True
    except:
        isNumber = False

    try:
        if isNumber:
            if "," in mytext:
                argList = getArgs(mytext," ",",")
                for i in range(len(argList)-1, -1, -1):
                    num = int(argList[i])
                    line.db[num].marked = False
                    if settings["syntax_hilighting"]: line.db[num].addSyntax()
                    markTotal += 1
                    if len(argList) > 200 and line.total > 500 and i/10.0 == int(i/10.0): statusMessage("Processing: ", (100/((len(argList)+1) * 1.0/(i+1))))
            elif "-" in mytext:
                argList = getArgs(mytext," ","-")
                start = max(1, int(argList[0]))
                end = min(len(line.db), int(argList[1]))
                for i in range(end, start - 1, - 1):
                    was_marked = False
                    if line.db[i].marked: was_marked = True
                    line.db[i].marked = False
                    if settings["syntax_hilighting"] and was_marked: line.db[i].addSyntax()
                    markTotal += 1
                    statusMessage("Processing: ", (100/((end - start) * 1.0/markTotal)))

            else:
                argList = getArgs(mytext)
                if 'str' in str(type(argList)):
                    num = int(argList)
                else:
                    num = int(argList[0])
                line.db[num].marked = False
                if settings["syntax_hilighting"]: line.db[num].addSyntax()
                program_message = " Unmarked line number %i " %num
                markTotal += 1

        else: #if not number, search for text
            findthis = temptext
            for i in range(1, len(line.db)+1):
                item = line.db[i]
                if line.total > 500 and i/10.0 == int(i/10.0): statusMessage("Processing: ", (100/((len(line.db)+1) * 1.0/(i+1))))
                if findthis in item.text or findthis == item.text:
                    item.marked = False
                    if settings["syntax_hilighting"]: line.db[i].addSyntax()
                    markTotal += 1
        if markTotal > 1: program_message = " Unmarked %i lines " %markTotal
        elif markTotal == 1 and not program_message: program_message = " Unmarked 1 line "
        elif not program_message: program_message = " No items found! "
    except:
        program_message = " Error, mark failed! "

def deselect(mytext):
    """Function that flags lines as 'deselected'."""
    global program_message
    isNumber = False
    selectTotal = 0
    lineTotal = 0

    if reset_needed: resetLine()

    if len(mytext) <= 9: # if no arguments, deselect all
        program_message = " All lines deselected "
        deselect_all()
        return

    temptext = mytext[9:]

    try:
        if temptext.replace(" ","").replace("-","").replace(",","").isdigit(): isNumber = True
    except:
        isNumber = False

    try:
        if isNumber:
            if "," in mytext:
                argList = getArgs(mytext," ",",")
                for i in range(len(argList)-1, -1, -1):
                    num = int(argList[i])
                    line.db[num].selected = False
                    selectTotal += 1
            elif "-" in mytext:
                argList = getArgs(mytext," ","-")
                start = max(1, int(argList[0]))
                end = min(len(line.db), int(argList[1]))
                for i in range(end, start - 1, - 1):
                    line.db[i].selected = False
                    selectTotal += 1
            else:
                argList = getArgs(mytext)
                if 'str' in str(type(argList)):
                    num = int(argList)
                else:
                    num = int(argList[0])
                line.db[num].selected = False
                program_message = " Deselected line number %i " %num
                selectTotal += 1

        else:
            if mytext in ("deselect marked", "unselect marked"):
                for i in range(1, len(line.db) + 1):
                    if line.db[i].marked:
                        line.db[i].selected = False
                        lineTotal += 1
                if lineTotal < 1: program_message = " Nothing selected, no lines marked! "
                else: program_message = " Deselected %i lines " %lineTotal

            else: ##Search for function or class
                findfunction = "def " + temptext + "("
                findclass = "class " + temptext + "("
                for i in range(1, len(line.db)+1):
                    item = line.db[i]
                    if item.text.strip().startswith(findfunction) or item.text.strip().startswith(findclass):
                        if item.text.strip().startswith("def"): item_found = "function"
                        elif item.text.strip().startswith("class"): item_found = "class"
                        item.selected = False
                        lineTotal = 1
                        indent_needed = item.indentation
                        start_num = i + 1
                        break
                if not lineTotal:
                    program_message = " Specified function/class not found! "
                    return

                for i in range (start_num, line.total):
                    if line.db[i].text and line.db[i].indentation <= indent_needed: break
                    line.db[i].selected = False
                    lineTotal += 1
                program_message = " Delected %s '%s' (%i lines) " %(item_found, temptext,  lineTotal)

        if settings["syntax_hilighting"]: syntaxVisible()
        if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()

        if selectTotal > 1: program_message = " Deselected %i lines " %selectTotal
        elif selectTotal == 1 and not program_message: program_message = " Deselected 1 line "
        elif not program_message: program_message = " No items found! "
    except:
        program_message = " Error, select failed! "

def unmark_all():
    """Unmark all lines"""
    global program_message
    program_message = " All lines unmarked "
    for i in range(1, len(line.db)+1):
        was_marked = False
        if line.db[i].marked: was_marked = True
        line.db[i].marked = False
        if settings["syntax_hilighting"] and was_marked: line.db[i].addSyntax()
        if line.total > 500 and i/20.0 == int(i/20.0): statusMessage("Processing: ", (100/((len(line.db)+1) * 1.0/(i+1))))
    if reset_needed: resetLine()

def deselect_all():
    """Deselect all lines"""
    global program_message
    program_message = " All lines deselected "
    for i in range(1, len(line.db)+1):
        line.db[i].selected = False
    syntaxVisible()
    if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()

def ItemMember(mylist, mystring):
    """Checks items in list to see if they are in string"""
    for item in mylist:
        if item in mystring: return True
    return False

def getConfirmation(text = " Are you sure? (y/n) ", anykey = False):
    """Confirm selection in new (centered) window. Returns 'True' if 'y' pressed."""
    if not anykey and settings["skip_confirmation"] and text != " File exists, overwrite? (y/n) ":
        return True
    side = "   "
    if len(text) < 15:
        diff = 15 - len(text)
        spacer = " " * int(diff/2)
        text = spacer + text + spacer
    line = (len(text) + (len(side) * 2)) * " "
    stdscr.hline(int(HEIGHT/2) - 1, int(WIDTH/2) - int(len(text)/2) - len(side), curses.ACS_HLINE, (len(text) +6),settings["color_message"])
    #print corners
    stdscr.hline(int(HEIGHT/2) - 1, int(WIDTH/2) - int(len(text)/2) - len(side), curses.ACS_ULCORNER, 1,settings["color_message"])
    stdscr.hline(int(HEIGHT/2) - 1, int(WIDTH/2) - int(len(text)/2) + len(text) + 2, curses.ACS_URCORNER, 1,settings["color_message"])

    stdscr.addstr(int(HEIGHT/2) +1, int(WIDTH/2) - int(len(text)/2) - len(side), line, settings["color_message"]) # Prints blank line
    stdscr.addstr(int(HEIGHT/2), int(WIDTH/2) - int(len(text)/2) - len(side), side, settings["color_message"]) # Prints left side
    stdscr.vline(int(HEIGHT/2), int(WIDTH/2) - int(len(text)/2) - len(side), curses.ACS_VLINE, (3),settings["color_message"])#prints left side

    stdscr.addstr(int(HEIGHT/2), int(WIDTH/2) - int(len(text)/2), text, settings["color_message"]) # Prints text message

    stdscr.addstr(int(HEIGHT/2), int(WIDTH/2) - int(len(text)/2) + len(text), side, settings["color_message"]) # Prints right side
    stdscr.vline(int(HEIGHT/2), int(WIDTH/2) - int(len(text)/2) + len(text) + 2, curses.ACS_VLINE, (3),settings["color_message"])#prints right side

    if anykey: stdscr.addstr(int(HEIGHT/2)+1, int(WIDTH/2) - int(len("(press any key)")/2), "(press any key)", settings["color_message"])
    stdscr.hline(int(HEIGHT/2) +2, int(WIDTH/2) - int(len(text)/2) - len(side), curses.ACS_HLINE, (len(text) +6),settings["color_message"])
    #print bottom corners
    stdscr.hline(int(HEIGHT/2) + 2, int(WIDTH/2) - int(len(text)/2) - len(side), curses.ACS_LLCORNER, 1,settings["color_message"])
    stdscr.hline(int(HEIGHT/2) + 2, int(WIDTH/2) - int(len(text)/2) + len(text) + 2, curses.ACS_LRCORNER, 1,settings["color_message"])

     # Prints text message
    try:
        stdscr.addstr(current_line.y + HEIGHT-2, current_line.x, "", settings["color_normal"]) # Moves cursor to previous position
    except:
        pass

    stdscr.refresh()
    c = ""
    while (1):
        c = stdscr.getch()
        if anykey and c: return True
        if c == ord('y') or c == ord('Y'):
            pos = text.find("y")
            stdscr.addstr(int(HEIGHT/2), (int(WIDTH/2) - int(len(text)/2) + pos), 'y', settings["color_quote_double"]) # Prints text message
            stdscr.refresh()
            return True
        if c == ord('n') or c == ord('N'): return False

def promptUser(title = "ENTER COMMAND:", default_answer = "", footer = "(press 'enter' to proceed, UP arrow to cancel)", adjust_pos = False):
    """Displays window and prompts user to enter command

    Used for 'Entry', 'Find', and 'Save' windows"""
    c = ""
    if adjust_pos and "." in default_answer and default_answer.rfind(".") == len(default_answer) - 4:
        position = len(default_answer) - 4
    elif adjust_pos and "." in default_answer and default_answer.rfind(".") == len(default_answer) - 3:
        position = len(default_answer) - 3
    else:
        position = len(default_answer)
    text = default_answer
    side = "   "
    line = int(WIDTH - 16) * " "
    if WIDTH < 70 and footer == "(press 'enter' to proceed, UP arrow to cancel)":
        footer = "(press UP arrow to cancel)"
    footer = footer.center(int(WIDTH-16)-6)
    emptyline = (int(WIDTH - 16) - 6) * " "
    if len(text) > len(emptyline) * 2: text = text[0:(len(emptyline) * 2)]

    while c != 10:
        for i in range (0, 6):
            stdscr.addstr(int(HEIGHT/2) - 2 + i, 8, line, settings["color_message"])
        stdscr.addstr(int(HEIGHT/2) - 1, 11, title, settings["color_message"])
        stdscr.addstr(int(HEIGHT/2) + 2, 11, footer, settings["color_message"])
        stdscr.addstr(int(HEIGHT/2), 11, emptyline, settings["color_normal"])
        stdscr.addstr(int(HEIGHT/2) + 1, 11, emptyline, settings["color_normal"])

        ##print border
        stdscr.hline(int(HEIGHT/2) - 2, 9, curses.ACS_HLINE, (len(emptyline) +4),settings["color_message"])
        stdscr.hline(int(HEIGHT/2) + 3, 9, curses.ACS_HLINE, (len(emptyline) +4),settings["color_message"])
        stdscr.vline(int(HEIGHT/2) - 2, 8, curses.ACS_VLINE, (6),settings["color_message"])
        stdscr.vline(int(HEIGHT/2) - 2, (len(emptyline)+13), curses.ACS_VLINE, (6),settings["color_message"])
        stdscr.hline(int(HEIGHT/2) - 2, 8, curses.ACS_ULCORNER, 1,settings["color_message"])
        stdscr.hline(int(HEIGHT/2) + 3, 8, curses.ACS_LLCORNER, 1,settings["color_message"])
        stdscr.hline(int(HEIGHT/2) - 2, (len(emptyline)+13), curses.ACS_URCORNER, 1,settings["color_message"])
        stdscr.hline(int(HEIGHT/2) + 3, (len(emptyline)+13), curses.ACS_LRCORNER, 1,settings["color_message"])

        if len(text) > len(emptyline):
            stdscr.addstr(int(HEIGHT/2), 11, text[0:len(emptyline)], settings["color_normal"])
            stdscr.addstr(int(HEIGHT/2) + 1, 11, text[len(emptyline):], settings["color_normal"])
        else:
            stdscr.addstr(int(HEIGHT/2), 11, text, settings["color_normal"])

            if len(text) == len(emptyline) and position == len(emptyline):
                stdscr.addstr(int(HEIGHT/2) + 1, 11, "", settings["color_normal"]) #Moves cursor to second line

        #Move cursor
        if position < len(emptyline):
            stdscr.addstr(int(HEIGHT/2), position + 11, "", settings["color_normal"])
        else:
            stdscr.addstr(int(HEIGHT/2)+1, position + 11 - len(emptyline), "", settings["color_normal"])

        stdscr.refresh()
        c = stdscr.getch()

        part1 = text[0:position]
        part2 = text[position:]

        if c in (curses.KEY_UP, settings["key_find"], settings["key_entry_window"], settings["key_save_as"]): return False
        if c == curses.KEY_LEFT: position -= 1
        if c == curses.KEY_RIGHT: position += 1
        position = max(0, min(position,len(text)))

        if c == curses.KEY_BACKSPACE or c == 127:
            try:
                text = part1[0:-1] + part2
            except:
                pass
            position -= 1

        elif c in CHAR_DICT:
            text = (part1 + CHAR_DICT[c] + part2)
            position += 1

    stdscr.addstr(int(HEIGHT/2), 11, emptyline, settings["color_normal"]) #attempt to hide encrypt password during load/save
    stdscr.addstr(int(HEIGHT/2) + 1, 11, emptyline, settings["color_normal"])
    stdscr.refresh()

    return text

def resetLine():
    """Resets/clears line after command execution"""
    global reset_needed, text_entered
    current_line.text = ""
    if settings["debug"]: current_line.error = False
    current_line.addSyntax()
    current_line.x = 6
    reset_needed = False
    text_entered = ""

def delete(pos, syntax_needed = True):
    """Delete Line"""
    global currentNum, program_message

    if pos < 1: pos = 1
    if pos >= line.total:
        program_message = " Last line can not be deleted! "
        return # Can't delete last item

    temp = line.db[line.total]

    for i in range (pos, line.total - 1):
        next = i + 1
        markStatus = line.db[next].marked #attempt to fix bug where line deletion removes 'marked' status
        line.db[i] = line.db[next]
        line.db[i].number = i
        line.db[i].marked = markStatus
    del line.db[len(line.db)]
    line.total -= 1
    if pos <= currentNum: currentNum -= 1 #slight change
    if currentNum < 1: currentNum = 1

    line.db[line.total] = temp
    line.db[line.total].number = line.total

    line.db[currentNum].x = line.db[currentNum].end_x #new bit to fix bug, cursor should be at line end, not beginning

    if settings["syntax_hilighting"] and syntax_needed: syntaxVisible()
    if settings["splitscreen"] and syntax_needed: syntaxSplitscreen()
    if settings["splitscreen"] and settings["splitscreen"]>1: settings["splitscreen"] -= 1 #stop bottom half of screen from 'eating' top half after line deletion

def deleteLines(mytext):
    """Function that deletes lines"""
    global program_message, currentNum, saved_since_edit
    program_message = ""
    temptext = mytext
    if reset_needed: resetLine()
    update_que("Delete operation")
    update_undo()
    count = 0
    statCount = 0 ##For use with processing/status message
    delete_selection = False

    if temptext == "delete":
        selection,item_count = getSelected()
        if selection:
            if getConfirmation("Delete selection - %s lines? (y/n)" %item_count):
                temptext = "delete %s" %selection
                delete_selection = True
            else:
                program_message = " Delete aborted! "
                return

    try:
        if "," in temptext:
            argList = getArgs(temptext," ",",")
            line_num_list = []
            for t in argList:   #count args between 1 and length of line database
                if int(t) >= 1 and int(t) <= line.total:
                    count+= 1
                    line_num_list.append(int(t))
            if count < 0: count = 0
            if not delete_selection and not getConfirmation("Delete %i lines? (y/n)" %count): #Print confirmation message
                program_message = " Delete aborted! "
                return

            if count > 100 and line.total > 1000 and consecutiveNumbers(line_num_list): ##Use new delete (speed optimization)
                if WIDTH >= 69:
                    temp_message = "This operation will expand & unmark lines. Continue? (y/n)"
                else:
                    temp_message = "Lines will be unmarked. Continue? (y/n)"
                if getConfirmation(temp_message):
                    start = min(line_num_list)
                    end = max(line_num_list)
                    newDelete(start, end)
                    if delete_selection:
                        program_message = " Selection deleted (%i lines) " %(count)
                    else:
                        program_message = " Deleted %i lines " %(count)
                    return
                else:
                    program_message = " Delete aborted! "
                    return

            for i in range(len(argList)-1, -1, -1):
                num = int(argList[i])
                statCount += 1
                if line.total > 2000 and count >= 49 and statCount/10.0 == int(statCount/10.0): ## display processing message
                    statusMessage("Processing: ", (100/(count * 1.0/statCount)))
                delete(num, False)
            program_message = " Deleted %i lines " %(count)

        elif "-" in temptext:
            argList = getArgs(temptext," ","-")
            start = max(1, int(argList[0]))
            end = min(line.total, int(argList[1]))
            length = (end - start)
            if start > end: length = -1
            for i in range(end, start - 1, - 1):
                count += 1
            if not getConfirmation("Delete %i lines? (y/n)" %count):
                program_message = " Delete aborted! "
                return

            if length > 100 and line.total > 1000: ##Use new delete (speed optimization)
                if WIDTH >= 69:
                    temp_message = "This operation will expand & unmark lines. Continue? (y/n)"
                else:
                    temp_message = "Lines will be unmarked. Continue? (y/n)"
                if getConfirmation(temp_message):
                    newDelete(start, end)
                    program_message = " Deleted %i lines " %(length+1)

                    return
                else:
                    program_message = " Delete aborted! "
                    return

            for i in range(end, start - 1, - 1):
                statCount += 1
                if length > 500 and statCount/10.0 == int(statCount/10.0): ## display processing message
                    statusMessage("Processing: ", (100/(length * 1.0/statCount)))
                elif line.total > 2000 and length >= 49 and statCount/10.0 == int(statCount/10.0): ## display processing message
                    statusMessage("Processing: ", (100/(length * 1.0/statCount)))
                delete(i, False)
            program_message = " Deleted %i lines " %(length+1)
        else:
            argList = getArgs(temptext)
            if 'str' in str(type(argList)):
                num = int(argList)
            else:
                num = int(argList[0])
            if num < 1 or num > line.total:
                program_message = " Line does not exist, delete failed! "
                return
            elif num == line.total:
                program_message = " Last line can not be deleted! "
                return

            if not delete_selection and not getConfirmation("Delete line number %i? (y/n)" %num):
                program_message = " Delete aborted! "
                return
            delete(num, False)
            program_message = " Deleted line number %i " %num
        if not program_message: program_message = " Delete successful "
        saved_since_edit = False
        if settings["syntax_hilighting"]: syntaxVisible()
        if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()

    except:
        getConfirmation("Error occurred, nothing deleted!",True)

def insert(pos, text = "", paste_operation = False):
    """ Insert line"""
    global saved_since_edit
    saved_since_edit = False

    if pos < 1: pos = 1
    if pos > line.total: pos = line.total

    temp = line.db[line.total]
    a = line(text)

    a.checkExecutable()

    if paste_operation and settings["select_on_paste"]:
        a.selected = True

    if settings["syntax_hilighting"]: a.addSyntax() #changed/added to try to increase operation speed
    if settings["debug"]: errorTest(a.number)

    for i in range (line.total - 1, pos, -1):
        prev = i - 1
        line.db[i] = line.db[prev]
        line.db[i].number = i
    line.db[pos] = a
    line.db[pos].number = pos

    line.db[line.total] = temp
    line.db[line.total].number = line.total

def splitLine(pos,firstPart, secondPart):
    """Splits lines at position"""
    global currentNum, current_line, saved_since_edit
    saved_since_edit = False

    markStatus = line.db[pos].marked #attempt to fix 'mark' bug
    selectStatus = line.db[pos].selected #attempt to fix 'select' bug
    insert(pos)
    line.db[pos].text = firstPart
    line.db[pos+1].text = secondPart
    line.db[pos].marked = markStatus #attempt to fix 'mark' bug
    line.db[pos+1].marked = False #attempt to fix 'mark' bug

    line.db[pos].selected = selectStatus #attempt to fix 'select' bug
    line.db[pos+1].selected = False #attempt to fix 'select' bug

    line.db[pos].calcCursor()  #This added to fix bug where cursor position (end_x) was incorrect
    line.db[pos+1].calcCursor()

    currentNum += 1
    line.db[pos+1].y = line.db[pos+1].end_y
    line.db[pos+1].x = 6

    if settings["syntax_hilighting"]: syntaxVisible()

def newDoc():
    """Deletes current doc from memory and creates empty one"""
    global program_message, currentNum, savepath, saved_since_edit
    global undo_list, undo_text_que, undo_state_que, undo_state, undo_mark_que, undo_mark
    if reset_needed: resetLine()
    if not saved_since_edit and not getConfirmation("Create new file without saving old? (y/n)"): return
    if settings["splitscreen"]: settings["splitscreen"] = 1
    try:
        if line.db:
            line.locked = False
            del line.db
            line.db = {}
    except:
        pass
    l = line("")
    currentNum = 1
    savepath = ""
    program_message = " New file created "
    saved_since_edit = True
    undo_list = []; undo_text_que = []; undo_state_que = []; undo_state = []; undo_mark_que = []; undo_mark = []

def combineLines(pos, firstPart, secondPart):
    """Combines lines at position"""
    global currentNum, current_line

    if line.db[pos].marked or line.db[pos-1].marked: markStatus = True #attempt to fix 'mark' bug
    else: markStatus = False

    part1rows = line.db[pos - 1].number_of_rows
    tempx = line.db[pos - 1].end_x
    line.db[pos-1].text = firstPart + secondPart
    delete(pos)
    tempy = line.db[currentNum].end_y + (part1rows - 1)
    line.db[currentNum].y = tempy
    line.db[currentNum].x = tempx

    line.db[currentNum].marked = markStatus #attempt to fix 'mark' bug

    if settings["syntax_hilighting"]: syntaxVisible()

def goto(mytext):
    """program specific function which moves to given line number"""
    global currentNum, program_message, prev_line
    prev_line = currentNum
    tempstring = mytext[5:]
    item_found = ""
    if reset_needed: resetLine()
    try:
        if not tempstring.isdigit(): ##Find function or class
            findfunction = "def " + tempstring + "("
            findclass = "class " + tempstring + "("
            for i in range(1, len(line.db)+1):
                item = line.db[i]
                if item.text.strip().startswith(findfunction) or item.text.strip().startswith(findclass):
                    if item.text.strip().startswith("def"): item_found = "function"
                    elif item.text.strip().startswith("class"): item_found = "class"
                    tempstring = i
                    break
            if tempstring == mytext[5:]:
                if tempstring == "start": tempstring = 1
                elif tempstring == "end": tempstring = line.total
                else:
                    for i in range(1, len(line.db)+1):
                        item = line.db[i]
                        if item.text.strip().startswith("def %s" %tempstring) or item.text.strip().startswith("class %s" %tempstring):
                            if item.text.strip().startswith("def"): item_found = "function"
                            elif item.text.strip().startswith("class"): item_found = "class"
                            tempstring = i
                            break

            if tempstring == mytext[5:]:
                program_message = " Specified function/class not found! "
                return

        currentNum = max(min(int(tempstring), line.total), 1)
        line.db[currentNum].x = line.db[currentNum].end_x ##update cursor position
        if line.db[currentNum].collapsed: program_message = " Moved to line %i (collapsed) " %(currentNum)
        else: program_message = " Moved from line %i to %i " %(prev_line, currentNum)
        if settings["syntax_hilighting"]: syntaxVisible()
    except:
        program_message = " Goto failed! "

def prev():
    """Goto previous line"""
    global program_message, prev_line, currentNum
    if reset_needed: resetLine()
    try:
        current = currentNum
        currentNum = prev_line
        prev_line = current
        line.db[currentNum].x = line.db[currentNum].end_x ##update cursor position
        program_message = " Moved from line %i to %i " %(prev_line, currentNum)
        if settings["syntax_hilighting"]: syntaxVisible()
    except:
        program_message = " Prev failed! "

def comment(mytext):
    """New comment function that uses returnArgs"""
    global saved_since_edit, program_message
    if reset_needed: resetLine()
    selection = False
    if mytext == "comment":
        selection,item_count = getSelected()
        if selection:
            mytext = "comment %s" %selection
    try:
        mylist = returnArgs(mytext)
        count = len(mylist)
        update_que("COMMENT operation")
        update_undo()
        loop_num = 0
        for i in mylist:
            loop_num += 1
            if line.db[i].text:
                line.db[i].text = "#" + line.db[i].text
                if settings["debug"] and i > 1: ##update error status
                    line.db[i].error = False
                    errorTest(line.db[i].number) #test for code errors
                if len(mylist) > 200 and i/10.0 == int(i/10.0) and settings["syntax_hilighting"]:
                    statusMessage("Processing: ", (100/((len(mylist)+1.0)/(loop_num))))
            else: count -= 1
            if i == currentNum: line.db[currentNum].x = line.db[currentNum].end_x
        if selection: program_message = " Selection commented (%i lines) " %count
        elif len(mylist) == 1 and count == 1: program_message = " Commented line number %i " %mylist[0]
        else: program_message = " Commented %i lines " %count
    except:
        program_message = " Error, Comment Failed! "
    if settings["syntax_hilighting"]: syntaxVisible()
    if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()
    saved_since_edit = False

def uncomment(mytext):
    """New uncomment function that uses returnArgs"""
    global saved_since_edit, program_message
    if reset_needed: resetLine()
    selection = False
    if mytext == "uncomment":
        selection,item_count = getSelected()
        if selection:
            mytext = "Uncomment %s" %selection
    try:
        mylist = returnArgs(mytext)
        count = len(mylist)
        update_que("UNCOMMENT operation")
        update_undo()
        loop_num = 0
        for num in mylist:
            loop_num += 1
            if line.db[num].text and line.db[num].text[0] == "#":
                line.db[num].text = line.db[num].text[1:]
                if settings["debug"] and num > 1: ##update error status
                    line.db[num].error = False
                    errorTest(line.db[num].number) #test for code errors
                if len(mylist) > 200 and num/10.0 == int(num/10.0) and settings["syntax_hilighting"]:
                    statusMessage("Processing: ", (100/((len(mylist)+1.0)/(loop_num))))
            else: count -= 1
            if num == currentNum: line.db[currentNum].x = line.db[currentNum].end_x ##reset cursor if current line
        if selection: program_message = " Selection uncommented (%i lines) " %count
        elif len(mylist) == 1 and count == 1: program_message = " Uncommented line number %i " %mylist[0]
        else: program_message = " Uncommented %i lines " %count
    except:
        program_message = " Error, Uncomment Failed! "
    if settings["syntax_hilighting"]: syntaxVisible()
    if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()
    saved_since_edit = False

def indent(mytext):
    """New indent function that uses returnArgs"""
    global saved_since_edit, program_message
    if reset_needed: resetLine()
    selection = False
    if mytext == "indent":
        selection,item_count = getSelected()
        if selection:
            mytext = "Indent %s" %selection
    if reset_needed: resetLine()
    try:
        mylist = returnArgs(mytext)
        count = len(mylist)
        update_que("INDENT operation")
        update_undo()
        loop_num = 0
        for num in mylist:
            loop_num += 1
            if line.db[num].text:
                line.db[num].text = "    " + line.db[num].text
                if settings["debug"] and num > 1: ##update error status
                    line.db[num].error = False
                    errorTest(line.db[num].number) #test for code errors
                if len(mylist) > 200 and num/10.0 == int(num/10.0) and settings["syntax_hilighting"]:
                    statusMessage("Processing: ", (100/((len(mylist)+1.0)/(loop_num))))
            else: count -= 1
            if num == currentNum: line.db[currentNum].x = line.db[currentNum].end_x ##reset cursor if current line
        if selection: program_message = " Selection indented (%i lines) " %count
        elif len(mylist) == 1 and count == 1: program_message = " Indented line number %i " %mylist[0]
        else: program_message = " Indented %i lines " %count
    except:
        program_message = " Error, Indent Failed! "
    if settings["syntax_hilighting"]: syntaxVisible()
    if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()

    saved_since_edit = False

def unindent(mytext):
    """New unindent function that uses returnArgs"""
    global saved_since_edit, program_message
    if reset_needed: resetLine()
    selection = False
    if mytext == "unindent":
        selection,item_count = getSelected()
        if selection:
            mytext = "unindent %s" %selection
    try:
        mylist = returnArgs(mytext)
        count = len(mylist)
        update_que("UNINDENT operation")
        update_undo()
        loop_num = 0
        for num in mylist:
            loop_num += 1
            if line.db[num].text and line.db[num].text[0:4] == "    ":
                line.db[num].text = line.db[num].text[4:]
                if settings["debug"] and num > 1: ##update error status
                    line.db[num].error = False
                    errorTest(line.db[num].number) #test for code errors
                if len(mylist) > 200 and num/10.0 == int(num/10.0) and settings["syntax_hilighting"]:
                    statusMessage("Processing: ", (100/((len(mylist)+1.0)/(loop_num))))
            else: count -= 1
            if num == currentNum: line.db[currentNum].x = line.db[currentNum].end_x ##reset cursor if current line
        if selection: program_message = " Selection unindented (%i lines) " %count
        elif len(mylist) == 1 and count == 1: program_message = " Unindented line number %i " %mylist[0]
        else: program_message = " Unindented %i lines " %count
    except:
        program_message = " Error, Unindent Failed! "
    if settings["syntax_hilighting"]: syntaxVisible()
    if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()
    saved_since_edit = False

def syntaxVisible():
    """Adds syntax for lines visible on screen only""" #Added to speed up program
    start = min(line.total, currentNum + 2)
    end = max(0, currentNum - HEIGHT)

    for i in range(start,end, -1):
        try:
            if line.db[i].number_of_rows < HEIGHT - 4: line.db[i].addSyntax() #changed to further speed up program
        except:
            return

def syntaxSplitscreen():
    """Adds syntax for lines visible on splitscreen""" #Added to improve split functionality
    maxrow = int(HEIGHT/2 + 1)
    if not settings["splitscreen"]: return
    start = max(1, settings["splitscreen"])
    end = min(line.total, settings["splitscreen"] + maxrow)
    for i in range(start,end+1):
        try:
            if line.db[i].number_of_rows < HEIGHT - 4: line.db[i].addSyntax() #changed to further speed up program
        except:
            return

def debugVisible():
    """Debugs lines visible on screen only""" #Added to speed up program
    start = min(line.total, currentNum + 2)
    end = max(1, currentNum - HEIGHT)

    for i in range(start,end, -1):
        line.db[i].error = False
        errorTest(line.db[i].number)

def run():
    """Run command executes python code in a seperate window"""
    mypath = os.path.expanduser("~")
    tempFile = os.path.join(mypath, ".TEMP_warrior-ide_runfile.tmp")

    text_file = open(tempFile, "w")
    text_file.write("try:\n")
    for key in line.db:
        thisText = ("    " + line.db[key].text + "\n")
        text_file.write(thisText)
    text_file.write("except(NameError, IOError, IndexError, KeyError, SyntaxError, TypeError, ValueError, ZeroDivisionError, IndentationError),e:\n")
    text_file.write("    print 'ERROR:',e\n")
    text_file.write("else:\n")
    text_file.write("    print 'Run complete.'\n")
    hold_message = """raw_input("Press 'enter' to end")"""
    text_file.write(hold_message)
    text_file.close()
    entryList = []
    mystring = ""
    os.system("%s python %s" %(settings["terminal_command"], tempFile)) #Run program
    os.system("sleep 1")
    os.system("rm %s" %tempFile) #Delete tempFile

def getArgs(textString, breakChar = " ", seperator = " ", stripSpaces = True):
    """Function to seperate arguments from text string

            Optional arguments:
                breakChar - character that seperates 'command' from arguments
                            default is " "
                seperator - character that seperates arguments from one another
                            default is " "
                stripSpaces - strips spaces from arguments
                            default is True"""
    try:
        textString = textString[(textString.find(breakChar)+1):] #removes leading "command" at breakpoint

        if seperator != " " and stripSpaces: textString = textString.replace(" ", "") #strips spaces

        if seperator:
            argList = textString.split(seperator) #seperates arguments
        else:
            argList = []
            for item in textString: argList.append(item) #seperates individual characters, if not seperator

        if len(argList) == 1: return argList[0] #if single argument, return argument
        else: return argList #if multiple arguments, return list of arguments
    except:
        return False #return False if error occurs

def commandMatch(textString, command, alt = "<@>_foobar_", protect_needed = True):
    """Gets 'command' from string, returns False if next character is '='."""
    if textString == "<@>_foobar_": return False
    textList = ""
    origText = textString
    try:
        if not textString or textString[0] == " ": return False

        if not settings["inline_commands"] and protect_needed: return False

        if " " in textString and " " not in command:
            textList = textString.split()
            if len(textList) > 1:
                if textList[1] and textList[1][0] in ("=","+","-","*","/","%","(","[","{"):
                    if command in ("replace", "protect") and " with " in textString: pass
                    elif command in ("save", "saveas", "load") and textList[1][0] == "/": pass
                    else: return False
                if command in ("replace", "protect") and textString.count(" ") > 3 and " with " not in textString and "|" not in textString:
                    return False
                textString = textList[0]

        if settings["inline_commands"] == "protected" and protect_needed:
            command = settings["protect_string"] + command
            alt = settings["protect_string"] + alt
            temp_text = textString.replace(settings["protect_string"], "")
        else:
            temp_text = textString

        if command in ("syntax","entry","live","formatting", "tab","tabs","whitespace","show", "hide","goto","color", "help", "debug", "split", "guide", "pageguide") and len(textList) > 2:
            return False

        if alt in ("syntax","entry","live","formatting", "tab","tabs","whitespace","show", "hide","goto","color", "help", "debug", "split", "guide", "pageguide") and len(textList) > 2:
            return False

        if temp_text not in ("replace", "protect", "find", "save", "saveas", "load","mark") and origText.count(" ") - 1 > origText.count(",") + (2 * origText.count("-")):
            return False
        if temp_text not in ("replace", "protect", "find", "save", "saveas", "load","mark") and origText.count("-") > 1:
            return False
        if temp_text not in ("replace", "protect", "find", "save", "saveas", "load","mark") and "-" in origText and "," in origText:
            return False

        if textString == command or textString == alt:
            if settings["inline_commands"] == "protected" and protect_needed:
                current_line.text = current_line.text[len(settings["protect_string"]):]
            return True
        else:
            return False
    except:
        return False

def printBackground():
    """Displays background color"""
    for i in range (0,HEIGHT + 2):
        try:
            stdscr.addstr(i,0,(" " * WIDTH), settings["color_background"])
        except:
            return

def formattedComments(textstring):
    """Returns formatted text based on comment type"""
    if not textstring or len(textstring) > ROWSIZE + 1 or textstring[0].strip() != "#": return False
    strippedtext = textstring.strip("#")
    if settings["page_guide"] and settings["page_guide"] > 20: comment_width = settings["page_guide"]
    else: comment_width = ROWSIZE #changed from ROWSIZE - 1

    if strippedtext == "":
        tempText = " " * (comment_width)
        return tempText
    elif len(strippedtext) == 1:
        tempText = strippedtext * (comment_width)
        return tempText
    elif strippedtext.upper() == "DEBUG":
        textstring = "**DEBUG**"
        tempText = textstring.rjust(comment_width)
        return tempText
    else:
        try:
            if textstring[2] != "#" and textstring[-1] != "#": commentType = "LEFT"
            elif textstring[-1] != "#": commentType = "RIGHT"
            elif textstring[-1] == "#": commentType = "CENTER"
            else: commentType = "LEFT"
        except:
            commentType = "LEFT"
        #New formatting options
        if commentType == "LEFT":
            tempText = strippedtext.ljust(comment_width)
            return tempText
        elif commentType == "CENTER":
            tempText = strippedtext.center(comment_width)
            return tempText
        elif commentType ==  "RIGHT":
            tempText = strippedtext.rjust(comment_width)
            return tempText

def color_on(default_colors = False):
    """Turn on curses color and handle color assignments"""
    global program_message
    if reset_needed: resetLine()

    if curses.has_colors():
        curses.start_color()
    else:
        if OperatingSystem == "Macintosh": getConfirmation("Color not supported on the OSX terminal!", True)
        else: getConfirmation("Color not supported on your terminal!", True)
        defaultSettings(True, True)
        settings["display_color"] = False
        program_message = " Monochrome display "
        return

    curses.init_pair(1, curses.COLOR_WHITE, curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_CYAN, curses.COLOR_BLACK)
    curses.init_pair(3, curses.COLOR_BLUE, curses.COLOR_BLACK)
    curses.init_pair(4, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(5, curses.COLOR_YELLOW, curses.COLOR_BLACK)
    curses.init_pair(6, curses.COLOR_RED, curses.COLOR_BLACK)
    curses.init_pair(7, curses.COLOR_MAGENTA, curses.COLOR_BLACK)

    curses.init_pair(8, curses.COLOR_BLACK, curses.COLOR_WHITE)
    curses.init_pair(9, curses.COLOR_BLACK, curses.COLOR_CYAN)
    curses.init_pair(10, curses.COLOR_BLACK, curses.COLOR_BLUE)
    curses.init_pair(11, curses.COLOR_BLACK, curses.COLOR_GREEN)
    curses.init_pair(12, curses.COLOR_BLACK, curses.COLOR_YELLOW)
    curses.init_pair(13, curses.COLOR_BLACK, curses.COLOR_RED)
    curses.init_pair(14, curses.COLOR_BLACK, curses.COLOR_MAGENTA)

    curses.init_pair(15, curses.COLOR_BLUE, curses.COLOR_WHITE)
    curses.init_pair(16, curses.COLOR_GREEN, curses.COLOR_WHITE)
    curses.init_pair(17, curses.COLOR_RED, curses.COLOR_WHITE)

    curses.init_pair(18, curses.COLOR_WHITE, curses.COLOR_BLUE)
    curses.init_pair(19, curses.COLOR_WHITE, curses.COLOR_GREEN)
    curses.init_pair(20, curses.COLOR_WHITE, curses.COLOR_RED)

    curses.init_pair(21, curses.COLOR_RED, curses.COLOR_BLUE)
    curses.init_pair(22, curses.COLOR_BLUE, curses.COLOR_RED)

    curses.init_pair(23, curses.COLOR_MAGENTA, curses.COLOR_GREEN)
    curses.init_pair(24, curses.COLOR_GREEN, curses.COLOR_MAGENTA)

    curses.init_pair(25, curses.COLOR_YELLOW, curses.COLOR_GREEN)
    curses.init_pair(26, curses.COLOR_GREEN, curses.COLOR_YELLOW)

    curses.init_pair(27, curses.COLOR_WHITE, curses.COLOR_YELLOW)
    curses.init_pair(28, curses.COLOR_WHITE, curses.COLOR_MAGENTA)
    curses.init_pair(29, curses.COLOR_YELLOW, curses.COLOR_BLUE)
    curses.init_pair(30, curses.COLOR_GREEN, curses.COLOR_BLUE)
    curses.init_pair(31, curses.COLOR_MAGENTA, curses.COLOR_BLUE)
    curses.init_pair(32, curses.COLOR_CYAN, curses.COLOR_BLUE)

    curses.init_pair(33, curses.COLOR_CYAN, curses.COLOR_WHITE)
    curses.init_pair(34, curses.COLOR_YELLOW, curses.COLOR_WHITE)
    curses.init_pair(35, curses.COLOR_MAGENTA, curses.COLOR_WHITE)
    curses.init_pair(36, curses.COLOR_WHITE, curses.COLOR_WHITE)
    curses.init_pair(37, curses.COLOR_YELLOW, curses.COLOR_YELLOW)
    curses.init_pair(38, curses.COLOR_BLACK, curses.COLOR_BLACK)
    curses.init_pair(39, curses.COLOR_GREEN, curses.COLOR_RED)
    curses.init_pair(40, curses.COLOR_YELLOW, curses.COLOR_RED)
    curses.init_pair(41, curses.COLOR_CYAN, curses.COLOR_RED)
    curses.init_pair(42, curses.COLOR_MAGENTA, curses.COLOR_RED)
    curses.init_pair(43, curses.COLOR_BLUE, curses.COLOR_GREEN)
    curses.init_pair(44, curses.COLOR_CYAN, curses.COLOR_GREEN)
    curses.init_pair(45, curses.COLOR_RED, curses.COLOR_GREEN)
    curses.init_pair(46, curses.COLOR_RED, curses.COLOR_YELLOW)
    curses.init_pair(47, curses.COLOR_WHITE, curses.COLOR_CYAN)
    curses.init_pair(48, curses.COLOR_BLUE, curses.COLOR_CYAN)
    curses.init_pair(49, curses.COLOR_RED, curses.COLOR_CYAN)
    curses.init_pair(50, curses.COLOR_YELLOW, curses.COLOR_CYAN)
    curses.init_pair(51, curses.COLOR_MAGENTA, curses.COLOR_CYAN)

    curses.init_pair(52, curses.COLOR_BLUE, curses.COLOR_YELLOW)

    colors["white_on_black"] = curses.color_pair(1)
    colors["cyan_on_black"] = curses.color_pair(2)
    colors["blue_on_black"] = curses.color_pair(3)
    colors["green_on_black"] = curses.color_pair(4)
    colors["yellow_on_black"] = curses.color_pair(5)
    colors["red_on_black"] = curses.color_pair(6)
    colors["magenta_on_black"] = curses.color_pair(7)

    colors["black_on_white"] = curses.color_pair(8)
    colors["black_on_cyan"] = curses.color_pair(9)
    colors["black_on_blue"] = curses.color_pair(10)
    colors["black_on_green"] = curses.color_pair(11)
    colors["black_on_yellow"] = curses.color_pair(12)
    colors["black_on_red"] = curses.color_pair(13)
    colors["black_on_magenta"] = curses.color_pair(14)

    colors["blue_on_white"] = curses.color_pair(15)
    colors["green_on_white"] = curses.color_pair(16)
    colors["red_on_white"] = curses.color_pair(17)

    colors["white_on_blue"] = curses.color_pair(18)
    colors["white_on_green"] = curses.color_pair(19)
    colors["white_on_red"] = curses.color_pair(20)

    colors["red_on_blue"] = curses.color_pair(21)
    colors["blue_on_red"] = curses.color_pair(22)

    colors["magenta_on_green"] = curses.color_pair(23)
    colors["green_on_magenta"] = curses.color_pair(24)

    colors["yellow_on_green"] = curses.color_pair(25)
    colors["green_on_yellow"] = curses.color_pair(26)

    colors["white_on_yellow"] = curses.color_pair(27)
    colors["white_on_magenta"] = curses.color_pair(28)

    colors["yellow_on_blue"] = curses.color_pair(29)
    colors["green_on_blue"] = curses.color_pair(30)
    colors["magenta_on_blue"] = curses.color_pair(31)
    colors["cyan_on_blue"] = curses.color_pair(32)

    colors["cyan_on_white"] = curses.color_pair(33)
    colors["yellow_on_white"] = curses.color_pair(34)
    colors["magenta_on_white"] = curses.color_pair(35)
    colors["white_on_white"] = curses.color_pair(36)
    colors["yellow_on_yellow"] = curses.color_pair(37)
    colors["black_on_black"] = curses.color_pair(38)
    colors["green_on_red"] = curses.color_pair(39)
    colors["yellow_on_red"] = curses.color_pair(40)
    colors["cyan_on_red"] = curses.color_pair(41)
    colors["magenta_on_red"] = curses.color_pair(42)
    colors["blue_on_green"] = curses.color_pair(43)
    colors["cyan_on_green"] = curses.color_pair(44)
    colors["red_on_green"] = curses.color_pair(45)
    colors["red_on_yellow"] = curses.color_pair(46)
    colors["white_on_cyan"] = curses.color_pair(47)
    colors["blue_on_cyan"] = curses.color_pair(48)
    colors["red_on_cyan"] = curses.color_pair(49)
    colors["yellow_on_cyan"] = curses.color_pair(50)
    colors["magenta_on_cyan"] = curses.color_pair(51)

    colors["blue_on_yellow"] = curses.color_pair(52)

    if no_bold: BOLD = 0
    else: BOLD = curses.A_BOLD
    UNDERLINE = curses.A_UNDERLINE

    #default colors

    if default_colors or settings["default_colors"]:
        settings["color_dim"] = colors["white_on_black"]
        settings["color_line_numbers"] = colors["black_on_yellow"]
        settings["color_line_num_reversed"] = colors["white_on_blue"] + BOLD
        settings["color_warning"] = colors["white_on_red"] + BOLD
        settings["color_normal"] = colors["white_on_black"] + BOLD
        settings["color_background"] = colors["white_on_black"] + BOLD
        settings["color_message"] = colors["white_on_magenta"] + BOLD
        settings["color_reversed"] = colors["white_on_magenta"] + BOLD
        settings["color_underline"] = colors["white_on_black"] + UNDERLINE + BOLD
        settings["color_commands"] = colors["green_on_black"] + BOLD
        settings["color_commands_reversed"] = colors["white_on_green"] + BOLD
        settings["color_quote_double"] = colors["yellow_on_black"] + BOLD
        settings["color_comment"] = colors["yellow_on_black"]
        settings["color_comment_block"] = colors["black_on_yellow"]
        settings["color_comment_seperator"] = colors["black_on_red"]
        settings["color_comment_leftjust"] = colors["white_on_magenta"] + BOLD
        settings["color_comment_rightjust"] = colors["white_on_red"] + BOLD
        settings["color_comment_centered"] = colors["yellow_on_green"] + BOLD
        settings["color_number"] = colors["cyan_on_black"]
        settings["color_entry"] = colors["white_on_blue"] + BOLD

        settings["color_entry_command"] = colors["green_on_blue"] + BOLD
        settings["color_entry_quote"] = colors["yellow_on_blue"] + BOLD
        settings["color_entry_quote_triple"] = colors["red_on_blue"] + BOLD
        settings["color_entry_comment"] = colors["red_on_blue"] + BOLD
        settings["color_entry_functions"] = colors["magenta_on_blue"] + BOLD
        settings["color_entry_class"] = colors["cyan_on_blue"] + BOLD
        settings["color_entry_number"] = colors["cyan_on_blue"] + BOLD
        settings["color_entry_dim"] = colors["white_on_blue"]

        settings["color_operator"] = colors["white_on_black"]
        settings["color_functions"] = colors["magenta_on_black"] + BOLD
        settings["color_functions_reversed"] = colors["white_on_magenta"] + BOLD
        settings["color_class"] = colors["blue_on_black"] + BOLD
        settings["color_class_reversed"] = colors["white_on_blue"] + BOLD
        settings["color_quote_triple"] = colors["red_on_black"]
        settings["color_mark"] = colors["yellow_on_blue"] + BOLD + UNDERLINE
        settings["color_negative"] = colors["red_on_black"] + BOLD
        settings["color_entry_negative"] = colors["red_on_blue"] + BOLD
        settings["color_positive"] = colors["cyan_on_black"] + BOLD
        settings["color_entry_positive"] = colors["cyan_on_blue"] + BOLD
        settings["color_tab_odd"] = colors["white_on_black"]
        settings["color_tab_even"] = colors["yellow_on_black"]
        settings["color_whitespace"] = colors["black_on_white"] + UNDERLINE
        settings["color_header"] = colors["white_on_black"] + BOLD
        settings["color_bar"] = colors["white_on_black"]
        settings["color_constant"] = colors["white_on_black"] + UNDERLINE
        settings["color_entry_constant"] = colors["white_on_blue"] + BOLD
        settings["color_quote_single"] = colors["yellow_on_black"] + BOLD
        settings["color_selection"] = colors["black_on_white"] +  UNDERLINE
        settings["color_selection_reversed"] = colors["black_on_cyan"] + UNDERLINE

    settings["display_color"] = True

def draw_lineNumber_background():
    """Draws background for line numbers"""
    for y in range(2, HEIGHT+1):
        stdscr.addstr(y,0,"     ", settings["color_line_numbers"]) # Prints blank line number block

def endColon(mytext):
    """Finds end colon in text even when followed by comment
            Returns 'True' if colon found, 'False' otherwise"""
    if mytext and mytext[-1] == ":": return True
    elif ":" in mytext:
        templist = mytext.split(":")
        prev = templist[-2]
        last = templist[-1]
        if last.strip().startswith("#") and not prev.rstrip().endswith("#"):
            return True
        else:
            return False
    else:
        return False

def replaceText(mytext):
    """Function to replace old text with new"""
    global program_message, saved_since_edit
    selection, item_count = getSelected()
    if "replace marked" in mytext:
        replaceMarked(mytext)
        return
    elif "replace selected" in mytext:
        replaceSelected(mytext)
        return
    elif selection and getConfirmation("Act on %i selected lines only? (y/n)" %item_count):
        replaceSelected(mytext,False)
        return
    try:
        if "|" in mytext: (oldtext, newtext) = getArgs(mytext, " ", "|", False)
        else: (oldtext, newtext) = getArgs(mytext, " ", " with ", False)
    except:
        getConfirmation("Error occurred, replace operation failed!",True)
        return
    if reset_needed: resetLine()
    replaceNum = 0

    #calculate number of replacements
    for i in range(1, len(line.db)+1):
        item = line.db[i]
        if oldtext in item.text: replaceNum += item.text.count(oldtext)
    if replaceNum: #Confirm replacement
        if replaceNum > 1: messageText = "Replace %i items? (y/n)" %replaceNum
        else: messageText = "Replace 1 item? (y/n)"

        if not getConfirmation(messageText):
            program_message = " Replace aborted! "
            return
        else: # replace items

            update_que("REPLACE operation")
            update_undo()

            for i in range (1, len(line.db)+1):
                item = line.db[i]
                if oldtext in item.text:
                    if replaceNum > 200 and i/10.0 == int(i/10.0): # display processing message
                        statusMessage("Processing: ", (100/((len(line.db)+1) * 1.0/(i+1))))
                    temptext = item.text
                    temptext = temptext.replace(oldtext, newtext)
                    item.text = temptext
                    if settings["syntax_hilighting"]: item.addSyntax() #adjust syntax
                    if settings["debug"] and i > 1:
                        line.db[i].error = False
                        errorTest(line.db[i].number) #test for code errors
            program_message = " Replaced %i items " %replaceNum
        saved_since_edit = False
    else:
        getConfirmation("   Item not found!    ", True)

def replaceMarked(mytext):
    """Replace items in marked lines only"""
    global program_message, saved_since_edit
    count = 0
    markTotal = 0
    if reset_needed: resetLine()
    for i in range (1, len(line.db)+1): ##count number of marked lines
        if line.db[i].marked: markTotal += 1
    if markTotal == 0:
        getConfirmation("No lines are marked!", True)
        program_message = " Replace operation failed! "
        return
    if not getConfirmation("Do replace operation on %i marked lines? (y/n)" %markTotal):
        program_message = " Replace operation aborted! "
        return
    try:
        if "replace marked" in mytext: mytext = mytext.replace("replace marked","replacemarked")
        if "|" in mytext: (oldtext, newtext) = getArgs(mytext, " ", "|", False)
        else: (oldtext, newtext) = getArgs(mytext, " ", " with ", False)
    except:
        getConfirmation("Error occurred, replace operation failed!",True)
        return

    update_que("REPLACE operation")
    update_undo()

    for i in range(1, len(line.db)+1):
        item = line.db[i]
        if item.marked and oldtext in item.text:
            item.text = item.text.replace(oldtext, newtext)
            count += 1
            if settings["syntax_hilighting"]: item.addSyntax() #adjust syntax
            if settings["debug"] and i > 1:
                item.error = False
                errorTest(item.number) #test for code errors

    program_message = " Replaced %i items " %count
    if count == 0:
        getConfirmation("   Item not found.    ", True)
    else:
        saved_since_edit = False

def replaceSelected(mytext, message = True):
    """Replace items in selected lines only"""
    global program_message, saved_since_edit
    count = 0
    selectTotal = 0
    if reset_needed: resetLine()
    for i in range (1, len(line.db)+1): ##count number of selected lines
        if line.db[i].selected: selectTotal += 1
    if selectTotal == 0:
        getConfirmation("No lines are selected!", True)
        program_message = " Replace operation failed! "
        return
    if message and not getConfirmation("Do replace on %i selected lines? (y/n)" %selectTotal):
        program_message = " Replace operation aborted! "
        return
    try:
        if "replace selected" in mytext: mytext = mytext.replace("replace selected","replaceselected")
        if "|" in mytext: (oldtext, newtext) = getArgs(mytext, " ", "|", False)
        else: (oldtext, newtext) = getArgs(mytext, " ", " with ", False)
    except:
        getConfirmation("Error occurred, replace operation failed!",True)
        return

    update_que("REPLACE operation")
    update_undo()

    for i in range(1, len(line.db)+1):
        item = line.db[i]
        if item.selected and oldtext in item.text:
            item.text = item.text.replace(oldtext, newtext)
            count += 1
            if settings["syntax_hilighting"]: item.addSyntax() #adjust syntax
            if settings["debug"] and i > 1:
                item.error = False
                errorTest(item.number) #test for code errors

    program_message = " Replaced %i items " %count
    if count == 0:
        getConfirmation("   Item not found.    ", True)
    else:
        saved_since_edit = False

def copy(mytext, select_only=False):
    """Copy lines to internal 'clipboard'"""
    global clipboard, program_message
    if reset_needed: resetLine()
    if mytext == "copy" or select_only:
        selection,item_count = getSelected()
        if selection:
            mytext = "copy %s" %selection
            if settings["deselect_on_copy"]:
                selection,item_count = getSelected()
                line_list = selection.split(",")
                for item in line_list:
                    linenum = int(item)
                    line.db[linenum].selected = False
            select_only = True
    length = 1
    try:
        clipboard = []
        temptext = mytext
        if "," in temptext:
            argList = getArgs(temptext," ",",")
            length = len(argList)
            for i in range(len(argList)-1, -1, -1):
                num = int(argList[i])
                clipboard.append(line.db[num].text)

        elif "-" in temptext:
            argList = getArgs(temptext," ","-")
            start = int(argList[0])
            end = int(argList[1])
            length = (end - start) + 1
            if length > 25000:   #Stop copy operations that are too big
                getConfirmation("Copy operation limited to 25000 lines!", True)
                program_message = " Copy canceled, limit exceeded! "
                return
            for i in range(end, start - 1, -1):
                clipboard.append(line.db[i].text)
        else:
            argList = getArgs(temptext)
            if 'str' in str(type(argList)):
                num = int(argList)
            else:
                num = int(argList[0])
            clipboard.append(line.db[num].text)
            program_message = " Copied line number %i " %num
        if select_only:
            program_message = " Selection copied (%i lines) " %length
        elif not program_message:
            program_message = " %i lines copied " %length
    except:
        if reset_needed: resetLine()
        getConfirmation("Error occurred, nothing copied!",True)

def paste(mytext):
    """Paste lines from 'clipboard'"""
    global currentNum, program_message, saved_since_edit
    originalNum = currentNum
    if not clipboard:
        getConfirmation("Nothing pasted, clipboard is empty.",True)
        if reset_needed: resetLine()
        return
    if settings["select_on_paste"]: deselect_all()
    saved_since_edit = False

    length = len(clipboard)

    try:
        if getArgs(mytext) == "paste": # Pastes on current line

            temptext = mytext
            if reset_needed: resetLine()
            update_que("PASTE operation")
            update_undo()

            if length > 100 and line.total > 2000: # New bit to improve performance of BIG paste operations
                program_message = " Paste aborted! "
                if WIDTH >= 69:
                    if getConfirmation("This operation will expand & unmark lines. Continue? (y/n)"): newPaste(clipboard, currentNum)
                    return
                else:
                    if getConfirmation("Lines will be unmarked. Continue? (y/n)"): newPaste(clipboard, currentNum)
                    return

            current_line.text += clipboard[0]
            if settings["select_on_paste"]: current_line.selected = True

            if length > 1:
                for i in range(1,length):
                    insert (currentNum, clipboard[i], True)
                    if line.total > 2000 and length > 40 and i/5.0 == int(i/5.0):
                        statusMessage("Processing: ", (100/(length * 1.0/(i+1))))

                program_message = " Pasted %i lines at line number %i " %((len(clipboard)), originalNum)
            else:
                program_message = " Pasted text at line %i " %(currentNum)
            currentNum += len(clipboard) - 1
            line.db[currentNum].x = line.db[currentNum].end_x

        else:
            arg = getArgs(mytext)
            num = int(arg)

            if reset_needed: resetLine()
            if num > len(line.db): ##Stop paste operation
                program_message = " Error, line %i does not exist! " %(num)
                return
            update_que("PASTE operation")
            update_undo()

            if length > 100 and line.total > 2000: # New bit to improve performance of BIG paste operations
                program_message = " Paste aborted! "
                if WIDTH >= 69:
                    if getConfirmation("This operation will expand & unmark lines. Continue? (y/n)"): newPaste(clipboard, num)
                    return
                else:
                    if getConfirmation("Lines will be unmarked. Continue? (y/n)"): newPaste(clipboard, num)
                    return

            for i in range(0,length):
                insert (num, clipboard[i], True)
                if line.total > 2000 and length > 40 and i/5.0 == int(i/5.0):
                    statusMessage("Processing: ", (100/(length * 1.0/(i+1))))

            if num <= currentNum: currentNum += len(clipboard)
            if num > line.total: num = line.total - 1 #fix message bug
            if len(clipboard) > 1:
                program_message = " Pasted (inserted) %i lines at line number %i " %((len(clipboard)), num)
            else:
                program_message = " Pasted (inserted) text at line %i " %(num)
    except:
        if reset_needed: resetLine()
        getConfirmation("Error occurred, nothing pasted!",True)

def update_que(thetype = "UNKNOWN operation"):
    """Updates undo queues"""
    global undo_list, undo_type, undo_text_que, undo_state_que, undo_mark_que, text_entered, undo_select_que

    undo_type = thetype

    undo_text_que = []
    undo_state_que = []
    undo_mark_que = []
    undo_select_que = []

    for i in range(1, len(line.db)+1):
        undo_text_que.append(line.db[i].text)
        undo_state_que.append(line.db[i].collapsed)
        undo_mark_que.append(line.db[i].marked)
        undo_select_que.append(line.db[i].selected)
    text_entered = False #reset flag

def update_undo():
    """Updates global undo variables, sets them to undo queues"""
    global undo_list, undo_type, undo_text_que, undo_state_que, undo_mark_que, undo_mark, undo_state, undo_select_que, undo_select
    undo_list = undo_text_que
    undo_state = undo_state_que
    undo_mark = undo_mark_que
    undo_select = undo_select_que
    undo_text_que = []
    undo_state_que = []
    undo_mark_que = []
    undo_select_que = []

def undo():
    """Function that reverses command/restores state to last edit"""
    global currentNum, undo_list, undo_text_que, undo_state_que, undo_state, undo_mark_que, undo_mark, program_message, reset_needed, undo_select_que, undo_select
    count = 0
    if reset_needed: resetLine()
    if not undo_list:
        getConfirmation("There is nothing to undo!",True)
        return
    if not getConfirmation("Undo last %s? (y/n)" % undo_type):
        return
    del line.db
    line.db = {}
    length = len(undo_list)
    for i in range(0, len(undo_list)):
        count += 1
        string = undo_list[i]
        l = line(string)

        if length > 500 and count/100.0 == int(count/100.0): # display processing message
            statusMessage("Processing: ", (100/(length * 1.0/count)))

        if undo_state: l.collapsed = undo_state[i]
        if undo_mark: l.marked = undo_mark[i]
        if undo_select: l.selected = undo_select[i]
        if settings["syntax_hilighting"]: l.addSyntax() #adjust syntax
        if settings["debug"]: errorTest(l.number) #test for code errors

    if currentNum > line.total: currentNum = line.total
    undo_list = []
    undo_text_que = []
    undo_state_que = []
    undo_state = []
    undo_mark_que = []
    undo_mark = []
    undo_select_que = []
    undo_select = []

    program_message = " Undo successful "

def enterCommands():
    """Enter commands in 'Entry Window'"""
    global reset_needed, program_message

    program_message = ""
    if line.db[currentNum].text and currentNum == line.total: #create empty line if position is last line
        l = line() #create emtpy line

    reset_needed = False
    mytext = promptUser()
    if commandMatch(mytext, "load","read", False): loadCommand(mytext)
    elif commandMatch(mytext, "find","<@>_foobar_", False): find(mytext)
    elif commandMatch(mytext, "save","<@>_foobar_", False): save(savepath)
    elif commandMatch(mytext, "new","<@>_foobar_", False): newDoc()

    ##Action on marked lines
    elif commandMatch(mytext, "expand marked", "expandmarked", False): expand(markItems("expand"))
    elif commandMatch(mytext, "collapse marked", "collapsemarked", False): collapse(markItems("collapse"))
    elif commandMatch(mytext, "comment marked", "commentmarked", False): comment(markItems("comment"))
    elif commandMatch(mytext, "uncomment marked", "uncommentmarked", False): uncomment(markItems("uncomment"))
    elif commandMatch(mytext, "indent marked", "indentmarked", False): indent(markItems("indent"))
    elif commandMatch(mytext, "unindent marked", "unindentmarked", False): unindent(markItems("unindent"))
    elif commandMatch(mytext, "replacemarked","<@>_foobar_", False): replaceMarked(current_line.text)
    elif commandMatch(mytext, "copy marked","copymarked", False): copy(markItems("copy"))
    elif commandMatch(mytext, "delete marked","deletemarked", False): deleteLines(markItems("delete"))
    elif commandMatch(mytext, "cut marked", "cutmarked", False): cut(markItems("cut"))

    ##Action on selected lines
    elif commandMatch(mytext, "expand selected", "expand selection", False): expand(selectItems("expand"))
    elif commandMatch(mytext, "collapse selected", "collapse selection", False): collapse(selectItems("collapse"))
    elif commandMatch(mytext, "comment selected", "comment selection", False): comment(selectItems("comment"))
    elif commandMatch(mytext, "uncomment selected", "uncomment selection", False): uncomment(selectItems("uncomment"))
    elif commandMatch(mytext, "indent selected", "indent selection", False): indent(selectItems("indent"))
    elif commandMatch(mytext, "unindent selected", "unindent selection", False): unindent(selectItems("unindent"))
    elif commandMatch(mytext, "copy selected","copy selection", False): copy(selectItems("copy"),True)
    elif commandMatch(mytext, "delete selected","delete selection", False): deleteLines(selectItems("delete"))
    elif commandMatch(mytext, "cut selected", "cut selection", False): cut(selectItems("cut"))
    elif commandMatch(mytext, "select reverse", "select invert", False): invertSelection()
    elif commandMatch(mytext, "invert", "invert selection", False): invertSelection()

    elif mytext == "indent": indent("indent %s" %str(current_line.number))
    elif commandMatch(mytext, "indent","<@>_foobar_", False): indent(mytext)
    elif mytext == "unindent": unindent("unindent %s" %str(current_line.number))
    elif commandMatch(mytext, "unindent","<@>_foobar_", False): unindent(mytext)
    elif commandMatch(mytext, "replace","<@>_foobar_", False): replaceText(mytext)
    elif mytext == "copy": copy("copy %s" %str(current_line.number))
    elif commandMatch(mytext, "copy","<@>_foobar_", False): copy(mytext)
    elif mytext == "paste" and len(clipboard) > 1:
        getConfirmation("Error, multiple lines in memory. Specify line number.",True)
    elif commandMatch(mytext, "paste","<@>_foobar_", False): paste(mytext)
    elif mytext == "cut": cut("cut %i" %current_line.number) #if no args, cut current line
    elif commandMatch(mytext, "cut","<@>_foobar_", False): cut(mytext)
    elif commandMatch(mytext, "mark","<@>_foobar_", False): mark(mytext)
    elif mytext in ("unmark all", "unmark off"): unmark_all()
    elif commandMatch(mytext, "unmark","<@>_foobar_", False): unmark(mytext)

    ##Selecting/deselecting
    elif mytext in ("deselect", "unselect"): deselect("deselect %s" %str(current_line.number))
    elif commandMatch(mytext, "deselect all", "unselect all", False): deselect_all() # deselects all lines
    elif commandMatch(mytext, "select off", "select none", False): deselect_all() # deselects all lines
    elif commandMatch(mytext, "deselect", "unselect", False): deselect(mytext)
    elif commandMatch(mytext, "select up", False): selectup(mytext)
    elif commandMatch(mytext, "select down", False): selectdown(mytext)
    elif commandMatch(mytext, "select", False): select(mytext)

    elif commandMatch(mytext, "goto","<@>_foobar_", False): goto(mytext)
    elif mytext == "delete": deleteLines("delete %i" %currentNum) #delete current line if no argument
    elif commandMatch(mytext, "delete","<@>_foobar_", False): deleteLines(mytext)
    elif commandMatch(mytext, "quit","<@>_foobar_", False): quit()
    elif commandMatch(mytext, "show", "hide", False): showHide(mytext)
    elif mytext == "collapse": collapse("collapse %s" %str(current_line.number))
    elif mytext == "collapse": collapse("collapse %s" %str(current_line.number))
    elif mytext == "collapse all": collapse("collapse 1 - %s" %str(len(line.db)))
    elif commandMatch(mytext, "collapse","<@>_foobar_", False): collapse(mytext)
    elif mytext == "expand": expand("expand %s" %str(current_line.number))
    elif mytext == "expand": expand("expand %s" %str(current_line.number))
    elif mytext == "expand all": expandAll()
    elif commandMatch(mytext, "expand","<@>_foobar_", False): expand(mytext)
    elif commandMatch(mytext, "undo","<@>_foobar_", False): undo()
    elif mytext == "comment": comment("comment %s" %str(current_line.number))
    elif commandMatch(mytext, "comment","<@>_foobar_", False): comment(mytext)
    elif mytext == "uncomment": uncomment("uncomment %s" %str(current_line.number))
    elif commandMatch(mytext, "uncomment","<@>_foobar_", False): uncomment(mytext)
    elif commandMatch(mytext, "run","<@>_foobar_", False): run()
    elif commandMatch(mytext, "debug","<@>_foobar_", False): toggleDebug(mytext)
    elif commandMatch(mytext, "syntax","<@>_foobar_", False): toggleSyntax(mytext)

    elif commandMatch(mytext, "whitespace","<@>_foobar_", False): toggleWhitespace(mytext)
    elif commandMatch(mytext, "show whitespace", "hide whitespace" , False): toggleWhitespace(mytext)
    elif commandMatch(mytext, "guide", "pageguide", False): togglePageGuide(mytext)
    elif mytext == "color on":
        color_on()

    elif commandMatch(mytext, "split", "splitscreen"): toggleSplitscreen(mytext) ##toggle splitscreen
    elif commandMatch(mytext, "commands off","<@>_foobar_", False):
        settings["inline_commands"] = False
        program_message = " Inline commands turned off! "
    elif commandMatch(mytext, "commands on","<@>_foobar_", False):
        settings["inline_commands"] = True
        program_message = " Inline commands turned on! "
    elif commandMatch(mytext, "commands protected","<@>_foobar_", False):
        settings["inline_commands"] = "protected"
        program_message = " Inline commands protected with '%s' " %settings["protect_string"]
    elif commandMatch(mytext, "protect", "<@>_foobar_", False): toggleProtection(mytext)
    elif commandMatch(mytext,"timestamp","<@>_foobar_", False): timeStamp()
    elif mytext == "help":
        if getConfirmation("Load HELP GUIDE? Current doc will be purged! (y/n)"): showHelp()
    elif commandMatch(mytext, "help","<@>_foobar_", False): functionHelp(mytext)

    ## New commands (should be last round)
    elif commandMatch(mytext, "entry","<@>_foobar_", False): toggleEntry(mytext)
    elif commandMatch(mytext, "live","<@>_foobar_", False): toggleLive(mytext)
    elif commandMatch(mytext, "strip","<@>_foobar_", False):
        if getConfirmation("Strip extra spaces from lines? (y/n)"): stripSpaces(mytext)
    elif commandMatch(mytext, "savesettings", "saveprefs", False):
        if getConfirmation("Save current settings? (y/n)"): saveSettings()
    elif commandMatch(mytext, "setcolors", "setcolor", False): setColors()
    elif commandMatch(mytext, "isave", "<@>_foobar_", False): isave()
    elif commandMatch(mytext, "auto","<@>_foobar_", False): toggleAuto(mytext)
    elif commandMatch(mytext, "formatting","<@>_foobar_", False): toggleCommentFormatting(mytext)
    elif commandMatch(mytext, "tabs", "tab", False): toggleTabs(mytext)
    elif commandMatch(mytext, "prev","previous", False): prev()
    elif commandMatch(mytext, "acceleration","accelerate", False): toggleAcceleration(mytext)
    elif commandMatch(mytext, "revert","<@>_foobar_", False): revert()
    elif commandMatch(mytext, "saveas","<@>_foobar_", False):
        if len(mytext) > 7: tempPath = mytext[7:]
        elif not savepath: tempPath = False
        else:
            (fullpath, filename) = os.path.split(savepath)
            tempPath = filename
        if not tempPath: tempPath = ""
        if savepath:
            part1 = os.path.split(savepath)[0]
            part2 = tempPath
            tempPath = part1 + "/" + part2
        if "/" not in tempPath: tempPath = (os.getcwd() + "/" + tempPath)
        saveas_path = promptUser("SAVE FILE AS:", tempPath, "(press 'enter' to proceed, UP arrow to cancel)", True)
        if saveas_path: save(saveas_path)
        else: program_message = " Save aborted! "

    else:
        if mytext: program_message = " Command not found! "
        else: program_message = " Aborted entry "

def bugHunt():
    """If bugs found, moves you to that part of the program"""
    global program_message, currentNum
    program_message = ""
    collapsed_bugs = False
    ##Debug current line before moving to next
    line.db[currentNum].error = False
    errorTest(currentNum)

    if currentNum != len(line.db):
        for i in range(currentNum+1, len(line.db)+1):
            item = line.db[i]
            if item.error and item.collapsed: collapsed_bugs = True
            elif item.error:
                currentNum = item.number
                return

    for i in range(1, len(line.db)+1):
        item = line.db[i]
        if item.error and item.collapsed: collapsed_bugs = True
        elif item.error:
            currentNum = item.number
            return

    if collapsed_bugs: program_message = " Bugs found in collapsed sections "
    else: program_message = " No bugs found! "

def statusMessage(mytext, number, update_lines = False):
    """Displays status message"""
    if update_lines: ##clears entire header and updates number of lines
        stdscr.addstr(0,0, " " * (WIDTH), settings["color_header"])
        temp_text = "%i" %line.total
        lines_text = temp_text.rjust(11)
        if settings["inline_commands"] == "protected":
            protect_string = str(settings["protect_string"])
            stdscr.addstr(0,WIDTH-12 - len(protect_string) -1,lines_text, settings["color_header"])
            stdscr.addstr(0,WIDTH - len(protect_string) -1, protect_string, settings["color_message"])
        else:
            stdscr.addstr(0,WIDTH-12,lines_text, settings["color_header"])
    else: ##clears space for statusMessage only
        stdscr.addstr(0,0, " " * (WIDTH - 13), settings["color_header"])
    number = int(number) #Convert to integer
    message = " %s%i" %(mytext, number) + "% "
    stdscr.addstr(0,0, message,settings["color_warning"])
    stdscr.refresh()

def newPaste(clipboard, pos):
    """A new paste algorith meant to speed up LARGE paste operations. Based on 'load'"""
    global currentNum, program_message
    clipboard_length = len(clipboard)
    count = 0
    part1 = []
    part2 = deepcopy(clipboard)
    part2.reverse()
    part3 = []

    for i in range(1, pos):
        part1.append(line.db[i].text)
    for i in range(pos, len(line.db)+1):
        part3.append(line.db[i].text)

    temp_lines = part1 + part2 + part3

    del line.db
    line.db = {}

    length = len(temp_lines)

    for string in temp_lines:
        count += 1
        l = line(string)
        if settings["select_on_paste"] and count > pos-1 and count < pos + clipboard_length:
            l.selected = True
        if length > 500 and count/100.0 == int(count/100.0):
            statusMessage("Rebuilding Document: ", (100/(length * 1.0/count)))
        if settings["syntax_hilighting"]: l.addSyntax()
        if settings["debug"]: errorTest(l.number)

    if pos <= currentNum: currentNum = currentNum + clipboard_length
    if pos > line.total: currentNum = line.total - 1 #fix message bug
    program_message = " Pasted (inserted) %i lines at line %i " %(clipboard_length, pos)

def newDelete(start,end):
    """A new delete algorith meant to speed up LARGE delete operations. Based on 'load'"""
    global currentNum
    count = 0
    part1 = []
    part3 = []

    for i in range(1, start):
        part1.append(line.db[i].text)
    for i in range(end+1, len(line.db)+1):
        part3.append(line.db[i].text)

    temp_lines = part1 + part3

    del line.db
    line.db = {}

    length = len(temp_lines)
    if length == 0: temp_lines = [""] ##Fix bug that occured when deleting entire selection

    for string in temp_lines:
        count += 1
        l = line(string)

        if length > 500 and count/100.0 == int(count/100.0):
            statusMessage("Rebuilding Document: ", (100/(length * 1.0/count)))

        if settings["syntax_hilighting"]: l.addSyntax()
        if settings["debug"]: errorTest(l.number)

    if end < currentNum: currentNum -= (end-start)+1
    elif start > currentNum: pass
    else: currentNum = line.total
    if currentNum > line.total: currentNum = line.total #fix bug

def directoryAttributes(filelist, directory, sortby = settings["default_load_sort"], reverse = settings["default_load_reverse"], showHidden = settings["default_load_invisibles"]):
    """Takes list of filenames and the parent directory, and returns a sorted list of files, paths, and attributes"""
    mylist = []
    readableExtensions = (".txt", ".py", ".pwe", ".cpp", ".c", ".sh", ".js")

    for i in range (0, len(filelist)):
        if not showHidden and not filelist[i].startswith(".") and not filelist[i].endswith("~"):  # doesn't show hidden files or backup files
            if os.path.isdir((directory+filelist[i])):
                mylist.append(filelist[i])
            else:
                for item in readableExtensions: # trims to list to 'readable' files
                    if filelist[i].endswith(item): mylist.append(filelist[i])

        elif showHidden:
            if os.path.isdir((directory+filelist[i])):
                mylist.append(filelist[i])
            else:
                mylist.append(filelist[i])

    if directory.endswith("/"): tempDir = directory[0:-1]
    else: tempDir = directory
    if "/" in tempDir: prevPath = tempDir.rpartition("/")[0]  #assign ParentDir
    else: prevPath = "/"

    prevDir = ("", "../", prevPath, "", "", "parent","")

    directoryContents = []

    for i in range (0, len(mylist)): # cycles thru items in trimmed down list and calculates attributes
        file_name = mylist[i]

        if os.path.isdir((directory + file_name)): file_type = "DIR" #determines if item is directory
        elif file_name.endswith(".txt"): file_type = "text"     # could replace with loop!?
        elif file_name.endswith(".py"): file_type = "python"
        elif file_name.endswith(".pwe"): file_type = "encryp"
        elif file_name.endswith(".cpp"): file_type = "c++"
        elif file_name.endswith(".c"): file_type = "c"
        elif file_name.endswith(".sh"): file_type = "shell"
        elif file_name.endswith(".js"): file_type = "jscrpt"
        else: file_type = "***"
        try:
            rawsize = os.path.getsize((directory + file_name))/1024.00 #get size and convert to kilobytes
        except:
            rawsize = 0
        file_size = "%.2f" %rawsize #limit to two decimal places (f for float)
        file_size = file_size.rjust(8)
        try:
            mod_date = time.strftime('%Y-%m-%d %H:%M', time.localtime(os.path.getmtime((directory + file_name))))
        except:
            mod_date = "????-??-?? ??:??"
        path_to_file = directory + file_name

        ##Determine file access
        if not os.access(path_to_file, os.R_OK): file_access = "NO ACCESS!"
        elif os.access(path_to_file, os.X_OK): file_access = "executable"
        elif os.access(path_to_file, os.R_OK) and not os.access(path_to_file, os.W_OK): file_access = "READ ONLY "
        elif os.access(path_to_file, os.R_OK) and os.access(path_to_file, os.W_OK): file_access = "read/write"
        else: file_access = "UNKNOWN!!!"

        if sortby == "type": sort_me = file_type + file_name.lower() #sort by file_type, then file_name (case insensitive)
        elif sortby == "date": sort_me = mod_date + file_name.lower()
        elif sortby == "size": sort_me = file_size + file_name.lower()
        else: sort_me = file_name.lower()
        directoryContents.append((sort_me, file_name, path_to_file, file_size, mod_date, file_type, file_access))

    if not reverse: directoryContents.sort()
    else: directoryContents.sort(reverse = True)

    directoryContents.insert(0, prevDir)

    return directoryContents

def displayList(directory, page=1, position=0):
    """Displays scrolling list of files for user to choose from"""
    c = 0
    num = 0
    view = 5
    if os.path.isdir(directory) == False and "/" in directory: directory = directory.rpartition("/")[0] + "/" #removes filename (this bit edited)

    templist = os.listdir(directory)
    mylist = []
    SortType = settings["default_load_sort"]
    reverseSort = settings["default_load_reverse"]
    show_hidden = settings["default_load_invisibles"]

    directoryContents = directoryAttributes(templist, directory, SortType, reverseSort,show_hidden) #get file attributes from function

    while (True): # User can explore menus until they make a selection or cancel out
        total_pages = int( len(directoryContents)/(HEIGHT - 3) )
        if len(directoryContents)%(HEIGHT - 3) != 0: total_pages += 1

        stdscr.clear()
        #print empty lines
        if settings["color_background"]: printBackground()
        stdscr.addstr(0, 0, (" " * WIDTH), settings["color_header"]) #Print header
        stdscr.addstr(HEIGHT, 0, (" " * WIDTH), settings["color_header"]) #Print header

        if len(directory) > WIDTH -14:
            tempstring = "... %s" %directory[(len(directory) - WIDTH) + 14:] #s[len(s)-WIDTH:]
            stdscr.addstr(0, 0, tempstring, settings["color_header"]) #Print header
        else:
            stdscr.addstr(0, 0, directory, settings["color_header"]) #Print header
        stdscr.addstr( 0,(WIDTH-10),("page " + str(page) + "/" + str(total_pages)).rjust(10) , settings["color_header"])
        stdscr.hline(1,0,curses.ACS_HLINE,WIDTH, settings["color_bar"]) #print solid line

        stdscr.hline(HEIGHT-1,0,curses.ACS_HLINE,WIDTH, settings["color_bar"]) #print solid line

        if SortType == "size":   #change footer based on SortType
            footerString = "_Home | sort by _Name / *S*i*z*e / _Date / _Type"
        elif SortType == "date":
            footerString = "_Home | sort by _Name / _Size / *D*a*t*e / _Type"
        elif SortType == "type":
            footerString = "_Home | sort by _Name / _Size / _Date / *T*y*p*e"
        else:
            footerString = "_Home | sort by *N*a*m*e / _Size / _Date / _Type"

        printFormattedText(HEIGHT, footerString)
        if not show_hidden: printFormattedText(HEIGHT,"| show _. | _-/_+ info | _Quit", "rjust", WIDTH)
        else: printFormattedText(HEIGHT,"| hide _. | _-/_+ info | _Quit", "rjust", WIDTH)

        adjust = (page - 1) * (HEIGHT - 3)
        for i in range(0, HEIGHT - 3):
            num = (page -1) * (HEIGHT -3) + i
            try:
                name = directoryContents[num][1]
                fullpath = directoryContents[num][2]
                filesize = directoryContents[num][3]
                filemodDate = directoryContents[num][4]
                filetype = directoryContents[num][5]
                if len(directoryContents[num]) > 6: access = directoryContents[num][6]
                else: access = ""

            except:
                break
            #try:
            if position == num:
                #print empty line
                stdscr.addstr(i+2,0, (" " * WIDTH), settings["color_entry"])
                #print name
                if name == "../" or  name == os.path.expanduser("~"):
                    stdscr.addstr(i+2,0, name, settings["color_entry_quote"])
                else:
                    stdscr.addstr(i+2,0, name, settings["color_entry"])
                #clear second part of screen
                if view == 6: stdscr.addstr(i+2,(WIDTH-54), (" " * (WIDTH - (WIDTH - 54))), settings["color_entry"])
                if view == 5: stdscr.addstr(i+2,(WIDTH-41), (" " * (WIDTH - (WIDTH - 41))), settings["color_entry"])
                if view == 4: stdscr.addstr(i+2,(WIDTH-33), (" " * (WIDTH - (WIDTH - 33))), settings["color_entry"])
                if view == 3: stdscr.addstr(i+2,(WIDTH-21), (" " * (WIDTH - (WIDTH - 21))), settings["color_entry"])
                if view == 2: stdscr.addstr(i+2,(WIDTH-11), (" " * (WIDTH - (WIDTH - 11))), settings["color_entry"])
                #print file_access
                if view == 6 and num != 0:
                    if access == "NO ACCESS!":
                        stdscr.addstr(i+2,WIDTH-51, access, settings["color_warning"])
                    elif access == "READ ONLY ":
                        stdscr.addstr(i+2,WIDTH-51, access, settings["color_entry_quote"])
                    elif access == "read/write":
                        stdscr.addstr(i+2,WIDTH-51, access, settings["color_entry_command"])
                    else:
                        stdscr.addstr(i+2,WIDTH-51, access, settings["color_entry_functions"])

                #print filesize
                if view >= 5 and num != 0: stdscr.addstr(i+2,WIDTH-39, (str(filesize) + " KB"), settings["color_entry"])
                if view == 4 and num != 0: stdscr.addstr(i+2,WIDTH-31, (str(filesize) + " KB"), settings["color_entry"])
                if view == 3 and num != 0: stdscr.addstr(i+2,WIDTH-19, (str(filesize) + " KB"), settings["color_entry"])
                #print mod date
                if view >= 5: stdscr.addstr(i+2,WIDTH -25, filemodDate, settings["color_entry"])
                if view == 4: stdscr.addstr(i+2,WIDTH -18, (filemodDate.split(" ")[0]), settings["color_entry"])
                #print type
                if view > 1:
                    if filetype == "parent": stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_entry_quote"])
                    elif filetype == "DIR": stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_entry_number"])
                    elif filetype == "text":  stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_entry_functions"])
                    elif filetype == "python":  stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_entry_command"])
                    elif filetype == "encryp": stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_entry_comment"])
                    else: stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_entry"])
            else:
                stdscr.addstr(i+2,0, (" " * WIDTH), settings["color_background"])
                #print name
                if name == "../" or  name == os.path.expanduser("~"):
                    stdscr.addstr(i+2,0, name, settings["color_quote_double"])
                else:
                    stdscr.addstr(i+2,0, name, settings["color_normal"])
                #clear second part of screen
                if view == 6: stdscr.addstr(i+2,(WIDTH-54), (" " * (WIDTH - (WIDTH - 54))), settings["color_normal"])
                if view == 5: stdscr.addstr(i+2,(WIDTH-41), (" " * (WIDTH - (WIDTH - 41))), settings["color_normal"])
                if view == 4: stdscr.addstr(i+2,(WIDTH-33), (" " * (WIDTH - (WIDTH - 33))), settings["color_normal"])
                if view == 3: stdscr.addstr(i+2,(WIDTH-21), (" " * (WIDTH - (WIDTH - 21))), settings["color_normal"])
                if view == 2: stdscr.addstr(i+2,(WIDTH-11), (" " * (WIDTH - (WIDTH - 11))), settings["color_normal"])

                #print file_access
                if view == 6 and num != 0: stdscr.addstr(i+2,WIDTH-51, access, settings["color_dim"])
                #print filesize
                if view >= 5 and num != 0: stdscr.addstr(i+2,WIDTH-39, (str(filesize) + " KB"), settings["color_dim"])
                if view == 4 and num != 0: stdscr.addstr(i+2,WIDTH-31, (str(filesize) + " KB"), settings["color_dim"])
                if view == 3 and num != 0: stdscr.addstr(i+2,WIDTH-19, (str(filesize) + " KB"), settings["color_dim"])
                #print mod date
                if view >= 5: stdscr.addstr(i+2,WIDTH -25, filemodDate, settings["color_dim"])
                if view == 4: stdscr.addstr(i+2,WIDTH -18, (filemodDate.split(" ")[0]), settings["color_dim"])
                #print type
                if view > 1:
                    if filetype == "parent": stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_quote_double"])
                    elif filetype == "DIR": stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_number"])
                    elif filetype == "text":  stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_functions"])
                    elif filetype == "python":  stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_commands"])
                    elif filetype == "encryp": stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_warning"])
                    else: stdscr.addstr(i+2,WIDTH-6, filetype, settings["color_normal"])

            if len(directory) < WIDTH: stdscr.addstr(0,len(directory),"") # Move cursor
            #except:
            #    pass
        stdscr.refresh()

        c = stdscr.getch()

        if c == curses.KEY_UP: position -= 1
        elif c == curses.KEY_DOWN: position += 1
        elif c == curses.KEY_RIGHT and page < total_pages: page += 1; position += HEIGHT - 3
        elif c == curses.KEY_RIGHT: position += HEIGHT - 3
        elif c == curses.KEY_LEFT: page -= 1; position -= HEIGHT - 3

        elif c == ord('r') and not reverseSort: #reverse
            reverseSort = True
        elif c == ord('r'):
            reverseSort = False
        elif c == ord('t') and SortType == "type" and not reverseSort:
            reverseSort = True
        elif c == ord('k') and SortType == "type" and not reverseSort:
            reverseSort = True
        elif c == ord('t') or c == ord('k'):
            SortType = "type"
            reverseSort = False
        elif c == ord('d') and SortType == "date" and reverseSort:
            reverseSort = False
        elif c == ord('d'):
            SortType = "date"
            reverseSort = True
        elif c == ord('s') and SortType == "size" and reverseSort:
            reverseSort = False
        elif c == ord('s'):
            SortType = 'size'
            reverseSort = True
        elif c == ord('n') and SortType == "name" and not reverseSort:
            reverseSort = True
        elif c == ord('n'):
            SortType = "name"
            reverseSort = False
        elif c in (ord('-'), ord("_")): view = max(1, view - 1)
        elif c in (ord('='), ord("+")): view = min(6, view + 1)

        if WIDTH < 60 and view > 5: view = 5

        elif c == ord('.'):
            if show_hidden: show_hidden = False
            else: show_hidden = True

            templist = os.listdir(directory)
            directoryContents = directoryAttributes(templist, directory, SortType, reverseSort, show_hidden)
            position = 0
            page = 1

        elif c in (ord('q'), ord('Q'), ord('c'), ord('C')): # c for cancel
            if reset_needed: resetLine()
            return False

        elif c in (ord('h'), ord('H')):
            directory = (os.path.expanduser("~") + "/")
            templist = os.listdir(directory)
            directoryContents = directoryAttributes(templist, directory, SortType, reverseSort, show_hidden)
            position = 0
            page = 1

        elif c == 10 and directoryContents[position][1] == "../" and directoryContents[position][3] == "":
            directory = (directoryContents[position][2] + "/")
            if directory == "//": directory = "/"
            templist = os.listdir(directory)
            directoryContents = directoryAttributes(templist, directory, SortType, reverseSort, show_hidden)
            position = 0
            page = 1

        elif c == 10 and directoryContents[position][1] == os.path.expanduser("~") and directoryContents[position][3] == "":
            directory = (directoryContents[position][2] + "/")
            templist = os.listdir(directory)
            directoryContents = directoryAttributes(templist, directory, SortType, reverseSort, show_hidden)
            position = 0
            page = 1

        elif c == 10 and directoryContents[position][5] == "DIR" and os.access(directoryContents[position][2], os.R_OK):
            directory = (directoryContents[position][2] + "/")
            templist = os.listdir(directory)
            directoryContents = directoryAttributes(templist, directory, SortType, reverseSort, show_hidden)
            position = 0
            page = 1

        elif c == 10 and encodingReadable(directoryContents[position][2]):
            return (directoryContents[position][2])

        if c in ( ord('r'), ord('t'), ord('d'), ord('s'), ord('n'), ord('k') ): #update directoryContents
            directoryContents = directoryAttributes(templist, directory, SortType, reverseSort, show_hidden)
            position = 0
            page = 1

        if position + 1 > (HEIGHT - 3) * page and page < total_pages: page +=1
        elif position < (HEIGHT -3) * (page-1): page -=1
        page = max(1, page)
        page = min(page, int(len(directoryContents)/(HEIGHT-3))+1)
        position = max(0, position)
        position = min(position, len(directoryContents)-1)

def printFormattedText(y, string, type = False, width = 79):
    """Formats curses text by looking for 'special' characters.

        Type can be "rjust" for right justification, "center" for centered.
        Width should be passed when using Type.

        Text formatting
        ---------------
        '_' = UNDERLINE
        '^' = BOLD
        '*' = REVERSE

        String Replacement
        ------------------
        '$' = DIAMOND
        '|" = Vertical Line"""

    underline = False; bold = False; reverse = False
    tempstring = string.replace("*", "") #REVERSE
    tempstring = tempstring.replace("_", "") #UNDERLINE
    tempstring = tempstring.replace("^", "") #BOLD

    if type == "rjust": x = width - len(tempstring)
    elif type == "center": x = int( (width - len(tempstring))/2 )
    else: x = 0

    for z in range(0, len(string)):   #easy way to make first letter of each word standout
        item = string[z]
        if item == "_":
            underline = True
        elif item == "^":
            bold = True
        elif item == "*":
            reverse = True
        elif item == "$":
             stdscr.hline(y,x,curses.ACS_DIAMOND,(1), settings["color_normal"]) ## print diamond
             x += 1
        elif item == "|" and reverse == True:
            stdscr.vline(y, x, curses.ACS_VLINE, (1), settings["color_reversed"]) #prints vertical line
            reverse = False
            x += 1
        elif item == "|" and bold == True:
            stdscr.vline(y, x, curses.ACS_VLINE, (1), bold_TEXT) #prints vertical line
            reverse = False
            x += 1
        elif item == "|":
            stdscr.vline(y, x, curses.ACS_VLINE, (1), settings["color_bar"]) ##prints vertical line
            stdscr.hline(y-1,x,curses.ACS_TTEE,(1), settings["color_bar"]) ##Format previous line

            underline = False
            x += 1
        elif underline:
            underline = False
            stdscr.addstr(y,x, item, settings["color_underline"])
            x += 1
        elif bold:
            stdscr.addstr(y,x, item, BOLD_TEXT)
            bold = False
            x += 1
        elif reverse:
            stdscr.addstr(y,x, item, settings["color_reversed"])
            reverse = False
            x += 1
        else:
            stdscr.addstr(y,x, item, settings["color_header"])
            x += 1

def gotoMarked():
    """Move to next 'marked' line"""
    global currentNum, program_message, prev_line
    if currentNum < line.total:
        for i in range (currentNum + 1, len(line.db)+1):
            if line.db[i].marked:
                prev_line = currentNum
                currentNum = line.db[i].number
                if settings["syntax_hilighting"]: syntaxVisible()
                return
    for i in range(1, currentNum):
        if line.db[i].marked:
            prev_line = currentNum
            currentNum = line.db[i].number
            if settings["syntax_hilighting"]: syntaxVisible()
            return
    if line.db[currentNum].marked:
        program_message = " No other lines marked! "
    else:
        program_message = " No lines marked! "

def prevMarked():
    """Move to previous 'marked' line"""
    global currentNum, program_message, prev_line
    if currentNum > 1:
        for i in range(currentNum -1, 0, -1):
            if line.db[i].marked:
                prev_line = currentNum
                currentNum = line.db[i].number
                if settings["syntax_hilighting"]: syntaxVisible()
                return
    for i in range(line.total, currentNum, -1):
        if line.db[i].marked:
            prev_line = currentNum
            currentNum = line.db[i].number
            if settings["syntax_hilighting"]: syntaxVisible()
            return
    if line.db[currentNum].marked:
        program_message = " No other lines marked! "
    else:
        program_message = " No lines marked! "

def revert():
    """Revert file to last saved"""
    if reset_needed:resetLine()
    if getConfirmation("Revert to original file? (y/n)"):
        update_que("REVERT operation")
        update_undo()
        load(savepath)

def toggleSplitscreen(mytext):
    """Turn splitscreen on or off"""
    global program_message
    arg = getArgs(mytext)
    if reset_needed: resetLine()
    program_message = " Splitscreen on "
    if arg == "on": settings["splitscreen"] = 1
    elif arg == "off":settings["splitscreen"] = False; program_message = " Splitscreen off "
    elif arg in ("", "split", "splitscreen") and settings["splitscreen"]: settings["splitscreen"] = False; program_message = " Splitscreen off "
    elif arg in ("", "split", "splitscreen") and not settings["splitscreen"]: settings["splitscreen"] = 1
    else:
        try:
            if arg == "end": arg = max(1, line.total - 1)
            if arg == "start": arg = 1
            lineNumber = int(arg)
            maxrow = int(HEIGHT/2 + 1)
            if lineNumber > line.total - 1: lineNumber = line.total - 1
            if lineNumber < 1: lineNumber = 1
            if lineNumber > line.total: lineNumber = line.total
            settings["splitscreen"] = lineNumber
            program_message = " Splitscreen @ line %i " %lineNumber
        except:
            program_message = " Error, splitscreen failed! "
            return

def toggleDebug(mytext):
    """Turn debug mode on or off"""
    global program_message
    arg = getArgs(mytext)
    if reset_needed: resetLine()
    if arg not in ("on", "off") and settings["debug"] == True: arg = "off"
    elif arg not in ("on", "off") and settings["debug"] == False: arg = "on"
    if arg == "on":
        settings["debug"] = True
        program_message = " Debug on "
    elif arg == "off":
        settings["debug"] = False
        program_message = " Debug off "

def toggleAcceleration(mytext):
    """Turn acceleration on or off"""
    global program_message
    arg = getArgs(mytext)
    if reset_needed: resetLine()
    if arg not in ("on", "off") and settings["cursor_acceleration"] == True: arg = "off"
    elif arg not in ("on", "off") and settings["cursor_acceleration"] == False: arg = "on"
    if arg == "on":
        settings["cursor_acceleration"] = True
        program_message = " Cursor acceleration on "
    elif arg == "off":
        settings["cursor_acceleration"] = False
        program_message = " Cursor acceleration off "

def stripSpaces(mytext):
    """Strips extra/trailing spaces from line"""
    global program_message, saved_since_edit
    if reset_needed: resetLine()
    update_que("STRIP WHITESPACE operation")
    update_undo()
    count = 0
    for num in range (1, line.total+1):
        item = line.db[num]
        if item.text and item.text.count(" ") == len(item.text):
            item.text = ""
            if settings["syntax_hilighting"]: item.addSyntax()
            if settings["debug"]: errorTest(item.number)
            count += 1
        else:
            for i in range(64,0,-1):
                search = (i * " ")
                if item.text.endswith(search):
                    item.text = item.text[:-i]
                    if settings["syntax_hilighting"]: item.addSyntax()
                    if settings["debug"]: errorTest(item.number)
                    count += 1
    if not count: program_message = " No extra whitespace found! "
    else:
        program_message = " %i lines stripped " %count
        saved_since_edit = False

def setColors():
    """Function that allows user to set colors used with syntax hilighting"""
    global program_message
    if reset_needed: resetLine()
    if not settings["display_color"] or not curses.has_colors():
        getConfirmation("You can't set colors in monochrome mode!", True)
        return
    if WIDTH < 79 or HEIGHT < 19:
        getConfirmation("Increase termnal size to set colors!", True)
        return

    settings["default_colors"] = False
    win = curses.newwin(HEIGHT, WIDTH, 0,0) # 0,0 is start position
    x = int((WIDTH - 49)/2)
    c = 0
    i_num = 0
    item_list = []
    c_num = 0
    color_list = []
    temp_list = []
    empty = ("").center(49)
    seperator = ("").center(49,"@")
    style = 0
    style_change = False

    for key in settings.keys():
        if "color_" in key: item_list.append(key)
    for key in colors.keys():
        (item1, item2) = key.split("_on_")
        temp_list.append((item2+item1, key)) #change "white_on_blue" to ("bluewhite", "white_on_blue")
    temp_list.sort()

    for value in temp_list:
        color_list.append(value[1])

    item_list.sort()
    color_list.insert(0, "[CURRENT]")

    for i in range (0, HEIGHT+1):
        stdscr.addstr(i,0, (" " * WIDTH), settings["color_normal"])
        if i <= 8: stdscr.addstr(i,x, empty, curses.A_NORMAL) #redundant?
    title = ("SETCOLORS").center(49)
    header = " ITEM (up/down)               COLOR (left/right)"
    divider = ("").center(49,"-")
    footer = ("*N*o*r*m*a*l $ _Bold $ _Underline $ b_Oth")

    sample_header = ("SAMPLE LAYOUT").center(49)
    sample_left = ("Left justified").ljust(49)
    sample_right = ("Right justified").rjust(49)

    while c != 10: #continue until 'enter' is pressed
        item = item_list[i_num]
        color = color_list[c_num]
        stdscr.addstr(1,x, title, curses.A_REVERSE)
        stdscr.addstr(2,x, header, curses.A_BOLD)
        stdscr.hline(3,x,curses.ACS_HLINE,49,settings["color_bar"])
        if color == "[CURRENT]":
            for key, value in colors.items():
                if settings[item] == value:
                    search = key
                    style = 0
                elif settings[item] == value + curses.A_BOLD:
                    search = key
                    style = curses.A_BOLD
                elif settings[item] == value + curses.A_UNDERLINE:
                    search = key
                    style = curses.A_UNDERLINE
                elif settings[item] == value + curses.A_BOLD + curses.A_UNDERLINE:
                    search = key
                    style = curses.A_BOLD + curses.A_UNDERLINE
            index = color_list.index(search, 1)
            c_num = index
            color = color_list[c_num]

        stdscr.addstr(4,x+23, (color.replace("_"," ").rjust(25)), colors[color] + style) #testing
        stdscr.addstr(4,x+1, ( (item.replace("color","").replace("_"," ")) ).ljust(23), colors["white_on_blue"] + curses.A_BOLD) #testing
        stdscr.hline(5,x,curses.ACS_HLINE,49,settings["color_bar"])
        #print vertical lines
        stdscr.hline(4,x,curses.ACS_VLINE,1,settings["color_bar"])
        stdscr.hline(4,x+48,curses.ACS_VLINE,1,settings["color_bar"])
        #print corners
        stdscr.hline(3,x,curses.ACS_ULCORNER,1,settings["color_bar"])
        stdscr.hline(3,x+48,curses.ACS_URCORNER,1,settings["color_bar"])
        stdscr.hline(5,x,curses.ACS_LLCORNER,1,settings["color_bar"])
        stdscr.hline(5,x+48,curses.ACS_LRCORNER,1,settings["color_bar"])

        if style == curses.A_BOLD + curses.A_UNDERLINE:
            footer = ("_Normal $ _Bold $ _Underline $ *b*O*t*h")
        elif style == curses.A_BOLD:
            footer = ("_Normal $ *B*o*l*d $ _Underline $ b_Oth")
        elif style == curses.A_UNDERLINE:
            footer = ("_Normal $ _Bold $ *U*n*d*e*r*l*i*n*e $ b_Oth")
        else:
            footer = ("*N*o*r*m*a*l $ _Bold $ _Underline $ b_Oth")
        printFormattedText(6,footer, "center",WIDTH)
        stdscr.addstr(8,x, sample_header, settings["color_comment_centered"])   #Text types need to be changed?
        stdscr.addstr(9,x, seperator, settings["color_comment_seperator"])
        stdscr.addstr(10,x, sample_left, settings["color_comment_leftjust"])
        stdscr.addstr(11,x, sample_right, settings["color_comment_rightjust"])

        stdscr.addstr(12,x, "class", settings["color_class"])
        stdscr.addstr(12,x+12, "collapsed", settings["color_class_reversed"])
        stdscr.addstr(12,x+28, "print", settings["color_commands"])
        stdscr.addstr(12,x+40, "#comment", settings["color_comment"])

        stdscr.addstr(13,x, "def", settings["color_functions"])
        stdscr.addstr(13,x+12, "collapsed", settings["color_functions_reversed"])
        stdscr.addstr(13,x+28, "True", settings["color_positive"])
        stdscr.addstr(13,x+40, "False", settings["color_negative"])

        stdscr.addstr(14,x, "'quote'", settings["color_quote_single"])
        stdscr.addstr(14,x+12, '"double"', settings["color_quote_double"])
        stdscr.addstr(14,x+28, '"""doc"""', settings["color_quote_triple"])

        stdscr.addstr(14,x+40, 'CONSTANT', settings["color_constant"])

        stdscr.addstr(15,x, "()!=[]+-", settings["color_operator"])
        stdscr.addstr(15,x+12, "normal text", settings["color_normal"])
        stdscr.addstr(15,x+28,'0123456789', settings["color_number"])
        stdscr.addstr(15,x+40, " C.BLOCK", settings["color_comment_block"])

        stdscr.addstr(16,x, "print ", settings["color_entry_command"])
        stdscr.addstr(16,x+6, '"Entry line"', settings["color_entry_quote"])
        stdscr.addstr(16,x+18, "; ", settings["color_entry_dim"])
        stdscr.addstr(16,x+20, "number ", settings["color_entry"])
        stdscr.addstr(16,x+27, "= ", settings["color_entry_dim"])
        stdscr.addstr(16,x+29, "100", settings["color_entry_number"])
        stdscr.addstr(16,x+32, "; ", settings["color_entry_dim"])
        stdscr.addstr(16,x+34, "def ", settings["color_entry_functions"])
        stdscr.addstr(16,x+38, "#comment  ", settings["color_entry_comment"])

        stdscr.addstr(17,x, "class", settings["color_entry_class"])
        stdscr.addstr(17,x+5, ": ", settings["color_entry_dim"])
        stdscr.addstr(17,x+7, "False", settings["color_entry_negative"])
        stdscr.addstr(17,x+12, ", ", settings["color_entry_dim"])
        stdscr.addstr(17,x+14, "True", settings["color_entry_positive"])
        stdscr.addstr(17,x+18, "; ", settings["color_entry_dim"])
        stdscr.addstr(17,x+20, "CONSTANT", settings["color_entry_constant"])
        stdscr.addstr(17,x+28, "; ", settings["color_entry_dim"])
        stdscr.addstr(17,x+30, '"""Triple Quote"""', settings["color_entry_quote_triple"])

        stdscr.addstr(18,x, "999 ", settings["color_line_numbers"])
        stdscr.addstr(18,x+6, "....", settings["color_tab_odd"])
        stdscr.addstr(18,x+10, "....", settings["color_tab_even"])
        stdscr.addstr(18,x+14, "                                  ", settings["color_background"])

        stdscr.addstr(19,x+12,("Press [RETURN] when done!"), settings["color_warning"])
        stdscr.refresh()
        c = stdscr.getch()

        if c == curses.KEY_UP:
            i_num -= 1
            if i_num < 0: i_num = 0
            c_num = 0
            style_change = False
        elif c == curses.KEY_DOWN:
            i_num += 1
            if i_num > len(item_list)-1: i_num = len(item_list)-1
            c_num = 0
            style_change = False
        elif c == curses.KEY_LEFT:
            c_num -= 1
            if c_num < 1: c_num = 1
            style_change = False
            settings[item_list[i_num]] = colors[color_list[c_num]] + style

        elif c == curses.KEY_RIGHT:
            c_num += 1
            if c_num > len(color_list)-1: c_num = len(color_list)-1
            style_change = False
            settings[item_list[i_num]] = colors[color_list[c_num]] + style
        elif c in (ord("b"), ord("B")):
            style = curses.A_BOLD
            style_change = True
            settings[item_list[i_num]] = colors[color_list[c_num]] + style
        elif c in (ord("u"), ord("U")):
            style = curses.A_UNDERLINE
            style_change = True
            settings[item_list[i_num]] = colors[color_list[c_num]] + style
        elif c in (ord("n"), ord("N")): #set style to normal
            style = 0
            style_change = True # no longer needed?
            settings[item_list[i_num]] = colors[color_list[c_num]] + style
        elif c in (ord("o"), ord("O")):
            style = curses.A_BOLD + curses.A_UNDERLINE
            style_change = True
            settings[item_list[i_num]] = colors[color_list[c_num]] + style

def toggleProtection(mytext):
    """Turns protection on/off for inline commands"""
    global program_message
    if "protect with " in mytext:
        args = getArgs(mytext,"_foobar","protect with ", False)
        if args[1].endswith(" "): args[1] = args[1].rstrip()
        if len(args[1]) > 4: args[1] = args[1][0:4]
        if getConfirmation("Protect commands with '%s'? (y/n)" %args[1]):
            settings["protect_string"] = args[1]
            settings["inline_commands"] = "protected"
            program_message = " Commands now protected with '%s' " %args[1]
    else:
        program_message = " Commands protected with '%s' " %settings["protect_string"]
        arg = getArgs(mytext)
        if arg == "on":
            settings["inline_commands"] = "protected"
        elif arg == "off":
            settings["inline_commands"] = True
            program_message = " Command protection off! "
        else:
            program_message = " Error, protection not changed "
    if reset_needed: resetLine()

def defaultSettings(colors_only = False, skip_mono = False):
    """Set settings to default settings"""

    if not skip_mono:
        if no_bold: boldtext = 0
        else: boldtext = curses.A_BOLD
        settings["mono_normal"] = 0
        settings["mono_reverse"] = curses.A_REVERSE
        settings["mono_bold"] = boldtext
        settings["mono_underline"] = curses.A_UNDERLINE
        settings["mono_reverse_bold"] = curses.A_REVERSE + boldtext
        settings["mono_reverse_underline"] = curses.A_REVERSE + curses.A_UNDERLINE

    settings["color_normal"] = settings["mono_normal"]
    settings["color_background"] = settings["mono_normal"]
    settings["color_dim"] = settings["mono_normal"]
    settings["color_number"] = settings["mono_normal"]
    settings["color_warning"] = settings["mono_reverse_bold"]
    settings["color_message"] = settings["mono_reverse"]
    settings["color_reversed"] = settings["mono_reverse"]
    settings["color_underline"] = settings["mono_underline"]
    settings["color_commands"] = settings["mono_underline"]
    settings["color_quote_single"] = settings["mono_bold"]
    settings["color_quote_double"] = settings["mono_bold"]
    settings["color_quote_triple"] = settings["mono_bold"]
    settings["color_line_numbers"] = settings["mono_normal"]
    settings["color_line_num_reversed"] = settings["mono_reverse"]
    settings["color_operator"] = settings["mono_normal"]
    settings["color_entry"] = settings["mono_reverse"]
    settings["color_functions"] = settings["mono_underline"]
    settings["color_functions_reversed"] = settings["mono_reverse"]
    settings["color_commands_reversed"] = settings["mono_reverse"]
    settings["color_mark"] = settings["mono_reverse_underline"]
    settings["color_entry_command"] = settings["mono_reverse_bold"]
    settings["color_entry_quote"] = settings["mono_reverse"]
    settings["color_entry_quote_triple"] = settings["mono_reverse"]
    settings["color_entry_comment"] = settings["mono_reverse"]
    settings["color_entry_functions"] = settings["mono_reverse_bold"]
    settings["color_entry_class"] = settings["mono_reverse_bold"]
    settings["color_entry_dim"] = settings["mono_reverse"]
    settings["color_entry_number"] = settings["mono_reverse"]
    settings["color_comment"] = settings["mono_normal"]
    settings["color_comment_block"] = settings["mono_reverse"]
    settings["color_comment_seperator"] = settings["mono_reverse"]
    settings["color_comment_leftjust"] = settings["mono_reverse"]
    settings["color_comment_rightjust"] = settings["mono_reverse"]
    settings["color_comment_centered"] = settings["mono_reverse"]
    settings["color_operator"] = settings["mono_normal"]    #new color types
    settings["color_tab_odd"] = settings["mono_normal"]
    settings["color_tab_even"] = settings["mono_bold"]
    settings["color_whitespace"] = settings["mono_reverse_underline"]
    settings["color_class"] = settings["mono_underline"]
    settings["color_class_reversed"] = settings["mono_reverse"]
    settings["color_negative"] = settings["mono_normal"]
    settings["color_entry_negative"] = settings["mono_reverse"]
    settings["color_positive"] = settings["mono_normal"]
    settings["color_entry_positive"] = settings["mono_reverse"]
    settings["color_header"] = settings["mono_normal"]
    settings["color_bar"] = settings["mono_normal"]
    settings["color_constant"] = settings["mono_normal"]
    settings["color_entry_constant"] = settings["mono_reverse"]
    settings["color_selection"] = settings["mono_reverse_underline"]
    settings["color_selection_reversed"] = settings["mono_underline"]
    if colors_only: return

    settings["entry_hilighting"] = True
    settings["syntax_hilighting"] = True
    settings["live_syntax"] = True
    settings["debug"] = True
    settings["collapse_functions"] = False
    settings["splitscreen"] = False
    settings["showSpaces"] = False
    settings["show_indent"] = True
    settings["inline_commands"] = True #set to "protected" to protect commands with protect string
    settings["protect_string"] = "::"
    settings["format_comments"] = True
    settings["display_color"] = True
    settings["default_colors"] = True
    settings["auto"] = False
    settings["page_guide"] = False
    settings["cursor_acceleration"] = True
    ##The following settings can only be changed by manually editing pref file
    settings["cursor_max_horizontal_speed"] = 5
    settings["cursor_max_vertical_speed"] = 12
    settings["encrypt_warning"] = True
    settings["skip_confirmation"] = False
    settings["hilight_commands"] = True
    settings["deselect_on_copy"] = False
    settings["select_on_paste"] = False
    settings["default_load_sort"] = "name"
    settings["default_load_reverse"] = False
    settings["default_load_invisibles"] = False
    settings["key_entry_window"] = 5
    settings["key_find"] = 6
    settings["key_find_again"] = 7
    settings["key_next_bug"] = 4
    settings["key_next_marked"] = 14
    settings["key_previous_marked"] = 2
    settings["key_deselect_all"] = 1
    settings["key_page_down"] = 16
    settings["key_page_up"] = 21
    settings["key_save_as"] = 23
    settings["terminal_command"] = "gnome-terminal -x" #to launch in xterm, set to "xterm -e"

def isave():
    """Incremental save - increments last number in filename
            useful for saving versions"""
    global savepath, program_message
    if reset_needed: resetLine()
    if not savepath: ##stop incremental save if file has not yet been saved
        getConfirmation("Save file before using incremental save!", True)
        program_message = " Save failed! "
        return
    (directory, filename) = os.path.split(savepath)
    (shortname, ext) = os.path.splitext(filename)
    if filename.startswith('.'): shortname = filename; ext = ""
    else: (shortname, ext) = os.path.splitext(filename)

    number = ""
    for i in range(1, len(shortname)+1): #determine if name ends with number
        item = shortname[-i]
        if item.isdigit(): number = item + number
        else: break
    if number: ##increment number at end of filename
        newNum = int(number)+1
        end = len(shortname) - len(number)
        newName = shortname[0:end] + str(newNum)
    else: ##add 2 to end of filename
        newName = shortname + "2"
    newpath = os.path.join(directory, newName) + ext
    save(newpath)

def defaultColors():
    """set colors to default"""
    global program_message
    program_message = " Colors set to defaults "
    if reset_needed: resetLine()
    settings["default_colors"] = True
    color_on(True)

def returnArgs(temptext):
    """Returns list of args (line numbers, not text)"""
    try:
        the_list= []
        if "," in temptext:
            argList = getArgs(temptext," ",",")
            for i in range(0, len(argList)):
                num = int(argList[i])
                if num >= 1 and num <= line.total: the_list.append(num)
        elif "-" in temptext:
            argList = getArgs(temptext," ","-")
            start = int(argList[0])
            end = int(argList[1])
            for num in range(start, end+1):
                if num >= 1 and num <= line.total: the_list.append(num)
        else:
            argList = getArgs(temptext)
            if 'str' in str(type(argList)):
                num = int(argList)
            else:
                num = int(argList[0])
            the_list.append(num)
        return the_list
    except:
        return False

def timeStamp():
    """Prints current time & date"""
    global text_entered, program_message, saved_since_edit
    if reset_needed: resetLine()
    atime = time.strftime('%m/%d/%y %r (%A)', time.localtime())

    current_line.text = current_line.text + atime
    line.db[currentNum].x = line.db[currentNum].end_x
    text_entered = True
    saved_since_edit = False
    program_message = " Current time & date printed "

def rotateString(string, rotateNum, characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 {}[]()!@#$%^&*_+=-'\"\\|/<>,.?~`"):
    """Function that 'rotates' string.
           (I suggest you don't reuse this code in other programs... there are
            better ways to do this in Python)"""
    newtext = ""
    for i in range(0,len(string)):
        char = string[i]
        indexNum = characters.find(char)
        if indexNum == -1:
            newtext += string[i]
        else:
            position = indexNum + rotateNum
            while position >= len(characters):
                position -= len(characters)
            while position < 0:
                position = len(characters) + position
            newCharacter = characters[position]
            newtext += newCharacter
    return newtext

def encrypt(string, password, characters = "~!0ZaYbX1cWdVg{=}Uf9T2eSh[]RiQj3P8kO()lNmKn4LoMp7JqIrEs6GtFuHvDwCxBy5Az@#$%^&?*_+-'\"\\|/<>,. `"):
    """Encrypts text string based on password"""
    count = 0
    newtext = ""
    adjustment = 0
    for i in range(0, len(string)):
        rotateNum = characters.find(password[count]) + len(password) + len(string)

        if i/3.0 == int(i/3.0): rotateNum += 2
        if i/2.0 == int(i/2.0): rotateNum = -rotateNum
        if adjustment: rotateNum += adjustment

        newletter = rotateString(string[i], rotateNum)
        newtext += newletter
        count += 1
        if count >= len(password):
            count = 0
            adjustment += 1
            if adjustment > 7: adjustment = 0
    return newtext

def unencrypt(string, password, characters = "~!0ZaYbX1cWdVg{=}Uf9T2eSh[]RiQj3P8kO()lNmKn4LoMp7JqIrEs6GtFuHvDwCxBy5Az@#$%^&?*_+-'\"\\|/<>,. `"):
    """Unencrypts text string based on password"""
    count = 0
    newtext = ""
    adjustment = 0
    for i in range(0, len(string)):
        rotateNum = -characters.find(password[count]) - len(password) - len(string)

        if i/3.0 == int(i/3.0): rotateNum -= 2
        if i/2.0 == int(i/2.0): rotateNum = -rotateNum
        if adjustment: rotateNum -= adjustment
        newletter = rotateString(string[i], rotateNum)
        newtext += newletter
        count += 1
        if count >= len(password):
            count = 0
            adjustment += 1
            if adjustment > 7: adjustment = 0
    return newtext

def saveEncrypted(the_path):
    """Save encrypted file"""
    global program_message
    if settings["encrypt_warning"] and not confirmEncryption():
        program_message = " Encryption aborted! "
        return
    if WIDTH > 60:
        password = promptUser("Enter password for encrypted save:")
    else:
        password = promptUser("Enter password:")
    if not password:
        program_message = " Encryption aborted! "
        return
    if savepath and "." in savepath: extension = "." + (savepath.split(".")[-1])
    else: extension = ".???"

    if os.path.exists(the_path) and not getConfirmation(" File exists, overwrite? (y/n) "): return
    text_file = open(the_path, "w")

    checkPos = random.randrange(1, len(line.db)+1) #calculate random position to place decrypt check

    for i in range(1, len(line.db)+1):
        if len(line.db)+1 > 500 and i/100.0 == int(i/100.0): ##display status message
            statusMessage("Encrypting: ", (100/((len(line.db)+1) * 1.0/(i+1))))

        item = line.db[i]
        num_str = str(item.number)
        num_str = num_str[::-1] # reverse string
        linetext = item.text
        if i == 1: linetext = str(checkPos) + "|" + linetext
        if i == checkPos: linetext = linetext + "|" + extension + "-pw"
        temp = encrypt(linetext, num_str) #First pass
        thisText = encrypt(temp, password) #Second pass
        thisText +="\n"
        text_file.write(thisText)
    text_file.close()
    program_message = " Encrypted file saved "

def loadEncrypted(the_path):
    """Load encrypted file"""
    try:
        myfile = open(the_path)
        temp_lines = myfile.readlines()
        myfile.close()
        new_lines = []
        password = promptUser("File encrypted, enter password:")
        if not password: return (False, False)

        for i in range(0, len(temp_lines)):
            if len(temp_lines) > 500 and i/100.0 == int(i/100.0): ##display status message
                statusMessage("Decoding: ", (100/(len(temp_lines) * 1.0/(i+1))))
            num_str = str(i+1)
            num_str = num_str[::-1] # reverse string
            ctext = temp_lines[i]
            if ctext.endswith("\n"): ctext = ctext.replace("\n","")
            temp = unencrypt(ctext, password) #First pass
            thisText = unencrypt(temp, num_str) #Second pass
            new_lines.append(thisText)
            if i == 0:
                try:
                    (checkPos, new_lines[0]) = new_lines[0].split("|", 1)
                    checkPos = int(checkPos) - 1
                except:
                    checkPos = -1
            if i == checkPos or checkPos == -1:
                if checkPos == -1 or not new_lines[i].endswith("-pw"): ##check to see if decode successful
                    getConfirmation("Check password, file could not be loaded!", True)
                    return (False, False)
                (new_lines[i], lineEnding) = new_lines[i].rsplit("|", 1)
                extension = lineEnding[0:-3]
        if extension == ".pwe": extension = ".???"
        return (new_lines, extension)
    except:
        getConfirmation("Error, load failed during decoding!", True)

def confirmEncryption():
    """Displays encryption warning/confirmation"""
    win = curses.newwin(HEIGHT, WIDTH, 0,0) # 0,0 is start position
    x = int((WIDTH - 49)/2)
    y = int((HEIGHT -14)/2)
    c = 0
    empty = ("").center(49)
    seperator = ("").center(49,"@")
    textlist = ["","ENCRYPTION" , "" , "It is highly recommended that you save" , "a non-encrypted version of your file before" , "proceeding. If you forget your password or" , "something goes wrong during the encryption" , "process, your file will NOT be recoverable." , "" , "No guarantees are made to the strength of " , "the encryption, USE AT YOUR OWN RISK!" , "" , "Continue? (y/n)",""]
    for i in range(0, len(textlist)):
        item = textlist[i]
        centered = item.center(49)
        stdscr.addstr(y+i,x, centered, settings["color_warning"])
        stdscr.refresh()
    while (1):
        c = stdscr.getch()
        if c in (ord("y"), ord("Y")):
            for i in range(0,len(textlist)): stdscr.addstr(y+i,x,empty, settings["color_normal"])
            return True
        elif c in (ord("n"), ord("N")):
            return False

def toggleSyntax(mytext):
    """Toggle syntax hilighting"""
    global program_message
    program_message = " Syntax hilighting turned off "
    if "off" in mytext or "hide" in mytext:
        settings["syntax_hilighting"] = False
    elif mytext == "syntax" and settings["syntax_hilighting"]:
        settings["syntax_hilighting"] = False
    else:
        settings["syntax_hilighting"] = True
        for lineNum in line.db.values():
            lineNum.addSyntax()
            i = lineNum.number
            if len(line.db)+1 > 800 and i/10.0 == int(i/10.0): ##display status message
                statusMessage("Adding syntax: ", (100/((len(line.db)+1) * 1.0/(i+1))))
        program_message = " Syntax hilighting turned on "
    if reset_needed: resetLine()

def toggleWhitespace(mytext):
    """Toggle visible whitespace"""
    global program_message
    program_message = " Visible whitespace turned off "
    if "off" in mytext or "hide" in mytext:
        settings["showSpaces"] = False
    elif mytext == "whitespace" and settings["showSpaces"]:
        settings["showSpaces"] = False
    else:
        settings["showSpaces"] = True
        toggleSyntax("syntax on") #update syntax to include whitespace
        program_message = " Visible whitespace turned on "
    if reset_needed: resetLine()

def toggleTabs(mytext):
    """Toggle visible tabs"""
    global program_message
    program_message = " Visible tabs turned off "
    if "off" in mytext or "hide" in mytext:
        settings["show_indent"] = False
    elif mytext in ["tab","tabs"] and settings["show_indent"]:
        settings["show_indent"] = False
    else:
        settings["show_indent"] = True
        toggleSyntax("syntax on") #update syntax to include tabs
        program_message = " Visible tabs turned on "
    if reset_needed: resetLine()

def toggleLive(mytext):
    """Toggle syntax hilighting on entry line"""
    global program_message
    program_message = " Live syntax turned off "
    if "off" in mytext or "hide" in mytext:
        settings["live_syntax"] = False
    elif mytext == "live" and settings["live_syntax"]:
        settings["live_syntax"] = False
    else:
        settings["live_syntax"] = True
        program_message = " Live syntax turned on "
    if reset_needed: resetLine()

def toggleAuto(mytext):
    """Toggle feature automation (turns on features based on file type)"""
    global program_message
    program_message = " Auto-settings turned off "
    if "off" in mytext:
        settings["auto"] = False
    elif mytext == "auto" and settings["auto"]:
        settings["auto"] = False
    else:
        settings["auto"] = True
        program_message = " Auto-settings turned on "
    if reset_needed: resetLine()

def toggleEntry(mytext):
    """Toggle entry hilighting (colorizes entry line)"""
    global program_message
    program_message = " Entry hilighting turned off "
    if "off" in mytext or "hide" in mytext:
        settings["entry_hilighting"] = False
    elif mytext == "entry" and settings["entry_hilighting"]:
        settings["entry_hilighting"] = False
    else:
        settings["entry_hilighting"] = True
        program_message = " Entry hilighting turned on "
    if reset_needed: resetLine()

def toggleCommentFormatting(mytext):
    """Toggle comment formatting (formats/colorizes comments)"""
    global program_message
    program_message = " Comment formatting turned off "
    if "off" in mytext or "hide" in mytext:
        settings["format_comments"] = False
    elif mytext == "formatting" and settings["format_comments"]:
        settings["format_comments"] = False
    else:
        settings["format_comments"] = True
        program_message = " Comment formatting turned on "
    if reset_needed: resetLine()
    syntaxVisible()
    if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()

def togglePageGuide(mytext):
    """Toggle page guide (shows page guide)
        Default width of page is 80 characters."""
    global program_message
    program_message = " Page guide turned off "
    if "off" in mytext or "hide" in mytext:
        settings["page_guide"] = False
    elif mytext in ["guide", "pageguide"] and settings["page_guide"]:
        settings["page_guide"] = False
    elif getArgs(mytext) not in ["guide", "pageguide"] and "show" not in mytext and "on" not in mytext:
        try:
            num = int(getArgs(mytext))
            if num < 1: num = 80
            settings["page_guide"] = num
            program_message = " Page guide - %i characters " %num
        except:
            program_message = " Error occured, nothing changed! "
            if reset_needed: resetLine()
            return
    else:
        settings["page_guide"] = 80
        program_message = " Page guide turned on "
    if settings["page_guide"] > WIDTH - 7:
        if WIDTH > 59: program_message = " Error, terminal too small for %i character page guide! " %settings["page_guide"]
        else: program_message = " Error, page guide not displayed "
        settings["page_guide"] = False
    if reset_needed: resetLine()

def showHelp():
    """Display help guide"""
    global HELP_GUIDE, currentNum, saved_since_edit
    oversized = False

    try:
        if line.db:
            del line.db
            line.db = {}
    except:
        pass
    currentNum = 0
    total_rows = 0
    for i in range(0, len(HELP_GUIDE)):
        mytext = HELP_GUIDE[i]

        l = line(mytext)

        total_rows += (l.number_of_rows - 1)
        if l.number <= (HEIGHT -2) and currentNum + total_rows < (HEIGHT - 2): currentNum += 1

    currentNum -= 1
    copySettings()
    settings["debug"] = False
    settings["show_indent"] = False
    settings["entry_hilighting"] = False
    settings["syntax_hilighting"] = True
    settings["format_comments"] = True
    settings["live_syntax"] = True
    settings["showSpaces"] = False
    settings["splitscreen"] = False
    line.locked = True
    status["help"] = True
    saved_since_edit = True
    if WIDTH > 80: settings["page_guide"] = 72
    else: settings["page_guide"] = False

def showHide(mytext):
    """Allows show and hide commands to change settings"""
    global program_message
    if "show" in mytext: myflag = True
    else: myflag = False
    myitem = mytext.split(" ", 1)[1]
    temptext = ""
    if myitem == "syntax":
        settings["syntax_hilighting"] = myflag
        temptext = "Syntax highlighting"
    elif myitem in ("spaces","whitespace"):
        settings["showSpaces"] = myflag
        temptext = "Whitespace"
    elif myitem in ("tabs","tab stops","indent","indentation"):
        settings["show_indent"] = myflag
        temptext = "Visible tabs"
    elif myitem in ("entry", "entry line"):
        settings["entry_hilighting"] = myflag
        temptext = "Entry line highlighting"
    elif myitem in ("live", "live syntax"):
        settings["live_syntax"] = myflag
        temptext = "Live syntax"
    elif myitem in ("debug","bugs","debug mode"):
        settings["debug"] = myflag
        temptext = "Debug mode"
    elif myitem in ("formatting","comment formatting"):
        settings["format_comments"] = myflag
        temptext = "Comment formatting"
    elif myitem in ("split","splitscreen", "split screen"):
        settings["splitscreen"] = myflag
        temptext = "Splitscreen"
    elif myitem in ("guide", "pageguide"):
        settings["page_guide"] = myflag
        if settings["page_guide"] == True:
            settings["page_guide"] = 80

        if settings["page_guide"] > WIDTH - 7:
            settings["page_guide"] = False
            if WIDTH > 59: program_message = " Error, terminal too small for 80 character page guide! "
            else: program_message = " Error, page guide not displayed "
            if reset_needed: resetLine()
            return
        else:
            temptext = "Page guide"
    else:
        temptext = "Error, nothing"

    if myflag: program_message = " %s turned on " %temptext
    else: program_message = " %s turned off " %temptext

    if reset_needed: resetLine()
    if settings["syntax_hilighting"]: syntaxVisible()
    if settings["splitscreen"] and settings["syntax_hilighting"]: syntaxSplitscreen()
    if settings["debug"]: debugVisible()

def loadCommand(mytext):
    """Pre-processes load command"""
    if reset_needed: resetLine()
    if " " in mytext and len(mytext) > 5:
        if mytext[:4] == "read": readState = True
        else: readState = False
        load(mytext[5:], readState)
    else:
        if mytext[:4] == "read": readState = True
        else: readState = False
        if savepath: loadfile = displayList(savepath)
        else:
            tempPath = str(os.getcwd()+"/")
            loadfile = displayList(tempPath)
        if loadfile:
            if saved_since_edit:
                load(loadfile, readState)
            elif line.total < 2 and not savepath:
                load(loadfile, readState)
            elif getConfirmation("Load file without saving old? (y/n)"):
                load(loadfile, readState)

def cut(mytext):
    """Combines copy and delete into one operation"""
    global program_message
    if reset_needed: resetLine()
    if mytext.endswith("cut"):
        if getConfirmation("Cut selection? (y/n)"):
            cut(selectItems("cut"))
            return
        else:
            program_message = " Cut aborted! "
            return
    tempText = mytext.replace("cut", "copy")
    copy(tempText)
    printHeader()
    deleteLines(tempText.replace("copy","delete"))

def functionHelp(mytext):
    """Get info about classes, functions, and Modules

            Works with both external modules and
            functions/classes defined within program"""
    global program_message
    if reset_needed: resetLine()
    if WIDTH < 79: getConfirmation("Help truncated to fit screen", True)
    findDef = "def " + mytext[5:]
    findClass = "class " + mytext[5:]
    searchString = mytext[5:]
    if '.' in searchString: myname = "." + searchString.split('.',1)[1]
    else: myname = "foobar_zyx123"
    count = 0
    functionNum = 0
    docString = []
    mytype = ""
    c = 0
    for i in range(1, len(line.db)+1):
        itemText = line.db[i].text[line.db[i].indentation:]
        if itemText.startswith(findDef+"(") or itemText.startswith(findDef+" (") or itemText.startswith(findClass+"(") or itemText.startswith(findClass+" ("):
            functionNum = i
            mytype = itemText[0:4]
            if mytype == "def ": mytype = "FUNCTION"
            if mytype == "clas": mytype = "CLASS"
            definition = line.db[i].text
            myname = itemText.split(" ", 1)[1]
            if "(" in myname: myname = myname.split("(")[0]
            temp = line.db[i].text.replace(':','')
            if mytype == "FUNCTION": temp = temp.replace("def ", "")

            docString.append(temp)
            if line.db[i+1].text.strip().startswith('"""'):
                start = i+1
                for n in range(start, len(line.db)+1):
                    temp = line.db[n].text.replace('"""','')
                    docString.append(temp)
                    if line.db[n].text.endswith('"""'): break

        elif searchString in itemText or myname in itemText:
            if not itemText.startswith("import") and not itemText.startswith("from"):
                count += 1
    if not docString:
        mytype = "MODULE"
        if itemText:
            myname = itemText.split(" ", 1)[1]
        else:
            myname = searchString

        shortname = myname
        tempList = getInfo(searchString, getModules() )
        for item in tempList: docString.append(item)

    if docString:
        if docString[-1].strip() == "": del docString[-1] ##delete last item if blank
        stdscr.addstr(0, 0, (" " * (WIDTH)), settings["color_header"])
        stdscr.addstr(0, 0, ( " %s " %(myname) ), settings["color_message"])
        stdscr.addstr(0, WIDTH - 11, ("Used: %i" %count).rjust(10), settings["color_header"])
        stdscr.hline(1, 0, curses.ACS_HLINE, WIDTH, settings["color_bar"])

        start = 0
        while True:
            y = 1
            end = min( (start+(HEIGHT-3)), len(docString) )
            if end < 1: end = 1
            for l in range(start, end):
                docString[l] = docString[l].rstrip()
                y += 1
                stdscr.addstr(y, 0, (" " * (WIDTH)), settings["color_background"])
                if len(docString[l]) > WIDTH:
                    stdscr.addstr(y, 0, docString[l][0:WIDTH], settings["color_quote_double"])
                else:
                    stdscr.addstr(y, 0, docString[l], settings["color_quote_double"])
            if len(docString) < (HEIGHT - 2):
                stdscr.hline(end+2, 0, curses.ACS_HLINE,WIDTH, settings["color_bar"])
                stdscr.addstr(end+2, WIDTH, "") #move cursor

            else:
                stdscr.hline(HEIGHT-1, 0, curses.ACS_HLINE,WIDTH, settings["color_bar"])
                string = " _Start | _End | Navigate with ARROW keys"
                stdscr.addstr(HEIGHT, 0, (" " * (WIDTH)), settings["color_header"]) #footer
                printFormattedText(HEIGHT, string)
                printFormattedText(HEIGHT, '| _Quit ','rjust',WIDTH)
            stdscr.refresh()
            c = stdscr.getch()
            if c == ord('q'): break
            elif len(docString) < (HEIGHT - 4) and c != 0: ##Exit on key press if help is less than a page
                break

            elif c in (ord('s'), ord('S')): start = 0
            elif c in (ord('e'), ord('E')): start = len(docString) - (HEIGHT - 3)
            elif c == curses.KEY_DOWN: start += 1
            elif c == curses.KEY_UP: start -= 1
            elif c == curses.KEY_LEFT or c == ord('b'): start -= (HEIGHT - 3)
            elif c == curses.KEY_RIGHT or c == 32: start += (HEIGHT - 3)

            start = min(start, len(docString) - (HEIGHT - 3) )
            if len(docString) < (HEIGHT - 3): start = 0
            if start < 0: start = 0

    if not docString: program_message = " Help for '%s' not available! " %searchString

def getInfo(thisItem, moduleList = ['os','sys','random']):
    """Get info about python modules"""
    importString = ""
    for item in moduleList:
        importString += str("import %s; " %item)

    p = os.popen("python -c '%s help(%s)'" %(importString, thisItem))

    helpList = p.readlines()
    p.close()
    return helpList

def getModules():
    """Finds modules in current document"""
    moduleList = []
    for i in range (1, len(line.db)+1):
        mytext = line.db[i].text
        mytext = mytext.strip()
        if mytext.startswith("import ") or mytext.startswith("from "):
            mytext = mytext.replace("import ","")
            mytext = mytext.replace("from ","")
            if ';' in mytext:
                for item in mytext.split(";"):
                    if " " in item and item.startswith(" "): module = item.split(" ")[1]
                    elif " " in item: module = item.split(" ")[0]
                    else: module = item.replace(" ","")
                    moduleList.append(module)
            elif ',' in mytext:
                for item in mytext.split(","):
                    if " " in item and item.startswith(" "): module = item.split(" ")[1]
                    elif " " in item: module = item.split(" ")[0]
                    else: module = item.replace(" ","")
                    moduleList.append(module)
            elif " " in mytext:
                module = mytext.split(" ")[0]
                moduleList.append(module)
            else:
                module = mytext
                moduleList.append(module)
    if not moduleList: moduleList = ['__builtin__']
    return moduleList

def copySettings(reverse = False):
    """Makes a backup copy of current settings

            If optional arg reverse is set to 'True',
            settings is copied from backup"""
    global settings, backupSettings
    if reverse: settings = deepcopy(backupSettings)
    else: backupSettings = deepcopy(settings)

def findWindow():
    """Opens Find window"""
    global program_message
    findThis = promptUser("Find what item?")
    if findThis:
        if line.locked: ##In read only mode, find & mark join forces
            for i in range(1, len(line.db)+1):
                line.db[i].marked = False
            mark( "mark %s" %str(findThis) )
        find( "find %s" %str(findThis) )
    else:
        program_message = " Aborted search "

def quit(confirmNeeded = True, message = ""):
    """Gracefully exits program"""
    global breakNow
    breakNow = True
    if not saved_since_edit and confirmNeeded and not getConfirmation(" Quit without saving? (y/n) "): return
    curses.nocbreak(); stdscr.keypad(0); curses.echo() # to turn off curses settings
    curses.endwin(); #restore terminal to original condition
    if message: print message

def markItems(mytype):
    """Returns string of marked lines.
            Type of command to be executed must be passed

            example: markItems("copy")
    """
    markstring = ""
    word1 = mytype.capitalize()
    if getConfirmation("%s ALL marked lines? (y/n)" %word1):
        for i in range (1, len(line.db)+1):
            if line.db[i].marked:
                num = line.db[i].number
                markstring += "%i," %num
        if markstring.endswith(","): markstring = markstring[0:-1]
        return("%s %s" %(mytype, markstring))

def selectItems(mytype):
    """Returns string of selected lines.
            Type of command to be executed must be passed

            example: selectItems("copy")
    """
    selectstring = ""
    word1 = mytype.capitalize()
    for i in range (1, len(line.db)+1):
        if line.db[i].selected:
            num = line.db[i].number
            selectstring += "%i," %num
    if selectstring.endswith(","): selectstring = selectstring[0:-1]
    return("%s %s" %(mytype, selectstring))

def cursesOff():
    """Turns off curses and resets terminal to normal"""
    curses.nocbreak(); stdscr.keypad(0); curses.echo() # to turn off curses settings
    curses.endwin(); #restore terminal to original condition

def encodingReadable(the_path):
    """Check file encoding to see if it can be read by program"""
    if not os.access(the_path, os.R_OK): ##return if file not accesible
        getConfirmation("Access not allowed!", True)
        return False
    rawsize = os.path.getsize(the_path)/1024.00 #get size and convert to kilobytes
    if rawsize > 8000:
        if getConfirmation("File may not be readable. Continue? (y/n)"):
            return True
        else:
            return False

    myfile = open(the_path)
    temp_lines = myfile.readlines()
    myfile.close()

    try:
        stdscr.addstr(0, 0, temp_lines[-1][0:WIDTH],settings["color_header"])  #Tests output
        if len(temp_lines) > 100:
            stdscr.addstr(0, 0, temp_lines[-100][0:WIDTH],settings["color_header"])  #Tests output
        stdscr.addstr(0, 0, (" " * WIDTH))  #clears line
    except:
        getConfirmation("Error, can't read file encoding!", True)
        return False

    skip = int(len(temp_lines)/10)+1

    for i in range (0, len(temp_lines), skip):
        string = temp_lines[i]
        string = string.replace("\t","    ")
        string = string.replace("    ","    ")
        string = string.replace("\n","")
        string = string.replace("\r","")
        string = string.replace("\f", "") #form feed character, apparently used as seperator?

        try:
            stdscr.addstr(0, 0, string[0:WIDTH],settings["color_header"])  #Tests output
            stdscr.addstr(0, 0, (" " * WIDTH),settings["color_header"])  #clears line
        except:
            getConfirmation("Error, can't read file encoding!", True)
            return False
    return True

def invertSelection():
    """Inverts/reverses current selection"""
    if reset_needed: resetLine()
    count = 0
    selected_lines = ""
    for i in range (1, len(line.db)+1):
        item = line.db[i]
        if item.selected:
            count += 1
        else:
            if selected_lines != "": selected_lines += ", "
            selected_lines += str(i)
    if count == line.total: deselect_all()
    elif count == 0: select("select all")
    else: select("select %s" %selected_lines)

def drawPageGuide(end_pos = (HEIGHT + 1), hline_pos = 1):
    """Draws page guide"""
    if WIDTH <= (settings["page_guide"] + 6): return

    for i in range(2, end_pos):
        stdscr.vline(i, (settings["page_guide"] + 6), curses.ACS_VLINE, (1), settings["color_bar"]) #prints vertical line
    stdscr.hline(1, (settings["page_guide"]+6), curses.ACS_TTEE,(1), settings["color_bar"])

def getSelected():
    """Returns lines selected as text string, and the count

            ex: "4, 10, 20"
    """
    selected_lines = ""
    count = 0
    for i in range (1, len(line.db)+1):
        item = line.db[i]
        if item.selected:
            if selected_lines != "": selected_lines += ","
            selected_lines += str(i)
            count += 1
    if selected_lines:
        return selected_lines, count
    else:
        return False, 0

def printCommand():
    """New method to print executable commands"""
    if not line.db[currentNum].executable: return
    if len(line.db[currentNum].text) >= WIDTH - 6:
        stdscr.addstr((HEIGHT - 2) - line.db[currentNum].number_of_rows + 1, 6, line.db[currentNum].text.split()[0], settings["color_warning"])  #Prints command only if line oversized
    else:
        stdscr.addstr(HEIGHT - 2, 6, line.db[currentNum].text, settings["color_warning"])  #Prints entire line

def numLeftOf(mytext, position):
    """Function to compare position of number with other character"""
    flag = True
    if "[" not in mytext and "(" not in mytext and ":" not in mytext and "," not in mytext and ";" not in mytext and "=" not in mytext and "+" not in mytext and "-" not in mytext and "*" not in mytext and "/" not in mytext and "%" not in mytext: return False
    for char in ("[(:,;+-*/%="):
        if char in mytext:
            char_pos = mytext.rfind(char)
            if position <= char_pos:
                flag = False
                continue
            flag = True
            for i in range(char_pos, position):
                if mytext[i].isalpha(): flag = False
    return flag

def pageUp():
    """program specific function that moves up one page"""
    global currentNum, program_message, saved_since_edit, continue_down, continue_up, continue_left, continue_right

    program_message = ""
    continue_down = 0; continue_left = 0; continue_right = 0; continue_up = 0

    if settings["syntax_hilighting"]: line.db[currentNum].addSyntax() ##update syntax BEFORE leaving line
    currentNum = max((currentNum - (HEIGHT - 1)), 1)

def pageDown():
    """program specific function that moves down one page"""
    global currentNum, program_message, saved_since_edit, continue_down, continue_up, continue_left, continue_right

    program_message = ""
    continue_down = 0; continue_left = 0; continue_right = 0; continue_up = 0

    if settings["syntax_hilighting"]: line.db[currentNum].addSyntax() ##update syntax BEFORE leaving line
    currentNum = min((currentNum + (HEIGHT - 1)), line.total)

def invertMonochrome():
    """Inverts monochrome display"""
    settings["mono_bold"] = 2359296
    settings["mono_normal"] = 262144
    settings["mono_reverse"] = 0
    settings["mono_reverse_bold"] = 2097152
    settings["mono_reverse_underline"] = 131072
    settings["mono_underline"] = 393216

def consecutiveNumbers(num_list): ## Fixes delete bug with non-consecutive selection over 100 lines!
    """Returns true if list of numbers is consecutive"""
    num_list.sort()
    if len(num_list) == 1: return True
    for i in range(0, len(num_list)):
        if i != 0 and num_list[i] - num_list[i-1] != 1: return False
    return True

def readModeEntryWindow():
    """Enter commands in 'Entry Window'"""
    global reset_needed, program_message
    program_message = ""
    reset_needed = False
    mytext = promptUser()
    if commandMatch(mytext, "load","read", False):
        line.locked = False
        loadCommand(mytext)
    elif commandMatch(mytext, "new","<@>_foobar_", False): newDoc()

    elif commandMatch(mytext, "find","mark", False):
        for i in range(1, len(line.db)+1):
            line.db[i].marked = False
        mark(mytext)
        find(mytext)

    elif mytext in ("unmark all", "unmark off"): unmark_all()
    elif commandMatch(mytext, "unmark","<@>_foobar_", False): unmark(mytext)
    elif commandMatch(mytext, "goto","<@>_foobar_", False): goto(mytext)
    elif commandMatch(mytext, "quit","<@>_foobar_", False): quit()
    elif commandMatch(mytext, "split", "splitscreen"): toggleSplitscreen(mytext) ##toggle splitscreen
    elif commandMatch(mytext, "show split", "hide split"): toggleSplitscreen(mytext)
    elif commandMatch(mytext, "show splitscreen", "hide splitscreen"): toggleSplitscreen(mytext)
    elif mytext == "help":
        if getConfirmation("Load HELP GUIDE? Current doc will be purged! (y/n)"): showHelp()
    elif commandMatch(mytext, "prev","previous", False): prev()
    else:
        getConfirmation("That command not allowed in read mode!", True)

def saveas(the_path):
    """Forces open 'saveas' dialog and then saves file"""
    global program_message
    if reset_needed: resetLine()
    if not the_path: the_path = ""
    if savepath:
        part1 = os.path.split(savepath)[0]
        part2 = the_path
        the_path = part1 + "/" + part2
    if "/" not in the_path: the_path = (os.getcwd() + "/" + the_path)
    saveas_path = promptUser("SAVE FILE AS:", the_path, "(press 'enter' to proceed, UP arrow to cancel)", True)
    if saveas_path: save(saveas_path)
    else: program_message = " Save aborted! "

########################################################~#
######################### MAIN ##########################
########################################################~#

##Test terminal size
if HEIGHT < 14 or WIDTH < 49:
    quit(False, "ERROR: Warrior-IDE could not be launched, minimum terminal size of 50 x 15 required")
    sys.exit()
##set defaults
defaultSettings()
##load settings
if not loadSettings():
    saveSettings() #create settings file if one does not exist

#check for command line arguments
args = sys.argv
setMode = False
setColor = False
helpFlag = False
setProtectString = False
read_only = False
no_bold = False

if "-" not in args[-1] and len(args) > 1 and not args[-1].startswith("["): #check for file name/path
    mypath = args[-1]
    if "/" not in mypath: mypath = os.path.abspath(mypath)
else:
    mypath = False

if mypath and args and len(args) >= 2 and "s" in args[-2] and args[-2].startswith("-") and not args[-2].startswith("--"): mypath = False

if mypath and not os.path.exists(mypath):
    mypath = False #New bit to stop program from crashing when path is bad
    program_message = " Error, file could not be loaded! "

##check for flags
flaglist = []
for item in args:
    if item.startswith("-") and not item.startswith("--"):
        for letter in item:
            if letter != "-":
                flaglist.append(letter)
# check for help flag
if "h" in flaglist or "--help" in args:
    helpFlag = True
# set mode and color
if "t" in flaglist or "--text" in args:
    setMode = "text"
elif "p" in flaglist or "--python" in args:
    setMode = "python"
if "c" in flaglist or "--color" in args:
    setColor = "color"
elif "m" in flaglist or "--mono" in args:
    setColor = "monochrome"
elif "i" in flaglist or "--inverted" in args:
    setColor = "inverted"
if "r" in flaglist or "--read" in args:
    read_only = True
if "n" in flaglist or "--nobold" in args:
    no_bold = True

###FOR EDITING PURPOSES ONLY, REMOVE WHEN DONE!!!
if "--source" in args and not mypath: mypath = args[0]  # warrior-ide opens copy of itself for editing

if "s" in flaglist or "--string" in args:  # set protect string
    if "--string" in args:
        pos = args.index("--string")
        if mypath and len(args) >= 2 and "s" in args[-2] and args[-2] == "--string": mypath = False
    else:
        if mypath and len(args) >= 2 and "s" in args[-2] and args[-2].startswith("-"): mypath = False
        for i in range(0, len(args)):
            item = args[i]
            if item.startswith("-") and not item.startswith("--") and 's' in item: pos = i
    flag_error = """ERROR:\nArgument required by string flag (maximum size 4 characters)\nExample: Warrior-IDE -s '::' myfile.txt\n"""
    try:
        setProtectString = args[pos+1]
        #next part was modified to safeguard against pathname becoming protect string
        if len(setProtectString) < 5:
            settings["inline_commands"] = "protected" #set to "protected" to protect commands with protect string
            settings["protect_string"] = setProtectString
        else:
            cursesOff()
            print flag_error
            sys.exit()
    except:
        cursesOff(); print flag_error; sys.exit()

if no_bold:
    defaultSettings(False, False)

if setMode == "text":
    settings["entry_hilighting"] = False
    settings["syntax_hilighting"] = False
    settings["live_syntax"] = False
    settings["debug"] = False
    settings["collapse_functions"] = False
    settings["showSpaces"] = False
    settings["show_indent"] = False
    settings["inline_commands"] = "protected" #set to "protected" to protect commands with protect string
    settings["format_comments"] = True
    if setProtectString: settings["protect_string"] = setProtectString
elif setMode == "python":
    settings["entry_hilighting"] = True
    settings["syntax_hilighting"] = True
    settings["live_syntax"] = True
    settings["debug"] = True
    settings["show_indent"] = True
    if not settings["inline_commands"]: settings["inline_commands"] = True #set to "protected" to protect commands with protect string
    settings["format_comments"] = True

if setColor == "color":
    settings["display_color"] = True
    settings["default_colors"] = True
elif setColor == "monochrome":
    settings["display_color"] = False
    defaultSettings(True, True)
elif setColor == "inverted":
    settings["display_color"] = False
    invertMonochrome()
    defaultSettings(True, True)

##Turn on color
if settings["display_color"] and settings["default_colors"]: color_on(True) #default colors
elif settings["display_color"]: color_on() #user defined colors
##Clear screen and draw bar
if settings["color_background"]: printBackground()
stdscr.hline(1,0,curses.ACS_HLINE,WIDTH, settings["color_bar"])
##Adjust page guide if neccesary
if settings["page_guide"] > WIDTH - 7:
    settings["page_guide"] = False
##Load file or create new doc
line.db = {} ##create new doc (moved to fix bug)
l = line("")
currentNum = 1
savepath = ""
saved_since_edit = True

if helpFlag:
    showHelp()
    setMode = False
elif mypath: ##load file if path exists
    ##print 'splash screen' while loading
    stdscr.clear()
    stdscr.hline(1,0,curses.ACS_HLINE,WIDTH, settings["color_bar"])
    stdscr.addstr(int(HEIGHT/2) - 1, int(WIDTH/2) - 11,"                       ", settings["color_message"])
    stdscr.addstr(int(HEIGHT/2), int(WIDTH/2) - 11,"    warrior-ide  0.01    ", settings["color_message"])
    stdscr.addstr(int(HEIGHT/2) + 1, int(WIDTH/2) - 11,"                       ", settings["color_message"])
    if read_only: ##load read only file
        load(mypath, True)
    else: ##load file for editing
        load(mypath)

if not helpFlag and not line.locked: currentNum = line.total
current_line = line.db[currentNum]
undo_text_que = []
undo_state_que = []
undo_mark_que = []
undo_state = []
undo_mark = []
undo_list = []
text_entered = False
last_search = ""
reset_needed = False
startRow = 0

update_que()

indentLevel = 0
c = 0

##Begin Main Loop
while (1):
    try:

        if breakNow: break ##exit main loop, exit program
        current_line = line.db[currentNum]
        stdscr.clear()
        if settings["color_background"]: printBackground()
        if settings["color_line_numbers"]: draw_lineNumber_background()
        if line.locked: program_message = " READ ONLY MODE. Press 'q' to quit. "
        printHeader()
        if settings["page_guide"] and WIDTH > (settings["page_guide"] + 6): drawPageGuide()
        printCurrentLine()
        printPreviousLines()
        printNextLine()
        if settings["inline_commands"] and settings["hilight_commands"] and current_line.executable: printCommand()

        if settings["inline_commands"] == "protected": ##set protect variables
            pr_str = str(settings["protect_string"])
            pr_len = len(pr_str)
        else:
            pr_str = ""
            pr_len = 0

        if settings["splitscreen"]: splitScreen()

        if settings["debug"] and current_line.error and not program_message: #Print error messages
            stdscr.addstr(0, 0," " * (WIDTH - 13), settings["color_header"])
            stdscr.addstr(0, 0, " ERROR: %s " %(current_line.error), settings["color_warning"])

        ##Debugging
        #stdscr.addstr(0, 0, " KEYPRESS: %i              " %(c), settings["color_warning"])
        #if c == ord("\\"): print non_existant_variable ##force program to crash

        # Moves cursor to correct location
        if line.locked:
            stdscr.addstr(HEIGHT, WIDTH, "", settings["color_normal"]) # moves cursor
        elif current_line.number_of_rows > HEIGHT - 4:
            stdscr.addstr(HEIGHT-2, current_line.x, "", settings["color_normal"]) # moves cursor
        else:
            stdscr.addstr(current_line.y + HEIGHT-2, current_line.x, "", settings["color_normal"]) # moves cursor

        stdscr.refresh()

        # Get key presses
        c = stdscr.getch()

        if line.locked and c == 10: c = curses.KEY_DOWN ##Convert 'enter' to down arrow if document is 'locked'
        elif line.locked and  c in (ord('q'),ord('Q')) and getConfirmation("Close current document? (y/n)"):
            copySettings(True)
            newDoc()
            continue
        elif line.locked and c == ord('s'): currentNum = 1
        elif line.locked and c == ord('e'): currentNum = line.total

        reset_needed = True ##Trying to fix bug where commands aren't properly cleared
        if c == 10 and commandMatch(current_line.text, "collapse off", "expand all"):
            current_line.text = ""
            current_line.addSyntax()
            #settings["collapse_functions"] = False
            expandAll()
            if reset_needed: resetLine()

        elif c == 10 and commandMatch(current_line.text, "expand marked"): expand(markItems("expand"))
        elif c == 10 and commandMatch(current_line.text, "expand selected", "expand selection"): expand(selectItems("expand"))
        elif c == 10 and commandMatch(current_line.text, "expand"): expand(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "collapse marked"): collapse(markItems("collapse"))
        elif c == 10 and commandMatch(current_line.text, "collapse selected", "collapse selection"): collapse(selectItems("collapse"))
        elif c == 10 and commandMatch(current_line.text, "collapse all"): collapse("collapse 1 - %s" %str(len(line.db)))
        elif c == 10 and commandMatch(current_line.text, "collapse"): collapse(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "quit"):
            if reset_needed: resetLine()
            if not saved_since_edit and getConfirmation(" Quit without saving? (y/n) "): quit(False)
            elif saved_since_edit: quit(False)
        elif c == 10 and current_line.length - pr_len > 5 and commandMatch(current_line.text,"save"): #save w/ new name
            tempPath = current_line.text[5:]
            if reset_needed: resetLine()
            save(tempPath)
        elif c == 10 and commandMatch(current_line.text,"save"): #save (write over) current file
            if reset_needed: resetLine()
            save(savepath)
        elif c == 10 and commandMatch(current_line.text, "saveas"):
            if current_line.length - pr_len > 7: tempPath = current_line.text[7:]
            elif not savepath: tempPath = False
            else:
                (fullpath, filename) = os.path.split(savepath)
                tempPath = filename
            saveas(tempPath)

        elif c == 10 and commandMatch(current_line.text, "split", "splitscreen"): toggleSplitscreen(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "show", "hide"): showHide(current_line.text)

        elif c == 10 and commandMatch(current_line.text, "syntax"): toggleSyntax(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "show syntax", "hide syntax"): toggleSyntax(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "whitespace"): toggleWhitespace(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "show whitespace", "hide whitespace"): toggleWhitespace(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "tabs", "tab"): toggleTabs(current_line.text)

        elif c == 10 and commandMatch(current_line.text, "find"):
            reset_needed = True #Trying to fix intermittant bug where find doesn't clear line
            find(current_line.text)

        elif c == 10 and commandMatch(current_line.text, "mark"): mark(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "unmark all", "unmark off"): unmark_all() # unmarks all lines
        elif c == 10 and commandMatch(current_line.text, "unmark"): unmark(current_line.text)

        elif c == 10 and commandMatch(current_line.text, "deselect all", "unselect all"):
            if reset_needed: resetLine()
            deselect_all() # deselects all lines
        elif c == 10 and commandMatch(current_line.text, "select off", "select none"):
            deselect_all() # deselects all lines
            if reset_needed: resetLine()
        elif c == 10 and commandMatch(current_line.text, "deselect"):
            deselect(current_line.text)
            if reset_needed: resetLine()
        elif c == 10 and commandMatch(current_line.text, "select reverse", "select invert"): invertSelection()
        elif c == 10 and commandMatch(current_line.text, "invert", "invert selection"): invertSelection()
        elif c == 10 and commandMatch(current_line.text, "select up"): selectup(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "select down"): selectdown(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "select"): select(current_line.text)

        elif c == 10  and commandMatch(current_line.text, "goto"): goto(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "comment marked"): comment(markItems("comment"))
        elif c == 10 and commandMatch(current_line.text, "comment selected", "comment selection"): comment(selectItems("comment"))
        elif c == 10 and commandMatch(current_line.text, "comment"): comment(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "uncomment marked"): uncomment(markItems("uncomment"))
        elif c == 10 and commandMatch(current_line.text, "uncomment selected", "uncomment selection"): uncomment(selectItems("uncomment"))
        elif c == 10 and commandMatch(current_line.text, "uncomment"): uncomment(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "indent marked"): indent(markItems("indent"))
        elif c == 10 and commandMatch(current_line.text, "indent selected", "indent selection"): indent(selectItems("indent"))
        elif c == 10 and commandMatch(current_line.text, "indent"): indent(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "unindent marked"): unindent(markItems("unindent"))
        elif c == 10 and commandMatch(current_line.text, "unindent selected", "unindent selection"): unindent(selectItems("unindent"))
        elif c == 10 and commandMatch(current_line.text, "unindent"): unindent(current_line.text)

        elif c == 10 and commandMatch(current_line.text, "load","read"): loadCommand(current_line.text)

        elif c == 10 and commandMatch(current_line.text, "run"):
            if reset_needed: resetLine()
            run()

        elif c == 10 and commandMatch(current_line.text, "color on"):
            color_on()
        elif c == 10 and commandMatch(current_line.text, "color default", "color defaults"): defaultColors()

        elif c == 10 and commandMatch(current_line.text, "replace"): replaceText(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "copy marked"): copy(markItems("copy"))
        elif c == 10 and commandMatch(current_line.text, "copy selected","copy selection"): copy(selectItems("copy"),True)
        elif c == 10 and commandMatch(current_line.text, "copy"): copy(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "paste"): paste(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "undo"): undo()
        elif c == 10 and commandMatch(current_line.text, "delete marked"): deleteLines(markItems("delete"))
        elif c == 10 and commandMatch(current_line.text, "delete selected","delete selection"): deleteLines(selectItems("delete"))
        elif c == 10 and commandMatch(current_line.text, "delete"): deleteLines(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "revert"): revert()
        elif c == 10 and commandMatch(current_line.text, "new"): newDoc()
        elif c == 10 and commandMatch(current_line.text, "cut selected", "cut selection"): cut(selectItems("cut"))
        elif c == 10 and commandMatch(current_line.text, "cut"): cut(current_line.text)

        elif c == 10 and commandMatch(current_line.text, "protect"): toggleProtection(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "commands off"):
            if reset_needed: resetLine()
            if getConfirmation("Turn off inline commands? (y/n)"):
                settings["inline_commands"] = False
                getConfirmation("Command window still accesible with ctrl 'e'", True)
                program_message = " Inline commands turned off! "

        elif c == 10 and commandMatch(current_line.text, "debug"): toggleDebug(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "prev","previous"): prev()
        elif c == 10 and commandMatch(current_line.text, "strip") and getConfirmation("Strip extra spaces from lines? (y/n)"): stripSpaces(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "savesettings", "saveprefs") and getConfirmation("Save current settings? (y/n)"): saveSettings()
        elif c == 10 and commandMatch(current_line.text, "setcolors", "setcolor"): setColors()
        elif c == 10 and commandMatch(current_line.text, "isave"): isave()
        elif c == 10 and commandMatch(current_line.text, "entry"): toggleEntry(current_line.text)

        elif c == 10 and commandMatch(current_line.text, "live"): toggleLive(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "timestamp"): timeStamp()
        elif c == 10 and current_line.text.endswith("help") and commandMatch(current_line.text, "help"):
            if reset_needed: resetLine()
            if WIDTH > 60 and getConfirmation("Load HELP GUIDE? Current doc will be purged! (y/n)"): showHelp()
            elif WIDTH <= 60 and getConfirmation("Load HELP & purge current doc? (y/n)"): showHelp()
        elif c == 10 and commandMatch(current_line.text, "auto"): toggleAuto(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "formatting"): toggleCommentFormatting(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "help"): functionHelp(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "guide", "pageguide"): togglePageGuide(current_line.text)
        elif c == 10 and commandMatch(current_line.text, "acceleration","accelerate"): toggleAcceleration(current_line.text)

        # Return Key pressed
        elif c == 10: returnKey()
        # Key up
        elif c == curses.KEY_UP:
            new_time = time.time()
            if new_time - old_time > .2:
                continue_down = 0; continue_up = 0; continue_left = 0; continue_right = 0
            old_time = new_time
            moveUp()
        # Key down
        elif c == curses.KEY_DOWN:
            new_time = time.time()
            if new_time - old_time > .2:
                continue_down = 0; continue_up = 0; continue_left = 0; continue_right = 0
            old_time = new_time
            moveDown()
        # Key left
        elif c == curses.KEY_LEFT:
            if line.locked: currentNum = max(1, currentNum - (HEIGHT - 1))
            else:
                new_time = time.time()
                if new_time - old_time > .2:
                    continue_down = 0; continue_up = 0;continue_left = 0; continue_right = 0
                old_time = new_time
                moveLeft()
        # Key right
        elif c == curses.KEY_RIGHT:
            if line.locked: currentNum = min(line.total, currentNum + (HEIGHT - 1))
            else:
                new_time = time.time()
                if new_time - old_time > .2:
                    continue_down = 0; continue_up = 0;continue_left = 0; continue_right = 0
                old_time = new_time
                moveRight()

        # If read only mode, 'b' and 'space' should act as in terminal.
        elif line.locked and c in ( ord('b'), ord('B') ): moveUp()
        elif line.locked and c == ord(' '): moveDown()

        elif c == settings["key_save_as"]:
            reset_needed = False
            if not savepath: tempPath = False
            else:
                (fullpath, filename) = os.path.split(savepath)
                tempPath = filename
            saveas(tempPath)

        elif settings["splitscreen"] and c in (339,settings["key_page_up"]): #PAGEUP
            program_message = ""
            if settings["splitscreen"] > 1:
                settings["splitscreen"] -= 1
                if settings["syntax_hilighting"]: syntaxSplitscreen()

        elif settings["splitscreen"] and c in (338,settings["key_page_down"]): #PAGEDOWN
            program_message = ""
            if settings["splitscreen"] < line.total - 1:
                settings["splitscreen"] += 1
                if settings["syntax_hilighting"]: syntaxSplitscreen()

        elif c == settings["key_page_up"]: pageUp()
        elif c == settings["key_page_down"]: pageDown()

        elif c == settings["key_entry_window"]:
            if line.locked: readModeEntryWindow()
            else: enterCommands() #Control E pulls up dialog box

        elif c == settings["key_find"]:
            reset_needed = False
            findWindow()

        elif c == settings["key_find_again"] and not last_search:
            reset_needed = False
            findWindow()
        elif c == settings["key_find_again"] and last_search:
            reset_needed = False #fix bug that was deleting lines
            program_message = ""
            #find("find %s" %last_search) #Press control-g to find again
            find("find") #Press control -g to find again
        elif c == settings["key_deselect_all"] and line.locked: ##In read only mode, deselects selection
            last_search = ""
            unmark_all()
        elif c == settings["key_deselect_all"]: deselect_all() ##Press control-a to deselect lines
        elif settings["debug"] and c == settings["key_next_bug"]: bugHunt() #Press control-d to move to line with 'bug'
        elif not settings["debug"] and c == settings["key_next_bug"] and getConfirmation("Turn on debug mode? (y/n)"):
            reset_needed = False
            toggleDebug("debug on")
        elif c == settings["key_next_marked"]: gotoMarked() #goto next marked line if control-n is presed
        elif c == settings["key_previous_marked"]: prevMarked() #goto prev marked line if control-b is pressed

        # Key backspace (delete)
        elif c == curses.KEY_BACKSPACE or c == 127:
            if line.locked: moveUp() ## If document is locked, convert backspace/delete to ARROW UP
            else: keyBackspace()
        # Tab pressed (insert 4 spaces)
        elif c == 9: tabKey()
        # Other key presses (alphanumeric)
        elif not line.locked and c in CHAR_DICT: addCharacter(CHAR_DICT[c])

    except: ##quits program if crash occurs
        if getConfirmation("Program crashed, save rescued file? (y/n)"):
            tempName = "warrior-ide_rescued_file_" + str(int(time.time())) + ".txt"
            tempPath = os.path.expanduser("~") + "/Desktop/" + tempName
            save(tempPath)
            quit(False, "'%s' saved to Desktop!" %tempName)
        else:
            quit(False)

