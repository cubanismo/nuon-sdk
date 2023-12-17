/*
 * cache related defines
 */

/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/

 /* $Id: cache.h,v 1.8 2001/10/24 02:50:48 lreeber Exp $ */

#ifndef _CACHE_H
#define _CACHE_H

#ifdef __cplusplus
extern "C" {
#endif

#define CACHE_WAY(n) (((n)-1)<<8)
#define CACHE_DIRECT CACHE_WAY(1)
#define CACHE_2WAY   CACHE_WAY(2)
#define CACHE_3WAY   CACHE_WAY(3)

#define CACHE_WAYSIZE_1K (0<<4)
#define CACHE_WAYSIZE_2K (1<<4)
#define CACHE_WAYSIZE_4K (2<<4)
#define CACHE_WAYSIZE_8K (3<<4)

#define CACHE_BLOCKSIZE_16 0
#define CACHE_BLOCKSIZE_32 1
#define CACHE_BLOCKSIZE_64 2
#define CACHE_BLOCKSIZE_128 3

void _DCacheFlush(void);
void _DCacheSync(void);
void _DCacheSyncRegion(void *startaddr, void *endaddr);
void _DCacheInvalidateRegion(void *startaddr, void *endaddr);

void _CacheConfig(unsigned int dcachectl, unsigned int icachectl);

#ifdef __cplusplus
}
#endif

#endif
