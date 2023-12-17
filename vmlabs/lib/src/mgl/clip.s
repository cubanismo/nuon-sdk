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


	// Local equates
	CLIP_OUTSIDE = 1
	CLIP_INSIDE = 2



.module Clip1
.export _ClipXYZWUVCTriangle
.export _ClipXYZWUVCTriangle_size
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPERecipLUT
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEVertexCacheVertex
.import _MPEVertexCacheVertices
.import _MPEDMACache1
.import _MPEViewport


	; Register allocations
	; v7	=		Old vertex xyzw
	; v7[3] =		Input vertex counter
	; v7[2] =		Initial input vertex pointer
	; v7[1] = 		Initial output vertex pointer
	; v7[0] = 		Summed clip codes for triangle
	; v6	=		Previous vertex C
	; v6    =		Current clip plane equation
	; v5	=		Current vertex C
	; v5[3] = 		Output vertex count
	; v5[2] =		Current input vertex pointer
	; v5[1] =		Current output vertex pointer
	; v5[0] =		Previous output vertex pointer
	; v4	=		Old vertex uvC
	; v3	=		Current vertex xyzw
	; v2	=		Current vertex uvC
	; v1[3] =		Old vertex clip code
	; v1[2] =		Current vertex clip code
	; v1[1]	=		Previous vertex clip plane dot product
	; v1[0] =		Current vertex clip plane dot product

	_ClipXYZWUVCTriangle_size = _ClipXYZWUVC_end-_ClipXYZWUVCTriangle
.align.sv
_ClipXYZWUVCTriangle:
	ld_s	(_MPEVertexCacheVertex), v7[2]		; Grab current vertex pointer
	ld_s	(_MPEPolygonVertices), v7[3]		; Grab current vertex count
	add		#16, v7[2]							; Shift vertex pointer to texture vertices
	{
	cmp		#00, v7[3]							; Check for negative vertex count
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Set multiplication shift
	}
	{
	bra		ge, `CopyPolygon					; Skip clipping if trivial accept
	ld_s	(v7[2]), v7[0]						; Load first clip code
	add		#32, v7[2]							; Advance vertex pointer
	subm	v6[1], v6[1]						; Zero y component of clip plane normal
	}
	{
	ld_s	(v7[2]), r1							; Load second clip code
	add		#32, v7[2]							; Advance vertex pointer
	subm	v6[2], v6[2]						; Zero z component of clip plane normal
	}
	{
	ld_s	(v7[2]), r2							; Load third clip code
	sub		#80, v7[2]							; Reset vertex pointer
	}
	
	abs		v7[3]								; Insure vertex count is positive
	; Initialize clipping plane equation and clip plane count
`BuildClipPlanes:

	; pixel DMA cache will be used for scratch space, so wait for DMA to complete
`DMAwait:
	ld_s	(mdmactl), r0						; Read DMA control register
	nop
	and		#$f, r0								; Check for DMA activity
	bra		ne, `DMAwait

	{
	st_s	#6, (rc1)							; Initialize clip plane count
	or		r1, v7[0]							; Determine clip plane sum
	}
	{
	mv_s	#-(1<<GLXYZWCLIPSHIFT), v6[3]			; Initialize clip w component
	or		r2, v7[0]							; Clip codes complete
	}
	{
	mv_s	#_MPEDMACache1, v7[1]				; Initialize Destination DMA pointer
	sub		v6[3], #0, v6[0]					; Initialize clip x component					
	}

`ClipLoop:
	; Test if current clip plane violated at all
	{
	mv_s	v7[3], r0							; Copy vertex count into R0
	btst	#0, v7[0]							; Check if current plane active
	subm	v5[3], v5[3]						; Initialize output vertex count
	}

	; Skip clip plane if not violated
	{
	bra		eq, `AdvancePlane					; Jump if clipping plane not violated
	st_s	r0, (rc0)							; Initialize edge counter
	mul		#1, r0, >>#-5, r0					; Calculate vertex list length
	}
	{
	st_s	#1, (svshift)						; Set up small vector shift
	sub		#32, v7[2], v5[0]					; Determine initial offset for previous vertex pointer
	}
	{
	mv_s	v7[2], v5[2]						; Copy source vertex pointer
	copy	v7[1], v5[1]						; Copy destination vertex pointer
	addm	r0, v5[0]							; Previous vertex pointer complete
	}

	st_v	v7, (_MPEPolygonRightEdge)			; Save pointers/vertex count
	; Get last vertex data
	{
	ld_v	(v5[0]), v7							; Load old vertex xyzw
	add		#16, v5[0], r0						; Increment vertex pointer
	}
	ld_v	(r0), v4							; Load old vertex uvC

	; Calculate clip state of last vertex
	{
	sub		v7[3], #0, v1[1]
	mul		v6[0], v7[0], >>acshift, v1[0]		
	}
	{
	lsr		#06, v4[0]							; Shift clip codes out of s
	mul		v6[1], v7[1], >>acshift, v0[2]
	}
	{
	mul		v6[2], v7[2], >>acshift, v0[3]
	add		v1[0], v1[1]
	}
	add		v0[2], v1[1]
	add		v0[3], v1[1]
	{
	bra		lt, `EdgeLoop, nop
	mv_s	#CLIP_INSIDE, v1[3]					; Indicate vertex is inside
	lsl		#06, v4[0]							; Shift s back into position
	}

	mv_s	#CLIP_OUTSIDE, v1[3]
	
`EdgeLoop:

	; Read current vertex
	{
	ld_v	(v5[2]), v3							; Read current vertex xyzw
	add		#16, v5[2]							; Advance vertex pointer
	}
	{
	ld_v	(v5[2]), v2							; Read current vertex uvC
	add		#16, v5[2]							; Advance vertex pointer
	dec		rc0									; Decrement vertex counter
	}
	
	; Get state of current vertex
	{
	sub		v3[3], #0, v1[0]
	mul		v6[0], v3[0], >>acshift, v0[1]
	}
	{
	lsr		#06, v2[0]							; Shift out clip codes
	mul		v6[1], v3[1], >>acshift, v0[2]
	}
	{
	mul		v6[2], v3[2], >>acshift, v0[3]
	add		v0[1], v1[0]
	}
	add		v0[2], v1[0]
	lsl		#06, v2[0]							; Shift s back into position
	add		v0[3], v1[0]
	
	{
	bra		lt, `VertexIn, nop
	cmp		#CLIP_OUTSIDE, v1[3]				; Check state of previous vertex
	mv_s	#CLIP_INSIDE, v1[2]
	}

	mv_s	#CLIP_OUTSIDE, v1[2]
	bra		eq, `CopyVertex, nop				; Last vertex outside, so is this one

	; If out, but previously in, add exit
`AddExit:
	{
	st_v	v3, (_MPEPolygonLeftEdge)			; Save current xyzw
	sub		v1[1], v1[0], r0					; Calculate -dp(old) + dp(curr)		
	subm	v7[0], v3[0]						; Calculate dX
	}
	{
	st_v	v2, (_MPEPolygonLeftEdge+16)		; Save current uvC and position C for ld_sv					
	abs		r0									; Make denominator positive
	subm	v7[1], v3[1]						; Calculate dY
	}
	{
	st_v	v4, (_MPEPolygonLeftEdge+32)		; Save previous uvC and position C for ld_sv
	msb		r0, r1								; Calculate MSB of denominator
	subm	v7[2], v3[2]						; Calculate dZ
	}
	{
	push	v6									; Save v6
	sub		#08, r1, r2
	subm	v7[3], v3[3]						; Calculate dW
	}
	{
	mv_s	#_MPERecipLUT-128, v6[0]
	ls		r2, r0, r3
	}
	{
	mv_s	#$40000000, r3
	add		r3, v6[0]
	subm	v4[0], v2[0]						; Calculate dS
	}
	{
	ld_b	(v6[0]), v5[0]
	subm	v4[1], v2[1]						; Calculate dT
	}
	{
	add		#24+GLXYZWCLIPSHIFT, r2
	}
	{
	push	v5									; Save v5
	or		v5[0], >>#2, r3
	}
	{
	mv_s	#$7fffffff, v6[0]					; Copy TWO into v6[0]
	copy	v1[1], r1							; Copy dp(old) into r1
	mul		r3, r0, >>r1, r0
	}
	{
	ld_sv	(_MPEPolygonLeftEdge+40), v5			; Load previous C
	abs		r1									; Insure dp(old) is positive
	}
	{
	ld_sv	(_MPEPolygonLeftEdge+24), v6		; Load current C
	sub		r0, v6[0], r0
	}
	mul		r3, r0, >>r2, r0					; 1/denominator complete
	sub_sv	v5, v6								; Calculate dC
	mul		r1, r0, >>acshift, r0				; Alpha complete
	st_s	#24, (acshift)						; Alter acshift for interpolation
	mul		r0, v3[0]							; Calculate interpolated dX
	mul		r0, v3[1]							; Calculate interpolated dY
	{
	add		v3[0], v7[0]						; Calculate exit x
	mul		r0, v3[2]							; Calculate interpolated dZ
	}
	{
	add		v3[1], v7[1]						; Calculate exit y
	mul		r0, v3[3]							; Calculate interpolated dW
	}
	{
	add		v3[2], v7[2]						; Calculate exit z
	mul		r0, v2[0]							; Calculate interpolated dU
	}
	{
	add		v3[3], v7[3]						; Calculate exit w
	mul		r0, v2[1]							; Calculate interpolated dV
	}
	{
	add		v2[0], v4[0]						; Calculate exit s
	mul_sv	r0, v6, >>#24, v6					; Calculate interpolated dC
	}
	add		v2[1], v4[1]						; Calculate exit t
	{
	pop		v5									; Restore v5
	add_sv	v5, v6								; Calculate exit C 
	}
	ld_v	(_MPEPolygonLeftEdge), v3			; Load current xyzw
	{
	st_v	v7, (v5[1])							; Store exit xyzw
	add		#16, v5[1]
	}
	{
	st_v	v4, (v5[1])							; Store exit uv
	add		#08, v5[1]							; Increment destination vertex pointer
	}
	{
	st_sv	v6, (v5[1])							; Store exit C
	add		#08, v5[1]							; Increment destination vertex pointer
	}
	{
	bra		`CopyVertex							; We're done
	ld_v	(_MPEPolygonLeftEdge+16), v2		; Load current uvC
	}
	pop		v6									; Restore clip plane
	{
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Wait on pop
	add		#01, v5[3]							; Increment output vertex count
	}
	
`VertexIn:
	bra		ne, `AddVertex

	; If in, but previously outside, add entrance
`AddEntrance:
	{
	sub		v1[0], v1[1], r0					; Calculate alpha denominator
	subm	v3[0], v7[0]						; Calculate dX
	}
	{				
	st_v	v2, (_MPEPolygonLeftEdge+16)		; Save current uvC to position C for ld_sv
	abs		r0									; Insure denominator is positive		
	subm	v3[1], v7[1]						; Calculate dY
	}
	{
	st_v	v4, (_MPEPolygonLeftEdge+32)		; Save previous uvC and position C for ld_sv
	msb		r0, r1								; Calculate MSB of dot product
	subm	v3[2], v7[2]						; Calculate dZ
	}
	{
	push	v6									; Save v6
	sub		#08, r1, r2
	subm	v3[3], v7[3]						; Calculate dW
	}
	{
	mv_s	#_MPERecipLUT-128, v6[0]
	ls		r2, r0, r3
	}
	{
	mv_s	#$40000000, r3
	add		r3, v6[0]
	subm	v2[0], v4[0]						; Calculate dS
	}
	{
	ld_b	(v6[0]), v5[0]
	subm	v2[1], v4[1]						; Calculate dT
	}
	add		#24+GLXYZWCLIPSHIFT, r2
	{
	push	v5									; Save v5
	or		v5[0], >>#2, r3
	}
	{
	mv_s	#$7fffffff, v6[0]					; Copy TWO into v6[0]
	copy	v1[0], r1							; R1 holds numerator
	mul		r3, r0, >>r1, r0
	}
	ld_sv	(_MPEPolygonLeftEdge+24), v5		; Load current C
	{
	ld_sv	(_MPEPolygonLeftEdge+40), v6		; Load previous C
	sub		r0, v6[0], r0
	}
	{
	abs		r1									; Insure numerator is positive
	mul		r3, r0, >>r2, r0					; 1/denominator complete
	}
	sub_sv	v5, v6								; Calculate dC
	mul		r1, r0, >>acshift, r0				; Interpolated alpha complete
	st_s	#24, (acshift)						; Alter acshift for interpolation
	mul		r0, v7[0]							; Calculate interpolated dX
	mul		r0, v7[1]							; Calculate interpolated dY
	{
	add		v3[0], v7[0]						; Calculate entering x
	mul		r0, v7[2]							; Calculate interpolated dZ
	}
	{
	add		v3[1], v7[1]						; Calculate entering y
	mul		r0, v7[3]							; Calculate interpolated dW
	}
	{
	add		v3[2], v7[2]						; Calculate entering z
	mul		r0, v4[0]							; Calculate interpolated dS
	}
	{
	add		v3[3], v7[3]						; Calculate entering w
	mul		r0, v4[1]							; Calculate interpolated dT
	}
	{
	add		v2[0], v4[0]						; Calculate entering s
	mul_sv	r0, v6, >>#24, v6					; Calculate interpolated dC
	}
	{
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Restore acshift
	add		v2[1], v4[1]						; Calculate entering t
	}
	{
	pop		v5									; Restore v5
	add_sv	v5, v6								; Calculate entering C 
	}
	nop
	{
	st_v	v7, (v5[1])							; Store entering xyzw
	add		#16, v5[1]							; Increment destination vertex pointer
	}
	{
	st_v	v4, (v5[1])							; Store entering uv
	add		#08, v5[1]							; Increment destination vertex pointer
	}
	{
	st_sv	v6, (v5[1])							; Store entering C
	add		#08, v5[1]							; Increment destination vertex pointer
	}
	{
	pop		v6									; Restore clip plane	
	add		#01, v5[3]							; Increment output vertex count
	}
	
	; If in, add vertex
`AddVertex:
	{
	st_v	v3, (v5[1])					; Store current vertex xyzw
	add		#16, v5[1]					; Increment destination vertex pointer
	}
	{
	st_v	v2, (v5[1])					; Store current vertex uvC
	add		#16, v5[1]					; Increment destination vertex pointer
	}
	add		#01, v5[3]					; Increment output vertex count
	
`CopyVertex:
	{
	bra		c0ne, `EdgeLoop
	mv_v	v2, v4						; Copy current vertex uvC to old vertex uvC
	copy	v1[0], v1[1]				; Copy current vertex dot product into old dot product
	}
	{
	mv_v	v3, v7						; Copy current vertex xyzw to old vertex xyzw
	copy	v1[2], v1[3]				; Copy current vertex clip code into old clip code
	}


	; Update destination buffer
`SwapBuffers:
	nop											; Double duty NOP, remove with care
	ld_v		(_MPEPolygonRightEdge), v7		; Restore v7 parameters
	nop
	mv_s	v5[3], v7[3]						; Update vertex count
	{
	mv_s	v7[1], v7[2]						; Exchange vertex buffer pointers
	eor		#DMA_CACHE_EOR, v7[1]
	}

`AdvancePlane:
	neg		v6[3]								; Flip w component sign
	{
	bra		gt, `noadvance						; Branch if on even clip plane
	neg		v6[2]								; Flip z component sign
	dec		rc1									; Decrement clip plane counter				
	}
	{
	neg		v6[1]								; Flip y component sign
	mul		#1, v7[0], >>#1, v7[0]				; Right shift clip code sum
	}
	neg		v6[0]								; Flip x component sign


	; Advance clipping plane components
	{
	mv_s	v6[0], v6[1]						; Copy x component into y component
	copy	v6[1], v6[2]						; Copy y component into z component
	subm	v6[0], v6[0]						; Zero x component
	}

`noadvance:
	bra		c1ne, `ClipLoop
	cmp		#02, v7[3]							; Check for 3 or greater vertex count
	rts		le
	st_s	v7[3], (_MPEPolygonVertices)		; Store positive vertex count
	
	; Perform perspective division and viewpoint transform from source to MPEPolygonVerexList
	; v7[1] = _MPEPolygonVertexList-32
	; v7[2] = input vertex pointer
	; v7[3] = Input vertex counter
`CopyPolygon:
	nop
	ld_sv	(_MPEViewport+8), v2				; Load x/y viewport data
	ld_v	(_MPEViewport), v1					; Load z viewport data
	st_s	#GLINVWSCREENSHIFT, (acshift)		; Initialize multiply shift
	{
	mv_s	#_MPEPolygonVertexList-32, v7[1]	; Initialize destination pointer
	add		#01, v7[3], v7[0]					; Increment polygon vertices
	}
	st_s	v7[0], (rc0)						; Store vertex counter
	{
	mv_s	#$7fffffff, v7[0]					; v7[0] hold TWO for multiplies
	asr		#(16-GLXYZSCREENSHIFT), v2[1]		; Convert viewport x midpoint to fixed point
	}
	{
	mv_s	#$40000000, v0[0]					; v7[3] holds 8 bit LUT to 32 bit scalar conversion value
	asr		#(16-GLXYZSCREENSHIFT), v2[3]		; Convert viewport y midpoint to fixed point
	}


`CopyLoop:
	{
	ld_v	(v7[2]), v5											; Load current vertex xyzw
	add		#16, v7[2]											; Increment source vertex pointer
	mul		v7[3], v3[0], >>#GLXYZWCLIPSHIFT+1, v3[0]			; Calculate xd
	}

	mul		v7[3], v3[1], >>#GLXYZWCLIPSHIFT+1, v3[1]			; Calculate yd
	abs		v5[3]

	{
	msb		v5[3], r1											; Calculate log(2) of current w
	mul		v7[3], v3[2], >>#GLXYZWCLIPSHIFT+1, v3[2]			; Calculate zd
	}

	{
	mv_s	v7[3], v3[3]										; Copy 1/w into v3[3]
	sub		#08, r1, r2											; Convert log(2)w into index shift
	mul		v2[0], v3[0], >>#30+(16-GLXYZSCREENSHIFT), v3[0]	; Scale xd by viewport width/2
	}

	{
	ls		r2, v5[3], r3										; Convert w into index offset
	mul		v2[2], v3[1], >>#30+(16-GLXYZSCREENSHIFT), v3[1]	; Scale yd by viewport height/2
	}

	{
	mv_s	v0[0], r3											; Copy sign conversion value into r3
	add		#_MPERecipLUT-128, r3, r6							; Convert index offset into LUT index				
	mul		v1[0], v3[2], >>#30, v3[2]							; Scale zd by depth/2
	}

	{
	ld_b	(r6), r7							; Load LUT value
	add		v2[1], v3[0]						; xw complete
	}

	{
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, r2	; Convert index shift into final shift
	addm	v2[3], v3[1]						; yw complete
	}

	{
	or		r7, >>#2, r3						; Convert 8 bit LUT value to 32 bit scalar
	mul		v3[3], v4[0]						; Calculate s/w
	}

	{
	add		v1[1], v3[2]						; zw complete
	mul		r3, v5[3], >>r1, v5[3]				; Calculate xy
	}

	{
	st_v	v3, (v7[1])							; Store converted xyzw
	add		#16, v7[1]							; Increment destination vertex pointer
	mul		v3[3], v4[1]						; Calculate t/w
	dec		rc0									; Decrement vertex counter
	}

	{
	bra		c0ne, `CopyLoop						; Branch if more conversion needed
	mv_v	v5, v3								; Copy current xyzw for conversion
	sub		v5[3], v7[0], v7[3]					; Calculate 2-xy
	}
	
	{
	jmp		RASTERIZER_OVERLAY_ORIGIN			; Rasterize polygon
	st_v	v4, (v7[1])							; Store converted uvC
	add		#16, v7[1]							; Increment destination vertex pointer
	mul		r3, v7[3], >>r2, v7[3]				; 1/w complete
	}

	{
	ld_v	(v7[2]), v4							; Load current uvC
	add		#16, v7[2]							; Increment source vertex pointer
	}
	nop
.align.sv
_ClipXYZWUVC_end:

.module Clip2
.export _ClipXYZWCTriangle
.export _ClipXYZWCTriangle_size
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPERecipLUT
.import _MPEGRBtoYCB
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEVertexCache
.import _MPEVertexCacheVertex
.import _MPEVertexCacheVertices
.import _MPEDMACache1
.import _MPEViewport



	; Register allocations
	; v7	=		Old vertex xyzw
	; v7[3] =		Input vertex counter
	; v7[2] =		Initial input vertex pointer
	; v7[1] = 		Initial output vertex pointer
	; v7[0] = 		Summed clip codes for triangle
	; v6	=		Previous vertex C
	; v6    =		Current clip plane equation
	; v5	=		Current vertex C
	; v5[3] = 		Output vertex count
	; v5[2] =		Current input vertex pointer
	; v5[1] =		Current output vertex pointer
	; v5[0] =		Previous output vertex pointer
	; v4	=		Old vertex uvC
	; v3	=		Current vertex xyzw
	; v2	=		Current vertex C  c
	; v1[3] =		Old vertex clip code
	; v1[2] =		Current vertex clip code
	; v1[1]	=		Previous vertex clip plane dot product
	; v1[0] =		Current vertex clip plane dot product

	_ClipXYZWCTriangle_size = _ClipXYZWC_end-_ClipXYZWCTriangle
.align.sv
_ClipXYZWCTriangle:
	ld_s	(_MPEVertexCacheVertex), v7[2]		; Grab current vertex pointer
	ld_s	(_MPEPolygonVertices), v7[3]		; Grab current vertex count
	add		#16, v7[2]							; Shift vertex pointer to clip code
	{
	cmp		#00, v7[3]							; Check for negative vertex count
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Set multiplication shift
	}
	{
	bra		ge, `CopyPolygon					; Skip clipping if trivial accept
	ld_s	(v7[2]), v7[0]						; Load first clip code
	add		#32, v7[2]							; Advance vertex pointer
	subm	v6[1], v6[1]						; Zero y component of clip plane normal
	}
	{
	ld_s	(v7[2]), r1							; Load second clip code
	add		#32, v7[2]							; Advance vertex pointer
	subm	v6[2], v6[2]						; Zero z component of clip plane normal
	}
	{
	ld_s	(v7[2]), r2							; Load third clip code
	sub		#80, v7[2]							; Reset vertex pointer
	}
	
	abs		v7[3]								; Insure vertex count is positive
	; Initialize clipping plane equation and clip plane count
`BuildClipPlanes:

	; pixel DMA cache will be used for scratch space, so wait for DMA to complete
`DMAwait:
	ld_s	(mdmactl), r0						; Read DMA control register
	nop
	and		#$f, r0								; Check for DMA activity
	bra		ne, `DMAwait

	{
	st_s	#6, (rc1)							; Initialize clip plane count
	or		r1, v7[0]							; Determine clip plane sum
	}
	{
	mv_s	#-(1<<GLXYZWCLIPSHIFT), v6[3]			; Initialize clip w component
	or		r2, v7[0]							; Clip codes complete
	}
	{
	mv_s	#_MPEDMACache1, v7[1]				; Initialize Destination DMA pointer
	sub		v6[3], #0, v6[0]					; Initialize clip x component					
	}

`ClipLoop:

	; Test if current clip plane violated at all
	{
	mv_s	v7[3], r0							; Copy vertex count into R0
	btst	#0, v7[0]							; Check if current plane active
	subm	v5[3], v5[3]						; Initialize output vertex count
	}

	; Skip clip plane if not violated
	{
	bra		eq, `AdvancePlane					; Jump if clipping plane not violated
	st_s	r0, (rc0)							; Initialize edge counter
	mul		#1, r0, >>#-5, r0					; Calculate vertex list length
	}
	{
	st_s	#1, (svshift)						; Set up small vector shift
	sub		#32, v7[2], v5[0]					; Determine initial offset for previous vertex pointer
	}
	{
	mv_s	v7[2], v5[2]						; Copy source vertex pointer
	copy	v7[1], v5[1]						; Copy destination vertex pointer
	addm	r0, v5[0]							; Previous vertex pointer complete
	}

	st_v	v7, (_MPEPolygonRightEdge)			; Save pointers/vertex count
	; Get last vertex data
	{
	ld_v	(v5[0]), v7							; Load old vertex xyzw
	add		#24, v5[0], r0						; Increment vertex pointer
	}
	ld_sv	(r0), v4							; Load old vertex C

	; Calculate clip state of last vertex
	{
	sub		v7[3], #0, v1[1]
	mul		v6[0], v7[0], >>acshift, v1[0]		
	}
	{
	lsr		#06, v4[0]							; Shift clip codes out of s
	mul		v6[1], v7[1], >>acshift, v0[2]
	}
	{
	mul		v6[2], v7[2], >>acshift, v0[3]
	add		v1[0], v1[1]
	}
	add		v0[2], v1[1]
	add		v0[3], v1[1]
	{
	bra		lt, `EdgeLoop, nop
	mv_s	#CLIP_INSIDE, v1[3]					; Indicate vertex is inside
	lsl		#06, v4[0]							; Shift s back into position
	}

	mv_s	#CLIP_OUTSIDE, v1[3]
	
`EdgeLoop:
	; Read current vertex
	{
	ld_v	(v5[2]), v3							; Read current vertex xyzw
	add		#24, v5[2]							; Advance vertex pointer
	}
	{
	ld_sv	(v5[2]), v2							; Read current vertex C into v2
	add		#8, v5[2]							; Advance vertex pointer
	dec		rc0									; Decrement vertex counter
	}
	
	; Get state of current vertex
	{
	sub		v3[3], #0, v1[0]
	mul		v6[0], v3[0], >>acshift, v0[1]
	}
	mul		v6[1], v3[1], >>acshift, v0[2]
	{
	mul		v6[2], v3[2], >>acshift, v0[3]
	add		v0[1], v1[0]
	}
	add		v0[2], v1[0]
	add		v0[3], v1[0]
	
	{
	bra		lt, `VertexIn, nop
	cmp		#CLIP_OUTSIDE, v1[3]				; Check state of previous vertex
	mv_s	#CLIP_INSIDE, v1[2]
	}

	mv_s	#CLIP_OUTSIDE, v1[2]
	bra		eq, `CopyVertex, nop				; Last vertex outside, so is this one

	; If out, but previously in, add exit
`AddExit:
	{
	st_v	v3, (_MPEPolygonLeftEdge)			; Save current xyzw
	sub		v1[1], v1[0], r0					; Calculate -dp(old) + dp(curr)		
	subm	v7[0], v3[0]						; Calculate dX
	}
	{
	st_sv	v2, (_MPEPolygonLeftEdge+16)		; Save current C					
	abs		r0									; Make denominator positive
	subm	v7[1], v3[1]						; Calculate dY
	}
	{
	st_sv	v4, (_MPEPolygonLeftEdge+32)		; Save previous C
	msb		r0, r1								; Calculate MSB of denominator
	subm	v7[2], v3[2]						; Calculate dZ
	}
	{
	push	v6									; Save v6
	sub		#08, r1, r2
	subm	v7[3], v3[3]						; Calculate dW
	}
	{
	mv_s	#_MPERecipLUT-128, v6[0]
	ls		r2, r0, r3
	}
	{
	mv_s	#$40000000, r3
	add		r3, v6[0]
	}
	{
	ld_b	(v6[0]), v5[0]
	}
	{
	add		#24+GLXYZWCLIPSHIFT, r2
	}
	{
	push	v5									; Save v5
	or		v5[0], >>#2, r3
	}
	{
	mv_s	#$7fffffff, v6[0]					; Copy TWO into v6[0]
	copy	v1[1], r1							; Copy dp(old) into r1
	mul		r3, r0, >>r1, r0
	}
	{
	abs		r1									; Insure dp(old) is positive
	}
	{
	sub		r0, v6[0], r0
	}
	mul		r3, r0, >>r2, r0					; 1/denominator complete
	sub_sv	v4, v2								; Calculate dC
	mul		r1, r0, >>acshift, r0				; Alpha complete
	st_s	#24, (acshift)						; Alter acshift for interpolation
	mul		r0, v3[0]							; Calculate interpolated dX
	mul		r0, v3[1]							; Calculate interpolated dY
	{
	add		v3[0], v7[0]						; Calculate exit x
	mul		r0, v3[2]							; Calculate interpolated dZ
	}
	{
	add		v3[1], v7[1]						; Calculate exit y
	mul		r0, v3[3]							; Calculate interpolated dW
	}
	asl		#06, r0								; Convert interpolator to 2.30
	{
	add		v3[2], v7[2]						; Calculate exit z
	mul_sv	r0, v2, >>#30, v2					; Calculate interpolated dC
	}
	{
	add		v3[3], v7[3]						; Calculate exit w
	}
	{
	pop		v5									; Restore v5
	add_sv	v4, v2								; Calculate exit C 
	}
	ld_v	(_MPEPolygonLeftEdge), v3			; Load current xyzw
	{
	st_v	v7, (v5[1])							; Store exit xyzw
	add		#24, v5[1]
	}
	{
	st_sv	v2, (v5[1])							; Store exit C
	add		#08, v5[1]							; Increment destination vertex pointer
	}
	{
	bra		`CopyVertex							; We're done
	ld_sv	(_MPEPolygonLeftEdge+16), v2		; Load current C
	}
	pop		v6									; Restore clip plane
	{
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Wait on pop
	add		#01, v5[3]							; Increment output vertex count
	}
	
`VertexIn:
	bra		ne, `AddVertex

	; If in, but previously outside, add entrance
`AddEntrance:
	{
	sub		v1[0], v1[1], r0					; Calculate alpha denominator
	subm	v3[0], v7[0]						; Calculate dX
	}
	{				
	st_sv	v2, (_MPEPolygonLeftEdge+16)		; Save current C to position C for ld_sv
	abs		r0									; Insure denominator is positive		
	subm	v3[1], v7[1]						; Calculate dY
	}
	{
	st_sv	v4, (_MPEPolygonLeftEdge+32)		; Save previous C and position C for ld_sv
	msb		r0, r1								; Calculate MSB of dot product
	subm	v3[2], v7[2]						; Calculate dZ
	}
	{
	push	v6									; Save v6
	sub		#08, r1, r2
	subm	v3[3], v7[3]						; Calculate dW
	}
	{
	mv_s	#_MPERecipLUT-128, v6[0]
	ls		r2, r0, r3
	}
	{
	mv_s	#$40000000, r3
	add		r3, v6[0]
	}
	{
	ld_b	(v6[0]), v5[0]
	}
	add		#24+GLXYZWCLIPSHIFT, r2
	{
	push	v5									; Save v5
	or		v5[0], >>#2, r3
	}
	{
	mv_s	#$7fffffff, v6[0]					; Copy TWO into v6[0]
	copy	v1[0], r1							; R1 holds numerator
	mul		r3, r0, >>r1, r0
	}
	sub_sv	v2, v4								; Calculate dC
	{
	sub		r0, v6[0], r0
	}
	mul		r3, r0, >>r2, r0					; 1/denominator complete
	abs		r1									; Insure numerator is positive
	mul		r1, r0, >>acshift, r0				; Interpolated alpha complete
	st_s	#24, (acshift)						; Alter acshift for interpolation
	mul		r0, v7[0]							; Calculate interpolated dX
	mul		r0, v7[1]							; Calculate interpolated dY
	{
	add		v3[0], v7[0]						; Calculate entering x
	mul		r0, v7[2]							; Calculate interpolated dZ
	}
	{
	add		v3[1], v7[1]						; Calculate entering y
	mul		r0, v7[3]							; Calculate interpolated dW
	}
	{
	add		v3[2], v7[2]						; Calculate entering z
	}
	{
	asl		#6, r0								; Convert interpolator to 2.30			
	addm	v3[3], v7[3]						; Calculate entering w
	}
	{
	mul_sv	r0, v4, >>#30, v4					; Calculate interpolated dC
	}
	{
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Restore acshift
	}
	{
	pop		v5									; Restore v5
	add_sv	v2, v4								; Calculate entering C 
	}
	nop
	{
	st_v	v7, (v5[1])							; Store entering xyzw
	add		#24, v5[1]							; Increment destination vertex pointer
	}
	{
	st_sv	v4, (v5[1])							; Store entering C
	add		#8, v5[1]							; Increment destination vertex pointer
	}
	{
	pop		v6									; Restore clip plane	
	add		#01, v5[3]							; Increment output vertex count
	}
		


	; If in, add vertex
`AddVertex:
	{
	st_v	v3, (v5[1])					; Store current vertex xyzw
	add		#24, v5[1]					; Increment destination vertex pointer
	}
	{
	st_sv	v2, (v5[1])					; Store current vertex uvC
	add		#08, v5[1]					; Increment destination vertex pointer
	}
	add		#01, v5[3]					; Increment output vertex count
	
`CopyVertex:
	{
	bra		c0ne, `EdgeLoop
	mv_v	v2, v4						; Copy current vertex C to old vertex C
	copy	v1[0], v1[1]				; Copy current vertex dot product into old dot product
	}
	{
	mv_v	v3, v7						; Copy current vertex xyzw to old vertex xyzw
	copy	v1[2], v1[3]				; Copy current vertex clip code into old clip code
	}


	; Update destination buffer
`SwapBuffers:
	nop											; Double duty NOP, remove with care
	ld_v		(_MPEPolygonRightEdge), v7		; Restore v7 parameters
	nop
	mv_s	v5[3], v7[3]						; Update vertex count
	{
	mv_s	v7[1], v7[2]						; Exchange vertex buffer pointers
	eor		#DMA_CACHE_EOR, v7[1]
	}

`AdvancePlane:
	neg		v6[3]								; Flip w component sign
	{
	bra		gt, `noadvance						; Branch if on even clip plane
	neg		v6[2]								; Flip z component sign
	dec		rc1									; Decrement clip plane counter				
	}
	{
	neg		v6[1]								; Flip y component sign
	mul		#1, v7[0], >>#1, v7[0]				; Right shift clip code sum
	}
	neg		v6[0]								; Flip x component sign


	; Advance clipping plane components
	{
	mv_s	v6[0], v6[1]						; Copy x component into y component
	copy	v6[1], v6[2]						; Copy y component into z component
	subm	v6[0], v6[0]						; Zero x component
	}

`noadvance:
	bra		c1ne, `ClipLoop
	cmp		#02, v7[3]							; Make sure vertex count >= 3
	rts		le
	st_s	v7[3], (_MPEPolygonVertices)		; Store positive vertex count

	; Perform perspective division and viewpoint transform from source to MPEPolygonVerexList
	; v7[2] = input vertex pointer
	; v7[3] = Input vertex counter
`CopyPolygon:
	nop
	ld_v	(_MPEViewport), v1					; Load z viewport data
	ld_sv	(_MPEViewport+8), v2				; Load x/y viewport data
	st_s	v7[3], (rc0)						; Store vertex counter
	mv_s	#_MPEPolygonVertexList-32, v7[3]	; Initialize destination pointer
	{
	mv_s	v1[0], v7[0]						; Copy Z width into v7[0]
	asr		#(16-GLXYZSCREENSHIFT), v2[1]		; Convert viewport x midpoint to fixed point
	}
	{
	mv_s	v1[1], v7[1]						; Copy Z offset into v7[1]
	asr		#(16-GLXYZSCREENSHIFT), v2[3]		; Convert viewport y midpoint to fixed point
	}

`CopyLoop:
	; 1
	{
	ld_v	(v7[2]), v5											; Read in current xyzw clip coordinates
	 copy	v5[3], v3[3]										; Copy 1/w into final resting place
	 mul	v5[3], v3[0], >>#GLXYZWCLIPSHIFT+1, v3[0]			; Calculate xd from xc
	}

	; 2
	{
	add		#24, v7[2]											; Increment source vertex pointer
	 mul	v3[3], v3[1], >>#GLXYZWCLIPSHIFT+1, v3[1]			; Calculate yd from yc
	}

	; 3
	abs		v5[3]												; Insure w is positive
	
	; 4
	{
	 mv_s	v4[3], v6[3]										; Copy vertex color alpha
	msb		v5[3], r1											; Calculate MSB of wc
	 mul	v3[3], v3[2], >>#GLXYZWCLIPSHIFT+1, v3[2]			; Calculate zd
	}

	; 5
	{
	 mv_s	#$40000000, v4[3]									; $40000000 is used for color conversion offsets
	sub		#08, r1, r2											; Convert wc MSB into index shift
	 mul	v2[0], v3[0], >>#30+(16-GLXYZSCREENSHIFT), v3[0]	; Calculate xs from xd
	}

	; 6
	{
	mv_s	v4[3], r3											; It also makes a great signed conversion mask!
	ls		r2, v5[3], r0										; R0 holds index offset
	}

	; 7
	{
	 ld_sv	(_MPEGRBtoYCB), v1								; Read in 1st row of color conversion matrix
	add		#_MPERecipLUT-128, r0								; Convert R0 to LUT pointer
	 mul	v7[0], v3[2], >>#30, v3[2]							; Calculate zs offset
	}

	; 8
	{
	ld_b	(r0), r0											; Read LUT value
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, r2					; Convert R2 into final offset
	 mul	v2[2], v3[1], >>#30+(16-GLXYZSCREENSHIFT), v3[1]	; Calculate ys offset
	}

	; 9
	{
	 ld_sv	(_MPEGRBtoYCB+8), v1							; Read row 2 of color conversion matrix
	 add	v2[1], v3[0]										; xs complete
	 dotp	v1, v4, >>#30, v6[0]								; Calculate Y
	}

	; 10
	{
	or		r0, >>#2, r3										; R3 is 8 bit LUT value
	}

	; 11
	{
	mv_s	#$7fffffff, r0										; R0 holds two
	 add	v2[3], v3[1]										; ys complete
	mul		r3, v5[3], >>r1, v5[3]								; Calculate xy
	}

	; 12
	{
	 ld_sv	(_MPEGRBtoYCB+16), v1							; Load row 3 of color conversion matrix
	 add	v7[1], v3[2]										; zs complete
	 dotp	v1, v4, >>#30, v6[1]								; Calculate C
	}
	
	; 13
	{
 	 st_v	v3, (v7[3])											; Store screenspace coordinates
	 add	#24, v7[3]											; Increment destination vertex pointer
	}

	; 14
	{
	bra		c0ne, `CopyLoop										; Branch if more vertices left
	mv_v	v5, v3												; Copy clip coordinates into v3
	sub		v5[3], r0, v5[3]									; Calculate 2-xy
	 dotp	v1, v4, >>#30, v6[2]								; Calculate B
	}

	; 15
	{
	jmp		RASTERIZER_OVERLAY_ORIGIN							; Jump to polygon rasterizer
	ld_sv	(v7[2]), v4											; Read RGBA
	add		#08, v7[2]											; Increment source vertex pointer
	mul		r3, v5[3], >>r2, v5[3]								; 1/w complete
	}

	; 16
	{
	st_sv	v6, (v7[3])											; Store YCBA
	add		#08, v7[3]											; Increment destination vertex pointer
	dec		rc0													; Post-decrement vertex counter
	}
	nop

.align.sv
_ClipXYZWC_end:


.module Clip3
.export _ClipXYZWUVITriangle
.export _ClipXYZWUVITriangle_size
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPERecipLUT
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEVertexCacheVertex
.import _MPEVertexCacheVertices
.import _MPEDMACache1
.import _MPEViewport


	; Register allocations
	; v7	=		Old vertex xyzw
	; v7[3] =		Input vertex counter
	; v7[2] =		Initial input vertex pointer
	; v7[1] = 		Initial output vertex pointer
	; v7[0] = 		Summed clip codes for triangle
	; v6	=		Previous vertex C
	; v6    =		Current clip plane equation
	; v5	=		Current vertex C
	; v5[3] = 		Output vertex count
	; v5[2] =		Current input vertex pointer
	; v5[1] =		Current output vertex pointer
	; v5[0] =		Previous output vertex pointer
	; v4	=		Old vertex uvC
	; v3	=		Current vertex xyzw
	; v2	=		Current vertex uvC
	; v1[3] =		Old vertex clip code
	; v1[2] =		Current vertex clip code
	; v1[1]	=		Previous vertex clip plane dot product
	; v1[0] =		Current vertex clip plane dot product

	_ClipXYZWUVITriangle_size = _ClipXYZWUVI_end-_ClipXYZWUVITriangle
.align.sv
_ClipXYZWUVITriangle:
	ld_s	(_MPEVertexCacheVertex), v7[2]		; Grab current vertex pointer
	ld_s	(_MPEPolygonVertices), v7[3]		; Grab current vertex count
	add		#16, v7[2]							; Shift vertex pointer to texture vertices
	{
	cmp		#00, v7[3]							; Check for negative vertex count
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Set multiplication shift
	}
	{
	bra		ge, `CopyPolygon					; Skip clipping if trivial accept
	ld_s	(v7[2]), v7[0]						; Load first clip code
	add		#32, v7[2]							; Advance vertex pointer
	subm	v6[1], v6[1]						; Zero y component of clip plane normal
	}
	{
	ld_s	(v7[2]), r1							; Load second clip code
	add		#32, v7[2]							; Advance vertex pointer
	subm	v6[2], v6[2]						; Zero z component of clip plane normal
	}
	{
	ld_s	(v7[2]), r2							; Load third clip code
	sub		#80, v7[2]							; Reset vertex pointer
	}
	
	abs		v7[3]								; Insure vertex count is positive
	; Initialize clipping plane equation and clip plane count
`BuildClipPlanes:

	; pixel DMA cache will be used for scratch space, so wait for DMA to complete
`DMAwait:
	ld_s	(mdmactl), r0						; Read DMA control register
	nop
	and		#$f, r0								; Check for DMA activity
	bra		ne, `DMAwait

	{
	st_s	#6, (rc1)							; Initialize clip plane count
	or		r1, v7[0]							; Determine clip plane sum
	}
	{
	mv_s	#-(1<<GLXYZWCLIPSHIFT), v6[3]			; Initialize clip w component
	or		r2, v7[0]							; Clip codes complete
	}
	{
	mv_s	#_MPEDMACache1, v7[1]				; Initialize Destination DMA pointer
	sub		v6[3], #0, v6[0]					; Initialize clip x component					
	}

`ClipLoop:
	; Test if current clip plane violated at all
	{
	mv_s	v7[3], r0							; Copy vertex count into R0
	btst	#0, v7[0]							; Check if current plane active
	subm	v5[3], v5[3]						; Initialize output vertex count
	}

	; Skip clip plane if not violated
	{
	bra		eq, `AdvancePlane					; Jump if clipping plane not violated
	st_s	r0, (rc0)							; Initialize edge counter
	mul		#1, r0, >>#-5, r0					; Calculate vertex list length
	}
	{
	st_s	#1, (svshift)						; Set up small vector shift
	sub		#32, v7[2], v5[0]					; Determine initial offset for previous vertex pointer
	}
	{
	mv_s	v7[2], v5[2]						; Copy source vertex pointer
	copy	v7[1], v5[1]						; Copy destination vertex pointer
	addm	r0, v5[0]							; Previous vertex pointer complete
	}

	st_v	v7, (_MPEPolygonRightEdge)			; Save pointers/vertex count
	; Get last vertex data
	{
	ld_v	(v5[0]), v7							; Load old vertex xyzw
	add		#16, v5[0], r0						; Increment vertex pointer
	}
	ld_v	(r0), v4							; Load old vertex uvI

	; Calculate clip state of last vertex
	{
	sub		v7[3], #0, v1[1]
	mul		v6[0], v7[0], >>acshift, v1[0]		
	}
	{
	lsr		#06, v4[0]							; Shift clip codes out of s
	mul		v6[1], v7[1], >>acshift, v0[2]
	}
	{
	mul		v6[2], v7[2], >>acshift, v0[3]
	add		v1[0], v1[1]
	}
	add		v0[2], v1[1]
	add		v0[3], v1[1]
	{
	bra		lt, `EdgeLoop, nop
	mv_s	#CLIP_INSIDE, v1[3]					; Indicate vertex is inside
	lsl		#06, v4[0]							; Shift s back into position
	}

	mv_s	#CLIP_OUTSIDE, v1[3]
	
`EdgeLoop:

	; Read current vertex
	{
	ld_v	(v5[2]), v3							; Read current vertex xyzw
	add		#16, v5[2]							; Advance vertex pointer
	}
	{
	ld_v	(v5[2]), v2							; Read current vertex uvI
	add		#16, v5[2]							; Advance vertex pointer
	dec		rc0									; Decrement vertex counter
	}
	
	; Get state of current vertex
	{
	sub		v3[3], #0, v1[0]
	mul		v6[0], v3[0], >>acshift, v0[1]
	}
	{
	lsr		#06, v2[0]							; Shift out clip codes
	mul		v6[1], v3[1], >>acshift, v0[2]
	}
	{
	mul		v6[2], v3[2], >>acshift, v0[3]
	add		v0[1], v1[0]
	}
	add		v0[2], v1[0]
	lsl		#06, v2[0]							; Shift s back into position
	add		v0[3], v1[0]
	
	{
	bra		lt, `VertexIn, nop
	cmp		#CLIP_OUTSIDE, v1[3]				; Check state of previous vertex
	mv_s	#CLIP_INSIDE, v1[2]
	}

	mv_s	#CLIP_OUTSIDE, v1[2]
	bra		eq, `CopyVertex, nop				; Last vertex outside, so is this one

	; If out, but previously in, add exit
`AddExit:
	{
	st_v	v3, (_MPEPolygonLeftEdge)			; Save current xyzw
	sub		v1[1], v1[0], r0					; Calculate -dp(old) + dp(curr)		
	subm	v7[0], v3[0]						; Calculate dX
	}
	{
	st_v	v2, (_MPEPolygonLeftEdge+16)		; Save current uvI			
	abs		r0									; Make denominator positive
	subm	v7[1], v3[1]						; Calculate dY
	}
	{
	msb		r0, r1								; Calculate MSB of denominator
	subm	v7[2], v3[2]						; Calculate dZ
	}
	{
	push	v6									; Save v6
	sub		#08, r1, r2
	subm	v7[3], v3[3]						; Calculate dW
	}
	{
	mv_s	#_MPERecipLUT-128, v6[0]
	ls		r2, r0, r3
	}
	{
	mv_s	#$40000000, r3
	add		r3, v6[0]
	subm	v4[0], v2[0]						; Calculate dS
	}
	{
	ld_b	(v6[0]), v5[0]
	subm	v4[1], v2[1]						; Calculate dT
	}
	{
	add		#24+GLXYZWCLIPSHIFT, r2
	subm	v4[2], v2[2]						; Calculate dI
	}
	{
	push	v5									; Save v5
	or		v5[0], >>#2, r3
	}
	{
	mv_s	#$7fffffff, v6[0]					; Copy TWO into v6[0]
	copy	v1[1], r1							; Copy dp(old) into r1
	mul		r3, r0, >>r1, r0
	}
	{
	abs		r1									; Insure dp(old) is positive
	}
	{
	sub		r0, v6[0], r0
	}
	mul		r3, r0, >>r2, r0					; 1/denominator complete
	nop
	mul		r1, r0, >>acshift, r0				; Alpha complete
	st_s	#24, (acshift)						; Alter acshift for interpolation
	mul		r0, v3[0]							; Calculate interpolated dX
	mul		r0, v3[1]							; Calculate interpolated dY
	{
	add		v3[0], v7[0]						; Calculate exit x
	mul		r0, v3[2]							; Calculate interpolated dZ
	}
	{
	add		v3[1], v7[1]						; Calculate exit y
	mul		r0, v3[3]							; Calculate interpolated dW
	}
	{
	add		v3[2], v7[2]						; Calculate exit z
	mul		r0, v2[0]							; Calculate interpolated dS
	}
	{
	add		v3[3], v7[3]						; Calculate exit w
	mul		r0, v2[1]							; Calculate interpolated dT
	}
	{
	add		v2[0], v4[0]						; Calculate exit s
	mul		r0, v2[2]							; Calculate interpolated dI
	}
	add		v2[1], v4[1]						; Calculate exit t
	{
	pop		v5									; Restore v5
	add		v2[2], v4[2]						; Calculate exit I
	}
	ld_v	(_MPEPolygonLeftEdge), v3			; Load current xyzw
	{
	st_v	v7, (v5[1])							; Store exit xyzw
	add		#16, v5[1]
	}
	{
	st_v	v4, (v5[1])							; Store exit uvI
	add		#16, v5[1]							; Increment destination vertex pointer
	}
	{
	bra		`CopyVertex							; We're done
	ld_v	(_MPEPolygonLeftEdge+16), v2		; Load current uvI
	}
	pop		v6									; Restore clip plane
	{
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Wait on pop
	add		#01, v5[3]							; Increment output vertex count
	}
	
`VertexIn:
	bra		ne, `AddVertex

	; If in, but previously outside, add entrance
`AddEntrance:
	{
	sub		v1[0], v1[1], r0					; Calculate alpha denominator
	subm	v3[0], v7[0]						; Calculate dX
	}
	{				
	st_v	v2, (_MPEPolygonLeftEdge+16)		; Save current uvI
	abs		r0									; Insure denominator is positive		
	subm	v3[1], v7[1]						; Calculate dY
	}
	{
	st_v	v4, (_MPEPolygonLeftEdge+32)		; Save previous uvI
	msb		r0, r1								; Calculate MSB of dot product
	subm	v3[2], v7[2]						; Calculate dZ
	}
	{
	push	v6									; Save v6
	sub		#08, r1, r2
	subm	v3[3], v7[3]						; Calculate dW
	}
	{
	mv_s	#_MPERecipLUT-128, v6[0]
	ls		r2, r0, r3
	}
	{
	mv_s	#$40000000, r3
	add		r3, v6[0]
	subm	v2[0], v4[0]						; Calculate dS
	}
	{
	ld_b	(v6[0]), v5[0]
	subm	v2[1], v4[1]						; Calculate dT
	}
	add		#24+GLXYZWCLIPSHIFT, r2
	{
	push	v5									; Save v5
	or		v5[0], >>#2, r3
	}
	{
	mv_s	#$7fffffff, v6[0]					; Copy TWO into v6[0]
	copy	v1[0], r1							; R1 holds numerator
	mul		r3, r0, >>r1, r0
	}
	sub		v2[2], v4[2]						; Calculate dI
	{
	sub		r0, v6[0], r0
	}
	{
	abs		r1									; Insure numerator is positive
	mul		r3, r0, >>r2, r0					; 1/denominator complete
	}
	nop
	mul		r1, r0, >>acshift, r0				; Interpolated alpha complete
	st_s	#24, (acshift)						; Alter acshift for interpolation
	mul		r0, v7[0]							; Calculate interpolated dX
	mul		r0, v7[1]							; Calculate interpolated dY
	{
	add		v3[0], v7[0]						; Calculate entering x
	mul		r0, v7[2]							; Calculate interpolated dZ
	}
	{
	add		v3[1], v7[1]						; Calculate entering y
	mul		r0, v7[3]							; Calculate interpolated dW
	}
	{
	add		v3[2], v7[2]						; Calculate entering z
	mul		r0, v4[0]							; Calculate interpolated dS
	}
	{
	add		v3[3], v7[3]						; Calculate entering w
	mul		r0, v4[1]							; Calculate interpolated dT
	}
	{
	add		v2[0], v4[0]						; Calculate entering s
	mul		r0, v4[2]							; Calculate interpolated dI
	}
	{
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Restore acshift
	add		v2[1], v4[1]						; Calculate entering t
	}
	{
	pop		v5									; Restore v5
	add		v2[2], v4[2]						; Calculate entering I
	}
	nop
	{
	st_v	v7, (v5[1])							; Store entering xyzw
	add		#16, v5[1]							; Increment destination vertex pointer
	}
	{
	st_v	v4, (v5[1])							; Store entering uvY
	add		#16, v5[1]							; Increment destination vertex pointer
	}
	{
	pop		v6									; Restore clip plane	
	add		#01, v5[3]							; Increment output vertex count
	}
	
	; If in, add vertex
`AddVertex:
	{
	st_v	v3, (v5[1])					; Store current vertex xyzw
	add		#16, v5[1]					; Increment destination vertex pointer
	}
	{
	st_v	v2, (v5[1])					; Store current vertex uvI
	add		#16, v5[1]					; Increment destination vertex pointer
	}
	add		#01, v5[3]					; Increment output vertex count
	
`CopyVertex:
	{
	bra		c0ne, `EdgeLoop
	mv_v	v2, v4						; Copy current vertex uvI to old vertex uvI
	copy	v1[0], v1[1]				; Copy current vertex dot product into old dot product
	}
	{
	mv_v	v3, v7						; Copy current vertex xyzw to old vertex xyzw
	copy	v1[2], v1[3]				; Copy current vertex clip code into old clip code
	}


	; Update destination buffer
`SwapBuffers:
	nop											; Double duty NOP, remove with care
	ld_v		(_MPEPolygonRightEdge), v7		; Restore v7 parameters
	nop
	mv_s	v5[3], v7[3]						; Update vertex count
	{
	mv_s	v7[1], v7[2]						; Exchange vertex buffer pointers
	eor		#DMA_CACHE_EOR, v7[1]
	}

`AdvancePlane:
	neg		v6[3]								; Flip w component sign
	{
	bra		gt, `noadvance						; Branch if on even clip plane
	neg		v6[2]								; Flip z component sign
	dec		rc1									; Decrement clip plane counter				
	}
	{
	neg		v6[1]								; Flip y component sign
	mul		#1, v7[0], >>#1, v7[0]				; Right shift clip code sum
	}
	neg		v6[0]								; Flip x component sign


	; Advance clipping plane components
	{
	mv_s	v6[0], v6[1]						; Copy x component into y component
	copy	v6[1], v6[2]						; Copy y component into z component
	subm	v6[0], v6[0]						; Zero x component
	}

`noadvance:
	bra		c1ne, `ClipLoop
	cmp		#02, v7[3]							; Check for 3 or greater vertex count
	rts		le
	st_s	v7[3], (_MPEPolygonVertices)		; Store positive vertex count
	
	; Perform perspective division and viewpoint transform from source to MPEPolygonVerexList
	; v7[1] = _MPEPolygonVertexList-32
	; v7[2] = input vertex pointer
	; v7[3] = Input vertex counter
`CopyPolygon:
	nop
	ld_sv	(_MPEViewport+8), v2				; Load x/y viewport data
	ld_v	(_MPEViewport), v1					; Load z viewport data
	st_s	#GLINVWSCREENSHIFT, (acshift)		; Initialize multiply shift
	{
	mv_s	#_MPEPolygonVertexList-32, v7[1]	; Initialize destination pointer
	add		#01, v7[3], v7[0]					; Increment polygon vertices
	}
	st_s	v7[0], (rc0)						; Store vertex counter
	{
	mv_s	#$7fffffff, v7[0]					; v7[0] hold TWO for multiplies
	asr		#(16-GLXYZSCREENSHIFT), v2[1]		; Convert viewport x midpoint to fixed point
	}
	{
	mv_s	#$40000000, v0[0]					; v7[3] holds 8 bit LUT to 32 bit scalar conversion value
	asr		#(16-GLXYZSCREENSHIFT), v2[3]		; Convert viewport y midpoint to fixed point
	}


`CopyLoop:
	; 1
	{
	ld_v	(v7[2]), v5											; Load current vertex xyzw
	add		#16, v7[2]											; Increment source vertex pointer
	mul		v7[3], v3[0], >>#GLXYZWCLIPSHIFT+1, v3[0]			; Calculate xd
	}

	; 2
	mul		v7[3], v3[1], >>#GLXYZWCLIPSHIFT+1, v3[1]			; Calculate yd

	; 3
	abs		v5[3]

	; 4
	{
	msb		v5[3], r1											; Calculate log(2) of current w
	mul		v7[3], v3[2], >>#GLXYZWCLIPSHIFT+1, v3[2]			; Calculate zd
	}

	; 5
	{
	mv_s	v7[3], v3[3]										; Copy 1/w into v3[3]
	sub		#08, r1, r2											; Convert log(2)w into index shift
	mul		v2[0], v3[0], >>#30+(16-GLXYZSCREENSHIFT), v3[0]	; Scale xd by viewport width/2
	}

	; 6
	{
	mv_v	v4, v6												; Use v6 for uvI
	ls		r2, v5[3], r3										; Convert w into index offset
	mul		v2[2], v3[1], >>#30+(16-GLXYZSCREENSHIFT), v3[1]	; Scale yd by viewport height/2
	}

	; 7
	{
	mv_s	v0[0], r3											; Copy sign conversion value into r3
	add		#_MPERecipLUT-128, r3, r6							; Convert index offset into LUT index				
	mul		v1[0], v3[2], >>#30, v3[2]							; Scale zd by depth/2
	}

	; 8
	{
	ld_b	(r6), r7							; Load LUT value
	add		v2[1], v3[0]						; xw complete
	}

	; 9
	{
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, r2	; Convert index shift into final shift
	addm	v2[3], v3[1]						; yw complete
	}

	; 10
	{
	or		r7, >>#2, r3						; Convert 8 bit LUT value to 32 bit scalar
	mul		v3[3], v6[0]						; Calculate s/w
	}

	; 11
	{
	add		v1[1], v3[2]						; zw complete
	mul		r3, v5[3], >>r1, v5[3]				; Calculate xy
	}

	; 12
	{
	st_v	v3, (v7[1])							; Store converted xyzw
	add		#16, v7[1]							; Increment destination vertex pointer
	mul		v3[3], v6[1]						; Calculate t/w
	dec		rc0									; Decrement vertex counter
	}

	; 13
	{
	bra		c0ne, `CopyLoop						; Branch if more conversion needed
	mv_v	v5, v3								; Copy current xyzw for conversion
	sub		v5[3], v7[0], v7[3]					; Calculate 2-xy
	mul		v3[3], v6[2]						; Calculate I/w
	}

	; 14
	{
	jmp		RASTERIZER_OVERLAY_ORIGIN			; Rasterize polygon
	ld_v	(v7[2]), v4							; Load current uvI
	add		#16, v7[2]							; Increment source vertex pointer
	mul		r3, v7[3], >>r2, v7[3]				; 1/w complete
	}

	; 15
	{
	st_v	v6, (v7[1])							; Store u/w v/w I/w
	add		#16, v7[1]							; Increment destination vertex pointer
	}
	nop
.align.sv
_ClipXYZWUVI_end:


.module Clip4
.export _ClipXYZWUVIFTriangle
.export _ClipXYZWUVIFTriangle_size
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPERecipLUT
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEFogParameter
.import _MPEVertexCacheVertex
.import _MPEVertexCacheVertices
.import _MPEDMACache1
.import _MPEViewport


	; Register allocations
	; v7	=		Old vertex xyzw
	; v7[3] =		Input vertex counter
	; v7[2] =		Initial input vertex pointer
	; v7[1] = 		Initial output vertex pointer
	; v7[0] = 		Summed clip codes for triangle
	; v6	=		Previous vertex C
	; v6    =		Current clip plane equation
	; v5	=		Current vertex C
	; v5[3] = 		Output vertex count
	; v5[2] =		Current input vertex pointer
	; v5[1] =		Current output vertex pointer
	; v5[0] =		Previous output vertex pointer
	; v4	=		Old vertex uvC
	; v3	=		Current vertex xyzw
	; v2	=		Current vertex uvC
	; v1[3] =		Old vertex clip code
	; v1[2] =		Current vertex clip code
	; v1[1]	=		Previous vertex clip plane dot product
	; v1[0] =		Current vertex clip plane dot product

	_ClipXYZWUVIFTriangle_size = _ClipXYZWUVIF_end-_ClipXYZWUVIFTriangle
.align.sv
_ClipXYZWUVIFTriangle:
	ld_s	(_MPEVertexCacheVertex), v7[2]		; Grab current vertex pointer
	ld_s	(_MPEPolygonVertices), v7[3]		; Grab current vertex count
	add		#16, v7[2]							; Shift vertex pointer to texture vertices
	{
	cmp		#00, v7[3]							; Check for negative vertex count
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Set multiplication shift
	}
	{
	bra		ge, `CopyPolygon					; Skip clipping if trivial accept
	ld_s	(v7[2]), v7[0]						; Load first clip code
	add		#32, v7[2]							; Advance vertex pointer
	subm	v6[1], v6[1]						; Zero y component of clip plane normal
	}
	{
	ld_s	(v7[2]), r1							; Load second clip code
	add		#32, v7[2]							; Advance vertex pointer
	subm	v6[2], v6[2]						; Zero z component of clip plane normal
	}
	{
	ld_s	(v7[2]), r2							; Load third clip code
	sub		#80, v7[2]							; Reset vertex pointer
	}
	
	abs		v7[3]								; Insure vertex count is positive
	; Initialize clipping plane equation and clip plane count
`BuildClipPlanes:

	; pixel DMA cache will be used for scratch space, so wait for DMA to complete
`DMAwait:
	ld_s	(mdmactl), r0						; Read DMA control register
	nop
	and		#$f, r0								; Check for DMA activity
	bra		ne, `DMAwait

	{
	st_s	#6, (rc1)							; Initialize clip plane count
	or		r1, v7[0]							; Determine clip plane sum
	}
	{
	mv_s	#-(1<<GLXYZWCLIPSHIFT), v6[3]			; Initialize clip w component
	or		r2, v7[0]							; Clip codes complete
	}
	{
	mv_s	#_MPEDMACache1, v7[1]				; Initialize Destination DMA pointer
	sub		v6[3], #0, v6[0]					; Initialize clip x component					
	}

`ClipLoop:
	; Test if current clip plane violated at all
	{
	mv_s	v7[3], r0							; Copy vertex count into R0
	btst	#0, v7[0]							; Check if current plane active
	subm	v5[3], v5[3]						; Initialize output vertex count
	}

	; Skip clip plane if not violated
	{
	bra		eq, `AdvancePlane					; Jump if clipping plane not violated
	st_s	r0, (rc0)							; Initialize edge counter
	mul		#1, r0, >>#-5, r0					; Calculate vertex list length
	}
	{
	st_s	#1, (svshift)						; Set up small vector shift
	sub		#32, v7[2], v5[0]					; Determine initial offset for previous vertex pointer
	}
	{
	mv_s	v7[2], v5[2]						; Copy source vertex pointer
	copy	v7[1], v5[1]						; Copy destination vertex pointer
	addm	r0, v5[0]							; Previous vertex pointer complete
	}

	st_v	v7, (_MPEPolygonRightEdge)			; Save pointers/vertex count
	; Get last vertex data
	{
	ld_v	(v5[0]), v7							; Load old vertex xyzw
	add		#16, v5[0], r0						; Increment vertex pointer
	}
	ld_v	(r0), v4							; Load old vertex uvI

	; Calculate clip state of last vertex
	{
	sub		v7[3], #0, v1[1]
	mul		v6[0], v7[0], >>acshift, v1[0]		
	}
	{
	lsr		#06, v4[0]							; Shift clip codes out of s
	mul		v6[1], v7[1], >>acshift, v0[2]
	}
	{
	mul		v6[2], v7[2], >>acshift, v0[3]
	add		v1[0], v1[1]
	}
	add		v0[2], v1[1]
	add		v0[3], v1[1]
	{
	bra		lt, `EdgeLoop, nop
	mv_s	#CLIP_INSIDE, v1[3]					; Indicate vertex is inside
	lsl		#06, v4[0]							; Shift s back into position
	}

	mv_s	#CLIP_OUTSIDE, v1[3]
	
`EdgeLoop:

	; Read current vertex
	{
	ld_v	(v5[2]), v3							; Read current vertex xyzw
	add		#16, v5[2]							; Advance vertex pointer
	}
	{
	ld_v	(v5[2]), v2							; Read current vertex uvI
	add		#16, v5[2]							; Advance vertex pointer
	dec		rc0									; Decrement vertex counter
	}
	
	; Get state of current vertex
	{
	sub		v3[3], #0, v1[0]
	mul		v6[0], v3[0], >>acshift, v0[1]
	}
	{
	lsr		#06, v2[0]							; Shift out clip codes
	mul		v6[1], v3[1], >>acshift, v0[2]
	}
	{
	mul		v6[2], v3[2], >>acshift, v0[3]
	add		v0[1], v1[0]
	}
	add		v0[2], v1[0]
	lsl		#06, v2[0]							; Shift s back into position
	add		v0[3], v1[0]
	
	{
	bra		lt, `VertexIn, nop
	cmp		#CLIP_OUTSIDE, v1[3]				; Check state of previous vertex
	mv_s	#CLIP_INSIDE, v1[2]
	}

	mv_s	#CLIP_OUTSIDE, v1[2]
	bra		eq, `CopyVertex, nop				; Last vertex outside, so is this one

	; If out, but previously in, add exit
`AddExit:
	{
	st_v	v3, (_MPEPolygonLeftEdge)			; Save current xyzw
	sub		v1[1], v1[0], r0					; Calculate -dp(old) + dp(curr)		
	subm	v7[0], v3[0]						; Calculate dX
	}
	{
	st_v	v2, (_MPEPolygonLeftEdge+16)		; Save current uvI			
	abs		r0									; Make denominator positive
	subm	v7[1], v3[1]						; Calculate dY
	}
	{
	msb		r0, r1								; Calculate MSB of denominator
	subm	v7[2], v3[2]						; Calculate dZ
	}
	{
	push	v6									; Save v6
	sub		#08, r1, r2
	subm	v7[3], v3[3]						; Calculate dW
	}
	{
	mv_s	#_MPERecipLUT-128, v6[0]
	ls		r2, r0, r3
	}
	{
	mv_s	#$40000000, r3
	add		r3, v6[0]
	subm	v4[0], v2[0]						; Calculate dS
	}
	{
	ld_b	(v6[0]), v5[0]
	subm	v4[1], v2[1]						; Calculate dT
	}
	{
	add		#24+GLXYZWCLIPSHIFT, r2
	subm	v4[2], v2[2]						; Calculate dI
	}
	{
	push	v5									; Save v5
	or		v5[0], >>#2, r3
	}
	{
	mv_s	#$7fffffff, v6[0]					; Copy TWO into v6[0]
	copy	v1[1], r1							; Copy dp(old) into r1
	mul		r3, r0, >>r1, r0
	}
	{
	abs		r1									; Insure dp(old) is positive
	}
	{
	sub		r0, v6[0], r0
	}
	mul		r3, r0, >>r2, r0					; 1/denominator complete
	nop
	mul		r1, r0, >>acshift, r0				; Alpha complete
	st_s	#24, (acshift)						; Alter acshift for interpolation
	mul		r0, v3[0]							; Calculate interpolated dX
	mul		r0, v3[1]							; Calculate interpolated dY
	{
	add		v3[0], v7[0]						; Calculate exit x
	mul		r0, v3[2]							; Calculate interpolated dZ
	}
	{
	add		v3[1], v7[1]						; Calculate exit y
	mul		r0, v3[3]							; Calculate interpolated dW
	}
	{
	add		v3[2], v7[2]						; Calculate exit z
	mul		r0, v2[0]							; Calculate interpolated dS
	}
	{
	add		v3[3], v7[3]						; Calculate exit w
	mul		r0, v2[1]							; Calculate interpolated dT
	}
	{
	add		v2[0], v4[0]						; Calculate exit s
	mul		r0, v2[2]							; Calculate interpolated dI
	}
	add		v2[1], v4[1]						; Calculate exit t
	{
	pop		v5									; Restore v5
	add		v2[2], v4[2]						; Calculate exit I
	}
	ld_v	(_MPEPolygonLeftEdge), v3			; Load current xyzw
	{
	st_v	v7, (v5[1])							; Store exit xyzw
	add		#16, v5[1]
	}
	{
	st_v	v4, (v5[1])							; Store exit uvI
	add		#16, v5[1]							; Increment destination vertex pointer
	}
	{
	bra		`CopyVertex							; We're done
	ld_v	(_MPEPolygonLeftEdge+16), v2		; Load current uvI
	}
	pop		v6									; Restore clip plane
	{
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Wait on pop
	add		#01, v5[3]							; Increment output vertex count
	}
	
`VertexIn:
	bra		ne, `AddVertex

	; If in, but previously outside, add entrance
`AddEntrance:
	{
	sub		v1[0], v1[1], r0					; Calculate alpha denominator
	subm	v3[0], v7[0]						; Calculate dX
	}
	{				
	st_v	v2, (_MPEPolygonLeftEdge+16)		; Save current uvI
	abs		r0									; Insure denominator is positive		
	subm	v3[1], v7[1]						; Calculate dY
	}
	{
	st_v	v4, (_MPEPolygonLeftEdge+32)		; Save previous uvI
	msb		r0, r1								; Calculate MSB of dot product
	subm	v3[2], v7[2]						; Calculate dZ
	}
	{
	push	v6									; Save v6
	sub		#08, r1, r2
	subm	v3[3], v7[3]						; Calculate dW
	}
	{
	mv_s	#_MPERecipLUT-128, v6[0]
	ls		r2, r0, r3
	}
	{
	mv_s	#$40000000, r3
	add		r3, v6[0]
	subm	v2[0], v4[0]						; Calculate dS
	}
	{
	ld_b	(v6[0]), v5[0]
	subm	v2[1], v4[1]						; Calculate dT
	}
	add		#24+GLXYZWCLIPSHIFT, r2
	{
	push	v5									; Save v5
	or		v5[0], >>#2, r3
	}
	{
	mv_s	#$7fffffff, v6[0]					; Copy TWO into v6[0]
	copy	v1[0], r1							; R1 holds numerator
	mul		r3, r0, >>r1, r0
	}
	sub		v2[2], v4[2]						; Calculate dI
	{
	sub		r0, v6[0], r0
	}
	{
	abs		r1									; Insure numerator is positive
	mul		r3, r0, >>r2, r0					; 1/denominator complete
	}
	nop
	mul		r1, r0, >>acshift, r0				; Interpolated alpha complete
	st_s	#24, (acshift)						; Alter acshift for interpolation
	mul		r0, v7[0]							; Calculate interpolated dX
	mul		r0, v7[1]							; Calculate interpolated dY
	{
	add		v3[0], v7[0]						; Calculate entering x
	mul		r0, v7[2]							; Calculate interpolated dZ
	}
	{
	add		v3[1], v7[1]						; Calculate entering y
	mul		r0, v7[3]							; Calculate interpolated dW
	}
	{
	add		v3[2], v7[2]						; Calculate entering z
	mul		r0, v4[0]							; Calculate interpolated dS
	}
	{
	add		v3[3], v7[3]						; Calculate entering w
	mul		r0, v4[1]							; Calculate interpolated dT
	}
	{
	add		v2[0], v4[0]						; Calculate entering s
	mul		r0, v4[2]							; Calculate interpolated dI
	}
	{
	st_s	#GLXYZWCLIPSHIFT, (acshift)			; Restore acshift
	add		v2[1], v4[1]						; Calculate entering t
	}
	{
	pop		v5									; Restore v5
	add		v2[2], v4[2]						; Calculate entering I
	}
	nop
	{
	st_v	v7, (v5[1])							; Store entering xyzw
	add		#16, v5[1]							; Increment destination vertex pointer
	}
	{
	st_v	v4, (v5[1])							; Store entering uvY
	add		#16, v5[1]							; Increment destination vertex pointer
	}
	{
	pop		v6									; Restore clip plane	
	add		#01, v5[3]							; Increment output vertex count
	}
	
	; If in, add vertex
`AddVertex:
	{
	st_v	v3, (v5[1])					; Store current vertex xyzw
	add		#16, v5[1]					; Increment destination vertex pointer
	}
	{
	st_v	v2, (v5[1])					; Store current vertex uvI
	add		#16, v5[1]					; Increment destination vertex pointer
	}
	add		#01, v5[3]					; Increment output vertex count
	
`CopyVertex:
	{
	bra		c0ne, `EdgeLoop
	mv_v	v2, v4						; Copy current vertex uvI to old vertex uvI
	copy	v1[0], v1[1]				; Copy current vertex dot product into old dot product
	}
	{
	mv_v	v3, v7						; Copy current vertex xyzw to old vertex xyzw
	copy	v1[2], v1[3]				; Copy current vertex clip code into old clip code
	}


	; Update destination buffer
`SwapBuffers:
	nop											; Double duty NOP, remove with care
	ld_v		(_MPEPolygonRightEdge), v7		; Restore v7 parameters
	nop
	mv_s	v5[3], v7[3]						; Update vertex count
	{
	mv_s	v7[1], v7[2]						; Exchange vertex buffer pointers
	eor		#DMA_CACHE_EOR, v7[1]
	}

`AdvancePlane:
	neg		v6[3]								; Flip w component sign
	{
	bra		gt, `noadvance						; Branch if on even clip plane
	neg		v6[2]								; Flip z component sign
	dec		rc1									; Decrement clip plane counter				
	}
	{
	neg		v6[1]								; Flip y component sign
	mul		#1, v7[0], >>#1, v7[0]				; Right shift clip code sum
	}
	neg		v6[0]								; Flip x component sign


	; Advance clipping plane components
	{
	mv_s	v6[0], v6[1]						; Copy x component into y component
	copy	v6[1], v6[2]						; Copy y component into z component
	subm	v6[0], v6[0]						; Zero x component
	}

`noadvance:
	bra		c1ne, `ClipLoop
	cmp		#02, v7[3]							; Check for 3 or greater vertex count
	rts		le
	st_s	v7[3], (_MPEPolygonVertices)		; Store positive vertex count
	
	; Perform perspective division and viewpoint transform from source to MPEPolygonVerexList
	; v7[0] = 2.30 2
	; v7[1] = Destination vertex pointer
	; v7[2] = Input vertex counter
	; v0[0] = 2.30 4
`CopyPolygon:
	nop
	{
	sub		v6[0], v6[0]
	ld_s	(_MPEFogParameter), v6[2]			; Load fog data
	}
	{
	sub		v6[1], v6[1]
	ld_s	(_MPEFogParameter+4), v6[3]			; Load fog data
	}
	ld_sv	(_MPEViewport+8), v2				; Load x/y viewport data
	ld_v	(_MPEViewport), v1					; Load z viewport data
	st_s	#GLINVWSCREENSHIFT, (acshift)		; Initialize multiply shift
	mv_s	#_MPEPolygonVertexList-32, v7[1]	; Initialize destination pointer
	st_s	v7[3], (rc0)						; Store vertex counter
	{
	mv_s	#$7fffffff, v7[0]					; v7[0] hold TWO for multiplies
	asr		#(16-GLXYZSCREENSHIFT), v2[1]		; Convert viewport x midpoint to fixed point
	}
	{
	mv_s	#$40000000, v0[0]					; v7[3] holds 8 bit LUT to 32 bit scalar conversion value
	asr		#(16-GLXYZSCREENSHIFT), v2[3]		; Convert viewport y midpoint to fixed point
	}


`CopyLoop:
	; 1
//	bra		c0ne, `noprob
//	nop
//	nop
//	breakpoint
//`noprob:

	{
	ld_v	(v7[2]), v5											; Load vertex xyzw
	add		#16, v7[2]											; Advance source vertex pointer
	 mul	v7[3], v3[2], >>#GLXYZWCLIPSHIFT+1, v3[2]			; Calculate zd
	}

	; 2
	{
	 and	v6[0], v6[1]										; Handle negative overflow of f
	 mul	v2[0], v3[0], >>#30+(16-GLXYZSCREENSHIFT), v3[0]	; Scale xd by viewport width/2
	}


	; 3
	{
	abs		v5[3]												; Insure w is positive
	 mul	v2[2], v3[1], >>#30+(16-GLXYZSCREENSHIFT), v3[1]	; Scale yd by viewport height/2
	}

	; 4
	{
	msb		v5[3], r1											; Calculate log(2) of w
	 mul	v1[0], v3[2], >>#30, v3[2]							; Scale zd by depth/2
	}

	; 5
	{
	sub		#08, r1, r2											; Convert log(2) w into index shift
	 mul	v7[3], v4[2]										; Calculate I/w
	}

	; 6
	ls		r2, v5[3], r3										; Convert w into index offset

	; 7
	{
	mv_s	v0[0], r3											; Move LUT mask into R3
	add		#_MPERecipLUT-128, r3, r6							; R6 now contaisn pointer into Reciprocal LUT
	 addm	v2[1], v3[0]										; xw complete
	}

	; 8
	{
	ld_b	(r6), r7											; Read Reciprocal LUT value
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, r2					; Convert R2 into final reciprocal shift value
	 addm	v2[3], v3[1]										; yw complete
	}

	; 9
	{
	 sat		#GLXYZWCLIPSHIFT+1, v6[1]											; Handle positive overflow of f
	 addm	v1[1], v3[2]										; zw complete
	}

	; 10
	{
	or		r7, >>#2, r3										; Or in mask and Reciprocal LUT value
	 mul		v6[1], v4[2], >>#GLXYZWCLIPSHIFT, v4[2]			; Fogged I/w complete
	}

	; 11
	{
	sub		v6[2], v5[3], v6[0]									; Calculate w - end for fog f value
	mul		r3, v5[3], >>r1, v5[3]								; Calculate xy
	}

	; 12
	{
	asr		#31, v6[0], v6[1]									; Convert w to overflow mask
	 mul	v7[3], v4[0]										; Calculate s/w
	}

	; 13
	{
	 mv_s	v7[3], v3[3]										; Copy 1/w into v3[3]
	sub		v5[3], v7[0], v7[3]									; Calculate 2 - xy
	 mul	v7[3], v4[1]										; Calculate t/w
	}

	; 14
	{
	 st_v	v3, (v7[1])											; Store vertex xyzw
	 add	#16, v7[1]											; Increment destination vertex pointer
	mul		r3, v7[3], >>r2, v7[3]								; 1/w complete
	}

	; 15
	{
	bra		c0ne, `CopyLoop										; Branch if more vertices to process
	mv_v	v5, v3												; Copy vertex xyzw into v3
	mul		v6[3], v6[0], >>#30, v6[0]							; Calculate f = (z - end) / (start - end)
	}

	; 16
	{
	 jmp	RASTERIZER_OVERLAY_ORIGIN							; Jump to polygon rasterizer
	 st_v	v4, (v7[1])											; Store vertex s/w t/w fI/w
	 add	#16, v7[1]											; Increment destination vertex pointer
	mul		v7[3], v3[0], >>#GLXYZWCLIPSHIFT+1, v3[0]			; Calculate xd
	dec		rc0													; Decrement vertex counter
	}

	; 17
	{
	ld_v	(v7[2]), v4											; Load vertex stI
	add		#16, v7[2]											; Increment source vertex pointer
	mul		v7[3], v3[1], >>#GLXYZWCLIPSHIFT+1, v3[1]			; Calculate yd
	}
//	breakpoint
	nop
.align.sv
_ClipXYZWUVIF_end:
