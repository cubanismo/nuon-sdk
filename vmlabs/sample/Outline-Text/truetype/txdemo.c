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

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <string.h>
#include <nuon/mml2d.h>

/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

extern uint8 CollegeScript_TTF[];
	
/**************************************************************************/
/**************************************************************************/
/**************************************************************************/

int main( )
{
mmlSysResources sysRes;
mmlGC gc;
mmlFontContext fc;
mmlDisplayPixmap screen;
m2dRect r;
mmlFont CollegeScriptP;

/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );
	
/* Setup fonts */
	mmlInitFontContext( &gc, &sysRes, &fc, 4096 );
	CollegeScriptP = mmlAddFont( fc, "CollegeScript", eTrueType, CollegeScript_TTF, 69224 );

/* Initialize a single display pixmap as a framebuffer
   720 pixels wide by 480 lines tall, using 32 bit YCC-alpha pixels. */

	mmlInitDisplayPixmaps( &screen, &sysRes, 720, 480, e888Alpha, 1, NULL );
	mmlSimpleVideoSetup(&screen, &sysRes, eTwoTapVideoFilter);

/* Set all the pixels in the display pixmap */
	m2dFillColr( &gc, &screen, NULL, kBlack );

/* Draw some text */
	m2dSetRect( &r, 85, 20, 720, 480 );
	mmlSetTextProperties( fc, CollegeScriptP, 170, kBlue, kGray, eBlend, 0, 0 );
	mmlSimpleDrawText( fc, &screen, "NUON", 4, &r );
		
	m2dSetRect( &r, 85, 135, 720, 480 );
	mmlSetTextProperties( fc, CollegeScriptP, 130, kRed, kGray, eBlend, 0, 0 );
	mmlSimpleDrawText( fc, &screen, "was", 3, &r );

	m2dSetRect( &r, 85, 230, 720, 480 );
	mmlSetTextProperties( fc, CollegeScriptP, 160, kGreen, kGray, eBlend, 0, 0 );
	mmlSimpleDrawText( fc, &screen, "here!", 5, &r );

	while(1);

	mmlReleasePixmaps( (mmlPixmap*)&screen, &sysRes, 1 );
	return 0;
}
