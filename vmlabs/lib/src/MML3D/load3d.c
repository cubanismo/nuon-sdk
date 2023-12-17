/*
 * Copyright (C) 1995-2001 VM Labs, Inc.
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
 * Build3DPipe
 *
 * build a 4K buffer containing the various
 * pieces of a pipeline. Returns a pointer
 * to the newly allocated buffer.
 * Also fills in the entries in the parameter
 * block that correspond to function entry
 * points.
 *
 * INPUTS:
 * "piece" is a pointer to an array of pipeline
 * pieces. It should contain the following
 * components, in order:
 *   top level pipeline
 *   polygon load function
 *   vertex transform function
 *   clip code calculation function
 *   clipping function
 *   vertex lighting function
 *   perspective function
 *   polygon draw function
 *   pixel generating function
 *   reciprocal function
 *
 * NOTES:
 * the first 32 bits of the returned buffer is
 * the total size (in bytes) of the buffer
 *
 *
 * note also that the code has to remain cache-aligned,
 * and so it must be copied into someplace that
 * starts on a 32 byte boundary. That means that we
 * need to round the allocated memory off to
 * an appropriate size.
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <nuon/mutil.h>
#include "m3d.h"
#include "lib3d.h"

#define SIZE (4*1024)

#if 0
#define CACHELINE (32)
#else
#define CACHELINE (8)
#endif

long last_pipe_size;

long *
Build3DPipe(PipeComponent *piece, m3dParams *param)
{
    int i;
    long *codebuf, *origcodebuf;
    long codeptr;
    long *copy;
    long size;
    int numpiece;

    /* allocate the original piece of memory */
    origcodebuf = (long *)malloc(SIZE+8+CACHELINE);

    /* now round it off so it starts on a cache byte boundary */
    codeptr = 8 + (long)origcodebuf;  /* space for the size & original code ptr */
    codebuf = (long *)((codeptr + (CACHELINE-1)) & (~(CACHELINE-1)));
    --codebuf;

    i = 1;
    size = 0;
    numpiece = -1;  /* first "piece" is the pipeline top level, which doesn't
		       get a function pointer */

    while (piece->start && size <= SIZE) {
	copy = piece->start;
	if (numpiece >= 0 && numpiece < NUM_PIPE_FUNCS) {
            /* set the relative address of the pipeline component */
            /* this is the current offset from the start of the buffer,
               minus one longword (for the storage allocated for
               code size */
            param->pipe_funcs[numpiece] = (void *)((i-1)*sizeof(long));
	}
	numpiece++;

        while ( (copy < piece->end) && (size <= SIZE)) {
            codebuf[i++] = *copy++;
            size += 4;
        }

        /* pad out to a multiple of the cache line length */
        while ( (size <= SIZE) && ( (size & (CACHELINE-1)) != 0 ) ) {
            codebuf[i++] = 0x81008100; /* "nop" instructions */
            size += 4;
        }
	piece++;
    }

    if (size > SIZE) {
	for(;;) {
	    /* overflow of 4K -- abort */
	    __asm__("nop\nnop\nhalt\nnop\nnop\n");
	}
	write(2, "Pipeline too big!\n", 18);
	_exit(0xdead);
    }
    last_pipe_size = codebuf[0] = size;
    codebuf[-1] = (long)origcodebuf;  /* save the original pointer returned by malloc() */
    return codebuf;
}



/*
 * Free3DPipe
 * given a (previously built) pipeline,
 * free it
 */

void
Free3DPipe(long *pipe)
{
    free((long *)pipe[-1]);
}


/*
 * execute a 3D pipeline
 * mpe[] is the array of MPEs on which to run the
 * pipeline. This must not contain the current
 * MPE!
 */

void
Run3DPipe(int mpe[], int nummpes, long *pipe, m3dParams *parms)
{
    void *codestart;
    long codesize;
    void *datastart;
    long datasize;
    int i;
    int curmpe;

    codestart = &pipe[1];
    codesize = pipe[0];
    datastart = parms;
    datasize = sizeof(*parms);

    curmpe = 0;

    parms->total_mpes = nummpes;

    for (i = 0; i < nummpes; i++) {
	parms->cur_mpe = curmpe;
        StartMPE(mpe[i], codestart, codesize, datastart, datasize);
        curmpe++;
    }

    /* wait for the MPEs to finish */
    for (i = 0; i < nummpes; i++) {
        WaitMPE(mpe[i]);
    }
}

