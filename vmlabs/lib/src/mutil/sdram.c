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
 * routines for allocating memory from SDRAM
 *
 */

#include <stdlib.h>
#include <nuon/bios.h>
#include "sdram.h"

/*
 * This function is now obsolete; the BIOS
 * initializes SDRAM memory allocation for us.
 * Hence the new implementation does nothing...
 */

void
SDRAMInit(void *sdram_addr, unsigned long sdram_size)
{
}

/*
 * allocate some memory from SDRAM
 * this memory should be aligned on a 512 byte boundary.
 */

void *
SDRAMAlloc(unsigned long size)
{
    return _MemAlloc(size, 512, kMemSDRAM);
}

/*
 * free a region previously returned
 * by SDRAMAlloc
 */

void
SDRAMFree(void *ptr)
{
    _MemFree(ptr);
}
