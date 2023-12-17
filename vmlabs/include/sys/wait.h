#ifndef _SYS_WAIT_H
#define _SYS_WAIT_H

#include <sys/types.h>

#define WNOHANG 1
#define WUNTRACED 2

#define WIFEXITED(w)	(((w) & 0377) == 0)
#define WIFSIGNALED(w)	(((w) & 0377) != 0177 && ((w) & ~0377) == 0)
#define WIFSTOPPED(w)	(((w) & 0377) == 0177)
#define WEXITSTATUS(w)	(((w) >> 8) & 0377)
#define WTERMSIG(w)	((w) & 0177)
#define WSTOPSIG	WEXITSTATUS

pid_t wait (int *);
pid_t waitpid (pid_t, int *, int);

#endif
