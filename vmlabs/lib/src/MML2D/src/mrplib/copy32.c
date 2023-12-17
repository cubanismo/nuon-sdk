
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 6/24/99
 * MRP function for copy from e888alpha AppPixmap to 655 Display Pixmap
 * bot leftCol's must be even, and rowLength must be even.
 */

#include "../../nuon/mml2d.h"
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
#include <stddef.h>

typedef struct Copy32to16ParamBlock Copy32to16ParamBlock;
struct Copy32to16ParamBlock
{
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


/*-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------*/
mrpStatus Copy32to16(int environs, Copy32to16ParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	odmaCmdBlock*			odmaP;
 	mdmaCmdBlock*			mdmaP;
 	Copy32to16ParamBlock*	parP;
 	uint8*					tileBase;
 	int						srcAdr;
 	int						writeRow;
 	int						endRow;
 	int						parSizeLongs;
	int						mrpsetupstatus;

 	/* Set up local dtram & read in parameter block or  */
 	parSizeLongs = (sizeof(Copy32to16ParamBlock)+3)>>2;
 	mrpsetupstatus = 	mrpSetup
						(
							environs,
							parSizeLongs,
							&odmaP,
							&mdmaP,
							(int**)&parP,
							&tileBase,
							NULL 
						);
 	if (mrpsetupstatus)
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

 #ifdef BB /* another hack for maui */
 	_SetLocalVar( parP->destBufferAdr , kGraphicsBase);
 #endif

	srcAdr =	  _GetLocal( parP->srcBufferAdr )
				+ _GetLocal( parP->srcByteWidth ) * _GetLocal( parP->srcTopRow )
				+ (_GetLocal(parP->srcLeftCol)<<2);
	writeRow = _GetLocal( parP->destTopRow );
	endRow = writeRow + _GetLocal( parP->numRows );
 	MRP_DmaWait( kodmactl );

	_SetLocalVar( odmaP->dramAdr, tileBase );
  	MRP_DmaWait( kmdmactl );
	_SetLocalVar( mdmaP->dramAdr, tileBase );
	_SetLocalVar( mdmaP->sdramAdr, _GetLocal( parP->destBufferAdr ));
	_SetLocalVar( mdmaP->flags, _GetLocal( parP->destFlags));
	while( writeRow < endRow )
	{
		int pixToDo = _GetLocal(parP->rowLength);
		int dstStart = _GetLocal(parP->destLeftCol);
		int srcStart = srcAdr;
		while (pixToDo > 0)
		{
			int segSize = pixToDo > kMaxLongs ? kMaxLongs : pixToDo;
			_SetLocalVar( odmaP->sysAdr, srcStart );
			_SetLocalVar( odmaP->flags, 0x2000 | (segSize<<16));
			MRP_DmaDo( kodmactl, odmaP, 1 );
			_SetLocalVar( mdmaP->xDesc, segSize<<16 | dstStart );
			_SetLocalVar( mdmaP->yDesc, 1<<16 | writeRow );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			dstStart += segSize;
			srcStart += (segSize<<2);
			pixToDo -= segSize;
		}
		++writeRow;
		srcAdr += _GetLocal( parP->srcByteWidth );
	}
	return eFinished;
}

/*-------------------------------------------------------------------------------------------------
	CopyRectFast
	- Copy a block of pixels from sysRam to SDRAM.
	- No color conversion or expansion is done.
	- No scaling is done.
	- Format Translations are:
		e888Alpha	to	e888Alpha
		e888Alpha	to	e655
		e655		to	e655
		e8Clut		to	e8Clut 
	- Source left column must start on long word boundary
	- Destination left column must start on long word boundary
	- The width of the source block in bytes must be a multiple of 4.
-------------------------------------------------------------------------------------------------*/
mrpStatus CopyRectFast( int environs, CopyRectFastParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	odmaCmdBlock*			odmaP;
 	mdmaCmdBlock*			mdmaP;
 	CopyRectFastParamBlock*	parP;
 	uint8*					tileBase;
 	int						srcAdr;
 	int						writeRow;
 	int						endRow;
 	int						maxPix;
 	int						parSizeLongs = (sizeof(CopyRectFastParamBlock)+3) >> 2;
	int						mrpSetupStat;
	int						expand = 0;

 	/* Set up local dtram & read in parameter block or  */
	mrpSetupStat = mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, NULL );
	if (mrpSetupStat)
	{
		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
	}
	else 
	{
		parP = parBlockP;	
	}
 /* another hack for maui */
 #ifdef BB
 	_SetLocalVar( parP->destBufferAdr , kGraphicsBase);
 #endif
	srcAdr = _GetLocal( parP->srcBufferAdr )
	       + _GetLocal( parP->srcByteWidth ) * _GetLocal( parP->srcTopRow )
	       + (_GetLocal(parP->srcLeftCol) << (2 - _GetLocal( parP->srcPixShift ))  );
	writeRow = _GetLocal( parP->destTopRow );
	endRow = writeRow + _GetLocal( parP->numRows );
	if( _GetLocal( parP->srcPixShift ) == 1 && (_GetLocal( parP->destFlags ) & 0xF0) == 0x40 )
		expand = 1;
 	MRP_DmaWait( kodmactl );
	_SetLocalVar( odmaP->dramAdr, tileBase );

  	MRP_DmaWait( kmdmactl );
	_SetLocalVar( mdmaP->dramAdr , tileBase );
	_SetLocalVar( mdmaP->sdramAdr , _GetLocal( parP->destBufferAdr ));
	_SetLocalVar( mdmaP->flags, _GetLocal( parP->destFlags));
	maxPix = kMaxLongs << _GetLocal( parP->srcPixShift );
	while( writeRow < endRow )
	{
		int pixToDo = _GetLocal(parP->rowLength);
		int dstStart = _GetLocal(parP->destLeftCol);
		int srcStart = srcAdr;
		int segSize = maxPix;
		_SetLocalVar( mdmaP->yDesc, 1<<16 | writeRow );
		_SetLocalVar( odmaP->flags, 0x2000 | ((segSize>>_GetLocal(parP->srcPixShift))<<16));
		while( pixToDo > 0 )
		{
			if( pixToDo < maxPix )
			{
				segSize = pixToDo;
				_SetLocalVar( odmaP->flags, 0x2000 | ((segSize>>_GetLocal(parP->srcPixShift))<<16));
			}	
			_SetLocalVar( odmaP->sysAdr, srcStart );
			MRP_DmaDo( kodmactl, odmaP, 1 );
			if( expand )
			{
				uint16* p = (uint16*)tileBase + segSize;
				uint32* q = (uint32*)tileBase + segSize;
				int j;
				for(j=0; j<segSize; ++j )
				{
					int val = *--p;
					int y = val & 0xFC00;
					int cr = val & 0x3E0;
					int cb = val & 0x1F;
					*--q = (y<<16) | (cr<<14) | (cb<<11);
				}
			}
			_SetLocalVar( mdmaP->xDesc, segSize<<16 | dstStart );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			dstStart += segSize;
			srcStart += ((segSize>>_GetLocal(parP->srcPixShift))<<2);
			pixToDo -= segSize;
		}
		++writeRow;
		srcAdr += _GetLocal( parP->srcByteWidth );
	}
	return eFinished;
}

/*-------------------------------------------------------------------------------------------------
	CopyRect16
	rwb 7/10/01
	- Use only for copying 16bit pixels to 16bit pixels
	- Copy a block of pixels from sysRam to SDRAM.
	- No color conversion or expansion is done.
	- No scaling is done.
	- No Format Translations are done:
	- Source left column may start on any 16 bit word boundary
	- Destination left column may start on any 16-bit word boundary
	- The width of the source block may be any number of pixels.
-------------------------------------------------------------------------------------------------*/
mrpStatus CopyRect16( int environs, CopyRectFastParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	odmaCmdBlock*			odmaP;
 	mdmaCmdBlock*			mdmaP;
 	CopyRectFastParamBlock*	parP;
 	uint8*					tileBase;
 	int						srcAdr;
 	int						writeRow;
 	int						endRow;
 	int						parSizeLongs = (sizeof(CopyRectFastParamBlock)+3) >> 2;
	int						mrpSetupStat;

 	/* Set up local dtram & read in parameter block or  */
	mrpSetupStat = mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, NULL );
	if (mrpSetupStat)
	{
		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
	}
	else 
	{
		parP = parBlockP;	
	}
	srcAdr = _GetLocal( parP->srcBufferAdr )
	       + _GetLocal( parP->srcByteWidth ) * _GetLocal( parP->srcTopRow )
	       + (_GetLocal(parP->srcLeftCol) << 1  );
	writeRow = _GetLocal( parP->destTopRow );
	endRow = writeRow + _GetLocal( parP->numRows );
 	MRP_DmaWait( kodmactl );
	_SetLocalVar( odmaP->dramAdr, tileBase );

  	MRP_DmaWait( kmdmactl );
	_SetLocalVar( mdmaP->dramAdr , tileBase );
	_SetLocalVar( mdmaP->sdramAdr , _GetLocal( parP->destBufferAdr ));
	_SetLocalVar( mdmaP->flags, _GetLocal( parP->destFlags));
	while( writeRow < endRow )
	{
		int	oddStart = 0;
		int pixToDo = _GetLocal(parP->rowLength);
		int longsToDo = (pixToDo + 1)>>1;
		int dstStart = _GetLocal(parP->destLeftCol);
		int srcStart = srcAdr;
		_SetLocalVar( mdmaP->yDesc, 1<<16 | writeRow );
		while( longsToDo > 0 )
		{
			int segSize, longSize;
			if( srcStart & 0x2 )  // odd start
			{
				longSize = 1;
				segSize = 1;
				srcStart &= ~0x3;
				oddStart = 1;
				if(! (pixToDo & 1) ) ++longsToDo;
			}		
			else if( longsToDo < kMaxLongs )
			{
				longSize = longsToDo;
				segSize  = pixToDo;
			}
			else
			{
				longSize = kMaxLongs;
				segSize = kMaxLongs<<1;
			}
			_SetLocalVar( odmaP->flags, 0x2000 | (longSize<<16));
			_SetLocalVar( odmaP->sysAdr, srcStart );
			MRP_DmaDo( kodmactl, odmaP, 1 );
			if( oddStart )
			{
				_SetLocalVar( tileBase, _GetLocal( tileBase ) << 16 );
				oddStart = 0;
				srcStart += 2;
			}
			else
			{
				srcStart += (longSize<<2);
			}
			_SetLocalVar( mdmaP->xDesc, segSize<<16 | dstStart );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			dstStart += segSize;
			pixToDo -= segSize;
			longsToDo -= longSize;
		}
		++writeRow;
		srcAdr += _GetLocal( parP->srcByteWidth );
	}
	return eFinished;
}

/*-------------------------------------------------------------------------------------------------
	CopyRGBFast
	- Copy a block of eRGB0555 pixels from sysRam and convert to YCC655 in SDRAM.
	- No scaling is done.
	- Transparent pixels are not supported
-------------------------------------------------------------------------------------------------*/
mrpStatus CopyRGBFast( int environs, CopyRectFastParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	odmaCmdBlock*			odmaP;
 	mdmaCmdBlock*			mdmaP;
 	CopyRectFastParamBlock*	parP;
 	uint8*					tileBase;
 	int						srcAdr;
 	int						writeRow;
 	int						endRow;
 	int						parSizeLongs = (sizeof(CopyRectFastParamBlock)+3) >> 2;
	int						mrpSetupStat;

 	/* Set up local dtram & read in parameter block or  */
	mrpSetupStat = mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &tileBase, NULL );
	if (mrpSetupStat)
	{
		mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
	}
	else 
	{
		parP = parBlockP;	
	}
 /* another hack for maui */
 #ifdef BB
 	_SetLocalVar( parP->destBufferAdr , kGraphicsBase);
 #endif
	srcAdr = _GetLocal( parP->srcBufferAdr )
	       + _GetLocal( parP->srcByteWidth ) * _GetLocal( parP->srcTopRow )
	       + (_GetLocal(parP->srcLeftCol) << 1 );
	writeRow = _GetLocal( parP->destTopRow );
	endRow = writeRow + _GetLocal( parP->numRows );
 	MRP_DmaWait( kodmactl );  
	_SetLocalVar( odmaP->dramAdr, tileBase );

  	MRP_DmaWait( kmdmactl );
	_SetLocalVar( mdmaP->dramAdr , tileBase );
	_SetLocalVar( mdmaP->sdramAdr , _GetLocal( parP->destBufferAdr ));
	_SetLocalVar( mdmaP->flags, _GetLocal( parP->destFlags));
	SetIndex( xybase, xyctl, rx ,ry, tileBase, 2<<20, 0, 1 )
	SetIndex( uvbase, uvctl, ru ,rv, tileBase, (4<<20) | (1<<28), 0, 1 )
	while( writeRow < endRow )
	{
		int pixToDo = _GetLocal(parP->rowLength);
		int dstStart = _GetLocal(parP->destLeftCol);
		int srcStart = srcAdr;
		_SetLocalVar( mdmaP->yDesc, 1<<16 | writeRow );
		_SetLocalVar( odmaP->flags, 0x2000 | (kMaxLongs<<16));
		copyfast16A( pixToDo, srcStart, dstStart, odmaP, mdmaP );
		++writeRow;
		srcAdr += _GetLocal( parP->srcByteWidth );
	}
	return eFinished;
}
