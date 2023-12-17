/*
 *
 * Copyright (c) 2001 VM Labs, Inc.  All rights reserved.
 *
 * NOTICE: VM Labs permits you to use, modify, and distribute this file
 * in accordance with the terms of the VM Labs license agreement
 * accompanying it. If you have received this file from a source other
 * than VM Labs, then your use, modification, or distribution of it
 * requires the prior written permission of VM Labs.
 *
 * Written by Mike Fulton, VM Labs, Inc.
*/
	.text
	.align.v
	.export	_mdma_command, _odma_command
	.export	_mdma_ready, _odma_ready
	.export	_mdma_busy, _odma_busy
	.export	_mdma_status, _odma_status

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do main bus DMA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_mdma_command:
	ld_s	mdmactl,r1
	nop
	bits	#4,>>#0,r1		; Wait for PENDING bit to be clear
	bra	ne,_mdma_command,nop	; loop until it is.
{
	st_s	r0,mdmacptr		; Kick off DMA from MPE to main-bus
        rts
}
	nop
	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do other bus DMA.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_odma_command:

odma_check_dcache:
	ld_s	dcachectl,r1			; Check Dcache status value &
	nop
	bits	#4,>>#28,r1			; make sure high bits are set
	bra	ne,odma_check_dcache,nop	; before leaving loop

odma_pending:		
	ld_s	odmactl,r1
	nop
        bits	#4,>>#0,r1			; Wait for PENDING bit to be clear
	bra	ne,odma_pending,nop		; loop until it is.
{
	st_s	r0,odmacptr			; Kick off DMA from other bus to MPE
        rts
}
	nop
	nop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return ZERO if MAIN BUS DMA not busy, else return non-zero
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_mdma_status:
	ld_s	mdmactl,r0
	nop
{
	rts
	and	#$F,r0,r0	; Mask off non-BUSY bits
}
	nop	
	nop	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return ZERO if OTHER BUS DMA not busy, else return non-zero
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_odma_status:
	ld_s	odmactl,r0
	nop
{
	rts
	and	#$F,r0,r0	; Mask off non-BUSY bits
}
  	nop
	nop	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for MAIN BUS DMA status = not busy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_mdma_busy:
	ld_s	mdmactl,r0
	nop
	and	#$F,r0,r0
	bra	ne,_mdma_busy,nop
	rts
	nop	
  	nop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Wait for OTHER BUS DMA status = not busy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_odma_busy:
	ld_s	odmactl,r0
	nop
	and	#$F,r0,r0
	bra	ne,_odma_busy,nop
	rts
	nop	
  	nop
