/*
   Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
*/
/* 
 * Package of convenience library functions
 * to manage VDG
 * rwb 8/12/99
 */
#include "auxvid.h"

/* Fill in VidChannel struct for MAIN channel
 * Position pixmap framebuffer at horOffset and vertOffset
 * Always set both vert filter to none.
*/
#define MAX_SCREEN_HEIGHT 480
#define MAX_SCREEN_WIDTH 720
void mmlConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int horFilter, int hScale )
{
	memset(vP, 0, sizeof(vP));

	vP->src_xoff = 0;
	vP->src_yoff = 0;
	vP->src_width = MIN( sP->wide, MAX_SCREEN_WIDTH - horOffset );
	vP->src_height = MIN( sP->high, MAX_SCREEN_HEIGHT - vertOffset );
//	vP->vfilter = VID_VFILTER_2TAP;
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
void mmlConfigMain( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset )
{
	mmlConfigChan( vP, sP, horOffset, vertOffset, VID_VFILTER_4TAP, 1 );
}
