/*
 * Copyright (C) 1997-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

/*
 * video setup code
 *
 * The BIOS now has a similar routine (_VidSetup) which probably
 * should be used instead! This code is kept around for historical
 * interest.
 */

#include <nuon/video.h>

/* default border color is black */
#define DEFAULT_BORDER_COLOR 0x10808000

/*
 * create a full screen (720x480) image of the supplied frame buffer
 */

void
VidSetup(void *baseaddr, long dmaflags, int dmawidth, int dmaheight, int filtertype)
{
    VidDisplay display;
    VidChannel mainch;

    memset(&display, 0, sizeof(display));
    memset(&mainch, 0, sizeof(mainch));

    display.dispwidth = -1;
    display.dispheight = -1;
    display.bordcolor = DEFAULT_BORDER_COLOR;
    display.progressive = 0;

    mainch.dmaflags = dmaflags;
    mainch.base = baseaddr;
    mainch.dest_xoff = -1;
    mainch.dest_yoff = -1;
    mainch.dest_width = 720;
    mainch.dest_height = 479; // WAS 480; 479 works around a bug in early
                              // BIOSes

    mainch.src_xoff = 0;
    mainch.src_yoff = 0;
    mainch.src_width = dmawidth;
    mainch.src_height = dmaheight;
    mainch.vfilter = filtertype;
    mainch.hfilter = VID_HFILTER_4TAP;

    _VidConfig(&display, &mainch, (VidChannel *)0, (void *)0);
}

