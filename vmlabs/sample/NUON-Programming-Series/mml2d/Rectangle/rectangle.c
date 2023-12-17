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
mmlDisplayPixmap	gl_screen;

// Function prototypes
void fill_background(void);
void draw_square(mmlColor clr);
int main(void);


int main(void)
{
	// Initialize the system resources
	mmlPowerUpGraphics( &gl_sysRes );

	// Initialize a graphics context to a default state.
	mmlInitGC( &gl_gc, &gl_sysRes );

	// Initialize a single display pixmap as a framebuffer
	// SCREENWIDTH pixels wide by SCREENHEIGHT lines tall,
	// using PIXEL_TYPE format pixels.
	mmlInitDisplayPixmaps( &gl_screen, &gl_sysRes, SCREENWIDTH, SCREENHEIGHT,
							PIXEL_TYPE, 1, 0L );

	// Setup video to show the pixmap
	mmlSimpleVideoSetup(&gl_screen, &gl_sysRes, eTwoTapVideoFilter);

	// Main Program Event loop!
	while(1)
	{
		fill_background();	// Set all the pixels in the display pixmap
		draw_square(kBlue);	// Draw a blue square in the middle
		_VidSync(1);		// Wait for VBLANK to avoid glitches
	}

	// Release allocated memory
    mmlReleasePixmaps( (mmlPixmap*)&gl_screen, &gl_sysRes, 1 );
	
	exit(0);
	return 0;
}

void fill_background(void)
{
m2dRect scr;

	m2dSetRect( &scr, 0, 0, SCREENWIDTH, SCREENHEIGHT );
	m2dFillColr( &gl_gc, &gl_screen, &scr, kGray );
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
	m2dFillColr( &gl_gc, &gl_screen, &r, clr );
}
