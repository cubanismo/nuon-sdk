/*
 * Copyright (C) 2000-2001 VM Labs, Inc.
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
 * DMA to/from an MPE
 */

#include <nuon/mutil.h>
#include <nuon/dma.h>

/* write data to another MPE from external memory */
void _mpedma(long dmaflags, void *extaddr, void *intern, int mpe)
{
    // convert internal address to a system address
    intern = (mpe<<23) + (char *)intern;

    // set the REMOTE bit on the transfer
    dmaflags |= (1<<28);

    _DMALinear(dmaflags, extaddr, intern);
}

/* read/write another MPE's register */
long
_mpedmaregister(long dmaflags, void *externaddr, long data, int mpe)
{
    void *localmem;

    localmem = _MemLocalScratch(0);
    _SetLocalVar(localmem, data);
    externaddr = (mpe<<23) + (char *)externaddr;

    _DMALinear(dmaflags, externaddr, localmem);
    return _GetLocalVar(localmem);
}

/* read/write other bus memory, 32 bits only */
long
_obusdmascalar(long dmaflags, void *externaddr, long data)
{
    return _mpedmaregister(dmaflags, externaddr, data, 0);
}

