/*
   Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
*/
/* 
 * Package of convenient library functions for manipulating text.
 * rwb 8/6/99
 * aux libraries are intended to be C functions that could be written
 * by any application programmer, but are provided as a convenience so
 * that each programmer doesn't have to invent them.
 * They are not necessarily efficient, nor have they been exhaustively
 * tested.
 */
#include "aux2d.h"
#include <nuon/mml2d.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

/* return pointer to current text style in font context */
mmlTextStyle* activeTextStyle( mmlFontContext fc )
{
	uint32* p = (uint32*)fc;
	p += 8;
	return (mmlTextStyle*)p;
}

/* return the positions of the first and last letters of
 the word in a string that contains the index or the next
 word if the index is on a word break.
 	If the index points at a final word break, set both
 first and last to index.
*/
void wordBoundaries( textCode* t, int endText, int index, int* first, int* last )
{
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
	*last = --index;
}

/* Return the positions of first and last characters of
kth word in string.  If there are not k words, set first
and last to last position (terminator) in string.
*/
void kthWord( textCode* t, int endText, int k, int* kFirst, int* kLast )
{
	int first;
	int last = -1;
	int j;
	for( j=0; j<=k; ++j )
	{
		if( last < endText )
			wordBoundaries( t, endText, last+1, &first, &last );
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

/* Fill in an array with indices of the characters that
are the first and last letters in words or the punctuation following 
the word.  The array must be big enough to hold all the words.
	Return the number of words.
*/
int wordEnds( textCode t[], int nChars, int positions[][2] )
{
	int nWords = 0;
	int first;
	int last = 0;
	while( last < nChars )
	{
		wordBoundaries( t, nChars, last, &first, &last );
		positions[nWords][0] = first;	
		positions[nWords++][1] = last;	
		++last;
	}
	return nWords;
}	

/* Break a string into n lines that are each shorter than wide.  
Fill in a array with indices of first characters of first word
and last characters of last words in each of the lines.
	If a single word is greater than wide, break it up into pieces,
each wide or less.
	Returns number of lines.
*/
int lineBreak( mmlFontContext fc, textCode t[], int numChars, int lineEnds[][2], int wide )
{
	int positions[kMaxWordsInLine][2];
	int nWords = wordEnds( t, numChars, positions );
	int startChar = 0;
	int nLine = 0;
	int firstWord = 0;
	int word;
	m2dRect q;
	assert( nWords <= kMaxWordsInLine );
	word = firstWord;
	while( word < nWords )
	{
		m2dSetRect( &q, 0, 0, wide+1, 576 );
		mmlGetTextBox( fc, &t[startChar], 0, positions[word][1]-startChar, &q );  
		if( q.rightBot.x >= wide )
		{
			lineEnds[nLine][0] = startChar;
			if( word == firstWord )
			{
				int j = startChar;
				while( ++j <= positions[word][1] )
				{
					m2dSetRect( &q, 0, 0, wide+1, 576 );
					mmlGetTextBox( fc, &t[startChar], 0, j-startChar, &q );
					if( q.rightBot.x >= wide )
					{
						lineEnds[nLine++][1] = j-1;
						startChar = j;
						break;
					}
				}  
			}
			else
			{
				lineEnds[nLine++][1] = positions[word-1][1];
				startChar = positions[word][0];
				firstWord = word;
			}
		}
		else ++word;
	}
	lineEnds[nLine][0] = startChar;
	lineEnds[nLine++][1] = positions[nWords-1][1];
	return nLine;	
}	

/* Pour a long string into a rectangle, doing line breaks on word
boundaries, and laying out the lines according to an enumerated 
justification style.
*/	
void layoutText( mmlFontContext fc, mmlDisplayPixmap* sP,
		textCode t[], int nChars, m2dRect* rP, mmlJust mode)
{
	int line;
	int lineEnds[kMaxLinesInRect][2];
	int rClip = rP->rightBot.x;
	int bClip = rP->rightBot.y;
	int wide = rClip - rP->leftTop.x + 1;
	int nLines = lineBreak( fc, t, nChars, lineEnds, wide );
	mmlTextStyle* styleP = activeTextStyle( fc );
	for( line=0; line<nLines; ++line )
	{
		m2dRect q;
		int lineWidth;
		int startChar = lineEnds[line][0];
		int nChars = lineEnds[line][1] - startChar + 1;
		switch( mode )
		{
		case eCenterJust:
			m2dSetRect( &q, rP->leftTop.x, rP->leftTop.y + line*styleP->fontSize, rClip, bClip );
			mmlGetTextBox( fc, &t[startChar], 0, nChars-1, &q );
			lineWidth = q.rightBot.x - q.leftTop.x + 1;
			q.leftTop.x = rP->leftTop.x + (wide - lineWidth)/2;
			q.rightBot.x = rClip;
			break;
		case eLeftBotJust:
			m2dSetRect( &q, rP->leftTop.x, rP->rightBot.y - (nLines-line)*styleP->fontSize, rClip, bClip );
			break;
		case eRightTopJust:
			m2dSetRect( &q, rP->leftTop.x, rP->leftTop.y + line*styleP->fontSize, rClip, bClip );
			mmlGetTextBox( fc, &t[startChar], 0, nChars-1, &q );
			lineWidth = q.rightBot.x - q.leftTop.x + 1;
			m2dSetRect( &q, rP->rightBot.x - lineWidth, rP->leftTop.y + line*styleP->fontSize, rClip, bClip );
			break;
		case eRightBotJust:
			m2dSetRect( &q, rP->leftTop.x, rP->leftTop.y + (nLines-line)*styleP->fontSize, rClip, bClip );
			mmlGetTextBox( fc, &t[startChar], 0, nChars-1, &q );
			lineWidth = q.rightBot.x - q.leftTop.x + 1;
			m2dSetRect( &q, rP->rightBot.x - lineWidth, rP->rightBot.y - (nLines-line)*styleP->fontSize, rClip, bClip );
			break;
		case eLeftTopJust:
		default:
			m2dSetRect( &q, rP->leftTop.x, rP->leftTop.y + line*styleP->fontSize, rClip, bClip );
			break;
		}
		mmlSimpleDrawText( fc, sP, &t[startChar], nChars, &q );
	}
}

/* Draw a string of characters as one line in a rect;
 positioned at top, left of rect.  Clip to bottom, right.
*/
void drawString( mmlFontContext fc, mmlDisplayPixmap* sP,
		textCode t[], m2dRect* rP )
{
	int len = strlen( (char*) t );
	mmlSimpleDrawText( fc, sP, t, len, rP );
}

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
	kthWord( t, strlen(t), kth, &first, &last );
	mmlGetTextBox( gcP->fontContextP, t, first, last, &r );
	el.xScale = ((r.rightBot.x - r.leftTop.x)<<8)/(r.rightBot.y - r.leftTop.y );
	rad = (r.rightBot.y - r.leftTop.y)/2;
	xc = (r.rightBot.x + r.leftTop.x)/2;
	yc = (r.rightBot.y + r.leftTop.y)/2;
	m2dDrawStyledEllipse( gcP, sP, &el, xc, yc, rad );
}	
