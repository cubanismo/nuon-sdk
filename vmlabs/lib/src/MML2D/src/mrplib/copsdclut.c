/*
   Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
 */
/* rwb 6/24/99
 * MRP function for copy from e8Clut display pixmap to e8Clut display pixmap.
 * Source and Dest boundaries can be on any pixel boundary.
 * Copy is UNSCALED
 * 
 */
#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include <stddef.h>

#define kBufSize 33
#define kRowsPerBlock 62 /* require numRows to be less than 63 */
#define kBitPixRead 0x2000
#define GL( x ) ( _GetLocal( parP->x ) )
#define HL( x ) ( _GetLocal( x ) )

static void	ReadNextChunk( uint8* buf, int* bufFullP, uint8** bufLastPixP, int* bufLeftShiftP,
	 int* bufEndRowP, int* bufNumPixOutP );
static void Proc1( uint32* buf, int bufFull, uint8* bufLastPix, int bufLeftShift );
static void adjustLeftEdge(uint32 *bufP );
static void adjustRightEdge(const uint8 *bufP );
static void Proc2(uint32* buf, int bufFull, const uint8* bufLastPix, int bufLeftShift, int bufEndRow );
static void WriteNextChunk( const uint32* buf, int* bufFullP, int bufNumPixOut, int bufLeftShift );


static int startRow, rowIn, rowOut, offsetIn, oddDest,leftMask,rightShift, dstXbeg, dstXend;
static	unsigned int rightMask;
static odmaCmdBlock* odmaP;
static mdmaCmdBlock* mdmaP;
static CopyClutParamBlock* parP;
static uint32 *leftEdgeP, *rightEdgeP, *bufP, *outP;

mrpStatus CopSDClut(int environs, CopyClutParamBlock* parBlockP, int arg2, int arg3 ) 
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
 	dstXbeg = GL( destLeftCol );
 	flags = GL( destFlags ) | kBitPixRead;
 	yInfo = GL( numRows) << 16 | GL( destTopRow );
 	bufA = (uint32*)tileBase + 1 ;
 	bufB = bufA+kBufSize;
 	leftEdgeP = bufB+kBufSize;
 	rightEdgeP = leftEdgeP+(kRowsPerBlock>>2);
 	bufAFull = bufBFull = 0;
 	rowIn = - 1;
 	if( dstXbeg & 1 )
 	{
 		int xInfo = (2<<16)| (dstXbeg-1);
		
		SL( mdmaP->flags,    flags             );
		SL( mdmaP->sdramAdr, GL(destBufferAdr) );
		SL( mdmaP->xDesc,    xInfo             );
		SL( mdmaP->yDesc,    yInfo             );
		SL( mdmaP->dramAdr,  leftEdgeP         );
		MRP_DmaDo( kmdmactl, mdmaP, 1 );
 	}
 	dstXend = dstXbeg + GL( rowLength ) - 1;
 	if( (dstXend & 1) == 0)
 	{
 		int xInfo = (2<<16)| dstXend;
		
		SL( mdmaP->flags,    flags             );
		SL( mdmaP->sdramAdr, GL(destBufferAdr) );
		SL( mdmaP->xDesc,    xInfo             );
		SL( mdmaP->yDesc,    yInfo             );
		SL( mdmaP->dramAdr,  rightEdgeP        );
		MRP_DmaDo( kmdmactl, mdmaP, 1 );
 	}
 	rowOut = GL( destTopRow ) - 1;
 	do
 	{
		ReadNextChunk( (uint8*)bufA, &bufAFull, &bufALastPix, &bufALeftShift, &endRowA, &bufANumPixOut );
		Proc2( bufB, bufBFull, bufBLastPix, bufBLeftShift, endRowB  );
		WriteNextChunk( bufB, &bufBFull, bufBNumPixOut, bufBLeftShift );
		Proc1( bufA, bufAFull, bufALastPix, bufALeftShift );
		ReadNextChunk( (uint8*)bufB, &bufBFull, &bufBLastPix, &bufBLeftShift, &endRowB, &bufBNumPixOut );
		Proc2( bufA, bufAFull, bufALastPix, bufALeftShift, endRowA );
		WriteNextChunk( bufA, &bufAFull, bufANumPixOut, bufALeftShift );
		Proc1( bufB, bufBFull, bufBLastPix, bufBLeftShift );
	} while( bufBFull ); 		
	return eFinished;
}

static void	ReadNextChunk( uint8* buf, int* bufFullP, uint8** bufLastPixP, int* bufLeftShiftP,
	 int* bufEndRowP, int* bufNumPixOutP  )
{
	static int numPixStillToRead = 0;
	static int numLongsToRead = 0;
	static int colIn = 0;
	int numPixToProcess;
	uint32 xInfo, yInfo, flags;
	
	MRP_DmaWait( kmdmactl );

	if( numPixStillToRead <= 0 )
	{
		if(++rowIn >= GL( numRows ) ) return;
		colIn = GL( srcLeftCol ) & ~3;
		numPixStillToRead = GL( rowLength);
		startRow = 1;
		offsetIn = GL( srcLeftCol ) & 3;
		oddDest = GL( destLeftCol ) & 1;
	}
	else
	{
		colIn += 4*numLongsToRead;
		if( ( numLongsToRead - offsetIn + oddDest ) & 1 )
		{
			colIn -= 4;
			offsetIn = 3;
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
 	xInfo = (numLongsToRead<<18) | colIn;
 	yInfo = (1 << 16) | (GL( srcTopRow ) + rowIn );
 	flags = GL( srcByteWidth ) | kBitPixRead; // for clut, utilize field for flags.

	SL( mdmaP->flags,    flags            );
	SL( mdmaP->sdramAdr, GL(srcBufferAdr) );
	SL( mdmaP->xDesc,    xInfo            );
	SL( mdmaP->yDesc,    yInfo            );
	SL( mdmaP->dramAdr,  buf              );
	MRP_DmaDo( kmdmactl, mdmaP, 1 );

	*bufLastPixP = buf + numPixToProcess + offsetIn - 1;
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

static void Proc1( uint32* buf, int bufFull, uint8* bufLastPix, int bufLeftShift )
{
	long half,maskShift,numLongsIn;
	unsigned long a,b;
	
	if( bufFull == 0 ) return;
	
	MRP_DmaWait( kmdmactl );

	rightShift = (32 - bufLeftShift) & 0x1F;
	if( rightShift == 0 )
	{
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
	numLongsIn = (((uint32*)((int)bufLastPix & ~3)) - buf ) + 1;
	half = numLongsIn >> 1;
	while( half-- > 0 )
	{
		b = HL(*bufP);
		++bufP;
		SL( *outP, ((a & leftMask) << bufLeftShift ) | (( b & rightMask) >> rightShift ) );
		outP++;
		a = b;
	}
	--bufP;
	if( startRow && (dstXbeg & 1) ) adjustLeftEdge( buf - 1  );	
	
}
static void adjustLeftEdge(uint32 *bufP )
{
	int patch;
	patch = *(leftEdgeP + (rowIn>>1));
	if( rowIn & 1 )
		patch = (patch & 0xFF00) << 16; 
	else patch &= 0xFF000000;
	SL( *bufP, (*bufP & 0xFFFFFF) | patch );
}	

static void adjustRightEdge(const uint8 *bufP )
{
	uint32* lastP;
	int patch;
	if( (int)bufP & 1) return;
	patch = *(rightEdgeP + (rowIn>>1));
	if( (rowIn & 1) == 0 )patch >>= 16; 
	patch &= 0xFF;
	lastP = (uint32*)((int)bufP & ~3);
	if( (int)bufP & 2 )
		SL(*lastP , (*lastP & 0xFFFFFF00) | patch)
	else
		SL(*lastP , (*lastP & 0xFF000000) | (patch<<16))
}	

static void Proc2(uint32* buf, int bufFull, const uint8* bufLastPix, int bufLeftShift, int bufEndRow )
{
	long half,numLongsIn;
	unsigned long a,b;
	
	MRP_DmaWait( kmdmactl );
	
	if( bufFull == 0 ) return;
	if( bufLeftShift == 0 )
	{
		if( bufEndRow && !(dstXend & 1) ) adjustRightEdge( bufLastPix );
	 	return;
	} 
	numLongsIn = (((uint32*)((int)bufLastPix & ~3)) - buf ) + 1;
	half = numLongsIn - (numLongsIn >> 1);
	a = HL(*bufP);
	bufP++;
	b = HL(*bufP);
	++bufP;
	while( half-- > 0 )
	{
		SL(*outP , ((a & leftMask) << bufLeftShift ) | ( (b & rightMask) >> rightShift));
		++outP;
		a = b;
		b = HL(*bufP);
		++bufP;
	}
	if( bufEndRow && !(dstXend & 1) ) adjustRightEdge( bufLastPix - 3 );
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
	SL( mdmaP->sdramAdr, GL(destBufferAdr)            );
	SL( mdmaP->xDesc,    (bufNumPixOut<<16) | outXPos );
	SL( mdmaP->yDesc,    (1<<16) | rowOut             );
	SL( mdmaP->dramAdr,  buf                          );
	MRP_DmaDo( kmdmactl, mdmaP, 1 );

	*bufFullP = 0;
	outXPos += bufNumPixOut;
	numPixStillToWrite -= bufNumPixOut; 
}
