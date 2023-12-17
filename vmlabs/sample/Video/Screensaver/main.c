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

#include <stdlib.h>
#include <stdio.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include "progdefs.h"
#include "proto.h"
#include "screensaver.h"

mmlGC				gl_gc;
mmlSysResources 	gl_sysRes;
mmlDisplayPixmap	gl_screen;

int					gl_displaybuffer;	// index into gl_screenbuffers[] array
int					gl_drawbuffer;
mmlDisplayPixmap	gl_screenbuffers[2];

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

int main(void)
{
int saver_mode;

	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	/* Draw screen & do stuff */
	while(1)
	{
		saver_mode = screensaver( gl_screenbuffers[gl_displaybuffer].dmaFlags,
								  gl_screenbuffers[gl_displaybuffer].memP, 
								  SCREENWIDTH, SCREENHEIGHT, 300 );

		if( saver_mode != SCREENSAVER_OWNS_SCREEN )
		{
			// Draw background image
			draw_picture(background,0,0,IMAGEWIDTH,IMAGEHEIGHT,IMAGEWIDTH,IMAGEHEIGHT);
	
			// Request screen swap at next VBLANK
			swap_screenbuffers();
		}
		
		// Wait for buffer swap to take place before we loop
		_VidSync(0);
	}

	/* Release allocated memory */   
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[0], &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[1], &gl_sysRes, 1 );

	/* and exit! */   
	return 0;
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
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter );
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
	clearscreen(&gl_screenbuffers[gl_displaybuffer]);
	clearscreen(&gl_screenbuffers[gl_drawbuffer]);

	// Point the video hardware at the display buffer
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter );
}


