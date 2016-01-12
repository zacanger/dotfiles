/* emulation ($TERM) */
#define TT_TERMINFO               "xterm-256color"

//#define TT_SCROLLBAR_VISIBLE      // uncomment to show scrollbar
#define TT_DYNAMIC_WINDOW_TITLE   // uncomment to enable window_title_cb
//#define TT_URGENT_ON_BELL         // uncomment to enable window_urgency_hint_cb
#define TT_URL_BLOCK_MOUSE        // uncomment to block mouse (button-press events) in url-select mode
#define TT_SCROLLBACK_LINES       10000
#define TT_SEARCH_WRAP_AROUND     TRUE
#define TT_AUDIBLE_BELL           FALSE
#define TT_VISIBLE_BELL           FALSE
#define TT_FONT                   "Fira Code 10"
#define TT_X_WINDOW_SIZE          600
#define TT_Y_WINDOW_SIZE          400

/* VTE_ANTI_ALIAS_USE_DEFAULT, VTE_ANTI_ALIAS_FORCE_ENABLE, VTE_ANTI_ALIAS_FORCE_DISABLE */
#define TT_ANTIALIAS      VTE_ANTI_ALIAS_FORCE_ENABLE

/* VTE_CURSOR_SHAPE_BLOCK, VTE_CURSOR_SHAPE_IBEAM, VTE_CURSOR_SHAPE_UNDERLINE */
#define TT_CURSOR_SHAPE   VTE_CURSOR_SHAPE_UNDERLINE

/* VTE_CURSOR_BLINK_SYSTEM, VTE_CURSOR_BLINK_ON, VTE_CURSOR_BLINK_OFF */
#define TT_CURSOR_BLINK   VTE_CURSOR_BLINK_ON

/* double-click selection */
#define TT_WORD_CHARS "-A-Za-z0-9:./?%&#_=+@~"

/* colours */
#define TT_COLOR_BACKGROUND   "#101010"
#define TT_COLOR_FOREGROUND   "#cdcdcd"
/* black */
#define TT_COLOR0     "101010"
#define TT_COLOR8     "#4d4d4d"
/* red */
#define TT_COLOR1     "#B22222"
#define TT_COLOR9     "#ED2939"
/* green */
#define TT_COLOR2     "#00a000"
#define TT_COLOR10    "#32cd32"
/* yellow */
#define TT_COLOR3     "#cdcd00"
#define TT_COLOR11    "#ffff00"
/* blue */
#define TT_COLOR4     "#2346AE"
#define TT_COLOR12    "#2b65ec"
/* magenta */
#define TT_COLOR5     "#AA00AA"
#define TT_COLOR13    "#C154C1"
/* cyan */
#define TT_COLOR6     "#58C6ED"
#define TT_COLOR14    "#00DFFF"
/* white */
#define TT_COLOR7     "#e5e5e5"
#define TT_COLOR15    "#dddddd"

///* default colours; like urxvt */
//#define TT_COLOR_BACKGROUND   "#000000"
//#define TT_COLOR_FOREGROUND   "#bebebe"
///* black */
//#define TT_COLOR0      "#000000"
//#define TT_COLOR8      "#4d4d4d"
///* red */
//#define TT_COLOR1      "#cd0000"
//#define TT_COLOR9      "#ff0000"
///* green */
//#define TT_COLOR2      "#00cd00"
//#define TT_COLOR10     "#00ff00"
///* yellow */
//#define TT_COLOR3      "#cdcd00"
//#define TT_COLOR11     "#ffff00"
///* blue */
//#define TT_COLOR4      "#0000cd"
//#define TT_COLOR12     "#2b65ec"
///* magenta */
//#define TT_COLOR5      "#cd00cd"
//#define TT_COLOR13     "#ff00ff"
///* cyan */
//#define TT_COLOR6      "#00cdcd"
//#define TT_COLOR14     "#00ffff"
///* white */
//#define TT_COLOR7      "#e5e5e5"
//#define TT_COLOR15     "#ffffff"

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
