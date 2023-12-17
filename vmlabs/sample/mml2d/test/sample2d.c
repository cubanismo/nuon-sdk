/* Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission 
 */


/*
 * Simplest sample code to demonstrate MML2d library
 * No Text
 */

#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <nuon/mml2d.h>

void PlotPixel( mmlGC* gcP, mmlDisplayPixmap* screenP, int x, int y, mmlColor color );

#define PIXEL_TYPE e888Alpha
//#define PIXEL_TYPE e655Z
//#define PIXEL_TYPE e655

int main( )
{
    	mmlSysResources sysRes;
    	mmlGC gc;
	mmlAppPixmap source, clutSource;
    	mmlDisplayPixmap screen;
    	int srcWide, srcHigh;
    	uint16* srcP;
    	mmlColor yCC[512];
    	mmlColor* dtP;
    	mmlColor gray;

/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );

/* Initialize a single display pixmap as a framebuffer
   720 pixels wide by 480 lines tall, using 32 bit YCC-alpha pixels. */
    	mmlInitDisplayPixmaps( &screen, &sysRes, 720, 480, PIXEL_TYPE, 1, NULL );

/* Allocate memory for a 16-bit rgb source pixmap and initialize
	the pixmap. */
	srcWide = 160;
	srcHigh = 120;
	srcP = (uint16*)malloc( 2 * srcWide * srcHigh );
	mmlInitAppPixmaps( &source, &sysRes, srcWide, srcHigh, eRGBAlpha1555, 1, srcP);

/* show the sample pixmap */
	mmlSimpleVideoSetup(&screen, &sysRes, eNoVideoFilter);

/* Set all the pixels in the display pixmap to gray */
	gray = mmlColorFromRGB( 128, 128, 128 );
	m2dFillColr( &gc, &screen, NULL, gray );
	
/* Set all the pixels in the source pixmap to yellow */
/* NOTE: fully saturated yellow is bad for the VDG in 16bpp mode */
{
        uint16 veryYellow = 0x1c<<10 | 0x1c<<5;
	uint16* p = srcP;	
	int i,j;
	
	for( i=0; i<source.high; ++i )
		for( j=0; j<source.wide; ++j )
			*p++ = veryYellow;
}
/* Draw a black diamond 101 high by 101 wide in the source pixmap */
{
	uint16 black = 0;
	int row, topRow, middleRow, bottomRow, center, mapWidth, offset;
	uint16 *p;
	
	mapWidth = 160;
	topRow = 11;
	middleRow = 61;
	bottomRow = 111;
	center = 80;
	p = (uint16*)source.memP + topRow * mapWidth;
	offset = 0;
	for( row = topRow; row<=middleRow; ++row )
	{
		*(p + center - offset) = black;
		*(p + center + offset) = black;
		++offset;
		p += mapWidth;
	}
	offset = 0;
	p = (uint16*)source.memP + bottomRow * mapWidth;
	for( row = bottomRow; row>middleRow; --row )
	{
		*(p + center - offset) = black;
		*(p + center + offset) = black;
		++offset;
		p -= mapWidth;
	}
}
/* Copy a 120 by 120 rectangle containing the diamond from the source
to the display pixmap, converting color space. Locate the copied rectangle
at the location (80, 40 ) from the top left corner of the display pixmap.
*/
{
	m2dRect r;
	m2dPoint pt;
	r.leftTop.x = 20;
	r.leftTop.y = 0;
	r.rightBot.x = 139;
	r.rightBot.y = 119;
	pt.x = 80;
	pt.y = 40;
	m2dCopyRect(&gc, &source, &screen, &r, pt );
}

/* Do the same copy, but also correct for aspect ratio, so the diamond
is squared up in the display pixmap. Locate it at (320, 40 ).
Also, use setters instead of direct assignment.
*/
{
	m2dRect r;
	m2dSetRect( &r, 20, 0, 139, 119 );
	gc.fixAspect = eTrue;
	m2dCopyRect(&gc, &source, &screen, &r, m2dSetPoint( 320, 40) );
}

/* Do a non-destructive copy of the yellow patch within the framebuffer
 */
{
	m2dRect s;
	m2dSetRect( &s, 80, 40, 199, 159 );
	m2dCopyRectDis( &gc, &screen, &screen, &s, m2dSetPoint( 120, 110 ));
}

/* Create a 256 entry YCrCb Clut for use in 8 bit mode */
{
//#define cMax 1.0
#define cMax (14.9/16.0) //completely saturated colors don't work well

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

	dtP = &yCC[256];
		dtP = (mmlColor*) (((int)dtP) & ~0x3FF);  // align table to 1024 byte boundary 

	for( i=0; i<8; ++i)
	{
		for(j = 0; j<32; ++j )
		{
			rc = ((32.0-j)/32.0)*rgbColors[i].rC;
			gc = ((32.0-j)/32.0)*rgbColors[i].gC;
			bc = ((32.0-j)/32.0)*rgbColors[i].bC;
				dtP[(32*i)+j] = mmlColorFromRGBf( rc, gc, bc );
			}
		}
	}

	/* Create a color ramp rectangle using 8 bit clut */
	{
	uint8 *sP, *pixels;
	int row, col, i, j;
	srcWide = 160;
	srcHigh = 120;
	
/* Allocate memory for an 8-bit clut source pixmap and initialize the pixmap. */
	sP = (uint8*)malloc( srcWide * srcHigh );

		mmlInitAppPixmaps( &clutSource, &sysRes, srcWide, srcHigh, eClut8, 1, (void *)sP);
	mmlSetPixmapClut( (mmlPixmap*)&clutSource, dtP );
	
		// Create a bitmap that shows all of the colors from the CLUT
		pixels = sP;

		for(row = 0; row < srcHigh; ++row )
		{
			i = (row * 8) / srcHigh;

			for(col = 0; col < srcWide; ++col )
			{
				j = (col * 32) / srcWide;

				// Figure out the desired CLUT index and set the pixel.
				*pixels++ = (32 * i) + j;
			}
		}
	
		/* Copy rectangle to screen. Because source is indexed color and
		destination screen is true-color, use m2dScaledCopy function.  Slow
		but correct.  
		*/
	
		/* we can fix the aspect ratio.  We could also apply arbitrary
		horizontal or vertical scaling.
		*/	
		gc.fixAspect = eTrue;
		 
	{
	m2dRect src, dest;
	
			m2dSetRect( &src, 0, 0, srcWide-1, srcHigh-1 );
			m2dSetRect( &dest, 80, 240, 80+srcWide-1, 240+srcHigh-1);
			m2dScaledCopy( &gc, &clutSource, &screen, &src, &dest, 1,1,1,1);
		}
		
		// Some Debugging code.
		// Draw a similar rectangle using the colors from
		// the CLUT to make sure that the CLUT is OK.
		pixels = sP;
		for( row = 0; row < 8; ++row )
		{
			for( col = 0; col < 32; ++col )
			{
			m2dRect r;
			int sourcepix, source_x, source_y;

				// This tests the CLUT for corruption by drawing each
				// color value that is stored in the CLUT.
                
				sourcepix = (32 * row) + col;
                m2dSetRect( &r, 290+(col*5), 340+(row*10), 295+(col*5), 350+(row*10) );
				m2dFillColr( &gc, &screen, &r, dtP[sourcepix] );

				// This tests the bitmap for corruption by reading the
				// color index values from the bitmap, and then looking up
				// the appropriate CLUT entry... this requires an uncorrupted
				// CLUT to work.

				source_x = ((srcWide * col) / 32) + 2;
				source_y = ((srcHigh * row) / 8) + 4;
				sourcepix = pixels[ (source_y * srcWide) + source_x ];
                m2dSetRect( &r, 480+(col*5), 355+(row*10), 485+(col*5), 365+(row*10) );
				m2dFillColr( &gc, &screen, &r, dtP[sourcepix] );
			}
		}


}	

/* Draw an animated circle */
{
	int interval = 100000;
		int radius = 80;
	int rSquared = radius*radius;
		m2dPoint center = { 410, 250 };
	int x, y;
	double z;

	while( --interval > 0 )
	{
		int tim = 10000;
		int k = tim;
		for( x = radius; x >= -radius; --x )
		{
			z = rSquared - x*x;
			z = sqrt( z );			
			y = (8.0 * z / 9.0) + 0.5;
			while( --k > 0 ); /* slow down a little */
			k = tim;
			PlotPixel( &gc, &screen, center.x+x, center.y-y, kGreen );
			PlotPixel( &gc, &screen, center.x-x, center.y+y, kBlue );
		}
		for( x = -radius; x <= radius; ++x )
		{
			z = rSquared - x*x;
			z = sqrt( z );			
			y = (8.0 * z / 9.0) + 0.5;
			while( --k > 0 );
			k = tim;
			PlotPixel( &gc, &screen, center.x+x, center.y+y, kGreen );
			PlotPixel( &gc, &screen, center.x-x, center.y-y, kBlue );
		}
	}		
}
/* Release allocated memory */
mmlReleasePixmaps( (mmlPixmap*)&screen, &sysRes, 1 );
mmlReleasePixmaps( (mmlPixmap*)&source, &sysRes, 1 );
mmlReleasePixmaps( (mmlPixmap*)&clutSource, &sysRes, 1 );

return 0;
}
/*
 * Plot a single pixel in a display frame buffer
 */
void PlotPixel( mmlGC* gcP, mmlDisplayPixmap* screenP, int x, int y, mmlColor color )
{
	m2dRect r;
	r.leftTop.x = x;
	r.leftTop.y = y;
	r.rightBot.x = x;
	r.rightBot.y = y;
	m2dFillColr( gcP, screenP, &r, color );
}
