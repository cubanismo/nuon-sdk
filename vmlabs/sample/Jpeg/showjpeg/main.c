/*
 * Copyright (c) 2000-2001, VM Labs, Inc., All rights reserved.
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
  
   Written by Mike Fulton, VM Labs, Inc.
 
 */

#include "showjpeg.h"

/**************************************************************************/

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;

int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

long				*bg_screen_graphic;

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

#if SCREENWIDTH == 720
#define IMAGEDATA bg720_screen_jpeg
#define IMAGESIZE sz_bg720_screen_jpeg
#else
#define IMAGEDATA bg360_screen_jpeg
#define IMAGESIZE sz_bg360_screen_jpeg
#endif

extern long IMAGEDATA[], IMAGESIZE[];


void decompress_pictures(void)
{
	// Show message while we work!
	DebugWS( gl_screenbuffers[gl_displaybuffer].dmaFlags, gl_screenbuffers[gl_displaybuffer].memP, 
			 ((SCREENWIDTH/2)-((16*9)/2)), (SCREENHEIGHT/2), kWhite, 
			 "Decompressing..." );
	
	// Decompress title screen graphic for use throughout the program
	bg_screen_graphic = (long *)malloc(SCREENWIDTH*SCREENHEIGHT*4);
	if( ! bg_screen_graphic )
		return;
    
	decompress_jpeg( IMAGEDATA, (int)IMAGESIZE, bg_screen_graphic );
}


/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

void show_info(mmlDisplayPixmap *scrn)
{
char msg[200];

	sprintf( msg, "JPEG IMAGE SIZE = %d bytes", (int)IMAGESIZE );
	DebugWS( scrn->dmaFlags, scrn->memP, 40, 40, kWhite, msg );

	sprintf( msg, "SCREENWIDTH = %d", SCREENWIDTH );
	DebugWS( scrn->dmaFlags, scrn->memP, 40, 60, kWhite, msg );

	sprintf( msg, "SCREENHEIGHT = %d", SCREENHEIGHT );
	DebugWS( scrn->dmaFlags, scrn->memP, 40, 80, kWhite, msg );
}


int main(void)
{
	// Make sure gl_sysRes stuff is setup
	mmlPowerUpGraphics( &gl_sysRes );

	// Now make sure gl_gc stuff is setup
	mmlInitGC( &gl_gc, &gl_sysRes );

	// initialize double display buffers
	init_screenbuffers();

#if 1
	// Decompress pictures stored in JPEG format
	decompress_pictures();

    // Loop forever!
	while(1)
	{
		draw_picture( bg_screen_graphic,0,0,SCREENWIDTH,SCREENHEIGHT,SCREENWIDTH,SCREENHEIGHT );
		show_info( &gl_screenbuffers[gl_drawbuffer] );
		swap_screenbuffers();

		_VidSync(0);
	}
#else		
	show_jpeg( &gl_screenbuffers[gl_displaybuffer], IMAGEDATA, (int)IMAGESIZE );
	show_info( &gl_screenbuffers[gl_displaybuffer] );
    
	// Loop forever!
	while(1);
#endif

	// Release allocated memory
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[0], &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[1], &gl_sysRes, 1 );

	// and exit!   
	return 0;
}

