#define FUSE_USE_VERSION 26

#include <fuse.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include "akemi.h"
#include "fs.h"
#include "win.h"
#include "win_oper.h"

struct win_oper
{
	char *path;
	int (*mode)(int wid);
	char *(*read)(int wid);
	int (*write)(int wid, const char *buf);
};

static const struct win_oper akemi_win_oper[] = {
	{"", win_mode, dir_read, dir_write},
	{"/border", border_mode, dir_read, dir_write},
		{"/border/color", border_color_mode, border_color_read, border_color_write},
		{"/border/width", border_width_mode, border_width_read, border_width_write},
	{"/geometry", geometry_mode, dir_read, dir_write},
		{"/geometry/width", geometry_width_mode, geometry_width_read, geometry_width_write},
		{"/geometry/height", geometry_height_mode, geometry_height_read, geometry_height_write},
		{"/geometry/x", geometry_x_mode, geometry_x_read, geometry_x_write},
		{"/geometry/y", geometry_y_mode, geometry_y_read, geometry_y_write},
	{"/mapped", mapped_mode, mapped_read, mapped_write},
	{"/ignored", ignored_mode, ignored_read, ignored_write},
	{"/stack", stack_mode, stack_read, stack_write},
	{"/title", title_mode, title_read, title_write},
	{"/class", class_mode, class_read, class_write},
};

static int get_winid(const char *path)
{
	int wid = 0;
	if(strncmp(path, "/0x", 3) == 0)
		sscanf(path, "/0x%08x", &wid);

	if(!exists(wid))
		return -1;

	return wid;
}

static const char *get_winpath(const char *path)
{
	const char *winpath = strchr(path+1, '/');
	if(winpath==NULL)
		winpath="";
	return winpath;
}

static int akemi_getattr(const char *path, struct stat *stbuf)
{
	memset(stbuf, 0, sizeof(struct stat));
	if(strcmp(path, "/") == 0){
		stbuf->st_mode = S_IFDIR | 0700;
		stbuf->st_nlink = 2;
		return 0;
	}

	if(strcmp(path, "/focused") == 0){
		stbuf->st_mode = S_IFLNK | 0700;
		stbuf->st_nlink = 2;
		return 0;
	}

	int wid = get_winid(path);
	if(wid == -1)
		return -ENOENT;

	const char *winpath = get_winpath(path);

	int i;
	int exists = 0;
	int dir = 0;
	int index;
	for(i=0;i<sizeof(akemi_win_oper)/sizeof(struct win_oper); i++){
		if(strcmp(winpath, akemi_win_oper[i].path) == 0){
			index = i;
			exists = 1;
		}
		if((strncmp(winpath, akemi_win_oper[i].path, strlen(winpath)) == 0)
				&& (strlen(akemi_win_oper[i].path) > strlen(winpath))
				&& (strchr(akemi_win_oper[i].path+strlen(winpath)+1, '/') == NULL)
				&& ((akemi_win_oper[i].path+strlen(winpath))[0] == '/')){
			dir = 1;
			break;
		}
	}
	if(exists){
		if(dir){
			stbuf->st_mode = S_IFDIR | akemi_win_oper[index].mode(wid);
			stbuf->st_nlink = 2;
		}
		else{
			stbuf->st_mode = S_IFREG | akemi_win_oper[index].mode(wid);
			stbuf->st_nlink = 1;
			int size = 0;
			char *read_string = akemi_win_oper[index].read(wid);
			if((read_string != NULL) && (strcmp(read_string, "") != 0)){
				size = strlen(read_string);
				free(read_string);
			}
			stbuf->st_size = size;
		}
		return 0;
	}
	return -ENOENT;
}

static int akemi_readdir(const char *path, void *buf, fuse_fill_dir_t filler, off_t offset, struct fuse_file_info *fi)
{
	(void) offset;
	(void) fi;

	if(strcmp(path, "/") == 0){
		filler(buf, ".", NULL, 0);
		filler(buf, "..", NULL, 0);
		filler(buf, "focused", NULL, 0);

		int *wins = list_windows();
		int i;
		for(i=0; wins[i]; i++){
			int win = wins[i];

			char *win_string;
			win_string = malloc(sizeof(char)*(WID_STRING_LENGTH));

			sprintf(win_string, "0x%08x", win);
			filler(buf, win_string, NULL, 0);

			free(win_string);
		}
		free(wins);
		return 0;
	}

	const char *winpath = get_winpath(path);

	int exists = 0;
	int dir = 0;
	int i;
	for(i=0;i<sizeof(akemi_win_oper)/sizeof(struct win_oper); i++){
		if(strcmp(winpath, akemi_win_oper[i].path) == 0)
			exists = 1;
		if((strncmp(winpath, akemi_win_oper[i].path, strlen(winpath)) == 0)
				&& (strlen(akemi_win_oper[i].path) > strlen(winpath))
				&& (strchr(akemi_win_oper[i].path+strlen(winpath)+1, '/') == NULL)
				&& ((akemi_win_oper[i].path+strlen(winpath))[0] == '/')){
			dir = 1;
			filler(buf, akemi_win_oper[i].path+strlen(winpath)+1, NULL, 0);
		}
	}
	if(dir){
		filler(buf, ".", NULL, 0);
		filler(buf, "..", NULL, 0);
	}
	else
		return -ENOTDIR;
	if(!exists)
		return -ENOENT;
	return 0;
}

static int akemi_open(const char *path, struct fuse_file_info *fi)
{
	if(!exists(get_winid(path)))
		return -ENOENT;
	const char *winpath = get_winpath(path);
	int i;
	for(i=0;i<sizeof(akemi_win_oper)/sizeof(struct win_oper); i++){
		if(strcmp(winpath, akemi_win_oper[i].path) == 0){
			fi->nonseekable=1;
			return 0;
		}
	}
	return -ENOENT;
}

static int akemi_read(const char *path, char *buf, size_t size, off_t offset, struct fuse_file_info *fi)
{
	int wid = get_winid(path);
	if(!exists(wid))
		return -ENOENT;
	const char *winpath = get_winpath(path);
	int i;
	for(i=0;i<sizeof(akemi_win_oper)/sizeof(struct win_oper); i++){
		if(strcmp(winpath, akemi_win_oper[i].path) == 0){
			char *read_string = akemi_win_oper[i].read(wid);
			if(read_string == NULL)
				return errno;
			size_t len = strlen(read_string);
			if(size > len)
				size = len;
			memcpy(buf, read_string, size);
			free(read_string);
			return size;
		}
	}
	return -ENOENT;
}

static int akemi_write(const char *path, const char *buf, size_t size, off_t offset, struct fuse_file_info *fi)
{
	int wid = get_winid(path);
	if(!exists(wid))
		return -ENOENT;
	const char *winpath = get_winpath(path);
	int i;
	for(i=0;i<sizeof(akemi_win_oper)/sizeof(struct win_oper); i++){
		if(strcmp(winpath, akemi_win_oper[i].path) == 0){
			char *write_buf = malloc(size+1);
			sprintf(write_buf, "%.*s", (int) size, buf);
			int status = akemi_win_oper[i].write(wid, write_buf);
			free(write_buf);
			return status;
		}
	}
	return -ENOENT;
}

static int akemi_truncate(const char *path, off_t size)
{
	return 0;
}

static int akemi_rmdir(const char *path)
{
	if(strcmp(path, "/") == 0)
		return -EACCES;
	int wid = get_winid(path);
	if(!exists(wid))
		return -ENOENT;
	if(strchr(path+1, '/') == NULL){
		kill_win(wid);
		return 0;
	}
	return -EACCES;
}

int akemi_readlink(const char *path, char *buf, size_t size)
{
	if(strcmp(path, "/focused") == 0){
		sprintf(buf, "0x%08x", focused());
		return 0;
	}
	return -1;
}

static struct fuse_operations akemi_oper = {
	.destroy = akemi_cleanup,
	.truncate = akemi_truncate,
	.getattr = akemi_getattr,
	.readdir = akemi_readdir,
	.open = akemi_open,
	.read = akemi_read,
	.write = akemi_write,
	.rmdir = akemi_rmdir,
	.readlink = akemi_readlink,
};

int fuse_init(int argc, char **argv)
{
	return fuse_main(argc, argv, &akemi_oper, NULL);
}
