
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 6/24/99
 * MRP function for scroll-up
 * Scroll a rectangle in a display pixmap up by K Rows.
 * Pixmap pixels must be in 16 bit format.
 * leftCol must be even, and rowLength must be even.
 * rwb 9/24/00 Scroll down by setting K to minus number
 and setting topRow to bottom row.
 */
#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include <stddef.h>

typedef struct ScrollUpParamBlock ScrollUpParamBlock;
struct ScrollUpParamBlock{
	void*	frameBufferAdr;
	int		flags;			// pixtype will be overwritten to be 655
	int		leftCol;			
	int		rowLength;
	int		topRow;
	int		numRows;			
	int		rowSkip;	 // size of shift of each row
};
mrpStatus ScrollUp(int environs, ScrollUpParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	ScrollUpParamBlock* parP;
 	uint8* tileBase;
 	int flags, readRow, writeRow, endRow, inc, skip;

 	/* Set up local dtram & read in parameter block */
 	int parSizeLongs = (sizeof(ScrollUpParamBlock)+3)>>2;

 	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, NULL ) )
  		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
  	else
  		parP = parBlockP;
	flags = (_GetLocal( parP->flags ) & ~0x20F0) | 0x20;
	
 /* another hack for maui */
 #ifdef BB
 	_SetLocalVar( parP->frameBufferAdr , kGraphicsBase);
 #endif
 	
  	MRP_DmaWait( kmdmactl );
	_SetLocalVar( mdmaP->dramAdr , tileBase );
	_SetLocalVar( mdmaP->sdramAdr , _GetLocal( parP->frameBufferAdr ));
	skip = _GetLocal( parP->rowSkip );
	inc = (skip > 0) ? 1 : -1;
	writeRow = _GetLocal( parP->topRow );
	readRow = writeRow + skip;
	if( skip > 0 )
	{
		inc = 1;
	endRow = readRow + _GetLocal( parP->numRows );
	}
	else
	{
		inc = -1;
		endRow = readRow - _GetLocal( parP->numRows );		
	}
	while( readRow != endRow )
	{
		int pixToDo = _GetLocal(parP->rowLength);
		int segStart = _GetLocal(parP->leftCol);
		while( pixToDo > 0 )
		{
			int segSize = pixToDo > kMaxLongs ? kMaxLongs : pixToDo;
			_SetLocalVar( mdmaP->xDesc, segSize<<16 | segStart );
			_SetLocalVar( mdmaP->yDesc, 1<<16 | readRow );
			_SetLocalVar( mdmaP->flags, flags | 0x2000);
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			_SetLocalVar( mdmaP->flags, flags );
			_SetLocalVar( mdmaP->yDesc, 1<<16 | writeRow );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			segStart += segSize;
			pixToDo -= segSize;
		}
		readRow += inc;
		writeRow += inc;
	}
	return eFinished;
}
			
 
