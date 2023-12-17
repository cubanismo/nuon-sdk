/*
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission 
 */

/* 
 * Prototypes for a package of convenience library functions
 * for 2d and text using MML2d functions.
 * rwb 12/29/98
 */

#include <nuon/mml2d.h> 

#define kMaxWordsInLine 40
#define kMaxLinesInRect 20

typedef enum{
	eCenterJust,
	eLeftTopJust,
	eLeftBotJust,
	eRightTopJust,
	eRightBotJust
	} mmlJust;

void makePalette1( mmlColor ycc[256] );
void makePalette2( mmlColor ycc[256] );
void mmlSetClut( mmlColor ycc[], int indexFirst, int indexLast );
void delay( int tim );
void drawBox(mmlGC* gcP, mmlDisplayPixmap* sP,
	 m2dRect* rP, m2dLineStyle* styleP );
void drawString( mmlFontContext fc, mmlDisplayPixmap* sP,
	 textCode t[], m2dRect* rP );
void ellipseHigh(mmlGC* gcP, mmlDisplayPixmap* sP,
	m2dEllipseStyle* esP, textCode t[], int kth,
	m2dRect* rendP  );
void wordBoundaries( textCode* t, int nChars, int index, int* first, int* last );
void kthWord( textCode* t, int nChars, int k, int* kFirst, int* kLast );
mmlTextStyle* activeTextStyle( mmlFontContext fc );
int wordEnds( textCode t[], int nChars, int positions[][2] );
int lineBreak( mmlFontContext fc, textCode t[], int nChars, int lineEnds[][2], int wide );
void layoutText( mmlFontContext fc, mmlDisplayPixmap* sP,
		textCode t[],  int nChars, m2dRect* rP, mmlJust mode);

