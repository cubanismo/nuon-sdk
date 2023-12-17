
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

#include <stddef.h> 
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include "mrptypes.h"
#include "version.h"


/* Setup Prolog
 * New version for Aries 3 - rwb 9/26/01
 * This is prolog code to be used in every MRP that requires a parameter
 * block.  It uses the environmental flags in R0 to determine what part
 * of dtram is available for local use, and locates pointers in this 
 * address range.
 * 7/8/99 -rwb Alter to return a boolean that specifies whether the
 * parameter block should be dma'd into local memory, or whether it
 * should just be pointed to in cache memory.
 *	0 - point to cache
 *  1 - read into local mem.

*/
#define kReadParBlock 0x10000000

int mrpSetup( int env, int parBlockSizeLongs, odmaCmdBlock** odmaP,
	mdmaCmdBlock** mdmaP, int** parP, uint8** tileP, int** endP )
{
	int* topPtr;
	int mask, dataBottom, amountBytes;
	mask = env & 0x3FFF;
	
	dataBottom = 0x20100000 + (mask << 4 );
	if( tileP != NULL) *tileP = (uint8*)dataBottom;
	mask = (env >> 14) & 0x3FF;
	amountBytes = (mask + 1)<<4;
	topPtr = (int*)(dataBottom + amountBytes);
	if( endP != NULL ) *endP = topPtr;
	if( odmaP != NULL )
	{
	topPtr -= 4;
	*odmaP = (odmaCmdBlock*)topPtr;
	}
	if( mdmaP != NULL )
	{
	topPtr -= 8;
	*mdmaP = (mdmaCmdBlock*)topPtr;
	}
	if( parP != NULL )
	{
	topPtr -= parBlockSizeLongs;
	*parP = topPtr;
	}
	return (env & kReadParBlock) ? 1 : 0;
}


/* Setup Prolog
 * rwb 8/25/98
 * This is prolog code to be used in every MRP that requires a parameter
 * block.  It uses the environmental flags in R0 to determine what part
 * of dtram is available for local use, and locates pointers in this 
 * address range.
 * 7/8/99 -rwb Alter to return a boolean that specifies whether the
 * parameter block should be dma'd into local memory, or whether it
 * should just be pointed to in cache memory.
 *	0 - point to cache
 *  1 - read into local mem.


#define kReadParBlock 0x4000

int mrpSetup( int env, int parBlockSizeLongs, odmaCmdBlock** odmaP,
	mdmaCmdBlock** mdmaP, int** parP, uint8** tileP, int** endP )
{
	int* topPtr;
	int mask, dataBottom, amountBytes;
	mask = env & 0x1FF;
	
	dataBottom = 0x20100000 + (mask << 4 );
	if( tileP != NULL) *tileP = (uint8*)dataBottom;
	mask = (env >> 9) & 0x1F;
	amountBytes = (mask + 1)<<7;
	topPtr = (int*)(dataBottom + amountBytes);
	if( endP != NULL ) *endP = topPtr;
	if( odmaP != NULL )
	{
	topPtr -= 4;
	*odmaP = (odmaCmdBlock*)topPtr;
	}
	if( mdmaP != NULL )
	{
	topPtr -= 8;
	*mdmaP = (mdmaCmdBlock*)topPtr;
	}
	if( parP != NULL )
	{
	topPtr -= parBlockSizeLongs;
	*parP = topPtr;
	}
	return (env & kReadParBlock) ? 1 : 0;
}
 */

/*
Get info about run-time NUON platform and its software.
The address of a parameter block to be filled out is passed to the mrp.
A selector is also passed that specifies what info is to be filled out.
Some selectors allow run-time parameters to be set from the Host.
	selector 01 - Return version of MRP software.
	selector 02 - Return address and size of SDRAM available for graphics buffers and scratch.
rwb 8/3/99
*/
mrpStatus MrpInfo(int environs, SdramFillParamBlock* parBlockP, int selector, int arg3 )
{
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	InfoParamBlock* parP;
 	uint8* tileBase;
 	int* endP;
 	int alwaysFinish;

 	// Set up local dtram  
 	int parSizeLongs = (sizeof(InfoParamBlock)+3)>>2;
 	alwaysFinish = mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, &endP );
  	mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
 	switch( selector )
 	{
 		case 0x01:	
 			_SetLocalVar( parP->data[0],  kMrpVersion  );
		break;
		case 0x02:	
 			_SetLocalVar( parP->data[0],  kGraphicsBase );
 			_SetLocalVar( parP->data[1],  kGraphicsSize );
		break;
		default:
			return eUnrecognized;
	}
  	mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, 0, kWaitFlag  );
	return eFinished;
}


mrpStatus UnImp( int env, void* parP, int arg2, int arg3 )
{
	return eUnimplemented;
}


