#include "mast.h"
#include <string.h>

char* basename(char *s)
{
	char *p;

	p = strrchr(s, '/');
	if (p) return p + 1;
	return s;
}
