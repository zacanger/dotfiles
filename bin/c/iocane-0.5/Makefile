
PROG    =  iocane
FLAGS   =  -lX11
VER     =  0.5
PREFIX  ?= /usr

${PROG}: ${PROG}.c
	@gcc -o ${PROG} ${PROG}.c ${FLAGS}
	@strip ${PROG}

man:
	@gzip -c ${PROG}.1 > ${PROG}.1.gz

clean:
	@rm -rf ${PROG} ${PROG}.1.gz

tarball: clean
	#@rm -rf ${PROG}-*.tar.gz
	@tar -czf ${PROG}-${VER}.tar.gz *

install: ${PROG} man
	@install -Dm755 ${PROG} ${DESTDIR}${PREFIX}/bin/${PROG}
	@install -Dm666 ${PROG}.1.gz ${DESTDIR}${PREFIX}/share/man/man1/${PROG}.1.gz
	@install -Dm666 ${PROG}rc ${DESTDIR}${PREFIX}/share/${PROG}/${PROG}rc
	

