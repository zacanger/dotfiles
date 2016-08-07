#include <stdio.h>

/* prints out a random temp filename */

int main(int argc, char **argv) {
  printf("%s\n", tmpnam(NULL));
  return 0;
}
