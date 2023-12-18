/* Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */
/* 
 * Package of convenience library functions using MML2d functions
 * rwb 12/29/98
 */
#include <nuon/mml2d.h> 
#include <nuon/bios.h>

void makePalette1( mmlColor ycc[256] );
void makePalette2( mmlColor ycc[256] );
void mmlSetClut( mmlColor ycc[], int indexFirst, int indexLast );
void mmlConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int horFilter );
void mmlConfigOSD( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset );
void mmlConfigMain( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset );
void delay( int tim );
void drawBox(mmlGC* gcP, mmlDisplayPixmap* sP,
	 m2dRect* rP, m2dLineStyle* styleP );
void drawString( mmlFontContext fc, mmlDisplayPixmap* sP,
	 textCode t[], m2dRect* rP );
void ellipseHigh(mmlGC* gcP, mmlDisplayPixmap* sP,
	m2dEllipseStyle* esP, textCode t[], int kth,
	m2dRect* rendP  );
void wordBoundaries( textCode* t, int index, int* first, int* last );
void kthWord( textCode* t, int k, int* kFirst, int* kLast );

#define MIN( x, y ) ( (x) < (y) ? x : y )
