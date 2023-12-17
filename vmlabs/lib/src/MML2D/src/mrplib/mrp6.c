
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 6/5/98
 * MRP functions that reserve v6
 */

#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
Reserve( 24, 25, 26, 27 )

/* Read or Write to SysRam.
Both internAdr and srcAdr must be scalar (32bit) aligned.
Because it is convenient for clients to sometims do a "move" of 0 scalars,
a value of 0 is allowed.  This is a nop, except that it waits for prior dma finishes.
If waitQ == 1, wait for dma finish prior to returning, else return immediately,
allowing double buffering.
Set readQ to 1 to move from SysRam to DTRam, else move from DTRam to Sysram.
*/
void mrpSysRamMove( int numScalars,  char* internAdr, char* srcAdr,  odmaCmdBlock* odmaP,
	 int readQ, int waitQ )
{

	MRP_DmaWait( kodmactl );
	if( numScalars <= 0 ) return;
	SL( odmaP->flags,  readQ | (numScalars << 16) );
	SL( odmaP->sysAdr, srcAdr    );
	SL( odmaP->dramAdr, internAdr    );
	MRP_DmaDo( kodmactl, odmaP, 1 );
}	

/* Write a tile to SDRAM.
Does a bilinear write of a (partial)tile from MPE DRAM into an SDRAM pixmap
at position dTop, dLeft.  
Assumes there is a global variable mdmaFlags that is the beginning
of a 4 scalar block whose address can be stuffed into mdmacptr.
Assumes that one row of pixels can be written with a single dma.
rwb 9/21 - make dstType carry type & cluster info already shifted.
*/
void DmaWriteBlock
(
	char*			tileBase,
	int				blockWidthBytes,
	int				nRows,
	int				numPixels, 
 	char*			screenBase,
	int				screenStridePix,
	int				dLeft,
	int				dTop,
	int				dstType,
 	mdmaCmdBlock*	mdmaP
)
{
	int yDesc;

	if (numPixels == 0)
	{
		return;
	}

	yDesc = dTop;
	MRP_DmaWait( kmdmactl );	
	_SetLocalVar( mdmaP->flags,    ((screenStridePix>>3)<<16) | kPixWrite | dstType );
	_SetLocalVar( mdmaP->xDesc,    (numPixels<<16) | dLeft                          );
	_SetLocalVar( mdmaP->yDesc,    (1<<16) | yDesc                                  );
	_SetLocalVar( mdmaP->sdramAdr, screenBase                                       );
	do
	{
		_SetLocalVar( mdmaP->dramAdr,  tileBase );
		MRP_DmaDo( kmdmactl, mdmaP, 1 );
		yDesc++;
		_SetLocalVar( mdmaP->yDesc, (1<<16) | yDesc);
		tileBase += blockWidthBytes;
	} while (--nRows > 0);
}

/* 
Replicate the last pixel in row n times at end of row.
This is used to fill out a partial tile.
rwb 7/29/99 - bugfix to also move alpha component
*/
void RepeatPixels( indexBlock* rBlockP, int xLast, int numPix )
{
	Push( v6 )
	SetIndex( xybase, xyctl, rx, ry, rBlockP->pixBase, rBlockP->control, xLast, rBlockP->yIndex )
	GetDRamAlphaPP( v6, xy, rx );
	do{
		PutDRamAlphaPP( v6, xy, rx )
	}while(--numPix > 0 );
	Pop( v6 )
}

/* Replicate the bottomRow, numRows times.
rwb 7/29/99 - bugfix to also move alpha component
*/
void RepeatRows( indexBlock* rBlockP, int bottomRow, int pixPerRow, int numRows )
{
	void *nextRowP;

	Push( v6 )
	nextRowP = &&nextRow;
	SetIndex( xybase, xyctl, rx, ry, rBlockP->pixBase, rBlockP->control, rBlockP->xIndex, bottomRow )
	SetIndex( uvbase, uvctl, ru, rv, rBlockP->pixBase, rBlockP->control, rBlockP->xIndex, (bottomRow+1) )

	while(pixPerRow-- > 0)
	{
		GetDRamAlphaPP( v6, xy, rx )
		SetMpeCtrl( rv, (bottomRow+1) << 16)
		Loop( rc0, numRows )
	nextRow:	 PutDRamAlphaPPDec( v6, uv, rv, rc0 );
		Repeat( c0, nextRowP )
		IncIndex( ru )
	}	
	Pop( v6 )	
}

/* MoveTileRow
Move num pixels in block from srcBeg to dstBeg.
Row is specified in Block object
pixels are format 4 in dtram tile block.
rwb 7/29/99 - bugfix to also move alpha component
*/
void MoveTileRow( indexBlock* rBlockP, int srcBeg, int dstBeg, int num )
{
	void* againP = &&again;

	if( srcBeg == dstBeg || num == 0 ) return;
	SetIndex(xybase,xyctl,rx,ry,rBlockP->pixBase, rBlockP->control, srcBeg, rBlockP->yIndex )
	SetIndex(uvbase,uvctl,ru,rv,rBlockP->pixBase, rBlockP->control, dstBeg, rBlockP->yIndex )
	Push( v6 )
	Loop( rc0, num )
again:
	GetDRamAlphaPP( v6, xy, rx )
	PutDRamAlphaPPDec( v6, uv, ru, rc0)
	Repeat( c0, againP )
	Pop( v6 )
}

/* MoveTileCol
Move num pixels in block from srcBeg to dstBeg.
Column is specified in Block object
pixels are format 4 in dtram tile block.
rwb 7/29/99 - bugfix to also move alpha component
*/
void MoveTileCol( indexBlock* rBlockP, int srcBeg, int dstBeg, int num )
{
	void* againP = &&again;

	if( srcBeg == dstBeg || num == 0 ) return;
	SetIndex(xybase,xyctl,rx,ry,rBlockP->pixBase, rBlockP->control, rBlockP->xIndex, srcBeg )
	SetIndex(uvbase,uvctl,ru,rv,rBlockP->pixBase, rBlockP->control, rBlockP->xIndex, dstBeg )
	Push( v6 )
	Loop( rc0, num )
again:
	GetDRamAlphaPP( v6, xy, ry )
	PutDRamAlphaPPDec( v6, uv, rv, rc0)
	Repeat( c0, againP )
	Pop( v6 )
}
