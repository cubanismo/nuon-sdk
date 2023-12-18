/* Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */
/* 
 * Package of convenience library functions using MML2d functions
 * rwb 12/29/98
 */
#include "aux2d.h"
#include <nuon/mml2d.h>
#include <stdlib.h>
#include <string.h>
#include <nuon/comm.h>

/* do an ellipse highlight of a word in a rendered string.
   get the coordinates 
*/
void ellipseHigh(mmlGC* gcP, mmlDisplayPixmap* sP,
	m2dEllipseStyle* esP, textCode t[], int kth,
	m2dRect* rendP  )
{
	m2dEllipseStyle el;
	m2dRect r = *rendP;
	int first, last, xc, yc, rad;
	
	el = *esP;
	kthWord( t, kth, &first, &last );
	mmlGetTextBox( gcP->fontContextP, t, first, last, &r );
	el.xScale = ((r.rightBot.x - r.leftTop.x)<<8)/(r.rightBot.y - r.leftTop.y );
	rad = (r.rightBot.y - r.leftTop.y)/2;
	xc = (r.rightBot.x + r.leftTop.x)/2;
	yc = (r.rightBot.y + r.leftTop.y)/2;
	m2dDrawStyledEllipse( gcP, sP, &el, xc, yc, rad );
}	

/* return the positions of the first and last letters of
 the word in a string that contains the index or the next
 word if the index is on a word break.
 	If the index points at a final word break, set both
 first and last to index.
*/

void wordBoundaries( textCode* t, int index, int* first, int* last )
{
	int endText = strlen( t );
	while( CharKindQ( t[index], eAscii ) == eWhiteSpace &&
		index < endText ) ++index;
	if( index == endText )
	{
		*first = *last = index;
		return;
	}
	while( CharKindQ( t[index], eAscii ) != eWhiteSpace &&
		index >= 0 ) --index;
	*first = ++index;
	while( CharKindQ( t[index], eAscii ) != eWhiteSpace &&
		index < endText ) ++index;
	*last = index;
}

/* Return the positions of first and last characters of
kth word in string.  If there are not k words, set first
and last to last position (terminator) in string.
*/

void kthWord( textCode* t, int k, int* kFirst, int* kLast )
{
	int first;
	int endText = strlen( t );
	int last = -1;
	int j;
	for( j=0; j<=k; ++j )
	{
		if( last < endText )
			wordBoundaries( t, last+1, &first, &last );
		if( first == endText )
		{
			*kLast = endText;
			*kFirst = endText;
			return;
		}
	}
	*kFirst = first;
	*kLast = last;
}			

/* Draw a box on the edges of a rect using a specified style
*/

void drawBox(mmlGC* gcP, mmlDisplayPixmap* sP,
	 m2dRect* rP, m2dLineStyle* styleP )
{
	m2dDrawStyled2Dline( gcP, sP, styleP, rP->leftTop.x,
		rP->leftTop.y, rP->rightBot.x, rP->leftTop.y);
	m2dDrawStyled2Dline( gcP, sP, styleP, rP->leftTop.x,
		rP->leftTop.y, rP->leftTop.x, rP->rightBot.y);
	m2dDrawStyled2Dline( gcP, sP, styleP, rP->leftTop.x,
		rP->rightBot.y, rP->rightBot.x, rP->rightBot.y);
	m2dDrawStyled2Dline( gcP, sP, styleP, rP->rightBot.x,
		rP->leftTop.y, rP->rightBot.x, rP->rightBot.y);
}

/* Draw a string of characters in a rect positioned at top, left
   of rect.  Clip to bottom, right, but only draw as much as string.
*/

void drawString( mmlFontContext fc, mmlDisplayPixmap* sP,
		textCode t[], m2dRect* rP )
{
	int len = strlen( (char*) t );
	mmlSimpleDrawText( fc, sP, t, len, rP );
}

/*  Some CLUT stuff */
/* Create a palette of 125 colors, each with 2 levels of
transparency. Leave 0 for transparent, and 5 others for text.
*/
void makePalette1( mmlColor ycc[256] )
{
	int ix, i, j, k;
	double r, g, b;
	
	ycc[0] = 0xFF;	/* completely transparent pixel */
	ycc[5] = kBlack | 0x00;
	ycc[4] = kBlack | 0x30;
	ycc[3] = kBlack | 0x60;
	ycc[2] = kBlack | 0x90;
	ycc[1] = kBlack | 0xC0;
	ix = 5;
	for( i=0; i<=4; ++i )
	{
		r = 0.25 * i;
		for( j=0; j<=4; ++j )
		{
			g = 0.25*j;
			for(k=0; k<=4; ++k )
			{
				mmlColor val;
				b = 0.25*k;
				val = mmlColorFromRGBf( r, g, b );
				ycc[++ix] = val;		/* opaque */
				ycc[++ix] = val | 0x80; /* half transparent */
			}
		}
	}
}

void makePalette2( mmlColor ycc[256] )
{
#define ALPHA_INCR 16

	int    i,j;
    unsigned char alpha[16];

    ycc[0] = 0xFF;     // transparent
    
    for(i=0; i<16; i++)  // different alpha levels
        alpha[i] = ALPHA_INCR*(i+1)-1;

    ycc[1] = mmlColorFromRGB( 60, 60, 60 );
    ycc[17] = mmlColorFromRGB( 200, 200, 200 );

    ycc[33] = mmlColorFromRGB( 255, 0, 0 );
    ycc[49] = mmlColorFromRGB( 255, 255, 0 );
    ycc[65] = mmlColorFromRGB( 0, 0, 255 );
    ycc[81] = mmlColorFromRGB( 0, 255, 0 );
    ycc[97] = mmlColorFromRGB( 255, 0, 255 );
    ycc[113] = mmlColorFromRGB( 0, 255, 255 );

    ycc[129] = mmlColorFromRGB( 128, 0, 0 );
    ycc[145] = mmlColorFromRGB( 0, 128, 0 );
    ycc[161] = mmlColorFromRGB( 0, 0, 128 );
    ycc[177] = mmlColorFromRGB( 128, 128, 0 );
    ycc[193] = mmlColorFromRGB( 128, 0, 128 );
    ycc[209] = mmlColorFromRGB( 0, 128, 128 );

    ycc[225] = mmlColorFromRGB( 0, 64, 0 );

    for(i=1; i<=225; i+=16)
        for(j=0; j<16; j++)
            ycc[i+j] = ycc[i] | alpha[j];
//            ycc[i+j] = ycc[i];

#undef ALPHA_INCR
}
			
/* Set VDG Clut values between indexFirst and indexLast inclusiver.
 * rwb 1/7/99
 * ycc[0] is the value to be placed in CLUT[ indexFirst ]
*/		
void mmlSetClut( mmlColor ycc[], int indexFirst, int indexLast )
{
#define kWrite 0x80000000
#define kClutRegister 0x200
#define kVDGComAddress 0x41
	int j,k=0;
	long pack[4];
	pack[2] = 0;
	pack[3] = 0;
	for( j = indexFirst; j<indexLast; ++j )
	{
		pack[0] = kWrite | kClutRegister | j;
		pack[1] = ycc[k++];
		_CommSend( kVDGComAddress,  pack );
	}
#undef kWrite
#undef kClutRegister
#undef kVDGComAddress	
}

/* Return the mmlColor = alpha*fore + (1.0-alpha)*back
*/
mmlColor blendColors( mmlColor fore, mmlColor back, double alpha )
{
	int f,b, kVal, shift;
	double  beta = 1.0 - alpha;
	mmlColor val = 0;
	for( shift = 24; shift>8; shift-=8 )
	{
		f = (fore & 0xFF) >> shift;
		b = (back & 0xFF) >> shift;
		kVal = alpha*f + beta*b + 0.5;
		val |= kVal;
		val <<= 8;
	}
	return val;
}
	
void delay( int tim )
{
/* don't use clock function until timer bug is fixed 
	clock_t start = clock( );
	while( clock( ) - start < tim ); */
	int t;
	while( tim-- )
	{
		t = 2<<12;
		while( t-- );
	}
}

/* Fill in VidChannel struct for MAIN channel
 * Position pixmap framebuffer at horOffset and vertOffset
 * Always set both vert filter to none.
*/
#define MAX_SCREEN_HEIGHT 480
#define MAX_SCREEN_WIDTH 720
void mmlConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int vFilter )
{
	memset(vP, 0, sizeof(vP));
	vP->dmaflags = sP->dmaFlags;
	vP->base = sP->memP;
	vP->dest_xoff = horOffset;
	vP->dest_yoff = vertOffset;
	vP->dest_width = sP->wide;
	vP->dest_height = sP->high;

	vP->src_xoff = 0;
	vP->src_yoff = 0;
	vP->src_width = MIN( sP->wide, MAX_SCREEN_WIDTH - horOffset );
	vP->src_height = MIN( sP->high, MAX_SCREEN_HEIGHT - vertOffset );
	vP->vfilter = vFilter;
	vP->hfilter = VID_HFILTER_NONE;
	vP->alpha = 0;
}

/* Fill in VidChannel struct for OSD channel
*/
void mmlConfigOSD( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset )
{
	mmlConfigChan( vP, sP, horOffset, vertOffset, VID_VFILTER_NONE );
}

/* Fill in VidChannel struct for main channel
*/
void mmlConfigMain( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset )
{
	mmlConfigChan( vP, sP, horOffset, vertOffset, VID_VFILTER_2TAP );
}
