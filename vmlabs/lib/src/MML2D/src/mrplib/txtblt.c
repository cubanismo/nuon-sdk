
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Third cut at a Merlin Code Text blitter.
Version 1.0 only supports srcCopy mode.
Also only does max of 24 glyphs a time.
Assumes pixmaps in cache are encoded using VMLABs RLE compression.
Graphics Tile is broken into odma block, mdma block, par block (including
up to 24 glyph descriptors), and tile block.
tile block is divided into a pix column to write out and remainder to hold 
data read from glyph cache.
*/
#include <stdio.h>
#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include <stddef.h>

#define kWhitePre 0xC0
#define kBlackPre 0x80
#define kEndGlyphPre 0x40

#define kNumValues 16
/* kMaxLongs is max number of longs that should be transferred in any
single dma operation.  If the graphics block is at least 768 and platform
constraints allow it, this could be increased to 64.
*/

static inline void putNpix( int num, int color, uint32* outP )
{
	while( num-- > 0 )
	{
	    _SetLocalVar(*outP, color);
	    ++outP;
	}
};

/* Return next byte.  Decrement shift, and possibly advance input ptr.
*/ 
static inline int nextByte( uint32** vPP, int* shiftP )
{
	int val = (_GetLocal(**vPP) >> *shiftP) & 0xFF;
	*shiftP -= 8;
	if( *shiftP < 0 )
	{
		*shiftP = 24;
		*vPP += 1;
	}
	return val;
}

/* Use direct Pixel transfer command to write N columns of
forecolor or backcolor pixels directly to SDRAM. This
function does not have to
worry about pixel alignment for 16 bit and 32 bit pixels.
mode ForeBack16 - color is backColor
mode Trans32 - color is transparent alpha

DO LATER
mode ForeBack32 - color is backColor, alpha is min( const, destPix)
mode ForeBack8 - color is index of opaque backColor
mode Trans8 - color is index of transparent.
	
	All text blits only wait for DMA before blitting.
rwb 8/26/99 - Fix so never write more than kMaxLongs at a time.
*/ 

static void drawBlankCol( int flags, void* dstBase, int left, int numCols,
	int top, int high, int colorValue, mdmaCmdBlock* mdmaP )
{
	MRP_DmaWait( kmdmactl );			

	while( numCols-- > 0 )
	{
		int nRows = high;
		int y = top;
		while( nRows > 0 )
		{
			int numPix = MIN( nRows, kMaxLongs );
			_SetLocalVar( mdmaP->flags, flags | kBitDup);
			_SetLocalVar( mdmaP->sdramAdr, dstBase);
			_SetLocalVar( mdmaP->xDesc, (1<<16) | left);
			_SetLocalVar( mdmaP->yDesc, (numPix<<16) | y);
			_SetLocalVar( mdmaP->dramAdr, (char*)(&mdmaP->value));
			_SetLocalVar( mdmaP->value, colorValue);
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			nRows -= numPix;
			y += numPix;
		}
		++left;
	}
}

/* Write a single column from dtram to SDRAM.
rwb 8/26/99 - Assume never called with high > kMaxLongs 
*/
static inline void drawCol( int flags, void* dstBase, int left,
	int top, int high, void* tileBase, mdmaCmdBlock* mdmaP )
{
	MRP_DmaWait( kmdmactl );			

	_SetLocalVar( mdmaP->flags, flags);
	_SetLocalVar( mdmaP->sdramAdr, dstBase);
	_SetLocalVar( mdmaP->xDesc, (1<<16) | left);
	_SetLocalVar( mdmaP->yDesc, (high<<16) | top);
	_SetLocalVar( mdmaP->dramAdr, tileBase);
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
}

static inline int alphaFun( int alpha )
{
	
//	return alphaFun3( alpha, 100, 195, 85, 205 );
	alpha = 195 - (95 * (205 - alpha))/140;
	if( alpha > 195 ) alpha = 195;
	else if( alpha < 100 ) alpha = 100;
	return alpha;
}

/* Read GlyphDrawParamBlock and render 1 glyph.
Render more, if no urgent events require return.
ParamBlock .dstFormat already contains cluster and format shifted.
rwb 8/17/98 - New version to do antialiasing against video plane.
rwb 8/26/98 - Bug fixes.  Handle bottom clipping correctly. Also,
write columns 32 pix at a time, so can do large point sizes. Cut down
required size of graphics block.
*/
#define GDSIZE ((sizeof( glyphDescriptor ) + 3) & ~3)

mrpStatus TexBlt(int environs, DrawGlyphParamBlock* parAdr,
 int numGlyphs, int arg3 )
{
	odmaCmdBlock* odmaP;
	mdmaCmdBlock* mdmaP;
	DrawGlyphParamBlock* parP;
	uint8* tileP;
	uint32* glyphP;
	uint32* pixInP;
	int k, flags, high;
	int nTrail, dstLeft, dstTop, widthSoFar, nGlyphsTotal, nGlyphsFinished;
	int parHeaderLongs = (sizeof( DrawGlyphParamBlock ) + 3)>>2;
	mmlColor foreColor, backColor;
	void* dstBase;
	int values[kNumValues];
	int excess, nToDo, nGlyphsPerRead;
	
	mrpSetup(environs, 0, &odmaP, &mdmaP, NULL, &tileP, NULL );
	/* Allocate graphics block to write data, pix data, glyph descriptors */
	/* Allocate kMaxLongs for partial column to be created and written
	and kMaxLongs for compressed pix data being read in */
	pixInP = ((uint32*)tileP) + kMaxLongs;
	glyphP = pixInP + kMaxLongs;
	nGlyphsPerRead = ( ((uint32)mdmaP) - ((uint32)glyphP) )/GDSIZE;
	if( nGlyphsPerRead < 1 ) return eError;
	parP = (DrawGlyphParamBlock*)(glyphP - parHeaderLongs);
	/* Deliberate bug.  If DrawGlyph param block is at very end of memory, this
	could cause a dma error by trying to read non-existent address. So rare, not
	worth using code to protect from it. */
	mrpSysRamMove( parHeaderLongs + nGlyphsPerRead*(GDSIZE>>2), (void*)parP, (void*)parAdr,  odmaP, kSysReadFlag, kWaitFlag);
	
	/* Create table of mixed fore/back color values to be mapped into */
	{
		int j;
		int linCtrl = (e888Alpha<<20) | kChNorm ;   /* fore and backColor are type e888Alpha (4) */
		for( j=0; j<kNumValues; ++j )
			values[j] = blendPix( 4*j, &parP->foreColor, &parP->backColor, linCtrl ); 
		if( _GetLocal(parP->translucent))
			for( j=0; j<kNumValues; ++j )
				values[j] |= alphaFun( 0xFF - 16*j );
	} 
	flags 	= ((_GetLocal(parP->dstStridePix) & ~7)<<13) | _GetLocal(parP->dstFormat) | kPixWrite;
	high 		= _GetLocal(parP->dstHighPix);
	dstBase 	= (void*)_GetLocal(parP->dstBase);
	dstLeft 	= _GetLocal(parP->dstLeft);
	foreColor 	= _GetLocal(parP->foreColor);
	backColor 	= _GetLocal(parP->backColor);
	nGlyphsTotal = _GetLocal(parP->nGlyphsTotal);
	dstTop 		= _GetLocal(parP->dstTop);
	nTrail 		= _GetLocal(parP->nTrailCols); 
	excess		= _GetLocal(parP->excess);
	widthSoFar 	= 0;
	nGlyphsFinished = 0;
	nToDo = 1;
	k = 0;
/* do glyph k */
newGlyph:
	if( --nToDo == 0  )
	{
		glyphDescriptor* sysAdr = parAdr->glyph + nGlyphsFinished;
		nToDo = MIN( nGlyphsTotal - nGlyphsFinished, nGlyphsPerRead );	
		mrpSysRamMove( nToDo*(GDSIZE>>2), (void*)glyphP, (void*)sysAdr, odmaP, kSysReadFlag, kWaitFlag);
		k = 0;
	}
 	{
 		glyphDescriptor* glyphDescP = (glyphDescriptor*)glyphP;
		uint32* pixP	= (uint32*)_GetLocal( glyphDescP[k].glyphAdr );
/* nLeftCols and size are shorts, can't be gotten with GetLocal */
		int	size		= _GetLocal( glyphDescP[k++].nLeftCols );
		int	nLeft		= size >> 16;
		int	nLongs		= size & 0xFFFF;
		int	rowsLeft	= high;
		int extraPix	= excess;
		
		if( nLeft > 0 ) 
			drawBlankCol( flags, dstBase, dstLeft + widthSoFar, nLeft, dstTop, high, backColor, mdmaP );
		widthSoFar += nLeft;
		if( nLongs > 0 )
		{
			int n = 0;
			int code = 0;
			uint32* inP = glyphP;
			uint32* outP = (uint32*)tileP;
			int shift = 24;
			int val = 0;
			int rowsWritten = 0;
			int valRemain = 0;
			mmlColor color;
NextByte:
			if( val != 0 ) goto nextCol;
			if( inP == glyphP && shift == 24 )  /* used up all the pixmap data, read some more */
			{
				int nRead = nLongs > kMaxLongs ? kMaxLongs : nLongs;
				mrpSysRamMove( nRead, (void*)pixInP, (void*)pixP, odmaP, kSysReadFlag, kWaitFlag );
				nLongs -= nRead;
				pixP += nRead;
				inP = pixInP;
			}
			if( valRemain > 0 )  /* very long strip of white or black */
			{
				val = MIN( kMaxLongs, valRemain );
				valRemain -= val;
			}
			else
			{
				val = nextByte( &inP, &shift );
				code = val & 0xC0;
				if( code == kEndGlyphPre ) goto nextGlyph;
				val &= 0x3F;
				if( code == kBlackPre || code == kWhitePre )
				{
					valRemain = val;
					val = MIN(kMaxLongs, valRemain );
					valRemain -= val;
				} 
			}
nextCol:
			n = code == 0 ? 1 :  MIN( rowsLeft, val );
			color = backColor;			
			if( outP + n > pixInP )
			{
				int nWrite = (((int)(outP)) - ((int)(tileP)))>>2;
				if( nWrite > 0 )drawCol(  flags, dstBase, dstLeft + widthSoFar, dstTop+rowsWritten, nWrite, tileP, mdmaP );
				outP = (uint32*)tileP;
				rowsWritten += nWrite;
			}				
			if( rowsLeft == 0 && extraPix > 0 )
			{
				if( code == 0 )
				{
					--extraPix;
					val = 0;
				}
				else if( extraPix >= val )
				{
					extraPix -= val;
					val = 0;
				}
				else
				{
					val -= extraPix;
					extraPix = 0;
				}
			}
			else switch( code )
			{
			case 0:
 				_SetLocalVar(*outP,  values[val>>2]);
				--rowsLeft;
				++outP;
				val = 0;			
				break;
			case kBlackPre:
				color = foreColor;
			case kWhitePre:
				putNpix( n, color, outP );
				val -= n;
				rowsLeft -= n;
				outP += n;
				break;
			default:
				break;
			}
			if( rowsLeft == 0 && extraPix == 0 )
			{
				drawCol(  flags, dstBase, dstLeft + widthSoFar, dstTop+rowsWritten, high-rowsWritten, tileP, mdmaP );
				++widthSoFar;
				rowsLeft = high;
				rowsWritten = 0;
				extraPix = excess;
				outP = (uint32*)tileP;
			}
			goto NextByte;
		}
	}
nextGlyph:
	if( ++nGlyphsFinished < numGlyphs ) goto newGlyph;
	if(nTrail > 0)
		drawBlankCol( flags, dstBase, dstLeft + widthSoFar, nTrail, dstTop, high, backColor, mdmaP );		
	return eFinished;
}
#undef GDSIZE
		
	
