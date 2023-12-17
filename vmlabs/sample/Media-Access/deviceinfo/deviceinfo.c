/*
 * Test of media access functions
 *
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
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
			if( ds_ypos > 440 )
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

int main(void)
{
int mediahandle, blocksize, devices_available, status;
MediaDevInfo mediainfo;
char msgbuf[100];

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	print_message( 1, "Requesting available devices..." );
	swap_screenbuffers();
	
	devices_available = _MediaGetDevicesAvailable();
	sprintf( msgbuf, "devices_available = 0x%08x", devices_available );
	print_message( 1, msgbuf );
	print_message( -1, (void *)15 );

	if( devices_available & HAVE_BOOT_MEDIA )
	{
		sprintf( msgbuf, "MEDIA_BOOT_DEVICE" );
		print_message( 1, msgbuf );
	}

	if( devices_available & HAVE_DVD_MEDIA )
	{
		sprintf( msgbuf, "MEDIA_DVD" );
		print_message( 1, msgbuf );
	}

	if( devices_available & HAVE_REMOTE_MEDIA )
	{
		sprintf( msgbuf, "MEDIA_REMOTE" );
		print_message( 1, msgbuf );
	}

	if( devices_available & HAVE_FLASH_MEDIA )
	{
		sprintf( msgbuf, "MEDIA_FLASH" );
		print_message( 1, msgbuf );
	}

	print_message( -1, (void *)15 );
	print_message( 1, "Opening NUON.DAT on MEDIA_BOOT_DEVICE" );
	mediahandle = _MediaOpen(MEDIA_BOOT_DEVICE, "nuon.dat", 0, &blocksize );

	sprintf( msgbuf, "mediahandle = 0x%08x, blocksize = %d", mediahandle, blocksize );
	print_message( 1, msgbuf );

	status = _MediaGetInfo( mediahandle, &mediainfo );
	sprintf( msgbuf, "mediainfo.type = %ld", mediainfo.type );
	print_message( 1, msgbuf );
	
	sprintf( msgbuf, "mediainfo.state = %ld", mediainfo.state );
	print_message( 1, msgbuf );
	
	sprintf( msgbuf, "mediainfo.sectorsize = %ld", mediainfo.sectorsize );
	print_message( 1, msgbuf );

	print_message( -1, (void *)15 );
	
	sprintf( msgbuf, "Halting..." );
	print_message( 1, msgbuf );

	while(1);
	return 0;
}

