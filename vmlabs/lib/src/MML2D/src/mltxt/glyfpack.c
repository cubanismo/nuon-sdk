
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* rwb
 * 8/9/98
 */

#include "../../nuon/mml2d.h"

/* Version 1 of a more general glyph data packing function.
Input is an N-bit deep pixmap in row order.
Output is a vertical run-length-encoded byte sequence.
The bit meaning of each byte is:
0b00abcdef -- a pixel with this mask value (0 = opaque, 3F = transparent )
0b10abcdef -- write abcdef opaque pixels
0b11abcdef -- write abcdef transparent pixels
0b01000000 -- end of glyph
base is the number of pixels above the bottom of the column of the baseline pixel
Modify destP to point at long that will be start of next glyph.
*/
#define kWhitePre 0xC0
#define kBlackPre 0x80
#define kEndGlyphPre 0x40
#define kBlack 120
#define kWhite 0


/* Write an End Of Glyph byte. Advance dstPtr to point at start of next glyph.
*/
static void PutEndGlyph( uint32** dstPP, int* shiftP )
{
	uint32 mask, dVal, sVal;
	mask = ~( 0xFF << *shiftP );
	dVal = **dstPP & mask;
	sVal = kEndGlyphPre << *shiftP;
	**dstPP = dVal | sVal;
	++*dstPP;
}

/* Write a pixel value into dest byte.
   If packed int is full, advance pointer.
   If pointer would exceed cache limit, return failure.
*/	
static mmlStatus PutPixel( uint32 srcVal, uint32** dstPP, int* shiftP, uint32* endP )
{
	uint32 mask, dVal, sVal;
	mask = ~( 0xFF << *shiftP );
	dVal = **dstPP & mask;
	sVal = srcVal << *shiftP;
	**dstPP = dVal | sVal;
	*shiftP = (*shiftP - 8);
	if( *shiftP < 0 )
	{
		*shiftP = 24;
		if( ++*dstPP > endP ) return eGlyphTooBig;
	}
	return eOK;
}

/* Write a byte that represents a number of white or black pixels to be written
in a column. May be the bottom of one column and the top of the next column.
The most sig two bytes are a prefix indicating black or white.
Recursively deals with a count greater than 63
   If packed int is full, advance pointer.
   If pointer would exceed cache limit, return failure.
*/
static mmlStatus PutCount( int prefix, int num, uint32** dstPP, int* shiftP, uint32* endP )
{
	uint32 mask, dVal, sVal;
	while( num > 63 )
	{
		if( PutCount( prefix, 63, dstPP, shiftP, endP ) == eGlyphTooBig ) return eGlyphTooBig;
		num -= 63;
	}
	mask = ~( 0xFF << *shiftP );
	dVal = **dstPP & mask;
	sVal = ((num & 0x3F) | prefix ) << *shiftP;
	**dstPP = dVal | sVal;
	*shiftP = (*shiftP - 8);
	if( *shiftP < 0 )
	{
		*shiftP = 24;
		if( ++*dstPP > endP ) return eGlyphTooBig;
	}
	return eOK;
} 

/*	
* Pack raw pixmap into vertically RLE glych cache entry.
  If packed glyph won't fit into cache block, return failure.
*/
mmlStatus texPackGlyph( uint32* srcStartP, uint32* destP, int high, int wide, int rowBytessWide,
	int colHigh, int nTopWhite, uint32** nextP, uint32* endP )
{
	uint32 srcVal;
	int nBotWhite = colHigh - high - nTopWhite;
	int nWhite = 0;
	int byteShift = 24;
	int jCol;
	uint32* dstP = destP;
	for( jCol = 0; jCol<wide; ++jCol )
	{
		int jRow;
		int nBlack = 0;
		uint8* srcP = (uint8*)srcStartP;
		srcP += jCol;
		nWhite += nTopWhite;
		for( jRow=0; jRow<high; ++jRow )
		{
			srcVal = (uint32)*srcP;
			if( srcVal == kWhite )
			{
				if( nBlack > 0 )
				{
					if( PutCount( kBlackPre, nBlack, &dstP, &byteShift, endP ) == eGlyphTooBig ) return eGlyphTooBig;
					nBlack = 0;
				}
				++nWhite;
			}
			else if( srcVal == kBlack )
			{
				if( nWhite > 0 )
				{
					if( PutCount( kWhitePre, nWhite, &dstP, &byteShift, endP ) == eGlyphTooBig ) return eGlyphTooBig; 
					nWhite = 0;
				}
				++nBlack;
			}
			else
			{
				if( nWhite > 0 )
				{
					if( PutCount( kWhitePre, nWhite, &dstP, &byteShift, endP ) == eGlyphTooBig ) return eGlyphTooBig;
					nWhite = 0;
				}
				else if( nBlack > 0 )
				{
					if( PutCount( kBlackPre, nBlack, &dstP, &byteShift, endP ) == eGlyphTooBig ) return eGlyphTooBig;
					nBlack = 0;
				}
				srcVal >>= 1;  //map 1-119 into 1-63
				srcVal += 4;
				if( PutPixel( srcVal, &dstP, &byteShift, endP ) == eGlyphTooBig ) return eGlyphTooBig;
			}
			srcP += rowBytessWide;
		}
		if( nBlack > 0 )
		{ 
			if( PutCount( kBlackPre, nBlack, &dstP, &byteShift, endP ) == eGlyphTooBig ) return eGlyphTooBig;
			nBlack = 0;
		}
		nWhite += nBotWhite;
	}
	if( nWhite > 0 )
	{
		if( PutCount( kWhitePre, nWhite, &dstP, &byteShift, endP ) == eGlyphTooBig ) return eGlyphTooBig;
	}
	PutEndGlyph( &dstP, &byteShift );
	*nextP = dstP;
	return eOK;
}
		
				
				
				
				
				
				
				
				
				
			
					
			