
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Public 2D API Initializers
 * rwb 3/21/97
 * mod 10/1/97
 */

/* Initializer and setter functions. Initializers accept arguments for
most common fields and attempt to set other fields to acceptable
values. Very simple objects such as points may have only a general setter
and not an initializer. Functions return a pointer to the object being
initialized, so that functions can chained;
 e.g. transform( SetPoint(&pt, x, y, z ), ScaleMatrix( &mat, sx, sy, sz ) ).
At least some initializers need to return mmlStatus, because they could fail.
*/
#include "m2config.h"
#include "../../nuon/mml2d.h"
#include "../../nuon/mrpcodes.h"
#include "../mrplib/parblock.h"
#include <nuon/comm.h>
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <assert.h>

// variables which hold location and size of a variable in
// local dtram which we can use for DMA
void *_localRamPtr = 0;
int _localRamSize;

extern void _DCacheSync();

m2dPoint m2dSetPoint( uint16 x, uint16 y )
{
    m2dPoint pt;
    pt.x = x;
    pt.y = y;
    return pt;
}

m2dRect* m2dSetRect( m2dRect* rP, uint16 left, uint16 top, uint16 right, uint16 bottom )
{
	rP->leftTop.x = left;
	rP->leftTop.y = top;
	rP->rightBot.x = right;
	rP->rightBot.y = bottom;
	return rP;
}

void mmlInitGC( mmlGC* gcP, mmlSysResources* srP )
{
    assert( gcP != NULL );
	gcP->sysResP		= srP;
	gcP->z				= 0;
    gcP->alpha			= kOpaque;
    gcP->foreColor		= kBlack;
    gcP->backColor		= kWhite;
    gcP->clutForeIndex	= kBlackIndex;
    gcP->clutBackIndex	= kWhiteIndex;
    gcP->nClutAlpha		= kStandardReserve;
    gcP->drawOp			= eSrcCopy;
    gcP->zCompare		= eZnone;
	gcP->fixAspect		= eFalse;
	gcP->transparentSource = eFalse;
	gcP->transparentOverlay = eFalse;
	gcP->rgbTransparentValue = 0;
    gcP->disCopyBlend = 0;
	gcP->fontContextP = NULL;
	gcP->err = eOK;

	// LineStyle:
    gcP->defaultLS.lineKind	= eLine3;
    gcP->defaultLS.foreColor	= kBlack;
    gcP->defaultLS.foreColor2	= kBlack;
	gcP->defaultLS.colorBlend1	= 0x3f;
	gcP->defaultLS.colorBlend2	= 0;

    gcP->defaultLS.alpha	= 0x0;
    gcP->defaultLS.thick	= kThin;

    gcP->defaultLS.lineRandNum[0]	= 0x2574bea7;
    gcP->defaultLS.lineRandNum[1]	= 0xa3000000;
    gcP->defaultLS.lineRandNum[2]	= 0x83659328;
    gcP->defaultLS.lineRandNum[3]	= 0xa3000000;

	// EllipseStyle:
	gcP->defaultES.width = 0xe000; // 0x0800 is very thin line.  0xe000 is fat line.
	gcP->defaultES.foreColor = kBlack;
//	gcP->defaultES.foreColor2 = kBlack;
    gcP->defaultES.xScale = 0x0100;
    gcP->defaultES.yScale = 0x0100;
	gcP->defaultES.alpha = 0x0;
	gcP->defaultES.fill = 1;
	gcP->textBase = 0;
	gcP->textDiv = 16;
	gcP->textMax = 3;
	gcP->textMin = 0;
	gcP->textWidthScale = 0x10000;
	gcP->translucentText = 0;
	gcP->sequence = NULL;
}

/* Fill a rectangle in a display pixmap with a color.
 * If rect is NULL, cover entire pixmap.
 * OBSOLETE INTERFACE
 * NOTE: use FillColr for new applications
 */
void m2dFillOpaq( mmlGC* gcP, mmlDisplayPixmap* destP, m2dRect* rP, mmlColor color )
{
    m2dFillColor(gcP, destP, rP, color);
}

/* Fill a rectangle in an 8 bit display pixmap with a color.
  * If rect is NULL, cover entire pixmap.
  * boundaries can be on odd pixels.
  * color should be an 8 bit index repeated 4 times in a long.
  */
void m2dFillClut( mmlGC* gcP, mmlDisplayPixmap* destP, m2dRect* rP, mmlColor color )
{
	m2dRect s;
	FillClutParamBlock* parP = malloc( sizeof(FillClutParamBlock) );
	assert( parP != NULL );
	assert( gcP != NULL && destP != NULL );
	if( rP == NULL )
	{
		s.leftTop.x = 0;
		s.leftTop.y = 0;
		s.rightBot.x = destP->wide-1;
		s.rightBot.y = destP->high-1;
		rP = &s;
	}
	assert( rP->rightBot.x >= rP->leftTop.x );
	assert( rP->rightBot.y >= rP->leftTop.y );
	parP->destBufferAdr = destP->memP;
	parP->destFlags = ( destP->dmaFlags & 0xFF08F0 ) | ePixDma;
	parP->destLeftCol = rP->leftTop.x;
	parP->destTopRow = rP->leftTop.y;
	parP->rowLength = rP->rightBot.x - rP->leftTop.x + 1;
	parP->numRows = rP->rightBot.y - rP->leftTop.y + 1;
	parP->fillData = color; 
	mmlExecutePrimitive( gcP, eFillClut, parP, sizeof(FillClutParamBlock), 0, 0);
}

/* Fill a rectangle in a display pixmap with an opaque color.
 * If rect is NULL, cover entire pixmap.
 * width and height of rectangle must be greater than zero
 */
 #define kMinTransfer  128
// Eric Smith's new code:
void m2dFillColor( mmlGC* gcP, mmlDisplayPixmap* destP, m2dRect* rP, mmlColor color )
{
	m2dRect s;
	int wide;
	int pixtype;
	SdramFillParamBlock* parP = malloc( sizeof(SdramFillParamBlock) );
	assert( parP != NULL );
	assert( gcP != NULL && destP != NULL );
	parP->debug = 0xdcba;
	parP->numRowsFinished = 0;
	if( rP == NULL )
	{
		s.leftTop.x = 0;
		s.leftTop.y = 0;
		s.rightBot.x = destP->wide-1;
		s.rightBot.y = destP->high-1;
		rP = &s;
	}
	wide = rP->rightBot.x - rP->leftTop.x + 1;
	assert( wide > 0 );
	assert( rP->rightBot.y >= rP->leftTop.y );
	parP->flags = ( destP->dmaFlags & 0xFF08F0 ) | eDup | ePixDma;
	if( gcP->transparentOverlay ) parP->flags |= kTransBB;
// if pixmap is of type e655, change dmaFlag type from 2 to 8
	pixtype = (parP->flags & 0xF0) >> 4;
	if( pixtype == 0x2 )
	{
		parP->flags ^= 0x20;
		parP->flags |= 0x80;
	}
// otherwise, if we have an e655Z mode, change the pixel color
	else if (pixtype == 0x5 || (pixtype > 6)) {
	    int y, cr, cb;
	    y = ((color >> 24) & 0xff) >>2;
	    cr = ((color >> 16) & 0xff) >> 3;
	    cb = ((color >> 8) & 0xff) >> 3;
	    color = (y << 26) | (cr << 21) | (cb << 16) | (gcP->z >> 16U);
	}
	parP->base	= destP->memP;
	parP->fillTop = rP->leftTop.y;
	parP->xDesc	= ( wide << 16) | rP->leftTop.x ;
	parP->numRowsTotal	= rP->rightBot.y - rP->leftTop.y + 1;
	if( wide > kMinTransfer ) parP->numRowsPerTurn = 1;
	else parP->numRowsPerTurn = kMinTransfer/wide;
	parP->value	= color;
	mmlExecutePrimitive( gcP, eSdramFill, parP, sizeof(SdramFillParamBlock), 0, 0);

#if 0
/* if pixmap is of type e888AlphaZ, make another call to clear the Z buffer
 * (the smaller pixel types were already handled correctly, but this one
 * requires special handling because it's a 64 bit pixel mode)
 */
	if ( pixtype == 0x6 ) {
	    parP->flags |= 0x70;  /* set to "write Z value" */
	    parP->value = gcP->z;     /* Z value to fill with */
	    mmlExecutePrimitive( gcP, eSdramFill, parP, sizeof(SdramFillParamBlock), 0, 0);
	}
#endif

}


/* Use this function to do sraight copies with no color conversion,
no scaling, and very limited format translation.
    src and dest columns must begin on long boundaries
    and width of copy must be a multiple of 4 bytes
but eRGB0555 to e655 and e888Alpha is available without alignment requirements     
*/
void m2dCopyRectFast( mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint dpt )
{
	int shft[] = {1, 3, 1, 2, 0, 0, -1, 1, 1, 1, 0, 3, 2, 2, 2 };
	int flags = destP->dmaFlags & ~0x20F0;
	int srcFormat = (srcP->properties & 0xF0)>>4;
	CopyRectFastParamBlock* parP = malloc( sizeof(CopyRectFastParamBlock));
	assert (srcFormat == e655 || srcFormat == eClut8 || srcFormat == e888Alpha ||
		srcFormat == eRGB0555 );
	parP->srcBufferAdr = srcP->memP;
	parP->srcLeftCol = rP->leftTop.x;
	parP->srcTopRow = rP->leftTop.y;
	parP->destBufferAdr = destP->memP;
	if( (destP->properties & 0xF0) == 0x20  && (srcP->properties & 0xF0) != 0x20 )
		parP->destFlags = flags | 0x80;
	else
		parP->destFlags = flags | (destP->properties & 0xF0);	
	parP->destLeftCol = dpt.x;
	parP->destTopRow = dpt.y;
	parP->rowLength = rP->rightBot.x - rP->leftTop.x + 1;
	parP->numRows = rP->rightBot.y - rP->leftTop.y + 1;
	parP->srcPixShift = shft[srcFormat];
	parP->srcByteWidth = srcP->wide<<(2 - parP->srcPixShift) ;
	if( srcFormat == eRGB0555 ) 
		mmlExecutePrimitive( gcP, eCopyRGBFast, parP, sizeof(CopyRectFastParamBlock), 0, 0);	
	else
		mmlExecutePrimitive( gcP, eCopyRectFast, parP, sizeof(CopyRectFastParamBlock), 0, 0);	

}

/*
	rwb 7/10/01
	Straight copy of rect from 16 bit sysram pixmap to 16 bit sdram pixmap.
	No scaling, no color conversion.
	Any alignment is ok.
	Any rect size is ok.
	But Pixmaps should be long aligned and have a width that is a multiple of 4 bytes.
*/
void m2dCopyRect16( mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint dpt )
{
	int flags = destP->dmaFlags & ~0x20F0;
	int srcFormat = (srcP->properties & 0xF0)>>4;
	CopyRectFastParamBlock* parP = malloc( sizeof(CopyRectFastParamBlock));
	assert (srcFormat == e655 );
	parP->srcBufferAdr = srcP->memP;
	parP->srcLeftCol = rP->leftTop.x;
	parP->srcTopRow = rP->leftTop.y;
	parP->destBufferAdr = destP->memP;
	parP->destFlags = flags | (destP->properties & 0xF0);	
	parP->destLeftCol = dpt.x;
	parP->destTopRow = dpt.y;
	parP->rowLength = rP->rightBot.x - rP->leftTop.x + 1;
	parP->numRows = rP->rightBot.y - rP->leftTop.y + 1;
	parP->srcByteWidth = srcP->wide<<1;
	mmlExecutePrimitive( gcP, eCopyRect16, parP, sizeof(CopyRectFastParamBlock), 0, 0);	
}

/* Copy a rectangle from an application pixmap to an 8 bit Clut 
framebuffer in the OSD plane. 
If rect ptr is NULL, copy entire app pixmap.
	Version 1.
		Source must be 8 bit Clut.
		Copy is unscaled.
		No clipping, rect must fit in dest.
		Only do kMaxRowsPerBlock rows each primitive call. Based on size of graphics buffer.
*/	
#define kMaxRowsPerBlock 44	
void m2dCopyClutRect(mmlGC* gcP, mmlPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint pt )
{
	m2dRect s;
	m2dRect* sP = &s;
	int numRows, srcTop, dstTop;
	CopyClutParamBlock* parP;
	if( rP != NULL ) sP = rP;
	else
	{
		s.leftTop.x = 0;
		s.leftTop.y = 0;
		s.rightBot.x = srcP->wide-1;
		s.rightBot.y = srcP->high-1;
	}
	numRows = sP->rightBot.y - sP->leftTop.y + 1;
	srcTop = sP->leftTop.y;
	dstTop = pt.y;
	do{
		int cmd;
		parP = malloc( sizeof( CopyClutParamBlock ));
		assert( parP != NULL );
		parP->srcBufferAdr = srcP->memP;
		if( srcP->dmaFlags & ePixDma )
		{
			parP->srcByteWidth = srcP->dmaFlags;
			cmd = eCopySDClut;
		}
		else
		{	
			parP->srcByteWidth = srcP->wide;
			cmd = eCopyToClut;
		}
		parP->srcLeftCol = sP->leftTop.x;
		parP->srcTopRow = srcTop;
		parP->destBufferAdr = destP->memP;
		parP->destFlags = destP->dmaFlags;
		parP->destLeftCol = pt.x;
		parP->destTopRow = dstTop;
		parP->rowLength = sP->rightBot.x - sP->leftTop.x + 1;
		parP->numRows = numRows > kMaxRowsPerBlock ? kMaxRowsPerBlock : numRows;
		mmlExecutePrimitive( gcP, cmd, parP, sizeof(CopyClutParamBlock), 0, 0);
		numRows -= kMaxRowsPerBlock;
		srcTop += kMaxRowsPerBlock;
		dstTop += kMaxRowsPerBlock;
	} while( numRows > 0 );
}

/* Special form of copy, particularly for copying from decoded GIF arrays.
Convert & Copy a rect from an array of 8 bit index-color values to a position
	in a 16-bit or 32-bit display pixmap.
	Array width must be multiple of 4 pixels, but copied rectangle can be shorter.
	Pixels with transIndex value are not copied.
	A value of transIndex equal to 256 means all pixels are copied.
	clutP points to an array of 256 mmlColors.  clutP must be 1024 byte aligned,
	that is, bits 0-9 of the address must be 0.
*/
void m2dCopyTile8( mmlGC* gcP, mmlDisplayPixmap* destP, uint8* tileP, int left, int top, int pixWide, int pixHigh,
int rowPixStride, int xDest, int yDest, void* clutP, int transIndex )
{
	int wide, high;
	CopyTileParamBlock* parP = malloc( sizeof(CopyTileParamBlock) );
	wide = destP->wide - xDest + 1;
	if( wide > pixWide ) wide = pixWide;
	high = destP->high - yDest + 1;
	if( high > pixHigh ) high = pixHigh;
	parP->srcArrayAdr = tileP + top*rowPixStride + left;
	parP->srcPixStride = rowPixStride;
	parP->srcRectWide = wide;
	parP->srcRectHigh = high;
	if( transIndex == 256 )
		parP->clutAdrTrans = (int)clutP | 1;
	else
		parP->clutAdrTrans = (int)clutP | (transIndex<<2);
	parP->destAdr = destP->memP;
	parP->destFlags = destP->dmaFlags & 0xFFFFFF0F;
	if( (destP->dmaFlags & 0xF0 ) == 0x20 )
		parP->destFlags |= 0x80;				// cause 32 to 16 bit conversion
	else parP->destFlags |= (destP->dmaFlags & 0xF0);
	parP->destLeftCol = xDest;
	parP->destTopRow = yDest;
	mmlExecutePrimitive( gcP, eCopyTile8, parP, sizeof(CopyTileParamBlock), 0, 0);
}

/* 	Special form of copy. Like m2dCopyTile8 but transparency is not honored.
	Convert & Copy a rect from an array of 8 bit index-color values to a position
	in a 16-bit or 32-bit display pixmap. Note source is not pixmap.
	Array width must be multiple of 4 pixels, but copied rectangle can be shorter.
	clutP points to an array of 256 mmlColors.  clutP must be 1024 byte aligned,
	that is, bits 0-9 of the address must be 0.
*/
void m2dCopyTileAll( mmlGC* gcP, mmlDisplayPixmap* destP, uint8* tileP, int left, int top, int pixWide, int pixHigh,
int rowPixStride, int xDest, int yDest, void* clutP )
{
	int wide, high;
	CopyTileParamBlock* parP = malloc( sizeof(CopyTileParamBlock) );
	wide = destP->wide - xDest + 1;
	if( wide > pixWide ) wide = pixWide;
	high = destP->high - yDest + 1;
	if( high > pixHigh ) high = pixHigh;
	parP->srcArrayAdr = tileP + top*rowPixStride + left;
	parP->srcPixStride = rowPixStride;
	parP->srcRectWide = wide;
	parP->srcRectHigh = high;
	parP->clutAdrTrans = (int)clutP;
	parP->destAdr = destP->memP;
	parP->destFlags = destP->dmaFlags & 0xFFFFFF0F;
	if( (destP->dmaFlags & 0xF0 ) == 0x20 )
		parP->destFlags |= 0x80;				// cause 32 to 16 bit conversion
	else parP->destFlags |= (destP->dmaFlags & 0xF0);
	parP->destLeftCol = xDest;
	parP->destTopRow = yDest;
	mmlExecutePrimitive( gcP, eCopyTileAll, parP, sizeof(CopyTileParamBlock), 0, 0);
}

/* Copy a pixel rectangle from an application pixmap to a framebuffer
pixmap.  Do color conversion if necessary including clut expansion.
	appPixMap pixel format may be eGRB655 or eClut8
	framebuffer pixel format may be e888Alpha or e655
Do pixel resampling if gcP->fixAspect is set and source pixmap has square pixels.
If rect ptr is NULL, copy entire app pixmap.
4/30/99 rwb  quick hack to make copyrect work on more formats albeit more slowly than old asm version.
*/
void m2dCopyRect(mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint pt )
{
	int hnum, hden, vnum, vden;
	m2dRect clip;
	m2dRect s;
	m2dRect* sP = &s;
	if( rP != NULL ) sP = rP;
	else
	{
		s.leftTop.x = 0;
		s.leftTop.y = 0;
		s.rightBot.x = srcP->wide-1;
		s.rightBot.y = srcP->high-1;
	}
	vnum = vden = 1;
	if( gcP->fixAspect )
	{
		hnum = 9;
		hden = 8;
	}
	else
	{
		hnum = hden = 1;
	}
	clip.leftTop.x = pt.x;
	clip.leftTop.y = pt.y;
	clip.rightBot.x = hnum*(pt.x + sP->rightBot.x - sP->leftTop.x);
	clip.rightBot.x /= hden;
	clip.rightBot.y = pt.y + sP->rightBot.y - sP->leftTop.y;
	if( clip.rightBot.x >= destP->wide ) clip.rightBot.x = destP->wide-1;
	if( clip.rightBot.y >= destP->high ) clip.rightBot.y = destP->high-1;
	m2dScaledCopy(gcP, srcP, destP, sP, &clip, hnum, hden, vnum, vden );
}

/* New version of copy a rect from display pixmap to display pixmap
	Version 1 is simple, doesn't allow overlapping
	Note: srcType and dstType in paramblock contain cluster info and pix is already shifted.
*/
void m2dCopyRectDis(mmlGC* gcP, mmlDisplayPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint pt )
{
	m2dRect s;
	m2dRect* sP = &s;
	int numLines, numCols, firstSrcLine, firstSrcCol, firstDestLine, firstDestCol;
	int combine = gcP->disCopyBlend;
	int srcPix, dstPix;
	CopySDRAMParamBlock* paramP;
	
	assert( srcP != NULL && destP != NULL );	
	if( rP != NULL ) sP = rP;
	else
	{
		s.leftTop.x = 0;
		s.leftTop.y = 0;
		s.rightBot.x = srcP->wide-1;
		s.rightBot.y = srcP->high-1;
	}
	numLines = sP->rightBot.y - sP->leftTop.y + 1;
	firstSrcLine = sP->leftTop.y;
	firstDestLine = pt.y;
	numCols = sP->rightBot.x - sP->leftTop.x + 1;
	firstSrcCol = sP->leftTop.x;
	firstDestCol = pt.x;
	srcPix = ( srcP->dmaFlags & 0xF0 ) >> 4;
	if( srcPix == 2 )
	{
		srcPix = 8;
		combine = 0;	/* no alpha info, so can't combine */
	}
	dstPix = ( destP->dmaFlags & 0xF0 ) >> 4;
	if( dstPix == 2 ) dstPix = 8;
	paramP = (CopySDRAMParamBlock*)malloc( sizeof( CopySDRAMParamBlock) );
	assert( paramP != NULL );
	paramP->srcBase = srcP->memP;
	paramP->srcStrideBytes = ( srcP->dmaFlags & 0xFF0000 ) >> 13;
	paramP->srcPixType = ( srcP->dmaFlags & 0x800 ) | (srcPix<<4);
	paramP->srcTopStartPix = firstSrcLine;
	paramP->srcLeftStartPix = firstSrcCol;
	paramP->srcHighPix = numLines;
	paramP->srcWidePix = numCols;
	paramP->dstBase = destP->memP;
	paramP->dstStrideBytes = ( destP->dmaFlags & 0xFF0000 ) >> 13;
	paramP->dstPixType = ( destP->dmaFlags & 0x800 ) | (dstPix<<4);
	paramP->dstTop = firstDestLine;
	paramP->dstLeft = firstDestCol;
	paramP->dstHighPix = numLines;
	paramP->dstWidePix = numCols;
	paramP->blend = combine;
	
	mmlExecutePrimitive( gcP, eDCopy, paramP,
		sizeof( CopySDRAMParamBlock), 0, 0);
}


 /* Calculate derived fields for bilinear scaling copyrect parameter block 
 Return eBadScale if scale factors can not be accomodated in available memory.
 
 */
  /* Return the position of the most significant bit of x.
    0 -> 0
    1 -> 1
    2 -> 2
    3 -> 2
    etc.
*/
static inline int Msb( x )
{
	int p;
	asm("msb %1, %0": "=r" (p) : "r"(x));
	return p;
}

/* return smallest power of 2 greater than or equal tox
*/
static inline int Power2( x )
{
	int y, z;
	assert( x != 0);
	y = Msb( x );
	z = 1<< (y-1);
	if( z == x ) return x;
	else return z<<1;
}

 #define kDmaMax 64
 #define kTilePixSize 4
 
 int mmlBiCopyCalc( BiCopyParamBlock* b, int availMem )
 {
 	int h, w, th, tw, mw,mem, n, srcPixPerTile, srcMax, temp;
 	/* shift value to convert numPix to numBytes */
 	int shft[] = {1, -1, 1, 0, 2, 2, 4, 0, 1, 1, 2, 0, 4, 8 };
 
 /* Calculate size of biggest 2d tile for these scale factors that will fit
 in available DTRAM. Tile must be a power of 2 wide */	
 	th = h = b->vDen > b->vNum ? b->vDen : b->vNum;
 	tw = w = b->hDen > b->hNum ? b->hDen : b->hNum;
 	mem = h * Power2( w )  * kTilePixSize;
 	if( mem > availMem ) return eBadScale;
 	n = b->hDen;
 	srcMax = kDmaMax > b->srcWidePix ? b->srcWidePix : kDmaMax;
 	while( 1 ) 
 	{
 		if( n >= srcMax ) break;
 		tw += w;
 		mem = th * Power2( tw ) * kTilePixSize;
 		if( mem > availMem )
 		{
 			tw -= w;
 			goto exit;
 		}
 	 	n += b->hDen;

 	}
 	mw = Power2( tw );
 	n = b->vDen;
 	srcMax = b->srcHighPix;
 	while( 1 )
 	{
 		if( n >= srcMax ) break;
 		th += h;
 		mem = th * mw  * kTilePixSize;
 		if( mem > availMem )
 		{
 			th -= h;
 			break;
 		}
 		n += b->vDen;
 	}
 /* hack to make granularity very fine */
 //exit:	mw = Power2( tw );
 
 exit:	tw = tw < 64 ? tw : 64;
 		mw = Power2( tw );
 //		th = h;
  /* end of hack */
				
 	b->nSwathsFinished	= 0;
 	b->nTilesFinished	= 0;
 	b->tileWidePix		= mw;
 	b->tileHighPix		= th;
 	b->nBlocksHigh		= th/h;
 	b->nBlocksWide		= tw/w;
 	temp			= b->vDen*th;
 	srcPixPerTile		= temp/h;
 	b->nTilesHigh		= (b->srcHighPix + srcPixPerTile - 1)/srcPixPerTile;
 	temp			= b->hDen*tw;
 	srcPixPerTile		= temp/w;
 	temp			= b->srcWidePix * b->hNum + (b->hDen>>1);
 	temp			/= b->hDen;
 	if( temp < b->dstWidePix )
 		b->dstWidePix	= temp;
 	temp			= b->srcHighPix * b->vNum + (b->vDen>>1);
  	temp			/= b->vDen;
 	if( temp < b->dstHighPix )
 		b->dstHighPix	= temp;
 	b->nTilesWide		= (b->srcWidePix + srcPixPerTile - 1)/srcPixPerTile;
 	b->nTilesTotal		= b->nTilesWide * b->nTilesHigh;
 	b->recipV		= 0x40000000/b->vDen;
 	b->recipH		= 0x40000000/b->hDen; 
  	b->srcPixShift		= shft[b->srcPixType & 0xF];
 	return eOK;
 }

/* Return the amount and address of available resident DTRAM on a
specified platform.
Currently these are fixed constants in system Resources
*/
void* sysResDtram( mmlSysResources* srP, int* amountP )
{
	if( srP->platform == kGamePlatform )
	{
		*amountP = srP->intDataAvailDtram;
		return srP->intDataAdr;
	}
	else if( srP->platform == kBlackBirdPlatform )
	{
		*amountP = srP->bbAvailDtram;
		return srP->bbDtramAdr;
	}
	else return 0;
}
 
/* Copy a pixel rectangle from an application pixmap to a framebuffer
pixmap.  Do color conversion if necessary including clut expansion.
	appPixMap pixel format may be eGRB655 or eClut8
	framebuffer pixel format may be e888Alpha or e655
Also scale rectangle by factors hnum/hden and vnum/vden
Place rectangle at LeftTop of targRect. And clip to RightBot.
These are the coordinates in the dest buffer without any scaling applied.
If targ rect is NULL, use dest pixmap.
Ignore gcP->fixAspect. i.e. this is not done in addition to scaling.
Eventually, supplying 0's for scale factors, will cause correct scales to be
chosen to give src rect -> dst rect mapping.
If gcP->transparentSource is set, honor transparency.

*/
mmlStatus m2dScaledCopy(mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP,
 m2dRect* rP, m2dRect* targP, int hnum, int hden, int vnum, int vden )
 {
	BiCopyParamBlock* parP;
	m2dRect s,d;
	m2dRect* sP = &s;
	m2dRect* dP = &d;
	mmlPixFormat pix;
	int dstType, srcStridePix, availDtram,temp;
 	int shft[] = {1, -1, 1, 0, 2, 1, 4, 1, 1, 1 };
	int stat = eOK;
	assert( srcP != NULL && destP != NULL );
	pix = PIXFORMAT(srcP->properties); 
	assert( (pix != eClut4 && pix != eClut8 ) || srcP->yccClutP != NULL );
	assert( pix != e655 && pix != eGRB655 );
	parP  = (BiCopyParamBlock*)malloc( sizeof(BiCopyParamBlock) );
	assert( parP != NULL );
	assert( hnum > 0 && hnum < 11 &&
		hden > 0 && hden < 11 &&
		vnum > 0 && vnum < 11 &&
		vden > 0 && vden < 11 );
	if( rP != NULL ) sP = rP;
	else
	{
		s.leftTop.x = 0;
		s.leftTop.y = 0;
		s.rightBot.x = srcP->wide-1;
		s.rightBot.y = srcP->high-1;
	}
	if( sP->rightBot.x - sP->leftTop.x < 0 ) return eErr;
	if( sP->rightBot.y - sP->leftTop.y < 0 ) return eErr;
	parP->srcBase	= srcP->memP;
	srcStridePix	= srcP->dmaFlags >> 16;
 	parP->srcStrideBytes= srcStridePix << shft[ pix ];
 	parP->srcPixType	= pix;
 	if( gcP->transparentOverlay )
 	{
 		parP->srcPixType |= kTransBB;
 		if( pix != eClut8 )
 			parP->clutBase = (void*)gcP->rgbTransparentValue;
 	}
 	else if( gcP->transparentSource ) parP->srcPixType |= kTransparent;
 	parP->srcTopStartPix= sP->leftTop.y;
 	parP->srcLeftStartPix= sP->leftTop.x;
 	parP->srcHighPix	= sP->rightBot.y - sP->leftTop.y + 1;
 	parP->srcWidePix	= sP->rightBot.x - sP->leftTop.x + 1;
 	parP->dstBase	= destP->memP;
 	parP->dstStridePix = (destP->dmaFlags >> 13) & ~7;
 	dstType		= destP->dmaFlags & 0xF0;
/* if pixmap is of type e655, change dmaFlag type from 2 to 8 */
 	if( dstType  == 0x20 ) dstType = 0x80;
 	parP->dstPixType	= (destP->dmaFlags & 0x800) | dstType;
	if( targP != NULL ) dP = targP;
	else
	{
		d.leftTop.x = 0;
		d.leftTop.y = 0;
		d.rightBot.x = destP->wide-1;
		d.rightBot.y = destP->high-1;
	}
	if( dP->rightBot.x - dP->leftTop.x < 0 ) return eErr;
	if( dP->rightBot.y - dP->leftTop.y < 0 ) return eErr;
	
 	parP->dstTop	= dP->leftTop.y;
 	parP->dstLeft	= dP->leftTop.x;
 	
 	parP->dstWidePix = (hnum*(sP->rightBot.x - sP->leftTop.x + 1))/hden + 1;
 	if( parP->dstWidePix > dP->rightBot.x - dP->leftTop.x + 1 )
 		parP->dstWidePix = dP->rightBot.x - dP->leftTop.x + 1;
 	
 	temp = (parP->dstWidePix * hden )/hnum + 1;
 	if( temp < parP->srcWidePix ) parP->srcWidePix = temp;
 		
 	parP->dstHighPix = (vnum*(sP->rightBot.y - sP->leftTop.y + 1))/vden + 1;
 	if( parP->dstHighPix > dP->rightBot.y - dP->leftTop.y + 1 )
 		parP->dstHighPix = dP->rightBot.y - dP->leftTop.y + 1;

 	temp = (parP->dstHighPix * vden )/vnum + 1;
 	if( temp < parP->srcHighPix ) parP->srcHighPix = temp;

 	parP->hNum	= hnum;
 	parP->hDen	= hden;
 	parP->vNum	= vnum;
 	parP->vDen	= vden;
 	
 /* At this point, choose MPE, and determine available resident ram */
 	sysResDtram( gcP->sysResP, &availDtram );
 	
	if( (pix == eClut8) || (pix == eClut4) )
		parP->clutBase = srcP->yccClutP;
/* Force all pixels to be copied from cache into memory */ 
	_DCacheSync();
	availDtram -= 3 * 16;
	availDtram -= sizeof( BiCopyParamBlock );	
	stat = mmlBiCopyCalc( parP, availDtram );
	
	if( stat == eOK )	
	mmlExecutePrimitive( gcP, eBiCopy,
		 parP, sizeof(BiCopyParamBlock), 0, 0);
	return stat;
}





