#ifndef WIN_OPER_H
#define WIN_OPER_H
#include <fuse.h>
#include <errno.h>
char *dir_read(int wid);
int dir_write(int wid, const char *buf);

int win_mode(int wid);

int border_mode(int wid);
int border_color_mode(int wid);
char *border_color_read(int wid);
int border_color_write(int wid, const char *buf);
int border_width_mode(int wid);
char *border_width_read(int wid);
int border_width_write(int wid, const char *buf);

int geometry_mode(int wid);
int geometry_width_mode(int wid);
char *geometry_width_read(int wid);
int geometry_width_write(int wid, const char *buf);
int geometry_height_mode(int wid);
char *geometry_height_read(int wid);
int geometry_height_write(int wid, const char *buf);
int geometry_x_mode(int wid);
char *geometry_x_read(int wid);
int geometry_x_write(int wid, const char *buf);
int geometry_y_mode(int wid);
char *geometry_y_read(int wid);
int geometry_y_write(int wid, const char *buf);

int mapped_mode(int wid);
char *mapped_read(int wid);
int mapped_write(int wid, const char *buf);

int ignored_mode(int wid);
char *ignored_read(int wid);
int ignored_write(int wid, const char *buf);

int stack_mode(int wid);
char *stack_read(int wid);
int stack_write(int wid, const char *buf);

int title_mode(int wid);
char *title_read(int wid);
int title_write(int wid, const char *buf);

int class_mode(int wid);
char *class_read(int wid);
int class_write(int wid, const char *buf);
#endif
