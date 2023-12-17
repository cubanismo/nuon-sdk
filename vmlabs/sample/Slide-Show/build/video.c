/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

// deal with video and graphics

#include "video.h"


static mmlGC               gl_gc;
static mmlSysResources     gl_sysRes;

static int                 gl_displaybuffer;   // index into gl_screenbuffers[] array
static int                 gl_drawbuffer;
static mmlDisplayPixmap    gl_screenbuffers[2];

void InitVideo(void)
{
    // Make sure gl_sysRes stuff is setup
    mmlPowerUpGraphics( &gl_sysRes );

    // Now make sure gl_gc stuff is setup
    mmlInitGC( &gl_gc, &gl_sysRes );

    // initialize double display buffers
    init_screenbuffers();
}

void SwitchToNewImage(int i)
{
    extern volatile int AutoPlay;
    
    if (i >= 0 && i < NumImages) {
        show_jpeg(&gl_screenbuffers[gl_drawbuffer], ImageArr[i], ImageSize[i]);
        if (AutoPlay)
            swap_screenbuffers();
    }
}

void PaintOverWithNewImage(int i)
{
    if (i >= 0 && i < NumImages) {
        show_jpeg(&gl_screenbuffers[gl_displaybuffer], ImageArr[i], ImageSize[i]);
    }
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
    mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
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
    mmlSimpleVideoSetup(&gl_screenbuffers[gl_displaybuffer], &gl_sysRes, eTwoTapVideoFilter);
}

////////////////////////////////////////////////////////////////////////////
// Clear the screen... Divide into 8x8 segments
////////////////////////////////////////////////////////////////////////////

void clearscreen(mmlDisplayPixmap *scrn)
{
    long x, y;

    for (x = 0; x < scrn->wide; x += 8)
    {
        for (y = 0; y < scrn->high; y += 8)
        {
            _raw_plotpixel(scrn->dmaFlags, scrn->memP, (8<<16)|x, (8<<16)|y, clr_black);
        }
    }
}

        