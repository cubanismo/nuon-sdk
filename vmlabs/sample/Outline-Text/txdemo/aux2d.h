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
 * Package of convenience library functions using MML2d functions
 * rwb 12/29/98
 */

#include <nuon/mml2d.h>
#include <nuon/bios.h>

#define MIN( x, y ) ( (x) < (y) ? x : y )

void drawBox(mmlGC* gcP, mmlDisplayPixmap* sP,
	 m2dRect* rP, m2dLineStyle* styleP );
void drawString( mmlFontContext fc, mmlDisplayPixmap* sP,
	 textCode t[], m2dRect* rP );
void ellipseHigh(mmlGC* gcP, mmlDisplayPixmap* sP,
	m2dEllipseStyle* esP, textCode t[], int kth,
	m2dRect* rendP  );
void wordBoundaries( textCode* t, int index, int* first, int* last );
void kthWord( textCode* t, int k, int* kFirst, int* kLast );
void mmlSetClut( mmlColor ycc[], int indexFirst, int indexLast );
void makePalette1( mmlColor ycc[256] );
void mmlConfigChan( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset, int horFilter );
void mmlConfigOSD( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset );
void mmlConfigMain( VidChannel* vP, mmlDisplayPixmap* sP, int horOffset, int vertOffset );
void delay( int tim );
