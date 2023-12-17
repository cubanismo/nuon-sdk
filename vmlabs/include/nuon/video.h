/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

 All rights reserved.
*/


/*
 * BIOS video routines
 *
*/

/* $Id: video.h,v 1.19 2001/10/24 02:50:49 lreeber Exp $ */

#ifndef _VIDEO_H
#define _VIDEO_H

#ifdef __cplusplus
extern "C" {
#endif

/*
 * structure for overall display configuration
 */
typedef struct bios_viddisplay {
    int dispwidth;       /* width of display (-1 for default) */
    int dispheight;      /* height of display (-1 for default) */
    int bordcolor;       /* border color (24bpp) */
    int progressive;     /* flag for interlace (0) or progressive (1) */
    int fps;             /* fields per second (16.16 fixed point) */
    short pixel_aspect_x;   /* pixel aspect ratio (read only) */
    short pixel_aspect_y;
    short screen_aspect_x;  /* screen aspect ratio (read only) */
    short screen_aspect_y;
    int reserved[3];     /* reserved for future expansion; set to 0 */
    /* WARNING: reserved[3] may have to remain reserved forever:
       the Extiva2 BIOS does not set it (it sets only the first 36 bytes
       of the structure */
} VidDisplay;

/* structure for configuring a specific channel */
typedef struct bios_vidchannel {
    long dmaflags;       /* DMA flags for writing to or reading from a channel */
    void *base;          /* base address for the channel */
    int  dest_xoff;      /* x offset for screen image (integer; -1 == center automatically) */
    int  dest_yoff;      /* y offset for screen image (integer; -1 == center automatically) */
    int  dest_width;     /* width of the output on screen  (integer) */
    int  dest_height;    /* height of the output on screen (integer) */
    int  src_xoff;       /* x offset within source data (16.16 fixed point) */
    int  src_yoff;       /* y offset within source data (16.16 fixed point) */
    int  src_width;      /* width of source material (16.16 fixed point) */
    int  src_height;     /* height of source material (16.16 fixed point */
    unsigned char clut_select;    /* (for 4bpp only): which 16 CLUT entries to use */
    unsigned char alpha;          /* (for 16bpp only): default ALPHA to use on channel */
    unsigned char vfilter;        /* vertical filter to apply */
    unsigned char hfilter;        /* horizontal filter to apply */
    int reserved[5];     /* reserved for future expansion */
} VidChannel;

#define VID_HFILTER_NONE 0
#define VID_HFILTER_4TAP 4

#define VID_VFILTER_NONE 0
#define VID_VFILTER_2TAP 2
#define VID_VFILTER_4TAP 4

#define VID_CHANNEL_MAIN 0
#define VID_CHANNEL_OSD  1

/* Video mode defines */

#define VIDEO_WIDTH			(720)
#define VIDEO_HEIGHT_NTSC	(480)
#define VIDEO_HEIGHT_PAL	(576)

#define VIDEO_MODE_NTSC		(1)
#define VIDEO_MODE_PAL		(2)

/* BIOS Function prototypes */

extern int _VidConfig(VidDisplay *, VidChannel *main, VidChannel *osd, void *reserved);
extern int _VidChangeScroll(int which, int xoff, int yoff);
extern int _VidChangeBase(int which, long dmaflags, void *base);
extern int _VidQueryConfig(VidDisplay *);
extern long _VidSync(int n);
extern int _VidSetCLUTRange(int start, int num, unsigned long colors[]);
extern void _VidSetup(void *base, long dmaflags, int width, int height, int filter);
extern void _VidSetOutputType(int);

/* set video output to optimize for composite or svideo */
enum {
    kVidOutputDefault = 0,    /* use NVRAM setting */
    kVidOutputComposite = 1,  /* optimize for composite */
    kVidOutputSvideo = 2      /* optimize for Svideo */
};

#ifdef __cplusplus
}
#endif

#endif
