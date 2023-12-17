
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/



/* BiCopy.c
 * rwb 6/4/95
 */
 
 /* This version of copy copies a pixel rectangle from SysRam to SDRam.  It
 does color space conversion and bilinear scaling.  It operates by dividing the
 rectangle into tiles that can be individually scaled without affecting the values 
 of any pixels outside the tile.
 	Because a copy can take a long time, and this function may need to 
 share an MPE with other functions with real time requirements, the function is
 written to do only a single tile at a time.  When the function finishes the tile,
 it writes the current status to the parameter block and returns to the event loop.
 The dispatcher may immediately recall this function, if no other messages are
 waiting to be processed.
  	The Destination Pixel Type can not be CLUT based.
 	The source rectangle is assumed to be a piece of a large source pixmap
 described by a memory base and a width.  Likewise, the dest rectangle is assumed
 to be a piece of a large dest pixmap described by a base address and a width.  The
 base address of the dest pixmap must be a multiple of 512.

11/23/98 rwb - Modify to pay attention to transparent source pixels.
If a source pixel has an alpha value of 0xFF, then a dest pixel value is calculated
using the already existing dest pixel, rather than the source pixel.  1RGB pixels
are converted to 888Alpha pixels with an alpha value of 0xFF if the msb is set.

 
 Needs testing for sources that start on odd-byte boundaries
 */

#include "../../nuon/mml2d.h"
#include "pixmacro.h"
#include "parblock.h"
#include "mrpproto.h"

 
 mrpStatus BiCopy(int environs, BiCopyParamBlock* parBlockP, int arg2, int arg3 ) 
 {
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	BiCopyParamBlock* par;
 	uint8* tileBase;
 	int* endP;
 	indexBlock indexIn, indexOut;
 	mrpStatus stat;
 	
 	int tileWideBytes, readParBlockQ;
 	int inControlPixWide, outControlPixWide, dstPixShift, parSizeLongs;
	int transFrameQ, pixType, transVidQ;
	int select, dstType, transColor;

	int srcDataType[] = {0,1,2,3,4,5,6,2,2,2};

 	/* Set up local dtram & read in parameter block */
 	parSizeLongs = (sizeof(BiCopyParamBlock)+3)>>2;
 	readParBlockQ = mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&par, &tileBase, &endP );
 	if( readParBlockQ )
  		mrpSysRamMove( parSizeLongs, (char*)par, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
  	else par = parBlockP;
/* Hack to fix dstBase in SDRAM change */
#ifdef BB
	_SetLocalVar( par->dstBase , kGraphicsBase );
#endif
  	pixType = _GetLocal(par->srcPixType) & 0xFF;
  	transFrameQ = _GetLocal(par->srcPixType) & kTransparent;
  	transVidQ = _GetLocal(par->srcPixType) & kTransBB;
  	if( pixType == 9 ) transFrameQ = 0;
  	if( pixType != 8 && pixType != 9 ) transVidQ = 0;
  	
 	dstPixShift = 2; /* always 2 regardless of destPixType -- this is for DTRAM which is always 32bit */ 
 	tileWideBytes = _GetLocal(par->tileWidePix) << 2;
 	inControlPixWide = tileWideBytes >> _GetLocal(par->srcPixShift);
 	outControlPixWide = tileWideBytes >> dstPixShift;
 	transColor = (int)_GetLocal(par->clutBase);  /* use depends on srctype */	
 	indexIn.clutBase = (int*)_GetLocal(par->clutBase);
 	indexIn.pixBase = (int*)tileBase;
 	indexIn.control = srcDataType[pixType]<<20 | inControlPixWide | kChNorm;
 	indexOut.pixBase = (int*)tileBase;

	dstType = ( _GetLocal(par->dstPixType) & 0xF0 ) >>4;
#if 1
        if (dstType == 5 || dstType > 8) {
            // want 16bpp + 16 bit Z in DTRAM
            indexOut.control = e655Z << 20 | outControlPixWide | kChNorm  ;
        } else {
            indexOut.control = e888Alpha << 20 | outControlPixWide | kChNorm  ; /* In DTRAM, pixtype is always 888Alpha */
        }
#else
            indexOut.control = e888Alpha << 20 | outControlPixWide | kChNorm  ; /* In DTRAM, pixtype is always 888Alpha */
#endif
	SetMpeCtrl( linpixctl, kChNorm|(e888Alpha<<20) )
	
	select = 0;
/* dstType is a mess because of a mistake in bbird.h in defining 
TRANSFER
*/
	if( dstType == eRGBAlpha1555 ) select = 0x10;
	else if( dstType == e888Alpha ) select = 0x20;
	if( pixType == eClut8 ) select |= 0x800;
	else if( pixType == e888Alpha ) select |= 0x400;
	else if( pixType == eRGBAlpha1555 ) select |= 0x200;
	else if( pixType == eRGB0555 ) select |= 0x100;
	if( transVidQ != 0 ) select |= 2;
	else if( transFrameQ != 0 ) select |= 1;
	if( (_GetLocal(par->hNum) != _GetLocal(par->hDen) ) || (_GetLocal(par->vNum) != _GetLocal(par->vDen) ) )
		select |= 4;
	switch (select )
	{
	/* maui conditions */
		case 0x810:
			stat = copUnsClut16No( par, &indexIn, &indexOut, odmaP, mdmaP, transVidQ, transFrameQ );
			break;
		case 0x110:
			stat = copUns0RGB16Vid( par, &indexIn, &indexOut, odmaP, mdmaP, 0x8000 );
			 break;
		case 0x112:
			stat = copUns0RGB16Vid( par, &indexIn, &indexOut, odmaP, mdmaP, transColor );
			break;		
		case 0x212:
			stat = copUns1RGB16Vid( par, &indexIn, &indexOut, odmaP, mdmaP, transVidQ, transFrameQ );
			break;		
		default:
			stat = copDefault( par, &indexIn, &indexOut, odmaP, mdmaP, transVidQ, transFrameQ, transColor );
	}
	MRP_DmaWait( kmdmactl );
	return stat;
}
