/*
 * Copyright (c) 2000-2001, VM Labs, Inc., All rights reserved.
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
  
*/

#include <stdio.h>
#include <stdlib.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>
#include <nuon/mediaio.h> 
#include <nuon/bios.h>
#include <nuon/dma.h>

///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define NUMBLOCKS	(20)

char *gl_databuffer;
volatile int gl_finished = 0;
volatile int gl_numcallbacks = 0;
volatile int gl_lastblock = -1;
volatile int blocks[NUMBLOCKS];

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define SCREENWIDTH				(720)
#define SCREENHEIGHT			(480)

#define clr_white 				(0xeb808000)	// RGB(255,255,255)
#define clr_black 				(0x10808000)	// RGB(0,0,0)

///////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;
int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void clearscreen(mmlDisplayPixmap *scrn);
void swap_screenbuffers(void);
void init_screenbuffers(void);
void print_message(int scr, char *msg);

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void clearscreen(mmlDisplayPixmap *scrn)
{
long x, y, h;

	for (y = 0; y <= scrn->high; y += 8)
	{
		h = ((scrn->high - y) >= 8) ? 8 : (scrn->high - y); 
		
		for (x = 0; x < scrn->wide; x += 8)
		{
			_DMABiLinear(scrn->dmaFlags|DMA_DIRECT_BIT, scrn->memP, (8<<16)|x, (h<<16)|y, (void *)clr_black);
		}
    }
}

////////////////////////////////////////////////////////////////////////////
// Swap draw and display buffers.  Takes effect next VBLANK
////////////////////////////////////////////////////////////////////////////

void swap_screenbuffers(void)
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

void init_screenbuffers(void)
{
	// Initialize index values for gl_screenbuffers[] array
	gl_displaybuffer = 0;
	gl_drawbuffer = 1;

	// Create & clear each buffer

	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_displaybuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	mmlInitDisplayPixmaps( &gl_screenbuffers[gl_drawbuffer], &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	
	clearscreen(&gl_screenbuffers[gl_drawbuffer]);
	clearscreen(&gl_screenbuffers[gl_displaybuffer]);

	// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

void print_message(int scr, char *msg)
{
mmlDisplayPixmap *scrn = &gl_screenbuffers[gl_drawbuffer];
static int ds_ypos = 40;

	switch( scr )
	{
		// Just increment Y-POS
		case -1:
			ds_ypos += (int)msg;
			break;

		case 0:
			scrn = &gl_screenbuffers[gl_drawbuffer];
			break;

		case 1:
			scrn = &gl_screenbuffers[gl_displaybuffer];
			break;
	}

	switch( scr )
	{
		case 0:			
		case 1:
			if( ds_ypos > 430 )
			{
				{
				int x, y;
				long scratchsize;
				
					// Get address of internal memory scratch buffer to use for image buffer
					long *imgbuf = _MemLocalScratch((void *)&scratchsize);
				
					for( y = 15; y < scrn->high; y += 2 )
					{
						for( x = 0; x < scrn->wide; x += 16 )
						{
							// Read segment we're gonna move up a line
							_DMABiLinear(	scrn->dmaFlags|(1<<13), scrn->memP, 
											(x)|(16<<16), (y)|(2<<16),
											(void *)imgbuf );
				
							// write it back to new location
							_DMABiLinear(	scrn->dmaFlags, scrn->memP, 
											(x)|(16<<16), (y-15)|(2<<16),
											(void *)imgbuf );
						}
					}
				
					// Now clear bottom of screen
					for (y = (scrn->high-15); y < scrn->high; y++ )
					{
						for (x = 0; x < scrn->wide; x += 8)
						{
							_DMABiLinear(scrn->dmaFlags|DMA_DIRECT_BIT, scrn->memP, (8<<16)|x, (1<<16)|y, (void *)clr_black);
						}
					}
				}
				ds_ypos -= 15;
			}
			
			DebugWS( scrn->dmaFlags, scrn->memP, 40, ds_ypos, kWhite, msg );
			ds_ypos += 15;
			break;
	}
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

long readcallback(int status, long blocknum )
{	
	blocks[gl_numcallbacks++] = gl_lastblock = blocknum;
	
	gl_finished = 1;

	return (long)gl_databuffer;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int main(void)
{
int mediahandle, blocksize, status, i;
int lastblock, lastnumcallbacks;
char *databuffer;
char msgbuf[100];

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	print_message( 1, "Inside test program..." );
	swap_screenbuffers();
	
	print_message( -1, (void *)15 );
	print_message( 1, "Opening NUON.DAT on MEDIA_DVD" );
	print_message( -1, (void *)15 );

	mediahandle = _MediaOpen(MEDIA_DVD, "nuon.dat", 0, &blocksize );
	sprintf( msgbuf, "mediahandle = 0x%08x, blocksize = %d\n", mediahandle, blocksize );
	print_message( 1, msgbuf );   

	if( mediahandle == 0 )
	{
		print_message( 1, "_MediaOpen failed!" );   
		while(1);
	}

	databuffer = (char *)malloc( blocksize + 32 );
	gl_databuffer = (char *)(((long)databuffer + 15) & 0xFFFFFFF0 );
	
	sprintf( msgbuf, "Data buffer location = 0x%08lx (0x%08lx)", (long)databuffer, (long)gl_databuffer );
	print_message( 1, msgbuf );   
	
	sprintf( msgbuf, "Calling _MediaRead() to read %d blocks of data from offset 0", NUMBLOCKS );
	print_message( 1, msgbuf );   
	
	gl_finished = 0;
	gl_lastblock = lastblock = -1;
	lastnumcallbacks = 0;
	status = _MediaRead( mediahandle, MCB_END, 0, NUMBLOCKS, gl_databuffer, (MediaCB)&readcallback );

	// Print results of read operation   
	sprintf( msgbuf, "_MediaRead status = %d (0x%08x)", status, status );
	print_message( 1, msgbuf );   
	
	print_message( 1, "Blocks received:" );   

	while( ! gl_finished )
	{
		if( gl_lastblock != lastblock || lastnumcallbacks != gl_numcallbacks )
		{
			sprintf( msgbuf, "%8d (%d)\t", gl_lastblock, gl_numcallbacks );
			print_message( 1, msgbuf );   

			lastblock = gl_lastblock;
			lastnumcallbacks = gl_numcallbacks;
		}
		else
		{
			sprintf( msgbuf, "Nothing received yet... gl_numcallbacks = %d", gl_numcallbacks );
			print_message( 1, msgbuf );   
		}		
		
		// Wait awhile so we don't print up the wazoo.
		_VidSync(3);
	}

	print_message( -1, (void *)15 );
	
	print_message( 1, "Read operation completed" );   
	
	sprintf( msgbuf, "Number of callbacks received = %d", gl_numcallbacks );
	print_message( 1, msgbuf );   
	
	for( i = 0; i < gl_numcallbacks; i++ )
	{
		if( blocks[i] != i )
		{
			sprintf( msgbuf, "Callback %d got block %d", i, blocks[i] );
			print_message( 1, msgbuf );   
		}
	}

	print_message( 1, "Finished!" );   

	while(1);
	return 0;
}
