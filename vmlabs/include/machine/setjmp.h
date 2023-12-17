#ifdef __sparc__
/*
 * onsstack,sigmask,sp,pc,npc,psr,g1,o0,wbcnt (sigcontext).
 * All else recovered by under/over(flow) handling.
 */
#define	_JBLEN	9
#endif
/* necv70 was 9 as well. */
#ifdef __mc68000__
/*
 * onsstack,sigmask,sp,pc,psl,d2-d7,a2-a6,
 * fp2-fp7	for 68881.
 * All else recovered by under/over(flow) handling.
 */
#define	_JBLEN	34
#endif

#if defined(__Z8001__) || defined(__Z8002__)
/* 16 regs + pc */
#define _JBLEN 20
#endif

#ifdef ___AM29K__
/*
 * onsstack,sigmask,sp,pc,npc,psr,g1,o0,wbcnt (sigcontext).
 * All else recovered by under/over(flow) handling.
 */
#define	_JBLEN	9
#endif
#ifdef __i386__
#ifdef __unix__
# define _JBLEN	36
#elif defined(__WIN32__)
#define _JBLEN (13 * 4)
#else
#include "setjmp-dj.h"
#endif
#endif
#ifdef __i960__
#define _JBLEN 35
#endif

#ifdef __mips__
#define _JBLEN 11
#endif

#ifdef __m88000__
#define _JBLEN 21
#endif

#if defined(__powerpc__) || defined(__PPC__)
#define _JBLEN 62
#endif

#ifdef _JBLEN
typedef	int jmp_buf[_JBLEN];
/*
 * One extra word for the "signal mask saved here" flag.
 */
typedef	int sigjmp_buf[_JBLEN+1];
#endif

#ifdef __H8300__
#define _JBLEN 5
typedef int jmp_buf[_JBLEN];
#endif

#ifdef __H8300H__
/* same as H8/300 but registers are twice as big */
#define _JBLEN 10
typedef int jmp_buf[_JBLEN];
#endif

#ifdef __H8500__
#define _JBLEN 4
typedef int jmp_buf[_JBLEN];
#endif

#ifdef  __sh__
#define _JBLEN 20
typedef int jmp_buf[_JBLEN];
#endif

#ifdef  __v800
#define _JBLEN 28
typedef int jmp_buf[_JBLEN];
#endif

#ifdef __hppa__
/* %r30, %r2-%r18, %r27, pad, %fr12-%fr15.
   Note space exists for the FP registers, but they are not
   saved.  */
#define _JBLEN 28
typedef int jmp_buf[_JBLEN];
#endif

#ifdef __nuon__
#define _JBLEN 21
typedef int jmp_buf[_JBLEN];
#endif
