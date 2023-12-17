/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

/* 
 * Package of convenience library functions
 * to manage VDG
 * rwb 8/12/99
 */

// modified version of auxvid which scales smaller displaypixmaps
// to fit the entire screen
// af 3/10/00

// info now in sg.h
// #include "auxvid2.h"
#include "sg.h"


/* Fill in VidChannel struct for MAIN channel
 * Position pixmap framebuffer at horOffset and vertOffset
 * Always set both vert filter to none.
*/
#define MAX_SCREEN_HEIGHT 480
#define MAX_SCREEN_WIDTH 720
void My_ConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int horFilter, int hScale , int wScale)
{
	memset(vP, 0, sizeof(vP));

	vP->src_xoff = 0;
	vP->src_yoff = 0;
	vP->src_width = MIN( sP->wide, MAX_SCREEN_WIDTH - horOffset );
	vP->src_height = MIN( sP->high, MAX_SCREEN_HEIGHT - vertOffset );
	vP->vfilter = VID_VFILTER_NONE;
	vP->hfilter = horFilter;

	vP->dmaflags = sP->dmaFlags;
	vP->base = sP->memP;
	vP->dest_xoff = horOffset;
	vP->dest_yoff = vertOffset;
	//	vP->dest_width = hScale * vP->src_width;
	vP->dest_width = 720;
	//	vP->dest_height = wScale * sP->high;
	vP->dest_height = 480;

	vP->alpha = 0;
}

/* Fill in VidChannel struct for MAIN channel
 * Position pixmap framebuffer at horOffset and vertOffset
 * Always set both vert filter to none.
 */
void mmlConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int horFilter, int hScale )
{
	memset(vP, 0, sizeof(vP));

	vP->src_xoff = 0;
	vP->src_yoff = 0;
	vP->src_width = MIN( sP->wide, MAX_SCREEN_WIDTH - horOffset );
	vP->src_height = MIN( sP->high, MAX_SCREEN_HEIGHT - vertOffset );
	vP->vfilter = VID_VFILTER_NONE;
	vP->hfilter = horFilter;

	vP->dmaflags = sP->dmaFlags;
	vP->base = sP->memP;
	vP->dest_xoff = horOffset;
	vP->dest_yoff = vertOffset;
	vP->dest_width = hScale * vP->src_width;
	vP->dest_height = sP->high;

	vP->alpha = 0;
}



/* Fill in VidChannel struct for OSD channel
*/
void mmlConfigOSD( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int hScale )
{
	mmlConfigChan( vP, sP, horOffset, vertOffset, VID_VFILTER_NONE, hScale );
}


/* Fill in VidChannel struct for main channel
*/
void My_ConfigMain( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset )
{
	My_ConfigChan( vP, sP, horOffset, vertOffset, VID_VFILTER_4TAP, 2, 2 );
}
