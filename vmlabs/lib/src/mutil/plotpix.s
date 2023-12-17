/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
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
	;; Normally this routine should never be needed
	;; (an inline definition in a header file will
	;; expand to a direct call to _DMABiLinear).
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

	; should be handled now by a define in nuon/dma.h, but we'll provide
	; a real, callable function here for backwards compatibility
	
	.export __raw_plotpixel
	.text
	
__raw_plotpixel:
	jmp	__DMABiLinear
	bset	#27,r0			; set the direct bit of the DMA flags
	nop
