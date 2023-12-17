/* Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission 
 */

#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <time.h>
#include <nuon/mml2d.h>
#include <nuon/mutil.h>
#include <nuon/bios.h>
#include <stdio.h>


void delay( int tim );

#define CLUSTER 1
#define DMA_PIXEL_WRITE 0xC000
#define OSD_WIDTH 720
#define OSD_HEIGHT 480
/* frame buffer can be either 32 bit 888Alpha or 16 bit 655 */
#define OSD_XFER_TYPE e888Alpha
//#define OSD_XFER_TYPE e655

#define OSD_DMAFLAGS (DMA_PIXEL_WRITE | ((OSD_WIDTH/8)<<16) | (OSD_XFER_TYPE<<4) | (CLUSTER<<11))

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
	m2dArrow arrow;

/* Initialize the system resources and graphics context to a default state. */
	mmlPowerUpGraphics( &sysRes );
	mmlInitGC( &gc, &sysRes );
// goto lines;
/* Initialize a single display pixmap as a framebuffer
   720 pixels wide by 480 lines tall, using 32 bit YCC-alpha pixels. */
    	mmlInitDisplayPixmaps( &screen, &sysRes, OSD_WIDTH, OSD_HEIGHT, OSD_XFER_TYPE, 1, NULL );

/* Set all the pixels in the display pixmap to gray */
	gray = mmlColorFromRGB( 128, 128, 128 );
	m2dFillColr( &gc, &screen, NULL, gray );

/* show the sample pixmap */
	VidSetup( (void*)screen.memP, OSD_DMAFLAGS, OSD_WIDTH, OSD_HEIGHT, 2);
	
/* Fill Test */
{
	int colors[] = {kGray, kGreen, kRed, kWhite, kBlack, kCyan, kMagenta, kBlue };
	int i,j,k,m,n,o,p,a;
	i = j = n = 0;
	k = m = 1;
	a = 2000;
	while( --a > 0  )
	{
		m2dRect r;
		i = (i+11) % 719;
		j = (j+23) % 479;
		if(++k > 357 ) k = 1;
		if(++m > 127 ) m = 1;
		n = (n+1) % 8;
		o =  i + k > 719 ? 719 : i + k;
		p = j + m > 479 ? 479 : j + m;
		m2dSetRect( &r, i, j, o, p );
		
		m2dFillColr( &gc, &screen, &r, colors[n] );
	}
}
	m2dFillColr( &gc, &screen, NULL, gray );

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
	dtP = &yCC[256];
	dtP = (mmlColor*) (((int)dtP) & ~0x3FF);  /* align table */

	for( i=0; i<8; ++i)
	{
		for(j = 0; j<32; ++j )
		{
			rc = ((32.0-j)/32.0)*rgbColors[i].rC;
			gc = ((32.0-j)/32.0)*rgbColors[i].gC;
			bc = ((32.0-j)/32.0)*rgbColors[i].bC;
			dtP[32*i+j] = mmlColorFromRGBf( rc, gc, bc );
		}
	}
}

/* Very simple test of copy from e888Alpha to e888Alpha
   Puts a little color bar at 280,240.  Uses vertical scaling.
 */
{
	mmlAppPixmap s888;
	m2dRect d, r;
	uint32* sP;
	int high, wide, i, j;
	high = 16;
	wide = 32;
	sP = malloc( 4 * high * wide );
	mmlInitAppPixmaps( &s888, &sysRes, wide, high, e888Alpha, 1, sP);
	for( i = 0; i<high; ++i)
	{
		int k = i/2;
		mmlColor c = dtP[ 32*k + 16 ];
		for( j = 0; j<wide; ++j )
			*sP++ = c;
	}
	m2dSetRect( &r, 0, 0, wide-1, high-1 );
	m2dSetRect( &d, 280, 240, 719, 479 );
	m2dScaledCopy(&gc, &s888, &screen, NULL, &d, 1, 1, 4, 1 );
}	
	

/* Scaled Copy Test from 8 bit clut */
/* Creat a color ramp rectangle using 8 bit clut */
{
	uint8*	sP;
	int row, col, i;
	m2dRect r, d;
	srcWide = 160;
	srcHigh = 120;
	
/* Allocate memory for an 8-bit clut source pixmap and initialize the pixmap. */
	sP = (uint8*)malloc( srcWide * srcHigh );
	assert( sP != NULL );
	mmlInitAppPixmaps( &clutSource, &sysRes, srcWide, srcHigh, eClut8, 1, sP);
	mmlSetPixmapClut( (mmlPixmap*)&clutSource, dtP );
	
/* Create color ramp */
	for(row = 0; row<srcHigh; ++row )
	{
		i = 32*(row/15);
		for(col=0; col<srcWide; ++col )
		{
			*(sP + srcWide*row + col ) = i + col/5;	
		}
	}
/* Repeat a bunch of copies */
	{
		int n, high, wide, hd, hn, vd, vn, srow, scol;
		row = 100;
		col = 100;
		n = 500;
		high = 10;
		wide = 10;
		hd = hn = vd = vn = 1;
		srow = scol = 1;
		while( --n > 0 )
		{
			srow = (srow+1) % srcHigh;
			scol = (scol + 1) % srcWide;
			row = (row+1) % 360;
			col = (col+1) % 544;
			high = (high + 1) % srcHigh + 1;
			if( srow + high > srcHigh) high = srcHigh - srow;
			wide = (wide + 1) % srcWide + 1;
			if( scol + wide > srcWide ) wide = srcWide - scol;
			
			hd = (hd + 1) % 9 + 2;
			hn = (hn + 3) % 8 + 2;
			
			vd = (vd + 5) % 9 + 2;
			vn = (vn + 1) % 8 + 2;
	
			if( (hn*wide)/hd < 1 ) continue;
			if( (vn*high)/vd < 1 ) continue;
			
			if( (hn*wide)/hd + col > 704 ) col = 0;
			if( (vn*wide)/vd + row > 479 ) row = 0;
			
			m2dSetRect( &r, scol, srow, scol+wide-1, srow+high-1 );
			m2dSetRect( &d, col, row, 719, 479 );

			m2dScaledCopy(&gc, &clutSource, &screen, &r, &d, hn, hd, vn, vd );
			
		}
	}
	m2dSetRect( &d, 80, 240, 703, 479 );
	m2dScaledCopy(&gc, &clutSource, &screen, NULL, &d, 9, 8, 8, 8 );	
}
/* Allocate memory for a 16-bit rgb source pixmap and initialize
	the pixmap. */
	srcWide = 160;
	srcHigh = 120;
	srcP = (uint16*)malloc( 2 * srcWide * srcHigh );
	assert( srcP != NULL );
	mmlInitAppPixmaps( &source, &sysRes, srcWide, srcHigh, eRGB0555, 1, srcP);

	
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

/* 9/21 Do the same copy, but use ScaledCopy function and put
result at (320, 240 ) */

{
	m2dRect r,d;
	m2dSetRect( &r, 20, 0, 139, 119 );
	m2dSetRect( &d, 320, 240, 719, 479 );
	m2dScaledCopy(&gc, &source, &screen, &r, &d,9,10,4,5);
}


/* Do a non-destructive copy of the yellow patch within the framebuffer
 */
{
	m2dRect s;
	m2dSetRect( &s, 80, 40, 199, 159 );
	m2dCopyRectDis( &gc, &screen, &screen, &s, m2dSetPoint( 120, 110 ));
}

{
	mmlColor opaque, transparent, half;
	int row, col;
	
	transparent = 0xFF;
	opaque = (kBlue & 0xFFFFFF00) | 0x10;
	half = (kBlue & 0xFFFFFF00) | 0x20;
	
	m2dInitArrow( &sysRes, &arrow, 8, 8 );
	for(row=0; row<8; ++row )
		for( col=0; col<8; ++col )
			m2dSetArrowPixel( &gc, &arrow, col, row, transparent );
	
	m2dSetArrowPixel( &gc, &arrow, 0, 3, half );
	m2dSetArrowPixel( &gc, &arrow, 1, 2, half );
	m2dSetArrowPixel( &gc, &arrow, 1, 3, opaque );
	for(row=2; row<8; ++row ) m2dSetArrowPixel( &gc, &arrow, 2, row, opaque );
	m2dSetArrowPixel( &gc, &arrow, 2, 1, half );	
	m2dSetArrowPixel( &gc, &arrow, 3, 0, half );
	m2dSetArrowPixel( &gc, &arrow, 3, 1, opaque );
	m2dSetArrowPixel( &gc, &arrow, 3, 2, opaque );
	m2dSetArrowPixel( &gc, &arrow, 3, 3, half );
	m2dSetArrowPixel( &gc, &arrow, 3, 7, opaque );
	
	m2dSetArrowPixel( &gc, &arrow, 7, 3, half );
	m2dSetArrowPixel( &gc, &arrow, 6, 2, half );
	m2dSetArrowPixel( &gc, &arrow, 6, 3, opaque );
	for(row=2; row<8; ++row ) m2dSetArrowPixel( &gc, &arrow, 5, row, opaque );
	m2dSetArrowPixel( &gc, &arrow, 5, 1, half );	
	m2dSetArrowPixel( &gc, &arrow, 4, 0, half );
	m2dSetArrowPixel( &gc, &arrow, 4, 1, opaque );
	m2dSetArrowPixel( &gc, &arrow, 4, 2, opaque );
	m2dSetArrowPixel( &gc, &arrow, 4, 3, half );
	m2dSetArrowPixel( &gc, &arrow, 4, 7, opaque );
}

/* NOT SUPPORTED in SDK > 0.87 
gc.defaultES.fill = 0;
m2dDrawEllipse( &gc, &screen, 500, 300, 20 );
m2dDrawQuadArc( &gc, &screen, 550, 300, 20, 1 );
*/

/* Draw an animated circle */
{
	int interval = 400;
	int radius = 100;
	int rSquared = radius*radius;
	m2dPoint center = { 260, 180 };
	int x, y, k;
	double z;

	m2dShowArrow( &gc, &arrow, &screen, 360, 220 );	
	while( --interval > 0 )
	{
		int tim = 20;
		for( x = radius; x >= -radius; --x )
		{
			z = rSquared - x*x;
			k = z;
			z = sqrt( z );	
			k = z;
			
			y = (8.0 * z / 9.0) + 0.5;
			delay( tim );
			m2dMoveArrow( &gc, &arrow, &screen, center.x+x, center.y-y );
		}
		for( x = -radius; x <= radius; ++x )
		{
			z = rSquared - x*x;
			z = sqrt( z );	
			y = (8.0 * z / 9.0) + 0.5;
			delay( tim );
			m2dMoveArrow( &gc, &arrow, &screen, center.x+x, center.y+y );
		}

	}		
}
/* NOT SUPPORTED in SDK > 0.87 
//lines:
{
	m2dLineStyle LS1;
	m2dLineStyle LS2;
	m2dLineStyle LS3;
	m2dLineStyle LS4;
	m2dLineStyle LS5;
	m2dInitLineStyle( &gc, &LS1, kGreen, 8, 0x7fff, eLine1);
	m2dInitLineStyle( &gc, &LS2, kRed, 8, 0x7fff, eLine2);
	m2dInitLineStyle( &gc, &LS3, kCyan, 8, 0x7fff, eLine3);
	m2dInitLineStyle( &gc, &LS4, kBlue, 8, 0x7fff, eLine4);
	m2dInitLineStyle( &gc, &LS5, kMagenta, 8, 0x7fff, eLine5);
	m2dFillColr( &gc, &screen, NULL, kGray );
	m2dDrawStyled2Dline( &gc, &screen, &LS1,  50, 50, 500, 300 );
	m2dDrawStyled2Dline( &gc, &screen, &LS2,  150, 50, 500, 300 );
	m2dDrawStyled2Dline( &gc, &screen, &LS3,  250, 50, 500, 300 );
	m2dDrawStyled2Dline( &gc, &screen, &LS4,  350, 50, 500, 300 );
	m2dDrawStyled2Dline( &gc, &screen, &LS5,  450, 50, 500, 300 );
	(gc.defaultLS).lineKind = eLine6;
	(gc.defaultLS).foreColor = kYellow;
	(gc.defaultLS).foreColor2 = kRed;
	(gc.defaultLS).alpha = 0x7fff;
	(gc.defaultLS).thick = 8;
	(gc.defaultLS).colorBlend1 = 0x30;
	(gc.defaultLS).colorBlend2 = 0x30;

	m2dDraw2DLine( &gc, &screen, 550, 50, 500, 300 );			
}
*/
while(1);
return 0;
}

void delay( int tim )
{
	clock_t start = clock( );
	while( clock( ) - start < tim );
}
	
	
