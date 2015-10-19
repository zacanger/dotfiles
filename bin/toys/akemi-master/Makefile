CC=cc
PREFIX?=/usr
LD=$(CC)
LIBS=`pkg-config fuse --libs` `pkg-config xcb --libs`
CFLAGS=-Wall -c `pkg-config fuse --cflags` `pkg-config xcb --cflags`

SRC := $(wildcard *.c)
OBJ := $(SRC:.c=.o)

all: akemi

%.o: %.c *.h
	$(CC) $(CFLAGS) -o $@ $<

akemi: $(OBJ)
	$(LD) $(OBJ) $(LIBS) -o $@

install: akemi
	cp akemi $(PREFIX)/bin/

uninstall: 
	rm $(PREFIX)/bin/akemi

clean:
	rm *.o
	rm akemi
