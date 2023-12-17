
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 12/9/99
 * Copytile - Special version of copy from 8 bit indexed color to
 * 16 bit framebuffer.  Copy is unscaled, and is from the upper
 * left quadrant.  I.E. The entire array of indices is copied unless
 * it has to be clipped on the right or bottom.  
 * Pixels with the index value Transparent are not copied.
 * Assumes a YCC CLUT in Sysram that is 1024-byte aligned.
 * Can be trivially changed to 32 bit framebuffer
 * There is no loss of generality by assuming the upper left quadrant.
 Top and left clipping is accomplished by just changing the srcAdr.
 Note that srcAdr can point to any byte position, it does not need to
 be long aligned.
 */

#include "pixmacro.h"
#include "parblock.h"
#include "mrpproto.h"
#include <stddef.h>
#include "../../nuon/mml2d.h"

#define kMaxPix 64

/* function to read 8 bit values from dtram buffer, convert to
32 bit ycc values,  in dtram
buffer. 
ry & rv are already all set to 0
xybase is already pointing at 8bit buffer
uvbase is already pointing at 32bit buffer
xyctl and uvctl are already set correctly
Function sets rx to leftOffset and ru to 0;
*/
static inline void cvrt( int numpix,  int leftOffset );
static inline void cvrt( int numpix,  int leftOffset )
{
register int num = numpix;
register int left = leftOffset;
__asm__ volatile( 
		"			sub		r3, r3\n"
		"			mvr		%1, rx\n"
		"{\n"
		"			mvr		r3, ru\n"
		"			st_s	%0, rc0\n"
		"}\n" 
		"`10:		ld_p	(xy), v1\n"
		"			addr 	#1<<16, rx\n"
		"			ld_p	(r4), v1\n"
		"			nop\n"
		"			st_p	v1, (uv)\n"
		"{			addr 	#1<<16, ru\n"
		"			dec		rc0\n"
		"}\n"
		"			bra		c0ne, `10,nop\n"
		:: "r"(num), "r"(left)
		:"r3","r4","r5","r6","r7","cc"
	);
}

mrpStatus CopyTileAll(int environs, CopyTileParamBlock* parBlockP, int arg2, int arg3 ) 
{
 	CopyTileParamBlock* parP;
 	uint8* buf8P;
	odmaCmdBlock* odmaP;
	mdmaCmdBlock* mdmaP;
	uint32*	buf32P;
	int control, row, srcRectHigh, pixLeftOffset, odmaFlags, xDesc, yDesc, mdmaFlags;
	uint8 *srcRowStart, *srcAdr, *dAdr;	
		
 	int parSizeLongs = (sizeof(CopyClutParamBlock)+3)>>2;

 	mrpSetup( environs, parSizeLongs, &odmaP, &mdmaP, (int**)&parP, &buf8P, NULL );
#if USE_DISPATCHER == 1
	mrpSysRamMove( parSizeLongs, (char*)parP, (char*)parBlockP, odmaP, kSysReadFlag, kWaitFlag );
	#define GL( x ) _GetLocal( parP->x )
#else 
	parP = parBlockP;
	#define GL( x ) ( parP->x )
#endif	
 /* another hack for maui */
#ifdef BB
 	_SetLocalVar( parP->destAdr , kGraphicsBase);
#endif
	buf32P = (uint32*)buf8P + ((kMaxPix+4)>>2);
	SetMpeCtrl( clutbase, GL(clutAdrTrans) )	
	SetMpeCtrl( linpixctl, (e888Alpha << 20 ) | kChNorm ) 
    control = eClut8 << 20 | GL(srcRectWide)  ; /* In DTRAM, pixtype is always 888Alpha */
	SetIndex( xybase, xyctl, rx ,ry, buf8P, control, 0, 0 )
    control = e888Alpha << 20 | GL(srcRectWide) | kChNorm  ; /* In DTRAM, pixtype is always 888Alpha */
	SetIndex( uvbase, uvctl, ru ,rv, buf32P, control, 0, 0 )
		
	dAdr = GL(destAdr);
	mdmaFlags = GL(destFlags);
	row = GL( destTopRow );
	srcRowStart = GL(srcArrayAdr);
	pixLeftOffset = (int)srcRowStart & 0x3;
	srcRowStart = (uint8*)((int)srcRowStart & ~0x3);
	srcRectHigh = GL(srcRectHigh); 
	MRP_DmaWait( kmdmactl );
	MRP_DmaWait( kodmactl );
	while( srcRectHigh-- > 0 )
	{
		int pixToDo = GL(srcRectWide);
		int destLeftX = GL( destLeftCol );
		yDesc = 1<<16 | row;
		srcAdr = srcRowStart;
		while( pixToDo > 0 )		
		{
			// Read Dest buf 16 to 32
			int numPix = pixToDo > kMaxPix ? kMaxPix : pixToDo;
			xDesc = numPix<<16 | destLeftX;
			// Read Source buf 8
			odmaFlags = BitRead | ((numPix+4) & ~3)<<14; //read 4 extra pixels
			SL( odmaP->flags,  odmaFlags );
			SL( odmaP->sysAdr, srcAdr    );
			SL( odmaP->dramAdr, buf8P    );
			MRP_DmaDo( kodmactl, odmaP, 1 );
			// Convert Source buf 8 to 32
			cvrt( numPix, pixLeftOffset );			

			// Write Dest buf 32 to 16 or 32 bit dest.
			SL( mdmaP->flags,    mdmaFlags );
			SL( mdmaP->xDesc,    xDesc     );
			SL( mdmaP->yDesc,    yDesc     );
			SL( mdmaP->sdramAdr, dAdr     );
			SL( mdmaP->dramAdr,  buf32P     );
			MRP_DmaDo( kmdmactl, mdmaP, 1 );
			// More pixels on this row?
			pixToDo -= numPix;
			srcAdr += numPix;
			destLeftX += numPix;
		}		 		
		srcRowStart += GL( srcPixStride );
		++row;
	}
	return eFinished;
}