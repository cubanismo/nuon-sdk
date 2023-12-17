
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

; include files for the 32 bit versions of the math tables
;==============================================================
	.segment	text
	.align.v
;==============================================================
RecipLUT_32:		.include    "_reciplut.i"
;SineLUT:		.include    "_sinelut.i"
RSqrtLUT_32:		.include    "_rsqrtlut.i"

	.export		RecipLUT_32
;	.export		SineLUT
	.export		RSqrtLUT_32
;=============================
