/*
 * zclock
 * originally: aclock, (c) 2008 Christopher J. McKenzie, GPL
 */

#define DESCRIPTION\
       	"ASCII art digital clock"

#include <string.h>
#include <stdio.h>
#include <time.h>

#define SX 33
#define SY 13

#define COLOROFFSET	10
#define PADDING		20

short g_offset = 0;

char out[SY][SX + PADDING];

char *bw_clk[]=
{
" __      __________",
"/  \\____/ __    / /\\______ ",
"-==-  -/ /=/`/ / / .\\-  -/\\",
"=- -=-/ _` `  / /   .\\=-/\\\\",
"-- =-/ /_/`/ / /     /_///\\",
" -= / /_/`/ / /     / /\\/\\",
"___/ /_/`/ / /     /=///  \\",
"==/ /_/`/ / /  '  / /\\/",
"_/ _`_`_ / /    '/-/// ",
"/_______/_/     / /\\/  ",
"\\  ____ \\X\\    /-///   ",
"-\\ \\\\\\\\\\ \\X\\  / /\\/",
"=-\\_______\\X\\/ ///",
0};

char *color_clk[]=
{
" __      __________",
"/  \\____/ __    / /\\______ ",
"-==-  -/ /=/`/ / / .\\-  -/\\",
"=- -=-/ _` `  / /\033[02m\033[01m   \033[00m.\\=-/\\\\",
"-- =-/ /_/`/ / /\033[02m\033[01m     \033[00m/_///\\",
" -= / /_/`/ / /\033[02m\033[01m     \033[00m/ /\\/\\",
"___/ /_/`/ / /\033[02m\033[01m     \033[00m/=///  \\",
"==/ /_/`/ / /\033[02m\033[01m  '  \033[00m/ /\\/",
"_/ _`_`_ / /\033[02m\033[01m    '\033[00m/-/// ",
"/_______/_/\033[02m\033[01m     \033[00m/ /\\/  ",
"\\  ____ \\X\\\033[02m\033[01m    \033[00m/-///   ",
"-\\ \\\\\\\\\\ \\X\\\033[02m\033[01m  \033[00m/ /\\/",
"=-\\_______\\X\\/ ///",
0};

char *nums[]=
{
 "/\\",
"\\ \\",
 "\\/",

" \\",
"  \\",
"  ",

"/\\",
" / ",
"\\/",

"/\\",
" /\\",
 " /",

 " \\",
"\\/\\",
 "  ",

 "/ ",
"\\/\\",
  " /",

"/ ",
"\\/\\",
 "\\/",

"/\\",
"  \\",
"  ",

 "/\\",
"\\/\\",
 "\\/",

 "/\\",
"\\/\\",
  " /"
};

char *g_flags[][2] =
{
	{ "black",	"foreground" },	// This order corresponds with the ANSI escape codes
	{ "red",	"foreground" },
	{ "green",	"foreground" },
	{ "yellow",	"foreground" },
	{ "blue",	"foreground" },
	{ "purple",	"foreground" },
	{ "cyan",	"foreground" },
	{ "white",	"foreground" },

	{ "24",	"hour" },
	{ "12", "hour" },

	{ 0, 0 }
};

void show_usage(char*prog) {
	int ix;

	printf("%s\t%s\n\nUsage:\n", prog, DESCRIPTION);

	for (ix = 0; g_flags[ix][0]; ix++) {
		printf("\t-%s\tSet %s %s\n", g_flags[ix][0], g_flags[ix][0], g_flags[ix][1]);
	}
	printf("\n");
}

void makecolor(int color) {
	int ix, iy;

	for (ix = 0; color_clk[ix]; ix++) {
		memset(out[ix], 0, SX + 9);
		memcpy(out[ix], color_clk[ix], strlen(color_clk[ix]) * sizeof(char));
	}

	for (ix = 0; ix < SY; ix++) {
		for (iy = 0; out[ix][iy]; iy++) {
			if (out[ix][iy] == '\033') {
				// replace here
				if (out[ix][iy + 3] == '2') { // replace here
					out[ix][iy + 2] = '3';
					out[ix][iy + 3] = color + '0';
				}
			}
		}
	}
}

void donum(int i) {
	int d = 0,
	    x = SX - 9 - COLOROFFSET / 2,
	    y = 5;

	while (i) {
		x -= 2;
		d = ( (i % 10) + 1) * 3 - 1;
		memcpy(out[y--] + x + 1 + g_offset, nums[d--], 2 * sizeof(char));
		memcpy(out[y--] + x + g_offset, nums[d--], 3 * sizeof(char));
		memcpy(out[y--] + x + g_offset, nums[d--], 2 * sizeof(char));
		y += 5;
		i /= 10;
	}
}

int main(int argc, char*argv[]) {
	int i = 0;
	struct tm * t = NULL;
	time_t t1;

	char 	**clk = NULL,
	 	do24 = 1,
		*prog = argv[0],
		offset;

	clk = bw_clk;
	g_offset = 0;

	for (i = 0; clk[i]; i++) {
		memset(out[i], 0, SX + PADDING - 1);
		memcpy(out[i], clk[i], strlen(clk[i]) * sizeof(char));
	}

	if (argc > 1) {
		argv++;
		while (argv[0]) {
			for (i = 0; g_flags[i][0]; i++) {
				if (argv[0][2] == '-') { // accept -- or -
					offset = 2;
				} else {
					offset = 1;
				}
				if(!strcmp(argv[0] + offset, g_flags[i][0])) {
					if (g_flags[i][offset][0] == 'f') {// if is colour
						clk = color_clk;
						g_offset = COLOROFFSET;

						printf("Making color");
						makecolor(i);
					} else {
						if (argv[0][offset] == '2') {
							do24 = 1;
						} else if (argv[0][offset] == '1') {
							do24 = 0;
						}
					}
					break;
				}
			}
			// If it got here, then it went through the loop without matching
			if (g_flags[i][0] == 0) {
				show_usage(prog);
				return(0);
			}
			argv++;
		}
	}

	for (i = 0;i < SY; i++) {
		printf("\n");
	}

	lp:
		// uncommented voodoo
		if (out[7][15 + g_offset] == '\'') {
			out[7][15 + g_offset] = out[8][16 + g_offset] = ' ';
		}
		else {
			out[7][15 + g_offset] = out[8][16 + g_offset] = '\'';
		}

		time(&t1);
		t = localtime(&t1);

		if (t->tm_hour == 0 && t->tm_min == 0) {
			for(i = 0; clk[i]; i++) {
				memcpy(out[i], clk[i], strlen(clk[i]) * sizeof(char));
			}
		}
		if (do24 == 1) {
			donum(t->tm_hour * 100 + t->tm_min);
		}
		else {
			donum ((t->tm_hour % 12) * 100 + t->tm_min);
		}
		out[1][2] = t->tm_sec % 10 + '0';
		out[1][1] = (t->tm_sec / 10) % 10 + '0';

		printf("[%dD[%dA", SX, SY);

		for (i = 0; clk[i]; i++) {
			printf("%s\n", out[i]);
		}
		sleep(1);
	goto lp;

	return 0;
}

