	;;
	;; MPE overlay utility routines
	;;
	;; Copyright 1997 VM Labs, Inc.
	;; All rights reserved.
	;; This file is confidential and proprietary
	;; information of VM Labs disclosed pursuant
	;; to the non-disclosure agreement between
	;; VM Labs and the Recipient.
	;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; Define MAX_OVERLAYS to say how many
	; overlays there may be active at
	; any time. You will probably need at
	; least two -- one for instructions,
	; one for data.
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	MAX_OVERLAYS = 4

	;
	; load_overlay: loads an overlay into
	; MPE RAM. At most MAX_OVERLAYS overlays
	; may be active (i.e. loaded into MPE
	; memory) at any given time.
	;
	; Parameters:
	; r0 == external address of overlay to load
	; r1 == internal address (where to put the
	;       overlay in MPE IRAM)
	; r2 == size of overlay in bytes (this
	;       will be rounded up to long words)
	;
	; Returns:
	; r0 == 1 for success
	; r0 == 0 for failure
	;
	;
	; Registers used:
	; v0, v1
	;
	;
	; Most of the code below is taken up
	; with managing the overlay table
	; which is located starting at the
	; symbol OVERLAY_TABLE. This is used
	; by the debugger to help
	;
	; CAVEATS: overlays must be vector-aligned,
	; and must be loaded on a vector boundary.
	; This restriction mandated by the hardware
	; for instruction memory, and is probably
	; a good idea for data memory too since it
	; enables us to avoid some other bus
	; DMA problems.
	;
	;

	.segment instruction_ram
	.module overlay

	temp0 = v1[0]
	ol_ptr = v1[1]
	numols = v1[2]
	counter = v1[3]
			
	.export	load_overlay
	.import dma_read
	
load_overlay:
	; First, see if any overlay is presently
	; loaded at the internal address we
	; were given. If so, then we'll re-use
	; its slot in the overlay table
	;
	ld_s	OVERLAY_TABLE,numols	; get number of entries currently in table
	nop
	copy	numols,counter
{	bra	le,new_olay,nop		; break if no entries in table
	mv_s	#olay_1+4,ol_ptr	; start with the first overlay
}
	
`olloop:
	ld_s	(ol_ptr),temp0		; get its internal address
	nop
	cmp	r1,temp0		; does it match the internal address we're loading?
	bra	eq,found_olay,nop	; yes -- we found a slot
	add	#12,ol_ptr		; no -- move to next overlay
	sub	#1,counter
	bra	gt,`olloop,nop

	; if we reach here, then we need to create a
	; new overlay table entry. ol_ptr will
	; point at the new location; we need to
	; bump the count at the start of the
	; overlay table, and make sure it isn't
	; too big already
new_olay:
	cmp	#MAX_OVERLAYS,numols	; are there too many overlays yet?
	bra	ge,fail_load,nop	; yes -- fail the load
	add	#1,numols		; otherwise, update the overlay count
	st_s	numols,OVERLAY_TABLE

	;
	; here we need to set up the memory pointed
	; at by ol_ptr
	;
found_olay:
	sub	#4,ol_ptr		; move to the start of the overlay info
{	st_s	r0,(ol_ptr)		; save the external address
	add	#4,ol_ptr
}
{	st_s	r1,(ol_ptr)		; save the internal address
	add	#4,ol_ptr
}
	st_s	r2,(ol_ptr)		; save the size

{	push	v1,rz			; save rz
	add	#15,r2			; round size up to a multiple of 16
}
{	and	#~15,r2			; finish rounding size up
	jsr	dma_read,nop		; initiate DMA read
}
	pop	v1,rz
	nop
{	mv_s	#1,r0			; indicate success
	rts	nop
}

fail_load:
{	mv_s	#0,r0			; indicate failure
	rts	nop
}

	;
	; include the necessary DMA functions
	;
	.include "dma.s"
	
	; storage for the
	; overlay table
	;
	; This table is used by the debugger
	; to determine which overlays are
	; presently loaded. The first
	; long word gives the number of
	; overlays currently present. After
	; this come the overlays themselves,
	; at 3 long words per overlay:
	; sdram_address, internal_address, size in bytes
	;
	;
	; for now, we assume a maximum of 2 overlays
	; present in any MPE at a time
	;
	
	.segment local_ram
	.export OVERLAY_TABLE
OVERLAY_TABLE:
	.dc.s	0	; number of overlays
olay_1:
	_ii = 0
	.while (_ii < MAX_OVERLAYS)
	.dc.s	0, 0, 0 ; sdram address, internal address, size
	_ii = _ii + 1
	.end


	
