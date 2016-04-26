// emulation ($TERM)
#define TT_TERMINFO               "xterm-256color"
//#define TT_SCROLLBAR_VISIBLE      // uncomment to show scrollbar
#define TT_DYNAMIC_WINDOW_TITLE   // uncomment to enable window_title_cb
//#define TT_URGENT_ON_BELL         // uncomment to enable window_urgency_hint_cb
#define TT_URL_BLOCK_MOUSE        // uncomment to block mouse (button-press events) in url-select mode
#define TT_SCROLLBACK_LINES       10000
#define TT_SEARCH_WRAP_AROUND     TRUE
#define TT_AUDIBLE_BELL           FALSE
#define TT_VISIBLE_BELL           FALSE
#define TT_FONT                   "Hack 10"
#define TT_X_WINDOW_SIZE          800
#define TT_Y_WINDOW_SIZE          450

/* VTE_ANTI_ALIAS_USE_DEFAULT, VTE_ANTI_ALIAS_FORCE_ENABLE, VTE_ANTI_ALIAS_FORCE_DISABLE */
#define TT_ANTIALIAS      VTE_ANTI_ALIAS_FORCE_ENABLE

/* VTE_CURSOR_SHAPE_BLOCK, VTE_CURSOR_SHAPE_IBEAM, VTE_CURSOR_SHAPE_UNDERLINE */
#define TT_CURSOR_SHAPE   VTE_CURSOR_SHAPE_UNDERLINE

/* VTE_CURSOR_BLINK_SYSTEM, VTE_CURSOR_BLINK_ON, VTE_CURSOR_BLINK_OFF */
#define TT_CURSOR_BLINK   VTE_CURSOR_BLINK_ON

/* double-click selection */
#define TT_WORD_CHARS "-A-Za-z0-9:./?%&#_=+@~"

/* colours */
#define TT_COLOR_BACKGROUND   "#060606"
#define TT_COLOR_FOREGROUND   "#d4e5de"
/* black */
#define TT_COLOR0     "050505"
#define TT_COLOR8     "#212529"
/* red */
#define TT_COLOR1     "#c16c6c"
#define TT_COLOR9     "#ab656a"
/* green */
#define TT_COLOR2     "#6abf6a"
#define TT_COLOR10    "#7cee7c"
/* yellow */
#define TT_COLOR3     "#e1e16d"
#define TT_COLOR11    "#e5e579"
/* blue */
#define TT_COLOR4     "#8b99c1"
#define TT_COLOR12    "#81c3f4"
/* magenta */
#define TT_COLOR5     "#db63db"
#define TT_COLOR13    "#d094d0"
/* cyan */
#define TT_COLOR6     "#85d8f0"
#define TT_COLOR14    "#7af3f6"
/* white */
#define TT_COLOR7     "#eaecd6"
#define TT_COLOR15    "#eaeaea"

/* shortcuts */
#define TT_MODIFIER       GDK_CONTROL_MASK | GDK_SHIFT_MASK
#define TT_KEY_COPY       GDK_C
#define TT_KEY_PASTE      GDK_V
#define TT_KEY_OPEN       GDK_O   // pass selected text to xdg-open
#define TT_KEY_URL_INIT   GDK_U
#define TT_KEY_URL_NEXT   GDK_J   // only in url select mode, not matched against modifier
#define TT_KEY_URL_PREV   GDK_K   // only in url select mode, not matched against modifier

/* regex matching urls */
#define SPECIAL_CHARS   "[[:alnum:]\\Q+-_,?;.:/!%$^*&~#=()\\E]"
#define SCHEME          "(?:[[:alpha:]][+-.[:alpha:]]*://)"
#define USERINFO        "(?:[[:alnum:]]+(?:" SPECIAL_CHARS "+)?\\@)?"
#define HOST            "(?:(?:[[:alnum:]-]+\\.)*[[:alpha:]]{2,})"
#define PORT            "(?:\\:[[:digit:]]{1,5})?"
#define URLPATH         "(?:/" SPECIAL_CHARS "*)?"

const char * const url_regex = SCHEME USERINFO HOST PORT URLPATH "(?<!\\.)";

