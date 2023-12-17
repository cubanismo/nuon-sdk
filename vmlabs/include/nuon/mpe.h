/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


/*
 * BIOS MPE routines
 *
 */

#ifndef _MPE_H
#define _MPE_H

#ifdef __cplusplus
extern "C" {
#endif

/* definition to use in _MPEAlloc to get any MPE */
#define MPE_ANY           0

/* definitions for specific MPE capabilities */
#define MPE_HAS_ICACHE    0x01
#define MPE_HAS_DCACHE    0x02
#define MPE_HAS_CACHES    (MPE_HAS_ICACHE | MPE_HAS_DCACHE)

#define MPE_IRAM_8K       0x04
#define MPE_DTRAM_8K      0x08

#define MPE_HAS_MINI_BIOS 0x10

#define MPE_USER_FLAGS 0x00ffffff

/* the flags that are not "MPE_USER_FLAGS" are reserved for BIOS
 * use and cannot be passed to _MPEAlloc
 */

/* special flags for MPE's being allocated */
#define MPE_ALLOC_USER 0x1000000  /* allocated by user */
#define MPE_ALLOC_BIOS 0x2000000  /* allocated by BIOS (e.g. for CDI) */
#define MPE_ALLOC_ANY (MPE_ALLOC_USER|MPE_ALLOC_BIOS)

/* flags used by _MemLoadCoff */
#define LOADFLAGS_RUN       0x01
#define LOADFLAGS_SAVE_MPE  0x10
#define LOADFLAGS_NOMEDIA   0x20

/* function definitions */
extern int _MemLoadCoff(int mpe, void *coffbase, int runflags, void *extra);

extern int _MPEAlloc(long flags);
extern int _MPEAllocSpecific(int n);
extern int _MPEFree(int n);
extern int _MPEsAvailable(int flag);
extern void _MPEStop(int n);
extern void _MPERun(int n, void *startpc);
extern long _MPEWait(int n);
extern void _MPELoad(int mpe, void *mpeaddr, void *sysramaddr, long size);
extern long _MPEReadRegister(int n, void *regaddr);
extern void _MPEWriteRegister(int n, void *regaddr, long value);
extern int _MPERunThread(int mpe, void *initpc, void *arg, long *stacktop);
extern int _MPEAllocThread(void *initpc, void *arg, long *stacktop);
extern long _MPEStatus(int n);

#ifdef __cplusplus
}
#endif

#endif
