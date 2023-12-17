
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"

Reserve(24, 25, 26, 27 )
Reserve(20, 21, 22, 23 )
Reserve(16, 17, 18, 19 )
Reserve(12, 13, 14, 15 )
Reserve(8, 9, 10, 11 )

/* ColorCvrt
Move nPix pixels in a row from ...endIn to ...endOut,
doing color format conversion from the source format
to pixel type 4 (e888Alpha).  If src format is already e888Alpha,
this is just a move in the tile getting ready for horizontal scaling.
	Only supports source formats of 888Alpha, 8bitClut, and 16bit RGB 0:5:5:5
	Does not support 655ycc or GRB or 1555alphaRGB
11/24/98 Should never be called if source has transparent pixels.
	However, if called on 16bit RGB1555 format pixels, set the msb to 0.
7/29/99 Bugfix - 888Alpha to 888Alpha were not copying alpha.
*/
void ColorCvrt( indexBlock* inP, indexBlock* outP, int nPix, int endIn, int endOut, int srcType )
{	
	Push( v6 )
	Push( v5 )
	SetIndex( xybase, xyctl, rx ,ry, inP->pixBase, inP->control, endIn, inP->yIndex )
	SetIndex( uvbase, uvctl, ru ,rv, outP->pixBase, outP->control, endOut, outP->yIndex )
	
	if( srcType == e888Alpha )	/* 888Alpha */
	{
		void* s1P = &&s1;
		if( endIn == endOut ) goto exit;
		Loop( rc0, nPix )
	s1:	GetDRamAlphaMM( v6, xy, rx )	//V = rBlock--;
		PutDRamAlphaMM( v6, uv, ru )	//wBlock-- = V;
		DecCtr( rc0 )
		Repeat( c0, s1P )
	}					//while( --nPix > 0 );
	else if( srcType == eClut8 ) /* 8 bit clut */
	{
		void* s2P = &&s2;
		void* s25P = &&s25;
		SetMpeCtrl( clutbase, inP->clutBase )	
		Loop( rc0, nPix )
	s2:	GetDRamMM( v6, xy, rx )		//V = rBlock--;
		GetDRamAlphaInd( v6, r24 )		//V = *V[0];
		PutDRamAlphaMMDec( v6, uv, ru, rc0 )	//wBlock-- = V;
		Break( c0, s25P )
		GetDRamMM( v5, xy, rx )		//V = rBlock--;
		GetDRamAlphaInd( v5, r20 )		//V = *V[0];
		PutDRamAlphaMMDec( v5, uv, ru, rc0 )	//wBlock-- = V;
		Repeat( c0, s2P )
	s25:
						//}while( --nPix > 0 );
	}
	else if( srcType == eRGB0555 ||
		 srcType == eRGBAlpha1555 ) /* 16 bit RGB */
	{
		void* s3P = &&s3;
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
		asm (" bclr #29, r24");       // clear any tranaparent bit
		ShiftRegisterLeft( r24, 1 )	//msb is 0 in 1555 format
		DotPix( r20, v2, v6 )		//Z[0] = V * Y;
		DotPix( r21, v3, v6 )		//Z[1] = V * Cr;
		DotPix( r22, v4, v6 )		//Z[2] = V * Cb;
		PutDRamMM( v5, uv, ru )	//wBlock-- = Z;
		DecCtr( rc0 )
		Repeat( c0, s3P )
						//}while( --nPix > 0 );
		Pop( v2 )
		Pop( v3 )
		Pop( v4 )
	}
exit:
	Pop( v5 )
	Pop( v6 )
}
