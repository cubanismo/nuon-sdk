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
 * functions for starting a program on
 * another MPE
 */

#include <stdlib.h>
#include <nuon/bios.h>
#include <nuon/cache.h>
#include <nuon/mpe.h>
#include <nuon/dma.h>
#include "mutil.h"

#define MAX_TRANSFER 256

void
CopyToMPE(int mpe, void *mpeaddr, void *sysmem, long size)
{
    /* make sure data is written through to memory */
    _DCacheSync();

    /* use the BIOS to copy the data to the MPE;
       this will work even if the MPE is running the mini-BIOS
    */
    _MPELoad(mpe, mpeaddr, sysmem, size);
}

/*
 * copy data from an MPE to system memory
 * This should work on any MPE, as long as the MPE is not
 * itself performing other bus transfers.
 */
void
CopyFromMPE(int mpe, void *sysmem, void *mpeaddr, long size)
{
    long toaddr;
    long fromaddr;
    long xfersize;
    long flags;

    /* make sure data is written through to memory */
    _DCacheSync();

    toaddr = (long)sysmem;
    fromaddr = (long)mpeaddr;

    while (size > 0) {
	if (size > MAX_TRANSFER)
	    xfersize = MAX_TRANSFER;
	else
	    xfersize = size;

	flags = ((xfersize/4)<<16);

	_mpedma(flags, (void *)toaddr, (void *)fromaddr, mpe);
	toaddr += xfersize;
	fromaddr += xfersize;
	size -= xfersize;
    }

    /* invalidate the cache (the DMA has made it invalid) */
    _DCacheFlush();
}

void
StartMPE(int mpe, void *codestart, long codesize, void *datastart, long datasize)
{
    StopMPE(mpe);

    /* round code and data sizes up to vector boundaries */
    codesize = (codesize + 15) & ~15;
    datasize = (datasize + 15) & ~15;

    /* copy data to mpe */
    CopyToMPE(mpe, (void *)0x20100000, datastart, datasize);

    /* copy code to mpe */
    CopyToMPE(mpe, (void *)0x20300000, codestart, codesize);

    /* start the MPE at 0x20300000 */
    _MPERun(mpe, (void *)0x20300000);
}
