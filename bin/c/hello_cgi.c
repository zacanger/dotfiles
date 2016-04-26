/* gcc -O hello_cgi.c -s -o hello_cgi.cgi */

#include <stdio.h>

int
main(int argc, char** argv) {
  fputs("Content-type: text/plain\n\nHello.\n", stdout);
  exit(0);
}

