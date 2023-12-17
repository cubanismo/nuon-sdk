
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* Third cut at a Merlin Code Text blitter.
Version of text blitter for eClut8 mode. Simply writes index value into framebuffer.
Must process two columns at a time because 8 bit pixels are stored two columns per 
short, and beginning and ending addresses must be shorts not bytes.
Assumes pixmaps in cache are encoded using VMLABs RLE compression.
Graphics Tile is broken into odma block, mdma block, par block (including
glyph descriptors), and tile block.
tile block is divided into a pix column to write out and remainder to hold 
data read from glyph cache.  At most kMaxLongs are ever transferred in any
DMA.
*/
#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include <stddef.h>

#define kWhitePre 0xC0
#define kBlackPre 0x80
#define kEndGlyphPre 0x40

/* kMaxLongs is max number of longs that should be transferred in any
single dma operation.  If the graphics block is at least 768 and platform
constraints allow it, this could be increased to 64.
*/
static inline void putNEvenPix( int num, int index, uint16* outP )
{
	while( num-- > 0 ) 
	{
		int val = _GetLocalShort(*outP) & 0xFF;
		_SetLocalShortVar(*outP, val | (index << 8));
		outP++;
	}
}
	
static inline void putNOddPix( int num, int index, uint16* outP )
{
	while( num-- > 0 )
	{
		int val = _GetLocalShort(*outP) & 0xFF00;
		_SetLocalShortVar(*outP, val | index);
		outP++;
	}
}	

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

/* Move two columns betwee dtram and SDRAM; nShorts in each column.
   Each short contains pixels from 2 adjacent cols in same row.
   left must be even.
   Set readQ to kReadBit to move from SDRAM to dtram, else 0.
rwb 8/26/99 - Assume never called with nShorts > 2*kMaxLongs 
*/
static inline void move2Col( int flags, void* dstBase, int left,
	int top, int nShorts, void* tileBase, mdmaCmdBlock* mdmaP, int readQ )
{	
	MRP_DmaWait( kmdmactl );			
	_SetLocalVar( mdmaP->flags , (flags | readQ));
	_SetLocalVar( mdmaP->sdramAdr, dstBase);
	_SetLocalVar( mdmaP->xDesc, ((2<<16) | left));
	_SetLocalVar( mdmaP->yDesc, ((nShorts<<16) | top));
	_SetLocalVar( mdmaP->dramAdr, tileBase);
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
}

/* Read GlyphDrawParamBlock and render glyphs.
ParamBlock .dstFormat already contains cluster and format shifted.
rwb 8/17/98 - New version to do antialiasing against video plane.
rwb 8/26/98 - Bug fixes.  Handle bottom clipping correctly. Also,
write columns 32 pix at a time, so can do large point sizes. Cut down
required size of graphics block.
*/
#define GDSIZE ((sizeof( glyphDescriptor ) + 3) & ~3)

mrpStatus TexAlpha(int environs, DrawGlyphParamBlock* parAdr,
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
	void* dstBase;
	int excess, nToDo, nGlyphsPerRead, column;
	int indexDiv, indexMin, indexMax, foreIndex, indexHigh;
	
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
	foreIndex 	= _GetLocal(parP->foreColor);
	nGlyphsTotal = _GetLocal(parP->nGlyphsTotal);
	dstTop 		= _GetLocal(parP->dstTop);
	excess		= _GetLocal(parP->excess);
	indexMax	= (_GetLocal(parP->indexVals) & 0xFF00 ) >> 8;
	indexMin	= (_GetLocal(parP->indexVals) & 0xFF0000 ) >> 16;
	indexDiv	= (_GetLocal(parP->indexVals) & 0xFF000000) >> 24;
	indexHigh	= (_GetLocal(parP->indexVals) & 0xFF) + (64/indexDiv) - 1;
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
		column = dstLeft + widthSoFar;
		if( nLongs > 0 )
		{
			int n = 0;
			int code = 0;
			uint32* inP = glyphP;
			uint16* outP = (uint16*)tileP;
			int shift = 24;
			int val = 0;
			int rowsWritten = 0;
			int valRemain = 0;
			int nrd = MIN( kMaxLongs<<1, high );
			move2Col(  flags, dstBase, (column & ~1), dstTop, nrd, tileP, mdmaP, kSysReadFlag );
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
			if( outP + n > (uint16*)pixInP )
			{
				int nWrite = (((int)(outP)) - ((int)(tileP)))>>1;
				if( nWrite > 0 )
				{
					move2Col(  flags, dstBase, (column & ~1), dstTop+rowsWritten, nWrite, tileP, mdmaP, 0 );
					rowsWritten += nWrite;
					nWrite = MIN( kMaxLongs<<1, high - rowsWritten );
					move2Col(  flags, dstBase, (column & ~1), dstTop+rowsWritten, nWrite, tileP, mdmaP, kSysReadFlag );
				}	
				outP = (uint16*)tileP;
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
			int tempShort;
			case 0:
			/* val is always between 4 (1/120 cover) and 63 ( 118/120 & 119/120 cover) */
			/* for indexDiv = 16, indexHigh = base+4 */
				val /= indexDiv; // for indexDiv=16, val -> 0( 1/120&23/120) .. 3(88/120&119/120)
				val = indexHigh - val; // val -> base+4 ... base+1
				tempShort = _GetLocalShort( *outP );
				if( column & 1)
				{
					tempShort &= 0xFF00;
					if( val > indexMax ) tempShort |= indexMax;
					else if( val < indexMin ) tempShort |= indexMin;
					else tempShort |= val ;
				}
				else
				{
					tempShort &= 0xFF;
					if( val > indexMax ) tempShort |= (indexMax<<8);
					else if( val < indexMin ) tempShort |= (indexMin<<8);
					else tempShort |= (val<<8);
				}
				_SetLocalShortVar(*outP, tempShort );
				--rowsLeft;
				val = 0;
				++outP;
				break;
			case kBlackPre:
				if( column & 1 )
					putNOddPix( n, foreIndex, outP );
				else
					putNEvenPix( n, foreIndex, outP );
			case kWhitePre:
				rowsLeft -= n;
				val -= n;
				outP += n;
				break;
			case kEndGlyphPre:
				goto nextGlyph;
			default:
				break;
			}
			if( rowsLeft == 0 && extraPix == 0 )
			{
				int nRd;
				move2Col(  flags, dstBase, (column & ~1), dstTop+rowsWritten, high-rowsWritten, tileP, mdmaP, 0 );
				++column;
				rowsLeft = high;
				rowsWritten = 0;
				extraPix = excess;
				outP = (uint16*)tileP;
				nRd = MIN( kMaxLongs<<1, high );
				move2Col(  flags, dstBase, (column & ~1), dstTop, nRd, tileP, mdmaP, kSysReadFlag );
			}
			goto NextByte;
		}
	}
nextGlyph:
	widthSoFar = column - dstLeft;
	if( ++nGlyphsFinished < numGlyphs ) goto newGlyph;
	return eFinished;
}
#undef GDSIZE
		
