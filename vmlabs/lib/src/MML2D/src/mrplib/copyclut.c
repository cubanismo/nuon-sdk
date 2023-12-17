
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 6/24/99
 * MRP functions for copy from e8Clut app pixmap to e8Clut display pixmap,
 * Source and Dest boundaries can be on any pixel boundary.
 * Copy is UNSCALED
 * 
 */
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include <stddef.h>
#include <stdio.h>
#include "../../nuon/mml2d.h"

#define kBufSize 33
#define kRowsPerBlock 44 /* require numRows to be less than 45 */
#define kBitPixRead 0x2000
#define GL( x ) ( _GetLocal( parP->x ) )
#define HL( x ) ( _GetLocal( x ) )

static void	ReadNextChunk( uint8* buf, int* bufFullP, uint8** bufLastPixP, int* bufLeftShiftP,
	 int* bufEndRowP, int* bufNumPixOutP );
static void Proc1( uint32* buf, int bufFull, uint8** bufLastPixP, int bufLeftShift );
static void adjustLeftEdge(uint32 *bufP );
static void adjustRightEdge(const uint8 *bufP );
static void Proc2(uint32* buf, int bufFull, const uint8* bufLastPix, int bufLeftShift, int bufEndRow );
static void WriteNextChunk( const uint32* buf, int* bufFullP, int bufNumPixOut, int bufLeftShift );

static int startRow, rowIn, rowOut, offsetIn, oddDest,leftMask,rightShift, dstXbeg, dstXend, numLongsIn, rowRightAdj;
static	unsigned int rightMask;
static odmaCmdBlock* odmaP;
static mdmaCmdBlock* mdmaP;
static CopyClutParamBlock* parP;
static uint32 *leftEdgeP, *rightEdgeP, *bufP, *outP;
static uint8* srcBeg;

/* The idea is to break each row up into chunks.
Read a chunk of pixels.  If it is the beginning of the row, extra pixels may need to be
read because read must start on long boundary.
Slide the chunk left in the buffer so the first pixel is in position 0, unless the destination
x values is odd, in which case slide it left so first pixel is in position 1.
*/
/* This is a complex double buffer system that is doing no good right now 
because of the hardware dma bug.  But it will work in future and can be
made to work in ARIES by switching to asm language (to guarantee no cache misses
while main bus dma is active).
*/  
	 
mrpStatus CopUnClut(int environs, CopyClutParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	uint8* tileBase;
 	uint32 *bufA, *bufB;
 	int endRowA, endRowB;
 	uint8* bufALastPix, *bufBLastPix;
 	int bufALeftShift, bufBLeftShift, bufAFull, bufBFull, bufANumPixOut, bufBNumPixOut;
	int flags, yInfo;
	
 	/* Set up local dtram & read in parameter block or  */
 	int parSizeLongs = (sizeof(CopyClutParamBlock)+3)>>2;

 	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, NULL ) )
	  	mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
	else 
		parP = parBlockP;	
 /* another hack for maui */
 #ifdef BB
 	_SetLocalVar( parP->destBufferAdr , kGraphicsBase);
 #endif
 	srcBeg = (uint8*)GL( srcBufferAdr) + GL( srcTopRow) * GL( srcByteWidth) + GL( srcLeftCol);
 	srcBeg = (uint8*)((int)srcBeg & ~3);
 	srcBeg -= GL( srcByteWidth );
 	dstXbeg = GL( destLeftCol );
 	flags = GL( destFlags ) | kBitPixRead;
 	yInfo = GL( numRows) << 16 | GL( destTopRow );
 	bufA = (uint32*)tileBase + 1 ;
 	bufB = bufA+kBufSize;
 	leftEdgeP = bufB+kBufSize-1;
 	rightEdgeP = leftEdgeP+(kRowsPerBlock>>1);
 	rowRightAdj = 0;
 	bufAFull = bufBFull = 0;
 	rowIn = -1;
	MRP_DmaWait( kmdmactl );
 	if( dstXbeg & 1 )
 	{
 		int xInfo = (2<<16)| (dstXbeg-1);
		SL( mdmaP->flags,    flags                     );
		SL( mdmaP->sdramAdr, (uint8*)GL(destBufferAdr) );
		SL( mdmaP->xDesc,	 xInfo                     );
		SL( mdmaP->yDesc,	 yInfo                     );
		SL( mdmaP->dramAdr,	 (uint8*)leftEdgeP         );
		MRP_DmaDo( kmdmactl, mdmaP, 1 );
 	}
 	dstXend = dstXbeg + GL( rowLength ) - 1;
 	if( (dstXend & 1) == 0)
 	{
 		int xInfo = (2<<16)| dstXend;
 		SL( mdmaP->flags,    flags );
 		SL( mdmaP->sdramAdr, (uint8*)GL(destBufferAdr) );
 		SL( mdmaP->xDesc,    xInfo );
 		SL( mdmaP->yDesc,    yInfo );
 		SL( mdmaP->dramAdr,  (uint8*)rightEdgeP );
		MRP_DmaDo( kmdmactl, mdmaP, 1 );
 	}
 	rowOut = GL( destTopRow ) - 1;
 	MRP_DmaWait( kodmactl );
	do
 	{
		ReadNextChunk( (uint8*)bufA, &bufAFull, &bufALastPix, &bufALeftShift, &endRowA, &bufANumPixOut );
		Proc2( bufB, bufBFull, bufBLastPix, bufBLeftShift, endRowB  );
		WriteNextChunk( bufB, &bufBFull, bufBNumPixOut, bufBLeftShift );
		Proc1( bufA, bufAFull, &bufALastPix, bufALeftShift );
		ReadNextChunk( (uint8*)bufB, &bufBFull, &bufBLastPix, &bufBLeftShift, &endRowB, &bufBNumPixOut );
		Proc2( bufA, bufAFull, bufALastPix, bufALeftShift, endRowA );
		WriteNextChunk( bufA, &bufAFull, bufANumPixOut, bufALeftShift );
		Proc1( bufB, bufBFull, &bufBLastPix, bufBLeftShift );
	} while( bufBFull ); 		
	return eFinished;
}


static void	ReadNextChunk( uint8* buf, int* bufFullP, uint8** bufLastPixP, int* bufLeftShiftP,
	 int* bufEndRowP, int* bufNumPixOutP  )
{
	static int numPixStillToRead = 0;
	static int numLongsToRead = 0;
	static uint32* srcP = (uint32*)0;
	int numPixToProcess;
	
	if( numPixStillToRead <= 0 )
	{
		if(++rowIn >= GL( numRows ) ) return;
		srcBeg += GL( srcByteWidth );
		numPixStillToRead = GL( rowLength);
		srcP = (uint32*)srcBeg;
		startRow = 1;
		offsetIn = GL( srcLeftCol ) & 3;
		oddDest = GL( destLeftCol ) & 1;
	}
	else
	{
		srcP += numLongsToRead;
		if( ( 4 - offsetIn + oddDest ) & 1 )
		{
			--srcP;
			offsetIn = 3;
			++numPixStillToRead;
		}
		else offsetIn = 0;
		oddDest = 0;
		startRow = 0;
	}
	*bufLeftShiftP = (( offsetIn - oddDest ) & 3)<<3;
	
	numPixToProcess = numPixStillToRead;
	numLongsToRead = (numPixStillToRead + offsetIn + 3) >> 2;
	if( numLongsToRead > kMaxLongs )
	{
		numLongsToRead = kMaxLongs;
		numPixToProcess = 4*numLongsToRead - offsetIn;
	}
	SL( odmaP->flags, (numLongsToRead<<16) | kBitPixRead );
	SL( odmaP->sysAdr, srcP );
	SL( odmaP->dramAdr, buf );
	MRP_DmaDo( kodmactl, odmaP, 1 );
	*bufLastPixP = buf + numPixToProcess + offsetIn - 1;
	if( oddDest && (offsetIn == 0 )) *bufLastPixP += 4;
	*bufNumPixOutP = (numPixToProcess + oddDest) & ~1; 
	numPixStillToRead -= (4*numLongsToRead - offsetIn);
	if( numPixStillToRead <= 0 )
	{
		*bufEndRowP = 1;
		if( (numPixToProcess + oddDest) & 1 ) *bufNumPixOutP += 2;
	}
	else
		*bufEndRowP = 0;
	*bufFullP = 1;
}

/* shift pixels in left half of buffer left by bufLeftShift. There is a longword
prior to the beginning of the buffer, that can be shifted into.
Possibly paste pixel from framebuffer onto beginning of row.
*/
static void Proc1( uint32* buf, int bufFull, uint8** bufLastPixP, int bufLeftShift )
{
	long half,maskShift;
	unsigned long a,b;
	
	if( bufFull == 0 ) return;

	rightShift = (32 - bufLeftShift) & 0x1F;
	if( rightShift == 0 )
	{
	/* source pixels begin at position 1 (not 0) of 4 pixel long */
		if( startRow && (dstXbeg & 1)) adjustLeftEdge( buf );
		return;
	}
	outP = buf-1;
	maskShift = ((oddDest - offsetIn ) & 3 ) <<3;
	leftMask = (1 << maskShift) - 1;
	rightMask = ~leftMask;
	bufP = buf;
	if( offsetIn == 0 && oddDest ) --bufP;
	
	a = HL(*bufP);
	++bufP;
	numLongsIn = (((uint32*)((int)(*bufLastPixP) & ~3)) - buf ) + 1;
	half = numLongsIn >> 1;
	while( half-- > 0 )
	{
		b = HL(*bufP);
		++bufP;
		SL( *outP, ((a & leftMask) << bufLeftShift ) | (( b & rightMask) >> rightShift ) )
		outP++;
		a = b;
	}
	--bufP;
	*bufLastPixP -= 4;
	*bufLastPixP -= (bufLeftShift>>3);
	if( startRow && (dstXbeg & 1) ) adjustLeftEdge( buf - 1  );	
	
}
/* replace pixel 0 of a 4 pixel long with the existing framebuffer pixel */
static void adjustLeftEdge(uint32 *bufP )
{
	int patch;
	patch = *(leftEdgeP + (rowIn>>1));
	if( rowIn & 1 )
		patch = (patch & 0xFF00) << 16; 
	else patch &= 0xFF000000;
	SL( *bufP, (*bufP & 0xFFFFFF) | patch )
}	

/* if bufP is not an odd address, replace the following pixel with
the existing framebuffer pixel.
*/
static void adjustRightEdge(const uint8 *bufP )
{
	uint32* lastP;
	int patch;
	if( (int)bufP & 1) return;
	patch = *(rightEdgeP + (rowRightAdj>>1));
	if( (rowRightAdj & 1) == 0 )patch >>= 16; 
	patch &= 0xFF;
	lastP = (uint32*)((int)bufP & ~3);
	if( (int)bufP & 2 )
		SL(*lastP , (*lastP & 0xFFFFFF00) | patch)
	else
		SL(*lastP , (*lastP & 0xFF000000) | (patch<<16))
	++rowRightAdj;
}	
/* shift pixels in right half of buffer left by bufLeftShift. 
Possibly paste pixel from framebuffer onto end of row.
*/
static void Proc2(uint32* buf, int bufFull, const uint8* bufLastPix, int bufLeftShift, int bufEndRow )
{
	long half;
	unsigned long a,b;
	
	if( bufFull == 0 ) return;
	if( bufLeftShift == 0 )
	{
		if( bufEndRow && !(dstXend & 1) ) adjustRightEdge( bufLastPix );
	 	return;
	} 
	half = numLongsIn - (numLongsIn >> 1);
	a = HL(*bufP);
	bufP++;
	b = HL(*bufP);
	++bufP;
	while( half-- > 0 )
	{
		SL(*outP , ((a & leftMask) << bufLeftShift ) | ( (b & rightMask) >> rightShift))
		++outP;
		a = b;
		b = HL(*bufP);
		++bufP;
	}
	if( bufEndRow && !(dstXend & 1) ) adjustRightEdge( bufLastPix );
}	

static void WriteNextChunk( const uint32* buf, int* bufFullP, int bufNumPixOut, int bufLeftShift )
{
	static int numPixStillToWrite = 0;
	static int outXPos = 0;
	
	if( *bufFullP == 0 ) return;
	if( numPixStillToWrite <= 0 )
	{
		numPixStillToWrite = (GL( rowLength ) + (GL( destLeftCol ) & 1) + 1) & ~1;
		++rowOut;
		outXPos = GL( destLeftCol ) & ~1;
	}
	if( bufLeftShift != 0 ) --buf;
	SL( mdmaP->flags,    GL(destFlags)                );
	SL( mdmaP->sdramAdr, (uint8*)GL(destBufferAdr)    );
	SL( mdmaP->xDesc,    (bufNumPixOut<<16) | outXPos );
	SL( mdmaP->yDesc,    (1<<16) | rowOut             );
	SL( mdmaP->dramAdr,  (uint8*)buf                  );
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
	*bufFullP = 0;
	outXPos += bufNumPixOut;
	numPixStillToWrite -= bufNumPixOut; 
}
