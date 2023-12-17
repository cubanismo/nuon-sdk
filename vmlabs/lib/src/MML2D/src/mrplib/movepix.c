
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

/* 
rwb 7/1299

Move a row or column of (upto 32) N pixels between a SysRam buffer.  
and SDRAM beginning at position (x,y).
No color conversion is done. The raw data is packed into the buffer, 
4 8-bit pix per long, 2 16-bit pix per long, ... 2 longs per 64 bit pixel.
No checks are done.  The buffer must be allocated and big enough to hold
the data.  The pix row should not run off the edge of the pixmap. N should
not be greater than 32 pixels. readQ = 1 means transfer from SDRAM to SysRam,
0 means transfer from SysRam to SDRAM.

Only works for 16 and 32 bit pixels.
Two versions:
	Direct is used when caller and function are on same mpe; bypasses execprim
	Dispatch is dispatched thru mmlExecPrimitive
	
	rwb 11/6/00 - improve to handle case where pixformat of 8 is 
	passed in, asking for 32 bit to 16 bit translation.
	
	rwb 2/21/01 - Handle 8 bit pixels.  Restriction is that numPixels must be
	multiple of 4, and if the vertical flag is set, a vertical line 2 pixels wide
	and numPixels/2 high is created.
	Also fixed dispatch version which had never been extended from read to write.
*/ 
   
#include "../../nuon/mml2d.h"
#include <stddef.h>
#include "pixmacro.h"
#include "parblock.h"
#include "mrpproto.h"
												
void MovePixDirect( int flags, uint32* buffer, void* frameP, int x, int y,
 int numPix, int vert, uint32* tile, int readQ )	
{	
 	mdmaCmdBlock* mdmaP = (mdmaCmdBlock*)(tile + 64);
	int i, numLongs, format;

	format = flags & 0xF0;
	if( format == 0x40 || format == 0x80  ) numLongs = numPix;
	else if( format == 0x20 ) numLongs = (numPix+1)>>1;
	else if( format == 0x30 ) numLongs = (numPix+3)>>2;
	else numLongs = 0;
	if( readQ == 0 ) 
		for( i=0; i<numLongs; ++i) _SetLocalVar( tile[i], buffer[i] );
	MRP_DmaWait( kmdmactl );
	_SetLocalVar(mdmaP->flags , flags | (readQ<<13) );
	_SetLocalVar(mdmaP->sdramAdr , frameP );
	if( vert == 0 )
	{
		_SetLocalVar(mdmaP->xDesc , (numPix<<16) | x );
		_SetLocalVar(mdmaP->yDesc , (1<<16) | y );
	}
	else if( format == 0x30 )
	{
		_SetLocalVar(mdmaP->xDesc , (2<<16) | x );
		_SetLocalVar(mdmaP->yDesc , (numPix<<15) | y );
	}
	else
	{
		_SetLocalVar(mdmaP->xDesc , (1<<16) | x );
		_SetLocalVar(mdmaP->yDesc , (numPix<<16) | y );
	}
	_SetLocalVar(mdmaP->dramAdr , tile);	
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
	
	if( readQ != 0 )	
		for( i=0; i<numLongs; ++i) buffer[i] = _GetLocal(tile[i]);
}


/* Dispatch version of m2dReadPix
	r0 - environs
	r1 - frameP | readFlag<<7 | frameWide div8
	r2 - bufferP in sysRam
	r3
		31:31 - vertical
		30:30 - cluster
		29:26 - pixtype
		25:20 - numPix-1
		19:10 - yPos
		9:0   - xPos
*/
mrpStatus MovePixDispatch( int environs, void* frameP, uint32* buffer, int flags )
{	
 	mdmaCmdBlock* mdmaP;
 	odmaCmdBlock* odmaP;
 	uint8* tileBase;
	int numLongs, numPix, vert, format, readQ, i;
	uint32 dflags;
	uint32* tile;

 	mrpSetup( environs, 0, &odmaP, &mdmaP, NULL, &tileBase, NULL );
	vert = flags & 0x80000000;
	readQ = (((long)frameP) & 0x80 )>>7; 
	dflags =   (flags & 0x40000000)>>19;
	dflags |= ((flags & 0x3C000000)>>22);
	dflags |= ((((long)frameP) & 0x7F)<<16);
	numPix = ((flags & 0x3F00000)>>20) + 1;
	format = flags & 0xF0;
	if( format == 0x40 || format == 0x80  ) numLongs = numPix;
	else if( format == 0x20 ) numLongs = (numPix+1)>>1;
	else if( format == 0x30 ) numLongs = (numPix+3)>>2;
	else numLongs = 0;
	tile = (uint32*)tileBase;
	if( readQ == 0 ) 
		for( i=0; i<numLongs; ++i) _SetLocalVar( tile[i], buffer[i] );
	MRP_DmaWait( kmdmactl );
	_SetLocalVar(mdmaP->flags , dflags | readQ<<13 );
	_SetLocalVar(mdmaP->sdramAdr , ((long)frameP) & 0xFFFFFF00 );
	if( vert == 0 )
	{
		_SetLocalVar(mdmaP->xDesc , (numPix<<16) | (flags & 0x3FF) );
		_SetLocalVar(mdmaP->yDesc , (1<<16) | ((flags & 0xFFC00)>>10) );
	}
	else if( format == 0x30 )
	{
		_SetLocalVar(mdmaP->xDesc , (2<<16) | (flags & 0x3FF) );
		_SetLocalVar(mdmaP->yDesc , (numPix<<15) | ((flags & 0xFFC00)>>10) );
	}
	else
	{
		_SetLocalVar(mdmaP->xDesc , 1 | (flags & 0x3FF) );
		_SetLocalVar(mdmaP->yDesc , (numPix<<16) | ((flags & 0xFFC00)>>10) );
	}
	_SetLocalVar(mdmaP->dramAdr , tileBase);	
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
	if( readQ != 0 )	
		for( i=0; i<numLongs; ++i) buffer[i] = _GetLocal(tile[i]);
	return eFinished;
}
				