AWK_INCLUDE = /root/SPAWK/gawk
SQL_INCLUDE = /usr/include/mysql
LIB = libspawk.so
LIB_r = libspawk_r.so
OBJ = spawk.o
BU_LIST = README Makefile tools/*.sh src.stable/*.c src/*.c \
	lib/* bin/* Test/* Sample/*

.SUFFIXES:

all: $(LIB) $(LIB_r)

$(LIB): $(OBJ)
	@sh tools/makelib.sh $(LIB) /usr/lib/mysql/libmysqlclient.so

$(LIB_r): $(OBJ)
	@sh tools/makelib.sh $(LIB_r) /usr/lib/mysql/libmysqlclient_r.so

$(OBJ): spawk.c
	@sh tools/checkincl.sh $(AWK_INCLUDE) awk.h
	@sh tools/checkincl.sh $(SQL_INCLUDE) mysql.h
	@echo "Compiling \`spawk.c'..."
	@gcc -shared -g -c -O -I$(AWK_INCLUDE) -I$(SQL_INCLUDE) \
		-D_SPAWK_DEBUG -DHAVE_CONFIG_H spawk.c
	@strip --strip-unneeded $(OBJ)

install: $(LIB) $(LIB_r)
	@cp $(LIB) $(LIB_r) /usr/lib/

test:
	@make
	@-gawk -f Test/test99.awk 2>error
	@[ -s error ] && cat error >&2; rm -f error

cleanup:
	@rm -f spawk.[co] spawk.lst spawk.txt $(LIB) $(LIB_r) \
		BACKUP SPAWK TEST

fresh:
	@make cleanup
	@make

BACKUP: SPAWK TEST
	@make install
	@sh tools/backup.sh

SPAWK: $(BU_LIST)
	@make all
	@tar -czvf spawk.tar $(BU_LIST) >spawk.lst
	tar -cf SPAWK lib/install spawk.tar

spawk.c: src.stable/*.c src/*.c
	@sh tools/makesrc.sh >spawk.c
	@sh tools/makeprn.sh >spawk.txt

man:
	@groff -T ascii -man -rLL=6.5i -rLT=7.7i \
		lib/spawk.man | less -is

TEST: Test/*
	@(cd Test && tar -czvf ../TEST * >/dev/null)
