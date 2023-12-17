/* Copyright (c) 1995-2001, VM Labs, Inc., All rights reserved.
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

#include <stdlib.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>

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
// Clear the screen... Divide into 8x8 segments
////////////////////////////////////////////////////////////////////////////

void clearscreen(mmlDisplayPixmap *scrn)
{
long x, y;

    for (x = 0; x < scrn->wide; x += 8)
	{
		for (y = 0; y < scrn->high; y += 8)
		{
			_DMABiLinear(scrn->dmaFlags, scrn->memP, (8<<16)|x, (8<<16)|y, (void *)clr_black);
		}
    }
}


////////////////////////////////////////////////////////////////////////////
// This is our object draw routine, dedicated to drawing 32-bit sprites
// with a non-zero alpha channel marking transparent areas.
//
// This code tries to group pixels together to reduce the number of DMA
// operations required.
//
// This isn't the most efficient algorithm for NUON.  We've still got
// three idle processors that we're not using.  It would be better to have
// our sprite drawing code downloaded to another processor, then just send
// requests to it.
////////////////////////////////////////////////////////////////////////////

void plot_object( Ball_Position *ball )
{
register int xx, yy, x_run_start, x_run_length, offset, readflags;
register long *scanline_data;
register int x, y, xinfo, yinfo;
long *imgbuf, scratchsize;


	// Get address of internal memory scratch buffer
	// to use for DMA command buffers and image buffer
    imgbuf = _MemLocalScratch((void *)&scratchsize);

	x = ball->x;
	y = ball->y;

	// This code loads a scanline from the sprite,
	// then draws that to the screen as needed.

	scanline_data = imgbuf;							// Get source of sprite data inside MPE RAM
	offset = 0;										// Initial source offset = 0
	readflags = (1<<13) | (16 << 16);				// flags = READ, 16 longs


	// draw sprite scanline by scanline
	for( yy = 0; yy < SPRITE_HEIGHT; yy++ )
	{
		////////////////////////////////////////
		// Read a scanline of the sprite (16 longs)
		////////////////////////////////////////
		
		_DMALinear( readflags, &spritedata[offset], (void *)imgbuf );

		offset += SPRITE_WIDTH;							// Increment source pointer to next scanline
		
		////////////////////////////////////////
		// Write out this scanline of the sprite
		////////////////////////////////////////
		
		////////////////////////////////////////
		// NOTE: We're assuming that the DMA read operation 
		// will have transferred each pixel before it's tested
		// in the loop below.  This will PROBABLY work
		// most of the time, but it could break sometimes.
		////////////////////////////////////////

		yinfo = (y+yy)|(1<<16);					// Destination Y address

		// Initialize pixel-run variables
		x_run_start = -1;
		x_run_length = 0;

		// Step across the scanline and do each pixel
		for( xx = 0; xx < SPRITE_WIDTH; xx++ )
		{
			// If this pixel is non-transparent,
			if( ! (scanline_data[xx] & 0x000000FF) )			// Check alpha channel for transparent portions
			{
				// Then set the pixel-run start position
				if( x_run_length == 0 )
					x_run_start = xx;

				// and increment the pixel-run counter!
				x_run_length++;
			}
			else	// If current pixel is transparent
			{
				// and we just ended a non-transparent pixel-run, then draw it.
				// We know sprite is less than 64 longs wide, so use just 1 DMA command
				if( x_run_length )
				{
					xinfo = (x_run_start + x)|(x_run_length << 16);
					
					_DMABiLinear(	gl_screenbuffers[gl_drawbuffer].dmaFlags,
									(void *)gl_screenbuffers[gl_drawbuffer].memP, 
									xinfo, yinfo,
									(void *)&scanline_data[x_run_start] );
					
					
					x_run_length = 0;
				}
			}

			if( x_run_length >= 32 )
			{
				xinfo = (x_run_start + x)|(x_run_length << 16);

				_DMABiLinear(	gl_screenbuffers[gl_drawbuffer].dmaFlags,
								(void *)gl_screenbuffers[gl_drawbuffer].memP, 
								xinfo, yinfo,
								(void *)&scanline_data[x_run_start] );

				x_run_length = 0;
			}
		}

		// If we ended scanline without doing last DMA, do it now.
		if( x_run_length )
		{
			xinfo = (x_run_start + x)|(x_run_length << 16);

			_DMABiLinear(	gl_screenbuffers[gl_drawbuffer].dmaFlags,
							(void *)gl_screenbuffers[gl_drawbuffer].memP, 
							xinfo, yinfo,
							(void *)&scanline_data[x_run_start] );

		}
	}
}

