/* Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

/* Speed2d.c
Create overall mixture of 2d functions,
to compare using an r31 stack vs an sp stack
vs an sp stack in dtram.
rwb 9/3/99
*/

#include "aux2d.h"
#include "auxvid.h"
#include <nuon/mml2d.h>
#include <nuon/bios.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>

#define DEFAULT_BORDER_COLOR kBlack

int main( )
{
	mmlSysResources sysRes;
	mmlGC gc;
	mmlDisplayPixmap osd;
	VidDisplay display;
	VidChannel osdch;
	
	mmlAppPixmap source;
 	mmlColor ycc[512];
 	mmlColor* dtP;
 	int nDo, n, index;
 	int ncopyRect8;
 	clock_t tBeg, tEnd;
 	m2dRect r;
 	float fobjpsec;
 	mmlPixFormat destType, srcType;
 	
	destType = eClut8;
 	nDo = 5;
 	ncopyRect8 = 1;
	
/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );

/* Initialize a single display pixmap as a framebuffer to be used as osd channel
   720 pixels wide by 480 lines tall, using 16 bit YCC-alpha pixels. */
	mmlInitDisplayPixmaps( &osd, &sysRes, 720, 480, destType, 1, 0 );
/* Initialize the display configuration */
    memset(&display, 0, sizeof(display));
    display.dispwidth = -1;
    display.dispheight = -1;
    display.bordcolor = DEFAULT_BORDER_COLOR;
    display.progressive = 0;

/* Initialize the osd channel from the osd display pixmap */
	mmlConfigOSD( &osdch, &osd, 0, 0, 1 );

/* Configure the VDG channels and activate them */
    _VidConfig(&display, NULL, &osdch, (void *)0);
    
/* Create a 256 entry YCrCb Clut for use in 8 bit mode */
{
#define cMax 1.0
	int i,j;
	double rc, gc, bc;
	typedef struct rgb rgb;
	struct rgb
	{
		double rC;
		double gC;
		double bC;
	};
	rgb	rgbColors[8] = {{cMax,cMax,cMax},{cMax,0,0},{cMax, cMax, 0}, {0,cMax,0},
		{0, cMax, cMax},{0,0,cMax}, {cMax, 0, cMax},  {cMax/2.0, cMax, cMax/4.0} };
	dtP = &ycc[256];
	dtP = (mmlColor*) (((int)dtP) & ~0x3FF);  // align table 

	for( i=0; i<8; ++i)
	{
		for(j = 0; j<32; ++j )
		{
			rc = ((32.0-j)/32.0)*rgbColors[i].rC;
			gc = ((32.0-j)/32.0)*rgbColors[i].gC;
			bc = ((32.0-j)/32.0)*rgbColors[i].bC;
/*
			rc = ((32.0-0)/32.0)*rgbColors[i].rC;
			gc = ((32.0-0)/32.0)*rgbColors[i].gC;
			bc = ((32.0-0)/32.0)*rgbColors[i].bC;
*/
			dtP[32*i+j] = mmlColorFromRGBf( rc, gc, bc );
//		dtP[32*i+j] = kRed;
		}
	}
}
	_VidSetCLUTRange(0, 256, dtP );
 	index = 0;
	m2dFillClut( &gc, &osd, NULL, (index<<24)|(index<<16)|(index<<8)|index ); 
  
/* A Bunch of Timings */
{
	/* unscaled copy eClut8 */
	int srcWide = 160;
	int srcHigh = 120;
	int wide, high, top;
	uint8* srcP = (uint8*)malloc( srcWide * srcHigh );
	int i, row, col,k, index1;
	srcType = eClut8;
	mmlInitAppPixmaps( &source, &sysRes, srcWide, srcHigh, srcType, 1, srcP);
	mmlSetPixmapClut( (mmlPixmap*)&source, dtP );

/* Create color ramp */
	for(row = 0; row<srcHigh; ++row )
	{
		int val;
		uint8* ptr;
		i = row/15;
		for(col=0; col<srcWide; ++col )
		{
			val = 32*i + col/5;
			ptr = srcP + srcWide*row + col;
			*ptr = val;
		}
	}
	wide = 81;
	high = 99; //119;
	top = 60; //80;		

	m2dSetRect( &r, 0, 0, srcWide-1, srcHigh-1 );
	m2dCopyClutRect(&gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint( 50, 40) );

	tBeg = clock();

	
	for( n=0; n<ncopyRect8; ++n )
	{
		m2dSetRect( &r, 0, top, wide-1, high-1 );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  321, 40)  );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  440, 40 ) );
		m2dSetRect( &r, 0, top, wide, high );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  323, 90 ) );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  442, 90 ) );
		m2dSetRect( &r, 1, top, wide-1, high-1 );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  321, 140 ) );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  440, 140 ) );
		m2dSetRect( &r, 1, top, wide, high );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  323, 190)  );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  442, 190 ) );
		m2dSetRect( &r, 2, top, wide-1, high-1 );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  321, 240)  );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  440, 240 ) );
		m2dSetRect( &r, 2, top, wide, high );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  323, 290)  );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  442, 290 ) );
		m2dSetRect( &r, 3, top, wide-1, high-1 );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  321, 340)  );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  440, 340 ) );
		m2dSetRect( &r, 3, top, wide, high );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  323, 390)  );
		m2dCopyClutRect( &gc, (mmlPixmap*)&source, &osd, &r, m2dSetPoint(  442, 390 ) );
	}
/*
	for( n=0; n<ncopyRect8; ++n )
	{
		int left = 300;
		int top = 40;
		int right = 401;
		index1 = 40;
		index = (index1<<24) | (index1<<16) | (index1<<8) | index1;
		m2dSetRect( &r, left, top, right, top + 40 );
		m2dFillClut( &gc, &osd, &r, index );

		for( k=1; k<8; ++k )
		{
			top += 50;
			m2dSetRect( &r, left+k, top, right, top + 40 );
			m2dFillClut( &gc, &osd, &r, index );
		}
		top = 40;
		left = 420;
		right = 521;
		m2dSetRect( &r, left, top, right, top + 40 );
		m2dFillClut( &gc, &osd, &r, index );
		for( k=1; k<8; ++k )
		{
			top += 50;
			m2dSetRect( &r, left, top, right+k, top + 40 );
			m2dFillClut( &gc, &osd, &r, index );
		}

	}
*/
	tEnd = clock( );

	mmlReleasePixmaps( (mmlPixmap*)&source, &sysRes, 1 );

	fobjpsec = tEnd > tBeg ? (float)(16*ncopyRect8*CLOCKS_PER_SEC)/( tEnd - tBeg) : -99;
	printf( "\n 2d copyRect8 %dx%d - dst=%d - speed %10.3f",100, 40, destType, fobjpsec );
	printf( "\n Clocks per second = %d", CLOCKS_PER_SEC );
	fflush( stdout );
}
while(1);
return 0;		
}		 
