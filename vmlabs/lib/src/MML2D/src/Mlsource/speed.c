
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* 2d Functions with fast alternative implementations
 * if USE_DISPATCHER equals 0, functions can directly use NUON asm code
 * rwb 6/24/99
 * 
 */

#include "m2config.h"
#include "../mrplib/parblock.h"
#include "../../nuon/mml2d.h"
#include "../../nuon/mrpcodes.h"
#include <stdlib.h>
#include <stddef.h>
#include <string.h>
#include <assert.h>

typedef struct ScrollUpParamBlock ScrollUpParamBlock;
struct ScrollUpParamBlock{
	void*	frameBufferAdr;
	int		flags;			// pixtype will be overwritten to be 655
	int		leftCol;			
	int		rowLength;
	int		topRow;
	int		numRows;			
	int		rowSkip;	 // num rows to scroll each row
};

typedef struct Copy32to16ParamBlock Copy32to16ParamBlock;
struct Copy32to16ParamBlock{
	void*	srcBufferAdr;
	int		srcByteWidth;	// width of Pixmap (in bytes)				
	int		srcLeftCol;			
	int		srcTopRow;
	void*	destBufferAdr;
	int		destFlags;		// must be pixtype 8 and Write	
	int		destLeftCol;			
	int		destTopRow;
	int		rowLength;
	int		numRows;			
};

void m2dCopy32to16( mmlGC* gcP, mmlAppPixmap* srcP, mmlDisplayPixmap* destP, m2dRect* rP, m2dPoint dpt )
{
	Copy32to16ParamBlock* parP = malloc( sizeof(Copy32to16ParamBlock));
	parP->srcBufferAdr = srcP->memP;
	parP->srcByteWidth = srcP->wide<<2;
	parP->srcLeftCol = rP->leftTop.x;
	parP->srcTopRow = rP->leftTop.y;
	parP->destBufferAdr = destP->memP;
	parP->destFlags = (destP->dmaFlags & ~0x20F0) | 0x80;
	parP->destLeftCol = dpt.x;
	parP->destTopRow = dpt.y;
	parP->rowLength = rP->rightBot.x - rP->leftTop.x + 1;
	parP->numRows = rP->rightBot.y - rP->leftTop.y + 1;
	mmlExecutePrimitive( gcP, eCopy32, parP, sizeof(Copy32to16ParamBlock), 0, 0);	
}

/* rect can not be NULL
rwb 9/24/00
	if skip is negative, scroll down. 
 */
void m2dScrollUp( mmlGC* gcP, mmlDisplayPixmap* destP, m2dRect* rP, int skip )
{
	ScrollUpParamBlock* parP = malloc( sizeof(ScrollUpParamBlock) );
	parP->frameBufferAdr	= destP->memP;
	parP->flags = ( destP->dmaFlags & 0xFF08F0 ) | ePixDma;
	parP->leftCol = rP->leftTop.x;
	parP->rowLength = rP->rightBot.x - rP->leftTop.x + 1;
	if( skip > 0 )
	{
	parP->topRow = rP->leftTop.y;
	parP->numRows = rP->rightBot.y - rP->leftTop.y + 1 - skip;
	}
	else
	{
		parP->topRow = rP->rightBot.y;	
		parP->numRows = rP->rightBot.y - rP->leftTop.y + 1 + skip;
	}
	parP->rowSkip = skip;
	mmlExecutePrimitive( gcP, eScrollUp, parP, sizeof(ScrollUpParamBlock), 0, 0);
}


