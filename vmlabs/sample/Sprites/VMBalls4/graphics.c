/*
 * Copyright (c) 2001, VM Labs, Inc., All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 * Written by Mike Fulton, VM Labs, Inc.
 *
 */

#include "vmballs.h"
#include "proto.h"


////////////////////////////////////////////////////////////////////////////
// Swap draw and display buffers.  Takes effect next VBLANK
////////////////////////////////////////////////////////////////////////////

void swap_screenbuffers()
{
int tmp;

	tmp = gl_displaybuffer;
	gl_displaybuffer = gl_drawbuffer;
	gl_drawbuffer = tmp;
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
// Initialize the draw/display buffers, clear the memory, put one up!
////////////////////////////////////////////////////////////////////////////

void init_screenbuffers()
{
	// Initialize index values for gl_screenbuffers[] array
	gl_displaybuffer = 0;
	gl_drawbuffer = 1;

	// Create each buffer

	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_displaybuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_drawbuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );

	// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
// Draw the background image.
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
// This function copies a 32-bpp sprite image from SYSRAM to SDRAM
////////////////////////////////////////////////////////////////////////////

void copy_sprite_to_sdram( long *spritedata, mmlDisplayPixmap *spritebuf )
{
register int yy, offset, readflags;
long *imgbuf, scratchsize;

	// Get address of internal memory scratch buffer
	// to use for DMA command buffers and image buffer
    imgbuf = _MemLocalScratch((void *)&scratchsize);

	readflags = (1<<13) | (SPRITE_WIDTH << 16);				// flags = READ, SPRITE_WIDTH longs
	offset = 0;

	// copy sprite scanline by scanline
	for( yy = 0; yy < SPRITE_HEIGHT; yy++ )
	{
		// Read from source
		_DMALinear( readflags, &spritedata[offset], (void *)imgbuf );

		// Increment source pointer to next scanline
		offset += SPRITE_WIDTH;
		
		// Write to destination
		_DMABiLinear(	spritebuf->dmaFlags, (void *)spritebuf->memP, 
						(0|(SPRITE_WIDTH<<16)), yy|(1<<16),
						(void *)imgbuf );
	}
}

/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

int Vblanksync(int count)
{
static int vbsync_startfield = 0;

	/* If count is positive, then we'll wait for either the next VBLANK, */
	/* or for the n'th VBLANK since the last one we waited for. */

	if( count >= 0 )
	{
		/* Wait for next field to start, then exit */
		if( count == 0 )
		{
			/* Get field of starting position... */
			vbsync_startfield = _VidSync(-1);
	
			while(_VidSync(-1) == vbsync_startfield );
			return(_VidSync(-1));
		}

		/* Wait for specified number of vblanks since last Vblanksync(-1) or Vblanksync(n>=0) */
		else
		{
			while(_VidSync(-1) < (vbsync_startfield+count) );

			/* Before we leave, get current count */
			vbsync_startfield = _VidSync(-1);

			return(_VidSync(-1));
		}

	}

	/* if count == -1, then return the current field counter value */

	else if( count == -1 )
	{
		/* Return current field */
		return(_VidSync(-1));
	}

	/* If count == -2, then return the number of fields since the last */
	/* time we waited for synchronization */

	else if( count == -2 )
	{
		/* return # fields since last sync */
		return(_VidSync(-1) - vbsync_startfield );
	}
	return(-1);
}


