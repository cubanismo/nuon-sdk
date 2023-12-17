
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* File of static inline functions to be included in all
bicopy files.  All functions CLOBBER v6.
rwb 2/8/99
*/ 

#include <stdio.h>
#include "../../nuon/mml2d.h"
#include "mrpproto.h"

/*-------------------------------------------------------------------------------------------------
	MoveTileRow
	Move num pixels in block from srcBeg to dstBeg.
	Row is specified in Block object
	pixels are format 4 in dtram tile block.
-------------------------------------------------------------------------------------------------*/
static inline void MoveTileRowI( indexBlock* rBlockP, int srcBeg, int dstBeg, int num )
{
	void* againP = &&again;
	
	if( srcBeg == dstBeg || num == 0 ) return;
	SetIndex(xybase,xyctl,rx,ry,rBlockP->pixBase, rBlockP->control, srcBeg, rBlockP->yIndex )
	SetIndex(uvbase,uvctl,ru,rv,rBlockP->pixBase, rBlockP->control, dstBeg, rBlockP->yIndex )
	Loop( rc0, num )
again:
	GetDRamAlphaPP( v6, xy, rx )
	PutDRamAlphaPPDec( v6, uv, ru, rc0)
	Repeat( c0, againP )
}


/*-------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------*/
static inline void mrpSysRamMoveI
(
	int				numScalars,
	char*			internAdr,
	char*			srcAdr, 
	odmaCmdBlock*	odmaP,
	int				readQ,
	int				waitQ
)
{
	MRP_DmaWait( kodmactl );
	if( numScalars <= 0 )
	{
		return;
	}
	SL( odmaP->flags,   readQ | (numScalars << 16) );
	SL( odmaP->sysAdr,  srcAdr                     );
	SL( odmaP->dramAdr, internAdr                  );
	MRP_DmaDo( kodmactl, odmaP, 1 );
}



/*-------------------------------------------------------------------------------------------------
	Write a row to SDRAM, double-buffered. 
	- dstType includes pixType already shifted and cluster bit if applicable
-------------------------------------------------------------------------------------------------*/
static inline void DmaWriteRowI
(
	char*			tileBase,
	int				numPixels, 
 	char*			screenBase,
	int				screenStridePix,
	int				dLeft,
	int				dTop,
	int				dstType,
 	mdmaCmdBlock*	mdmaP
)
{
	if( numPixels == 0 )
	{
		return;
	}

	MRP_DmaWait( kmdmactl );
	_SetLocalVar( mdmaP->flags,    ((screenStridePix>>3)<<16) | kPixWrite | dstType );
	_SetLocalVar( mdmaP->xDesc,    (numPixels<<16) | dLeft                          );
	_SetLocalVar( mdmaP->yDesc,    (1<<16) | dTop                                   );
	_SetLocalVar( mdmaP->dramAdr,  tileBase                                         );
	_SetLocalVar( mdmaP->sdramAdr, screenBase                                       );
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
}


/*-------------------------------------------------------------------------------------------------
	Read a row from SDRAM. 
	srcType includes pixType already shifted and cluster bit if applicable
-------------------------------------------------------------------------------------------------*/
static inline void DmaReadRowI
(
	char*			tileBase,
	int				numPixels, 
 	void*			screenBase,
	int				screenStridePix,
	int				dLeft,
	int				dTop,
	int				srcType,
 	mdmaCmdBlock*	mdmaP
)
{
	if (numPixels == 0)
	{
		return;
	}

	MRP_DmaWait( kmdmactl );			
	_SetLocalVar( mdmaP->flags,    ((screenStridePix>>3)<<16) | kPixRead | srcType );
	_SetLocalVar( mdmaP->xDesc,    (numPixels<<16) | dLeft                         );
	_SetLocalVar( mdmaP->yDesc,    (1<<16) | dTop                                  );
	_SetLocalVar( mdmaP->dramAdr,  tileBase                                        );
	_SetLocalVar( mdmaP->sdramAdr, screenBase                                      );
	MRP_DmaDo( kmdmactl, mdmaP, 1 );
}
