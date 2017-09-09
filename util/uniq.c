#include "mast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

#define EXPAND 8192

#define OPT_COUNT 1
#define OPT_DUPES 2
#define OPT_UNIQS 4

static int flags = 0;
static int skip_bytes = 0;
static int skip_fields = 0;

static void print(FILE *out, const char *line, unsigned long count)
{
	if (flags & OPT_DUPES && count == 1)
		return;
	if (flags & OPT_UNIQS && count > 1)
		return;

	if (flags & OPT_COUNT) fprintf(out, "%7lu %s\n", count, line);
	else                   fprintf(out, "%s\n", line);
}

static int offset(const char *line)
{
	int i, fields;
	int inspace;

	if (skip_fields == 0)
		return 0;

	fields = 0;
	inspace = 0;
	for (i = 0; line[i]; i++) {
		if (inspace && !isspace(line[i])) {
			inspace = 0;
			if (++fields >= skip_fields)
				return i;

		} else if (!inspace &&  isspace(line[i])) {
			inspace = 1;
		}
	}

	return i;
}

static int diff(const char *prev, int p_len, const char *this, int t_len)
{
	int p_skip, t_skip;

	p_skip = skip_bytes + offset(prev);
	t_skip = skip_bytes + offset(this);

	if (p_len < p_skip && t_len < t_skip)
		return 0; /* same */

	if (p_len < p_skip || t_len < t_skip)
		return 1; /* different */

	if (p_len - p_skip != t_len - t_skip)
		return 1; /* different */

	return strcmp(prev+p_skip, this+t_skip) != 0;
}

static void do_uniq(FILE *in, FILE *out)
{
	char c, *prev, *this, *tmp;
	int i, n, len;
	unsigned long count;

	prev = this = NULL;
	len = i = n = count = 0;
	while ((c = getc(in)) != EOF) {
		if (i + 2 >= n) {
			n += EXPAND;
			tmp = realloc(this, n);
			if (!tmp) {
				fprintf(stderr, "uniq: %s\n", strerror(errno));
				exit(1);
			}
			this = tmp;
		}
		this[i] = c;
		if (c != '\n') i++;
		else {
			this[i] = '\0';
			if (prev && diff(prev, len, this, i)) {
				print(out, prev, count);
				count = 0;

				free(prev);
				prev = NULL;
			}

			if (!prev) {
				prev = this;
				len = i;
			}
			this = NULL;
			i = n = 0;

			count++;
		}
	}
	if (!this && prev)
		print(out, prev, count);
}

int uniq_main(int argc, char **argv, char **envp)
{
	int i, j, early;
	FILE *in, *out;
	char *number;

	/* check for arguments */
	flags = 0;
	for (i = 1; i < argc; i++) {
		if (argv[i][0] != '-')
			break;

		early = 0;
		for (j = 1; !early && argv[i][j]; j++) {
			switch (argv[i][j]) {
			case 'c': flags |= OPT_COUNT; break;
			case 'd': flags |= OPT_DUPES; break;
			case 'u': flags |= OPT_UNIQS; break;
			case 'f':
				if (argv[i][j+1]) number = &argv[i][j+1];
				else {
					if (i+1 >= argc) {
						fprintf(stderr, "uniq: -f requires an argument.\n");
						exit(1);
					}
					number = argv[++i];
				}
				skip_fields = 0;
				for (; *number; number++) {
					if (*number >= '0' && *number <= '9')
						skip_fields = skip_fields * 10 + (*number - '0');
					else {
						fprintf(stderr, "uniq: invalid number of fields to skip for -f\n");
						exit(1);
					}
				}
				early = 1;
				break;

			case 's':
				if (argv[i][j+1]) number = &argv[i][j+1];
				else {
					if (i+1 >= argc) {
						fprintf(stderr, "uniq: -s requires an argument.\n");
						exit(1);
					}
					number = argv[++i];
				}
				skip_bytes = 0;
				for (; *number; number++) {
					if (*number >= '0' && *number <= '9')
						skip_bytes = skip_bytes * 10 + (*number - '0');
					else {
						fprintf(stderr, "uniq: invalid number of bytes to skip for -s\n");
						exit(1);
					}
				}
				early = 1;
				break;

			default:
				fprintf(stderr, "uniq: unrecognized option '-%c'\n", argv[i][j]);
				return 1;
			}
		}
	}

	if (argc - i > 2) {
		fprintf(stderr, "uniq: extra operand '%s'\n", argv[i+2]);
		return 1;
	}

	in  = stdin;
	out = stdout;
	if (argc - i > 0) {
		in = fopen(argv[i], "r");
		if (!in) {
			fprintf(stderr, "%s: %s\n", argv[i], strerror(errno));
			return 1;
		}
	}

	if (argc - i > 1) {
		out = fopen(argv[i+1], "w");
		if (!out) {
			fprintf(stderr, "%s: %s\n", argv[i+1], strerror(errno));
			return 1;
		}
	}

	do_uniq(in, out);
	return 0;
}
