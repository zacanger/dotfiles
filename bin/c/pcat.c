#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>

/* Persistent cat: read an input file, retrying reads which lead to an error.
 * Copyright 2003 Adam Sampson <ats@offog.org>
 */

const char *name;
int fd = -1;

void die(int err, const char *s) {
  fprintf(stderr, "%s", s);
  if (err) fprintf(stderr, ": %s", strerror(errno));
  fprintf(stderr, "\n");
  exit(1);
}

void reopen() {
  if (fd != -1) close(fd);
  fd = open(name, O_RDONLY);
  if (fd < 0) die(1, "open failed");
}

int main(int argc, char **argv) {
  struct stat st;
  off_t pos = 0, size;
  int attempts = 0;

  if (argc < 2) die(0, "usage: pcat <file>");
  name = argv[1];
  reopen();

  if (fstat(fd, &st) < 0) die(1, "stat failed");
  size = st.st_size;

  while (pos < size) {
    ssize_t count;
    char buf[65536];

    if (lseek(fd, pos, SEEK_SET) < 0) die(1, "lseek failed");
    count = read(fd, buf, sizeof buf);
    if (count < 0 && errno == EIO) {
      if (++attempts >= 20 && 0) {
	fprintf(stderr, "read error at %ld, try %d, giving up\n",
		pos, attempts);
	count = 512;
	memset(buf, 0, count);
      } else {
	fprintf(stderr, "read error at %ld, try %d\n", pos, attempts);
	reopen();
      }
    } else if (count < 0) {
      die(1, "read failed");
    }

    if (count > 0) {
      if (fwrite(buf, 1, count, stdout) < count) die(1, "write error");
      pos += count;
      attempts = 0;
    }
  }

  return 0;
}

