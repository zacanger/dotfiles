#ifndef WIN_H
#define WIN_H

#define WID_STRING_LENGTH 11

void xcb_init();
void xcb_cleanup();


int focused();
int exists(int wid);
void set_width(int wid, int width);
int get_width(int wid);
void set_height(int wid, int height);
int get_height(int wid);
void set_x(int wid, int height);
int get_x(int wid);
void set_y(int wid, int height);
int get_y(int wid);
int get_border_width(int wid);
void set_border_width(int wid, int width);
void set_border_color(int wid, int width);
int get_mapped(int wid);
int get_ignored(int wid);
void kill_win(int wid);
void raise(int wid);
void lower(int wid);
void set_mapped(int wid, int mapped);
void set_ignored(int wid, int ignore);
char *get_title(int wid);
char **get_class(int wid);
int *list_windows();

#endif
