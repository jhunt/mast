#include "mast.h"
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#define COUNT_LINES  1
#define COUNT_WORDS  2
#define COUNT_CHARS  4
#define COUNT_OCTETS 8

#define OCTETS 0
#define CHARS  1
#define WORDS  2
#define LINES  3

static unsigned long total[4];

static void print(unsigned long d[4], int mode, const char *file)
{
	if (file) {
		switch (mode) {
		case COUNT_OCTETS: fprintf(stdout, "%7lu %s\n", d[OCTETS], file); break;
		case COUNT_CHARS:  fprintf(stdout, "%7lu %s\n", d[CHARS],  file); break;
		case COUNT_WORDS:  fprintf(stdout, "%7lu %s\n", d[WORDS],  file); break;
		case COUNT_LINES:  fprintf(stdout, "%7lu %s\n", d[LINES],  file); break;

		case COUNT_OCTETS | COUNT_WORDS: fprintf(stdout, "%7lu %7lu %s\n", d[WORDS], d[OCTETS], file); break;
		case COUNT_OCTETS | COUNT_LINES: fprintf(stdout, "%7lu %7lu %s\n", d[LINES], d[OCTETS], file); break;
		case COUNT_CHARS  | COUNT_WORDS: fprintf(stdout, "%7lu %7lu %s\n", d[WORDS], d[CHARS],  file); break;
		case COUNT_CHARS  | COUNT_LINES: fprintf(stdout, "%7lu %7lu %s\n", d[LINES], d[CHARS],  file); break;
		case COUNT_WORDS  | COUNT_LINES: fprintf(stdout, "%7lu %7lu %s\n", d[LINES], d[WORDS],  file); break;

		case COUNT_OCTETS | COUNT_WORDS | COUNT_LINES: fprintf(stdout, "%7lu %7lu %7lu %s\n", d[LINES], d[WORDS], d[OCTETS], file); break;
		case COUNT_CHARS  | COUNT_WORDS | COUNT_LINES: fprintf(stdout, "%7lu %7lu %7lu %s\n", d[LINES], d[WORDS], d[CHARS],  file); break;
		}
	} else {
		switch (mode) {
		case COUNT_OCTETS: fprintf(stdout, "%7lu\n", d[OCTETS]); break;
		case COUNT_CHARS:  fprintf(stdout, "%7lu\n", d[CHARS]);  break;
		case COUNT_WORDS:  fprintf(stdout, "%7lu\n", d[WORDS]);  break;
		case COUNT_LINES:  fprintf(stdout, "%7lu\n", d[LINES]);  break;

		case COUNT_OCTETS | COUNT_WORDS: fprintf(stdout, "%7lu %7lu\n", d[WORDS], d[OCTETS]); break;
		case COUNT_OCTETS | COUNT_LINES: fprintf(stdout, "%7lu %7lu\n", d[LINES], d[OCTETS]); break;
		case COUNT_CHARS  | COUNT_WORDS: fprintf(stdout, "%7lu %7lu\n", d[WORDS], d[CHARS]);  break;
		case COUNT_CHARS  | COUNT_LINES: fprintf(stdout, "%7lu %7lu\n", d[LINES], d[CHARS]);  break;
		case COUNT_WORDS  | COUNT_LINES: fprintf(stdout, "%7lu %7lu\n", d[LINES], d[WORDS]);  break;

		case COUNT_OCTETS | COUNT_WORDS | COUNT_LINES: fprintf(stdout, "%7lu %7lu %7lu\n", d[LINES], d[WORDS], d[OCTETS]); break;
		case COUNT_CHARS  | COUNT_WORDS | COUNT_LINES: fprintf(stdout, "%7lu %7lu %7lu\n", d[LINES], d[WORDS], d[CHARS]);  break;
		}
	}

}

static void do_wc(int fd, const char * file, int mode)
{
	char buf[8192];
	ssize_t n;
	int i, inspace, utf8n;

	unsigned long c[] = { 0, 0, 0, 0 };

	inspace = 0;
	utf8n = 0;
	while ((n = read(fd, buf, 8192)) != 0) {
		c[OCTETS] += n;
		for (i = 0; i < n; i++) {
			if (buf[i] == '\n') c[LINES]++;
			if (isspace(buf[i])) {
				if (!inspace) {
					c[WORDS]++;
					inspace = 1;
				}
			} else inspace = 0;

			if (utf8n > 1) utf8n--;
			else {
				     if ((buf[i] & 0xf0) == 0xc0) utf8n = 1;
				else if ((buf[i] & 0xf0) == 0xe0) utf8n = 2;
				else if ((buf[i] & 0xf0) == 0xf0) utf8n = 3;
				else c[CHARS]++;
			}
		}
	}
	if (n < 0) {
		fprintf(stderr, "%s: %s\n", file ? file : "<stdin>", strerror(errno));
		return;
	}

	print(c, mode, file);
	total[OCTETS] += c[OCTETS];
	total[CHARS]  += c[CHARS];
	total[WORDS]  += c[WORDS];
	total[LINES]  += c[LINES];
}

int wc_main(int argc, char **argv, char **envp)
{
	int mode, n, i, j, rc, fd;

	mode = 0;

	/* check for arguments */
	for (i = 1; i < argc; i++) {
		if (argv[i][0] != '-')
			break;

		for (j = 1; argv[i][j]; j++) {
			switch (argv[i][j]) {
			case 'c': mode |= COUNT_OCTETS; break;
			case 'm': mode |= COUNT_CHARS;  break;
			case 'w': mode |= COUNT_WORDS;  break;
			case 'l': mode |= COUNT_LINES;  break;
			default:
				fprintf(stderr, "wc: unrecognized option '-%c'\n", argv[i][j]);
				return 1;
			}
		}
	}

	if (!mode)
		mode = COUNT_OCTETS | COUNT_WORDS | COUNT_LINES;

	rc = 0;
	n = 0;
	if (i < argc) {
		/* read all the operand files, ignoring standard input */
		for (; i < argc; i++) {
			fd = open(argv[i], O_RDONLY);
			if (fd < 0) {
				fprintf(stderr, "%s: %s\n", argv[i], strerror(errno));
				rc = 1;
				continue;
			}

			do_wc(fd, argv[i], mode);
			close(fd);
			n++;
		}
		if (n > 1)
			print(total, mode, "total");

	} else {
		/* only read standard input */
		do_wc(0, NULL, mode);
	}

	return rc;
}
