
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* Third cut at a Merlin Code Text blitter.
Version of text blitter that combines forecolor with existing graphics osd pixels.
Assumes pixmaps in cache are encoded using VMLABs RLE compression.
Graphics Tile is broken into odma block, mdma block, par block (including
glyph descriptors), and tile block.
tile block is divided into a pix column to write out and remainder to hold 
data read from glyph cache.
*/
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


/* Write a single column from dtram to SDRAM.
   Set readQ to kReadBit to move from SDRAM to dtram, else 0.
rwb 8/26/99 - Assume never called with high > kMaxLongs 
*/
static inline void moveCol( int flags, void* dstBase, int left,
	int top, int high, void* tileBase, mdmaCmdBlock* mdmaP, int readQ  )
{

	MRP_DmaWait( kmdmactl );			

	_SetLocalVar( mdmaP->flags, flags | readQ);
	_SetLocalVar( mdmaP->sdramAdr, dstBase);
	_SetLocalVar( mdmaP->xDesc, (1<<16) | left);
	_SetLocalVar( mdmaP->yDesc, (high<<16) | top);
	_SetLocalVar( mdmaP->dramAdr, tileBase);
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
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

mrpStatus TexBlend(int environs, DrawGlyphParamBlock* parAdr,
 int numGlyphs, int arg3 )
{
	odmaCmdBlock* odmaP;
	mdmaCmdBlock* mdmaP;
	DrawGlyphParamBlock* parP;
	uint8* tileP;
	uint32* glyphP;
	uint32* pixInP;
	int k, flags, high;
	int dstLeft, dstTop, widthSoFar, nGlyphsTotal, nGlyphsFinished;
	int parHeaderLongs = (sizeof( DrawGlyphParamBlock ) + 3)>>2;
	mmlColor foreColor, backColor;
	void* dstBase;
	int linCtrl = (e888Alpha<<20) | kChNorm ;   /* fore and backColor are type e888Alpha (4) */
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
	
	flags 	= ((_GetLocal(parP->dstStridePix) & ~7)<<13) | _GetLocal(parP->dstFormat) | kPixWrite;
	high 		= _GetLocal(parP->dstHighPix);
	dstBase 	= (void*)_GetLocal(parP->dstBase);
	dstLeft 	= _GetLocal(parP->dstLeft);
	foreColor 	= _GetLocal(parP->foreColor);
	backColor 	= _GetLocal(parP->backColor);
	nGlyphsTotal = _GetLocal(parP->nGlyphsTotal);
	dstTop 		= _GetLocal(parP->dstTop);
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
			int nrd = MIN( kMaxLongs, high );
			moveCol(  flags, dstBase, dstLeft + widthSoFar, dstTop, nrd, tileP, mdmaP, kSysReadFlag );
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
			if( outP + n > pixInP )
			{
				int nWrite = (((int)(outP)) - ((int)(tileP)))>>2;
				if( nWrite > 0 )
				{
					moveCol(  flags, dstBase, dstLeft + widthSoFar, dstTop+rowsWritten, nWrite, tileP, mdmaP, 0 );
					rowsWritten += nWrite;
					nWrite = MIN( kMaxLongs, high - rowsWritten );
					moveCol(  flags, dstBase, dstLeft + widthSoFar, dstTop+rowsWritten, nWrite, tileP, mdmaP, kSysReadFlag );
				}	
				outP = (uint32*)tileP;
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
				_SetLocalVar(*outP, blendPix( val, &foreColor, (mmlColor*) outP, linCtrl ));
				--rowsLeft;
				++outP;
				val = 0;			
				break;
			case kBlackPre:
				putNpix( n, foreColor, outP );
			case kWhitePre:
				val -= n;
				rowsLeft -= n;
				outP += n;
				break;
			default:
				break;
			}
			if( rowsLeft == 0 && extraPix == 0 )
			{
				int nRd;
				moveCol(  flags, dstBase, dstLeft + widthSoFar, dstTop+rowsWritten, high-rowsWritten, tileP, mdmaP, 0 );
				++widthSoFar;
				rowsLeft = high;
				rowsWritten = 0;
				extraPix = excess;
				outP = (uint32*)tileP;
				nRd = MIN( kMaxLongs, high );
				moveCol(  flags, dstBase, dstLeft + widthSoFar, dstTop, nRd, tileP, mdmaP, kSysReadFlag );
			}
			goto NextByte;
		}
	}
nextGlyph:
	if( ++nGlyphsFinished < numGlyphs ) goto newGlyph;
	return eFinished;
}
#undef GDSIZE
		
