
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/



/* C callable functions for plotting points and doing small fills.
 * These functions do not use parameter blocks, all parameters are
 * contained in argument registers.
 * Each function has two versions, one for direct call on a native
 * NUON mpe; and one for execution via a dispatcher.  The dispatcher
 * calls must have all parameters packed into r1, r2 & r3.
 */

/* SmallFill -  Fill a small rectangle with an opaque color.
	 xLength * yLength must be <= 64 pixels.
	 color can have alpha value, but this capability is only used
	 when called by drawpoint, because of the need to be compatible
	 with dispatch version, where the lsb 8 bits of color are used
	 for frame info.
*/

/*	SmallFillDirect
	Direct version of SmallFill (also used for direct version of DrawPoint )
	r0 - dmaFlags - FrameBufferWidth, Cluster, PixType (2 or 4)
	r1 - frameBuffer Address
	r2 - xLength<<16 | x Position
	r3 - yLength<<16 | y Position
	r4 - DTRAM address to be used as mdma command block
	r5 - 32 bit color 
	r6, r7 - scratch
*/
	.export _SmallFillDirect
	.text
	
_SmallFillDirect:
	btst	#5, r0
{	bra		eq, `waitcache, nop	;check for 16 bit framebuffer
	or		#$400C000, r0		;set dup and pixwrite
}
	bclr	#5, r0				;if 16bit, set transfer 
	bset	#7, r0				; mode to 8
	; make sure there is no cache write in progress, and that all DMA has finished	
`waitcache:
	ld_io	dcachectl,r6
	ld_io	mdmactl,r7
	bits	#3,>>#28,r6
	bra		ne,`waitcache
	bits	#4,>>#0,r7
	bra		ne,`waitcache
{	st_v	v0, (r4)
	add		#20, r4, r7
}
{	add		#16, r4, r6
	st_s	r5, (r7)
}
	st_s	r7, (r6)
	st_s	r4, (mdmacptr)	;start the dma
	; wait for DMA to finish
`wait2:
	ld_io	(mdmactl),r7
	nop
	bits	#4,>>#0,r7
	bra		ne,`wait2,nop
	rts		nop

/* SmallFllDispatch - Dispatch version of SmallFill with all info packed into 3 args.
	r0 - environs
	r1 - frameBuffer Address | (frameWidth div 8)
	r2 - yDesc<<16 | xDesc
		yDesc = yLen<<10 | yPos
		xDesc = xLen<<10 | xPos
	r3 - 24bitcolor | flags
		flags = FrameClusterBit<<7 | FrameTransferType
 environs:
 	8-0 vector offset of graphics tile from 0x20100000
 baseP:
 	7-0 FrameBuffer width (in pixels) divided by 8
 	31-8 FrameBuffer address (must be on 512 byte boundary )
 coords:
 	9-0 xPos
 	15-10 xLen
 	25-16 yPos
 	31-26 yLen
 color:
 	3-0 FramePixTransferType
 	7	FrameClusterBit
 	31-8	24 bit YCC opaque color
 */
	;
	; Scratch registers: r5 == used for mdmactl
	;                    r6 == used for dcachectl
	;					r7, r8
	; v2 - used to build mdma Command
	
	
	.export _SmallFillDispatch
	.text
		
_SmallFillDispatch:
	
	; r8 = flags
	mv_s	#$400C000, r8		;bits for pix write and for dup
	and		#$FF, r3, r5	;get cluster bit & pix transfer type
	or		r5, >>#-4, r8
	and		#$FF, r1, r5	;get framebuffer width 
	or		r5, >>#-16, r8
	; r9 = base address
	and		#$FFFFFF00, r1, r9
	; r10 = x Description
	and		#$3FF, r2, r10
	and		#$FC00, r2, r5
	or		r5, >>#-6, r10
	; r11 = y description
	and		#$3FF0000, r2, r11
	asr		#16, r11
	and		#$FC000000, r2, r5
	or		r5, >>#10, r11
	; r4 = address of mdma command block
	and		#$1FF, r0, r4
	asl		#4, r4
	add		#$20100000, r4
	; make sure there is no cache write in progress, and that all DMA has finished	
`waitcache:
	ld_io	dcachectl,r6
	ld_io	mdmactl,r5
	bits	#3,>>#28,r6
{	bra	ne,`waitcache,nop
	bits	#4,>>#0,r5
}
	bra	ne,`waitcache,nop
	st_v	v2, (r4)
	; r6 = address of 5th scalar in command block  
	add		#16, r4, r6
	; r7 = address of color	
	add		#20, r4, r7
	st_s	r7, (r6)
	and		#$FFFFFF00, r3
	st_s	r3, (r7)
	
	st_s	r4,(mdmacptr)	; start the DMA
	; wait for DMA to finish
`wait2:
	ld_io	(mdmactl),r5
	nop
	bits	#4,>>#0,r5
	bra	ne,`wait2,nop

	rts		
	mv_s	#0, r0		;return status = eFinished
	nop		

/* DrawPoint
	Plot a single point in a color. 
	Can only be used with 16 bit and 32 bit framebuffers.
	Color can have alpha value if framebuffer is 32 bits.
*/
/* DrawPointDirect uses SmallFillDirect with xLength=1 and yLength=1
*/
	
/*	DrawPointDispatch
	Dispatched version of DrawPoint		
	r0 - environs
	r1 - frameBuffer Address | (frameWidth div 8)
	r2 - cluster<<27 | pixtype<<20 | yPos<<10 | xPos
	r3 - color
	r4 - r7 scratch
	v2 - used to build command block
*/
	.export _DrawPointDispatch
	.text
	
_DrawPointDispatch:
	
	; r8 = flags
	and		#$8F00000, r2, r4	;get cluster bit & pix transfer type
	rot		#16, r4
	or		#$400C000, r4, r8	;bits for pix write and for dup
	and		#$FF, r1, r5		;get framebuffer width div 8 
	or		r5, >>#-16, r8
	btst	#5, r8
	bra		eq, `around, nop
	bclr	#5, r8
	bset	#7, r8
`around:
	; r9 = base address
	and		#$FFFFFF00, r1, r9
	; r10 = x description
	and		#$3FF, r2, r10
	bset	#16, r10
	; r11 = y description
	bits	#9,>>#10,r2
	or		#$10000, r2, r11	
	; r4 = address of mdma command block
	and		#$1FF, r0, r4
	asl		#4, r4
	add		#$20100000, r4

	; make sure there is no cache write
	; in progress, and that all DMA
	; has finished	
`waitcache:
	ld_io	dcachectl,r6
	ld_io	mdmactl,r7
	bits	#3,>>#28,r6
	bra		ne,`waitcache,nop
	bits	#4,>>#0,r7
	bra		ne,`waitcache,nop

	st_v	v2, (r4)
	; r6 = address of 5th scalar in command block  
	add		#16, r4, r6
	; r7 = address of color	
	add		#20, r4, r7
	st_s	r7, (r6)
	st_s	r3, (r7)	
	st_s	r4,(mdmacptr)	; start the DMA
	; wait for DMA to finish
`wait2:
	ld_io	mdmactl,r7
	nop
	bits	#4,>>#0,r7
	bra	ne,`wait2,nop

	rts		
	mv_s	#0, r0		;return status = eFinished
	nop		

