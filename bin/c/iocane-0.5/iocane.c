/************************************************************************\
* IOCANE - Simulate X11 mouse events
*
* Author: Jesse McClure, copyright 2012-2013
* License: GPLv3
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*
\************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <X11/Xlib.h>

#define MAXLINE		100
#define MAXSYMLEN	12

#define HELP	\
	"IOCANE: Copyright 2012, Jesse McClure\n" \
	"See `man iocane` for commands and examples.\n"

typedef struct { KeyCode key; char *command;} Key;

static Display *dpy;
static int scr, sw, sh;
static Window root;
static Bool running = True;

static void press(int arg) {
	XEvent ev;
	memset(&ev, 0x00, sizeof(ev));
	usleep(100000);
	ev.type = ButtonPress;
	ev.xbutton.button = arg;
	ev.xbutton.same_screen = True;
	XQueryPointer(dpy,root, &ev.xbutton.root, &ev.xbutton.window,
			&ev.xbutton.x_root, &ev.xbutton.y_root, &ev.xbutton.x, 
			&ev.xbutton.y,&ev.xbutton.state);
	ev.xbutton.subwindow = ev.xbutton.window;
	while(ev.xbutton.subwindow) {
		ev.xbutton.window = ev.xbutton.subwindow;
		XQueryPointer(dpy, ev.xbutton.window, &ev.xbutton.root,
				&ev.xbutton.subwindow, &ev.xbutton.x_root, &ev.xbutton.y_root, 
				&ev.xbutton.x, &ev.xbutton.y, &ev.xbutton.state);
	}
	XSendEvent(dpy,PointerWindow,True,0xfff,&ev);
	XFlush(dpy);
	usleep(100000);
	ev.type = ButtonRelease;
	ev.xbutton.state = 0x400;
	XSendEvent(dpy,PointerWindow, True, 0xfff, &ev);
	XFlush(dpy);
}

static void command(char *line) {
	if (line[0] == '\0' || line[0] == '\n' || line[0] == '#') return;
	int x=0, y=0;
	if (line[0] > 47 && line[0] < 58) sscanf(line,"%d %d",&x,&y);
	else sscanf(line,"%*s %d %d",&x,&y);
	if (line[0] == 'p') XWarpPointer(dpy,None,root,0,0,0,0,sw,sh);
	else if (line[0] == 'b') press(x);
	else if (line[0] == 'm') XWarpPointer(dpy,None,None,0,0,0,0,x,y);
	else if (line[0] == 'c')
		XDefineCursor(dpy,root,XCreateFontCursor(dpy,x));
	else if (line[0] == 'q') running = False;
	else if (line[0] == 'e') running = False;
	else if (line[0] == 's') { sleep(x); usleep(y*1000); }
	else XWarpPointer(dpy,None,root,0,0,0,0,x,y);
	XFlush(dpy);
}

int main(int argc, const char **argv) {
	int i, mode = 0;
	FILE *input = NULL;
	if (!(dpy=XOpenDisplay(0x0))) return 1;
	scr = DefaultScreen(dpy);
	root = RootWindow(dpy,scr);
	sw = DisplayWidth(dpy,scr);
	sh = DisplayHeight(dpy,scr);
	for (i = 1; i < argc; i++) {
		if (argv[i][0] == '-') {
			if (argv[i][1] == 'h') { printf(HELP); exit(0); }
			else if (argv[i][1] == 'i') mode = 1;
			else if (argv[i][1] == 's') mode = 2;
			else if (argv[i][1] == 'c' && argc > i+1) {
				command((char *)argv[(++i)]);
				if (!mode) mode = -1;
			}
		}
		else {
			printf("in = ",argv[i]);
			input = fopen(argv[i],"r");
			if (input) mode = 3;
		}
	}
	if (mode < 0) exit(0);
	if (!input) input = stdin;
	if (mode == 0 || mode == 2 || mode == 3) {
		char line[MAXLINE+1];
		while (running && (fgets(line,MAXLINE,input)) != NULL)
			command(line);
		XCloseDisplay(dpy);
		if (mode == 3) fclose(input);
		return 0;
	}
	/* no args -> interactive mode: */
	char *dir = getenv("PWD");
	chdir(getenv("XDG_CONFIG_HOME"));
	chdir("iocane");
	FILE *rcfile = fopen("config","r");
	if (!rcfile) {
		chdir(getenv("HOME"));
		rcfile = fopen(".iocanerc","r");
	}
	if (!rcfile) rcfile = fopen("/usr/share/iocane/iocanerc","r");
	if (dir) chdir(dir);
	if (!rcfile) {
		fprintf(stderr,"IOCANE: no iocanerc file found.\n");
		XCloseDisplay(dpy);
		return 0;
	}
	Key *keys = NULL;
	KeySym keysym;
	char *line = (char *) calloc(MAXLINE+MAXSYMLEN+2,sizeof(char));
	char keystring[MAXSYMLEN];
	int j; i = 0;
	unsigned int mods[] = {0,LockMask,Mod2Mask,LockMask|Mod2Mask};
	while (fgets(line,MAXLINE+MAXSYMLEN+2,rcfile) != NULL) {
		if (line[0] == '#' || line[0] == '\n') continue;
		strncpy(keystring,line,MAXSYMLEN); *strchr(keystring,' ') = '\0';
		if ( (keysym=XStringToKeysym(keystring)) == NoSymbol ) continue;
		keys = realloc(keys,(i+1) * sizeof(Key));
		keys[i].key = XKeysymToKeycode(dpy,keysym);
		keys[i].command = (char *) calloc(strlen(line) - strlen(keystring),
				sizeof(char));
		strcpy(keys[i].command,strchr(line,' ')+1);
		for (j = 0; j < 4; j++) XGrabKey(dpy, keys[i].key, mods[j],
				root,True,GrabModeAsync, GrabModeAsync);
		i++;
	}
	int keycount = i;
	free(line);
	fclose(rcfile);	
	XEvent ev;
	XKeyEvent *e;
	while (running && !XNextEvent(dpy,&ev)) if (ev.type == KeyPress) {
		e = &ev.xkey;
		for (i = 0; i < keycount; i++)
			if (e->keycode == keys[i].key && keys[i].command)
				command(keys[i].command);
	}
	for (i = 0; i < keycount; i++) free(keys[i].command);
	free(keys);
	XCloseDisplay(dpy);
	return 0;
}

