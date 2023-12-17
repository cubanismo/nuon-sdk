/*
 * Hello World - Shows minimum screen setup & text output
 *
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>
#include <nuon/bios.h>
#include <nuon/mml2d.h>

////////////////////////////////////////////////////////////////////////////

#define SCREENWIDTH			(360)
#define SCREENHEIGHT 		(240)
#define BACKGROUNDCOLOR 	(0x60808000)  /* darkish grey */

mmlGC						gl_gc;
mmlSysResources 			gl_sysRes;
mmlDisplayPixmap			gl_screen;

////////////////////////////////////////////////////////////////////////////

int main(void)
{
char buf[SPRINTF_MAX];
long x, y;

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );	

	// Create the display buffer
	mmlInitDisplayPixmaps( &gl_screen, &gl_sysRes, SCREENWIDTH, SCREENHEIGHT, e888Alpha, 1, 0 );

	// Clear the display buffer
    for (x = 0; x < gl_screen.wide; x += 8)
	{
		for (y = 0; y < gl_screen.high; y += 8)
		{
			_DMABiLinear(gl_screen.dmaFlags|DMA_DIRECT_BIT, gl_screen.memP, (8<<16)|x, (8<<16)|y, (void *)BACKGROUNDCOLOR);
		}
    }

	// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screen, &gl_sysRes, eTwoTapVideoFilter);
	
	msprintf(buf, "Hello World" );
	DebugWS(gl_screen.dmaFlags, gl_screen.memP, 30, 30, kYellow, buf);

	while(1);
    return 0;
}

