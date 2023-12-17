/*
 * Copyright (C) 1998-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

	GROWAMOUNT = 1024
	.text
	.cache
	.export _m3dAddVertex
	.import _realloc
_m3dAddVertex:

	; Check if current size of execute buffer is adequate
	{
	ld_s	(r0), r11				; Read current value of maxentries
	add	#4, r0, r4				; Calculate pointer to numentries
	}
	{
	ld_s	(r4), r6				; Read numentries
	add	#40, r0, r5				; Calculate pointer to entries
	}
	{
	ld_s	(r5), r7				; Read entries pointer
	sub	#01, r11				; Decrement maxentries by  1
	}
	{
	cmp	r11, r6					; Check if numentries >= maxentries - 1
	}
	{
	bra	lt, `bufferOK, nop		; Jump if limit has not been met
	mv_s	r0, r8					; Move buf/maxentries pointer
	add	#01, r11				; Undecrement maxentries
	}

	; Save state on C stack and realloc entries pointer
	{
	mv_s	r31, r9					; Save original C stack pointer
	and	#$fffffff0, r31			; Vector align stack pointer
	}
	{
	ld_s	(rz), r10				; Read rz into to r10
	add	#GROWAMOUNT, r11		; Calculate new maxentries
	}
	sub	#16, r31				; Predecrement stack pointer
	{
	st_v	v0, (r31)				; Save registers r0-r3
	sub	#16, r31				; Decrement C stack pointer
	}
	{
	st_v	v1, (r31)				; Save registers r4-r7
	sub	#16, r31				; Decrement C stack pointer
	}
	{
	mv_s	#_realloc, r2			; Put subroutine pointer in r2
	add	#04, r5					; R5 now points to realentries
	}

	{
	jsr	(r2)					; Reallocate execution buffer entries pointer
	st_v	v2, (r31)				; Save registers r8-r11
	}
	{
	ld_s	(r5), r0				; Load current realentries pointer into r5
	lsl	#04, r11, r1			; Multiply new number of entries by 16 (sizeof (m3dBufEntry))
	}
	add	#16, r1					; Add 16 to desired allocation size

	; Restore stack and store updated entries pointer and maxentries
	{
	ld_v	(r31), v2				; Restore registers r8-r11
	add	#16, r31				; Increment C stack pointer
	}
	{
	ld_v	(r31), v1				; Restore registers r4-r7
	add	#16, r31				; Increment C stack pointer
	}
	{
	st_s	r11, (r8)				; Store new value of maxentries
	add	#15, r0, r1				; Increment entries pointer
	}
	and	#$fffffff0, r1			; R1 is vector-aligned entries pointer
	{
	st_s	r1, (r5)				; Store new entries pointer
	add	#04, r5					; R5 now points to realentries
	}
	{
	st_s	r0, (r5)				; Store new realentries pointer
	copy	r1, r7					; Copy entries into r7
	}
	ld_v	(r31), v0				; Restore registers r0-r3	
	copy	r9, r31					; Restore original C stack pointer
	st_s	r10, (rz)				; Store original subroutine return
	
`bufferOK:

	; Read and position current vertex attributes for vector storage
	{
	mv_s	r1, r0					; Copy x into r0
	add	#32, r8, r11			; R11 points to tv
	subm	r5, r5					; Set r5 to zero
	}
	{
	ld_s	(r11), r11				; Read tv
	add	#24, r8, r10			; R10 points to nz
	addm	r5, r2, r1				; Copy y into r1
	}
	{
	ld_s	(r10), r10				; Read tu
	add	#28, r8, r3				; R3 now points to tu
	addm	r5, r3, r2				; Copy z into r2
	}
	{
	ld_s	(r3), r3				; Read nz
	add	#20, r8, r9				; R9 now points to ny
	}
	{
	ld_s	(r9), r9				; Read ny
	add	#16, r8					; r8 now points to nx
	addm	r5, r8, r5				; Move buf pointer into r5
	}
	{
	ld_s	(r8), r8				; Read nx
	lsl	#04, r6					; Convert numentries into an offset
	}
	{
	add	#12, r5					; R5 now points to curpoly
	addm	r6, r7					; R7 now points to appropriate buffer entries
	}
	{
	st_v	v0, (r7)				; Store x, y, z, and tu
	add	#16, r7					; Increment vector pointer
	}
	{
	st_v	v2, (r7)				; Store nx, ny, nz, and tv
	add	#32, r6					; Increment numentries as an offset
	subm	r6, r7					; R7 now points to entries+16
	}

	ld_s	(r5), r5				; Load curpoly into r5
	lsr	#04, r6					; Convert numentries back into index
	{
	st_s	r6, (r4)				; Store new value of numentries
	sub	#16, r7					; R7 now points to entries
	}

	; Update buf->entries[curpoly]->buf[0] and return
	lsl	#04, r5					; Convert curpoly into 16x offset
	add	r7, r5					; R5 now points to buf->entries[curpoly]->buf[0]
	ld_s	(r5), r4				; Load buf->entries[curpoly]->buf[0]
	rts
	add	#01, r4					; Increment buf->entries[curpoly]->buf[0]
	st_s	r4, (r5)				; Store updated buf->entries[curpoly]->buf[0]

