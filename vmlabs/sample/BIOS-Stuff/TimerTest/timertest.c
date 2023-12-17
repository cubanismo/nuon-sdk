/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <string.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/mutil.h>

#define SCREENWIDTH		(192)
#define SCREENHEIGHT	(80)

#define TOP_MARGIN		(10)
#define LEFT_MARGIN		(15)

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

int main( )
{
mmlSysResources sysRes;
mmlGC gc;
mmlFontContext fc;
mmlDisplayPixmap screen;
m2dRect r;
mmlFont fontP;
long seconds, useconds;
char timestr[100];
extern uint8 SysFont[];

	// Initialize the system resources and graphics context to a default state.
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );
	
	// Setup fonts
	mmlInitFontContext( &gc, &sysRes, &fc, 4096 );
	fontP = mmlAddFont( fc, "sysFont", eT2K, SysFont, 20000 );

	// Initialize a single display pixmap as a framebuffer
	mmlInitDisplayPixmaps( &screen, &sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, NULL );
	mmlSimpleVideoSetup(&screen, &sysRes, eFourTapVideoFilter);

	// Initialize the timer
	InitTimer();

	// Set all the pixels in the display pixmap
	m2dFillColr( &gc, &screen, NULL, kBlack );

	// Clear the background of the text area first
	m2dSetRect( &r, LEFT_MARGIN, TOP_MARGIN, SCREENWIDTH, (TOP_MARGIN + 25) );		
	m2dFillColr( &gc, &screen, &r, kBlack );

	mmlSetTextProperties( fc, fontP, 20, kGreen, kGray, eBlend, 0, 0 );
	mmlSimpleDrawText( fc, &screen, "Seconds : Microseconds", 22, &r );

	while(1)
	{
		m2dSetRect( &r, LEFT_MARGIN, (TOP_MARGIN + 40), SCREENWIDTH, (TOP_MARGIN + 65) );
		m2dFillColr( &gc, &screen, &r, kBlack );
        mmlSetTextProperties( fc, fontP, 20, (kBlue + 0x30000000), kGray, eBlend, 0, 0 );

		// Get the current timer value
		GetTimer( &seconds, &useconds );
		sprintf( timestr, "%08ld : %06ld", seconds, useconds );
		
		mmlSimpleDrawText( fc, &screen, timestr, strlen(timestr), &r );
		
		// Wait for VBLANK to reduce flickering
		_VidSync(1);
	}        

	mmlReleasePixmaps( (mmlPixmap*)&screen, &sysRes, 1 );
	return 0;
}
