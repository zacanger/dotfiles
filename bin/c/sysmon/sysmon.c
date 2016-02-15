/* gh:debianjoe/clinky */
/* mod: gh:zacanger */

#include <stdio.h>
#include <stdlib.h>
#include <sys/sysinfo.h>
#include <sys/utsname.h>
#include <unistd.h>
#include <math.h>

#define TO_MB(m) ((m * (unsigned long long)si.mem_unit) / MEGABYTE)

/* set delay for refresh, and switch if refresh is desired */
static const int delay = 5; /* in seconds */
static const char refresh = 1; /* if refreshing term is desired */
/* set conversion constants */
const double MEGABYTE = 1024 * 1024;
void getnprint ();
void hold ();

int main () {
  while (refresh == 1) {
    getnprint();
    hold();
  }
  getnprint();
  return 0;
}

void getnprint() {
  struct sysinfo si;
  struct utsname ut;
  sysinfo(&si);
  uname(&ut);

  unsigned long totalmem = TO_MB(si.totalram) / 1024;
  unsigned long usedmem = TO_MB(si.totalram - si.freeram);
  unsigned long buffermem = TO_MB(si.bufferram);
  unsigned long freemem = TO_MB(si.freeram);

  /* raw readings */
  printf("\033[1;33m+++ \033[1;32msysmon \033[1;33m+++\033[1;m\n\n");
  printf("uname:\t\t\033[1;31m%s\n\t\t%s\n\t\t%s\033[1;m\n", ut.sysname, ut.release, ut.version);
  printf("Hostname:\t\033[1;31m%s\033[1;m\n", ut.nodename);
  printf("Total:\t\t\033[1;31m%lu GB\033[1;m\n", totalmem);
  printf("Used:\t\t\033[1;31m%lu MB\033[1;m (cache not subtracted)\n", usedmem);
  printf("Free:\t\t\033[1;31m%lu MB\033[1;m\n", freemem);
  printf("Buffer:\t\t\033[1;31m%lu MB\033[1;m\n", buffermem);
  printf("Uptime:\t\t\033[1;31m%ld\033[1;m minutes.\n", si.uptime/60);
  printf("Load:\t\t\033[1;31m%.2f\033[1;m\n", si.loads[0] / 65536.0);
  printf("Processes:\t\033[1;31m%d\033[1;m\n", si.procs);
  printf("Page size:\t\033[1;31m%ld\033[1;m bytes\n", sysconf(_SC_PAGESIZE));

  long cpus = sysconf(_SC_NPROCESSORS_ONLN);
  long csize = sysconf(_SC_LEVEL1_ICACHE_SIZE) / pow(2, 10);
  long cassoc = sysconf(_SC_LEVEL1_ICACHE_ASSOC);
  long cline = sysconf(_SC_LEVEL1_ICACHE_LINESIZE);

  printf("CPUs:\t\t\033[1;31m%ld\033[1;m\n", cpus);
  printf("lvl 1 icache size = %ldK, \n\tassoc = %ld, \n\tline size = %ld\n",
  csize, cassoc, cline);

  csize = sysconf(_SC_LEVEL1_DCACHE_SIZE) / pow(2, 10);
  cassoc = sysconf(_SC_LEVEL1_DCACHE_ASSOC);

  printf("lvl 1 icache size = %ldK, \n\tassoc = %ld, \n\tline size = %ld\n",
  csize, cassoc, cline);
  cline = sysconf(_SC_LEVEL1_DCACHE_LINESIZE);
  csize = sysconf(_SC_LEVEL2_CACHE_SIZE) / pow(2, 10);
  printf("lvl 1 dcache size = %ldK, \n\tassoc = %ld, \n\tline size = %ld\n",
  csize, cassoc, cline);
  cassoc = sysconf(_SC_LEVEL2_CACHE_ASSOC);
  cline = sysconf(_SC_LEVEL2_CACHE_LINESIZE);
  printf("lvl 2 cache size = %ldK, \n\tassoc = %ld, \n\tline size = %ld\n",
  csize, cassoc, cline);
}

void hold () {
  fflush(stdout);
  sleep(delay);
  printf("\033[2J\033[1;H\033[1;30m");
}

