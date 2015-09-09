#include <stdio.h>
#include <ncurses.h>
#include <stdlib.h>
#include <unistd.h>

#define WIDTH 30
#define HEIGHT 10

/* Not being root, or having root's EUID is a waste of time here */

int startx = 0;
int starty = 0;
int alpha = 1;

char *choices[] = {
			"Create Snapshot",
			"Change Snapshot",
			"Make ISO from Snapshot",
			"make stage3 tarball",
			"edit env variables",
			"Exit",
		  };
int n_choices = sizeof(choices) / sizeof(char *);
void print_menu(WINDOW *menu_win, int highlight);

int main()
{
    if(geteuid() != 0) {
	/* Check if user is root, yell at them if they aren't and exit */
	printf("\033[1;31mYou need SU rights to perform these tasks\033[1;m\n\n");
	exit(1);
    }


	while(alpha != 0){
		WINDOW *menu_win;
		int highlight = 1;
		int choice = 0;
		int c, row, col;

		initscr();
		clear();
		noecho();
		cbreak();	/* Line buffering disabled. pass on everything */
		startx = (40 - WIDTH) / 2;
		starty = (20 - HEIGHT) / 2;

		menu_win = newwin(HEIGHT, WIDTH, starty, startx);
		keypad(menu_win, TRUE);
		attron(A_BOLD);
		mvprintw(0, 8, "BBQ sys2iso");
		attroff(A_BOLD);
		mvprintw(2, 4, "Use arrow keys to go up and down");
		mvprintw(3, 4, " Press enter to select a choice");
		refresh();
		print_menu(menu_win, highlight);
		while (choice == 0){
			getmaxyx(stdscr, row, col);
			if(row < 22 || col < 60){
				endwin();
				printf("\n\033[1;31mTerm must be at least 60 x 22\n\n\033[1;m");
				alpha = 0;
				exit(1);
			}
			c = wgetch(menu_win);
			switch(c){
				case KEY_UP:
					if(highlight == 1)
						highlight = n_choices;
					else
						--highlight;
					break;
				case KEY_DOWN:
					if(highlight == n_choices)
						highlight = 1;
					else
						++highlight;
					break;
				case 10:
					choice = highlight;
					break;
				default:
					mvprintw(15, 0, "Please Choose an option.");
					refresh();
					break;
			}
			print_menu(menu_win, highlight);
			if(choice != 0)
				break;
		}
		if(choice == 6){	/*clean exit, requires change if main menu has more items*/
			endwin();
			printf("\033[2J\033[1;H");
			printf("\n\n\033[1;31mHappy roasting!\033[1;m\n\n");
			alpha = 0;
			exit(1);
		}
		else if(choice == 1){ /*create snapshot*/
			def_prog_mode();
			endwin();
			printf("\033[2J\033[1;H");
			printf("This should be the Create Snapshot script\n\n");
			system("/usr/local/bin/system2iso");
			reset_prog_mode();
			refresh();
			choice = 0;
		}
		else if(choice == 2){ /* change snapshot */
			def_prog_mode();
			endwin();
			printf("\033[2J\033[1;H");
			printf("This should be the chroot script section\n\n");
			system("/bin/bash /usr/local/bin/system2iso_chroot");
			getch();
			reset_prog_mode();
			refresh();
		}
		else if(choice == 3){ /* make ISO from snapshot */
			def_prog_mode();
			endwin();
			printf("\033[2J\033[1;H");
			printf("This SHOULD be the ISO from Snapshot section\n\n");
 			system("/usr/local/bin/system2iso_last");
			reset_prog_mode();
			refresh();
		}
		else if(choice == 4){ /* make stage3 tarball from snapshot */
			def_prog_mode();
			endwin();
			printf("\033[2J\033[1;H");
			printf("This should be the stage 3 section\n\n");
			system("/bin/bash"); /*this should be full path to script */
			reset_prog_mode();
			refresh();
		}
		else if(choice == 5){
			def_prog_mode();
			endwin();
			printf("\033[2J\033[1;H");
			printf("This should be the environment editing section\n\n");
			system("/bin/bash"); /*this should be full path to script */
			reset_prog_mode();
			refresh();
		}
		clrtoeol();
		refresh();
	}
	endwin();
	return 0;
}

void print_menu(WINDOW *menu_win, int highlight)
{
	int x, y, i;

	x = 2;
	y = 2;
	box(menu_win, 0, 0);
	for(i = 0; i < n_choices; ++i){
		if(highlight == i + 1){
			wattron(menu_win, A_REVERSE);
			mvwprintw(menu_win, y, x, "%s", choices[i]);
			wattroff(menu_win, A_REVERSE);
		}
		else
			mvwprintw(menu_win, y, x, "%s", choices[i]);
		++y;
	}
	wrefresh(menu_win);
}
