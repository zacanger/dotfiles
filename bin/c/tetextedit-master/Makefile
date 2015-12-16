CFLAGS := -std=c99 -Wall -Wextra -Werror -pedantic -O2 -pipe \
	  -Wno-unused-function -Wno-unused-parameter
PREFIX ?= /usr/local
.PHONY : clean install
SOURCES := $(patsubst %.c,%.o,$(wildcard src/*.c))
all: $(SOURCES) te
.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<
te:
	$(CC) $(CFLAGS) $(SOURCES) -o bin/te
clean:
	rm -f bin/*
	rm -f src/*.o
install:
	mkdir -p "$(PREFIX)/bin"
	cp -r bin/ "$(PREFIX)/bin/"
