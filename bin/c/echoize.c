/*
 * Simple utility to turn a binary file into a sequence of bash echo commands
 * that recreates the file byte-for-byte. Intended for recovering from nasty
 * system problems where no executable runs, and the only thing left is a bash
 * shell.
 *
 * Adapted from:
 *	http://fakeguido.blogspot.com/2010/08/rescuing-hosed-system-using-only-bash.html
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/* Special escape sequences that can't be safely represented by the \x..
 * notation. Binary zero causes echo to terminate prematurely, so we must use
 * "\\0000". Backslashes get interpolated more times than you might expect, so
 * we need to write it as "\\\\". It also cannot be safely represented as \x5C,
 * because the shell interpolates it after expansion.
 */
#define BINARY_ZERO_IDX	0
#define BACKSLASH_IDX	1
#define FMT_STRING_IDX	2
static char *single_escapes[] = {
	"\\\\0000",		/* binary 0 */
	"\\\\\\\\",		/* literal backslash */
	"\\x%02x",		/* format string */
};

/*
 * The following cat-in-bash trick allows us to copy-n-paste a very large
 * amount of echo commands in a single shot, saving them into a script that
 * bash can then run to regenerate the binary file:
 *
 *	(IFS=$'\n';while read line;do echo "$line";done) > script.echo
 *
 * However, due to the 'echo' command in this trick adding another level of
 * shell interpolation, we need to double-escape the usual escape sequences in
 * order for the target script to be at the right level of escaping.
 */

static char *double_escapes[] = {
	"\\\\\\\\0000",		/* binary 0 */
	"\\\\\\\\\\\\\\\\\\",	/* literal backslash */
	"\\\\x%02x",		/* format string */
};

void echoize(FILE *fp, size_t bufsize, char *target, char **escapes) {
	char *op = ">";
	unsigned char *buf = NULL;
	size_t nread;
	int i;

	buf = (unsigned char *)malloc(bufsize);
	if (!buf) {
		fprintf(stderr, "Out of memory\n");
		exit(2);
	}

	do {
		nread = fread(buf, 1, bufsize, fp);
		if (!nread)
			break;

		printf("echo -ne $'");
		for (i=0; i < nread; i++) {
			if (buf[i] == '\0') {
				printf(escapes[BINARY_ZERO_IDX]);
			} else if (buf[i] == '\\') {
				printf(escapes[BACKSLASH_IDX]);
			} else {
				printf(escapes[FMT_STRING_IDX], buf[i]);
			}
		}
		printf("' %s %s\n", op, target);

		op = ">>";
	} while (!feof(fp));
}

void showhelp(const char *progname) {
	fprintf(stderr,
		"Syntax:\n"
		"\t%s [options] <inputfile> [<targetname>]\n\n"
		"Converts <inputfile> into a bunch of bash echo commands that recreates the\n"
		"file byte-for-byte as <targetname>. If <targetname> is omitted, it defaults\n"
		"to <inputfile>.\n\n"
		"Available options:\n"
		"    -b<size>   Specify number of bytes to encode per line [Default: 128]\n"
		"    -d         Double-escape the escape sequences\n"
		"    -h         Show this help\n\n"
		"The -d option is useful for pasting a large number of lines to a remote\n"
		"terminal by allowing you to copy them into a script using the following\n"
		"trick to emulate cat in bash:\n\n"
		"\t(IFS=$'\\n';while read line;do echo \"$line\";done) > target.script\n\n"
		"and then running the script to recreate the binary:\n\n"
		"\t(source target.script)\n\n"
		"The double-escaping is necessary because the above trick adds another level\n"
		"of metacharacter interpolation.\n",
		progname
	);
	exit(1);
}

int main(int argc, char *argv[]) {
	char *filename = NULL;
	char *targetname = NULL;
	char **escapetbl = single_escapes;
	size_t blocksize = 128;
	int opt;
	FILE *fp = NULL;

	while ((opt = getopt(argc, argv, "b:dh")) != -1) switch(opt) {
	case 'b':
		blocksize = strtoull(optarg, NULL, 0);
		break;
	case 'd':
		escapetbl = double_escapes;
		break;
	case 'h':
	case '?':
	default:
		showhelp(argv[0]);
	}

	if (optind >= argc)
		showhelp(argv[0]);

	targetname = filename = argv[optind++];

	if (optind < argc)
		targetname = argv[optind++];

	fp = fopen(filename, "r");
	if (!fp) {
		fprintf(stderr, "Unable to open '%s': %s\n",
			filename, strerror(errno));
		exit(2);
	}

	echoize(fp, blocksize, targetname, escapetbl);

	fclose(fp);
	exit(0);
}
