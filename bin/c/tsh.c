/*  tsh, a shell by zac anger, 2016.
 *  following http://brennan.io/2015/01/16/write-a-shell-in-c/
 *  this will hopefully be a (very basic, but) functional shell in c.
 *  it'll be a nice little follow-up experiment to `tt` (which is my
 *  primary terminal, these days! :D).
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/param.h>

// built-in shell command declarations
int tsh_cd(char **args);
int tsh_help(char **args);
int tsh_exit(char **args);
int tsh_history();

// built-ins, and their functions
char *builtin_str[] = {
  "cd",
  "help",
  "exit",
  "history"
};

char cwd[1024];

#define MAX_HISTORY 100

char *history[MAX_HISTORY];
int history_pos = 0;

int (*builtin_func[]) (char**) = {
  &tsh_cd,
  &tsh_help,
  &tsh_exit,
  &tsh_history
};

int tsh_num_builtins() {
  return sizeof(builtin_str) / sizeof(char *);
}

int tsh_num_history() {
  return sizeof(history) / sizeof(char *);
}

void history_save(char item[]) {
  int i = history_pos % MAX_HISTORY;
  history[i] = NULL;
  history[i] = item;
  history_pos++;
}

// implementation of builtins

// params: list of args. 0 is CD, 1 is dir.
int tsh_cd(char **args) {
  if (args[1] == NULL) {
    fprintf(stderr, "tsh: expected args to cd\n");
  } else {
    if (chdir(args[1]) != 0) {
      perror("tsh");
    }
    getcwd(cwd, sizeof(cwd));
  }
  return 1;
}

// history
int tsh_history() {
  int i, pos;
  int n = 0;
  int t = tsh_num_history();
  if (history_pos > MAX_HISTORY) {
    pos = history_pos % MAX_HISTORY;
  } else {
    pos = 0;
  }
  i = pos;
  while (1) {
    if (n >= t) {
      return 1;
    }
    i = pos % MAX_HISTORY;
    if (history[i]) {
      printf("pos %d i %d\n", pos, i);
      printf("%s\n", history[i]);
    }
    pos++;
    n++;
  }
  return 1;
}

// params: irrelevant
int tsh_help(char **args) {
  int i;
  printf("-------------------\n");
  printf("--------tsh--------\n");
  printf("-------------------\n");
  printf("type commands and arguments\n\n");
  printf("built in commands:\n");

  for (i = 0; i < tsh_num_builtins(); i++) {
    printf("  --%s\n", builtin_str[i]);
  }

  printf("\nuse man for command usage\n\n");
  return 1;
}

// params: irrelevant. returns 0 to exit.
int tsh_exit(char **args) {
  return 0;
}

// launching commands. waits for launced to exit.
// params: args list, null-terminated
int tsh_launch(char **args) {
  pid_t pid;
  int status;

  pid = fork();
  if (pid == 0) {
    // child process
    if (execvp(args[0], args) == -1) {
      perror("tsh");
    }
    exit(EXIT_FAILURE);
  } else if (pid < 0) {
    // fork error
    perror("tsh");
  } else {
    // parent process
    do {
      waitpid(pid, &status, WUNTRACED);
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
  }

  return 1;
}

// executing commands or builtins
// params: list of args, null-terminated
int tsh_execute(char **args) {
  int i;
  if (args[0] == NULL) {
    // no command entered
    return 1;
  }

  for (i = 0; i < tsh_num_builtins(); i++) {
    if (strcmp(args[0], builtin_str[i]) == 0) {
      return (*builtin_func[i])(args);
    }
  }

  return tsh_launch(args);
}

#define TSH_RL_BUFSIZE 1024

// read stdin, return it
char *tsh_read_line(void) {
  int bufsize = TSH_RL_BUFSIZE;
  int position = 0;
  char *buffer = malloc(sizeof(char) * bufsize);
  int c;

  if (!buffer) {
    fprintf(stderr, "tsh allocation error\n");
    exit(EXIT_FAILURE);
  }

  while (1) {
    // read char
    c = getchar();

    // at EOF, replace with null char, return
    if (c == EOF || c == '\n') {
      buffer[position] = '\0';
      return buffer;
    } else {
      buffer[position] = c;
    }
    position++;

    // if buffer exceeded, reallocate
    if (position >= bufsize) {
      bufsize += TSH_RL_BUFSIZE;
      buffer = realloc(buffer, bufsize);
      if (!buffer) {
        fprintf(stderr, "tsh allocation error\n");
        exit(EXIT_FAILURE);
      }
    }
  }
}

#define TSH_TOK_BUFSIZE 64
#define TSH_TOK_DELIM " \t\r\n\a"

// split line into tokens. takes the line, returns array of tokens, null-terminated
char **tsh_split_line(char *line) {
  int bufsize = TSH_TOK_BUFSIZE, position = 0;
  char **tokens = malloc(bufsize * sizeof(char*));
  char *token, **tokens_backup;

  if (!tokens) {
    fprintf(stderr, "tsh allocation error\n");
    exit(EXIT_FAILURE);
  }

  token = strtok(line, TSH_TOK_DELIM);
  while (token != NULL) {
    tokens[position] = token;
    position++;

    if (position >= bufsize) {
      bufsize += TSH_TOK_BUFSIZE;
      tokens_backup = tokens;
      tokens = realloc(tokens, bufsize * sizeof(char*));
      if (!tokens) {
        free(tokens_backup);
        fprintf(stderr, "tsh allocation error\n");
        exit(EXIT_FAILURE);
      }
    }

    token = strtok(NULL, TSH_TOK_DELIM);
  }
  tokens[position] = NULL;
  return tokens;
}

// get input. process it.
void tsh_loop(void) {
  char *line;
  char **args;
  int status;

  if (getcwd(cwd, sizeof(cwd)) != NULL) {
    printf("><\n");
  }

  do {
    // printf(">.<: ");
    printf("[%s]>< ", cwd);
    line = tsh_read_line();
    args = tsh_split_line(line);
    status = tsh_execute(args);

    if (strncmp(args[0], "history", sizeof(*args[0])) != 0) {
      // don't save history in history
      history_save(*args);
    }

    free(line);
    free(args);
  } while (status);
}

// entry point. argc: arg count; argv: argv; return: status
int main(int argc, char **argv) {
  // we'd load configs here, i guess.
  tsh_loop();
  return EXIT_SUCCESS;
}

