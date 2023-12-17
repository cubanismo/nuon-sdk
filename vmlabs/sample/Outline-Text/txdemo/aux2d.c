/* 
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 * Package of convenience library functions using MML2d functions
 * rwb 12/29/98
 */
 
#include <stdlib.h>
#include <string.h>
#include <nuon/mml2d.h>
#include <nuon/bios.h>

#include "aux2d.h"

/* do an ellipse highlight of a word in a rendered string.
   get the coordinates 
*/
/* NOT SUPPORTED in SDK > 0.87 
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
*/   
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
/* Draw a string of characters in a rect positioned at top, left
   of rect.  Clip to bottom, right, but only draw as much as string.
*/

void drawString( mmlFontContext fc, mmlDisplayPixmap* sP,
		textCode t[], m2dRect* rP )
{
	int len = strlen( (char*) t );
	mmlSimpleDrawText( fc, sP, t, len, rP );
}

