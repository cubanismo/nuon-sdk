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

#ifndef _BIGBALL_H_
#define _BIGBALL_H_

#define SCREENWIDTH			(360)
#define SCREENHEIGHT		(240)

#define MY_DMAFLAGS (((SCREENWIDTH/8)<<16)|DMA_PIXEL_WRITE|DMA_CLUSTER_BIT|(4<<4))

/***************************************************************************/
/* Define some commonly used colors in 32-bit Y-Cr-Cb-Alpha colorspace *****/
/***************************************************************************/

#define clr_white 			(0xeb808000)	// RGB(255,255,255)
#define clr_light_grey		(0xb5808000)	// RGB(192,192,192)
#define clr_medium_grey		(0x7e808000)	// RGB(128,128,128)
#define clr_dark_grey		(0x47808000)	// RGB(64,64,64)
#define clr_black 			(0x10808000)	// RGB(0,0,0)

#define clr_dark_red		(0x31b66e00)	// RGB(128,0,0)
#define clr_red 			(0x51f05b00)	// RGB(255,0,0)
#define clr_light_red		(0x8bc66900)	// RGB(255,96,96)

#define clr_dark_blue		(0x1d78b800)	// RGB(0,0,128)
#define clr_blue 			(0x296ff000)	// RGB(0,0,255)
#define clr_light_blue		(0x7276c600)	// RGB(64,64,255)

#define clr_dark_green		(0x51525c00)	// RGB(0,128,0)
#define clr_green 			(0x91233700)	// RGB(0,255,0)
#define clr_light_green		(0xb3465300)	// RGB(128,255,128)

#define clr_dark_yellow 	(0xa5832b00)	// RGB(196,196,0)
#define clr_yellow 			(0xd2921100)	// RGB(255,255,0)
#define clr_light_yellow 	(0xdf894900)	// RGB(255,255,128)

#define clr_dark_cyan 		(0x5d499300)	// RGB(0,128,128)
#define clr_cyan 			(0xaa11a600)	// RGB(0,255,255)
#define clr_light_cyan 		(0xba2d9c00)	// RGB(64,255,255)

#define clr_dark_magenta	(0x3dafa500)	// RGB(128,0,128)
#define clr_magenta 		(0x6adeca00)	// RGB(255,0,255)
#define clr_light_magenta 	(0x8bc6d800)	// RGB(255,64,255)

#define clr_dark_orange 	(0x72b14900)	// RGB(192,96,0)
#define clr_orange 			(0x92c13600)	// RGB(255,128,0)
#define clr_light_orange	(0xb9a53f00)	// RGB(255,192,64)

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

typedef struct
{
	long	flags;
	long	*ram_address;
	long	*mpe_address;

} OtherBusDMACommand;

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

extern long   				background[];

extern mmlGC				gl_gc;
extern mmlSysResources 		gl_sysRes;
extern mmlDisplayPixmap		gl_screen;

extern int					gl_displaybuffer;	// index into gl_screenbuffers[] array
extern int					gl_drawbuffer;
extern mmlDisplayPixmap		gl_screenbuffers[2];

extern char					msgbuf[400];

#endif
