/*
 * 
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
*/

	.export		_drawbar, _size_drawbar

	.text
	.align.v
_drawbar:
        mv_s	#0x20100000,r0  ; Load address of DMA command buffer

_mdma:
	ld_s	mdmactl,r1
	nop
        bits	#4,>>#0,r1	; Wait for PENDING bit to be clear
	bra	ne,_mdma,nop	; loop until it is.
	st_s	r0,mdmacptr	; Kick off main bus DMA

_mdma_busy:
	ld_s	mdmactl,r0
	nop
	and	#$F,r0,r0
	bra	ne,_mdma_busy,nop

	nop
	nop
        halt
        nop
        nop               

_end_drawbar:

	_size_drawbar = _end_drawbar - _drawbar

