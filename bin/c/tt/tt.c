/* originally by ryan.q@linux.com | forked by gh:zacanger */

#include <stdlib.h>
#include <glib.h>
#include <sys/wait.h>
#include <gdk/gdkkeysyms.h>
#include <vte/vte.h>
#include <signal.h>
#include "config.h"

static gboolean url_select_mode = FALSE;
static int child_pid = 0; // needs to be global for signal_handler to work

/* xdg-open, text is argument */
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

/* cb, get data from gtkclipboard */
  static void
xdg_open_selection_cb(GtkClipboard* clipboard, const char* string, gpointer data)
{
  xdg_open(string);
}

/* selected text => xdg-open */
  static void
xdg_open_selection(GtkWidget* terminal)
{
  GdkDisplay* display = gtk_widget_get_display(terminal);;
  GtkClipboard* clipboard = gtk_clipboard_get_for_display(display, GDK_SELECTION_PRIMARY);
  vte_terminal_copy_primary(VTE_TERMINAL (terminal));
  gtk_clipboard_request_text(clipboard, xdg_open_selection_cb, NULL);
}

/* cb, window urgency hint @ beep */
  static void
window_urgency_hint_cb(VteTerminal* vte)
{
  gtk_window_set_urgency_hint(GTK_WINDOW (gtk_widget_get_toplevel(GTK_WIDGET (vte))), TRUE);
}

/* unset on focus */
  gboolean
window_focus_cb(GtkWindow* window)
{
  gtk_window_set_urgency_hint(window, FALSE);
  return FALSE;
}

/* dynamic window title */
  static void
window_title_cb(VteTerminal* vte)
{
  gtk_window_set_title(GTK_WINDOW (gtk_widget_get_toplevel(GTK_WIDGET (vte))), vte_terminal_get_window_title(vte));
}

/* respond @ key presses */
  static gboolean
key_press_cb(VteTerminal* vte, GdkEventKey* event)
{
  if (url_select_mode) {
    switch (gdk_keyval_to_upper(event->keyval)) {
      case TT_KEY_URL_NEXT:
        vte_terminal_search_find_next(vte);
        return TRUE;
      case TT_KEY_URL_PREV:
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
  if ((event->state & (TT_MODIFIER)) == (TT_MODIFIER)) {
    switch (gdk_keyval_to_upper(event->keyval)) {
      case TT_KEY_COPY:
        vte_terminal_copy_clipboard(vte);
        return TRUE;
      case TT_KEY_PASTE:
        vte_terminal_paste_clipboard(vte);
        return TRUE;
      case TT_KEY_OPEN:
        xdg_open_selection(vte);
        return TRUE;
      case TT_KEY_URL_INIT:
        url_select_mode = vte_terminal_search_find_previous(vte);
        return TRUE;
    }
  }
  return FALSE;
}

/* block mouse in url-select mode */
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
  vte_terminal_search_set_wrap_around     (vte, TT_SEARCH_WRAP_AROUND);
  vte_terminal_set_audible_bell           (vte, TT_AUDIBLE_BELL);
  vte_terminal_set_visible_bell           (vte, TT_VISIBLE_BELL);
  vte_terminal_set_cursor_shape           (vte, TT_CURSOR_SHAPE);
  vte_terminal_set_cursor_blink_mode      (vte, TT_CURSOR_BLINK);
  vte_terminal_set_word_chars             (vte, TT_WORD_CHARS);
  vte_terminal_set_scrollback_lines       (vte, TT_SCROLLBACK_LINES);
  vte_terminal_set_font_from_string_full  (vte, TT_FONT, TT_ANTIALIAS);

  /* init colours */
  gdk_color_parse(TT_COLOR_FOREGROUND, &color_fg);
  gdk_color_parse(TT_COLOR_BACKGROUND, &color_bg);
  gdk_color_parse(TT_COLOR0,  &color_palette[0]);
  gdk_color_parse(TT_COLOR1,  &color_palette[1]);
  gdk_color_parse(TT_COLOR2,  &color_palette[2]);
  gdk_color_parse(TT_COLOR3,  &color_palette[3]);
  gdk_color_parse(TT_COLOR4,  &color_palette[4]);
  gdk_color_parse(TT_COLOR5,  &color_palette[5]);
  gdk_color_parse(TT_COLOR6,  &color_palette[6]);
  gdk_color_parse(TT_COLOR7,  &color_palette[7]);
  gdk_color_parse(TT_COLOR8,  &color_palette[8]);
  gdk_color_parse(TT_COLOR9,  &color_palette[9]);
  gdk_color_parse(TT_COLOR10, &color_palette[10]);
  gdk_color_parse(TT_COLOR11, &color_palette[11]);
  gdk_color_parse(TT_COLOR12, &color_palette[12]);
  gdk_color_parse(TT_COLOR13, &color_palette[13]);
  gdk_color_parse(TT_COLOR14, &color_palette[14]);
  gdk_color_parse(TT_COLOR15, &color_palette[15]);

  vte_terminal_set_colors(vte, &color_fg, &color_bg, &color_palette, 16);
}

  static void
vte_spawn(VteTerminal* vte, char* working_directory, char* command, char** environment)
{
  GError* error = NULL;
  char** command_argv = NULL;

  /* command => array */
  if (!command)
    command = vte_get_user_shell();
  g_shell_parse_argv(command, NULL, &command_argv, &error);
  if (error) {
    g_printerr("Failed to parse command: %s\n", error->message);
    g_error_free(error);
    exit(EXIT_FAILURE);
  }

  /* create pty object */
  VtePty* pty = vte_terminal_pty_new(vte, VTE_PTY_NO_HELPER, &error);
  if (error) {
    g_printerr("Failed to create pty: %s\n", error->message);
    g_error_free(error);
    exit(EXIT_FAILURE);
  }
  vte_pty_set_term(pty, TT_TERMINFO);
  vte_terminal_set_pty_object(vte, pty);

  /* default shell (or command) */
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

/* exit tt; exit status of child process */
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
  gboolean version = FALSE;   // version(?)
  const GOptionEntry entries[] = {
    {"version",   'v', 0, G_OPTION_ARG_NONE,    &version,   "show version; exit", 0},
    {"execute",   'e', 0, G_OPTION_ARG_STRING,  command,    "execute command rather than shell", "COMMAND"},
    {"directory", 'd', 0, G_OPTION_ARG_STRING,  directory,  "set working dir of shell (or command given with -e)", "PATH"},
    {"keep",      'k', 0, G_OPTION_ARG_NONE,    keep,       "keep tt open after child process exits", 0},
    {"name",      'n', 0, G_OPTION_ARG_STRING,  name,       "set first value of WM_CLASS; second is 'tt'", "NAME"},
    {"title",     't', 0, G_OPTION_ARG_STRING,  title,      "set value of WM_NAME; disables window_title_cb", "TITLE"},
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
    g_print("tt " TT_VERSION "\n");
    exit(EXIT_SUCCESS);
  }
}

/* signal handler */
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

  /* command-line arguments parser vars */
  char* command = NULL;
  char* directory = NULL;
  gboolean keep = FALSE;
  char* name = NULL;
  char* title = NULL;

  gtk_init(&argc, &argv);
  parse_arguments(argc, argv, &command, &directory, &keep, &name, &title);

  /* window */
  window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
  g_signal_connect(window, "delete-event", gtk_main_quit, NULL);
  gtk_window_set_wmclass(GTK_WINDOW (window), name ? name : "tt", "tt");
  gtk_window_set_title(GTK_WINDOW (window), title ? title : "tt");
  gtk_window_set_decorated(GTK_WINDOW (window), FALSE); // uncomment to remove decorations

  /* window size (config.h) */
  gtk_window_set_default_size(GTK_WINDOW (window), TT_X_WINDOW_SIZE, TT_Y_WINDOW_SIZE);

  /* window icon (from theme) */
  icon_theme = gtk_icon_theme_get_default();
  icon = gtk_icon_theme_load_icon(icon_theme, "terminal", 48, 0, &error);
  if (error)
    g_error_free(error);
  if (icon)
    gtk_window_set_icon(GTK_WINDOW (window), icon);

  /* box */
  box = gtk_hbox_new(FALSE, 0);
  gtk_container_add(GTK_CONTAINER (window), box);

  /* vte widget */
  GtkWidget* vte_widget = vte_terminal_new();
  gtk_box_pack_start(GTK_BOX (box), vte_widget, TRUE, TRUE, 0);
  VteTerminal* vte = VTE_TERMINAL (vte_widget);
  if (!keep)
    g_signal_connect(vte, "child-exited", G_CALLBACK (vte_exit_cb), NULL);
  g_signal_connect(vte, "key-press-event", G_CALLBACK (key_press_cb), NULL);
#ifdef TT_URGENT_ON_BELL
  g_signal_connect(vte, "beep", G_CALLBACK (window_urgency_hint_cb), NULL);
  g_signal_connect(window, "focus-in-event",  G_CALLBACK (window_focus_cb), NULL);
  g_signal_connect(window, "focus-out-event", G_CALLBACK (window_focus_cb), NULL);
#endif // TT_URGENT_ON_BELL
#ifdef TT_URL_BLOCK_MOUSE
  g_signal_connect(vte, "button-press-event", G_CALLBACK (button_press_cb), NULL);
#endif // TT_URL_BLOCK_MOUSE
#ifdef TT_DYNAMIC_WINDOW_TITLE
  if (!title)
    g_signal_connect(vte, "window-title-changed", G_CALLBACK (window_title_cb), NULL);
#endif // TT_DYNAMIC_WINDOW_TITLE

  /* geometry hints (window resizing) */
  geo_hints.base_width  = vte->char_width;
  geo_hints.base_height = vte->char_height;
  geo_hints.min_width   = vte->char_width;
  geo_hints.min_height  = vte->char_height;
  geo_hints.width_inc   = vte->char_width;
  geo_hints.height_inc  = vte->char_height;
  gtk_window_set_geometry_hints(GTK_WINDOW (window), vte_widget, &geo_hints,
      GDK_HINT_RESIZE_INC | GDK_HINT_MIN_SIZE | GDK_HINT_BASE_SIZE);

  /* scrollbar */
#ifdef TT_SCROLLBAR_VISIBLE
  GtkWidget* scrollbar;
  scrollbar = gtk_vscrollbar_new(vte->adjustment);
  gtk_box_pack_start(GTK_BOX (box), scrollbar, FALSE, FALSE, 0);
#endif // TT_SCROLLBAR_VISIBLE

  vte_config(vte);
  vte_spawn(vte, directory, command, NULL);

  /* signal handler */
  signal(SIGHUP, signal_handler);
  signal(SIGINT, signal_handler);
  signal(SIGTERM, signal_handler);

  /* cleanup */
  g_free(command);
  g_free(directory);
  g_free(name);
  g_free(title);

  /* show; run main */
  gtk_widget_show_all(window);
  gtk_main();

  return EXIT_SUCCESS;
}

