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

#include <nuon/mml2d.h>
#include <nuon/dma.h>
#include <nuon/bios.h>

#define SCREENWIDTH		(360)
#define SCREENHEIGHT	(240)
#define	PIXEL_TYPE		(e888Alpha) 	// 32-bit Y-Cr-Cb-Alpha format

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen[2];
int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;

void fill_background(void)
{
m2dRect scr;

	m2dSetRect( &scr, 0, 0, SCREENWIDTH, SCREENHEIGHT );
	m2dFillColr( &gl_gc, &gl_screen[gl_drawbuffer], &scr, kGray );
}


void draw_square(mmlColor clr)
{
m2dRect r;
int x, y, w, h;

	w = SCREENWIDTH / 2;
	h = SCREENHEIGHT / 2;
	x = (w / 2);
	y = (h / 2);

	m2dSetRect( &r, x, y, x+w, y+h );
	m2dFillColr( &gl_gc, &gl_screen[gl_drawbuffer], &r, clr );
}

////////////////////////////////////////////////////////////////////////////
// Swap draw and display buffers. Takes effect next VBLANK
////////////////////////////////////////////////////////////////////////////

void swap_screenbuffers()
{
int tmp;

	tmp = gl_displaybuffer;
	gl_displaybuffer = gl_drawbuffer;
	gl_drawbuffer = tmp;
	mmlSimpleVideoSetup(&gl_screen[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
// Initialize the draw/display buffers
////////////////////////////////////////////////////////////////////////////

void init_screenbuffers()
{
	// Initialize index values for gl_screenbuffers[] array
	gl_displaybuffer = 0;
	gl_drawbuffer = 1;

	// Create buffers
	mmlInitDisplayPixmaps( gl_screen, &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, PIXEL_TYPE, 2, 0L );

	// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screen[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

int main( )
{
	// Initialize the system resources and graphics context to a default state.
	mmlPowerUpGraphics( &gl_sysRes );
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	// Main Program Event loop!
	while(1)
	{
		// Set all the pixels in the display pixmap
		fill_background();

		// Draw a blue square in the middle
		draw_square(kRed);

		swap_screenbuffers();

		_VidSync(0);
	}

	// Release allocated memory
    mmlReleasePixmaps( (mmlPixmap*)&gl_screen, &gl_sysRes, 1 );
	
	return 0;
}
