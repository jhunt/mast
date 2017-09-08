#include "mast.h"
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>

static void do_cat(int fd)
{
	char buf[8192];
	ssize_t n, writ, left;

	while ((n = read(fd, buf, 8192)) != 0) {
		left = n;
		while (left > 0) {
			writ = write(1, buf, left);
			if (writ < 0) {
				fprintf(stderr, "fd %d: %s\n", fd, strerror(errno));
				return;
			}
			left -= writ;
		}
	}
}

int cat_main(int argc, char **argv, char **envp)
{
	int i, rc, fd;

	/* check for arguments */
	for (i = 1; i < argc; i++) {
		if (argv[i][0] != '-')
			break;

		if (argv[i][1] == 'u' && !argv[i][2])
			continue;
		fprintf(stderr, "cat: unrecognized option '%s'\n", argv[i]);
		return 1;
	}

	rc = 0;
	if (i < argc) {
		/* read all the operand files, ignoring standard input */
		for (; i < argc; i++) {
			fd = open(argv[i], O_RDONLY);
			if (fd < 0) {
				fprintf(stderr, "%s: %s\n", argv[i], strerror(errno));
				rc = 1;
				continue;
			}

			do_cat(fd);
			close(fd);
		}
	} else {
		/* only read standard input */
		do_cat(0);
	}

	return rc;
}
