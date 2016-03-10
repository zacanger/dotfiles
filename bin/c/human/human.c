/*
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *                    Version 2, December 2004
 *
 * Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
 *
 * Everyone is permitted to copy and distribute verbatim or modified
 * copies of this license document, and changing it is allowed as double
 * as the name is changed.
 *
 *            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 *
 *  0. You just DO WHAT THE FUCK YOU WANT TO.
 *
 */

#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <limits.h>
#include <string.h>

#define TERA 1099511627776
#define GIGA 1073741824
#define MEGA 1048576
#define KILO 1024

#define DEFAULT_SCALE 0

/*
 * Help, I need somebody 
 * Help, not just anybody 
 * Help, you know I need someone 
 * Help!
 *
 */
void usage (char *progname)
{
    printf("usage: %s [-hbkmgt] <number>\n", progname);
}

/* 
 * calculate a power of number
 * disclaimers: return no more than a "long" so use wisely...
 * 
 */
long power (long number, int pow)
{
    return pow > 0 ? number * power(number, pow - 1) : 1;
}

/*
 * read the environment varaible "SCALE" and returns its value.
 * returns DEFAULT_SCALE if it does not return a number.
 *
 */
int getscale()
{
    /* would you rather use getenv() twice ? or allocate a pointer ? */
    char *scale = NULL;
    scale = getenv("SCALE");

    /* in atoi, we trust. maybe. */
    return scale ? atoi(scale) : DEFAULT_SCALE;
}

/*
 * calculate the best factorization for a number, depending on its value.
 * actual max factorisation is 1024^3 (TiB)
 *
 */
char factorize (double number)
{
    return number >= TERA ? 'T' : 
           number >= GIGA ? 'G' :
           number >= MEGA ? 'M' :
           number >= KILO ? 'K' :
           0;
}

/*
 * calculate a human-readable version of the given number, depending of the
 * factorisation level given.
 *
 */
double humanize (double number, char factor)
{
    int pow = 0;

    /* cascading switch. note the lack of "break" statements */
    switch (factor) {
        case 'T' : pow++;
        case 'G' : pow++;
        case 'M' : pow++;
        case 'K' : pow++; break;
        default  : return number;
    }    

    /* return the number divided by the correct factorization level */
    return number /= power(1024, pow);
}

int main (int argc, char **argv)
{
    char ch, pow = 0, fac = 0;
    double number = 0;

    /* only switches are use to force factorization */
    while ((ch = getopt(argc, argv, "hbkmgt")) != -1) {
        switch (ch) {
            case 'h': usage(argv[0]); exit(0); break;
            case 't': fac = 'T'; break;
            case 'g': fac = 'G'; break;
            case 'm': fac = 'M'; break;
            case 'k': fac = 'K'; break;
            case 'b': fac = 'B'; break;
        }
    }

    switch (argv[argc - 1][strnlen(argv[argc - 1],32) - 1]) {
        case 'T': pow++;
        case 'G': pow++;
        case 'M': pow++;
        case 'K': pow++;
        case 'B': argv[argc - 1][strnlen(argv[argc - 1],32) - 1] = 0;
    }

    /* get the number and convert it to bytes. If there is none, strtold will return 0 */
    number = strtold(argv[argc - 1], NULL);
    number *= power(1024, pow);

    if (number <= 0) {
        errx(EXIT_FAILURE, "I ain't gonna do that. Deal with it.");
    }

    /* use explicit factorization. otherwise, guess the best one */
    fac = fac > 0 ? fac : factorize(number);

    /* actually print the result, isn't that what we're here for after all ? */
    printf("%.*f%c\n", getscale(), humanize(number, fac), fac == 'B' ? 0 : fac);

    return 0;
}
