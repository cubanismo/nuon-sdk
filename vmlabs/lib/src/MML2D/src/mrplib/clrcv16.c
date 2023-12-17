
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* Color convert functions for RGB to YCC for the uunscaled
0RGB16 and 1RGB16 source cases.  Ideally these would be inline
but they use so many registers that there would be too few
registers left over for the compiler so the rest of the code
would be very bulky and therefore slow.  Until we have a pixel-aware
compiler, this is the best we can do.
*/ 
 
#include "pixmacro.h"
 Reserve(24, 25, 26, 27 )
  Reserve(20, 21, 22, 23 )
  Reserve(16, 17, 18, 19 )
  Reserve(12, 13, 14, 15 )
  Reserve( 8, 9, 10 ,11 )
#include "parblock.h"
#include "mrpproto.h"
/* Source is 0RGB16.  If source = trans, make pixel transparent.
*/
void ColCvrt0RGB16( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int trans )
{
	register short int* p;
	SetIndex( xybase, xyctl, rx ,ry, inP->pixBase, inP->control, endIn, inP->yIndex )
	SetIndex( uvbase, uvctl, ru ,rv, outP->pixBase, outP->control, endOut, outP->yIndex )	
 	SetMpeCtrl( xyctl, (inP->control & ~kChNorm ))
	p = (short int*)inP->pixBase + (inP->control & 0x7FF)*inP->yIndex + endIn;
	{
		Push( v6 )		
		Push( v5 )
		Push( v4 )
		Push( v3 )
		Push( v2 )
		SetFixed( r8, 0.257 )
		SetFixed( r9, 0.504 )
		SetFixed( r10, 0.098 )
		SetFixed( r12, 0.439 )
		SetFixed( r13, -0.368 )
		SetFixed( r14, -0.071 )
		SetFixed( r16, -0.148 )
		SetFixed( r17, -0.291 )
		SetFixed( r18, 0.439 )
		SetFixed( r27, 1.0 )
		SetRegister( r11, 33<<21 )
		SetRegister( r15, 1<<21 )
		SetRegister( r19, 1<<21 )				
		while( nPix-- > 0 )
		{				
			if( *p-- != trans ) goto s5;
		SetRegister( r20, 0 )
		SetRegister( r21, 0x80000000 )
		SetRegister( r22, 0x80000000 )
		asm( "addr #-1<<16, rx" :: );
		goto s4;
	s5:	GetDRamMM( v6, xy, rx )		//V = rBlock--;
		ShiftRegisterLeft( r24, 1 )	//msb is 0 in 0555 format
		DotPix( r20, v2, v6 )		//Z[0] = V * Y;
		DotPix( r21, v3, v6 )		//Z[1] = V * Cr;
		DotPix( r22, v4, v6 )		//Z[2] = V * Cb;
	s4:
		PutDRamMM( v5, uv, ru )	//wBlock-- = Z;
		DecCtr( rc0 )
		}
		Pop( v2 )
		Pop( v3 )
		Pop( v4 )
		Pop( v5 )
		Pop( v6 )
	}
}

/* Source is 1RGB16.  If msb is set, make pixel transparent.
*/
void ColCvrt1RGB16( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int transFlag )
{
	void* s3P = &&s3;
	void* s4P = &&s4;
	SetIndex( xybase, xyctl, rx ,ry, inP->pixBase, inP->control, endIn, inP->yIndex )
	SetIndex( uvbase, uvctl, ru ,rv, outP->pixBase, outP->control, endOut, outP->yIndex )	
 	SetMpeCtrl( xyctl, (inP->control & ~kChNorm ))
	{
		Push( v6 )		
		Push( v5 )
		Push( v4 )
		Push( v3 )
		Push( v2 )
		SetFixed( r8, 0.257 )
		SetFixed( r9, 0.504 )
		SetFixed( r10, 0.098 )
		SetFixed( r12, 0.439 )
		SetFixed( r13, -0.368 )
		SetFixed( r14, -0.071 )
		SetFixed( r16, -0.148 )
		SetFixed( r17, -0.291 )
		SetFixed( r18, 0.439 )
		SetFixed( r27, 1.0 )
		SetRegister( r11, 33<<21 )
		SetRegister( r15, 1<<21 )
		SetRegister( r19, 1<<21 )				
		Loop( rc0, nPix )
	s3:	GetDRamMM( v6, xy, rx )			//V = rBlock--;
		if( !transFlag ) goto s4;
		asm("btst #29, r24\n"
			"jmp ne, (%0)\n"
			 "mv_s #$80000000, r21\n"
			 "{ 
			 	mv_s #0, r20\n
			 	copy r21, r22
			  }"
			:: "r" (s4P)
			: "cc", "r20", "r21", "r22"
		    );
		ShiftRegisterLeft( r24, 1 )		//msb is 0 in 1555 format
		DotPix( r20, v2, v6 )		//Z[0] = V * Y;
		DotPix( r21, v3, v6 )		//Z[1] = V * Cr;
		DotPix( r22, v4, v6 )		//Z[2] = V * Cb;
	s4:
		PutDRamMM( v5, uv, ru )	//wBlock-- = Z;
		DecCtr( rc0 )
		Repeat( c0, s3P )
						//while( --nPix > 0 );
		Pop( v2 )
		Pop( v3 )
		Pop( v4 )
		Pop( v5 )
		Pop( v6 )
	}
}
