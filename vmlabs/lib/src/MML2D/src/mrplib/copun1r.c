
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* Copy Inner Loops
 * rwb 2/8/99
 * Unscaled Case: Requires hnum = hden = vnum = vden = 1
 *	Also does not do clipping.  Assumes destWide = srcWide, etc.
 * RGB1555 Video Transparency Flag is set. If msb is 1, set pixel to 0,0,0
 */
#include "pixmacro.h"
/* Ideally, the ColCvrt1RGB16 function would be inline.  But it uses
vectors v2 ... v6 and Reserving all those registers leaves too few
registers for the compiler resulting in very slow code.  We can not 
create an inline asm function, so this is the best compromise for now.
*/
 Reserve(24, 25, 26, 27 )
#include "parblock.h"
#include "mrpproto.h"

#include "mrp6in.c"
/* Copy unscaled from RGB source to 16bit YCC; Vid flag set */
mrpStatus copUns1RGB16Vid(BiCopyParamBlock* par, indexBlock* indexInP, indexBlock* indexOutP,
	odmaCmdBlock* odmaP, mdmaCmdBlock* mdmaP, int transVidQ,  int transFrameQ )
{
 	int  srcLeftStartByte, offsetBytes, offsetPix, tileWideBytes;
	int nRowsIn, nColsIn, nRowsOut, nColsOut, extraCols, nRows; 
	int nPixIn, nBytesIn, nLongsIn, endPix, tilePosition, srcLeftPix, srcTopPix;
	int rowsRead, rowsFinished;
	int top, left;
	char *srcBytePtr, *srcPtr, *inPtr;

	Push( v6 )
 	nRowsIn  = _GetLocal(par->nBlocksHigh) * _GetLocal(par->vDen);
 	nColsIn  = _GetLocal(par->nBlocksWide) * _GetLocal(par->hDen);
 	nRowsOut = _GetLocal(par->nBlocksHigh) * _GetLocal(par->vNum);
 	nColsOut = _GetLocal(par->nBlocksWide) * _GetLocal(par->hNum);
 	tileWideBytes = _GetLocal(par->tileWidePix) << 2;
nextTurn:	
 	extraCols = 0;
 	if( _GetLocal(par->nSwathsFinished) == _GetLocal(par->nTilesWide) - 1 )
 		extraCols = _GetLocal(par->nTilesWide) * nColsIn - _GetLocal(par->srcWidePix);
 	srcLeftPix 	= _GetLocal(par->srcLeftStartPix) + _GetLocal(par->nSwathsFinished) * nColsIn;
 	srcLeftStartByte = srcLeftPix << _GetLocal(par->srcPixShift);	
 	tilePosition = _GetLocal(par->nTilesFinished) - _GetLocal(par->nSwathsFinished) * _GetLocal(par->nTilesHigh);
 	srcTopPix   = _GetLocal(par->srcTopStartPix) + tilePosition * nRowsIn;
 	srcBytePtr  = (char*)(_GetLocal(par->srcBase) + srcTopPix * _GetLocal(par->srcStrideBytes) + srcLeftStartByte);
 	srcPtr        = (char*)((int)srcBytePtr & ~3);
 	offsetBytes	= srcBytePtr - srcPtr;
 	offsetPix	= offsetBytes >> _GetLocal(par->srcPixShift);
	
 	nPixIn 	= nColsIn - extraCols;
	nBytesIn 	= (nPixIn << _GetLocal(par->srcPixShift)) + offsetBytes;
	nLongsIn 	= (nBytesIn+3) >> 2;
	endPix     	= _GetLocal(par->tileWidePix)-extraCols-1;
		 	
	indexInP->yIndex = indexOutP->yIndex = _GetLocal(par->tileHighPix) - nRowsIn;
 	inPtr = indexInP->pixBase + indexInP->yIndex * tileWideBytes;
	top = _GetLocal(par->dstTop) + tilePosition * _GetLocal(par->nBlocksHigh);
	left = _GetLocal(par->dstLeft) + _GetLocal(par->nSwathsFinished) * _GetLocal(par->nBlocksWide);
 	nRows = nRowsIn < _GetLocal(par->srcHighPix) ? nRowsIn : _GetLocal(par->srcHighPix);
 	if( tilePosition == _GetLocal(par->nTilesHigh) - 1 )
 		nRows = _GetLocal(par->srcHighPix) - tilePosition * nRowsIn;
	rowsRead = 0;
	rowsFinished = 0;
 	do{
	 	if( rowsRead < nRows )
	 	{
	 		mrpSysRamMoveI( nLongsIn, inPtr, srcPtr, odmaP, kSysReadFlag, 0 );  
	 		srcPtr += _GetLocal(par->srcStrideBytes);
	 		inPtr += tileWideBytes;
	 		++rowsRead;
	 	}
	 	if( rowsFinished == nRows-1 ) MRP_DmaWait( kodmactl );
	 	if( rowsRead > 1 || nRows == 1 )
	 	{
		 	ColCvrt1RGB16( indexInP, indexOutP, nPixIn, nPixIn+offsetPix-1, endPix, transVidQ  );
		 	MoveTileRowI( indexOutP, endPix-nPixIn+1, 0, nPixIn );
		 	DmaWriteRowI( indexOutP->pixBase+rowsFinished*tileWideBytes, nPixIn, (char*)_GetLocal(par->dstBase),
			 	 _GetLocal(par->dstStridePix),  left, top, _GetLocal(par->dstPixType), mdmaP );
			++indexOutP->yIndex;
			++indexInP->yIndex;
			++top;
			++rowsFinished;
		}
 	} while( rowsFinished < nRows ); 	
 	if( tilePosition == _GetLocal(par->nTilesHigh) - 1) _SetLocalVar(par->nSwathsFinished, _GetLocal(par->nSwathsFinished)+1 ) ;
 	_SetLocalVar(par->nTilesFinished, _GetLocal(par->nTilesFinished)+1);
 	if( _GetLocal(par->nTilesFinished) < _GetLocal(par->nTilesTotal) ) goto nextTurn;
	Pop( v6 )
 	return eFinished;
 }
