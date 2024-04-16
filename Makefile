.PHONY: clean distclean default

CC=gcc
CFLAGS=-Wall

default: mbc

lexer.c: lexer.l
	flex -s -o lexer.c lexer.l

lexer.o: lexer.c lexer.h parser.h

parser.h parser.c: parser.y
	bison -dv -o parser.c parser.y

parser.o: parser.c lexer.h

mbc: lexer.o parser.o
	$(CC) $(CFLAGS) -o mbc lexer.o parser.o

clean:
	$(RM) lexer.c parser.c parser.h parser.output *.o

distclean: clean
	$(RM) mbc
