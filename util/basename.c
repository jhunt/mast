#include "mast.h"
#include <stdio.h>
#include <string.h>

int basename_main(int argc, char **argv, char **envp)
{
	char *name, *a, *b;

	if (argc < 2) {
		fprintf(stderr, "basename: missing operand\n");
		return 1;
	}
	if (argc > 3) {
		fprintf(stderr, "basename: extra operand '%s'\n", argv[3]);
		return 1;
	}

	/* strip the trailing slashes */
	name = argv[1] + strlen(argv[1]) - 1;
	while (*name == '/' && name > argv[1])
		*name-- = '\0';

	/* basename "" -> . */
	if (!*argv[1]) {
		fprintf(stdout, ".\n");
		return 0;
	}

	/* basename / -> / */
	if (strcmp(argv[1], "/") == 0) {
		fprintf(stdout, "/");
		return 0;
	}

	name = basename(argv[1]);
	if (argc == 3) {
		/* handle the suffix */
		a = name    + strlen(name);
		b = argv[2] + strlen(argv[2]);
		while (a >= name && b >= argv[2]) {
			if (*a != *b) goto done;
			a--; b--;
		}
		a++;
		if (a != name)
			*a = '\0';
	}

done:
	fprintf(stdout, "%s\n", name);
	return 0;
}
