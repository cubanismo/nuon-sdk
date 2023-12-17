/* Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/


#include "mpedefs.h"

.nocache
.text

.module lb1
.export _LoadV8Triangles
.export _LoadV8Triangles_size
.export _LoadV8Triangles_return
.import _MPEVertexCache
.import _MPEVertexCacheVertex
.import _MPEVertexCacheVertices
.import _MPEODMACmdBuf
.import _EventHandler

	; Main control block for rendering a block of
	; X Y Z W U V C1 C2 triangles
	; Requires 16 bytes of stack space
	source_pointer	= r4
	render_delta	= r5	; scalars
	block_length	= r6	; scalars
	
_LoadV8Triangles_size = lb1_end - lb1_start
_LoadV8Triangles_return = VERTEX_LOADER_OVERLAY_ORIGIN+(lb1_return-lb1_start)
_LoadV8Triangles:
lb1_start:
	mv_v	v0, v1
	lsl		#2, render_delta				; convert to bytes
lb1_morevertices:

	; Read a block of 3 or 6 vertices
	{
	mv_s	#6, r3							; Initialize vertex counter to 6
	cmp		#48, block_length				; Check if reading last 3 vertices
	}
	{
	bra		ge, lb1_read48, nop				; Jump if this is the case
	mv_s	#48, r0							; Default to reading 6 vertices
	}
	
	; Reading <6 vertices!
	{
	mv_s	#3, r3							; Set to transform 3 vertices
	copy	block_length, r0				; Set to read 24 long words
	}

lb1_read48:
	mv_s	#_MPEVertexCache, r2
	mv_s	#_MPEODMACmdBuf, r8

	{
	st_s	r2, (_MPEODMACmdBuf+8)		; Store destination read address
	lsl		#16, r0, r1							; Shift long word count into position
	}
	{
	st_s	source_pointer, (_MPEODMACmdBuf+4)		; Store source read address
	bset	#13, r1								; R1 is now DMA flag
	}
	{
	st_s	r1, (_MPEODMACmdBuf)					; Store DMA flags
	add		render_delta, source_pointer		; Increment source pointer
	}
	{
	st_s	r8, (odmacptr)						; Trigger DMA
	sub		render_delta,>>#2, block_length		; Decrement total block length
	}

`DMAwait:
	ld_s	(odmactl), r31						; Read DMA control register
	nop
	and		#$f, r31							; Check for DMA activity
	bra		ne, `DMAwait, nop

	; Once DMA is complete, jump to rendering routine
	st_s	r2, (_MPEVertexCacheVertex)			; Store starting vertex
	{
	bra		lb1_transformandrender				; Jump to rasterization subroutine
	push	v1									; Save block length
	}
	st_s	r3, (_MPEVertexCacheVertices)		; Store initial vertex count
	st_s	r3, (rc0)							; Store countdown for xform

lb1_return:
	; Main loop control
	pop		v1									; Restore block parameters
	nop
	
	cmp		#00, block_length	; Check if more vertices to render
	bra		gt, lb1_morevertices, nop

lb1_done:
	; Return to MPE Manager
	jmp		_EventHandler, nop

	; Insert rendering routine here
.align.sv
lb1_transformandrender:
lb1_end:

.module lb2
.export _LoadV4Triangles
.export _LoadV4Triangles_size
.export _LoadV4Triangles_return
.import _MPEVertexCache
.import _MPEVertexCacheVertex
.import _MPEVertexCacheVertices
.import _MPEODMACmdBuf
.import _EventHandler

	; Main control block for rendering a block of
	; X Y Z C triangles
	; Requires 16 bytes of stack space
	source_pointer	= r4
	render_delta	= r5	; scalars
	block_length	= r6	; scalars
	
_LoadV4Triangles_size = lb2_end - lb2_start
_LoadV4Triangles_return = VERTEX_LOADER_OVERLAY_ORIGIN+(lb2_return-lb2_start)

_LoadV4Triangles:
lb2_start:
	mv_v	v0, v1
	lsl		#2, render_delta				; convert to bytes
lb2_morevertices:

	; Read a block of 3 or 6 vertices
	{
	mv_s	#6, r3							; Initialize vertex counter to 6
	cmp		#24, block_length				; Check if reading last 3 vertices
	}
	{
	bra		ge, lb2_read48, nop				; Jump if this is the case
	mv_s	#24, r0							; Default to reading 6 vertices
	}
	
	; Reading <6 vertices!
	{
	mv_s	#3, r3							; Set to transform 3 vertices
	copy	block_length, r0				; Set to read 12 long words
	}

lb2_read48:
	mv_s	#_MPEVertexCache+96, r2
	mv_s	#_MPEODMACmdBuf, r8

	{
	st_s	r2, (_MPEODMACmdBuf+8)		; Store destination read address
	lsl		#16, r0, r1							; Shift long word count into position
	}
	{
	st_s	source_pointer, (_MPEODMACmdBuf+4)		; Store source read address
	bset	#13, r1								; R1 is now DMA flag
	}
	{
	st_s	r1, (_MPEODMACmdBuf)					; Store DMA flags
	sub		#6<<4, r2							; Reset vertex pointer to _MPEVertexCache
	addm	render_delta, source_pointer		; Increment source pointer
	}
	{
	st_s	r8, (odmacptr)						; Trigger DMA
	sub		render_delta,>>#2, block_length		; Decrement total block length
	}

`DMAwait:
	ld_s	(odmactl), r31						; Read DMA control register
	nop
	and		#$f, r31							; Check for DMA activity
	bra		ne, `DMAwait, nop

	; Once DMA is complete, jump to rendering routine
	st_s	r2, (_MPEVertexCacheVertex)			; Store starting vertex
	{
	bra		lb2_transformandrender				; Jump to rasterization subroutine
	push	v1									; Save block length
	}
	st_s	r3, (_MPEVertexCacheVertices)		; Store initial vertex count
	st_s	r3, (rc0)							; Store countdown for xform

lb2_return:
	; Main loop control
	pop		v1									; Restore block parameters
	nop
	
	cmp		#00, block_length	; Check if more vertices to render
	bra		gt, lb2_morevertices, nop

lb2_done:
	; Return to MPE Manager
	jmp		_EventHandler, nop

	; Insert rendering routine here
.align.sv
lb2_transformandrender:
lb2_end:

