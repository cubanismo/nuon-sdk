
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <stdlib.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>

#include "controller.h"
#include "proto.h"

////////////////////////////////////////////////////////////////////////////
// Draw the background image.
// This function is hardwired for 32-bit pixels...
////////////////////////////////////////////////////////////////////////////

#define DMA_SEGMENT_LENGTH	(32)	// Presumes that 1 pixel = 1 longword

void draw_picture(long *picture,int xoff, int yoff, int imgwid, int imght, int wclip, int hclip )
{
long *theScanline, scratchsize;
int xx, yy;
int segment_width;
int readflags;

	// Get address of internal memory scratch buffer to use for image buffer
	long *imgbuf = _MemLocalScratch((void *)&scratchsize);
	
	theScanline = picture;

	for( yy = 0; yy < hclip; yy++ )
	{
		for( xx = 0; xx < wclip; xx += DMA_SEGMENT_LENGTH )
		{
			segment_width = imgwid - xx;
			if( segment_width > DMA_SEGMENT_LENGTH )
				segment_width = DMA_SEGMENT_LENGTH;

			readflags = (1<<13) | (segment_width << 16);	// flags = READ, # longs

			// Read section
			_DMALinear( readflags, &theScanline[xx], (void *)imgbuf );
	
			// Write section
			_DMABiLinear(	gl_screenbuffers[gl_drawbuffer].dmaFlags,
							(void *)gl_screenbuffers[gl_drawbuffer].memP, 
							(xx+xoff)|(segment_width<<16), (yy+yoff)|(1<<16),
							(void *)imgbuf );
		}

		theScanline += imgwid;
	}
}

////////////////////////////////////////////////////////////////////////////
// Clear the screen... Divide into 8x8 segments
////////////////////////////////////////////////////////////////////////////

void clearscreen(mmlDisplayPixmap *scrn)
{
long x, y;

    for (x = 0; x < scrn->wide; x += 8)
	{
		for (y = 0; y < scrn->high; y += 8)
		{
			_raw_plotpixel(scrn->dmaFlags, scrn->memP, (8<<16)|x, (8<<16)|y, clr_black);
		}
    }
}

