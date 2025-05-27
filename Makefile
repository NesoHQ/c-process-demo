CC = gcc
CFLAGS = -g -Wall

all: cow nofork p

cow: cow.c
	$(CC) $(CFLAGS) cow.c -o cow.out

nofork: nofork.c
	$(CC) $(CFLAGS) nofork.c -o nofork.out

p: p.c
	$(CC) $(CFLAGS) p.c -o p.out

clean:
	rm -f *.out
