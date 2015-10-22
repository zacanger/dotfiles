/*
 * inotify
 *
 * Watches all files given to you on the command line
 *
 */
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <linux/limits.h>
#include <sys/inotify.h>
#include <sys/select.h>

#define ARGS IN_ONESHOT | IN_ALL_EVENTS
#define EVENT_SIZE  (sizeof (struct inotify_event))
#define BUF_LEN        (1024 * (EVENT_SIZE + 16))
char 
  buf[BUF_LEN],
  dir[PATH_MAX];

struct {
  int bit;
  char *desc;
} map[] = {
  { IN_ACCESS, "IN_ACCESS" },
  { IN_ATTRIB, "IN_ATTRIB" },
  { IN_CLOSE_WRITE, "IN_CLOSE_WRITE" },
  { IN_CLOSE_NOWRITE, "IN_CLOSE_NOWRITE" },
  { IN_CREATE, "IN_CREATE" },
  { IN_DELETE, "IN_DELETE" },
  { IN_DELETE_SELF, "IN_DELETE_SELF" },
  { IN_MODIFY, "IN_MODIFY" },
  { IN_MOVE_SELF, "IN_MOVE_SELF" },
  { IN_MOVED_FROM, "IN_MOVED_FROM" },
  { IN_MOVED_TO, "IN_MOVED_TO" },
  { IN_OPEN, "IN_OPEN" }
};

int main(int argc, char*argv[]) {
  int 
    lastError = -1,
    len,
    ix,
    i,
    iy,
    fd = 0,
    mapLen = 12,
    *g_name = (int*)malloc(sizeof(int) * argc),
    *g_wd = (int*)malloc(sizeof(int) * argc),
    *g_fd = (int*)malloc(sizeof(int) * argc);

  getcwd(dir, PATH_MAX);

  fd_set rfds;
  FD_ZERO(&rfds);

  for(ix = 1; ix < argc; ix++) {
    g_fd[ix - 1] = inotify_init();
    if(g_fd[ix - 1] == -1) {
      printf("Ran out of inotify handlers before adding \"%s\"... those are the breaks\n", argv[ix]);
      break;
    }
    printf("%s\n", argv[ix]);
  }

  printf("Watching %d out of %d requested files.\n", ix - 1, argc - 1);
  fflush(0);

  while(1) {
    fd = 0;
    lastError = -1;

    for(ix = 1; ix < argc; ix++) {

      do {
        // Only add files to the watch that exist
        g_wd[fd] = inotify_add_watch( 
          g_fd[fd], argv[ix],
          ARGS
        );

        if(g_wd[fd] != -1) {
          g_name[fd] = ix;
          fd++;
        } else {
          if(lastError != ix) {
            lastError = ix;
            printf("sleeping\n");
            fflush(0);
            usleep(1000);
            continue;
          } else {
            printf("Failed to place a watch on %s :: ", argv[ix]);
            fflush(0);
            perror("Error");
          }
        }
      } while(0);
    }

    for(ix = 0; ix < fd; ix++) {
      FD_SET(g_fd[ix], &rfds);
    }

    select(g_fd[fd - 1] + 1, &rfds, NULL, NULL, NULL);

    for(ix = 0; ix < fd; ix++) {

      if(FD_ISSET(g_fd[ix], &rfds)) {
        len = read (g_fd[ix], buf, BUF_LEN);

        if (len > 0) {
          i = 0;
          while (i < len) {
            struct inotify_event *event;

            event = (struct inotify_event *) &buf[i];

            if (event->len) {
              printf ("%s ", event->name);
            }
            // Output type of access by using the map above
            for (iy = 0; iy < mapLen; iy++) {
              if(event->mask & map[iy].bit && map[iy].desc) {
                printf("%19s %s/%s\n", map[iy].desc, dir, argv[g_name[ix]]);
              }
            }

            i += EVENT_SIZE + event->len;
          }
        }
      }
    } 

    fflush(0);
    FD_ZERO(&rfds);
  }

  free(g_name);
  free(g_fd);
  free(g_wd);

  return (!fd);
}
