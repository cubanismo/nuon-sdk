/*
 * Copyright (C) 1997-2001 VM Labs, Inc.
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
 * memory routines for SDRAM
 *
 */
#ifndef MMLMEM_H
#define MMLMEM_H

#ifdef __cplusplus
extern "C" {
#endif

void SDRAMInit(void *startaddr, unsigned long size);
void *SDRAMAlloc(unsigned long size);
void SDRAMFree(void *);

#ifdef __cplusplus
}
#endif

#endif
