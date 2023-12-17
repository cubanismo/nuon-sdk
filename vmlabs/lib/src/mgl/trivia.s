/*Copyright (C) 1996-2001 VM Labs, Inc. 

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


.module Triv1
.import _LoadV8Triangles_return
.export _TrivialV8Triangle
.export _TrivialV8Triangle_size
.import _MPEVertexCacheVertex
.import _MPEVertexCacheVertices
.import _MPEPolygonVertices
	
	; Trivial accept/reject an 8 longword per vertex triangle

_TrivialV8Triangle_size = _TrivialV8Triangle_end - _TrivialV8Triangle

.align.sv
_TrivialV8Triangle:
`tr_start:
	{
	ld_s	(_MPEVertexCacheVertex), r31		; Load current vertex pointer
	sub		r0, r0								; Set R0 to 0
	}
	nop
	add		#16, r31, r30						; R30 points to first clip code
	{
	ld_s	(r30), r1							; Load first clip code
	add		#32, r30							; Increment clip code pointer
	}
	{
	ld_s	(r30), r2							; Load second clip code
	add		#32, r30							; Increment clip code pointer
	}
	{
	ld_s	(r30), r3							; Load third clip code
	and		#63, r1								; Mask out texture coordinates
	addm	r0, r1, r4							; Copy vertex 0 clip code to R4
	}
	and		r2, r1								; And clip code 0 and 1 together
	and		r3, r1								; And clip code 2, 1, and 0
	{
	bra		ne, `TrivialReject
	or		r2, r4								; Or clip codes 0 and 1 together
	}
	or		r3, r4								; Or clip codes 2, 1, and 0
	and		#63, r4								; Mask out texture coordinate data
	{
	bra		eq, `TrivialAccept, nop					; Jump if trivial accept
	mv_s	#03, r0
	}
		

	; Some clipping required
`MixedClip:
	neg		r0									; Store negative vertex count to
												; indicate polygon clipping
												; NOTICE THIS!!!!!^^^^^^^^^
												; Thank you...

`TrivialAccept:
	jsr		CLIPPER_OVERLAY_ORIGIN				; Jump to light clip render path
	st_s	r0, (_MPEPolygonVertices)			; Store vertex count
	nop

	; Skip Triangle, check for more, otherwise RTS
`TrivialReject:
`NextTriangle:
	ld_s	(_MPEVertexCacheVertices), r0		; Load vertex cache count
	ld_s	(_MPEVertexCacheVertex), r1			; Load current vertex pointer
	sub		#03, r0								; Decrement vertex cache count
	{
	st_s	r0, (_MPEVertexCacheVertices)		; Store updated vertex count
	bra		ne, _TrivialV8Triangle				; Branch if more triangles
	add		#96, r1								; Increment vertex pointer
	}
	st_s	r1, (_MPEVertexCacheVertex)
	nop

	; Done, return
	jmp		_LoadV8Triangles_return, nop
	
.align.sv
_TrivialV8Triangle_end:


.module Triv2
.import _LoadV4Triangles_return
.export _TrivialV4Triangle
.export _TrivialV4Triangle_size
.import _MPEVertexCacheVertex
.import _MPEVertexCacheVertices
.import _MPEPolygonVertices

	; Trivial accept/reject a 4 longword per vertex triangle

_TrivialV4Triangle_size = _TrivialV4Triangle_end - _TrivialV4Triangle

.align.sv
_TrivialV4Triangle:
`tr_start:
	{
	ld_s	(_MPEVertexCacheVertex), r31		; Load current vertex pointer
	sub		r0, r0								; Set R0 to 0
	}
	nop
	add		#16, r31, r30						; R30 points to first clip code
	{
	ld_s	(r30), r1							; Load first clip code
	add		#32, r30							; Increment clip code pointer
	}
	{
	ld_s	(r30), r2							; Load second clip code
	add		#32, r30							; Increment clip code pointer
	}
	{
	ld_s	(r30), r3							; Load third clip code
	and		#63, r1								; Mask out texture coordinates
	addm	r0, r1, r4							; Copy vertex 0 clip code to R4
	}
	and		r2, r1								; And clip code 0 and 1 together
	and		r3, r1								; And clip code 2, 1, and 0
	{
	bra		ne, `TrivialReject
	or		r2, r4								; Or clip codes 0 and 1 together
	}
	or		r3, r4								; Or clip codes 2, 1, and 0
	and		#63, r4								; Mask out texture coordinate data
	{
	bra		eq, `TrivialAccept, nop					; Jump if trivial accept
	mv_s	#03, r0
	}
		

	; Some clipping required
`MixedClip:
	neg		r0									; Store negative vertex count to
												; indicate polygon clipping
												; NOTICE THIS!!!!!^^^^^^^^^
												; Thank you...

`TrivialAccept:
	jsr		CLIPPER_OVERLAY_ORIGIN				; Jump to light clip render path
	st_s	r0, (_MPEPolygonVertices)			; Store vertex count
	nop

	; Skip Triangle, check for more, otherwise RTS
`TrivialReject:
`NextTriangle:
	ld_s	(_MPEVertexCacheVertices), r0		; Load vertex cache count
	ld_s	(_MPEVertexCacheVertex), r1			; Load current vertex pointer
	sub		#03, r0								; Decrement vertex cache count
	{
	st_s	r0, (_MPEVertexCacheVertices)		; Store updated vertex count
	bra		ne, _TrivialV4Triangle			; Branch if more triangles
	add		#96, r1								; Increment vertex pointer
	}
	st_s	r1, (_MPEVertexCacheVertex)

	; Done, return
	jmp		_LoadV4Triangles_return
	nop
	nop
	
.align.sv
_TrivialV4Triangle_end:
