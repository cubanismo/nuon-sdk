/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/* rwb 12/15/98
 * MRP functions that reserve v6 and v5
 */
 
#include "mrpproto.h"
#include "pixmacro.h"
#include "parblock.h"
Reserve( 24, 25, 26, 27 )
Reserve( 20, 21, 22, 23 )

/* return an int which is a color in same format as foreColor
and backColor and which = ((mask+1)*foreColr + (63-mask)*backColor)/64

DO LATER
8 bit pixels
*/
int blendPix( int mask, mmlColor* foreColorP, mmlColor* backColorP, int linCtrl )
{
	int rval, back;
	int oneDiv64 = 0x01000000;  /* 1/64 in 2.30 format  */
	Push( v5 )
	Push( v6 )
	mask += 1;
	mask &= ~1;
	mask <<= 16;
	back = (64<<16) - mask;
	SetMpeCtrl( linpixctl, linCtrl );
	LoadPix( v5, foreColorP )
	LoadPix( v6, _GetLocal(backColorP) )
	MulPix( v5, oneDiv64 )
	MulPix( v6, oneDiv64 )
	MulPixInt( v5, mask, v5 )
	MulPixInt( v6, back, v6 )
	AddPix( v6, v5 )
	StorePix( v5, &rval );
	Pop( v6 )
	Pop( v5 )
	return rval;
}
		
/* return an int which is a color in same format as foreColor
and backColor and which = ((mask+1)*foreColr + (63-mask)*backColor)/64
AND set alpha value to min( foreAlpha, backAlpha );
*/
int blendPixAlpha( int mask, mmlColor* foreColorP, mmlColor* backColorP, int linCtrl )
{
	int rval, back;
	int oneDiv64 = 0x01000000;  /* 1/64 in 2.30 format  */
	Push( v5 )
	Push( v6 )
	mask += 1;
	mask &= ~1;
	mask <<= 16;
	back = (64<<16) - mask;
	SetMpeCtrl( linpixctl, linCtrl );
	LoadPixZ( v5, foreColorP )
	LoadPixZ( v6, _GetLocal(backColorP) )
	MulPix( v5, oneDiv64 )
	MulPix( v6, oneDiv64 )
	MulPixInt( v5, mask, v5 )
	MulPixInt( v6, back, v6 )
	AddPix( v6, v5 )
	asm(
	" nop\n"
	" lsr #24,r23\n"
	" lsr #24,r27\n"
	" cmp r23, r27\n"
	" bra ge, `lab, nop \n"
	" mv_s r27,r23 \n"
	" `lab: lsl #24,r23 \n"
	::);
	/*
	C equif of asm, but optimization screws up c code
	GetRegister( r23, rval )
	GetRegister( r27, back )
	rval = (rval>>24) & 0xFF;
	back = (back>>24) & 0xFF;
	if( back < rval ) MoveRegister( r27, r23 )
	*/
	StorePixZ( v5, &rval );
	Pop( v6 )
	Pop( v5 )
	return rval;
}
		
