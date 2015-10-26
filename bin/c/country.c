/* country.c - random country music lyrics generator
**
** Author unknown.
*/

#include <stdio.h>

#define RANDSTR(array, max)             \
        ((array)[random() % (max)])

char *strings_1[] =
{
        "on the highway",
        "in Sheboygan",
        "outside Fresno",
        "at a truck stop",
        "on probation",
        "in a jail cell",
        "in a nightmare",
        "incognito",
        "in the Stone Age",
        "in a treehouse",
        "in a gay bar"
};
#define STR1SIZE 11

char *strings_2[] =
{
        "in September",
        "at McDonald's",
        "ridin' shotgun",
        "wrestlin' gators",
        "all hunched over",
        "poppin' uppers",
        "sort of pregnant",
        "with joggers",
        "stoned on oatmeal",
        "with Merv Griffin",
        "dead all over"
};
#define STR2SIZE 11

char *strings_3[] =
{
        "that purple dress",
        "that little hat",
        "that burlap bra",
        "those training pants",
        "the stolen goods",
        "that plastic nose",
        "the Stassin pin",
        "the neon sign",
        "that creepy smile",
        "the hearing aid",
        "the boxer shorts"
};
#define STR3SIZE 11

char *strings_4[] =
{
        "sobbin' at the toll booth",
        "drinkin' Dr. Pepper",
        "weighted down with Twinkies",
        "breakin' out with acne",
        "crawlin' through the prairie",
        "smellin' kind of funny",
        "crashin' through the guardrail",
        "chewin' on a hangnail",
        "talkin' in Swahili",
        "drownin' in the quicksand",
        "slurpin' up linguini"
};
#define STR4SIZE 11

char *strings_5[] =
{
        "in the twilight",
        "but I loved her",
        "by the off-ramp",
        "near Poughkeepsie",
        "with her cobra",
        "when she shot me",
        "on her elbows",
        "with Led-Zeppelin",
        "with Miss Piggy",
        "with a wetback",
        "in her muu-muu"
};
#define STR5SIZE 11

char *strings_6[] =
{
        "no guy would ever love her more",
        "that she would be an easy score",
        "she'd bought her dentures in a store",
        "that she would be a crashing bore",
        "I'd never rate her more than \"4\"",
        "they'd hate her guts in Baltimore",
        "it was a raven, nothing more",
        "we really lost the last World War",
        "I'd have to scrape her off the floor",
        "what strong deodorants were for",
        "that she was rotten to the core",
        "that I would upchuck on the floor"
};
#define STR6SIZE 12

char *strings_7[] =
{
        "I promised her",
        "I knew deep down",
        "She asked me if",
        "I told her shrink",
        "The judge declared",
        "My Pooh Bear said",
        "I shrieked in pain",
        "The painters knew",
        "A Klingon said",
        "My hamster thought",
        "The blood test showed",
        "Her rabbi said"
};
#define STR7SIZE 12

char *strings_8[] =
{
        "stay with her",
        "warp her mind",
        "swear off booze",
        "change my sex",
        "punch her out",
        "live off her",
        "have my rash",
        "stay a dwarf",
        "hate her dog",
        "pick my nose",
        "play \"Go Fish\"",
        "salivate"
};
#define STR8SIZE 12

char *strings_9[] =
{
        "our love would never die",
        "there was no other guy",
        "man wasn't meant to fly",
        "that Nixon didn't lie",
        "her basset hound was shy",
        "that Rolaids made her high",
        "she'd have a swiss on rye",
        "she loved my one blue eye",
        "her brother's name was Hy",
        "she liked \"Spy vs. Spy\"",
        "that birthdays made her cry",
        "she couldn't stand my tie"
};
#define STR9SIZE 13

char *strings_10[] =
{
        "run off",
        "wind up",
        "boogie",
        "yodel",
        "sky dive",
        "turn green",
        "freak out",
        "blast off",
        "make it",
        "black out",
        "bobsled",
        "grovel",
};
#define STR10SIZE 12

char *strings_11[] =
{
        "with my best friend",
        "in my Edsel",
        "on a surfboard",
        "on \"The Gong Show\"",
        "with her dentist",
        "on her \"Workmate\"",
        "with a robot",
        "with no clothes on",
        "at her health club",
        "in her Maytag",
        "with her guru",
        "while in labor"
};
#define STR11SIZE 12

char *strings_12[] =
{
        "You'd think at least that she'd have said",
        "I never had the chance to say",
        "She told her fat friend Grace to say",
        "I now can kiss my credit cards",
        "I guess I was too smashed to say",
        "I watched her melt away and sobbed",
        "She fell beneath the wheels and cried",
        "She sent a hired thug to say",
        "She freaked out on the lawn and screamed",
        "I pushed her off the bridge and waved",
        "But that's the way that pygmies say",
        "She sealed me in the vault and smirked"
};
#define STR12SIZE 12

int main(int argc, char *argv[])
{
        int seed;

        if ( argc == 1 )
	{
		time(&seed);
		seed ^= getpid();
	}
        else if ( argc != 2 )
        {
                fprintf(stderr, "syntax: %s <seed>\n", argv[0]);
                exit(1);
        }
	else
		seed = atoi(argv[1]);

        srandom(seed);

        printf("I met her %s %s\n",
                RANDSTR(strings_1, STR1SIZE),
                RANDSTR(strings_2, STR2SIZE));

        printf("I can still recall %s she wore\n",
                RANDSTR(strings_3, STR3SIZE));

        printf("She was %s %s,\n",
                RANDSTR(strings_4, STR4SIZE),
                RANDSTR(strings_5, STR5SIZE));


        printf("and I knew %s;\n",
                RANDSTR(strings_6, STR6SIZE));

        printf("%s I'd %s forever;\n",
                RANDSTR(strings_7, STR7SIZE),
                RANDSTR(strings_8, STR8SIZE));

        printf("She said to me %s;\n",
                RANDSTR(strings_9, STR9SIZE));

        printf("But who'd have thought she'd %s %s;\n",
                RANDSTR(strings_10, STR10SIZE),
                RANDSTR(strings_11, STR11SIZE));

        printf("%s goodbye.\n",
                RANDSTR(strings_12, STR12SIZE));

        exit(0);
}

