
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/


/*
	EXTERN_C void inner2(int nRows, int numPix, uint16* srcStart, uint16* dstStart,
	 odmaCmdBlock* odmaP, mdmaCmdBlock* mdmaP )
	An inner loop that
		reads 1 rows of 0555RGB pixels from sysRam into DTRAM
	 	cvrts 0555RGB pixels in DTRAM to 8888YCC pixels
	 	writes  1 rows to sdRam as e655 pixels
	 	r31 is preserved throughout
	 version C - make it work for odd pixel boundaries in source pix map
*/
        .export     _copyfast16A
		.segment	text
		.align.v
        .cache
/* register names */
temp0 = r0
temp1 =	r1
temp2 =	r2
odmaP =	r3
mdmaP =	r4
srcStart = r5	// start column in source pixmap
dstStart = r6	// start column in destination pixmap
segSize = r7	// number of pixels in a single dma transfer
numPix = r28	// width of row in pixels
xudec = r29		// adjust end of rows in dtram: x10000 for even start, 0 for odd start
rc0dec = r30	// if src is odd and npix > 64, only process 63 pix the first time
/* constants */
kMaxPix = 64
OsysAdrOff = 4
MxDescOff = 8
kodmactl = $20500500		
kmdmactl = $20500600
_copyfast16A:
		sub		#16,r31
		st_v	v2,(r31)
		sub		#16,r31
		st_v	v3,(r31)
		sub		#16,r31
		st_v	v4,(r31)
		sub		#16,r31
		st_v	v5,(r31)
		sub		#16,r31
		st_v	v6,(r31)
		push	v7,rz		
		mv_s	temp0,numPix
		mv_s	temp1,srcStart
		mv_s	temp2,dstStart
//		mv_s	#fix(0.514,30),r8
		mv_s	#fix(0.257,30),r8
		mv_s	#fix(0.504,30),r9
		mv_s	#fix(0.098,30),r10
		mv_s	#(33<<21),r11
//		mv_s	#fix(0.878,30),r12
		mv_s	#fix(0.439,30),r12
		mv_s	#fix(-0.368,30),r13
		mv_s	#fix(-0.071,30),r14
		mv_s	#(1<<21),r15
		mv_s	#fix(-0.148,30),r16
//		mv_s	#fix(-0.296,30),r16
		mv_s	#fix(-0.291,30),r17
		mv_s	#fix(0.439,30),r18
		mv_s	#(1<<21),r19
		mv_s	#fix(1.0,30),r27
		mv_s	#0, rc0dec
		mv_s	#0,xudec
		btst	#1,srcStart
		bra		eq, `even, nop
		bclr	#1,srcStart				// make it start on long boundary
		mv_s	#$10000, xudec				// odd source
		cmp		#kMaxPix, numPix
		bra		lt, `even, nop
		mv_s	#1, rc0dec			
`even:
		mv_s	#kMaxPix, segSize
		cmp		#kMaxPix, numPix
		bra		ge, `around, nop
		mv_s	numPix, segSize
		add		#2, segSize, temp1
		asl		#15,temp1
		bset	#13,temp1
		st_s	temp1, (odmaP)
`around:
		add		#OsysAdrOff, odmaP, temp0
		st_s	srcStart, (temp0)
		mv_s	#kodmactl, r0
		mv_s	odmaP, r1
		mv_s	#1, r2
		push	v2
		jsr		__Dma_do,nop
		pop		v2
/* now do RGB to YCC conversion rev 1 */
		sub		rc0dec, segSize, temp0
		st_s	temp0, rc0
		asl		#16,temp0
		sub		#$10000,temp0
		mvr		temp0,ru
		add		xudec,temp0
		mvr		temp0, rx
		ld_p	(xy), v6
		addr	#-1<<16, rx
		dotp	v2, v6, >>#30, r20
`cvrt:
		dotp	v3, v6, >>#30, r21
{		dotp	v4, v6, >>#30, r22
		dec		rc0
}
{		bra		c0ne, `cvrt
		ld_p	(xy), v6
		addr	#-1<<16, rx
}
{		st_p	v5, (uv)
		addr	#-1<<16, ru
}
		dotp	v2, v6, >>#30, r20
		sub		rc0dec, segSize, temp1
		asl		#16, temp1
		or		dstStart, temp1
		add		#MxDescOff, mdmaP, temp0
		st_s	temp1, (temp0)
		mv_s	#kmdmactl, r0
		mv_s	mdmaP, r1
		mv_s	#1, r2
		push	v2
		jsr		__Dma_do,nop
		pop		v2
		add		segSize, dstStart
		sub		rc0dec, dstStart
		mv_s	segSize, temp0
		asl		#1, temp0
		add		temp0, srcStart
		sub		segSize, numPix
		add		rc0dec,numPix
		mv_s	#0,rc0dec
		mv_s	#0,xudec
		bra		gt, `even, nop
		pop		v7,rz
		nop
		ld_v	(r31),v6
		add		#16,r31
		ld_v	(r31),v5
		add		#16,r31
		ld_v	(r31),v4
		add		#16,r31
		ld_v	(r31),v3
		add		#16,r31
		ld_v	(r31),v2
		add		#16,r31
		rts 	nop
		nop
		nop		
		
