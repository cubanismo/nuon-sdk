/*Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission 
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
#include <time.h>


/* Draw a box on the edges of a rect using a specified style
*/
/* NOT SUPPORTED in SDK > 0.87 

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
*/
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
	int j,k;
	long pack[4];
	pack[2] = 0;
	pack[3] = 0;
	k = 0;
	for( j = indexFirst; j<=indexLast; ++j )
	{
		pack[0] = kWrite | kClutRegister | j;
		pack[1] = ycc[k];
		++k;
		_CommSend( kVDGComAddress,  pack );
	}
#undef kWrite
#undef kClutRegister
#undef kVDGComAddress	
}
/* Read VDG Clut values between indexFirst and indexLast inclusiver.
 * rwb 1/7/99
 * ycc[0] is the value to be placed in CLUT[ indexFirst ]
*/		
void mmlGetClut( mmlColor ycc[], int indexFirst, int indexLast )
{
#define kClutRegister 0x200
#define kVDGComAddress 0x41
	int j,k;
	long pack[4];
	pack[2] = 0;
	pack[3] = 0;
	k = 0;
	for( j = indexFirst; j<=indexLast; ++j )
	{
		pack[0] = kClutRegister | j;
		pack[1] = 0;
		_CommSendRecv( kVDGComAddress,  pack );
		ycc[k] = pack[1];
		++k;
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
	for( shift = 24; shift>0; shift-=8 )
	{
		f = (fore & (0xFF << shift)) >> shift;
		b = (back & (0xFF << shift)) >> shift;
		kVal = alpha*f + beta*b + 0.5;
		val |= kVal;
		val <<= 8;
	}
	return val;
}
	
void delay( int tim )
{
	clock_t start = clock( );
	while( clock( ) - start < tim ); 
/*
	int t;
	while( tim-- )
	{
		t = 2<<12;
		while( t-- );
	}
*/
}
