PREFIX:=/usr/local
MANPREFIX:=${PREFIX}/share/man

CC = cc
LD= ${CC}
RM = rm
CFLAGS = -Wall
LDFLAGS =

.SUFFIXES: .c .o .gz
.PHONY : all clean install uninstall

.c.o:
	@echo -e "CC $<"
	@${CC} -c ${CFLAGS} $< -o $@

human: human.o
	@echo -e "LD human"
	@${LD} $^ -o $@ ${LDFLAGS}

all : human human.1

clean :
	${RM} -f human *.o *.gz *~

install: human human.1
	install -D -m 0755 human ${DESTDIR}${PREFIX}/bin/human
	install -D -m 0644 human.1 ${DESTDIR}${MANPREFIX}/man1/human.1

uninstall:
	${RM} ${DESTDIR}${PREFIX}/bin/human
	${RM} ${DESTDIR}${MANPREFIX}/man1/human.1
