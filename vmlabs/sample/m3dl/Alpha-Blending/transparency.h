/*
Copyright (C) 2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this
 file in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/*
 * Header BACKGROUND DEMO
 */

#include <m3dl/m3dl.h>

#define RGBMODE				(0)			//0 YCrCb, 1 RGB
#define HIRES					(1)			//0 LoRes, 1 HiRes
#define NUMBUFFERS		(3)			//2 Double, 3 Triple Buffering
#define M3DL_STARTMPE	(1)			//M3DL Start Render MPE
#define M3DL_NUMMPE		(2)			//M3DL Number of Rendering MPEs
#define BACKGROUND		(1)			//0 No Background, 1 Background
#define VERBOSEOUTPUT	(1)			//Dump Information 0 No, 1 Yes
#define DISPLAYFRAMES	(1)			//Display Framerate

#if	(HIRES == 1)
	#define SCR_WIDTH		(360*2)
	#define SCR_HEIGHT	(240*2)
#else
	#define SCR_WIDTH		(360)
	#define SCR_HEIGHT	(240)
#endif

#define MAXBALLS			(200)		//Maximum #of balls (array definition)
#define BALLCOLORS		(4)			//4 Colored balls
#define BALLSACTIVE		(100) 		//#of active balls
#define BALLSPACING		(3<<4)					//Ball spacing
#define BALLANGLE			((40<<16)/360)		//Every 40 degrees

typedef struct _BALLNFO {
	md16DOT16		angle;					//Angle (polar coordinates)
	md28DOT4		distance;				//Distance (in screen coordinates)
} BALLNFO;

