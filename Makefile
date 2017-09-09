BINS := mast
BINS := cmast

FUNCS :=
FUNCS += basename

UTILS :=
UTILS += util/basename.c
UTILS += util/cat.c
UTILS += util/false.c
UTILS += util/true.c
UTILS += util/uniq.c
UTILS += util/wc.c

ALIASES :=
ALIASES += basename
ALIASES += cat
ALIASES += false
ALIASES += true
ALIASES += uniq
ALIASES += wc

all: $(BINS)
	strip --strip-all $+
	for bin in $(ALIASES); do \
		ln -sf cmast $$bin; \
	done

clean:
	rm -f $(BINS:=.o) $(FUNCS:=.o)
	rm -f $(BINS)
	rm -f $(ALIASES)

test: check
check: all
	PATH=.:$$PATH ./tests/run ./tests/*.t

cmast: multicall.o $(FUNCS:=.o) $(UTILS:.c=.o)
	$(CC) $(CFLAGS) $(LDFLAGS) $(LIBS) $+ -o $@

%: %.s
	nasm -f elf64 $+
	$(LD) $*.o -o $@

util/%.o: util/%.c
	$(CC) -I. $(CFLAGS) -c $+ -o $@
