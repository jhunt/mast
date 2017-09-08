UTILS := mast

ALIASES :=
ALIASES += true
ALIASES += false

all: $(UTILS)
	strip --strip-all $+
	for bin in $(ALIASES); do \
		ln -sf mast $$bin; \
	done

clean:
	rm -f $(UTILS:=.o)
	rm -f $(UTILS)
	rm -f $(ALIASES)

%: %.s
	nasm -f elf64 $+
	ld $*.o -o $@
