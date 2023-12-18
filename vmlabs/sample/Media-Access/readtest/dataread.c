/*
 * Test of printf functions and PC file server
 *
 * See MAKEFILE for info on using MLOAD file server option
 *
 * Copyright (c) 1998 VM Labs, Inc.  All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>
#include <nuon/mediaio.h> 
#include <nuon/bios.h>
#include <nuon/dma.h>

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

#define USE_TIMER	(0)

#define SCREENWIDTH				(720)
#define SCREENHEIGHT			(480)

#define clr_white 				(0xeb808000)	// RGB(255,255,255)
#define clr_black 				(0x10808000)	// RGB(0,0,0)

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;
int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

char				*gl_databuffer[20];
volatile int 		gl_finished = 0;

long 				timer_sec[5], timer_usec[5];

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
#if USE_TIMER
	// Get the current timer value
	GetTimer( &timer_sec[blocknum], &timer_usec[blocknum] );
#endif

	gl_finished = blocknum;
	return (long)gl_databuffer;
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int main(void)
{
int mediahandle, blocksize, status, row, chr, i;
int blocking_test;
char *databuffer;
char msgbuf[100];

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	print_message( 1, "Inside test program..." );
	swap_screenbuffers();
	
#if USE_TIMER
	// Initialize the timer
	InitTimer();
#endif
	
#if 1
	print_message( 1, "This program is set up to use MEDIA_BOOT_DEVICE as the device" );
	print_message( 1, "type.  This could be equivalent to either MEDIA_REMOTE or MEDIA_DVD");
	print_message( 1, "depending on how your program was launched.");
	print_message( -1, (void *)15);
	print_message( 1, "For MEDIA_DVD when booting from disc, the filename parameter for " );
	print_message( 1, "_MediaOpen() must point to a valid file located in the disc's NUON" );
	print_message( 1, "directory." );
	print_message( -1, (void *)15);
	print_message( 1, "For MEDIA_REMOTE, the filename parameter doesn't matter, but you must" );
	print_message( 1, "specify the right options to MLOAD to turn on the REMOTE MEDIA SERVER" );
	print_message( 1, "and specify the file on the PC that will be used for data reading." );
	print_message( -1, (void *)15);
	print_message( 1, "When using MEDIA_BOOT_DEVICE, you still have to do whatever would be" );
	print_message( 1, "appropriate for the actual device.");
	print_message( -1, (void *)15);
#endif

	while(1);

	mediahandle = _MediaOpen(MEDIA_DVD, "nuon.dat", 0, &blocksize );
	sprintf( msgbuf, "mediahandle = 0x%08x, blocksize = %d\n", mediahandle, blocksize );
	print_message( 1, msgbuf );

	for( i = 0; i < 20; i++ )
	{
		sprintf( msgbuf, "pass %d\n", i );
		print_message( 1, msgbuf );

		databuffer[i] = (char *)malloc( (blocksize*5) + 32 );
		gl_databuffer[i] = (char *)(((long)databuffer[i] + 15) & 0xFFFFFFF0 );
	
		sprintf( msgbuf, "Data buffer location = 0x%08lx (0x%08lx)\n", (long)databuffer[i], (long)gl_databuffer[i] );
		print_message( 1, msgbuf );
		
		sprintf( msgbuf, "Calling _MediaRead() to read 5 blocks of data from offset 0\n" );
		print_message( 1, msgbuf );
		
		status = _MediaRead( mediahandle, MCB_END, 0, 5, gl_databuffer[i], (MediaCB)&readcallback );
	
		blocking_test = gl_finished;
	
		// If we're using the ethernet link to our host PC, then don't 
		// do printf() calls while media access is still happening.
		while( gl_finished < 4 );
		
		// Print results of read operation   
		sprintf( msgbuf, "_MediaRead status = %d (0x%08x)\n", status, status );
		print_message( 1, msgbuf );

		sprintf( msgbuf, "Blocking flag = %d\n", blocking_test );
		print_message( 1, msgbuf );
	}


#if USE_TIMER
	for( i = 0; i<5; i++ )
	{
		sprintf( msgbuf, "Block %d timecode = %d:%d\n", i, timer_sec[i], timer_usec[i] );      
		print_message( 1, msgbuf );
	}
#endif

	sprintf( msgbuf, "Dumping first 256 bytes of buffer we just read...\n\n" );
	print_message( 1, msgbuf );

    for( row = 0; row < 16; row++ )
	{
		// Print row address
		sprintf( msgbuf, "0x%08x: ", row*16 );

		// Do hex dump
        for( i = 0 ; i < 16; i++ )
        {
		char hexval[10];

			chr = (int)gl_databuffer[(row*16)+i]  & 0xFF;
            sprintf( hexval, "%02x ", chr );
			strcat( msgbuf, hexval );
		}

		// Spacer
        strcat( msgbuf, "     " );

		// Do character dump
		for( i = 0 ; i < 16; i++ )
        {
		char chrstr[10];

			chr = (int)gl_databuffer[(row*16)+i];
			
			// Make sure it's a valid ASCII character 
			if( chr >= 32 && chr <= 127 )
				sprintf( chrstr, "%c", chr );	// yes, print it
			else
				sprintf( chrstr, " " );			// no, print space

			strcat( msgbuf, chrstr );
		}

		// Go to next line
		print_message( 1, msgbuf );
	}

	print_message( -1, (void *)15);
	print_message( 1, "Finished!" );
	
	while(1);
	return 0;
}
