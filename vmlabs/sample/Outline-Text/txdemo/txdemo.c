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
 * Simplest sample code to demonstrate MML2d text functions
 * rwb 8/17/98
 */
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <string.h>

#include <nuon/mml2d.h>

#include "aux2d.h"

extern uint8 SysFont[];
extern uint8 CollegeScript[];
extern uint8 SansCB[];

static int seconds( )
{
	clock_t now = clock( );
	return (now/(CLOCKS_PER_SEC)) % 60;
}
	
int main( )
{
mmlSysResources sysRes;
mmlGC gc;
mmlFontContext fc;
mmlDisplayPixmap screen;
m2dRect r,q,s;
mmlFont sysP;
mmlFont CollegeScriptP;
mmlTextStyle bw28, wr28, wb60, CollegeScript54;
m2dEllipseStyle transBlue;
int oldSeconds;
textCode t[] = "11:58:00 PM";
int select, change = 1;
int changeCurs = 1;
int ks;

/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );
	
/* Setup fonts */
	mmlInitFontContext( &gc, &sysRes, &fc, 16384); //4096 );

	sysP = mmlAddFont( fc, "sysFont", eT2K, SysFont, 40000 );
	CollegeScriptP = mmlAddFont( fc, "CollegeScript", eT2K, CollegeScript, 64000 );
	
/* Initialize a single display pixmap as a framebuffer
   720 pixels wide by 480 lines tall, using 32 bit YCC-alpha pixels. */
    mmlInitDisplayPixmaps( &screen, &sysRes, 720, 480, e888Alpha, 1, NULL );
	mmlSimpleVideoSetup(&screen, &sysRes, eTwoTapVideoFilter);

/* Set all the pixels in the display pixmap to yellow */
	m2dFillColr( &gc, &screen, NULL, kGray );
	
/* Draw a red line in middle of NUON */
	m2dSetRect( &r, 60, 60, 260, 110 );
	m2dFillColr( &gc, &screen, &r, kRed );
	
/* Draw some text */
	m2dSetRect( &r, 85, 20, 720, 480 );
	mmlSetTextProperties( fc, sysP, 170, kBlue, kGray, eBlend, 0, 0 ); 
	mmlSimpleDrawText( fc, &screen, "NUON", 4, &r );

#if 1
	for( ks = 50; ks <= 120; ks+=5 )
	{
		mmlSetTextProperties( fc, sysP, ks, kGreen, kGray, eOpaque, 0, 0 ); 
		m2dSetRect( &r, 85, 200, 720, 480 );
		mmlSimpleDrawText( fc, &screen, "NUON", 4, &r );
	}
#endif

	mmlSetTextProperties( fc, sysP, 24, kRed, kGray, eOpaque, 0, 0 ); 
	for( ks = 0; ks < 6; ++ks )
	{
        textCode kc[16];
        int j,k;

		k = 0x18 + (16 * ks);
		
		for(j=0; j<16; ++j)
			kc[j] = k+j;

		m2dSetRect( &r, 85, 150+(ks*24), 720, 480 );
		mmlSimpleDrawText( fc, &screen, kc, 16, &r );
	}

	m2dSetRect( &r, 400, 200, 720, 399 );
	mmlInitTextStyle( &wb60, sysP, 50, kWhite, kBlack, eOpaque, 0, 0 ); 
	mmlSetTextStyle( fc, &wb60 );	
	drawString( fc, &screen, t, &r );
/* NOT SUPPORTED in SDK > 0.87 

	{
		m2dLineStyle transGray;
		m2dInitLineStyle( &gc, &transGray, kGreen, 2, 0xe000, eLine3 );

		++r.rightBot.x;
		--r.leftTop.x;
		--r.leftTop.y;
		++r.rightBot.y; 
		drawBox( &gc, &screen, &r, &transGray );
	}
*/	
	// Set up decorative font sentence and elliptical highlight 
	{
		char* s = "Decorative Fonts Anyone ?";
		mmlInitTextStyle(  &CollegeScript54, CollegeScriptP, 54, kYellow, kBlack, eOpaque, 0, 0 );
		mmlSetTextStyle( fc, &CollegeScript54 );
/* NOT SUPPORTED in SDK > 0.87 
		m2dInitEllipseStyle( &gc, &transBlue, 10, kBlue, 0x2C0, 0x100, 0xA0, 1);
*/
		m2dSetRect( &r, 50, 380, 700, 480 );
	
		mmlSimpleDrawText( fc, &screen, s, strlen(s), &r );
	}

	mmlInitTextStyle( &wr28, sysP, 28, kWhite, kRed, eOpaque, kFillRect, 0 ); 
	mmlInitTextStyle( &bw28, sysP, 28, kBlack, kWhite, eOpaque, kFillRect, 0 );

	select = 2;
	oldSeconds = seconds( );
	m2dSetRect( &r, 400, 200, 720, 399 );
	mmlSetTextProperties( fc, sysP, 60, kWhite, kBlack, eOpaque, 0, 0 ); 	
	
	while(1)
	{
		textCode temp[4];
		int newSeconds = seconds( );
		if( newSeconds != oldSeconds )
		{
			int minutes, hours;
			char day;
			oldSeconds = newSeconds;
			sprintf( temp, "%02d", newSeconds );
			t[6] = temp[0];
			t[7] = temp[1];
			if( newSeconds == 0 )
			{
				sscanf( &t[3], "%2d\n", &minutes );
				if(++minutes > 59 )
				{
					minutes = 0;
					sscanf( &t[0], "%2d\n", &hours );
					if( ++hours > 12 ) hours = 1;
					if( hours == 12 )
					{
						sscanf( &t[9], "%c\n", &day );
						if( day == 'A' ) day = 'P';
						else day = 'A';
						sprintf( temp, "%c", day );
						t[9] = temp[0];
					}
					sprintf( temp, "%02d", hours );
					t[0] = temp[0];
					t[1] = temp[1];
				}
				sprintf( temp, "%02d", minutes );
				t[3] = temp[0];
				t[4] = temp[1];
			}
			
			mmlSetTextStyle( fc, &wb60 );	
			mmlGetTextBox( fc, t, 0, 10, &r );
			mmlSimpleDrawText( fc, &screen, t, 11, &r );
			if( rand() % 10 ==  1 ) change = 1;
			else change = 0;
			if( rand()%5 == 1 )
			{
				static int prev = 0;
			 	changeCurs = rand()%5 + 1;
			 	if( changeCurs == prev ) changeCurs = (prev + 1) % 5 + 1;
			 	prev = changeCurs;
			}
			else changeCurs = 0;
			
		}
		
/* NOT SUPPORTED in SDK > 0.87 
		if( changeCurs )
		{
			char* s = " Reverse Play Pause Stop Forward ";
			m2dRect r1;
			m2dSetRect( &r1, 50, 300, 700, 480 );
			mmlSetTextStyle( fc, &wb60 );
			mmlSimpleDrawText( fc, &screen, s, strlen(s), &r1 );
			ellipseHigh( &gc, &screen, &transBlue, s, changeCurs-1, &r1 );
			changeCurs = 0;
		} 
*/	
		if( change ) // redraw the selection box 
		{
			change = 0;
			select = (select + 1) % 4;
			m2dSetRect( &s, 450, 50, 720, 399 );
			q = s;
			if( select == 0 ) 
				mmlSetTextStyle( fc, &wr28 );
			else mmlSetTextStyle( fc, &bw28 );
			mmlGetTextBox( fc, " Language ", 0, 9, &s );
			mmlSimpleDrawText( fc, &screen, " Language", 9, &s );
			s.leftTop.y = s.rightBot.y + 1;
			s.rightBot.y = q.rightBot.y;
			if( select == 1 ) 
				mmlSetTextStyle( fc, &wr28 );
			else mmlSetTextStyle( fc, &bw28 );
			mmlSimpleDrawText( fc, &screen, " Langue", 7, &s );
			s.leftTop.y = s.rightBot.y + 1;
			s.rightBot.y = q.rightBot.y;
			if( select == 2 ) 
				mmlSetTextStyle( fc, &wr28 );
			else mmlSetTextStyle( fc, &bw28 );
			mmlSimpleDrawText( fc, &screen, " Idioma", 7, &s );
			s.leftTop.y = s.rightBot.y + 1;
			s.rightBot.y = q.rightBot.y;
			if( select == 3 ) 
				mmlSetTextStyle( fc, &wr28 );
			else mmlSetTextStyle( fc, &bw28 );
			mmlSimpleDrawText( fc, &screen, " Sprache", 8, &s );
			
			// Now box it 
/* NOT SUPPORTED in SDK > 0.87 
			{
				m2dLineStyle transRed;
				m2dInitLineStyle( &gc, &transRed, kRed,
					 4, 0xd000, eLine3 ); 
				q.rightBot.x = s.rightBot.x;
				q.rightBot.y = s.rightBot.y;
				drawBox( &gc, &screen, &q, &transRed );
			}
*/
		} 
	}
	mmlReleasePixmaps( (mmlPixmap*)&screen, &sysRes, 1 );
	return 0;
}
			
	