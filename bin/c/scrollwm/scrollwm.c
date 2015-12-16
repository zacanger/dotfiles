/*******************************************************************\
* SCROLLWM - a floating WM with a single large scrollable workspace
*
* Author: Jesse McClure, copyright 2012
* License: GPLv3
*
* Based on code from TinyWM and TTWM
* TinyWM is written by Nick Welch <mack@incise.org>, 2005.
* TTWM is written by Jesse McClure, 2011-2012
\*******************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <X11/Xlib.h>
#include <X11/keysym.h>
#include <X11/XKBlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>

#define MAX(a, b) ((a) > (b) ? (a) : (b))

#define SCWM_FLOATING	0x0001
#define SCWM_TRANSIENT	0x0003
#define SCWM_FULLSCREEN	0x0004
#define SCWM_TILED		0xFF00
#define SCWM_ANY		0xFFFF

enum {Background, Default, Target, Hidden, Normal, Sticky, Urgent, Title, TagList, LASTColor };
enum {MOff, MWMove, MWResize, MDMove, MDResize };

typedef struct {
	unsigned int mod;
	KeySym keysym;
	void (*func)(const char *);
	const char *arg;
} Key;

typedef struct {
	unsigned int mod, button;
	void (*func)(const char *);
	const char *arg;
} Button;

typedef struct Client Client;
struct Client {
	char *title;
//	int tlen;
	int x, y;
	float w, h;
	int tags, flags;
	Client *next;
	Window win;
	Window parent;
};

typedef struct Checkpoint Checkpoint;
struct Checkpoint {
	int x,y;
	float zoom;
	char key;
	Checkpoint *next;
};

static void buttonpress(XEvent *);
static void buttonrelease(XEvent *);
static void configurerequest(XEvent *);
static void destroynotify(XEvent *);
static void enternotify(XEvent *);
static void expose(XEvent *);
static void keypress(XEvent *);
static void maprequest(XEvent *);
static void motionnotify(XEvent *);
static void propertynotify(XEvent *);
static void unmapnotify(XEvent *);

static void animate(int,int);
static void animatefocus();
static void checkpoint(const char *);
static void checkpoint_set(const char *);
static void checkpoint_update(int,int,float);
static void cycle(const char *);
static void cycle_tile(const char *);
static void desktop(const char *);
static void draw(Client *);
static void focusclient(Client *);
static void fullscreen(const char *);
static Bool intarget(Client *,int);
static void killclient(const char *);
static void move(const char *);
static Bool neighbors(Client *);
static Bool onscreen(Client *);
static void quit(const char *);
static void scrollwindows(Client *,int,int);
static GC   setcolor(int);
static void shift(const char *);
static Bool swap(Client *, Client *);
static void switcher(const char *);
static void spawn(const char *);
static void tag(const char *);
static void tagconfig(const char *);
static void target(const char *);
static void tile_one(Client *);
static void tile(const char *);
static void toggletag(const char *);
static void unmanage(Client *);
static void window(const char *);
static Client *wintoclient(Window);
static void zoomwindow(Client *,float,int,int);
static void zoom(Client *,float,int,int);

static const int max_status_line = 512;
#include "config.h"

static Display * dpy;
static Window root, bar;
static Pixmap buf, sbar;
static int scr, sw, sh;
static GC gc;
#ifdef __SCWM_ICONS_H__
static Pixmap iconbuf;
static GC bgc;
#endif
static Colormap cmap;
static XFontStruct *fontstruct;
static int fontheight, barheight;
static XWindowAttributes attr;
static XButtonEvent start;
static int mousemode;
static XColor color;
static Client *clients=NULL;
static Client *focused=NULL,*slave=NULL;
static Client *nextintarg=NULL,*previntarg=NULL;
static Bool holdfocused=False;
static Checkpoint *checks=NULL;
static Bool running = True;
static int tags_stik = 0, tags_hide = 0, tags_urg = 0;
static int curtag = 0;
static int ntilemode = 0;
static char curtile[2] = "0";
static int statuswidth = 0;
static FILE *inpipe;
static char targetmode = 's';
static const char *noname_window = "(UNNAMED)";
//static Bool fullscreenstate = False;
static void (*handler[LASTEvent]) (XEvent *) = {
	[ButtonPress]		= buttonpress,
	[ButtonRelease]		= buttonrelease,
	[ConfigureRequest]	= configurerequest,
	[DestroyNotify]		= destroynotify,
	[EnterNotify]		= enternotify,
	[Expose]			= expose,
	[KeyPress]			= keypress,
	[MapRequest]		= maprequest,
	[PropertyNotify]	= propertynotify,
	[MotionNotify]		= motionnotify,
	[UnmapNotify]		= unmapnotify,
};

void animate(int tx,int ty) {
	if (!animations) {
		scrollwindows(clients,tx,ty);
		return;
	}
	int dx = (tx == 0 ? 0 : (tx > 0 ? animatespeed+1 : -(animatespeed+1)));
	int dy = (ty == 0 ? 0 : (ty > 0 ? animatespeed+1 : -(animatespeed+1)));
	while (abs(tx) > animatespeed || abs(ty) > animatespeed) {
		scrollwindows(clients,dx,dy);
		tx -= dx; ty -= dy;
		if (abs(tx) < animatespeed+1) dx = 0;
		if (abs(ty) < animatespeed+1) dy = 0;
	}
	scrollwindows(clients,tx,ty);
}

void animatefocus() {
	if ( !animations || !focused || !scrolltofocused || onscreen(focused)) return;
	int tx=-focused->x+tilegap, ty=-focused->y+(showbar?barheight:0)+tilegap;
	animate(tx,ty);
}

void buttonpress(XEvent *e) {
	XButtonEvent *ev = &e->xbutton;
	Client *c;
	if ((c=wintoclient(ev->subwindow))) focused = c;
	if (!(ev->state || focused)) return;
	int i;
	start = *ev;
	for (i = 0; i < sizeof(buttons)/sizeof(buttons[0]); i++)
		if ( (ev->button == buttons[i].button) && buttons[i].func &&
				buttons[i].mod == ((ev->state&~Mod2Mask)&~LockMask) )
			buttons[i].func(buttons[i].arg);
	if (c) focusclient(c);
	if (mousemode != MOff)
		XGrabPointer(dpy,root,True,PointerMotionMask | ButtonReleaseMask,
			GrabModeAsync,GrabModeAsync, None, None, CurrentTime);
}

void buttonrelease(XEvent *e) {
	XUngrabPointer(dpy, CurrentTime);
	mousemode = MOff;
}

static char checkpoint_helper(const char *arg) {
	if (arg == NULL) {
		XGrabKeyboard(dpy,root,True,GrabModeAsync,GrabModeAsync,CurrentTime);
		XEvent e;
		while (!XCheckTypedEvent(dpy,KeyPress,&e));
		XKeyEvent *ev = &e.xkey;
		char *cs = XKeysymToString(XkbKeycodeToKeysym(dpy,(KeyCode)ev->keycode,0,0));
		XUngrabKeyboard(dpy,CurrentTime);
		if (cs) return cs[0];
		else return '0';
	}
	else {
		return arg[0];
	}
}

void checkpoint_init() {
	int i;
	Checkpoint *cp;
	for (i = 0; i < 1 || tag_name[i-1]; i++) {
		cp = (Checkpoint *) calloc(1,sizeof(Checkpoint));
		cp->zoom = 1.0;
		cp->key =  48 + i;
		cp->y = (i > 0 ? sh*(i-1) : 0);
		cp->next = checks;
		checks = cp;
	}
}

void checkpoint(const char *arg) {
	char key = checkpoint_helper(arg);
	Checkpoint *cp;
	Client *prev = focused;
	for (cp = checks; cp; cp = cp->next) {
		if (cp->key == key) {
			animate(-cp->x,-cp->y);
			zoom(clients,1/cp->zoom,0,0);
			focused = clients;
			while (focused && !(onscreen(focused) || (focused->tags & tags_hide)) )
				focused=focused->next;
			if (focused) focusclient(focused);
			else focused=prev;
			draw(clients);
			return;
		}
	}
}

void checkpoint_set(const char *arg) {
	char key = checkpoint_helper(arg);
	if (key == '0') return; /* never reset checkpoint zero */
	Checkpoint *cp;
	for (cp = checks; cp; cp = cp->next)
		if (cp->key == key) {
			cp->x = 0;
			cp->y = 0;
			cp->zoom = 1.0;
			return;
		}
	cp = (Checkpoint *) calloc(1,sizeof(Checkpoint));
	cp->next = checks;
	cp->zoom = 1.0;
	cp->key = key;
	checks = cp;
}

void checkpoint_update(int x, int y, float zoom) {
	Checkpoint *cp;
	for (cp = checks; cp; cp = cp->next) {
		if (zoom != 1) {
			cp->zoom*=zoom;
			cp->x = (cp->x-x)*zoom + x;
			cp->y = (cp->y-y)*zoom + y;
		}
		else {
			cp->x+=x;
			cp->y+=y;
		}
	}
}

void configurerequest(XEvent *e) {
	XWindowChanges wc;
	XConfigureRequestEvent *ev = &e->xconfigurerequest;
	Client *c;
	if ( (c=wintoclient(ev->window)) && (ev->x==0) && (ev->y==0) &&
			(ev->width==sw) && (ev->height==sh) ) {
		focusclient(c);
		fullscreen(NULL);
		return;
	}
	wc.x = ev->x; wc.y = ev->y;
	wc.width = ev->width; wc.height = ev->height;
	wc.border_width = borderwidth;
	wc.sibling = ev->above;
	wc.stack_mode = e->xconfigurerequest.detail;
	XConfigureWindow(dpy, ev->window, ev->value_mask, &wc);
	XFlush(dpy);
}

void cycle(const char *arg) {
	if (!focused) return;
	Client *prev = focused;
	char tm;
	if (arg == NULL) tm = targetmode;
	else tm = arg[0];
	if (tm == 'a') {
		focused = focused->next;
		if (!focused) focused = clients;
	}
	else if (tm == 'v') {
		while ( (focused=focused->next) && (focused->tags & tags_hide) );
		if (!focused) {
			focused = clients;
			if (clients && (clients->tags & tags_hide) )
				while ((focused=focused->next)->tags & tags_hide );
		}
	}
	else if (tm == 's') {
		while (focused && (!onscreen(focused=focused->next) || (focused->tags & tags_hide)) );
		if (!focused) {
			if ( !onscreen(focused=clients) || (focused->tags & tags_hide) )
				while (focused && (!onscreen(focused=focused->next) || (focused->tags & tags_hide)) );
		}
	}
	else if (tm == 't') {
		while ( (focused=focused->next) && !(focused->tags & prev->tags) );
		if (!focused) {
			focused = clients;
			if ( clients && !(clients->tags & prev->tags) )
				while ( (focused=focused->next) && !(focused->tags & prev->tags) );
		}
	}
	else if (tm == 'o') {
		if (!focused || !slave) return;
		if (focused == slave)
			for (focused = clients; !onscreen(focused); focused = focused->next);
		else
			focused = slave;
	}
	if (!focused) focused = prev;
	focusclient(focused);
	animatefocus();
	draw(clients);
}

void cycle_tile(const char *arg) {
	if (!tile_modes[++ntilemode]) ntilemode=0;
	tile(tile_modes[ntilemode]);
}

void destroynotify(XEvent *e) {
	Client *c;
	if (!(c=wintoclient(e->xunmap.window))) return;
	if (!e->xunmap.send_event) unmanage(c);
}

void desktop(const char *arg) {
	if (arg[0] == 'm') mousemode = MDMove;
	else if (arg[0] == 'r') mousemode = MDResize;
	else if (arg[0] == 'g') zoom(clients,1.1,start.x_root,start.y_root);
	else if (arg[0] == 's') zoom(clients,.92,start.x_root,start.y_root);
}

void draw(Client *stack) {
	if (focused) tags_urg &= ~focused->tags;
	tags_urg &= ~(1<<curtag);
	/* WINDOWS */
	int tags_occ = 0;
	int loc[9] = {0,0,0,0,0,0,0,0,0}, cx,cy;
	XSetWindowAttributes wa;
	while (stack) {
		cx = stack->x + stack->w/2;
		cy = stack->y + stack->h/2;
		loc[(cx<0?0:(cx<sw?1:2))*3 + (cy<0?0:(cy<sh?1:2))]++;
		tags_occ |= stack->tags;
		if (stack->tags & tags_hide) {
			XMoveWindow(dpy,stack->win,sw+2,0);
			stack = stack->next;
			continue;
		}
		XMoveResizeWindow(dpy,stack->win,stack->x,stack->y,
			MAX(stack->w,win_min),MAX(stack->h,win_min));
		setcolor( (highlightfocused && stack == focused ? Hidden :
			(stack->tags & tags_stik ? Sticky : Normal)) );
		wa.border_pixel = color.pixel;
		XChangeWindowAttributes(dpy,stack->win,CWBorderPixel,&wa);
		stack = stack->next;
	}
	/* STATUS BAR */
	XFillRectangle(dpy,buf,setcolor(Background),0,0,sw,barheight);
	/* tags */
	int i, x=10,w=0;
	int col;
	for (i = 0; tag_name[i]; i++) {
		if (!(tags_occ & (1<<i)) && curtag != i) continue;
		col = (tags_urg & (1<<i) ? Urgent :
				(tags_hide & (1<<i) ? Hidden :
				(tags_stik & (1<<i) ? Sticky : 
				(tags_occ  & (1<<i) ? Normal : Default ))));
		XDrawString(dpy,buf,setcolor(col),x,fontheight,tag_name[i],strlen(tag_name[i]));
		w = XTextWidth(fontstruct,tag_name[i],strlen(tag_name[i]));
		if (curtag == i)
			XFillRectangle(dpy,buf,gc,x-2,fontheight+1,w+4,barheight-fontheight);
		x+=w+10;
	}
	/* overview "icon" and target indicator*/
	if (clients) {
		x = MAX(x+20,sw/10);
		XDrawRectangle(dpy,buf,setcolor(Default),x,fontheight-9,6,6);
		XDrawRectangle(dpy,buf,gc,x,fontheight-6,6,6);
		XDrawRectangle(dpy,buf,gc,x+3,fontheight-9,6,6);
		XDrawRectangle(dpy,buf,gc,x+3,fontheight-6,6,6);
		setcolor(Hidden);
		for (i = 0; i < 3; i++) for (w = 0; w < 3; w++) if (loc[i*3+w])
			XFillRectangle(dpy,buf,gc,x+3*i,fontheight-9+3*w,4,4);
		x+=18;
	}
	setcolor(Target);
	if (targetmode == 't') XDrawString(dpy,buf,gc,x,fontheight,"[tag]",5);
	else if (targetmode == 'v') XDrawString(dpy,buf,gc,x,fontheight,"[vis]",5);
	if (targetmode != 's') x += XTextWidth(fontstruct,"[all]",4) + 18;
	/* title */
	if (focused) {
		setcolor(Title);
		XDrawString(dpy,buf,gc,x,fontheight,focused->title,strlen(focused->title));
		x += XTextWidth(fontstruct,focused->title,strlen(focused->title)) + 10;
		XDrawString(dpy,buf,setcolor(TagList),x,fontheight,"[",1);
		x += XTextWidth(fontstruct,"[",1);
		/* tag list */
		for (i = 0; tag_name[i]; i++) if (focused->tags & (1<<i)) {
			XDrawString(dpy,buf,gc,x,fontheight,tag_name[i],strlen(tag_name[i]));
			x += XTextWidth(fontstruct,tag_name[i],strlen(tag_name[i]));
			XDrawString(dpy,buf,gc,x,fontheight,", ",2);
			w = XTextWidth(fontstruct,", ",2);
			x += w;
		}
		x -= w;
		XFillRectangle(dpy,buf,setcolor(Background),x,0,10,barheight);
		XDrawString(dpy,buf,setcolor(TagList),x,fontheight,"]",1);
	}
	/* USER STATUS INFO */
	if (statuswidth)
		XCopyArea(dpy,sbar,buf,gc,0,0,statuswidth,barheight,sw-statuswidth,0);
	XCopyArea(dpy,buf,bar,gc,0,0,sw,barheight,0,0);
	XFlush(dpy);
}

void enternotify(XEvent *e) {
	if (!focusfollowmouse) return;
	Client *c = wintoclient(e->xcrossing.window);
	if (c) {
		focusclient(c);
		draw(clients);
	}
}

void expose(XEvent *e) {
	draw(clients);
}

void focusclient(Client *c) {
	focused = c;
	if (!c) return;
	XSetInputFocus(dpy,c->win,RevertToPointerRoot,CurrentTime);
	XRaiseWindow(dpy,c->win);
neighbors(c);
if (previntarg) slave = c;
	if (!(c->flags & SCWM_FULLSCREEN)) XRaiseWindow(dpy,bar);
}

static void fullscreen(const char *arg) {
	if (!focused) return;
	static int wx,wy,ww,wh;
	if ( !(focused->flags & SCWM_FULLSCREEN) ) {
		focused->flags |= SCWM_FULLSCREEN;
		wx=focused->x; wy=focused->y;
		ww=focused->w; wh=focused->h;
		focused->x = -borderwidth; focused->y = -borderwidth;
		focused->w = sw; focused->h = sh;
		XRaiseWindow(dpy,focused->win);
	}
	else {
		focused->flags &= ~SCWM_FULLSCREEN;
		XRaiseWindow(dpy,bar);
		focused->x = wx; focused->y = wy;
		focused->w = ww; focused->h = wh;
	}
	draw(clients);
}

Bool intarget(Client *c,int flags) {
	char tm = targetmode;
	if (c->flags & ~flags) return False;
	else if (tm == 'a') return True;
	else if (tm == 's') return onscreen(c);
	else if (tm == 't') return (c->tags & (1<<curtag));
	else if (tm == 'v') return (c->tags & ~tags_hide);
	else return False;
}

void keypress(XEvent *e) {
	unsigned int i;
	XKeyEvent *ev = &e->xkey;
	KeySym keysym = XkbKeycodeToKeysym(dpy,(KeyCode)ev->keycode,0,0);
	for (i = 0; i < sizeof(keys)/sizeof(keys[0]); i++)
		if ( (keysym==keys[i].keysym) && keys[i].func &&
				keys[i].mod == ((ev->state&~Mod2Mask)&~LockMask) )
			keys[i].func(keys[i].arg);
}

void killclient(const char *arg) {
        if (!focused) return;
        XEvent ev;
        ev.type = ClientMessage;
        ev.xclient.window = focused->win;
        ev.xclient.message_type = XInternAtom(dpy, "WM_PROTOCOLS", True);
        ev.xclient.format = 32;
        ev.xclient.data.l[0] = XInternAtom(dpy, "WM_DELETE_WINDOW", True);
        ev.xclient.data.l[1] = CurrentTime;
        XSendEvent(dpy,focused->win,False,NoEventMask,&ev);
}

void maprequest(XEvent *e) {
	Client *c,*parent;
	static XWindowAttributes wa;
	Bool fsme = False;
	XMapRequestEvent *ev = &e->xmaprequest;
	if (!XGetWindowAttributes(dpy, ev->window, &wa)) return;
	if (wa.override_redirect) return;
	if (!wintoclient(ev->window)) {
		if (!(c=calloc(1,sizeof(Client)))) exit(1);
		c->win = ev->window;
		XGetWindowAttributes(dpy,c->win, &attr);
		c->x = attr.x; c->y = attr.y;
		c->w = attr.width; c->h = attr.height;
		if ( (c->x==0) && (c->y==0) && (c->w==sw) && (c->h==sh) ) fsme = True;
		if (c->y < (topbar ? barheight : 0) +tilegap && showbar) {
			c->y = (topbar ? barheight : 0) + tilegap;
			c->x = tilegap;
		}
		c->tags = (1<<curtag);
		if (XGetTransientForHint(dpy,c->win,&c->parent))
			c->flags |= SCWM_TRANSIENT;
		else
			c->parent = ev->parent;
		if ( !(XFetchName(dpy,c->win,&c->title)) || c->title == NULL ) {
			if ( (parent=wintoclient(c->parent)) )
				c->title = strdup(parent->title);
			else
				c->title = strdup(noname_window);
		}
		// get _NET_WM_WINDOW_TYPE - set SCWM_FLOATING
		XSelectInput(dpy,c->win,PropertyChangeMask | EnterWindowMask);
		c->next = clients;
		clients = c;
		XSetWindowBorderWidth(dpy,c->win,borderwidth);
		XMapWindow(dpy,c->win);
		focusclient(c);
	}
	if (fsme) fullscreen(NULL);
	else if (autoretile) tile(curtile);
	draw(clients);
}

void move(const char *arg) {
	if (arg[0] == 'L') animate(sw,0);
	else if (arg[0] == 'R') animate(-sw,0);
	else if (arg[0] == 'U') animate(0,sh);
	else if (arg[0] == 'D') animate(0,-sh);
	else if (arg[0] == 'l') animate(25,0);
	else if (arg[0] == 'r') animate(-25,0);
	else if (arg[0] == 'u') animate(0,25);
	else if (arg[0] == 'd') animate(0,-25);
}

void motionnotify(XEvent *e) {
	int xdiff, ydiff;
	while(XCheckTypedEvent(dpy,MotionNotify,e));
	xdiff = e->xbutton.x_root - start.x_root;
	ydiff = e->xbutton.y_root - start.y_root;
if (activeedges) {
if (mousemode == MWMove) holdfocused=True; 
if (e->xbutton.x_root > sw-2) {
	move("Right");
	XWarpPointer(dpy,None,root,0,0,0,0,e->xbutton.x_root-4,e->xbutton.y_root);
}
else if (e->xbutton.x_root < 1) {
	move("Left");
	XWarpPointer(dpy,None,root,0,0,0,0,4,e->xbutton.y_root);
}
if (e->xbutton.y_root > sh-2) {
	move("Down");
	XWarpPointer(dpy,None,root,0,0,0,0,e->xbutton.x_root,e->xbutton.y_root-4);
}
else if (e->xbutton.y_root < 1) {
	move("Up");
	XWarpPointer(dpy,None,root,0,0,0,0,e->xbutton.x_root,4);
}
XFlush(dpy);
holdfocused=False; 
}
	if (mousemode == MWMove) {
		focused->x+=xdiff; focused->y+=ydiff; draw(clients);
	}
	else if (mousemode == MWResize) {
		focused->w+=xdiff; focused->h+=ydiff; draw(clients);
	}
	else if (mousemode == MDMove) {
		scrollwindows(clients,xdiff,ydiff);
	}
	start.x_root+=xdiff; start.y_root+=ydiff;
}

Bool neighbors(Client *c) {
	previntarg = NULL;
	nextintarg = NULL;
	if (!intarget(c,SCWM_ANY)) return False;
	Client *stack;
	for (stack = clients; stack && stack != c; stack = stack->next) {
		if (	(targetmode == 'a') || (targetmode == 's' && onscreen(stack))	||
				(targetmode == 't' && (stack->tags & (1<<curtag)))				||
				(targetmode == 'v' && (stack->tags & ~tags_hide))				)
			previntarg = stack;
	}
	for (nextintarg = stack->next;
		nextintarg && !(
			(targetmode == 'a') || (targetmode == 's' && onscreen(nextintarg)) ||
			(targetmode == 't' && (nextintarg->tags & (1<<curtag))) ||
			(targetmode == 'v' && (nextintarg->tags & ~tags_hide))
		);
		nextintarg = nextintarg->next);
	return True;
}

Bool onscreen(Client *c) {
	if (!c) return False;
	if ((c->x + c->w/2) > 0 && (c->x + c->w/2) < sw	&&
		(c->y + c->h/2) > 0 && (c->y + c->h/2) < sh )
		return True;
	return False;
}

void propertynotify(XEvent *e) {
    XPropertyEvent *ev = &e->xproperty;
    Client *c,*parent;
    if ( !(c=wintoclient(ev->window)) ) return;
    if (ev->atom == XA_WM_NAME) {
        XFree(c->title); c->title = NULL;
		if ( !(XFetchName(dpy,c->win,&c->title)) || c->title == NULL ) {
			if ( (parent=wintoclient(c->parent)) )
				c->title = strdup(parent->title);
			else
				c->title = strdup(noname_window);
		}
        draw(clients);
    }
    else if (ev->atom == XA_WM_HINTS) {
        XWMHints *hint;
        if ( (hint=XGetWMHints(dpy,c->win)) && (hint->flags & XUrgencyHint) )
			tags_urg |= c->tags;
        draw(clients);
    }
}

void quit(const char *arg) {
	running = False;
}

GC setcolor(int col) {
	XAllocNamedColor(dpy,cmap,colors[col],&color,&color);
	XSetForeground(dpy,gc,color.pixel);
	return gc;
}

void scrollwindows(Client *stack, int x, int y) {
	while (stack) {
		if (holdfocused && focused && stack==focused) {
			stack = stack->next;
			continue;
		}
		if (!(stack->tags & tags_stik)) {
			stack->x+=x;
			stack->y+=y;
		}
		stack = stack->next;
	}
	checkpoint_update(x,y,1);
	draw(clients);
}

void spawn(const char *arg) {
	system(arg);
}

void status(char *msg) {
	char *col = (char *) calloc(8,sizeof(char));
	char *t,*c = msg;
	int l;
#ifdef __SCWM_ICONS_H__
	int arg;
#endif
	XColor color;
	statuswidth = 0;
	XFillRectangle(dpy,sbar,setcolor(Background),0,0,sw/2,barheight);
	setcolor(Default);
	while(*c != '\n') {
		if (*c == '{') {
			if (*(++c) == '#') {
				strncpy(col,c,7);
				XAllocNamedColor(dpy,cmap,col,&color,&color);
				XSetForeground(dpy,gc,color.pixel);
			}
#ifdef __SCWM_ICONS_H__
			else if ( (*c == 'i') && (sscanf(c,"i %d",&arg) == 1) ) {
				XFillRectangle(dpy,iconbuf,bgc,0,0,iconwidth,iconheight);
				XDrawPoints(dpy,iconbuf,gc,icons[arg].pts,icons[arg].n,CoordModeOrigin);
				XCopyArea(dpy,iconbuf,sbar,gc,0,0,iconwidth,iconheight,statuswidth,(barheight-iconheight)/2);
				statuswidth+=iconwidth+1;
			}
#endif /* __SCWM_ICONS_H__ */
			c = strchr(c,'}')+1;
		}
		else {
			if ((t=strchr(c,'{'))==NULL) t=strchr(c,'\n');
			l = (t == NULL ? 0 : t-c);
			if (l) {
				XDrawString(dpy,sbar,gc,statuswidth,fontheight,c,l);
				statuswidth+=XTextWidth(fontstruct,c,l);
			}
			c+=l;
		}
	}
	free(col);
	draw(clients);
}

void shift(const char *arg) {
	if (!focused) return;
	neighbors(focused);
	if (arg[0] == 'l' && swap(focused,previntarg))
		focused = previntarg;
	else if (arg[0] == 'r' && swap(focused,nextintarg))
		focused = nextintarg;
	draw(clients);
}

Bool swap(Client *a, Client *b) {
	if (!a || !b) return False;
	Client t;
	t.title = a->title; a->title=b->title; b->title = t.title;
//	t.tlen = a->tlen; a->tlen=b->tlen; b->tlen = t.tlen;
	t.tags = a->tags; a->tags=b->tags; b->tags = t.tags;
	t.win = a->win; a->win=b->win; b->win = t.win;
	return True;
}

void switcher(const char *arg) {
	Client *stack, *selclient = NULL;
	int n, sel = 0;
	KeySym ks;
	XEvent e;
	XKeyEvent *ev;
	for (n = 0, stack = clients; stack; n++, stack = stack->next);
	if (n == 0) return;
	XMoveResizeWindow(dpy,bar,0,(topbar ? 0 : sh-(n+3)*barheight),sw,(n+3)*barheight);
	XFillRectangle(dpy,bar,setcolor(Background),0,barheight,sw,(n+2)*barheight);
	XDrawLine(dpy,bar,setcolor(Title),10,barheight+2,sw-20,barheight+2);
	XFillRectangle(dpy,bar,gc,0,(n+3)*barheight-2,sw,2);
	XGrabKeyboard(dpy,root,True,GrabModeAsync,GrabModeAsync,CurrentTime);
	while (True) {
		XFillRectangle(dpy,bar,setcolor(Background),0,barheight+4,
			sw,(n+2)*barheight-8);
		for (n = 0, stack = clients; stack; n++, stack = stack->next) {
			if (sel == n) {
				setcolor(Target);
				selclient = stack;
			}
			else if (stack->flags & tags_hide) setcolor(Hidden);
			else if (stack->flags & tags_stik) setcolor(Sticky);
			else if (onscreen(stack)) setcolor(Title);
			else setcolor(Default);
			XDrawString(dpy,bar,gc,10,(n+3)*barheight,
				stack->title,strlen(stack->title));
		}
		draw(clients);
		XFlush(dpy);
		XMaskEvent(dpy,KeyPress, &e);
		ev = &e.xkey;
		ks = XkbKeycodeToKeysym(dpy,(KeyCode)ev->keycode,0,0);
		if (ks == XK_q) break;
		else if (ks == XK_Return) {
			if (selclient) {
				focusclient(selclient);
				animatefocus();
			}
			break;
		}
		else if (ks == XK_Down || ks == XK_j) sel++;
		else if (ks == XK_Up || ks == XK_k) sel--;
		else continue;
		if (sel < 0) sel = 0;
		else if (sel >= n) sel = n-1;
	}
	XUngrabKeyboard(dpy,CurrentTime);
	XMoveResizeWindow(dpy,bar,0,(showbar?(topbar?0:sh-barheight):-barheight),sw,barheight);
}

void tag(const char *arg) {
	curtag = arg[0] - 49;
	tags_urg &= ~(1<<curtag);
	Client *c, *t=NULL;
	if (tagpoints)
		checkpoint(arg);
	else if (clients) {
		for (c = clients; c; c = c->next) if (c->tags & (1<<curtag)) {
			if (!t) t = c;
			XRaiseWindow(dpy,c->win);
		}
		XRaiseWindow(dpy,bar);
		if (! (focused->tags & (1<<curtag)) && t ) focused = t;
		focusclient(focused);
	}
	draw(clients);
}

void tagconfig(const char *arg) {
	int i;
	if (arg[0] == 'h') tags_hide |= (1<<curtag);
	else if (arg[0] == 's') tags_stik |= (1<<curtag);
	else if (arg[0] == 'n') {
		tags_stik &= ~(1<<curtag);
		tags_hide &= ~(1<<curtag);
	}
	else if (arg[0] == 't')
		showbar = !showbar;
	else if (arg[0] == 'm')
		topbar = !topbar;
	else if (arg[0] == 'o') for (i = 0; tag_name[i]; i++) {
		if (i != curtag) tags_hide |= (1<<i);
		else tags_hide &= ~(1<<i);
	}
	if (showbar) XMoveWindow(dpy,bar,0,(topbar ? 0 : sh - barheight));
	else XMoveWindow(dpy,bar,0,(topbar ? -barheight: sh));
	if (autoretile) tile(curtile);
	else draw(clients);
}

void target(const char *arg) {
	targetmode = arg[0];
	draw(clients);
}

void tile_one(Client *stack) {
	while (!intarget(stack,SCWM_TILED)) stack=stack->next;
	stack->x = tilegap;
	stack->y = (showbar && topbar ? barheight : 0) + tilegap;
	stack->w = sw - 2*(tilegap + borderwidth);
	stack->h = sh - (showbar ? barheight: 0) - 2*(tilegap + borderwidth);
	slave = stack;
}

void tile_bstack(Client *stack, int count) {
	while (!intarget(stack,SCWM_TILED)) stack=stack->next;
	int w = (sw - tilegap)/(count-1);
	int h = (sh - (showbar && topbar ? barheight : 0) - tilegap)/2 - (tilegap + 2*borderwidth);
	stack->x = tilegap;
	stack->y = (showbar && topbar ? barheight : 0) + tilegap;
	stack->w = sw - 2*(tilegap + borderwidth);
	stack->h = h + tilebias;
	int i=0;
	while ((stack=stack->next)) {
		if (!intarget(stack,SCWM_TILED)) continue;
		stack->x = tilegap + i*w;
		stack->y = (showbar && topbar ? barheight : 0) + h + 2*(tilegap+borderwidth) + tilebias;
		stack->w = MAX(w - tilegap - 2*borderwidth,win_min);
		stack->h = h - tilebias;
		i++;
		if (!stack->next) stack->w = MAX(sw - stack->x - tilegap - 2*borderwidth,win_min);
	}
}

void tile_flow(Client *stack, int count) {
	int x = 0;
	while (stack) {
		if (!intarget(stack,SCWM_TILED)) {
			stack = stack->next;
			continue;
		}
		stack->x = tilegap + sw*(x++);
		stack->y = (showbar && topbar ? barheight : 0) + tilegap;
		stack->w = sw - 2*(tilegap + borderwidth);
		stack->h = sh - (showbar ? barheight: 0) - 2*(tilegap + borderwidth);
		stack = stack->next;
	}
}

void tile_monocle(Client *stack,int count) {
	while (stack) {
		if (!intarget(stack,SCWM_TILED)) {
			stack = stack->next;
			continue;
		}
		tile_one(stack);
		stack = stack->next;
	}
}


void tile_rstack(Client *stack, int count) {
	while (!intarget(stack,SCWM_TILED)) stack=stack->next;
	int w = (sw - tilegap)/2 - (tilegap + 2*borderwidth);
	int h = (sh - (showbar && topbar ? barheight : 0) - tilegap)/(count-1);
	stack->x = tilegap;
	stack->y = (showbar && topbar ? barheight : 0) + tilegap;
	stack->w = w + tilebias;
	stack->h = sh - (showbar ? barheight: 0) - 2*(tilegap + borderwidth);
	int i=0;
	while ((stack=stack->next)) {
		if (!intarget(stack,SCWM_TILED)) continue;
		stack->x = w + 2*(tilegap+borderwidth) + tilebias;
		stack->y = (showbar && topbar ? barheight : 0) + tilegap + i*h;
		stack->w = w - tilebias;
		stack->h = MAX(h - tilegap - 2*borderwidth,win_min);
		i++;
		if (!stack->next)
			stack->h = MAX(sh - (showbar ? (topbar ? 0: barheight) : 0)
				- stack->y - tilegap - 2*borderwidth,win_min);
	}
}

void tile_ttwm(Client *stack, int count) {
	while (!intarget(stack,SCWM_TILED)) stack=stack->next;
	int w = (sw - tilegap)/2 - (tilegap + 2*borderwidth);
	stack->x = tilegap;
	stack->y = (showbar && topbar ? barheight : 0) + tilegap;
	stack->w = w + tilebias;
	stack->h = sh - (showbar ? barheight: 0) - 2*(tilegap + borderwidth);
	int i=0;
	XRaiseWindow(dpy,stack->next->win);
	XRaiseWindow(dpy,bar);
	while ((stack=stack->next)) {
		if (!intarget(stack,SCWM_TILED)) continue;
		stack->x = w + 2*(tilegap+borderwidth) + tilebias;
		stack->y = (showbar && topbar ? barheight : 0) + tilegap;
		stack->w = w - tilebias;
		stack->h = sh - (showbar ? barheight: 0) - 2*(tilegap + borderwidth);
		i++;
	}
}

void tile(const char *arg) {
	int i = 0;
	Client *c;
	if (arg[0] != 'i' && arg[0] != 'd' && arg[0] != 'a') curtile[0] = arg[0];
	for (c = clients; c; c = c->next)
		if (intarget(c,SCWM_TILED)) i++;
	if (i == 0) return;
	else if (i == 1) { tile_one(clients); draw(clients); return; }
	if (arg[0] == 't') tile_ttwm(clients,i);
	else if (arg[0] == 'r') tile_rstack(clients,i);
	else if (arg[0] == 'b') tile_bstack(clients,i);
	else if (arg[0] == 'm') tile_monocle(clients,i);
	else if (arg[0] == 'f') tile_flow(clients,i);
	else if (arg[0] == 'i') {
		tilebias += 4;
		tile(curtile);
	}
	else if (arg[0] == 'd') {
		tilebias -= 4;
		tile(curtile);
	}
	else if (arg[0] == 'a') {
		if ( (autoretile=~autoretile) )
			tile(curtile);
	}
	else return;
	draw(clients);
}

void toggletag(const char *arg) {
	if (!focused) return;
	int t = arg[0] - 49;
	focused->tags = focused->tags ^ (1<<t);
	draw(clients);
}

void unmanage(Client *c) {
	Client *t;
//	Bool retile = (autoretile ? !(c->flags & ~SCWM_TILED) : False);
	if (c == focused) {
		neighbors(c);
		if (nextintarg) focusclient(nextintarg);
		else if (previntarg) focusclient(previntarg);
		else focusclient(NULL);
	}
	if (c == clients) clients = c->next;
	else {
		for (t = clients; t && t->next != c; t = t->next);
		t->next = c->next;
	}
	XFree(c->title);
	free(c);
	c = NULL;
	if (!focused) {
		focused=clients;
	//	cycle("screen");
	}
	if (autoretile) tile(curtile);
	draw(clients);
}

void unmapnotify(XEvent *e) {
	Client *c;
	if (!(c=wintoclient(e->xunmap.window))) return;
	if (!e->xunmap.send_event) unmanage(c);
}

void window(const char *arg) {
	if (arg[0] == 'm') mousemode = MWMove;
	else if (arg[0] == 'r') mousemode = MWResize;
	else if (arg[0] == 'g') zoomwindow(focused,1.1,start.x_root,start.y_root);
	else if (arg[0] == 's') zoomwindow(focused,.92,start.x_root,start.y_root);
	else if (arg[0] == 'z') {
		focused->x=-borderwidth; focused->w=sw;
		focused->y=(showbar && topbar ? barheight : 0)-borderwidth;
		focused->h=(showbar ? sh-barheight : sh) + borderwidth;
	}
}

Client *wintoclient(Window w) {
	Client *c;
	for (c = clients; c && c->win != w; c = c->next);
	if (c) return c;
	else return NULL;
}

void zoomwindow(Client *c, float factor, int x, int y) {
	c->w *= factor; c->h *= factor;
	if (c->w < zoom_min) c->w = zoom_min;
	if (c->h < zoom_min) c->h = zoom_min;
	c->x = (c->x-x) * factor + x;
	c->y = (c->y-y) * factor + y;
}


void zoom(Client *stack, float factor, int x, int y) {
	while (stack) {
		if (!(stack->tags & tags_stik)) zoomwindow(stack,factor,x,y);
		stack = stack->next;
	}
	checkpoint_update(x,y,factor);
	draw(clients);
}

int xerror(Display *d, XErrorEvent *ev) {
	char msg[1024];
	XGetErrorText(dpy,ev->error_code,msg,sizeof(msg));
	fprintf(stderr,"====== SCROLLWM ERROR =====\nrequest=%d error=%d\n%s\n===========================\n",
		ev->request_code,ev->error_code,msg);
	return 0;
}


int main(int argc, const char **argv) {
	if (argc > 1) inpipe = popen(argv[1],"r");
	else inpipe = stdin;
	/* init X */
    if(!(dpy = XOpenDisplay(0x0))) return 1;
	scr = DefaultScreen(dpy);
	sw = DisplayWidth(dpy,scr);
	sh = DisplayHeight(dpy,scr);
    root = DefaultRootWindow(dpy);
	XSetErrorHandler(xerror);
	XDefineCursor(dpy,root,XCreateFontCursor(dpy,scrollwm_cursor));
	/* gc init */
	cmap = DefaultColormap(dpy,scr);
	XGCValues val;
	val.font = XLoadFont(dpy,font);
	fontstruct = XQueryFont(dpy,val.font);
	fontheight = fontstruct->ascent+1;
	barheight = fontstruct->ascent+fontstruct->descent+2;
	gc = XCreateGC(dpy,root,GCFont,&val);
	/* buffers and windows */
	bar = XCreateSimpleWindow(dpy,root,0,(topbar ? 0 : sh-barheight),sw,barheight,0,0,0);
	buf = XCreatePixmap(dpy,root,sw,barheight,DefaultDepth(dpy,scr));
	sbar = XCreatePixmap(dpy,root,sw/2,barheight,DefaultDepth(dpy,scr));
#ifdef __SCWM_ICONS_H__
	XAllocNamedColor(dpy,cmap,colors[Background],&color,&color);
	bgc = DefaultGC(dpy,scr);
	XSetForeground(dpy,bgc,color.pixel);
	iconbuf = XCreatePixmap(dpy,root,iconwidth,iconheight,DefaultDepth(dpy,scr));
#endif
	XSetWindowAttributes wa;
	wa.override_redirect = True;
	wa.event_mask = ExposureMask;
	XChangeWindowAttributes(dpy,bar,CWOverrideRedirect|CWEventMask,&wa);
	XMapWindow(dpy,bar);
	wa.event_mask = FocusChangeMask | SubstructureNotifyMask | ButtonPressMask |
			ButtonReleaseMask | PropertyChangeMask | SubstructureRedirectMask |
			StructureNotifyMask;
	XChangeWindowAttributes(dpy,root,CWEventMask,&wa);
	XSelectInput(dpy,root,wa.event_mask);
	/* checkpoint init */
	checkpoint_init();
	/* key and mouse binding */
	unsigned int mods[] = {0, LockMask, Mod2Mask, LockMask|Mod2Mask};
	KeyCode code;
	XUngrabKey(dpy,AnyKey,AnyModifier,root);
	int i,j;
	for (i = 0; i < sizeof(keys)/sizeof(keys[0]); i++)
		if ( (code=XKeysymToKeycode(dpy,keys[i].keysym)) ) for (j = 0; j < 4; j++)
			XGrabKey(dpy,code,keys[i].mod|mods[j],root,True,
				GrabModeAsync,GrabModeAsync);
	for (i = 0; i < sizeof(buttons)/sizeof(buttons[0]); i++) for (j = 0; j < 4; j++)
		if (buttons[i].mod)
	    XGrabButton(dpy,buttons[i].button,buttons[i].mod,root,True,ButtonPressMask,
			GrabModeAsync,GrabModeAsync,None,None);
	/* main loop */
	curtile[0] = tile_modes[0][0];
	draw(clients);
    XEvent ev;
	int xfd, sfd;
	fd_set fds;
	sfd = fileno(inpipe);
	xfd = ConnectionNumber(dpy);
	char *line = (char *) calloc(max_status_line+1,sizeof(char));
	while (running) {
		FD_ZERO(&fds);
		FD_SET(sfd,&fds);
		FD_SET(xfd,&fds);
		select(xfd+1,&fds,0,0,NULL);
		if (FD_ISSET(xfd,&fds)) while (XPending(dpy)) {
			XNextEvent(dpy,&ev);
			if (handler[ev.type]) handler[ev.type](&ev);
		}
		if (FD_ISSET(sfd,&fds)) {
			if (fgets(line,max_status_line,inpipe))
				status(line);
		}
	}
	/* clean up */
	Checkpoint *cp = checks;
	while (checks) {
		cp = checks;
		checks = checks->next;
		free(cp);
	}
	free(line);
	XFreeFontInfo(NULL,fontstruct,1);
	XUnloadFont(dpy,val.font);
	return 0;
}

// vim: ts=4


