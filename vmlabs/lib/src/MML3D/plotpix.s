/*
 * Copyright (C) 1997-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */
	;;
	;; routine to plot a pixel, or short
	;; line, using the DMA engine.
	;;
	

	;
	; arguments:
	; r0 == dma flags
	; r1 == screen base address
	; r2 == X pointer (low 16 bits) & length (high 16 bits)
	; r3 == Y pointer (low 16 bits) & length (high 16 bits)
	;
	; r4 == color (32 bit word; interpretation depends on
	;       pixel type, see MMA manual)
	;
	; Scratch registers: r5 == used for mdmactl
	;                    r6 == used for dcachectl
	;		     r7 == used for intctl
	
	;
	; C prototype:
	; void _raw_plotpixel(long dmaflags, void *dmaaddr, long xinfo, long yinfo, long color)
	;
	
	;
	; the emulator doesn't support the DIRECT
	; bit on DMA, so define DIRECT=0 if you
	; want the code to be able to run
	; on the emulator
	;
	
DIRECT = 0
	
	.export __raw_plotpixel
	.text
	
__raw_plotpixel:
	; turn off interrupts (so no interrupt code will
	; affect the cache)
	ld_io	intctl,r7		; save old intctl
	st_io	#(1<<7)|(1<<3),intctl	; disable interrupts (with software)
	
	; make sure there is no cache write
	; in progress, and that all DMA
	; has finished

	
`waitcache:
	ld_io	dcachectl,r6
	ld_io	mdmactl,r5
	bits	#3,>>#28,r6
{	bra	ne,`waitcache,nop
	bits	#4,>>#0,r5
}
	bra	ne,`waitcache,nop

	; set up a DMA command block


.if DIRECT	
	bset	#27,r0			; set the direct bit of the DMA flags
.else
	bset	#26,r0			; set the "dup" bit of the DMA flags
.endif
	
	;; FROM THIS POINT UNTIL AFTER THE MEMORY IS RESTORED
	;; DO NOT MAKE ANY ACCESSES THROUGH THE CACHE
	
	ld_v	$20100000,v2		; save contents of $20100000 - $2010000f in v2
	st_v	v0,$20100000		; set up first part of pixel DMA block
	ld_v	$20100010,v0		; save contents of $20100010 - $2010001f in v0
.if DIRECT
	st_s	r4,$20100010		; set up direct data for DMA
.else
	st_s	#$20100014,$20100010
	st_s	r4,$20100014
.endif
	
	st_s	#$20100000,(mdmacptr)	; start the DMA

	; wait for DMA to finish
`wait2:
	ld_io	(mdmactl),r5
	nop
	bits	#4,>>#0,r5
	bra	ne,`wait2,nop
		

	;; RESTORE MEMORY

	st_v	v2,$20100000
{	st_v	v0,$20100010
	lsr	#1,r7
}
	;; OK TO USE CACHE AGAIN

{	not	r7
	rts
}
	and	#(1<<6)|(1<<2),r7
	st_io	r7,intctl		; re-enable interrupts
