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

#ifndef _VIDEOSCALE_H_
#define _VIDEOSCALE_H_

/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

#define IMAGEWIDTH				(180)
#define IMAGEHEIGHT				(120)
#define IMAGEXOFFSET			(0)
#define IMAGEYOFFSET			(0)

// screen width must be a valid DMA width

#define SCREENWIDTH				(192)	// 192x128 = Roughly same proportions as 720x480
#define SCREENHEIGHT			(128)   // This keeps pixel shape the same.

#define SCREENWIDTH_CROP    	(180)	// The "CROP" values should be equal or less than  
#define SCREENHEIGHT_CROP		(120)	// the SCREENWIDTH & SCREENHEIGHT values.
#define	SCREENWIDTH_STEPRATE	(4)		// Scaling factor = 1 / (crop height / actual height)

/***************************************************************************/
/* Define some commonly used colors in 32-bit Y-Cr-Cb-Alpha colorspace *****/
/***************************************************************************/

#define clr_white 			(0xeb808000)	// RGB(255,255,255)
#define clr_black 			(0x10808000)	// RGB(0,0,0)

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

#endif
