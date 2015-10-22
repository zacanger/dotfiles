/* Make the X cursor dance in silly ways.
   Link with -lX11 -lm for X11 and math libs
 */
#include <X11/Xlib.h>
#include <unistd.h>
#include <time.h>
#include <math.h>
#include <stdio.h>

int main(){
  Display *disp = XOpenDisplay(0);
  XSynchronize(disp, True);
  struct timespec delay = {0, 10000000};

  double x = 0, y = 0; // pixels
  double phase = 0;    // rads
  double radius = 0;  // pixels
  double turnrate = 0; // rads/sec
  double dt = 0.01;
  double t = 0;        // sec
  
  int lastx = 0;
  int lasty = 0;

  int first = 1;

  while (1){
    t+=dt;
    radius = 60 * (1 + sin( t/ 2.0));
    turnrate = 13*sin(t / 4.0);
    x = radius * cos(phase);
    y = radius * sin(phase);
    phase+=dt * turnrate;
    int currx = (int)x, curry = (int)y; //Mmmmm... curry
    if (first){
      first=0;
      lastx=currx;
      lasty = curry;
    }
    if (currx != lastx || curry != lasty){
      XWarpPointer(disp, None, None, 0, 0, 0, 0, currx - lastx, curry - lasty);
      lastx = currx;
      lasty = curry;
    }

    nanosleep(&delay, NULL);
  }
  XCloseDisplay(disp);
  return 0;
}
