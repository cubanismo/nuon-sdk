/* unified sys/types.h: 
   start with sef's sysvi386 version.
   merge go32 version -- a few ifdefs.
   h8300hms, h8300xray, and sysvnecv70 disagree on the following types:

   typedef int gid_t;
   typedef int uid_t;
   typedef int dev_t;
   typedef int ino_t;
   typedef int mode_t;
   typedef int caddr_t;

   however, these aren't "reasonable" values, the sysvi386 ones make far 
   more sense, and should work sufficiently well (in particular, h8300 
   doesn't have a stat, and the necv70 doesn't matter.) -- eichin
 */

#ifndef _SYS_TYPES_H
#define _SYS_TYPES_H

#ifdef __i386__
#if !defined (__unix__) || defined (_WIN32)
#define __go32_types__
#endif
#endif

# include <stddef.h>	
# include <machine/types.h>

# ifndef	_POSIX_SOURCE

#  define	physadr		physadr_t
#  define	quad		quad_t

#ifndef U_CHAR_DEFINED
#define U_CHAR_DEFINED
typedef	unsigned char	u_char;
#endif //U_CHAR_DEFINED

#ifndef U_SHORT_DEFINED
#define U_SHORT_DEFINED
typedef	unsigned short	u_short;
#endif //U_SHORT_DEFINED

#ifndef U_INT_DEFINED
#define U_INT_DEFINED
typedef	unsigned int	u_int;
#endif //U_INT_DEFINED

#ifndef U_LONG_DEFINED
#define U_LONG_DEFINED
typedef	unsigned long	u_long;
#endif //U_LONG_DEFINED

#ifndef USHORT_DEFINED
#define USHORT_DEFINED
typedef	unsigned short	ushort;		/* System V compatibility */
#endif //USHORT_DEFINED

#ifndef UINT_DEFINED
#define UINT_DEFINED
typedef	unsigned int	uint;		/* System V compatibility */
#endif //UINT_DEFINED
# endif	/*!_POSIX_SOURCE */

#ifndef __time_t_defined
typedef _TIME_T_ time_t;
#define __time_t_defined
#endif

typedef	long	daddr_t;
typedef	char *	caddr_t;

typedef int ssize_t;

#ifdef __go32_types__
typedef	unsigned long	ino_t;
#else
#ifdef __sparc__
typedef	unsigned long	ino_t;
#else
typedef	unsigned short	ino_t;
#endif
#endif

typedef	short	dev_t;

typedef	long	off_t;

typedef	unsigned short	uid_t;
typedef	unsigned short	gid_t;
typedef int pid_t;
typedef	long	key_t;

#ifdef __go32_types__
typedef	char *	addr_t;
typedef int mode_t;
#else
#if defined (__sparc__) && !defined (__sparc_v9__)
#ifdef __svr4__
typedef unsigned long mode_t;
#else
typedef unsigned short mode_t;
#endif
#else
typedef unsigned mode_t;
#endif
#endif /* ! __go32_types__ */

typedef unsigned int nlink_t;

# ifndef	_POSIX_SOURCE

#  define	NBBY	8		/* number of bits in a byte */
/*
 * Select uses bit masks of file descriptors in longs.
 * These macros manipulate such bit fields (the filesystem macros use chars).
 * FD_SETSIZE may be defined by the user, but the default here
 * should be >= NOFILE (param.h).
 */
#  ifndef	FD_SETSIZE
#	define	FD_SETSIZE	60
#  endif

typedef	long	fd_mask;
#  define	NFDBITS	(sizeof (fd_mask) * NBBY)	/* bits per mask */
#  ifndef	howmany
#	define	howmany(x,y)	(((x)+((y)-1))/(y))
#  endif

typedef	struct fd1_set {
	fd_mask	fds_bits[howmany(FD_SETSIZE, NFDBITS)];
} fd1_set;


#  define	FD_SET(n, p)	((p)->fds_bits[(n)/NFDBITS] |= (1L << ((n) % NFDBITS)))
#  define	FD_CLR(n, p)	((p)->fds_bits[(n)/NFDBITS] &= ~(1L << ((n) % NFDBITS)))
#  define	FD_ISSET(n, p)	((p)->fds_bits[(n)/NFDBITS] & (1L << ((n) % NFDBITS)))
#  define	FD_ZERO(p)	bzero((caddr_t)(p), sizeof (*(p)))

#  define 	sint8     char
#  define 	sint16    short
#  define 	sint32    long

#  define 	uint8     unsigned char
#  define 	uint16    unsigned short
#  define 	uint32    unsigned int

#  define 	vint8     volatile char
#  define 	vint16    volatile short
#  define 	vint32    volatile long

#  define 	vuint8    volatile unsigned char
#  define 	vuint16   volatile unsigned short
#  define 	vuint32   volatile unsigned long

# endif	/* _POSIX_SOURCE */
#undef __go32_types__
#endif	/* _SYS_TYPES_H */
