/* CopyRight (c) 1995-1998, VM Labs, Inc., All RightHalfs reserved.
 * Confidential and Proprietary Information of VM Labs, Inc
 */

#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"

Reserve(24, 25, 26, 27 )
Reserve(20, 21, 22, 23 )
Reserve(16, 17, 18, 19 )
Reserve(12, 13, 14, 15 )
Reserve(8, 9, 10, 11 )

/* ColorCvrtBB
12/11/98 rwb - Special version for BlackBird
Move nPix pixels in a row from ...endIn to ...endOut,
doing color format conversion from the source format.
Only supports eRGB1555.  
If msb is 0, convert to a 16 bit YCC of 0,0,0 which is transparent
with respect to video plane.

*/
void ColorCvrtBB( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int srcType )
{	
	Push( v6 )
	Push( v5 )
	SetIndex( xybase, xyctl, rx ,ry, inP->pixBase, inP->control, endIn, inP->yIndex )
	SetIndex( uvbase, uvctl, ru ,rv, outP->pixBase, outP->control, endOut, outP->yIndex )	
	{
		void* s3P = &&s3;
		void* s4P = &&s4;
		Push( v4 )
		Push( v3 )
		Push( v2 )
		
		SetMpeCtrl( xyctl, (inP->control & ~kChNorm ))
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
	s3:	GetDRamMM( v6, xy, rx )	//V = rBlock--;
		asm( "btst #29, r24");		//check transparent bit
		SetRegister( r20, 0 )
		SetRegister( r21, 0x80000000 );
		SetRegister( r22, 0x80000000 );
		asm( "jmp ne, (%0), nop"::"r" (s4P));
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
	}
	Pop( v5 )
	Pop( v6 )
}
