/*
 * 
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <nuon/bios.h>
#include <nuon/dma.h>
#include "screensaver.h"

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void _screensaver_16bit_clear(int dmaFlags, void *mem, int w, int h)
{
long x, y;

    for (x = 0; x < w; x += 8)
	{
		for (y = 0; y < h; y += 8)
		{
			_DMABiLinear(dmaFlags|DMA_DIRECT_BIT, mem, (8<<16)|x, (8<<16)|y, (void *)((4<<10)|(16<<5)|16) );
		}
    }
}

// Assumes 16-bit pixels...

static void _screensaver_16bit_1( int dmaFlags, void *mem, int w, int h )
{
int x, y;
int readflags, writeflags;
int read_y;
long scratchsize;
long tmpbuffer[64];

	// Get address of internal memory scratch buffer to use for image buffer
	long *imgbuf = _MemLocalScratch((void *)&scratchsize);

	readflags =  (1<<13) | (8 << 16);	// flags = READ, # longs
	writeflags = (8<<16);
	
	for( y = 0; y < h; y++ )
	{
		for( x = 0; x < w; x += 16 )
		{
			// Read original segment at bottom of the screen that we don't want to throw away
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(16<<16), (h-1)|(1<<16),
							(void *)imgbuf );

			// Write it to TEMP buffer
			_DMALinear( writeflags, tmpbuffer, (void *)imgbuf );

			if( y == 0 )
			{
				read_y = h - 1;
			}
			else
			{
				read_y = y - 1;
			}
			
			
			// Read segment we're gonna move down a line
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(16<<16), (read_y)|(1<<16),
							(void *)imgbuf );

			// write it back to new location
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(16<<16), (y)|(1<<16),
							(void *)imgbuf );

			// read segment back from TEMP buffer
			_DMALinear( writeflags, tmpbuffer, (void *)imgbuf );

			// Write it back to new location
			_DMABiLinear(	dmaFlags, mem, 
							(x)|(16<<16), (read_y)|(1<<16),
							(void *)imgbuf );
		}
	}
}

// Assumes 16-bit pixels...

static void _screensaver_16bit_2( int dmaFlags, void *mem, int w, int h )
{
int x, y, yy, pixel;
long scratchsize;

	// Get address of internal memory scratch buffer to use for image buffer
	short *imgbuf = _MemLocalScratch((void *)&scratchsize);

	for( yy = 0; yy < 16; yy++ )
	{	
		for( x = 0; x < w; x += 8 )
		{
			for( y = yy; y < h; y += 16 )
			{
				// Read block of pixels
				_DMABiLinear(	dmaFlags|(1<<13), mem, 
								(x)|(8<<16), (y)|(1<<16),
								(void *)imgbuf );
	
				for( pixel = 0; pixel < 8; pixel++ )
				{
					int luma = (imgbuf[pixel] & 0xf800) >> 10;
					int cr =   (imgbuf[pixel] & 0x07e0) >> 5;
					int cb =   (imgbuf[pixel] & 0x001f);
	
					luma += 1;
					if( luma > 59 )
						luma = 4;
	
					cr += 2;
					if( cr > 29 )
						cr = 2;
	
					cb += 1;
					if( cb > 29 )
						cb = 2;
	
					imgbuf[pixel] = (luma << 10) | (cr << 5) | cb;
				}
	
				// Write it back to new location
				_DMABiLinear(	dmaFlags, mem, 
								(x)|(8<<16), (y)|(1<<16),
								(void *)imgbuf );
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

// Assumes 16-bit pixels...

static void _screensaver_16bitZ_1( int dmaFlags, void *mem, int w, int h )
{
int x, y;
int readflags, writeflags;
int read_y;
long scratchsize;
long tmpbuffer[64];

	// Get address of internal memory scratch buffer to use for image buffer
	long *imgbuf = _MemLocalScratch((void *)&scratchsize);

	readflags =  (1<<13) | (8 << 16);	// flags = READ, # longs
	writeflags = (8<<16);
	
	for( y = 0; y < h; y++ )
	{
		for( x = 0; x < w; x += 16 )
		{
			// Read original segment at bottom of the screen that we don't want to throw away
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(8<<16), (h-1)|(1<<16),
							(void *)imgbuf );

			// Write it to TEMP buffer
			_DMALinear( writeflags, tmpbuffer, (void *)imgbuf );

			if( y == 0 )
			{
				read_y = h - 1;
			}
			else
			{
				read_y = y - 1;
			}
			
			
			// Read segment we're gonna move down a line
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(8<<16), (read_y)|(1<<16),
							(void *)imgbuf );

			// write it back to new location
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(8<<16), (y)|(1<<16),
							(void *)imgbuf );

			// read segment back from TEMP buffer
			_DMALinear( writeflags, tmpbuffer, (void *)imgbuf );

			// Write it back to new location
			_DMABiLinear(	dmaFlags, mem, 
							(x)|(8<<16), (read_y)|(1<<16),
							(void *)imgbuf );
		}
	}
}

// Assumes 16-bit pixels...

static void _screensaver_16bitZ_2( int dmaFlags, void *mem, int w, int h )
{
int x, y, yy, pixel;
long scratchsize;

	// Get address of internal memory scratch buffer to use for image buffer
	short *imgbuf = _MemLocalScratch((void *)&scratchsize);

	for( yy = 0; yy < 16; yy++ )
	{	
		for( x = 0; x < w; x += 8 )
		{
			for( y = yy; y < h; y += 16 )
			{
				// Read block of pixels
				_DMABiLinear(	dmaFlags|(1<<13), mem, 
								(x)|(8<<16), (y)|(1<<16),
								(void *)imgbuf );
	
				// Skip every other 16 bits
				for( pixel = 0; pixel < 16; pixel += 2 )
				{
					int luma = (imgbuf[pixel] & 0xf800) >> 10;
					int cr =   (imgbuf[pixel] & 0x07e0) >> 5;
					int cb =   (imgbuf[pixel] & 0x001f);
	
					luma += 1;
					if( luma > 59 )
						luma = 4;
	
					cr += 2;
					if( cr > 29 )
						cr = 2;
	
					cb += 1;
					if( cb > 29 )
						cb = 2;
	
					imgbuf[pixel] = (luma << 10) | (cr << 5) | cb;
				}
	
				// Write it back to new location
				_DMABiLinear(	dmaFlags, mem, 
								(x)|(8<<16), (y)|(1<<16),
								(void *)imgbuf );
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void _screensaver_32bit_clear(int dmaFlags, void *mem, int w, int h)
{
long x, y;

    for (x = 0; x < w; x += 8)
	{
		for (y = 0; y < h; y += 8)
		{
			_DMABiLinear(dmaFlags|DMA_DIRECT_BIT, mem, (8<<16)|x, (8<<16)|y, (void *)0x10808000 );
		}
    }
}


// Assumes 32-bit pixels...

static void _screensaver_32bit_1( int dmaFlags, void *mem, int w, int h )
{
int x, y;
int readflags, writeflags;
int read_y;
long scratchsize;
long tmpbuffer[64];

	// Get address of internal memory scratch buffer to use for image buffer
	long *imgbuf = _MemLocalScratch((void *)&scratchsize);

	readflags =  (1<<13) | (8 << 16);	// flags = READ, # longs
	writeflags = (8<<16);
	
	for( y = 0; y < h; y++ )
	{
		for( x = 0; x < w; x += 8 )
		{
			// Read original segment at bottom of the screen that we don't want to throw away
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(8<<16), (h-1)|(1<<16),
							(void *)imgbuf );

			// Write it to TEMP buffer
			_DMALinear( writeflags, tmpbuffer, (void *)imgbuf );

			if( y == 0 )
			{
				read_y = h - 1;
			}
			else
			{
				read_y = y - 1;
			}
			
			
			// Read segment we're gonna move down a line
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(8<<16), (read_y)|(1<<16),
							(void *)imgbuf );

			// write it back to new location
			_DMABiLinear(	dmaFlags|(1<<13), mem, 
							(x)|(8<<16), (y)|(1<<16),
							(void *)imgbuf );

			// read segment back from TEMP buffer
			_DMALinear( writeflags, tmpbuffer, (void *)imgbuf );

			// Write it back to new location
			_DMABiLinear(	dmaFlags, mem, 
							(x)|(8<<16), (read_y)|(1<<16),
							(void *)imgbuf );
		}
	}
}

// Assumes 32-bit pixels...

static void _screensaver_32bit_2( int dmaFlags, void *mem, int w, int h )
{
int x, y, yy, pixel;
long scratchsize;

	// Get address of internal memory scratch buffer to use for image buffer
	long *imgbuf = _MemLocalScratch((void *)&scratchsize);

	for( yy = 0; yy < 16; yy++ )
	{	
		for( x = 0; x < w; x += 8 )
		{
			for( y = yy; y < h; y += 16 )
			{
				// Read block of pixels
				_DMABiLinear(	dmaFlags|(1<<13), mem, 
								(x)|(8<<16), (y)|(1<<16),
								(void *)imgbuf );
	
				for( pixel = 0; pixel < 8; pixel++ )
				{
					int luma = (imgbuf[pixel] & 0xff000000) >> 24;
					int cr =   (imgbuf[pixel] & 0x00ff0000) >> 16;
					int cb =   (imgbuf[pixel] & 0x0000ff00) >> 8;
	
					luma += 2;
					if( luma > 240 )
						luma = 16;
	
					cr += 3;
					if( cr > 235 )
						cr = 16;
	
					cb += 1;
					if( cb > 235 )
						cb = 16;
	
					imgbuf[pixel] = (luma << 24) | (cr << 16) | (cb << 8);
				}
	
				// Write it back to new location
				_DMABiLinear(	dmaFlags, mem, 
								(x)|(8<<16), (y)|(1<<16),
								(void *)imgbuf );
			}
		}
	}
}

int screensaver( int dmaFlags, void *mem, int w, int h, int maxidle )
{
static int active = 0;
static int idle_ticks_so_far = 0;

	if( ! active )
	{
		if( Buttons(_Controller[1]) )
		{
			idle_ticks_so_far = 0;
		}
		else
		{
			if( ++idle_ticks_so_far > maxidle )
			{
				// Turn on screen saver if we go too long without input
				active = 1;
			}                     
		}
	}

	else
	{
	int pixelmode = (dmaFlags & 0x000000F0) >> 4;

		if( Buttons(_Controller[1]) )
		{
			active = 0;
			idle_ticks_so_far = 0;

			switch( pixelmode )
			{
				case 2:
					_screensaver_16bit_clear(dmaFlags, mem, w, h );
					break;

				case 4:
					_screensaver_32bit_clear(dmaFlags, mem, w, h );
					break;
				
				case 5:
					_screensaver_16bit_clear(dmaFlags, mem, w, h );
					break;
			}

			// Screen saver is done... request redraw
			return SCREENSAVER_REDRAW;
		}

		else
		{
			switch( pixelmode )
			{
				case 2:
					// Do screen saver thing
					_screensaver_16bit_1(dmaFlags, mem, w, h);
					_screensaver_16bit_2(dmaFlags, mem, w, h);
					
					// Return code indicating that screensaver has control of screen
					return SCREENSAVER_OWNS_SCREEN;

				case 4:
					// Do screen saver thing
					
					if( (w * h) < 200000 )
                        _screensaver_32bit_1(dmaFlags, mem, w, h);

					_screensaver_32bit_2(dmaFlags, mem, w, h);
					
					// Return code indicating that screensaver has control of screen
					return SCREENSAVER_OWNS_SCREEN;
				
				case 5:
					// Do screen saver thing
					_screensaver_16bitZ_1(dmaFlags, mem, w, h);
					_screensaver_16bitZ_2(dmaFlags, mem, w, h);
					
					// Return code indicating that screensaver has control of screen
					return SCREENSAVER_OWNS_SCREEN;

				default:
					// Return code indicating that screensaver has done nothing to screen
					return SCREENSAVER_NOT_ACTIVE;
			}
			
		}

	}

	// Screen saver is not active
	return SCREENSAVER_NOT_ACTIVE;
}

