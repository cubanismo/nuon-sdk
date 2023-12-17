/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

/*
 * Misc. utility functions
 */

#ifndef MPEUTIL_H
#define MPEUTIL_H

#include <nuon/bios.h>

#ifdef __cplusplus
extern "C" {
#endif

/* comm bus functions */
void CommSend(int target, long packet[]);
int CommRecv(long packet[]);
int CommRecvQuery(long packet[]);

void CommSendInfo(int target, int info, long packet[]);
int CommRecvInfo(int *info, long packet[]);
int CommRecvQueryInfo(int *info, long packet[]);

int CommSendRecv(int target, long packet[]);

/* video functions */
void VidSetup(void *base, long dmaflags, int width, int height, int filter);

/* timer functions */
void InitTimer(void);
long GetTimer(long *secs, long *usecs);

/* MPE running functions */

#define StopMPE(mpe) _MPEStop(mpe)
#define WaitMPE(mpe) _MPEWait(mpe)
#define ReadMPERegister(mpe, regaddr) _MPEReadRegister(mpe, regaddr)
#define WriteMPERegister(mpe, regaddr, value) _MPEWriteRegister(mpe, regaddr, value)

/* NOTE: "dest" must be an MPE-relative address */
void CopyToMPE(int mpe, void *dest, void *src, long size);

/* NOTE: "src" must be an MPE-relative address */
void CopyFromMPE(int mpe, void *dest, void *src, long size);

void StartMPE(int mpe, void *codestart, long codesize, void *datastart, long datasize);

/* DMA and misc. related drawing functions in libmutil */
/* (mostly syntactic sugar for BIOS calls) */

/* write a string using an ugly, LED like font -- useful for debugging */
extern void
DebugWS(long dmaflags, void *dmaaddr, int xpos, int ypos, long color, const char *str);


/* write data to another MPE from external memory */
extern void _mpedma(long dmaflags, void *externaddr, void *internaddr, int mpe);

/* read/write another MPE's register */
extern long _mpedmaregister(long dmaflags, void *externaddr, long data, int mpe);

/* read/write other bus memory, 32 bits only */
extern long _obusdmascalar(long dmaflags, void *externaddr, long data);

/* fixed point functions */
static inline double FixToDouble(int fix, int numbits)
{
    return (double)fix/(double)(1<<numbits);
}

static inline int DoubleToFix(double d, int numbits)
{
    return (int)(d * (double)(1<<numbits));
}

/* calculate sine and cosine of a 16.16 rotation, return as 2.30 fixed point */
int FixSinCos(int angle, int *sinval, int *cosval);

/* calculate a/b, assuming b as "shift" fracbits (answer has same fracbits as a) */
int FixDiv(int a, int b, int shift) __attribute__ ((const));

/* calculate 1/a, assuming "a" has "fracbits" fractional bits; the
 * upper 32 bits of the return has the reciprocal, the lower 32 bits has
 * the fracbits of the reciprocal
 * NOTE: a must be greater than 0.
 */
long long FixRecip(int a, int fracbits) __attribute__ ((const));

/* calculate sqrt(a), with the same number of fractional bits as a */
int FixSqrt(int a, int shift) __attribute__ ((const));

/* calculate 1/sqrt(a), with "ashift" being fractional bits in a, "rshift" fractional
   bits of result */
int FixRSqrt(int a, int ashift, int rshift) __attribute__ ((const));


/* the "nops" around the multiply are necessary to protect it
 * from 2 tick operations by the compiler; the assembler
 * will eliminate these if you use -mreopt
 */
#define FixMul(a,b,shift)                                               \
__extension__                                                           \
({      register int retvalue = a;                                      \
        __asm__                                                         \
        (" nop\n"                                                       \
         " mul    %2,%1,>>%3,%0\n"                                      \
         " nop\n"                                                       \
        : "=r"(retvalue)                        /* outputs */           \
        : "0"(retvalue), "r"(b), "ir"(shift)    /* inputs  */           \
        : "cc"                                  /* clobbered regs */    \
        );                                                              \
        retvalue;                                                       \
})

/*
 * macro to access an "internal memory" value from cached
 * code; this is designed to protect against a cache bug
 * which causes problems for consecutive loads, one from
 * cached memory which causes a miss, the next from
 * uncached (local) memory
 */
#define _GetLocalVar(variable)                                          \
__extension__                                                           \
({      register int retvalue;                                          \
        register volatile void *addr = &(variable);                     \
        __asm__ volatile                                                \
        (" nop\n"                                                       \
         " ld_io   (%1),%0\n"                                           \
         " nop\n"                                                       \
        : "=r"(retvalue)                        /* outputs */           \
        : "r"(addr)                             /* inputs  */           \
        );                                                              \
        retvalue;                                                       \
})

#define _SetLocalVar(variable,value)                                   \
__extension__                                                           \
({      register int theval = (int)value;                               \
        register volatile void *addr = &variable;                       \
        __asm__ volatile                                                \
        (" nop\n"                                                       \
         " st_io   %1,(%0)\n"                                            \
        :                                       /* outputs */           \
        : "r"(addr),"r"(theval)                 /* inputs  */           \
        );                                                              \
	theval;                                                         \
})
#ifdef __cplusplus
}
#endif

#endif

