
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 9/3/98
 * MRP functions for new granular fill
 */
#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"

mrpStatus SdramFill(int environs, SdramFillParamBlock* parBlockP, int arg2, int arg3 )
{
 	odmaCmdBlock*			odmaP;
 	mdmaCmdBlock*			mdmaP;
 	SdramFillParamBlock*	parP;
 	uint8*					tileBase;
 	int*					endP;
 	int						rowsToDo;
	int						readParBlockQ;
 	int						rowLength;
	int						rowStart;
	int						xSize;
	int						segWide;
	int						segStart;
	int						flags;
	int						value;
	int						parSizeLongs;

	/* Set up local dtram & read in parameter block */
 	parSizeLongs = (sizeof(SdramFillParamBlock)+3)>>2;
 	readParBlockQ = mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, &endP );
  	if( readParBlockQ )
  		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
  	else parP = parBlockP;
  	MRP_DmaWait( kmdmactl );
 /* another hack for maui */
#ifdef BB
	_SetLocalVar( parP->base , kGraphicsBase );
#endif
	flags = _GetLocal( parP->flags );
	_SetLocalVar( mdmaP->flags, flags & ~0x300); /* Strip transparency bits */
	_SetLocalVar( mdmaP->sdramAdr , _GetLocal( parP->base ));
//	_SetLocalVar( mdmaP->xDesc , _GetLocal( parP->xDesc ));
	rowLength =  _GetLocal( parP->xDesc ) >> 16;
	rowStart = _GetLocal( parP->xDesc ) & 0xFFFF;
	_SetLocalVar( mdmaP->dramAdr , &mdmaP->value );
	value = _GetLocal( parP->value );
	if( (flags & kTransBB) && ((value & 0xFF) == 0xFF)  )
		_SetLocalVar( mdmaP->value, 0xFF );
	else
		_SetLocalVar( mdmaP->value , value );
	MRP_DmaWait( kmdmactl );
nextTurn:
	rowsToDo = _GetLocal( parP->numRowsPerTurn  );
	if( _GetLocal( parP->numRowsFinished ) + _GetLocal( parP->numRowsPerTurn )
		 > _GetLocal( parP->numRowsTotal ) ) 
		rowsToDo = _GetLocal( parP->numRowsTotal) - _GetLocal( parP->numRowsFinished );
	segWide = rowLength;
	segStart = rowStart;
nextXseg:
	xSize = segWide > 64 ? 64 : segWide;
	_SetLocalVar( mdmaP->xDesc , (xSize << 16) | segStart);
	_SetLocalVar
	(
		mdmaP->yDesc,
		(rowsToDo << 16) | (_GetLocal(parP->fillTop) + _GetLocal(parP->numRowsFinished))
	);
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
	segStart += xSize;
	segWide -= xSize;
	if (segWide > 0)
	{
		goto nextXseg;
	}
	_SetLocalVar( parP->numRowsFinished, _GetLocal( parP->numRowsFinished )  + rowsToDo );
	if (_GetLocal( parP->numRowsFinished) < _GetLocal( parP->numRowsTotal))
	{
		goto nextTurn;
	}
	return eFinished;
}
