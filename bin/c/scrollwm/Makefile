CFLAGS	+=	-Os -Wall -Wno-unused-parameter -Wno-unused-result
PROG	=	scrollwm
LIBS	=	-lX11
PREFIX	?=	/usr
MANDIR	?=	/usr/share/man
VER		=	0.1

$(PROG): $(PROG).c config.h icons.h
	@$(CC) $(CFLAGS) $(LIBS) -o $(PROG) $(PROG).c
	@strip $(PROG)
#	@gzip -c $(PROG).1 > $(PROG).1.gz

clean:
	@rm -f $(PROG)
#	@rm -f $(PROG).1.gz

tarball: clean
	@rm -f ttwm.tar.gz
	@tar -czf ttwm-${VER}.tar.gz *

install:
	@mkdir -p ${DESTDIR}${PREFIX}/bin
	@install -m755 ${PROG} ${DESTDIR}${PREFIX}/bin/${PROG}
#	@install -Dm666 $(PROG).1.gz ${DESTDIR}${MANDIR}/man1/$(PROG).1.gz

