	;;
	;; DMA utility routines
	;;
	;; Copyright 1997 VM Labs, Inc.
	;; All rights reserved.
	;; This file is confidential and proprietary
	;; information of VM Labs disclosed pursuant
	;; to the non-disclosure agreement between
	;; VM Labs and the Recipient.
	;;
	;;

	.module dmafuncs
	.export dma_write
	.export dma_read	
		
	; internal register usage
	dma_size = r0
	dma_extaddr = r1
	dma_intaddr = r2
	dma_ctlreg = r3
	dma_flags = r4
	xfer_size = r5
	cur_size = r6
	temp0 = r7

	;
	; subroutine dma_write:
	; read some number of bytes from external RAM
	; into internal RAM
	;
	; parameters:
	; r0 == external address
	; r1 == internal address
	; r2 == number of bytes
	;
	; Registers modified:
	; v0, v1
	;
	; Stack used:
	; 4 long words (used as a DMA transfer buffer)
	;
dma_write:
	bra	common_dma	; next two instructions are in delay slots
	nop
	;; fall through to dma_read -- note that the
	;; first instruction of dma_read also gets executed
	;; by dma_write!!!


	;
	; subroutine dma_read:
	; read some number of bytes from external RAM
	; into internal RAM.
	;
	; parameters:
	; r0 == external address
	; r1 == internal address
	; r2 == number of bytes
	;
	; Registers modified:
	; v0, v1
	;
	; Stack used:
	; 4 long words (used as a DMA transfer buffer)
	;

	; maximum size of one DMA chunk, in bytes
	; make this a multiple of 16 bytes, so
	; that other bus DMAs that start aligned
	; will finish aligned (helps avoid an
	; other bus DMA bug)
	
MAX_SIZE = (60*4)
	
	
dma_read:
	;;;; NOTE NOTE NOTE: first instruction of dma_read
	;;;; is also executed by dma_write above (it is
	;;;; in a delay slot)
	mv_s	#0,dma_flags
	bset	#13,dma_flags		; set read bit

	; fall through

	;
	; Common subroutine, used for both
	; reads and writes
	;
	
common_dma:
	
	; round up to next largest number of longwords
{	add	#3,r2,xfer_size
	mv_s	r1,dma_intaddr
}
	and	#~3,xfer_size
{	copy	r0,dma_extaddr
	mv_s	#addrof(mdmactl),dma_ctlreg
}
	
	push	v0		; create a 16 byte buffer on the stack
	
	; check for which bus to use
	; our rule of thumb: if the upper nybble is 4, use the
	; main bus, otherwise use the other bus
	; (the other bus is better for MPE<->MPE transfers,
	; because the main bus is buggy)
	;
	copy	dma_extaddr,temp0
	bits	#3,>>#28,temp0		; extract top nybble
	cmp	#4,temp0
	bra	eq,start_xfer,nop
	sub	#addrof(mdmactl)-addrof(odmactl),dma_ctlreg   ;; set dma_ctlreg to addrof(odmactl)

start_xfer:
	;
	; Figure out how many bytes to DMA this time
	; around the loop; do at most MAX_SIZE bytes
	;
	
	mv_s	#MAX_SIZE,cur_size
	cmp	cur_size,xfer_size
	bra	ge,bigxfer,nop		; if (xfer_size - max_size >= 0, use max_size)	
	mv_s	xfer_size,cur_size

bigxfer:
	asl	#(16-2),cur_size,dma_size	; put in the upper 16 bits, as words

	; wait for DMA pending to go clear
wait_pending:
	ld_s	(dma_ctlreg),temp0
	or	dma_flags,dma_size	; now DMA flags are set up for transfer
					;; (it's OK to do the "or" multiple times)
{	btst	#4,temp0
	ld_io	sp,temp0		; get current stack pointer (used as DMA buffer)
}
	bra	ne,wait_pending,nop

	
{	st_v	v0,(temp0)
	add	#16,dma_ctlreg		; point to control register
}
	; launch the DMA
	st_s	temp0,(dma_ctlreg)	; start DMA
	sub	#16,dma_ctlreg

	; update DMA variables
	sub	cur_size,xfer_size
	bra	gt, start_xfer
	add	cur_size,dma_extaddr
	add	cur_size,dma_intaddr
	
	; wait for the DMA to finish
wait_dma:
	ld_s	(dma_ctlreg),temp0
	nop
	bits	#4,>>#0,temp0
	bra	ne,wait_dma,nop

	; restore the stack pointer with pop v0
	; NOTE: this does *not* restore the contents of
	; v0, because we were using the stack
	; as a buffer for the DMA command
	
	pop	v0	
	rts	nop



