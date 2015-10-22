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

#include <stdlib.h>
#include <glib.h>
#include <sys/wait.h>
#include <gdk/gdkkeysyms.h>
#include <vte/vte.h>
#include <signal.h>
#include "config.h"

static gboolean url_select_mode = FALSE;
static int child_pid = 0;   // needs to be global for signal_handler to work

/* spawn xdg-open and pass text as argument */
static void
xdg_open(const char* text)
{
    GError* error = NULL;
    char* command = g_strconcat("xdg-open ", text, NULL);
    g_spawn_command_line_async(command, &error);
    if (error) {
        g_printerr("xdg-open: %s\n", error->message);
        g_error_free(error);
    }
    g_free(command);
}

/* callback to receive data from GtkClipboard */
static void
xdg_open_selection_cb(GtkClipboard* clipboard, const char* string, gpointer data)
{
    xdg_open(string);
}

/* pass selected text to xdg-open */
static void
xdg_open_selection(GtkWidget* terminal)
{
    GdkDisplay* display = gtk_widget_get_display(terminal);;
    GtkClipboard* clipboard = gtk_clipboard_get_for_display(display, GDK_SELECTION_PRIMARY);
    vte_terminal_copy_primary(VTE_TERMINAL (terminal));
    gtk_clipboard_request_text(clipboard, xdg_open_selection_cb, NULL);
}

/* callback to set window urgency hint on beep events */
static void
window_urgency_hint_cb(VteTerminal* vte)
{
    gtk_window_set_urgency_hint(GTK_WINDOW (gtk_widget_get_toplevel(GTK_WIDGET (vte))), TRUE);
}

/* callback to unset window urgency hint on focus */
gboolean
window_focus_cb(GtkWindow* window)
{
    gtk_window_set_urgency_hint(window, FALSE);
    return FALSE;
}

/* callback to dynamically change window title */
static void
window_title_cb(VteTerminal* vte)
{
    gtk_window_set_title(GTK_WINDOW (gtk_widget_get_toplevel(GTK_WIDGET (vte))), vte_terminal_get_window_title(vte));
}

/* callback to react to key press events */
static gboolean
key_press_cb(VteTerminal* vte, GdkEventKey* event)
{
    if (url_select_mode) {
        switch (gdk_keyval_to_upper(event->keyval)) {
            case TINYTERM_KEY_URL_NEXT:
                vte_terminal_search_find_next(vte);
                return TRUE;
            case TINYTERM_KEY_URL_PREV:
                vte_terminal_search_find_previous(vte);
                return TRUE;
            case GDK_Return:
                xdg_open_selection(vte);
            case GDK_Escape:
                vte_terminal_select_none(vte);
                url_select_mode = FALSE;
                return TRUE;
        }
        return TRUE;
    }
    if ((event->state & (TINYTERM_MODIFIER)) == (TINYTERM_MODIFIER)) {
        switch (gdk_keyval_to_upper(event->keyval)) {
            case TINYTERM_KEY_COPY:
                vte_terminal_copy_clipboard(vte);
                return TRUE;
            case TINYTERM_KEY_PASTE:
                vte_terminal_paste_clipboard(vte);
                return TRUE;
            case TINYTERM_KEY_OPEN:
                xdg_open_selection(vte);
                return TRUE;
            case TINYTERM_KEY_URL_INIT:
                url_select_mode = vte_terminal_search_find_previous(vte);
                return TRUE;
        }
    }
    return FALSE;
}

/* callback to block mouse when in url-select mode */
static gboolean
button_press_cb(VteTerminal* vte, GdkEventButton* event)
{
    if (url_select_mode)
        return TRUE;
    return FALSE;
}

static void
vte_config(VteTerminal* vte)
{
    GdkColor color_fg, color_bg;
    GdkColor color_palette[16];
    GRegex* regex = g_regex_new(url_regex, G_REGEX_CASELESS, G_REGEX_MATCH_NOTEMPTY, NULL);

    vte_terminal_search_set_gregex(vte, regex);
    vte_terminal_search_set_wrap_around     (vte, TINYTERM_SEARCH_WRAP_AROUND);
    vte_terminal_set_audible_bell           (vte, TINYTERM_AUDIBLE_BELL);
    vte_terminal_set_visible_bell           (vte, TINYTERM_VISIBLE_BELL);
    vte_terminal_set_cursor_shape           (vte, TINYTERM_CURSOR_SHAPE);
    vte_terminal_set_cursor_blink_mode      (vte, TINYTERM_CURSOR_BLINK);
    vte_terminal_set_word_chars             (vte, TINYTERM_WORD_CHARS);
    vte_terminal_set_scrollback_lines       (vte, TINYTERM_SCROLLBACK_LINES);
    vte_terminal_set_font_from_string_full  (vte, TINYTERM_FONT, TINYTERM_ANTIALIAS);

    /* init colors */
    gdk_color_parse(TINYTERM_COLOR_FOREGROUND, &color_fg);
    gdk_color_parse(TINYTERM_COLOR_BACKGROUND, &color_bg);
    gdk_color_parse(TINYTERM_COLOR0,  &color_palette[0]);
    gdk_color_parse(TINYTERM_COLOR1,  &color_palette[1]);
    gdk_color_parse(TINYTERM_COLOR2,  &color_palette[2]);
    gdk_color_parse(TINYTERM_COLOR3,  &color_palette[3]);
    gdk_color_parse(TINYTERM_COLOR4,  &color_palette[4]);
    gdk_color_parse(TINYTERM_COLOR5,  &color_palette[5]);
    gdk_color_parse(TINYTERM_COLOR6,  &color_palette[6]);
    gdk_color_parse(TINYTERM_COLOR7,  &color_palette[7]);
    gdk_color_parse(TINYTERM_COLOR8,  &color_palette[8]);
    gdk_color_parse(TINYTERM_COLOR9,  &color_palette[9]);
    gdk_color_parse(TINYTERM_COLOR10, &color_palette[10]);
    gdk_color_parse(TINYTERM_COLOR11, &color_palette[11]);
    gdk_color_parse(TINYTERM_COLOR12, &color_palette[12]);
    gdk_color_parse(TINYTERM_COLOR13, &color_palette[13]);
    gdk_color_parse(TINYTERM_COLOR14, &color_palette[14]);
    gdk_color_parse(TINYTERM_COLOR15, &color_palette[15]);

    vte_terminal_set_colors(vte, &color_fg, &color_bg, &color_palette, 16);
}

static void
vte_spawn(VteTerminal* vte, char* working_directory, char* command, char** environment)
{
    GError* error = NULL;
    char** command_argv = NULL;

    /* Parse command into array */
    if (!command)
        command = vte_get_user_shell();
    g_shell_parse_argv(command, NULL, &command_argv, &error);
    if (error) {
        g_printerr("Failed to parse command: %s\n", error->message);
        g_error_free(error);
        exit(EXIT_FAILURE);
    }

    /* Create pty object */
    VtePty* pty = vte_terminal_pty_new(vte, VTE_PTY_NO_HELPER, &error);
    if (error) {
        g_printerr("Failed to create pty: %s\n", error->message);
        g_error_free(error);
        exit(EXIT_FAILURE);
    }
    vte_pty_set_term(pty, TINYTERM_TERMINFO);
    vte_terminal_set_pty_object(vte, pty);

    /* Spawn default shell (or specified command) */
    g_spawn_async(working_directory, command_argv, environment,
                  (G_SPAWN_DO_NOT_REAP_CHILD | G_SPAWN_SEARCH_PATH | G_SPAWN_LEAVE_DESCRIPTORS_OPEN),  // flags from GSpawnFlags
                  (GSpawnChildSetupFunc)vte_pty_child_setup, // an extra child setup function to run in the child just before exec()
                  pty,          // user data for child_setup
                  &child_pid,   // a location to store the child PID
                  &error);      // return location for a GError
    if (error) {
        g_printerr("%s\n", error->message);
        g_error_free(error);
        exit(EXIT_FAILURE);
    }
    vte_terminal_watch_child(vte, child_pid);
    g_strfreev(command_argv);
}

/* callback to exit TinyTerm with exit status of child process */
static void
vte_exit_cb(VteTerminal* vte)
{
    int status = vte_terminal_get_child_exit_status(vte);
    gtk_main_quit();
    exit(WIFEXITED(status) ? WEXITSTATUS(status) : EXIT_FAILURE);
}

static void
parse_arguments(int argc, char* argv[], char** command, char** directory, gboolean* keep, char** name, char** title)
{
    gboolean version = FALSE;   // show version?
    const GOptionEntry entries[] = {
        {"version",   'v', 0, G_OPTION_ARG_NONE,    &version,   "Display program version and exit.", 0},
        {"execute",   'e', 0, G_OPTION_ARG_STRING,  command,    "Execute command instead of default shell.", "COMMAND"},
        {"directory", 'd', 0, G_OPTION_ARG_STRING,  directory,  "Sets the working directory for the shell (or the command specified via -e).", "PATH"},
        {"keep",      'k', 0, G_OPTION_ARG_NONE,    keep,       "Don't exit the terminal after child process exits.", 0},
        {"name",      'n', 0, G_OPTION_ARG_STRING,  name,       "Set first value of WM_CLASS property; second value is always 'TinyTerm' (default: 'tinyterm')", "NAME"},
        {"title",     't', 0, G_OPTION_ARG_STRING,  title,      "Set value of WM_NAME property; disables window_title_cb (default: 'TinyTerm')", "TITLE"},
        { NULL }
    };

    GError* error = NULL;
    GOptionContext* context = g_option_context_new(NULL);
    g_option_context_set_help_enabled(context, TRUE);
    g_option_context_add_main_entries(context, entries, NULL);
    g_option_context_parse(context, &argc, &argv, &error);
    g_option_context_free(context);

    if (error) {
        g_printerr("option parsing failed: %s\n", error->message);
        g_error_free(error);
        exit(EXIT_FAILURE);
    }

    if (version) {
        g_print("tinyterm " TINYTERM_VERSION "\n");
        exit(EXIT_SUCCESS);
    }
}

/* UNIX signal handler */
static void
signal_handler(int signal)
{
    if (child_pid != 0)
        kill(child_pid, SIGHUP);
    exit(signal);
}

int
main (int argc, char* argv[])
{
    GtkWidget* window;
    GtkWidget* box;
    GdkPixbuf* icon;
    GdkGeometry geo_hints;
    GtkIconTheme* icon_theme;
    GError* error = NULL;

    /* Variables for parsed command-line arguments */
    char* command = NULL;
    char* directory = NULL;
    gboolean keep = FALSE;
    char* name = NULL;
    char* title = NULL;

    gtk_init(&argc, &argv);
    parse_arguments(argc, argv, &command, &directory, &keep, &name, &title);

    /* Create window */
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    g_signal_connect(window, "delete-event", gtk_main_quit, NULL);
    gtk_window_set_wmclass(GTK_WINDOW (window), name ? name : "tinyterm", "TinyTerm");
    gtk_window_set_title(GTK_WINDOW (window), title ? title : "TinyTerm");

    /* set default window size, defined in config.h */
    gtk_window_set_default_size(GTK_WINDOW (window), TINYTERM_X_WINDOW_SIZE, TINYTERM_Y_WINDOW_SIZE);

    /* Set window icon supplied by an icon theme */
    icon_theme = gtk_icon_theme_get_default();
    icon = gtk_icon_theme_load_icon(icon_theme, "terminal", 48, 0, &error);
    if (error)
        g_error_free(error);
    if (icon)
        gtk_window_set_icon(GTK_WINDOW (window), icon);

    /* Create main box */
    box = gtk_hbox_new(FALSE, 0);
    gtk_container_add(GTK_CONTAINER (window), box);

    /* Create vte terminal widget */
    GtkWidget* vte_widget = vte_terminal_new();
    gtk_box_pack_start(GTK_BOX (box), vte_widget, TRUE, TRUE, 0);
    VteTerminal* vte = VTE_TERMINAL (vte_widget);
    if (!keep)
        g_signal_connect(vte, "child-exited", G_CALLBACK (vte_exit_cb), NULL);
    g_signal_connect(vte, "key-press-event", G_CALLBACK (key_press_cb), NULL);
    #ifdef TINYTERM_URGENT_ON_BELL
    g_signal_connect(vte, "beep", G_CALLBACK (window_urgency_hint_cb), NULL);
    g_signal_connect(window, "focus-in-event",  G_CALLBACK (window_focus_cb), NULL);
    g_signal_connect(window, "focus-out-event", G_CALLBACK (window_focus_cb), NULL);
    #endif // TINYTERM_URGENT_ON_BELL
    #ifdef TINYTERM_URL_BLOCK_MOUSE
    g_signal_connect(vte, "button-press-event", G_CALLBACK (button_press_cb), NULL);
    #endif // TINYTERM_URL_BLOCK_MOUSE
    #ifdef TINYTERM_DYNAMIC_WINDOW_TITLE
    if (!title)
        g_signal_connect(vte, "window-title-changed", G_CALLBACK (window_title_cb), NULL);
    #endif // TINYTERM_DYNAMIC_WINDOW_TITLE

    /* Apply geometry hints to handle terminal resizing */
    geo_hints.base_width  = vte->char_width;
    geo_hints.base_height = vte->char_height;
    geo_hints.min_width   = vte->char_width;
    geo_hints.min_height  = vte->char_height;
    geo_hints.width_inc   = vte->char_width;
    geo_hints.height_inc  = vte->char_height;
    gtk_window_set_geometry_hints(GTK_WINDOW (window), vte_widget, &geo_hints,
                                  GDK_HINT_RESIZE_INC | GDK_HINT_MIN_SIZE | GDK_HINT_BASE_SIZE);

    /* Create scrollbar */
    #ifdef TINYTERM_SCROLLBAR_VISIBLE
    GtkWidget* scrollbar;
    scrollbar = gtk_vscrollbar_new(vte->adjustment);
    gtk_box_pack_start(GTK_BOX (box), scrollbar, FALSE, FALSE, 0);
    #endif // TINYTERM_SCROLLBAR_VISIBLE

    vte_config(vte);
    vte_spawn(vte, directory, command, NULL);

    /* register signal handler */
    signal(SIGHUP, signal_handler);
    signal(SIGINT, signal_handler);
    signal(SIGTERM, signal_handler);

    /* cleanup */
    g_free(command);
    g_free(directory);
    g_free(name);
    g_free(title);

    /* Show widgets and run main loop */
    gtk_widget_show_all(window);
    gtk_main();

    return EXIT_SUCCESS;
}
