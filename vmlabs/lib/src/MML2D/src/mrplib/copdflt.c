
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
 */

#include "../../nuon/mml2d.h"
#include "pixmacro.h"
#include "parblock.h"
#include "mrpproto.h"

/* Slo..ow Default Copy from any source to 16bit YCC
   transVidQ is true, if pixType rgb0555 or rgb1555 pixtypes are to honor video transparency
   transFrameQ is true if pixType clut or 32bit are to honor framebuf transparency
   if transVidQ is true, transFrameQ is false.
   transVidQ is ignored in the case of scaling.
 */
mrpStatus copDefault(BiCopyParamBlock* par, indexBlock* indexInP, indexBlock* indexOutP,
	odmaCmdBlock* odmaP, mdmaCmdBlock* mdmaP, int transVidQ,  int transFrameQ, int transColor )
{
 	int  srcLeftStartByte, offsetBytes, offsetPix, tileWideBytes;
	int nRowsIn, nColsIn, nRowsOut, nColsOut, extraCols, nRows; 
	int nPixIn, nBytesIn, nLongsIn, endPix, tilePosition, srcLeftPix, srcTopPix;
	int rowsRead, rowsFinished;
	int left, nc, extraRows, pixType, nCols;
	uint8 *srcBytePtr, *srcPtr, *inPtr;

 	nRowsIn  = _GetLocal( par->nBlocksHigh ) * _GetLocal( par->vDen );
 	nColsIn  = _GetLocal( par->nBlocksWide ) * _GetLocal( par->hDen );
 	nRowsOut = _GetLocal( par->nBlocksHigh ) * _GetLocal( par->vNum );
 	nColsOut = _GetLocal( par->nBlocksWide ) * _GetLocal( par->hNum );
 	tileWideBytes = _GetLocal( par->tileWidePix ) << 2;
 	extraRows = _GetLocal( par->nTilesHigh ) * nRowsIn - _GetLocal( par->srcHighPix );
 	pixType = _GetLocal( par->srcPixType ) & 0xFF;
 	if( (_GetLocal( par->hNum ) != _GetLocal( par->hDen ) ) ||
 		(_GetLocal( par->vNum ) != _GetLocal( par->vDen ) ) ) transVidQ = 0;
nextTurn:	
 	extraCols = 0;
 	if( _GetLocal( par->nSwathsFinished ) == _GetLocal( par->nTilesWide ) - 1 )
 		extraCols = _GetLocal( par->nTilesWide ) * nColsIn - _GetLocal( par->srcWidePix );
 	srcLeftPix 	= _GetLocal( par->srcLeftStartPix ) + _GetLocal( par->nSwathsFinished ) * nColsIn;
 	srcLeftStartByte = srcLeftPix << _GetLocal( par->srcPixShift );	
 	tilePosition = _GetLocal( par->nTilesFinished ) - _GetLocal( par->nSwathsFinished )
 		 * _GetLocal( par->nTilesHigh );
 	srcTopPix   = _GetLocal( par->srcTopStartPix ) + tilePosition * nRowsIn;
 	srcBytePtr  = (char*)_GetLocal( par->srcBase ) + srcTopPix * _GetLocal( par->srcStrideBytes )
 		 + srcLeftStartByte;
 	srcPtr        = (char*)((int)srcBytePtr & ~3);
 	offsetBytes	= srcBytePtr - srcPtr;
 	offsetPix	= offsetBytes >> _GetLocal( par->srcPixShift );
	
 	nPixIn 	= nColsIn - extraCols;
	nBytesIn 	= (nPixIn << _GetLocal( par->srcPixShift )) + offsetBytes;
	nLongsIn 	= (nBytesIn+3) >> 2;
	endPix     	= _GetLocal( par->tileWidePix ) -extraCols-1;
		 	
	indexInP->yIndex = indexOutP->yIndex = _GetLocal( par->tileHighPix ) - nRowsIn;
 	inPtr = indexInP->pixBase + indexInP->yIndex * tileWideBytes;
	left = _GetLocal( par->dstLeft ) + _GetLocal( par->nSwathsFinished )
		 * _GetLocal( par->nBlocksWide );
	nc = _GetLocal( par->nBlocksWide );
	if( _GetLocal( par->nSwathsFinished ) == _GetLocal( par->nTilesWide ) - 1 )
	{
		int temp = _GetLocal( par->dstWidePix ) - (_GetLocal( par->nTilesWide )-1) * nc;
		nc = temp < nc ? temp : nc;
	}
 	nRows = nRowsIn < _GetLocal( par->srcHighPix ) ? nRowsIn : _GetLocal( par->srcHighPix );
 	if( tilePosition == _GetLocal( par->nTilesHigh ) - 1 && extraRows > 0 )
 	{
 		nRows -= extraRows;
 	}
	rowsRead = 0;
	rowsFinished = 0;

 	do{
readagain:
	 	if( rowsRead < nRows )
	 	{
	 		mrpSysRamMove( nLongsIn, inPtr, srcPtr, odmaP, kSysReadFlag, 0 );  
	 		srcPtr += _GetLocal( par->srcStrideBytes );
	 		inPtr += tileWideBytes;
	 		++rowsRead;
	 	}
		else
		{
			MRP_DmaWait( kodmactl );
		}
	 	if( rowsRead == 1 )
	 	{
	 		if( nRows != 1 ) goto readagain;
			else
			{
				MRP_DmaWait( kodmactl );		
			}
	 	}
	 	if( transVidQ !=0 && pixType == eRGBAlpha1555 )
	 		ColCvrt1RGB16( indexInP, indexOutP, nPixIn, nPixIn+offsetPix-1, endPix , transVidQ ); 
	 	else if( transVidQ !=0 && pixType == eRGB0555 )
	 		ColCvrt0RGB16( indexInP, indexOutP, nPixIn, nPixIn+offsetPix-1, endPix , transColor ); 	 		
	 	else if( transFrameQ == 0 )
	 		ColorCvrt( indexInP, indexOutP, nPixIn, nPixIn+offsetPix-1, endPix , pixType );
	 	else
	 		ColorCvrtTrans( indexInP, indexOutP, nPixIn, nPixIn+offsetPix-1, endPix , pixType );
	 	if( extraCols > 0 ) RepeatPixels( indexOutP, endPix, extraCols );
	 	if( (_GetLocal( par->hNum ) == _GetLocal( par->hDen ) && transFrameQ == 0) || transVidQ != 0 )
	 		MoveTileRow( indexOutP, endPix-nPixIn+1, 0, nColsIn );
	 	else if( transFrameQ == 0 )
	 		ScaleTileRow( indexOutP, endPix-nPixIn+1, 0, _GetLocal( par->hNum), _GetLocal( par->hDen),
	 			 _GetLocal( par->recipH ), _GetLocal( par->nBlocksWide) ); 
	 	else
	 		ScaleTileRowTrans( indexOutP, endPix-nPixIn+1, 0, _GetLocal( par->hNum),
	 			_GetLocal( par->hDen ), _GetLocal( par->recipH), _GetLocal( par->nBlocksWide),
	 			_GetLocal( par->tileHighPix), (void*) _GetLocal( par->dstBase),
	 			((_GetLocal( par->dstStridePix)>>3)<<16) | kPixRead | _GetLocal( par->dstPixType),
	 			(nColsOut<<16) | (_GetLocal( par->dstLeft) + _GetLocal( par->nSwathsFinished) * nColsOut),
	 			(1<<16) | (_GetLocal( par->dstTop) + tilePosition * nRowsOut), mdmaP );
		++indexOutP->yIndex;
		++indexInP->yIndex;
 	} while( ++rowsFinished < nRows );
 
  	if( tilePosition == _GetLocal( par->nTilesHigh ) - 1 && extraRows > 0 )
 	{
 		indexOutP->xIndex = 0;
 		RepeatRows( indexOutP, nRowsIn-extraRows-1, nColsOut, extraRows );
 	}
 	nCols = nColsOut < _GetLocal( par->dstWidePix ) ? nColsOut : _GetLocal( par->dstWidePix );
 	indexOutP->xIndex = 0;
 	if( (_GetLocal( par->vNum) != _GetLocal( par->vDen)) && ( transVidQ == 0 ) )
 	do{
 		ScaleTileCol( indexOutP, _GetLocal( par->tileHighPix) - nRowsIn, 0, _GetLocal( par->vNum),
 		_GetLocal( par->vDen), _GetLocal( par->recipV), _GetLocal( par->nBlocksHigh) );
		++indexOutP->xIndex;
 	}while( --nCols > 0 );

 	{
 		int nr, nc, top, left;
 		
 		top = _GetLocal( par->dstTop) + tilePosition * nRowsOut;
 		left = _GetLocal( par->dstLeft) + _GetLocal( par->nSwathsFinished ) * nColsOut;
 		nr = nRowsOut;
 		if(tilePosition == _GetLocal( par->nTilesHigh ) - 1)
 		{
 			int temp = _GetLocal( par->dstHighPix ) - (_GetLocal( par->nTilesHigh ) -1) * nr;
 			nr = temp < nr ? temp : nr;
 		}
 		nc = nColsOut;
 		if( _GetLocal( par->nSwathsFinished ) == _GetLocal( par->nTilesWide ) - 1 )
 		{
 			int temp = _GetLocal( par->dstWidePix ) - (_GetLocal( par->nTilesWide ) -1) * nc;
 			nc = temp < nc ? temp : nc;
 		}
	 	DmaWriteBlock( indexOutP->pixBase, tileWideBytes, nr, nc, (char*)_GetLocal( par->dstBase),
		 	 _GetLocal( par->dstStridePix),  left, top, _GetLocal( par->dstPixType), mdmaP );
 	 }
	
 	if( tilePosition == _GetLocal( par->nTilesHigh ) - 1)
 		_SetLocalVar( par->nSwathsFinished, _GetLocal( par->nSwathsFinished) + 1);
 	_SetLocalVar( par->nTilesFinished, _GetLocal( par->nTilesFinished) + 1);
 	if( _GetLocal( par->nTilesFinished ) < _GetLocal( par->nTilesTotal) ) goto nextTurn;

 	return eFinished;
 }
