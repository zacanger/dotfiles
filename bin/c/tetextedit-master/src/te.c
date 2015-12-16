/* te.c : te is a text editor -- (C)Marisa Kirisame - MIT Licensed */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

/* consts */
static const char *ver = "0.0.1";
static const char *errmsgs[] =
{
	"No error",
	"Out of range",
	"Not number",
	"Memory full",
	"Blank",
	"Syntax error",
	"Broken",
	"Unrecognized",
	"tetete",
	"File read fail",
	"Unknown",
};
static const unsigned errnum = 9;

/* global vars */
static char *filen = NULL;
static FILE *doc = NULL;
static char **text = NULL;
static unsigned textlen = 0;
static unsigned cur = 0;
static unsigned terrno = 0;
static unsigned verrmsg = 0;

/* deallocate text */
void freelines( void )
{
	unsigned long int i;
	for ( i=0; i<textlen; i++ )
		free(text[i]);
	free(text);
}

/* make line */
static void setentry( unsigned idx, const char *ln )
{
	if ( idx >= textlen )
		return;
	if ( text == NULL )
		return;
	if ( text[idx] != NULL )
		free(text[idx]);
	text[idx] = malloc(strlen(ln)+1);
	strcpy(text[idx],ln);
}

/* increment array */
static void increasedict( void )
{
	if ( text == NULL )
	{
		text = malloc(sizeof(char*));
		text[0] = NULL;
	}
	else
	{
		text = realloc(text,sizeof(char*)*(textlen+1));
		text[textlen] = NULL;
	}
}

/* read a line */
static char* readline( FILE *dict )
{
	unsigned i = 0;
	int ch = 0;
	char *line = NULL;
	line = malloc(2);
	while ( !feof(dict) )
	{
		ch = fgetc(dict);
		if ( ch == '\n' )
		{
			line = realloc(line,i+1);
			line[i] = '\0';
			break;
		}
		if ( feof(dict) )
			break;
		line = realloc(line,i+2);
		line[i] = ch;
		line[++i] = '\0';
	}
	return line;
}

/* read text */
int readlines( FILE *dict )
{
	unsigned i = 0;
	char *got = NULL;
	if ( dict == NULL )
		return 1;
	while ( !feof(dict) )
	{
		increasedict();
		got = readline(dict);
		if ( got == NULL )
			break;
		textlen++;
		setentry(i++,got);
		free(got);
		got = NULL;
	}
	/* ignore last line */
	textlen--;
	free(text[textlen]);
	return 0;
}

/* error */
static const char* lasterror( void )
{
	return (terrno<errnum)?errmsgs[terrno]:errmsgs[errnum];
}

/* ? */
static int err( unsigned errno )
{
	terrno = errno;
	puts((verrmsg)?lasterror():(":3?"+2*(errno!=8)));
	return 1;
}

/* die */
static unsigned bail( const char *mesg, ... )
{
	va_list args;
	va_start(args,mesg);
	vfprintf(stderr,mesg,args);
	va_end(args);
	return 1;
}

/* save as */
static unsigned savefileas( void )
{
	unsigned i = 0;
	char fname[256];
	int ch = getchar();
	while ( (ch != '\n') && (i<255) )
	{
		fname[i++] = ch;
		ch = getchar();
	}
	fname[i] = 0;
	FILE *fil = fopen(fname,"w");
	if ( !fil )
		return err(9);
	for ( i = 0; i<textlen; i++ )
		fprintf(fil,"%s\n",text[i]);
	fclose(fil);
	return 0;
}

/* save */
static unsigned savefile( char *fname )
{
	FILE *fil = fopen(fname,"w");
	if ( !fil )
		return err(9);
	unsigned i;
	for ( i = 0; i<textlen; i++ )
		fprintf(fil,"%s\n",text[i]);
	fclose(fil);
	return 0;
}

/* spaghetti */
static unsigned parsecmd( const char *cmd )
{
	/* te */
	if ( !strcmp(cmd,":3") )
		return err(8);
	/* bye */
	if ( !strcmp(cmd,"q") )
		return 0;
	/* verbose */
	if ( !strcmp(cmd,"E") )
	{
		verrmsg = !verrmsg;
		return 1;
	}
	/* what happen */
	if ( !strcmp(cmd,"e") )
	{
		puts(lasterror());
		return 1;
	}
	/* version */
	if ( !strcmp(cmd,"v") )
	{
		puts(ver);
		return 1;
	}
	/* print */
	if ( !strcmp(cmd,"p") )
	{
		unsigned i;
		for ( i = 0; i<textlen; i++ )
			printf("%s\n",text[i]);
		return 1;
	}
	/* count */
	if ( !strcmp(cmd,"lc") )
	{
		printf("%d\n",textlen);
		return 1;
	}
	/* line print */
	if ( cmd[0] == 'l' )
	{
		if ( cmd[1] == 0 )
		{
			printf("%s\n",text[cur]);
			return 1;
		}
		if ( cmd[1] == 'e' )
		{
			printf("%s\n",text[textlen-1]);
			return 1;
		}
		if ( (cmd[1] < '0') || (cmd[1] > '9') )
			return err(2);
		unsigned pos = atoi(cmd+1);
		if ( pos > textlen )
			return err(1);
		printf("%s\n",text[pos]);
		return 1;
	}
	/* move cursor */
	if ( cmd[0] == 'm' )
	{
		if ( cmd[1] == 0 )
		{
			printf("%d\n",cur);
			return 1;
		}
		if ( cmd[1] == 'e' )
		{
			cur = textlen-1;
			return 1;
		}
		if ( (cmd[1] < '0') || (cmd[1] > '9') )
			return err(2);
		unsigned pos = atoi(cmd+1);
		if ( pos > textlen )
			return err(1);
		cur = pos;
		return 1;
	}
	/* save */
	if ( cmd[0] == 's' )
	{
		(cmd[1]=='a')?savefileas():savefile(filen);
		return 1;
	}
	/* unrecognized */
	return err(7);
}

/* entry */
int main( int argc, char **argv )
{
	/* nofile */
	if ( argc <= 1 )
		return bail("te: no file\n");
	/* create if not exist */
	if ( (doc = fopen(argv[1],"r")) == NULL )
		doc = fopen(argv[1],"w");
	/* something broke */
	if ( !doc )
		return bail("te: cannot make \"%s\"\n",argv[1]);
	fclose(doc);
	/* cannot open for read */
	if ( (doc = fopen(argv[1],"r")) == NULL )
		return bail("te: cannot read \"%s\"\n",argv[1]);
	/* make array */
	readlines(doc);
	fclose(doc);
	filen = argv[1];
	char cmd[256];
	int ch = 0;
	cur = textlen;
	/* main loop */
	for ( ; ; )
	{
		unsigned i = 0;
		/* read expression */
		while ( (i < 256) && (ch != '\n') )
		{
			ch = getchar();
			cmd[i] = (char)ch;
			i++;
		}
		cmd[i-1] = 0;
		if ( !parsecmd(cmd) )	/* zero means close */
			break;
		ch = 0;
		i = 0;
	}
	/* endo */
	freelines();
	return 0;
}
