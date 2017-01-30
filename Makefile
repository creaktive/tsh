CC		= gcc
RM		= rm -f
STRIP		= strip
CFLAGS		= -O3 -W -Wall

TOOLCHAIN	= /var/toolchain/sys30

COMM		= pel.o aes.o sha1.o
TSH		= tsh
TSHD		= tshd

VERSION=tsh-0.7
CLIENT_OBJ=pel.c aes.c sha1.c  tsh.c
SERVER_OBJ=pel.c aes.c sha1.c tshd.c

DISTFILES= \
    sha1.h \
    README \
    ChangeLog\
    pel.h \
    Makefile \
    aes.h\
    tsh.h\
    $(CLIENT_OBJ) $(SERVER_OBJ)

all:
	@echo
	@echo "Please specify one of these targets:"
	@echo
	@echo "	make linux"
	@echo "	make linux_x64"
	@echo "	make freebsd"
	@echo "	make openbsd"
	@echo "	make netbsd"
	@echo "	make cygwin"
	@echo "	make sunos"
	@echo "	make irix"
	@echo "	make hpux"
	@echo "	make osf"
	@echo "	make iphone"
	@echo "	make darwin"
	@echo
	make `uname | tr A-Z a-z`

osx: darwin

darwin:
	$(MAKE)								\
		CC="clang"						\
		LDFLAGS="$(LDFLAGS) -lutil"				\
		DEFS="$(DEFS) -DOPENBSD"				\
		$(TSH) $(TSHD)

iphone:
	$(MAKE)								\
		CFLAGS="$(CFLAGS) -I$(TOOLCHAIN)/usr/include"		\
		LDFLAGS="$(LDFLAGS) -L$(TOOLCHAIN)/usr/lib -lutil"	\
		DEFS="$(DEFS) -DOPENBSD"				\
		$(TSH) $(TSHD)
	ldid -S $(TSH)
	ldid -S $(TSHD)

linux:
	gcc -O -W -Wall -o tsh  $(CLIENT_OBJ)
	gcc -O -W -Wall -o tshd $(SERVER_OBJ) -lutil -DLINUX
	strip tsh tshd

linux_x64:
	$(MAKE)								\
		LDFLAGS="$(LDFLAGS) -Xlinker --no-as-needed -lutil"	\
		DEFS="$(DEFS) -DLINUX"					\
		$(TSH) $(TSHD)

openbsd:
	$(MAKE)								\
		LDFLAGS="$(LDFLAGS) -lutil"				\
		DEFS="$(DEFS) -DOPENBSD"				\
		$(TSH) $(TSHD)

freebsd:
	$(MAKE)								\
		LDFLAGS="$(LDFLAGS) -lutil"				\
		DEFS="$(DEFS) -DFREEBSD"				\
		$(TSH) $(TSHD)

netbsd: openbsd

sunos:
	$(MAKE)								\
		LDFLAGS="$(LDFLAGS) -lsocket -lnsl"			\
		DEFS="$(DEFS) -DSUNOS"					\
		$(TSH) $(TSHD)

cygwin:
	$(MAKE)								\
		DEFS="$(DEFS) -DCYGWIN"					\
		$(TSH) $(TSHD)

irix:
	$(MAKE)								\
		CC="cc"							\
		CFLAGS="-O"						\
		DEFS="$(DEFS) -DIRIX"					\
		$(TSH) $(TSHD)

hpux:
	$(MAKE)								\
		CC="cc"							\
		CFLAGS="-O"						\
		DEFS="$(DEFS) -DHPUX"					\
		$(TSH) $(TSHD)

osf:
	$(MAKE)								\
		CC="cc"							\
		CFLAGS="-O"						\
		DEFS="$(DEFS) -DOSF"					\
		$(TSH) $(TSHD)

$(TSH): $(COMM) tsh.o
	$(CC) ${LDFLAGS} -o $(TSH) $(COMM) tsh.o
	$(STRIP) $(TSH)

$(TSHD): $(COMM) tshd.o
	$(CC) ${LDFLAGS} -o $(TSHD) $(COMM) tshd.o
	$(STRIP) $(TSHD)

aes.o: aes.h
pel.o: aes.h pel.h sha1.h
sha1.o: sha1.h
tsh.o: pel.h tsh.h
tshd.o: pel.h tsh.h

.c.o:
	$(CC) ${CFLAGS} ${DEFS} -c $*.c

clean:
	$(RM) $(TSH) $(TSHD) *.o core


dist:
	mkdir $(VERSION)
	cp $(DISTFILES) $(VERSION)
	tar -czf $(VERSION).tar.gz $(VERSION)
	rm -r $(VERSION)

