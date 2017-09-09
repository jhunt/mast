#include "mast.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#define SILENT   1
#define SHOWBYTE 2

int cmp_main(int argc, char **argv, char **envp)
{
	int i, j, flags, rc;
	int line, pos, byte;
	FILE *a, *b;
	char ac, bc;

	/* check for arguments */
	flags = 0;
	for (i = 1; i < argc; i++) {
		if (argv[i][0] != '-')
			break;

		if (!argv[i][1])
			break;

		for (j = 1; argv[i][j]; j++) {
			switch (argv[i][j]) {
			case 's': flags |= SILENT;   break;
			case 'l': flags |= SHOWBYTE; break;
			default:
				fprintf(stderr, "cmp: unrecognized option '-%c'\n", argv[i][j]);
				return 1;
			}
		}
	}

	if (flags == (SILENT | SHOWBYTE)) {
		fprintf(stderr, "cmp: the -s and -l options are incompatible\n");
		return 2;
	}

	if (argc - i != 2) {
		fprintf(stderr, "cmp: missing operand\n");
		return 2;
	}

	rc = 0;
	if (argv[i][0] == '-' && !argv[i][1])
		a = stdin;
	else {
		a = fopen(argv[i], "r");
		if (!a) {
			fprintf(stderr, "%s: %s\n", argv[i], strerror(errno));
			rc = 1;
		}
	}

	if (argv[i+1][0] == '-' && !argv[i+1][1])
		b = stdin;
	else {
		b = fopen(argv[i+1], "r");
		if (!b) {
			fprintf(stderr, "%s: %s\n", argv[i+1], strerror(errno));
			rc = 1;
		}
	}

	if (rc) return rc;

	line = pos = byte = 1;
	for (;;) {
		ac = getc(a);
		bc = getc(b);

		if (ac == EOF && bc == EOF)
			return 0;

		if (ac == EOF) {
			fprintf(stderr, "cmp: EOF on %s\n", argv[i]);
			return 1;
		}
		if (bc == EOF) {
			fprintf(stderr, "cmp: EOF on %s\n", argv[i+1]);
			return 1;
		}

		if (ac != bc) {
			if (flags & SILENT) return 1;

			if (flags & SHOWBYTE) {
				fprintf(stdout, "%d %o %o\n", byte, (unsigned char)ac, (unsigned char)bc);
			} else {
				fprintf(stdout, "%s %s differ: char %d, line %d\n",
				                argv[i], argv[i+1], pos, line);
				return 1;
			}
		}

		if (ac == '\n') {
			line++;
			pos = 0;
		}
		pos++;
		byte++;
	}

	return 0;
}
