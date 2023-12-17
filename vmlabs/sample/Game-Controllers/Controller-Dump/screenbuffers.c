
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/


#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>

#include "controller.h"
#include "proto.h"

////////////////////////////////////////////////////////////////////////////
// Swap draw and display buffers.  Takes effect next VBLANK
////////////////////////////////////////////////////////////////////////////

void swap_screenbuffers()
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

void init_screenbuffers()
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
	mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

