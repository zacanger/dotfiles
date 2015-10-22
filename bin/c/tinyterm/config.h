/*
* Ryan P.C. McQuen | Everett, WA | ryan.q@linux.com
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2 of the License, or
* (at your option) any later version, with the following exception:
* the text of the GPL license may be omitted.
*
* This program is distributed in the hope that it will be useful, but
* without any warranty; without even the implied warranty of
* merchantability or fitness for a particular purpose. Compiling,
* interpreting, executing or merely reading the text of the program
* may result in lapses of consciousness and/or very being, up to and
* including the end of all existence and the Universe as we know it.
* See the GNU General Public License for more details.
*
* You may have received a copy of the GNU General Public License along
* with this program (most likely, a file named COPYING).  If not, see
* <http://www.gnu.org/licenses/>.
*
*/

/* Terminal emulation (value of $TERM) (default: xterm) */
#define TINYTERM_TERMINFO               "xterm"

//#define TINYTERM_SCROLLBAR_VISIBLE      // uncomment to show scrollbar

#define TINYTERM_DYNAMIC_WINDOW_TITLE   // uncomment to enable window_title_cb
#define TINYTERM_URGENT_ON_BELL         // uncomment to enable window_urgency_hint_cb
#define TINYTERM_URL_BLOCK_MOUSE        // uncomment to block mouse (button-press events) in url-select mode
#define TINYTERM_SCROLLBACK_LINES       15000
#define TINYTERM_SEARCH_WRAP_AROUND     TRUE
#define TINYTERM_AUDIBLE_BELL           FALSE
#define TINYTERM_VISIBLE_BELL           FALSE
#define TINYTERM_FONT                   "terminus 9"
#define TINYTERM_X_WINDOW_SIZE          990
#define TINYTERM_Y_WINDOW_SIZE          590

/* One of VTE_ANTI_ALIAS_USE_DEFAULT, VTE_ANTI_ALIAS_FORCE_ENABLE, VTE_ANTI_ALIAS_FORCE_DISABLE */
#define TINYTERM_ANTIALIAS      VTE_ANTI_ALIAS_FORCE_ENABLE

/* One of VTE_CURSOR_SHAPE_BLOCK, VTE_CURSOR_SHAPE_IBEAM, VTE_CURSOR_SHAPE_UNDERLINE */
#define TINYTERM_CURSOR_SHAPE   VTE_CURSOR_SHAPE_BLOCK

/* One of VTE_CURSOR_BLINK_SYSTEM, VTE_CURSOR_BLINK_ON, VTE_CURSOR_BLINK_OFF */
#define TINYTERM_CURSOR_BLINK   VTE_CURSOR_BLINK_OFF

/* Selection behavior for double-clicks */
#define TINYTERM_WORD_CHARS "-A-Za-z0-9:./?%&#_=+@~"

/* Custom color scheme */
#define TINYTERM_COLOR_BACKGROUND   "#000000"
#define TINYTERM_COLOR_FOREGROUND   "#bebebe"
/* black */
#define TINYTERM_COLOR0     "#000000"
#define TINYTERM_COLOR8     "#4d4d4d"
/* red */
#define TINYTERM_COLOR1     "#B22222"
#define TINYTERM_COLOR9     "#ED2939"
/* green */
#define TINYTERM_COLOR2     "#00a000"
#define TINYTERM_COLOR10    "#32cd32"
/* yellow */
#define TINYTERM_COLOR3     "#cdcd00"
#define TINYTERM_COLOR11    "#ffff00"
/* blue */
#define TINYTERM_COLOR4     "#2346AE"
#define TINYTERM_COLOR12    "#2b65ec"
/* magenta */
#define TINYTERM_COLOR5     "#AA00AA"
#define TINYTERM_COLOR13    "#C154C1"
/* cyan */
#define TINYTERM_COLOR6     "#58C6ED"
#define TINYTERM_COLOR14    "#00DFFF"
/* white */
#define TINYTERM_COLOR7     "#e5e5e5"
#define TINYTERM_COLOR15    "#ffffff"

///* Default color scheme - matches default colors of urxvt */
//#define TINYTERM_COLOR_BACKGROUND   "#000000"
//#define TINYTERM_COLOR_FOREGROUND   "#bebebe"
///* black */
//#define TINYTERM_COLOR0      "#000000"
//#define TINYTERM_COLOR8      "#4d4d4d"
///* red */
//#define TINYTERM_COLOR1      "#cd0000"
//#define TINYTERM_COLOR9      "#ff0000"
///* green */
//#define TINYTERM_COLOR2      "#00cd00"
//#define TINYTERM_COLOR10     "#00ff00"
///* yellow */
//#define TINYTERM_COLOR3      "#cdcd00"
//#define TINYTERM_COLOR11     "#ffff00"
///* blue */
//#define TINYTERM_COLOR4      "#0000cd"
//#define TINYTERM_COLOR12     "#2b65ec"
///* magenta */
//#define TINYTERM_COLOR5      "#cd00cd"
//#define TINYTERM_COLOR13     "#ff00ff"
///* cyan */
//#define TINYTERM_COLOR6      "#00cdcd"
//#define TINYTERM_COLOR14     "#00ffff"
///* white */
//#define TINYTERM_COLOR7      "#e5e5e5"
//#define TINYTERM_COLOR15     "#ffffff"

/* Keyboard shortcuts */
#define TINYTERM_MODIFIER       GDK_CONTROL_MASK | GDK_SHIFT_MASK
#define TINYTERM_KEY_COPY       GDK_C
#define TINYTERM_KEY_PASTE      GDK_V
#define TINYTERM_KEY_OPEN       GDK_O   // pass selected text to xdg-open
#define TINYTERM_KEY_URL_INIT   GDK_U
#define TINYTERM_KEY_URL_NEXT   GDK_J   // only in url select mode, not matched against modifier
#define TINYTERM_KEY_URL_PREV   GDK_K   // only in url select mode, not matched against modifier

/* Regular expression matching urls */
#define SPECIAL_CHARS   "[[:alnum:]\\Q+-_,?;.:/!%$^*&~#=()\\E]"
#define SCHEME          "(?:[[:alpha:]][+-.[:alpha:]]*://)"
#define USERINFO        "(?:[[:alnum:]]+(?:" SPECIAL_CHARS "+)?\\@)?"
#define HOST            "(?:(?:[[:alnum:]-]+\\.)*[[:alpha:]]{2,})"
#define PORT            "(?:\\:[[:digit:]]{1,5})?"
#define URLPATH         "(?:/" SPECIAL_CHARS "*)?"

const char * const url_regex = SCHEME USERINFO HOST PORT URLPATH "(?<!\\.)";
