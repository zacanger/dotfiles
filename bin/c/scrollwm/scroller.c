/**********************************************************\
* SCOROLLER:
* Author: Jesse McClure, 2012
* License: released to public domain (attribution appreciated)
* Example status input for scrollwm
*
* Displays and colors icons for the following:
* - CPU: red > yellow > blue > grey
* - MEM: red > yellow > blue > grey
* - VOL: blue > grey > yellow > red (with different icons)
* - BAT: green > grey > yellow > red (with different icons)
* - WIFI: green > grey > yellow > red (with different icons)
* - MAIL: green = most recent mail is new, blue = new mail exists,
*         grey = no new mail
* - CLOCK: red = appointment within 20 minutes,
*          yellow = appontment within 2 hours,
*          green = appointment later today,
*          blue = no more appointments today
* - Time is shown in 24 hour HH:MM format
* 
* Many aspects of scroller are specific to my hardware and/or
* configuration.  As such this should serve as a template for
* your own status programs rather than being used as-is.
* Specific points to check/adjust:
*  1) details of the audio codec file seem hardware dependent
*  2) mail settings are based on my own synced maildir archive
*  3) assumes the use of rem(ind) for scheduling
*  4) battery files may differ (common change: BAT1 -> BAT0)
*
* COMPILE:
*   $ sed -i 's/jmcclure/'$USER'/' scroller.c
*   $ gcc -o scroller scroller.c
*
* NOTE:
*   To use this status input you must compile scrollwm with
*   the #include "icons.h" line uncommented in the config.h
*   or in your own ~/.scrollwm_conf.h
*
\**********************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/stat.h>
#include <dirent.h>
#include <time.h>

/* input files */
static const char *CPU_FILE		= "/proc/stat";
static const char *MEM_FILE		= "/proc/meminfo";
static const char *AUD_FILE		= "/proc/asound/card0/codec#0";
static const char *WIFI_FILE	= "/proc/net/wireless";
static const char *BATT_NOW		= "/sys/class/power_supply/BAT1/charge_now";
static const char *BATT_FULL	= "/sys/class/power_supply/BAT1/charge_full";
static const char *BATT_STAT	= "/sys/class/power_supply/BAT1/status";
static const char *MAIL_CUR		= "/home/jmcclure/mail/INBOX/cur";
static const char *MAIL_NEW		= "/home/jmcclure/mail/INBOX/new";
static const char *REM_CMD		= "rem -naa -b1 | sort";

/* colors			  			    R G B */
static const long int White		= 0xDDDDDD;
static const long int Grey		= 0x686868;
static const long int Blue		= 0x68B0E0;
static const long int Green		= 0x288428;
static const long int Yellow	= 0x997700;
static const long int Red		= 0x990000;

/* icon names: may need to be adjusted to match updates to icons.h */
enum {
	clock_icon, cpu_icon, mem_icon,
	speaker_hi_icon, speaker_mid_icon, speaker_low_icon, speaker_mute_icon,
	wifi_full_icon, wifi_hi_icon, wifi_mid_icon, wifi_low_icon,
	mail_new_icon, mail_none_icon,
	batt_full_icon, batt_hi_icon, batt_mid_icon, batt_low_icon, batt_zero_icon,
	batt_charge_icon,
};

/* variables */
static long		j1,j2,j3,j4,ln1,ln2,ln3,ln4;
static int		n, loops = 0, mail = 0;
static char		c, clk[8], *aud_file, *mail_file;
static FILE		*in;
static time_t	current;

static int mailcheck() {
	DIR *dir;
	struct dirent *de;
	struct stat info;
	time_t cur,new;
	char *dname;
	chdir(MAIL_CUR);
	if ( !(dir=opendir(MAIL_CUR)) ) return 0;
	while ( (de=readdir(dir)) ) dname = de->d_name;
	if (dname[0] == '.') { closedir(dir); return 0; }
	stat(dname,&info);
	cur = info.st_mtime;
	closedir(dir);
	chdir(MAIL_NEW);
	if ( !(dir=opendir(MAIL_NEW)) ) return -1;
	while ( (de=readdir(dir)) ) dname = de->d_name;
	if (dname[0] == '.') { closedir(dir); return 0; }
	stat(dname,&info);
	new = info.st_mtime;
	closedir(dir);
	if (new > cur) return 2;
	else return 1;
}

static long schedulecheck() {
	FILE *in;
	if ( !(in=popen(REM_CMD,"r")) ) return 0;
	int y,m,d,hh=-1,mm;
	time_t c,t = time(NULL);
	struct tm *tmp = localtime(&t);
	while (fscanf(in,"%d/%d/%d %d:%d",&y,&m,&d,&hh,&mm) != 5)
		fscanf(in,"%*[^\n]\n");
	pclose(in);
	tmp->tm_year=y-1900; tmp->tm_mon=m-1; tmp->tm_mday=d;
	c = mktime(tmp);
	if (c != t) return Blue; /* nothing left today */
	tmp->tm_hour=hh; tmp->tm_min=mm;
	c = mktime(tmp);
	if (c < t + 1200) return Red; /* next event within 20 minutes */
	if (c < t + 7200) return Yellow; /* next event within 2 hours */
	return Green; /* event later today */
}

int main(int argc, const char **argv) {
	in = fopen(CPU_FILE,"r");
	fscanf(in,"cpu %ld %ld %ld %ld",&j1,&j2,&j3,&j4);
	fclose(in);
	long clock_color = schedulecheck();
	/* main loop */
	for (;;) {
		if ( (in=fopen(CPU_FILE,"r")) ) {       /* CPU MONITOR */
			fscanf(in,"cpu %ld %ld %ld %ld",&ln1,&ln2,&ln3,&ln4);
			fclose(in);
			if (ln4>j4) n=(int)100*(ln1-j1+ln2-j2+ln3-j3)/(ln1-j1+ln2-j2+ln3-j3+ln4-j4);
			else n=0;
			j1=ln1; j2=ln2; j3=ln3; j4=ln4;
			if (n > 85) printf("{#%06X}{i %d} ",Red,cpu_icon);
			else if (n > 60) printf("{#%06X}{i %d} ",Yellow,cpu_icon);
			else if (n > 20) printf("{#%06X}{i %d} ",Blue,cpu_icon);
			else printf("{#%06X}{i %d} ",Grey,cpu_icon);
		}
		if ( (in=fopen(MEM_FILE,"r")) ) {		/* MEM USAGE MONITOR */
			fscanf(in,"MemTotal: %ld kB\nMemFree: %ld kB\nBuffers: %ld kB\nCached: %ld kB\n", &ln1,&ln2,&ln3,&ln4);
			fclose(in);
			n = 100*(ln2+ln3+ln4)/ln1;
			if (n > 80) printf("{#%06X}{i %d} ",Grey,mem_icon);
			else if (n > 65) printf("{#%06X}{i %d} ",Green,mem_icon);
			else if (n > 15) printf("{#%06X}{i %d} ",Yellow,mem_icon);
			else printf("{#%06X}{i %d} ",Red,mem_icon);
		}
		if ( (in=fopen(AUD_FILE,"r")) ) {       /* AUDIO VOLUME MONITOR */
			while ( fscanf(in," Amp-Out caps: ofs=0x%x",&ln1) !=1 )
				fscanf(in,"%*[^\n]\n");
			while ( fscanf(in," Amp-Out vals: [0x%x",&ln2) != 1 )
				fscanf(in,"%*[^\n]\n");
			while ( fscanf(in,"Node 0x14 [%c",&c) != 1 )
				fscanf(in,"%*[^\n]\n");
			while ( fscanf(in," Amp-Out vals: [0x%x",&ln3) != 1 )
				fscanf(in,"%*[^\n]\n");
			fclose(in);
			if (ln3 != 0) printf("{#%06X}{i %d} ",Red,speaker_mute_icon);
			else {
				n = 100*ln2/ln1;
				if (n > 95) printf("{#%06X}{i %d} ",Blue,speaker_hi_icon);
				else if (n > 75) printf("{#%06X}{i %d} ",Grey,speaker_hi_icon);
				else if (n > 50) printf("{#%06X}{i %d} ",Grey,speaker_mid_icon);
				else if (n > 30) printf("{#%06X}{i %d} ",Yellow,speaker_mid_icon);
				else if (n > 10) printf("{#%06X}{i %d} ",Yellow,speaker_low_icon);
				else printf("{#%06X}{i %d} ",Red,speaker_low_icon);
			}
		}
		if ( (in=fopen(BATT_NOW,"r")) ) {       /* BATTERY MONITOR */
			fscanf(in,"%ld\n",&ln1); fclose(in);
			if ( (in=fopen(BATT_FULL,"r")) ) { fscanf(in,"%ld\n",&ln2); fclose(in); }
			if ( (in=fopen(BATT_STAT,"r")) ) { fscanf(in,"%c",&c); fclose(in); }
			n = (ln1 ? ln1 * 100 / ln2 : 0);
			if (c == 'C') printf("{#%06X}{i %d} ",Yellow,batt_charge_icon);
			else if (n > 95) printf("{#%06X}{i %d} ",Green,batt_full_icon);
			else if (n > 90) printf("{#%06X}{i %d} ",Blue,batt_full_icon);
			else if (n > 85) printf("{#%06X}{i %d} ",Grey,batt_full_icon);
			else if (n > 70) printf("{#%06X}{i %d} ",Grey,batt_hi_icon);
			else if (n > 40) printf("{#%06X}{i %d} ",Grey,batt_mid_icon);
			else if (n > 20) printf("{#%06X}{i %d} ",Grey,batt_low_icon);
			else if (n > 15) printf("{#%06X}{i %d} ",Yellow,batt_low_icon);
			else if (n > 8) printf("{#%06X}{i %d} ",Yellow,batt_zero_icon);
			else printf("{#%06X}{i %d} ",Red,batt_zero_icon);
		}
		if ( (in=fopen(WIFI_FILE,"r")) ) {       /* WIFI MONITOR */
			n = 0;
			fscanf(in,"%*[^\n]\n%*[^\n]\n wlan0: %*d %d.",&n);
			fclose(in);
			if (n == 0) printf("{#%06X}{i %d} ",Red,wifi_low_icon);
			else if (n > 63) printf("{#%06X}{i %d} ",Green,wifi_full_icon);
			else if (n > 61) printf("{#%06X}{i %d} ",Grey,wifi_full_icon);
			else if (n > 56) printf("{#%06X}{i %d} ",Grey,wifi_mid_icon);
			else if (n > 51) printf("{#%06X}{i %d} ",Grey,wifi_low_icon);
			else printf("{#%06X}{i %d} ",Yellow,wifi_low_icon);
		}
		if ((loops % 10) == 0) mail = mailcheck();    /* MAIL */
			if (mail == 1) printf("{#%06X}{i %d} ",Blue,mail_new_icon);
			else if (mail == 2) printf("{#%06X}{i %d} ",Green,mail_new_icon);
			else printf("{#%06X}{i %d} ",Grey,mail_none_icon);
		if ((loops % 40) == 0) {					/* TIME */
			time(&current);
			strftime(clk,6,"%H:%M",localtime(&current));
		}
		if (loops++ > 120) {
			clock_color = schedulecheck();
			loops = 0;
		}	
		printf(" {#%06X}{i %d}{#%06X} %s \n",clock_color,clock_icon,White,clk);
		fflush(stdout);
		sleep(1);
	}
	return 0;
}
