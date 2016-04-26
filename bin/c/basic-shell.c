// basic shell!

#include <sys/wait.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>

void parseCmd(char* cmd, char** params);
int executeCmd(char** params);

#define MAX_COMMAND_LENGTH 100
#define MAX_NUMBER_OF_PARAMS 10

int main() {
  char cmd[MAX_COMMAND_LENGTH + 1];
  char* params[MAX_NUMBER_OF_PARAMS + 1];

  int cmdCount = 0;

  while(1) { // print prompt
    char* username = getenv("USER");
    printf("%s@shell %d> ", username, ++cmdCount);

    // Read command from standard input, exit on Ctrl+D
    if (fgets(cmd, sizeof(cmd), stdin) == NULL) {
      break;
    }

    // Remove trailing newline character, if any
    if (cmd[strlen(cmd)-1] == '\n') {
      cmd[strlen(cmd)-1] = '\0';
    }

    // Split cmd into array of parameters
    parseCmd(cmd, params);

    // Exit?
    if (strcmp(params[0], "exit") == 0) {
      break;
    }

    // Execute command
    if(executeCmd(params) == 0) {
      break;
    }
  }
  return 0;
}

// Split cmd into array of parameters
void parseCmd(char* cmd, char** params) {
  for (int i = 0; i < MAX_NUMBER_OF_PARAMS; i++) {
    params[i] = strsep(&cmd, " ");
    if (params[i] == NULL) {
      break;
    }
  }
}

int executeCmd(char** params) {
  pid_t pid = fork(); // fork proc

  if (pid == -1) { // err
    char* error = strerror(errno);
    printf("fork: %s\n", error);
    return 1;
  }

  else if (pid == 0) { // child proc
    execvp(params[0], params); // exec command

    char* error = strerror(errno); // on err
    printf("shell: %s: %s\n", params[0], error);
    return 0;
  }

  else { // parent proc
    int childStatus; // wait for child proc to finish
    waitpid(pid, &childStatus, 0);
    return 1;
  }
}

