
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

	.include	"macros.i"

;==============================================================
	.segment	data
;==============================================================
	.align.v
	odmacmd: .dc.s 0
	save_r4: .ds.s 1

	.export		odmacmd
	.export		odma_wtrd

BitRead = 13
LeftDmaActive = 4
BitBug 		= 8
BugAdr 		= $1FC
LoBusPriority 	= 1<<5

;==============================================================
	.segment text
;==============================================================
.if defined( ARIES )
; rwb 8/2/99 create aries version that doesn't have to work around bug
; also leave priority level unchanged
odma_wtrd:	
; Function to DMA a block of N items into mpe using Other Bus
; Uses V1.
; Assumes Vector aligned Command block reserved at odmacmd:
; Call Arguments
;	r4 - number of items to be transferred - total number bytes must be <= 1016 ???
;	   - if total number of bytes is not a multiple of 4, r4 is increased to make it so.
;	r5 - system memory address (external address) - byte address must be multiple of 4
;	r6 - dtram memory address (internal address)
;	r7 - log2(number of bytes per item) i.e. number of bits to
;		shift left by to convert numberItems to numberBytes
;	r31 - return address (created by caller)
; Returns with	r4, r6, & r7 unchanged
; 		r5 incremented by number of bytes in transfer; not including extra for bad end address
; 		rz set to r31 (return address )
; 		r31 set to 0
{	st_s	r31, rz
	neg	r7
}
	ls	r7, r4, r4		; num bytes to be transferred

	mv_s	#save_r4, r28
{
	st_s	r4, (r28)
	add	#3, r4 
}
	and	#$FFFC, r4	; round num bytes up to a multiple of 4
	dmaWait odmactl, r31
	lsl	#14, r4, r4		;r4 contains numLongs in left half

	bset	#BitRead, r4
		
	mv_s	#odmacmd, r30
	ld_s	(r30),r30
	nop
			
	st_v	v1, (r30)

{
	ld_s	(r28), r4
	neg	r7
}
	nop
{
	st_s	r30, (odmacptr)
	add	r4, r5		;r5 ready for next read; ignore extra word to work around bug
}
	rts
	mv_s	#0, r31
	ls	r7, r4, r4		;restore r4 to original or adjusted value

.else		
odma_wtrd:	
; Function to DMA a block of N items into mpe using Other Bus
; Uses V1.
; Assumes Vector aligned Command block reserved at odmacmd:
; Works around Other Bus DMA bug
;	if ending address would end in xxxF8, 1 extra scalar is transferred
; WARNING - up to 7 extra bytes can be read.  Internal dest buffer should
;	have two scalers of slop at end to account for this possibility.
;	we can fix this by doing two reads in bug case, but this is inefficient
; Call Arguments
;	r4 - number of items to be transferred - total number bytes must be <= 1016
;	   - if total number of bytes is not a multiple of 4, r4 is increased to make it so.
;	r5 - system memory address (external address) - byte address must be multiple of 4
;	r6 - dtram memory address (internal address)
;	r7 - log2(number of bytes per item) i.e. number of bits to
;		shift left by to convert numberItems to numberBytes
;	r31 - return address (created by caller)
; Returns with	r4, r6, & r7 unchanged
; 		r5 incremented by number of bytes in transfer; not including extra for bad end address
; 		rz set to r31 (return address )
; 		r31 set to 0
{	st_s	r31, rz
	neg	r7
}
	ls	r7, r4, r4		; num bytes to be transferred

	mv_s	#save_r4, r28
{//	st_s	r4, (save_r4)
	st_s	r4, (r28)
	add	#3, r4 
}
	and	#$FFFC, r4	; round num bytes up to a multiple of 4
	add	r4, r5, r31	; end byte address
	bits	#BitBug, >>#0, r31
	cmp	#BugAdr, r31
	bra	ne, loop2, nop
	add	#4, r4		; read in an extra scalar to work around bug
; Wait for existing otherBus DMA to finish before issuing command.
loop2:
	dmaWait odmactl, r31
{	lsl	#14, r4, r4		;r4 contains numLongs in left half
	mv_s	#LoBusPriority, r31
}
	bset	#BitRead, r4
		
	mv_s	#odmacmd, r30
	ld_s	(r30),r30
	nop
			
//	st_v	v1, (odmacmd)
	st_v	v1, (r30)

{//	ld_s	(save_r4), r4
	ld_s	(r28), r4
	neg	r7
}
	nop
	st_s	r31, (odmactl)

{//	st_s	#odmacmd, (odmacptr)
	st_s	r30, (odmacptr)
	add	r4, r5		;r5 ready for next read; ignore extra word to work around bug
}
	rts
	mv_s	#0, r31
	ls	r7, r4, r4		;restore r4 to original or adjusted value
		 
.endif