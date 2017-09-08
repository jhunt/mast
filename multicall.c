#include "mast.h"
#include <stdio.h>
#include <string.h>

#define UTILITY(x) extern int x ## _main(int, char **, char **)

UTILITY(basename);
UTILITY(cat);
UTILITY(true);
UTILITY(false);
UTILITY(wc);

typedef int (*mainfn)(int, char **, char **);
static struct {
	const char *program;
	mainfn      handler;
} UTILS[] = {
	{ "basename", basename_main },
	{ "cat",      cat_main      },
	{ "false",    false_main    },
	{ "true",     true_main     },
	{ "wc",       wc_main       },
	{ NULL, NULL }
};

#undef  UTILITY

int main(int argc, char **argv, char **envp) {
	char *program;
	int i;

	program = basename(argv[0]);
	//fprintf(stderr, "mast: running `%s'\n", program);

	for (i = 0; UTILS[i].program; i++)
		if (strcmp(program, UTILS[i].program) == 0)
			return UTILS[i].handler(argc, argv, envp);

	fprintf(stderr, "mast: unrecognized utility `%s'\n", program);
	return 2;
}
