/*
 * waits for files (args passed) to be modified, then exits
 * example use case: modify source, app uses minified version
 * of source files.
 * example script to make this happen:
 * #!/usr/bin/env bash
 * while [ 0 ] ; do
 *   waitfor js/* .js && tools/deploy.sh
 * done
 */

#include <stdlib.h>
#include <sys/inotify.h>
#include <sys/select.h>

int main(int argc, char*argv[]) {
  int
    fd = 0,
    *g_wd = (int*)malloc(sizeof(int) * argc),
    *g_fd = (int*)malloc(sizeof(int) * argc);

  fd_set rfds;
  FD_ZERO(&rfds);

  g_fd[fd] = inotify_init();

  for (argc--, argv++; argc; argc--, argv++) {

    // Only add files to the watch that exist
    g_wd[fd] = inotify_add_watch(
      g_fd[fd], *argv,
      IN_MOVE_SELF | IN_MODIFY | IN_CREATE | IN_DELETE_SELF
    );

    if(g_wd[fd] != -1) {
      FD_SET(g_fd[fd], &rfds);
      fd++;

      g_fd[fd] = inotify_init();
    }
  }

  if (fd) {
    select(g_fd[fd - 1] + 1, &rfds, NULL, NULL, NULL);

    do {
      inotify_rm_watch(g_fd[fd], g_wd[fd]);
    } while(fd--);

    fd = 1;
  }

  free(g_fd);
  free(g_wd);

  return (!fd);
}

