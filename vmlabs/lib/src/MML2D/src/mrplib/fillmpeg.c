
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 5/21/99
 * Function to fill a rect in video memory with a solid color.
 * Version 1 requires xstart & xlength to be multiples of 8
 */ 

#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include <stddef.h>

mrpStatus FillMpeg(int environs, MpegFillParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	odmaCmdBlock* odmaP;
 	mdmaCmdBlock* mdmaP;
 	MpegFillParamBlock* parP;
 	long* buf, *localAdr;
 	int rowStart,yStart, numRows, component, nRow, rowLength, mpcBits, j;
 	int value, valueL, valueR, valueB;
 	uint8* base;

 	/* Set up local dtram & read in parameter block */
 	int parSizeLongs = (sizeof(MpegFillParamBlock)+3)>>2;

 	if( mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, (uint8**)&buf, NULL ) )
  		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
  	else
  		parP = parBlockP;
	rowStart = _GetLocal( parP->xDesc ) & 0xFFFF;
	yStart = _GetLocal( parP->yDesc ) & 0xFFFF;
	
	value = _GetLocal( parP->color ) >> 24;
	valueL = (value << 8) | value;
	value = (_GetLocal( parP->color ) >> 16 ) & 0xFF;
	valueR = (value << 8 ) | value;
	value = (_GetLocal( parP->color ) >> 8 ) & 0xFF;
	valueB = (value << 8 ) | value;
	for(j=0; j<64; j+=4)
	{
		 _SetLocalVar(*(buf+j), (valueL<<16) | valueL);
		 _SetLocalVar(*(buf+j+1), (valueL<<16) | valueL);
		 _SetLocalVar(*(buf+j+2), (valueR<<16) | valueR);
		 _SetLocalVar(*(buf+j+3), (valueB<<16) | valueB);
	}	
	component = 0;
	MRP_DmaWait( kmdmactl );
nextComponent:
	if(++component == 1 )
	{
		mpcBits = 0x00;
		base = (uint8*)_GetLocal( parP->lumaBase );
		localAdr = buf;
		numRows = _GetLocal( parP->yDesc ) >> 16;
		rowLength =  _GetLocal( parP->xDesc ) >> 16;
	}
	else if( component == 2 ) 
	{
		mpcBits = 0x10;
		base = (uint8*)_GetLocal( parP->chromaBase );
		localAdr = buf+2;
		numRows = _GetLocal( parP->yDesc ) >> 16;
		rowLength =  _GetLocal( parP->xDesc ) >> 16;
	}
	else return eFinished;
	_SetLocalVar( mdmaP->flags, (_GetLocal( parP->frameLumaWidth )<<12) | mpcBits | 0x00008a00 );
	for( nRow=0; nRow<numRows; ++nRow )
	{
		int segStart = rowStart;
		int pixelsToDo = rowLength;
		int segWide;
nextSeg:
		segWide = pixelsToDo > 64 ? 64 : pixelsToDo;
		_SetLocalVar( mdmaP->xDesc , (segWide << 16) | (segStart<<1));
		_SetLocalVar( mdmaP->yDesc , (1 << 16) | ((yStart + nRow)<<1) );
		_SetLocalVar( mdmaP->sdramAdr, base );
		_SetLocalVar( mdmaP->dramAdr , localAdr );
		MRP_DmaDo( kmdmactl, mdmaP, 1 );
		segStart += segWide;
		pixelsToDo -= segWide;
		if( pixelsToDo > 0 ) goto nextSeg;
	}
	goto nextComponent;
}
