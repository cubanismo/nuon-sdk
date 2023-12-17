/*
 * header file for low-level C DMA
 * interface
*/

/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


#ifndef NUON_DMA_H
#define NUON_DMA_H

#ifdef __cplusplus
extern "C" {
#endif

#define DMA_READ_BIT (1<<13)

#define DMA_MPEG_WRITE (2<<14)
#define DMA_MPEG_READ (DMA_MPEG_WRITE|DMA_READ_BIT)

#define DMA_PIXEL_WRITE (3<<14)
#define DMA_PIXEL_READ (DMA_PIXEL_WRITE|DMA_READ_BIT)

#define DMA_CLUSTER_BIT (1<<11)

#define DMA_DIRECT_BIT (1<<27)
#define DMA_REMOTE_BIT (1<<28)

/* BIOS interfaces to the DMA */
void _DMALinear(long dmaflags, void *extaddr, void *internaddr);
void _DMABiLinear(long dmaflags, void *baseaddr, long xinfo, long yinfo, void *externaddr);


/* routine to plot pixels or short lines */
/* this assembly language routine uses bilinear DMA to
 * draw a single pixel or short line of pixels. The
 * parameters are as follows:
 *    dmaflags:  flags for the main bus DMA (see MMA manual)
 *               the read bit must NOT be set; the
 *               transfer must be a pixel mode write
 *               _raw_plotpixel will itself set the
 *               DUPLICATE and/or DIRECT bits, so those
 *               need not be set in the parameter
 *    dmaaddr:   base address of screen; must be in SDRAM
 *    xinfo:     X length (high 16 bits) and position (low 16 bits)
 *    yinfo:     Y length (high 16 bits) and position (low 16 bits)
 *    color:     32 bits; interpretation depends on pixel type
 *               specified in "dmaflags"
 *
 * Note that the X and Y lengths can be any combination which
 * specifies at most 64 long words of data; for example, in
 * a 32bpp mode, it is possible to plot an 8x8 rectangle with
 * a single call to _raw_plotpixel. The X and Y positions
 * specify the upper left corner of the rectangle.
 * _raw_plotpixel does no error checking whatsoever; illegal
 * values will probably crash the machine.
 */

#if 0
extern void
_raw_plotpixel(long dmaflags, void *dmaaddr, long xinfo, long yinfo, long color);
#else

/* slightly quicker way to get to the DMA */
extern inline void
_raw_plotpixel(long dmaflags, void *dmaaddr, long xinfo, long yinfo, long color)
{
    _DMABiLinear((dmaflags|DMA_DIRECT_BIT), dmaaddr, xinfo, yinfo, (void *)color);
}
#endif

#ifdef __cplusplus
}
#endif

#endif /* NUON_DMA_H */
