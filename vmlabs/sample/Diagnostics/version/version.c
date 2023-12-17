
/*
 * Copyright (c) 1996-2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

 
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <string.h>

#include <nuon/mml2d.h>

extern uint8 SysFont[];

extern char libbios_version[];
extern char libc_version[];
extern char libmutil_version[];
extern char libmml3d_version[];
extern char libmml2d_version[];
extern char libmltxt_version[];
extern char libnise_version[];
extern char libmgl_version[];

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

int is_whitespace(char *txt);
int wraptext( int x, int y, int width, char *str );

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

mmlSysResources gl_sysRes;
mmlGC 			gl_grafcontext;
mmlFontContext 	gl_fc;
mmlDisplayPixmap screen;
mmlFont 		theFont;
mmlTextStyle 	bw24;
int				txt_size;

int main( )
{
m2dRect r;
int x, y;

/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &gl_sysRes );
	mmlInitGC( &gl_grafcontext, &gl_sysRes );
	
/* Setup fonts */
	mmlInitFontContext( &gl_grafcontext, &gl_sysRes, &gl_fc, 4096 );
	theFont = mmlAddFont( gl_fc, "sysFont", eT2K, SysFont, 50000 );
	
/* Initialize a single display pixmap as a framebuffer
   720 pixels wide by 480 lines tall, using 32 bit YCC-alpha pixels. */
    mmlInitDisplayPixmaps( &screen, &gl_sysRes, 720, 480, e888Alpha, 1, NULL );
	mmlSimpleVideoSetup(&screen, &gl_sysRes, eTwoTapVideoFilter);

/* Set all the pixels in the display pixmap to gray */
	m2dFillColr( &gl_grafcontext, &screen, NULL, kGray );
	
	x = 70;
	y = 30;

/* Draw some text */
	m2dSetRect( &r, x, y, 720, 480 );
	txt_size = 65;
	mmlSetTextProperties( gl_fc, theFont, txt_size, kBlue, kGray, eBlend, 0, 0 ); 
	mmlSimpleDrawText( gl_fc, &screen, "NUON Library Versions", 21, &r );
	y+= txt_size;

/* print version strings */
	txt_size = 23;
	mmlInitTextStyle( &bw24, theFont, txt_size, kBlack, kGray, eOpaque, 0, 0 ); 
	mmlSetTextStyle( gl_fc, &bw24 );

	y += 8 + wraptext( x, y, 640-x, libbios_version );
    y += 8 + wraptext( x, y, 640-x, libc_version );
    y += 8 + wraptext( x, y, 640-x, libmutil_version );
    y += 8 + wraptext( x, y, 640-x, libmml3d_version );
    y += 8 + wraptext( x, y, 640-x, libmgl_version );
    y += 8 + wraptext( x, y, 640-x, libmml2d_version );
    y += 8 + wraptext( x, y, 640-x, libmltxt_version );
	y += 8 + wraptext( x, y, 640-x, libnise_version );

/* wait */
    while(1);

	mmlReleasePixmaps( (mmlPixmap*)&screen, &gl_sysRes, 1 );
	return 0;
}

////////////////////////////////////////////////////////////////////////////
// Utility function for word-wrap routine
////////////////////////////////////////////////////////////////////////////

int is_whitespace(char *txt)
{
	if( *txt == ' ' )			// Space
		return 1;
	
	else if( *txt == 0x09 )		// Tab
		return 1;

	else if( *txt == 0x0d )		// Carriage return
		return 1;

	else if( *txt == 0x0a )		// Linefeed
		return 1;

	return 0;
}

////////////////////////////////////////////////////////////////////////////
// Simple, and possibly less than perfect word-wrap routine
////////////////////////////////////////////////////////////////////////////

int wraptext( int x, int y, int width, char *str )
{
m2dRect textextent;
char *startpos;
char *termpos;
int xpos, ypos, xmax;
char wrap_char;
int finished;
	
	xpos = x;
	ypos = y;
	xmax = x + width;

	startpos = str;
	termpos = startpos;
	finished = 0;

	do
	{
		do
		{
			termpos++;
			wrap_char = *termpos;
			*termpos = 0;

			// Let's see if everything fits.
			m2dSetRect( &textextent, xpos, ypos, xmax, 480 );
			mmlGetTextBox( gl_fc, startpos, 0, strlen(startpos), &textextent );
			
			*termpos = wrap_char;

		}
		while( textextent.rightBot.x < xmax && *termpos );


		if( *termpos )
		{
			do
			{
				termpos--;
				if (is_whitespace( termpos ) )
					break;
			}
			while( termpos >= startpos );         
		}
		else
		{
			finished = 1;
		}

		wrap_char = *termpos;
		*termpos = 0;

		// Let's see if everything fits.
		m2dSetRect( &textextent, xpos, ypos, xmax, 480 );
		mmlGetTextBox( gl_fc, startpos, 0, strlen(startpos), &textextent );
		mmlSimpleDrawText( gl_fc, &screen, startpos, strlen(startpos), &textextent );

		*termpos = wrap_char;
		startpos = ++termpos;

		xpos = x;
		ypos += txt_size;
	}
	while( *termpos && (! finished) );

	// Return height of text.
	return( ypos - y );
}

