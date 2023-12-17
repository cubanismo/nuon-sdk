/*
 * Copyright (c) 2000-2001, VM Labs, Inc., All rights reserved.
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
  
*/

#ifndef _SHOWJPEG_H_
#define _SHOWJPEG_H_

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <nuon/dma.h>
#include <nuon/mutil.h>
#include <nuon/msprintf.h>

#include <jpeg/jpeglib.h>

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

#define BIG_PICTURE			(0)

#if BIG_PICTURE
#define SCREENWIDTH			(720)
#define SCREENHEIGHT		(480)
#else
#define SCREENWIDTH			(360)
#define SCREENHEIGHT		(240)
#endif

/***************************************************************************/
/* Define some commonly used colors in 32-bit Y-Cr-Cb-Alpha colorspace *****/
/***************************************************************************/

#define clr_white 			(0xeb808000)	// RGB(255,255,255)
#define clr_black 			(0x10808000)	// RGB(0,0,0)

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

extern mmlGC			gl_gc;
extern mmlSysResources 	gl_sysRes;
extern mmlDisplayPixmap	gl_screen;

extern int				gl_displaybuffer;	// index into gl_screenbuffers[] array
extern int				gl_drawbuffer;
extern mmlDisplayPixmap	gl_screenbuffers[2];

/***************************************************************************/
/***************************************************************************/
/***************************************************************************/

#include "proto.h"

#endif // _SHOWJPEG_H_
