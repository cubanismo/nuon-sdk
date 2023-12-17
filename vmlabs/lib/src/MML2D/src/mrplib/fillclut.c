
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 10/18/99
 * MRP function for fill into e8Clut display pixmap.
 * Dest boundaries can be on any pixel boundary.
 * 
 */
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include <stddef.h>
#include "../../nuon/mml2d.h"


#define kMaxPix 128
#define kMaxRows (kMaxPix>>1)	

#define GL( x ) ( _GetLocal( parP->x ) )
#define HL( x ) ( _GetLocal( parP->x ) )
	 
mrpStatus FillClut(int environs, FillClutParamBlock* parBlockP, int arg2, int arg3 ) 
{
	int xBeg, xEnd, rowSize;
	odmaCmdBlock* odmaP;
	mdmaCmdBlock* mdmaP;
	FillClutParamBlock* parP;
 	uint32 *buf;
	
 	/* Set up local dtram & read in parameter block or  */
 	int parSizeLongs = (sizeof(FillClutParamBlock)+3)>>2;
 	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, (uint8**)&buf, NULL ) )
	  	mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
	else 
		parP = parBlockP;	
	
 /* another hack for maui */
 #ifdef BB
 	_SetLocalVar( parP->destBufferAdr , kGraphicsBase);
 #endif
 	xBeg = GL( destLeftCol );
 	rowSize = GL( rowLength );
	MRP_DmaWait( kmdmactl );
 	if( xBeg & 1)
 	{
 		int 		rowsToDo = GL( numRows );
 		int 		yBeg = GL( destTopRow );
 		uint32 	val = GL( fillData ) & 0xFF00FF;
 		uint32	flags = GL( destFlags ) | kPixRead;
 		while( rowsToDo > 0 )
 		{
 			int numRows = rowsToDo > kMaxRows ? kMaxRows : rowsToDo;
 			int numLongs = (2*numRows+3)>>2;
 			int yInfo = (numRows << 16) | yBeg;
   			uint32* ptr = buf;
			SL( mdmaP->flags,    flags                     );
			SL( mdmaP->sdramAdr, (uint8*)GL(destBufferAdr) );
			SL( mdmaP->xDesc,    (2<<16) | (xBeg & ~1)     );
			SL( mdmaP->yDesc,    yInfo                     );
			SL( mdmaP->dramAdr,  (uint8*)buf               );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			while( numLongs-- > 0 )
 			{
 				*ptr = (*ptr & 0xFF00FF00 ) | val;
 				++ptr;
 			}
 			flags &= ~BitRead;
			SL( mdmaP->flags,    flags                     );
			SL( mdmaP->sdramAdr, (uint8*)GL(destBufferAdr) );
			SL( mdmaP->xDesc,    (2<<16) | (xBeg & ~1)     );
			SL( mdmaP->yDesc,    yInfo                     );
			SL( mdmaP->dramAdr,  (uint8*)buf               );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
 			rowsToDo -= numRows;
 			yBeg += numRows;
 		}
 		 --rowSize;
 		 ++xBeg;
 	}
  	xEnd = xBeg + rowSize - 1;
  	if(! (xEnd & 1 ) )
  	{
  		int 		rowsToDo = GL( numRows );
 		int 		yBeg = GL( destTopRow );
 		uint32 	val = GL( fillData ) & 0xFF00FF00;
 		uint32	flags = GL( destFlags ) | kPixRead;
		while( rowsToDo > 0 )
 		{
 			int numRows = rowsToDo > kMaxRows ? kMaxRows : rowsToDo;
 			int numLongs = (2*numRows+3)>>2;
 			int yInfo = (numRows << 16) | yBeg;
 			uint32* ptr = buf;
			SL( mdmaP->flags,    flags                     );
			SL( mdmaP->sdramAdr, (uint8*)GL(destBufferAdr) );
			SL( mdmaP->xDesc,    (2<<16) | xEnd            );
			SL( mdmaP->yDesc,    yInfo                     );
			SL( mdmaP->dramAdr,  (uint8*)buf               );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			while( numLongs-- > 0 )
 			{
 				*ptr = (*ptr & 0xFF00FF ) | val;
 				++ptr;
 			}
 			flags &= ~BitRead;
			SL( mdmaP->flags,    flags                     );
			SL( mdmaP->sdramAdr, (uint8*)GL(destBufferAdr) );
			SL( mdmaP->xDesc,    (2<<16) | xEnd            );
			SL( mdmaP->yDesc,    yInfo                     );
			SL( mdmaP->dramAdr,  (uint8*)buf               );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
 			rowsToDo -= numRows;
 			yBeg += numRows;
 		}
  		--rowSize;
  		--xEnd;
  	}
  	{
	  	int	flags		= GL(destFlags) | kBitDup | kPixWrite;
	  	int	row		= GL( destTopRow );
  		int 	rowsToDo	= GL( numRows );
		*buf = GL( fillData );
	  	while( rowsToDo-- > 0 )
	  	{
	  		int numPixToFill = rowSize;
	  		int x = xBeg;
	  		int yInfo = (1<<16) | (row++); 
	  		while( numPixToFill > 0 )
	  		{
	  			int numFill = numPixToFill > kMaxPix ? kMaxPix : numPixToFill;
				SL( mdmaP->flags,    flags                     );
				SL( mdmaP->sdramAdr, (uint8*)GL(destBufferAdr) );
				SL( mdmaP->xDesc,    (numFill << 16) | x       );
				SL( mdmaP->yDesc,    yInfo                     );
				SL( mdmaP->dramAdr,  (uint8*)buf               );
				MRP_DmaDo( kmdmactl, mdmaP, 1 );
	 			numPixToFill -= numFill;
	 			x += numFill;
	 		}
	 	}
 	}
 	return eFinished;
}
