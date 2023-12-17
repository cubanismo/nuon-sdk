/*
 *
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 * Written by Mike Fulton, VM Labs, Inc.
*/

#include <stdlib.h>

#include <nuon/mml2d.h>
#include <nuon/bios.h>

#include "showpic.h"
#include "proto.h"

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
	/* Make sure gl_sysRes stuff is setup */
	mmlPowerUpGraphics( &gl_sysRes );

	/* Now make sure gl_gc stuff is setup */
	mmlInitGC( &gl_gc, &gl_sysRes );

	init_screenbuffers();

	/* Draw screen & do stuff */
	while(1)
	{
		// Draw background image
		draw_picture(background);

        // Request screen swap at next VBLANK
		swap_screenbuffers();

		// Wait for buffer swap to take place before we loop
		_VidSync(0);
	}

	/* Release allocated memory */   
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[0], &gl_sysRes, 1 );
	mmlReleasePixmaps( (mmlPixmap*)&gl_screenbuffers[1], &gl_sysRes, 1 );

	/* and exit! */   
	return 0;
}

