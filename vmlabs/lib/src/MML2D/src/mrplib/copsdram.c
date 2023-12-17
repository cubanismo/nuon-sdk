/*
   Copyright (c) 1995-1999, VM Labs, Inc., All rights reserved.
   Confidential and Proprietary Information of VM Labs, Inc.
   These materials may be used or reproduced solely under an express
   written license from VM Labs, Inc.
*/
/* CopySDRAM - rwb 6/9/99
 * Copy rect from any display pixmap to any display pixmap.
 * destination can be 16 bit or 32 bit.
 * source can be 16 bit or 32 bit.
 * if source is 32 bit, alpha value can be used for blending.
 * No Color Conversion in first version
 *     So, no point in double buffering.
 * No aspect-ratio correction required
 * No anti-flicker filtering required.
 */
 
#include <stddef.h>
#include "../../nuon/mml2d.h"
#include "pixmacro.h"
Reserve(20, 21, 22, 23 )
Reserve(24, 25, 26, 27 )
#include "parblock.h"
#include "mrpproto.h"
#include "mrp6in.c"

#define MAXDMALONGS 32

 
/*-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------*/
mrpStatus CopySDRAM(int environs, CopySDRAMParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	odmaCmdBlock*			odmaP;
 	mdmaCmdBlock*			mdmaP;
 	CopySDRAMParamBlock*	parP;
 	uint32*					buf;
	int						linCtrl = (e888Alpha<<20) | kChNorm;
	int						numRows;
	int						rowLength;
	int						i;
	int						k;
	int						srcStarty;
	int						dstStarty;
	int						numPixToDo;
	int						blend;
	int						segLength;
	int						srcStartx;
	int						dstStartx;
	int						incx;
	int						incy;
	int						srcBeginy;
	int						dstBeginy;
	int						srcBeginx;
	int						dstBeginx;
 	int						parSizeLongs;

		/* Set up local dtram & read in parameter block */
 	parSizeLongs = (sizeof(CopySDRAMParamBlock)+3)>>2;
 	if (mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, (uint8**)&buf, NULL ) )
	{
  		mrpSysRamMove
		(
			parSizeLongs,
			(char*)parP,
			(char*)parBlockP,
			odmaP,
			kSysReadFlag,
			kWaitFlag
		);
	}
  	else
	{
		parP = parBlockP;
	}
	MRP_DmaWait( kodmactl );
		
	numRows =	_GetLocal(parP->srcHighPix) < _GetLocal(parP->dstHighPix) ?
				_GetLocal(parP->srcHighPix) : _GetLocal(parP->dstHighPix);
	rowLength =	_GetLocal(parP->srcWidePix) < _GetLocal(parP->dstWidePix) ?
				_GetLocal(parP->srcWidePix) : _GetLocal(parP->dstWidePix);
	blend = _GetLocal( parP->blend );
	srcBeginy = _GetLocal(parP->srcTopStartPix);
	dstBeginy = _GetLocal(parP->dstTop);
	incy = 1;
	if (srcBeginy < dstBeginy)
	{
		srcBeginy += numRows-1;
		dstBeginy += numRows-1;
		incy = -1;
	}
	srcBeginx = _GetLocal(parP->srcLeftStartPix);
	dstBeginx = _GetLocal(parP->dstLeft);
	incx = 1;
	if (srcBeginx < dstBeginx)
	{
		srcBeginx += rowLength;
		dstBeginx += rowLength;
		incx = -1;
	}
	srcStarty = srcBeginy;
	dstStarty = dstBeginy;
	for (i=0; i<numRows; ++i)
	{
		numPixToDo = rowLength;
		srcStartx = srcBeginx;
		dstStartx = dstBeginx;
		while (numPixToDo > 0)
		{
			segLength = numPixToDo < MAXDMALONGS ? numPixToDo : MAXDMALONGS;
			if (incx == -1)
			{
				srcStartx -= segLength;
				dstStartx -= segLength;
			}			
			DmaReadRowI
			(
				(uint8*)buf,
				segLength,
				(void*)_GetLocal(parP->srcBase),
				_GetLocal(parP->srcStrideBytes),
				 srcStartx,
				 srcStarty,
				 _GetLocal(parP->srcPixType),
				 mdmaP
			);
			if (blend)
			{ 
				DmaReadRowI
				(
					(uint8*)(buf+MAXDMALONGS),
					segLength,
					(void*)_GetLocal(parP->dstBase), 
					_GetLocal(parP->dstStrideBytes),
					dstStartx,
					dstStarty,
					_GetLocal(parP->dstPixType),
					mdmaP
				);
				for (k=0; k<segLength; ++k)
/*				{
					int mask = (*(buf+k) & 0xFF) >> 2;
					if( blend == 2 )
						*(buf+k) = blendPixAlpha(mask, buf + MAXDMALONGS + k, buf + k , linCtrl );
					else
					*(buf+k) = blendPix(mask, buf + MAXDMALONGS + k, buf + k , linCtrl ) & ~0xFF;
				}
*/
				{
					uint32* tempP = buf+k;
					uint32 temp = _GetLocal(*tempP);
					int mask = (temp & 0xFF) >> 2;
					if( blend == 2 )
						temp = blendPixAlpha(mask, (mmlColor*) (buf + MAXDMALONGS + k), (mmlColor*) (buf + k) , linCtrl );
					else
						temp = blendPix(mask, (mmlColor*) (buf + MAXDMALONGS + k), (mmlColor*) (buf + k) , linCtrl ) & ~0xFF;
					_SetLocalVar(*tempP, temp );
				}
			}
			DmaWriteRowI
			(
				(uint8*)buf,
				segLength,
				(void*)_GetLocal(parP->dstBase), 
				_GetLocal(parP->dstStrideBytes),
				dstStartx,
				dstStarty,
				_GetLocal(parP->dstPixType),
				mdmaP
			);
			numPixToDo -= segLength;
			if (incx == 1)
			{
				srcStartx += segLength;
				dstStartx += segLength;
			}
		}
		srcStarty += incy;
		dstStarty += incy;
	}	
	return eFinished;
}	
