/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.

*/

; MGL polygon rasterization routines

#include "mpedefs.h"

.nocache
.text

.align.sv
.module RasStub
.export _RasterStub
.export _RasterStub_size
_RasterStub_size = _RasterStub_end - _RasterStub
_RasterStub:
	rts		nop
.align.sv
_RasterStub_end:

// TODO: This rasterizer has a bug which caused nasty color banding. RasCB and RasCB2 have the same problem.
.align.sv
.module RasC
.export _RasterC
.export _RasterC_size
.import _FloorDivMod
.import _MPEMDMACmdBuf
.import _MPEPolygonGradient
.import _MPEPolygonColorGradient
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEPolygonVertex
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPEPolygonLeftEdgeExtra
.import _MPEPolygonRightEdgeExtra
.import _MPEPolygonEdgeExtra
.import _MPEPolygonX
.import _MPEPolygonY
.import _MPEPolygonDMASize
.import _MPEPolygonDMASourcePointer
.import _MPEPolygonPixelPointer
.import _MPESDRAMPointer
.import _MPEDMAFlags
.import _MPEPolygonScanlineRemainder
.import _MPEPolygonScanlineRecipLUT
.import _MPEPolygonScanlineValues
.import _MPEPolygonScanlineColorValues
.import _MPEPolygonNextLeftVertexPointer
.import _MPEPolygonNextRightVertexPointer
.import _MPERecipLUT

	; Register equates
	X0 = v7				// Vertex 0 vector
	x0 = r28
	y0 = r29
	z0 = r30
	w0 = r31
	C0 = v2				// Vertex 0 color
	CY0 = v2[0]
	CC0 = v2[1]
	CB0 = v2[2]
	CA0 = v2[3]
	X1 = v6				// Vertex 1 vector
	x1 = r24
	y1 = r25
	z1 = r26
	w1 = r27
	C1 = v3				// Vertex 1 color
	CY1 = v3[0]
	CC1 = v3[1]
	CB1 = v3[2]
	CA1 = v3[3]
	X2 = v5				// Vertex 2 vector
	x2 = r20
	y2 = r21
	z2 = r22
	w2 = r23
	C2 = v4				// Vertex 2 color
	CY2 = v4[0]
	CC2 = v4[1]
	CB2 = v4[2]
	CA2 = v4[3]

_RasterC_size = _RasterC_end - _RasterC
_RasterC:
	mv_s	#_MPEPolygonVertexList, r0				; Initialize vertex list
	st_s	r0, (_MPEPolygonVertex)					; Kludge a 3 vertex polygon

	; Calculate Gradients from any 3 vertices (optimized for trivial accept)
	; Affects all registers

`PolygonLoop:
	ld_s	(_MPEPolygonVertex), r0
	nop

	; Stage 1, load data for triangle and calculate dV0 AND dV1
	{
	ld_v 	(r0), X2						; Load vertex 0 xyz1/w
	add		#24, r0							; Increment vertex pointer					
	}
	{
	ld_sv	(r0), C2						; Load vertex 0 C
	add		#8, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X0						; Load vertex 2 xyz1/w
	add		#24, r0							; Increment vertex pointer
	}
	{
	ld_sv 	(r0), C0						; Load vertex 2 C
	add		#8, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X1						; Load vertex 1 xyz1/w
	add		#24, r0							; Increment vertex pointer
	subm	x2, x0							; Calculate x0 - x2		
	}
	{
	ld_sv 	(r0), C1						; Load vertex 1 C
	sub		z2, z0							; Calculate z0 - z2
	subm	y2, y0							; Calculate y0 - y2
	}

	; Calculate dX, dY, dCY, dCC, dCB, and dZ
	{
	st_s	#GLXYZSCREENSHIFT, (acshift)		; Set acshift for dX and dY products
	sub		x2, x1								; Calculate x1 - x2
	subm	y2, y1								; Calculate y1 - y2
	}
	{
	sub_sv	C2, C0								; Calculate C0 - C2	
	mul		x1, y0, >>acshift, x2				; X2 now contains (x1 - x2) * (y0 - y2)
	}
	{
	sub_sv	C2, C1								; Calculate C1 - C2
	mul		x0, y1, >>acshift, y2				; Y2 now contains (x0 - x2) * (y1 - y2)
	}
	msb		z0, r6								; Calculate MSB of (z0 - z2)
	sub		y2, x2, r0							; R0 now contains dX or signed area
	{
	bra		le, `EndPolygon1
	abs		r0									; Insure denominator is positive
	subm	z2, z1								; Calculate z1 - z2
	}
	msb		z1, r7								; Calculate MSB of (z1 - z2)
	msb		r0, r1								; Calculate dX MSB
	sub		#08, r1, r2							; R2 holds index shift for 1/dX	
	{
	mv_s	#_MPERecipLUT-128, r4				; R4 holds reciprocal LUT pointer
	ls		r2, r0, r3							; Convert dX into index offset
	}
	{
	mv_s	#$40000000, r3						; R3 holds unsigned LUT value conversion mask
	cmp		r6, r7								; Compare dZ MSBs
	addm	r3, r4								; R4 holds pointer to reciprocal LUT value
	}
	{
	bra		ge, `z1msbgreater					; Branch if (z1 - z2) MSB is greater
	ld_b	(r4), r5							; Load 8 bit reciprocal LUT value
	}
	add		#(36-GLXYZSCREENSHIFT), r2			; Adjust 1/dX answer shift
	{
	mv_s	#$7fffffff, r4						; R4 holds 2.30 TWO	
	or		r5, >>#2, r3						; Convert 8 bit LUT value to 32 bit scalar
	}


	mv_s	r6, r7								; (z0 - z2) MSB greater
`z1msbgreater:
	{
	mv_s	x0, r1								; Copy (x0 - x2) into r1
	cmp		#20, r7								; Check MSB
	mul		r3, r0, >>r1, r0					; Calculate xy
	}	
	bra		le, `zmsblessthan20					; Branch if z MSB < 20
	{
	mv_s	#GLXYZSCREENSHIFT, r5				; R5 holds default preshift value for multiplication
	copy	y1, r4								; Copy (y1 - y2) into r4
	subm	r0, r4, r0							; Calculate 2 - xy
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r6				; R6 holds default postshift value for multiplication
	mul		r3, r0, >>r2, r0					; 1/dX complete
	}

	add		#GLXYZSCREENSHIFT-20, r7, r5		; R5 holds adjusted dz preshift
	sub		r7, #GLINVDXSCREENSHIFT+20, r6		; R6 holds adjusted dz postshift
`zmsblessthan20:
	{
	mv_s	y0, r2								; Copy (y0 - y2) into r2
	mul		z0, r4, >>r5, r4					; R4 holds (z0 - z2) * (y1 - y2)
	}
	{
	mv_s	x1, r3								; Copy (x1 - x2) into r3
	mul		z1, r2, >>r5, r2					; R2 holds (z1 - z2) * (y0 - y2)
	}
	{
	mul		z0, r3, >>r5, r3					; R3 holds (z0 - z2) * (x1 - x2)
	}
	{
	sub		r4, r2								; R2 holds (z0 - z2) * (y1 - y2) - (z1 - z2) * (y0 - y2)
	mul		z1, r1, >>r5, r1					; R1 holds (z1 - z2) * (x0 - x2)
	}
	mul		r0, r2, >>r6, r2					; dz/dX complete
	mul		r0, y0, >>#GLINVDXSCREENSHIFT-6, y0	; y0 holds (y0 - y2) / dX 
	{
	st_s	r2, (_MPEPolygonGradient)			; Store dz/dX
	sub		r1, r3								; R3 holds (z1 - z2) * (x0 - x2) - (z0 - z2) * (x1 - x2)

	mul		r0, y1, >>#GLINVDXSCREENSHIFT-6, y1	; y1 holds (y1 - y2) / dX
	}
	mul		r0, r3, >>r6, r3					; dz/dY complete
	mul		r0, x0, >>#GLINVDXSCREENSHIFT-6, x0	; x0 holds -(x0 - x2) / dY
	{
	st_s	r3, (_MPEPolygonGradient+16)		; Store dz/dY
	mul		r0, x1, >>#GLINVDXSCREENSHIFT-6, x1	; x1 holds -(x1 - x2) / dY
	}
	st_s	#16, (acshift)
	mul		y1, CY0, >>acshift, x2
	mul		y1, CC0, >>acshift, y2
	mul		y1, CB0, >>acshift, z2
	mul		y0, CY1, >>acshift, v1[0]
	mul		y0, CC1, >>acshift, v1[1]
	mul		y0, CB1, >>acshift, v1[2]
	mul		x1, CY0, >>acshift, CY0
	mul		x1, CC0, >>acshift, CC0
	mul		x1, CB0, >>acshift, CB0
	mul		x0, CY1, >>acshift, CY1
	mul		x0, CC1, >>acshift, CC1
	mul		x0, CB1, >>acshift, CB1	
	sub		x2, v1[0]
	sub		y2, v1[1]
	sub		z2, v1[2]
	sub		CY1, CY0
	sub		CC1, CC0
	sub		CB1, CB0
	st_v	v1, (_MPEPolygonColorGradient)		; Save dc/dX
	st_v	C0, (_MPEPolygonColorGradient+16)		; Save dc/dY

	; Rasterization equates
	y = r30						; Current y
	leftVertex = r31			; Current left vertex
	rightVertex = r29			; Current right vertex

	; Find top vertex
	mv_s	#$7fffffff, y						; Set yTop to maximum
	ld_s	(_MPEPolygonVertex), r31			; Initial vertex pointer
	lsl		#01, y, r27							; Set R27 to yMin 
	{
	mv_s	#3, r28								; Load vertex count
	add		#04, r31							; Increment vertex pointer to y
	}
	mv_s	r31, r29							; Copy vertex pointer

`topsearch:
	ld_s	(r31), r0							; Load vertex y
	nop
	cmp		y, r0								; Check if new minimum y
	{
	bra		gt, `nonewminvertex, nop			; Jump if vertex is definitely not at top
	cmp		y, r27								; Check for new maximum y
	}

	; New minimum  y/vertex
	mv_s	r31, r29							; Copy current vertex into top vertex pointer
	mv_s	r0, y								; Copy current vertex y into minimum y pointer
`nonewminvertex:
	{
	bra		ge, `nonewmaxvertex, nop			; Jump if no new max y
	sub		#01, r28							; Decrement vertex count
	}

	mv_s	y, r27								; Set R27 to new yMax
`nonewmaxvertex:
	bra		ne, `topsearch						; Jump if more vertices to check
	add		#32, r31
	nop

	{
	mv_s	#32, r1								; Set increment input to left vertex
	sub		#04, r29							; Make vertex pointer point to vertex again
	}
	{
	mv_s	r29, r31							; Set current vertices to same vertex
	copy	r29, r0								; Set left vertex pointer for subroutine
	}

	; Prepare initial left edge
	push	v7, rz								; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge, nop
	ld_s	(pcexec), r2
	}

	; Prepare initial right edge
	{
	bra		`PrepareEdge
	mv_s	#-32, r1
	copy	r31, r0
	}
	ld_s	(pcexec), r2
	nop
	pop		v7, rz						; Restore edge pointers and subroutine return

	; Walk left and right edges and fire off scanlines
`WalkLoop:
	; Walk a scanline
	ld_v	(_MPEPolygonLeftEdge), v7			; Load left edge parameters
	ld_v	(_MPEPolygonLeftEdge+16), v5		; Load final batch of left edge stuff
	ld_v	(_MPEPolygonRightEdge), v4			; Load right edge parameters
	{
	st_s	v7[3], (_MPEPolygonX)				; Store initial polygon x
	asl		#16, v7[3], v7[2]					; Convert x to bilinear coordinate
	}
	{
	ld_v	(_MPEPolygonLeftEdge+48), v6		; Load additional left edge stuff
	abs		v5[0]
	subm	v3[1], v3[1]						; Set scanline remainder to 0
	mvr		v7[2], rx							; Set bilinear x
	}
	{
	ld_v	(_MPEPolygonColorGradient), v7		; Load dc/dX
	sub		v7[3], v4[3], v3[0]					; Calculate scanline width
	addm	v3[1], v5[0], v4[3]					; Copy z/w into v4[3]
	}
	
`CalculateDMASize:
	{
	ld_s	(_MPEPolygonGradient), v1[3]			; Load dz/dX
	bra		le, `StepLeftEdge						; Jump if zero width scanline
	cmp		#64, v3[0]								; Check for maximum DMA length
	}	
	{
	ld_v	(_MPEPolygonColorGradient), v2			; Read dc/dX 
	bra		le, `OneBigStep
	}
	ld_s	(_MPEPolygonDMASourcePointer), v0[3]	; Load current DMA destination pointer
	nop

	{
	mv_s	#64, v3[0]	
	sub		#64, v3[0], v3[1]					; Calculate scanline remainder
	}
`OneBigStep:
	st_s	v3[0], (_MPEPolygonDMASize)				; Store DMA size
	st_s	v3[0], (rc1)							; Store scanline size in DMA countdown
	st_s	v3[1], (_MPEPolygonScanlineRemainder)	; Store scanline remainder



	; Generic c and z rasterization loop

	; v0[3] = DMA destination pointer
	; v1[3] = dz/dx
	; v4[3] = initial/final z
	; v6[0] = Y
	; v6[1] = C
	; v6[2] = B
	; v6[3] = z
	; v7[0] = dY/dx
	; v7[1] = dC/dx
	; v7[2] = dB/dx
	; rc1 = DMA/scanline countdown


`RasterPreLoop:
	{
	mv_s	v4[3], v6[3]							; put z in v6[3]
	dec		rc1										; predecrement pixel/DMA countdown
	}

`RasterLoop:
	; 1
	{
	bra		c1ne, `RasterLoop
	st_pz	v6, (v0[3])								; Store output pixel
	add		#04, v0[3]								; Advance DMA destination pointer
	addm	v7[0], v6[0]							; Advance Y
	}

	; 2
	{
	add		v7[1], v6[1]							; Advance C
	addm	v7[2], v6[2]							; Advance B
	}
	
	; 3
	{
	add		v1[3], v6[3]							; Advance z
	dec		rc1
	}

`RasterPostLoop:
	mv_s v6[3], v4[3]								; put z back in v4[3]

	; Wait for DMA and then let things rip
`DMAwait:
	ld_s	(mdmactl), r0							; Read DMA control register
	ld_s	(_MPEPolygonScanlineRemainder), r7		; Load scanline remainder
	and		#$f, r0									; Check for DMA activity
	bra		ne, `DMAwait


`DoDMA:
	ld_s	(_MPEPolygonDMASourcePointer), r4
	ld_s	(_MPEPolygonX), r2
	ld_s	(_MPEPolygonDMASize), r5
	ld_s	(_MPEPolygonY), r3
	{
	ld_s	(_MPEDMAFlags), r0
	lsl		#16, r5
	addm	r2, r5, r6					; Increment polygon X
	}
	{
	ld_s	(_MPESDRAMPointer), r1
	bset	#16, r3						; YPOS input complete
	}
	{
	st_s	r4, (_MPEMDMACmdBuf+16)
	or		r5, r2						; XPOS input complete
	}
	{
	st_v	v0, (_MPEMDMACmdBuf)
	eor		#DMA_CACHE_EOR, r4			; Flip DMA buffers
	}
	st_s	#_MPEMDMACmdBuf, (mdmacptr)

;---------------------------------------------------------------------

`CheckScanlineRemainder:
	{
	cmp		#00, r7										; Check if any pixels are left on scanline
	st_s	r6, (_MPEPolygonX)							; Store updated polygon x
	}
	{
	st_s	r4, (_MPEPolygonDMASourcePointer)			; Store updated polygon DMA pointer
	bra		gt, `CalculateDMASize						; Branch if not at end of scanline
	}
	sub		v3[1], v3[1]								; Zero scanline remainder
	copy	r7, v3[0]									; Set v3[0] to remaining scanline width

	; Increment left and right edges
`StepLeftEdge:
	ld_v	(_MPEPolygonLeftEdge), v7			; Load edge xStep numerator errorTerm x
	ld_v	(_MPEPolygonLeftEdge+16), v6		; Load edge	z zstep 1/w 1/wstep
	ld_v	(_MPEPolygonLeftEdge+48), v5		; Load edge color
	{
	ld_v	(_MPEPolygonLeftEdge+64), v4		; Load cStep
	add		v7[1], v7[2]						; Increment left errorTerm
	addm	v7[0], v7[3]						; Increment left x
	}
	{
	ld_s	(_MPEPolygonY), r0					; Load current polygon y
	addm	v6[1], v6[0]						; Increment z
	}
	{
	bra		le, `NoLeftOverflow					; Branch if errorTerm < 0
	add		v4[2], v5[2]						; Increment cB
	}
	{
	ld_v	(_MPEPolygonEdgeExtra), v4			; Load height/denominators for both edges
	add		v4[0], v5[0]						; Increment cY
	addm	v4[1], v5[1]						; Increment cC
	}
	ld_s	(_MPEPolygonGradient), r1			; Load dz/dX


`LeftOverFlow:
	{
	ld_v	(_MPEPolygonColorGradient), v2		; Load dc/dX
	add		#01, v7[3]							; Increment x
	subm	v4[1], v7[2]						; Reset error term
	}
	add		r1, v6[0]							; Increment z
	{
	add		v2[0], v5[0]						; Increment cY
	addm	v2[1], v5[1]						; Increment cC
	}
	add		v2[2], v5[2]						; Increment cB

`NoLeftOverflow:
	{
	st_v	v7, (_MPEPolygonLeftEdge)		; Store updated left edge info
	sub		#01, v4[0]						; Decrement height
	}
	{
	st_v	v6, (_MPEPolygonLeftEdge+16)	; Store updated left edge info
	}
	{
	bra		gt, `StepRightEdge
	st_v	v5, (_MPEPolygonLeftEdge+48)	; Store updated left edge info
	add		#01, r0							; Increment polygon y
	}
	{
	st_v	v4, (_MPEPolygonEdgeExtra)		; Store updated height/denominator
	asl		#16, r0, r1						; Convert y to 16.16 fp
	}
	{
	st_s	r0, (_MPEPolygonY)				; Store updated polygon y
	mvr		r1, ry
	}
	
	; Prepare next left edge
	push	v7, rz										; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge								; Jump to edge calculation routine
	mv_s	#32, r1										; Set vertex increment to positive
	}
	ld_s	(pcexec), r2								; Load return address
	ld_s	(_MPEPolygonNextLeftVertexPointer), r0		; Load next vertex pointer
	pop		v7, rz
	
`StepRightEdge:
	ld_v	(_MPEPolygonRightEdge), v7			; Load right edge data
	ld_v	(_MPEPolygonEdgeExtra), v6			; Load height/denominator
	{
	add		v7[1], v7[2]						; Increment right errorTerm
	addm	v7[0], v7[3]						; Increment right x
	}
	bra		le, `NoRightOverflow, nop			; Branch if errorTerm < 0
	{
	add		#01, v7[3]							; Increment x
	subm	v6[3], v7[2]						; Reset errorTerm
	}

`NoRightOverflow:
	{
	st_v	v7, (_MPEPolygonRightEdge)				; Store updated edge parameters
	sub		#01, v6[2]								; Decrement edge height
	}
	{
	bra		ne, `WalkLoop, nop						; Jump to main loop if more left
	st_v	v6, (_MPEPolygonEdgeExtra)				; Updated edge data complete
	add		#01, r0									; Increment polygon y
	}

	; Prepare next right edge
	push	v7, rz									; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge							; Jump to edge calculation routine
	mv_s	#-32, r1								; Set vertex increment to positive
	}
	ld_s	(pcexec), r2							; Load return address
	ld_s	(_MPEPolygonNextRightVertexPointer), r0	; Load next vertex pointer
	{
	bra		`WalkLoop, nop
	pop		v7, rz
	}

	; Subroutines

	; Prepares an edge, pass vertex pointer in R0
	; 32 for a right edge or -32 for a left edge in R1
	; and return address in R2
	; Next vertex pointer is returned in R0
	; Affects R0-R30!!!! (R31 must be unaffected SML 9/30/98)
`PrepareEdge:
	{
	st_s	#9, rc0								; Store maximum vertex count
	copy	r1, r7								; Wait on load and save increment
	}
	st_s	r2, (rz)							; Store return address
`PrepEdge:
	{
	bra		c0eq, `EndPolygon
	mv_s	#3, r27								; Read number of vertices
	}
	ld_s	(_MPEPolygonVertex), r28			; R28 points to MPE Polygon Vertex List
	{
	ld_v	(r0), v2							; Read x1, y1, z1, 1/w1
	add		#24, r0								; Increment vertex pointer to C 
	addm	r7, r0, r26 						; R26 now points to second vertex
	}
	{
	ld_sv	(r0), v3							; Read C
	cmp		r28, r26							; Check for vertex underflow
	mul		#16, r27, >>#-1, r27				; Calculate 32 * vertices 
	}
	{
	bra		ge, `nounderflow					; Jump if no underflow
	copy	r9, r25								; Copy fixed point y1 into r25
	}
	{
	mv_s	r8, r24								; Copy fixed point x1 into R24
	add		r27, r28, r29						; R29 points past end of active vertices
	dec		rc0									; Decrement vertex search counter
	}
	mv_s	#((1<<GLXYZSCREENSHIFT)-1), r30		; R30 contains ceiling rounder

	add		r27, r26							; Wrap vertex around to end of list
`nounderflow:
	cmp		r29, r26							; Check for vertex pointer overflow
	bra		ne, `nooverflow, nop				; Jump if no overflow

	sub		r27, r26							; Wrap vertex around to beginning of list

`nooverflow:
	{
	ld_v	(r26), v4							; Read x2, y2, z2, 1/w2
	add		r30, r8								; Round up x1
	addm	r30, r9								; Round up y1
	}
	{
	ld_v	(_MPEPolygonGradient), v5			; Read gradient x stuff
	asr		#GLXYZSCREENSHIFT, r9				; Integer y1 complete
	}
	{
	add		r30, r16							; Round up x2
	addm	r30, r17							; Round up y2
	}
	{
	asr		#GLXYZSCREENSHIFT, r17				; Integer y2 complete
	mul		#1, r8, >>#GLXYZSCREENSHIFT, r8		; Integer x1 complete
	}
	{
	sub		r9, r17, r30						; R30 contains height of edge
	mul		#1, r16, >>#GLXYZSCREENSHIFT, r16	; Integer x2 complete
	}

	bra		mi, `EndPolygon, nop				; Jump if polygon end reached
	bra		ne, `realedge, nop					; Jump if not a flat edge

	; Flat edge, jump to next vertex and try again
	{
	bra		`PrepEdge, nop
	mv_s	r26, r0					; Set current vertex to next vertex	
	}
	
	; Genuine edge, calculate Bresenham parameters 
`realedge:
	{
	push	v2, rz						; Save subroutine return address
	jsr		_FloorDivMod
	}
	{
	mv_s	r30, r1								; R1 = denominator = dY
	sub		r8, >>#(-GLXYZSCREENSHIFT), r24		; Calculate x prestep
	}
	{
	st_s	#00, (acshift)						; Set acshift to 0
	sub		r9, >>#(-GLXYZSCREENSHIFT), r25		; Calculate y prestep
	subm	r8, r16, r0							; R0 = numerator = dX
	}
	
	{
	mv_s	r30, r4								; Move edge height into R4
	copy	r8, r3								; Move initial x into R3
	addm	r1, r1								; Set numerator to 2X remainder
	}
	; Check for left/right edge
	{
	pop		v2, rz								; Restore subroutine return address
	cmp		#00, r7								; Check for left or right edge
	}

	{
	ld_s	(_MPEPolygonGradient), v5[0]		; Load x components of gradient
	add		r4, r4, r5							; Set denominator to 2X edge height
	bra		ge, `leftedge
	}
	{
	ld_v	(_MPEPolygonColorGradient), v4		; Load dc/dX
	neg		r24									; Make x prestep positive
	}
	neg		r25									; Make y prestep positive

`rightedge:
	st_s	r26, (_MPEPolygonNextRightVertexPointer)	; Store next right vertex
	{
	st_v	v0, (_MPEPolygonRightEdge)			; Store right edge Bresenham parameters
	rts
	}
	st_s	r4, (_MPEPolygonRightEdgeExtra)		; Store height
	st_s	r5, (_MPEPolygonRightEdgeExtra+4)	; Store denominator

	// Calculate all Bresenham parameters and prestep them to integer coordinates
	// If you don't do this, you get HORRIBLE texture swim
`leftedge:
	{
	st_s	v1[0], (_MPEPolygonLeftEdgeExtra)			; Store height
	copy	v2[2], v1[0]								; Copy z into v1[0]
	}
	{
	st_s	v1[1], (_MPEPolygonLeftEdgeExtra+4)			; Store denominator
	mul		r0, v5[0], >>acshift, v1[1]					; Calculate first component of zStep
	}
	{
	ld_s	(_MPEPolygonGradient+16), v5[1]				; Load dz/dY
	}
	st_s	#00, (acshift)
	{
	st_s	v2[1], (_MPEPolygonY)						; Store current polygon y coordinate
	mul		r0, v4[0], >>acshift, v2[0]					; Calculate first component of cYStep
	}
	{
	asl		#16, v2[1], v2[2]
	mul		r0, v4[1], >>acshift, v2[1]					; Calculate first component of cCStep
	}
	{
	mul		r0, v4[2], >>acshift, v2[2]					; Calculate first component of cBStep
	mvr		v2[2], ry
	}
	{
	st_v	v0, (_MPEPolygonLeftEdge)					; Store left edge Bresenham parameters	
	add		v5[1], v1[1]								; zStep complete
	mul		r24, v5[0], >>#GLXYZSCREENSHIFT, v5[0]		; Calculate dz/dX * xPrestep
	}
	{
	ld_v	(_MPEPolygonColorGradient+16), v0			; Load dc/dY
	lsl		#(30-GLXYZSCREENSHIFT), r24					; Convert xPrestep to 2.30 fp number									
	}
	{
	st_s	r26, (_MPEPolygonNextLeftVertexPointer)		; Store next left vertex
	add		v5[0], v1[0]								; z1 = z + dz/dx * xPrestep
	mul		r25, v5[1], >>#GLXYZSCREENSHIFT, v5[1]		; Calculate dz/dY * yPrestep
	}
	lsl		#(30-GLXYZSCREENSHIFT), r25					; Convert yPrestep to 2.30 fp number
	{
	add		v5[1], v1[0]								; z1 complete
	mul_sv	r24, v4, >>#30, v4							; Calculate dc/dx * xPrestep
	}
	{
	st_v	v1, (_MPEPolygonLeftEdge+16)				; Store z    zStep
	add		v0[0], v2[0]								; cYStep complete
	}
	add		v0[1], v2[1]								; cCStep complete
	{
	add		v0[2], v2[2]								; cBStep complete
	mul_sv	r25, v0, >>#30, v0							; Calculate dc/dy * yPrestep
	}
	{
	rts
	st_v	v2, (_MPEPolygonLeftEdge+64)				; Store cStep
//	add_sv	v4, v3										; c1 = c + dc/dx * xPrestep
	}
//	add_sv	v0, v3										; c1 = c + dc/dx * xPrestep + dx/dy * yPrestep
	nop
	st_v	v3, (_MPEPolygonLeftEdge+48)				; Store c
	
;---------------------------------------------------------------------------------------



	; Move onto next polygon or clean up if done
`EndPolygon:
	pop		v7, rz							; Restore subroutine return
`EndPolygon1:
	ld_s	(_MPEPolygonVertices), r0		; Load current vertex count
	ld_s	(_MPEPolygonVertex), r1			; Load current vertex pointer
	sub		#01, r0							; Decrement vertex count
	{
	ld_v	(r1), v1						; Load 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex counter
	}
	{
	ld_v	(r1), v2						; Load 1st vertex C
	add		#16, r1							; Increment 1st vertex counter
	}
	st_s	r1, (_MPEPolygonVertex)			; Store new 1st vertex pointer
	cmp		#3, r0							; Check for last triangle
	{
	bra		ge, `PolygonLoop				; Jump if more triangles to rasterize
	st_s	r0, (_MPEPolygonVertices)		; Store new vertex count
	}
	{
	st_v	v1, (r1)						; Store 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex pointer
	}
	st_v	v2, (r1)
	
	; Clean up and exit
`RasterDone:
	rts		nop

.align.sv
_RasterC_end:


// see pipeline.c for circumstances under which it is valid to use this rasterizer
// TODO: This rasterizer has a bug which caused nasty color banding. RasC and RasCB2 have the same problem.
.align.sv
.module RasCB
.export _RasterCB
.export _RasterCB_size
.import _FloorDivMod
.import _MPEMDMACmdBuf
.import _MPEPolygonGradient
.import _MPEPolygonColorGradient
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEPolygonVertex
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPEPolygonLeftEdgeExtra
.import _MPEPolygonRightEdgeExtra
.import _MPEPolygonEdgeExtra
.import _MPEPolygonX
.import _MPEPolygonY
.import _MPEPolygonDMASize
.import _MPEPolygonDMASourcePointer
.import _MPEPolygonPixelPointer
.import _MPESDRAMPointer
.import _MPEDMAFlags
.import _MPEPolygonScanlineRemainder
.import _MPEPolygonScanlineRecipLUT
.import _MPEPolygonScanlineValues
.import _MPEPolygonScanlineColorValues
.import _MPEPolygonNextLeftVertexPointer
.import _MPEPolygonNextRightVertexPointer
.import _MPERecipLUT

	; Register equates
	X0 = v7				// Vertex 0 vector
	x0 = r28
	y0 = r29
	z0 = r30
	w0 = r31
	C0 = v2				// Vertex 0 color
	CY0 = v2[0]
	CC0 = v2[1]
	CB0 = v2[2]
	CA0 = v2[3]
	X1 = v6				// Vertex 1 vector
	x1 = r24
	y1 = r25
	z1 = r26
	w1 = r27
	C1 = v3				// Vertex 1 color
	CY1 = v3[0]
	CC1 = v3[1]
	CB1 = v3[2]
	CA1 = v3[3]
	X2 = v5				// Vertex 2 vector
	x2 = r20
	y2 = r21
	z2 = r22
	w2 = r23
	C2 = v4				// Vertex 2 color
	CY2 = v4[0]
	CC2 = v4[1]
	CB2 = v4[2]
	CA2 = v4[3]

_RasterCB_size = _RasterCB_end - _RasterCB
_RasterCB:
	mv_s	#_MPEPolygonVertexList, r0				; Initialize vertex list
	st_s	r0, (_MPEPolygonVertex)					; Kludge a 3 vertex polygon

	; Calculate Gradients from any 3 vertices (optimized for trivial accept)
	; Affects all registers

`PolygonLoop:
	ld_s	(_MPEPolygonVertex), r0
	nop

	; Stage 1, load data for triangle and calculate dV0 AND dV1
	{
	ld_v 	(r0), X2						; Load vertex 0 xyz1/w
	add		#24, r0							; Increment vertex pointer					
	}
	{
	ld_sv	(r0), C2						; Load vertex 0 C
	add		#8, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X0						; Load vertex 2 xyz1/w
	add		#24, r0							; Increment vertex pointer
	}
	{
	ld_sv 	(r0), C0						; Load vertex 2 C
	add		#8, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X1						; Load vertex 1 xyz1/w
	add		#24, r0							; Increment vertex pointer
	subm	x2, x0							; Calculate x0 - x2		
	}
	{
	ld_sv 	(r0), C1						; Load vertex 1 C
	sub		z2, z0							; Calculate z0 - z2
	subm	y2, y0							; Calculate y0 - y2
	}

	; Calculate dX, dY, dCY, dCC, dCB, and dZ
	{
	st_s	#GLXYZSCREENSHIFT, (acshift)		; Set acshift for dX and dY products
	sub		x2, x1								; Calculate x1 - x2
	subm	y2, y1								; Calculate y1 - y2
	}
	{
	sub_sv	C2, C0								; Calculate C0 - C2	
	mul		x1, y0, >>acshift, x2				; X2 now contains (x1 - x2) * (y0 - y2)
	}
	{
	sub_sv	C2, C1								; Calculate C1 - C2
	mul		x0, y1, >>acshift, y2				; Y2 now contains (x0 - x2) * (y1 - y2)
	}
	msb		z0, r6								; Calculate MSB of (z0 - z2)
	sub		y2, x2, r0							; R0 now contains dX or signed area
	{
	bra		le, `EndPolygon1
	abs		r0									; Insure denominator is positive
	subm	z2, z1								; Calculate z1 - z2
	}
	msb		z1, r7								; Calculate MSB of (z1 - z2)
	msb		r0, r1								; Calculate dX MSB
	sub		#08, r1, r2							; R2 holds index shift for 1/dX	
	{
	mv_s	#_MPERecipLUT-128, r4				; R4 holds reciprocal LUT pointer
	ls		r2, r0, r3							; Convert dX into index offset
	}
	{
	mv_s	#$40000000, r3						; R3 holds unsigned LUT value conversion mask
	cmp		r6, r7								; Compare dZ MSBs
	addm	r3, r4								; R4 holds pointer to reciprocal LUT value
	}
	{
	bra		ge, `z1msbgreater					; Branch if (z1 - z2) MSB is greater
	ld_b	(r4), r5							; Load 8 bit reciprocal LUT value
	}
	add		#(36-GLXYZSCREENSHIFT), r2			; Adjust 1/dX answer shift
	{
	mv_s	#$7fffffff, r4						; R4 holds 2.30 TWO	
	or		r5, >>#2, r3						; Convert 8 bit LUT value to 32 bit scalar
	}


	mv_s	r6, r7								; (z0 - z2) MSB greater
`z1msbgreater:
	{
	mv_s	x0, r1								; Copy (x0 - x2) into r1
	cmp		#20, r7								; Check MSB
	mul		r3, r0, >>r1, r0					; Calculate xy
	}	
	bra		le, `zmsblessthan20					; Branch if z MSB < 20
	{
	mv_s	#GLXYZSCREENSHIFT, r5				; R5 holds default preshift value for multiplication
	copy	y1, r4								; Copy (y1 - y2) into r4
	subm	r0, r4, r0							; Calculate 2 - xy
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r6				; R6 holds default postshift value for multiplication
	mul		r3, r0, >>r2, r0					; 1/dX complete
	}

	add		#GLXYZSCREENSHIFT-20, r7, r5		; R5 holds adjusted dz preshift
	sub		r7, #GLINVDXSCREENSHIFT+20, r6		; R6 holds adjusted dz postshift
`zmsblessthan20:
	{
	mv_s	y0, r2								; Copy (y0 - y2) into r2
	mul		z0, r4, >>r5, r4					; R4 holds (z0 - z2) * (y1 - y2)
	}
	{
	mv_s	x1, r3								; Copy (x1 - x2) into r3
	mul		z1, r2, >>r5, r2					; R2 holds (z1 - z2) * (y0 - y2)
	}
	{
	mul		z0, r3, >>r5, r3					; R3 holds (z0 - z2) * (x1 - x2)
	}
	{
	sub		r4, r2								; R2 holds (z0 - z2) * (y1 - y2) - (z1 - z2) * (y0 - y2)
	mul		z1, r1, >>r5, r1					; R1 holds (z1 - z2) * (x0 - x2)
	}
	mul		r0, r2, >>r6, r2					; dz/dX complete
	mul		r0, y0, >>#GLINVDXSCREENSHIFT-6, y0	; y0 holds (y0 - y2) / dX 
	{
	st_s	r2, (_MPEPolygonGradient)			; Store dz/dX
	sub		r1, r3								; R3 holds (z1 - z2) * (x0 - x2) - (z0 - z2) * (x1 - x2)

	mul		r0, y1, >>#GLINVDXSCREENSHIFT-6, y1	; y1 holds (y1 - y2) / dX
	}
	mul		r0, r3, >>r6, r3					; dz/dY complete
	mul		r0, x0, >>#GLINVDXSCREENSHIFT-6, x0	; x0 holds -(x0 - x2) / dY
	{
	st_s	r3, (_MPEPolygonGradient+16)		; Store dz/dY
	mul		r0, x1, >>#GLINVDXSCREENSHIFT-6, x1	; x1 holds -(x1 - x2) / dY
	}
	st_s	#16, (acshift)
	mul		y1, CY0, >>acshift, x2
	mul		y1, CC0, >>acshift, y2
	mul		y1, CB0, >>acshift, z2
	mul		y1, CA0, >>acshift, w2
	mul		y0, CY1, >>acshift, v1[0]
	mul		y0, CC1, >>acshift, v1[1]
	mul		y0, CB1, >>acshift, v1[2]
	mul		y0, CA1, >>acshift, v1[3]
	mul		x1, CY0, >>acshift, CY0
	mul		x1, CC0, >>acshift, CC0
	mul		x1, CB0, >>acshift, CB0
	mul		x1, CA0, >>acshift, CA0
	mul		x0, CY1, >>acshift, CY1
	mul		x0, CC1, >>acshift, CC1
	mul		x0, CB1, >>acshift, CB1	
	mul		x0, CA1, >>acshift, CA1	
	sub		x2, v1[0]
	sub		y2, v1[1]
	sub		z2, v1[2]
	sub		w2, v1[3]
	sub		CY1, CY0
	sub		CC1, CC0
	sub		CB1, CB0
	sub		CA1, CA0
	st_v	v1, (_MPEPolygonColorGradient)		; Save dc/dX
	st_v	C0, (_MPEPolygonColorGradient+16)		; Save dc/dY

	; Rasterization equates
	y = r30						; Current y
	leftVertex = r31			; Current left vertex
	rightVertex = r29			; Current right vertex

	; Find top vertex
	mv_s	#$7fffffff, y						; Set yTop to maximum
	ld_s	(_MPEPolygonVertex), r31			; Initial vertex pointer
	lsl		#01, y, r27							; Set R27 to yMin 
	{
	mv_s	#3, r28								; Load vertex count
	add		#04, r31							; Increment vertex pointer to y
	}
	mv_s	r31, r29							; Copy vertex pointer

`topsearch:
	ld_s	(r31), r0							; Load vertex y
	nop
	cmp		y, r0								; Check if new minimum y
	{
	bra		gt, `nonewminvertex, nop			; Jump if vertex is definitely not at top
	cmp		y, r27								; Check for new maximum y
	}

	; New minimum  y/vertex
	mv_s	r31, r29							; Copy current vertex into top vertex pointer
	mv_s	r0, y								; Copy current vertex y into minimum y pointer
`nonewminvertex:
	{
	bra		ge, `nonewmaxvertex, nop			; Jump if no new max y
	sub		#01, r28							; Decrement vertex count
	}

	mv_s	y, r27								; Set R27 to new yMax
`nonewmaxvertex:
	bra		ne, `topsearch						; Jump if more vertices to check
	add		#32, r31
	nop

	{
	mv_s	#32, r1								; Set increment input to left vertex
	sub		#04, r29							; Make vertex pointer point to vertex again
	}
	{
	mv_s	r29, r31							; Set current vertices to same vertex
	copy	r29, r0								; Set left vertex pointer for subroutine
	}

	; Prepare initial left edge
	push	v7, rz								; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge, nop
	ld_s	(pcexec), r2
	}

	; Prepare initial right edge
	{
	bra		`PrepareEdge
	mv_s	#-32, r1
	copy	r31, r0
	}
	ld_s	(pcexec), r2
	nop
	pop		v7, rz						; Restore edge pointers and subroutine return

	; Walk left and right edges and fire off scanlines
`WalkLoop:
	; Walk a scanline
	ld_v	(_MPEPolygonLeftEdge), v7			; Load left edge parameters
	ld_v	(_MPEPolygonLeftEdge+16), v5		; Load final batch of left edge stuff
	ld_v	(_MPEPolygonRightEdge), v4			; Load right edge parameters
	{
	st_s	v7[3], (_MPEPolygonX)				; Store initial polygon x
	asl		#16, v7[3], v7[2]					; Convert x to bilinear coordinate
	}
	{
	ld_v	(_MPEPolygonLeftEdge+48), v6		; Load additional left edge stuff
	abs		v5[0]
	subm	v3[1], v3[1]						; Set scanline remainder to 0
	mvr		v7[2], rx							; Set bilinear x
	}
	{
	ld_v	(_MPEPolygonColorGradient), v7		; Load dc/dX
	sub		v7[3], v4[3], v3[0]					; Calculate scanline width
	addm	v3[1], v5[0], v4[3]					; Copy z/w into v4[3]
	}

`CalculateDMASize:
	{
	ld_s	(_MPEPolygonGradient), v1[3]			; Load dz/dX
	bra		le, `StepLeftEdge						; Jump if zero width scanline
	cmp		#64, v3[0]								; Check for maximum DMA length
	}	
	{
	ld_v	(_MPEPolygonColorGradient), v2			; Read dc/dX 
	bra		le, `OneBigStep
	}
	ld_s	(_MPEPolygonDMASourcePointer), v5[3]	; Load current DMA destination pointer
	nop

	{
	mv_s	#64, v3[0]	
	sub		#64, v3[0], v3[1]					; Calculate scanline remainder
	}
`OneBigStep:
	st_s	v3[0], (_MPEPolygonDMASize)				; Store DMA size
	st_s	v3[0], (rc1)							; Store scanline size in DMA countdown
	st_s	v3[1], (_MPEPolygonScanlineRemainder)	; Store scanline remainder


	; v0[0] = scratch; destination Y; final Y
	; v0[1] = scratch; destination C; final C
	; v0[2] = scratch; destination B; final B
	; v0[3] = scratch; destination z
	; v1[0] = scratch
	; v1[1] = scratch
	; v1[2] = unused
	; v1[3] = dz/dx
	; v2[0] = intermediate Y
	; v2[1] = intermediate C
	; v2[2] = intermediate B
	; v2[3] = unused
	; v3[0] = scanline size in pixels
	; v3[1] = unused
	; v3[2] = unused
	; v3[3] = unused
	; v4[0] = unused
	; v4[1] = unused
	; v4[2] = unused
	; v4[3] = z
	; v5[0] = unused
	; v5[1] = unused
	; v5[2] = unused
	; v5[3] = DMA destination pointer
	; v6[0] = Y
	; v6[1] = C
	; v6[2] = B
	; v6[3] = A
	; v7[0] = dY/dx
	; v7[1] = dC/dx
	; v7[2] = dB/dx
	; v7[3] = dA/dx

	; rc1 = DMA/scanline countdown


`RasterPreLoop:

`DMAwait0:
	ld_s	(mdmactl), v1[0]
	ld_s	(_MPEDMAFlags), v0[0]
	{
	and		#$f, v1[0]
	ld_s	(_MPEPolygonY), v0[3]
	}
	{
	bra		ne, `DMAwait0
	ld_s	(_MPEPolygonX), v0[2]
	bset	#13, v0[0]
	}
	{
	ld_s	(_MPESDRAMPointer), v0[1]
	bset	#16, v0[3]	
	}
	or		v3[0], >>#-16, v0[2]
	st_v	v0, (_MPEMDMACmdBuf)
	st_s	v5[3], (_MPEMDMACmdBuf+16)
	st_s	#_MPEMDMACmdBuf, (mdmacptr)
`DMAwait1:
	ld_s	(mdmactl), v0[0]
	nop
	and		#$f, v0[0]
	bra		ne, `DMAwait1, nop

; TODO: optimize further
`RasterLoop:
	ld_pz	(v5[3]), v0								; load existing color and z
	lsr		#1, v4[3], v1[0]
	lsr		#1, v0[3], v1[1]
	cmp		v1[1], v1[0]
	{
	bra		ge, `Step
	sub_p	v0, v6, v2
	dec		rc1										; decrement pixel/DMA countdown
	}
	mul_p	v6[3], v2, >>#30, v2
	nop
	add_p	v2, v0
`Step:
	{
	st_pz	v0, (v5[3])								; store blended color and destination z
	bra		c1ne, `RasterLoop
	add		#04, v5[3]								; increment DMA destination pointer
	addm	v7[0], v6[0]							; increment Y
	}
	{
	add		v7[1], v6[1]							; increment C
	addm	v7[2], v6[2]							; increment B
	}
	{
	add		v7[3], v6[3]							; increment A
	addm	v1[3], v4[3]							; increment z
	}

`RasterPostLoop:
	
	; Wait for DMA and then let things rip
`DMAwait:
	ld_s	(mdmactl), r0							; Read DMA control register
	ld_s	(_MPEPolygonScanlineRemainder), r7		; Load scanline remainder
	and		#$f, r0									; Check for DMA activity
	bra		ne, `DMAwait


`DoDMA:
	ld_s	(_MPEDMAFlags), r0
	ld_s	(_MPEPolygonX), r2
	{
	ld_s	(_MPEPolygonDMASize), r5
	and		#$fffffffb, r0				; change z test mode 3 to 1
	}
	ld_s	(_MPEPolygonY), r3
	{
	ld_s	(_MPEPolygonDMASourcePointer), r4
	lsl		#16, r5
	addm	r2, r5, r6					; Increment polygon X
	}
	{
	ld_s	(_MPESDRAMPointer), r1
	bset	#16, r3						; YPOS input complete
	}
	{
	st_s	r4, (_MPEMDMACmdBuf+16)
	or		r5, r2						; XPOS input complete
	}
	{
	st_v	v0, (_MPEMDMACmdBuf)
	eor		#DMA_CACHE_EOR, r4			; Flip DMA buffers
	}
	st_s	#_MPEMDMACmdBuf, (mdmacptr)

;---------------------------------------------------------------------

`CheckScanlineRemainder:
	{
	cmp		#00, r7										; Check if any pixels are left on scanline
	st_s	r6, (_MPEPolygonX)							; Store updated polygon x
	}
	{
	st_s	r4, (_MPEPolygonDMASourcePointer)			; Store updated polygon DMA pointer
	bra		gt, `CalculateDMASize						; Branch if not at end of scanline
	}
	sub		v3[1], v3[1]								; Zero scanline remainder
	copy	r7, v3[0]									; Set v3[0] to remaining scanline width

	; Increment left and right edges
`StepLeftEdge:
	ld_v	(_MPEPolygonLeftEdge), v7			; Load edge xStep numerator errorTerm x
	ld_v	(_MPEPolygonLeftEdge+16), v6		; Load edge	z zstep 1/w 1/wstep
	ld_v	(_MPEPolygonLeftEdge+48), v5		; Load edge color
	{
	ld_v	(_MPEPolygonLeftEdge+64), v4		; Load cStep
	add		v7[1], v7[2]						; Increment left errorTerm
	addm	v7[0], v7[3]						; Increment left x
	}
	{
	ld_s	(_MPEPolygonY), r0					; Load current polygon y
	addm	v6[1], v6[0]						; Increment z
	}
	{
	bra		le, `NoLeftOverflow					; Branch if errorTerm < 0
	add		v4[2], v5[2]						; Increment cB
	addm	v4[3], v5[3]						; Increment cA
	}
	{
	ld_v	(_MPEPolygonEdgeExtra), v4			; Load height/denominators for both edges
	add		v4[0], v5[0]						; Increment cY
	addm	v4[1], v5[1]						; Increment cC
	}
	ld_s	(_MPEPolygonGradient), r1			; Load dz/dX


`LeftOverFlow:
	{
	ld_v	(_MPEPolygonColorGradient), v2		; Load dc/dX
	add		#01, v7[3]							; Increment x
	subm	v4[1], v7[2]						; Reset error term
	}
	add		r1, v6[0]							; Increment z
	{
	add		v2[0], v5[0]						; Increment cY
	addm	v2[1], v5[1]						; Increment cC
	}
	{
	add		v2[2], v5[2]						; Increment cB
	addm	v2[3], v5[3]						; Increment cA
	}

`NoLeftOverflow:
	{
	st_v	v7, (_MPEPolygonLeftEdge)		; Store updated left edge info
	sub		#01, v4[0]						; Decrement height
	}
	{
	st_v	v6, (_MPEPolygonLeftEdge+16)	; Store updated left edge info
	}
	{
	bra		gt, `StepRightEdge
	st_v	v5, (_MPEPolygonLeftEdge+48)	; Store updated left edge info
	add		#01, r0							; Increment polygon y
	}
	{
	st_v	v4, (_MPEPolygonEdgeExtra)		; Store updated height/denominator
	asl		#16, r0, r1						; Convert y to 16.16 fp
	}
	{
	st_s	r0, (_MPEPolygonY)				; Store updated polygon y
	mvr		r1, ry
	}
	
	; Prepare next left edge
	push	v7, rz										; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge								; Jump to edge calculation routine
	mv_s	#32, r1										; Set vertex increment to positive
	}
	ld_s	(pcexec), r2								; Load return address
	ld_s	(_MPEPolygonNextLeftVertexPointer), r0		; Load next vertex pointer
	pop		v7, rz
	
`StepRightEdge:
	ld_v	(_MPEPolygonRightEdge), v7			; Load right edge data
	ld_v	(_MPEPolygonEdgeExtra), v6			; Load height/denominator
	{
	add		v7[1], v7[2]						; Increment right errorTerm
	addm	v7[0], v7[3]						; Increment right x
	}
	bra		le, `NoRightOverflow, nop			; Branch if errorTerm < 0
	{
	add		#01, v7[3]							; Increment x
	subm	v6[3], v7[2]						; Reset errorTerm
	}

`NoRightOverflow:
	{
	st_v	v7, (_MPEPolygonRightEdge)				; Store updated edge parameters
	sub		#01, v6[2]								; Decrement edge height
	}
	{
	bra		ne, `WalkLoop, nop						; Jump to main loop if more left
	st_v	v6, (_MPEPolygonEdgeExtra)				; Updated edge data complete
	add		#01, r0									; Increment polygon y
	}

	; Prepare next right edge
	push	v7, rz									; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge							; Jump to edge calculation routine
	mv_s	#-32, r1								; Set vertex increment to positive
	}
	ld_s	(pcexec), r2							; Load return address
	ld_s	(_MPEPolygonNextRightVertexPointer), r0	; Load next vertex pointer
	{
	bra		`WalkLoop, nop
	pop		v7, rz
	}

	; Subroutines

	; Prepares an edge, pass vertex pointer in R0
	; 32 for a right edge or -32 for a left edge in R1
	; and return address in R2
	; Next vertex pointer is returned in R0
	; Affects R0-R30!!!! (R31 must be unaffected SML 9/30/98)
`PrepareEdge:
	{
	st_s	#9, rc0								; Store maximum vertex count
	copy	r1, r7								; Wait on load and save increment
	}
	st_s	r2, (rz)							; Store return address
`PrepEdge:
	{
	bra		c0eq, `EndPolygon
	mv_s	#3, r27								; Read number of vertices
	}
	ld_s	(_MPEPolygonVertex), r28			; R28 points to MPE Polygon Vertex List
	{
	ld_v	(r0), v2							; Read x1, y1, z1, 1/w1
	add		#24, r0								; Increment vertex pointer to C 
	addm	r7, r0, r26 						; R26 now points to second vertex
	}
	{
	ld_sv	(r0), v3							; Read C
	cmp		r28, r26							; Check for vertex underflow
	mul		#16, r27, >>#-1, r27				; Calculate 32 * vertices 
	}
	{
	bra		ge, `nounderflow					; Jump if no underflow
	copy	r9, r25								; Copy fixed point y1 into r25
	}
	{
	mv_s	r8, r24								; Copy fixed point x1 into R24
	add		r27, r28, r29						; R29 points past end of active vertices
	dec		rc0									; Decrement vertex search counter
	}
	mv_s	#((1<<GLXYZSCREENSHIFT)-1), r30		; R30 contains ceiling rounder

	add		r27, r26							; Wrap vertex around to end of list
`nounderflow:
	cmp		r29, r26							; Check for vertex pointer overflow
	bra		ne, `nooverflow, nop				; Jump if no overflow

	sub		r27, r26							; Wrap vertex around to beginning of list

`nooverflow:
	{
	ld_v	(r26), v4							; Read x2, y2, z2, 1/w2
	add		r30, r8								; Round up x1
	addm	r30, r9								; Round up y1
	}
	{
	ld_v	(_MPEPolygonGradient), v5			; Read gradient x stuff
	asr		#GLXYZSCREENSHIFT, r9				; Integer y1 complete
	}
	{
	add		r30, r16							; Round up x2
	addm	r30, r17							; Round up y2
	}
	{
	asr		#GLXYZSCREENSHIFT, r17				; Integer y2 complete
	mul		#1, r8, >>#GLXYZSCREENSHIFT, r8		; Integer x1 complete
	}
	{
	sub		r9, r17, r30						; R30 contains height of edge
	mul		#1, r16, >>#GLXYZSCREENSHIFT, r16	; Integer x2 complete
	}

	bra		mi, `EndPolygon, nop				; Jump if polygon end reached
	bra		ne, `realedge, nop					; Jump if not a flat edge

	; Flat edge, jump to next vertex and try again
	{
	bra		`PrepEdge, nop
	mv_s	r26, r0					; Set current vertex to next vertex	
	}
	
	; Genuine edge, calculate Bresenham parameters 
`realedge:
	{
	push	v2, rz						; Save subroutine return address
	jsr		_FloorDivMod
	}
	{
	mv_s	r30, r1								; R1 = denominator = dY
	sub		r8, >>#(-GLXYZSCREENSHIFT), r24		; Calculate x prestep
	}
	{
	st_s	#00, (acshift)						; Set acshift to 0
	sub		r9, >>#(-GLXYZSCREENSHIFT), r25		; Calculate y prestep
	subm	r8, r16, r0							; R0 = numerator = dX
	}
	
	{
	mv_s	r30, r4								; Move edge height into R4
	copy	r8, r3								; Move initial x into R3
	addm	r1, r1								; Set numerator to 2X remainder
	}
	; Check for left/right edge
	{
	pop		v2, rz								; Restore subroutine return address
	cmp		#00, r7								; Check for left or right edge
	}

	{
	ld_s	(_MPEPolygonGradient), v5[0]		; Load x components of gradient
	add		r4, r4, r5							; Set denominator to 2X edge height
	bra		ge, `leftedge
	}
	{
	ld_v	(_MPEPolygonColorGradient), v4		; Load dc/dX
	neg		r24									; Make x prestep positive
	}
	neg		r25									; Make y prestep positive

`rightedge:
	st_s	r26, (_MPEPolygonNextRightVertexPointer)	; Store next right vertex
	{
	st_v	v0, (_MPEPolygonRightEdge)			; Store right edge Bresenham parameters
	rts
	}
	st_s	r4, (_MPEPolygonRightEdgeExtra)		; Store height
	st_s	r5, (_MPEPolygonRightEdgeExtra+4)	; Store denominator

	// Calculate all Bresenham parameters and prestep them to integer coordinates
	// If you don't do this, you get HORRIBLE texture swim
`leftedge:
	{
	st_s	v1[0], (_MPEPolygonLeftEdgeExtra)			; Store height
	copy	v2[2], v1[0]								; Copy z into v1[0]
	}
	{
	st_s	v1[1], (_MPEPolygonLeftEdgeExtra+4)			; Store denominator
	mul		r0, v5[0], >>acshift, v1[1]					; Calculate first component of zStep
	}
	{
	ld_s	(_MPEPolygonGradient+16), v5[1]				; Load dz/dY
	}
	st_s	#00, (acshift)
	{
	st_s	v2[1], (_MPEPolygonY)						; Store current polygon y coordinate
	mul		r0, v4[0], >>acshift, v2[0]					; Calculate first component of cYStep
	}
	{
	asl		#16, v2[1], v2[2]
	mul		r0, v4[1], >>acshift, v2[1]					; Calculate first component of cCStep
	}
	{
	mul		r0, v4[2], >>acshift, v2[2]					; Calculate first component of cBStep
	mvr		v2[2], ry
	}
	mul		r0, v4[3], >>acshift, v2[3]					; Calculate first component of cAStep
	{
	st_v	v0, (_MPEPolygonLeftEdge)					; Store left edge Bresenham parameters	
	add		v5[1], v1[1]								; zStep complete
	mul		r24, v5[0], >>#GLXYZSCREENSHIFT, v5[0]		; Calculate dz/dX * xPrestep
	}
	{
	ld_v	(_MPEPolygonColorGradient+16), v0			; Load dc/dY
	lsl		#(30-GLXYZSCREENSHIFT), r24					; Convert xPrestep to 2.30 fp number									
	}
	{
	st_s	r26, (_MPEPolygonNextLeftVertexPointer)		; Store next left vertex
	add		v5[0], v1[0]								; z1 = z + dz/dx * xPrestep
	mul		r25, v5[1], >>#GLXYZSCREENSHIFT, v5[1]		; Calculate dz/dY * yPrestep
	}
	lsl		#(30-GLXYZSCREENSHIFT), r25					; Convert yPrestep to 2.30 fp number
	{
	add		v5[1], v1[0]								; z1 complete
	mul_sv	r24, v4, >>#30, v4							; Calculate dc/dx * xPrestep
	}
	{
	st_v	v1, (_MPEPolygonLeftEdge+16)				; Store z    zStep
	add		v0[0], v2[0]								; cYStep complete
	}
	{
	add		v0[1], v2[1]								; cCStep complete
	addm	v0[3], v2[3]								; cAStep complete
	}
	{
	add		v0[2], v2[2]								; cBStep complete
	mul_sv	r25, v0, >>#30, v0							; Calculate dc/dy * yPrestep
	}
	{
	rts
	st_v	v2, (_MPEPolygonLeftEdge+64)				; Store cStep
//	add_sv	v4, v3										; c1 = c + dc/dx * xPrestep
	}
//	add_sv	v0, v3										; c1 = c + dc/dx * xPrestep + dx/dy * yPrestep
	nop
	st_v	v3, (_MPEPolygonLeftEdge+48)				; Store c
	
;---------------------------------------------------------------------------------------




	; Move onto next polygon or clean up if done
`EndPolygon:
	pop		v7, rz							; Restore subroutine return
`EndPolygon1:
	ld_s	(_MPEPolygonVertices), r0		; Load current vertex count
	ld_s	(_MPEPolygonVertex), r1			; Load current vertex pointer
	sub		#01, r0							; Decrement vertex count
	{
	ld_v	(r1), v1						; Load 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex counter
	}
	{
	ld_v	(r1), v2						; Load 1st vertex C
	add		#16, r1							; Increment 1st vertex counter
	}
	st_s	r1, (_MPEPolygonVertex)			; Store new 1st vertex pointer
	cmp		#3, r0							; Check for last triangle
	{
	bra		ge, `PolygonLoop				; Jump if more triangles to rasterize
	st_s	r0, (_MPEPolygonVertices)		; Store new vertex count
	}
	{
	st_v	v1, (r1)						; Store 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex pointer
	}
	st_v	v2, (r1)
	
	; Clean up and exit
`RasterDone:
	rts		nop

.align.sv
_RasterCB_end:


// see pipeline.c for circumstances under which it is valid to use this rasterizer
// TODO: This rasterizer has a bug which caused nasty color banding. RasC and RasCB have the same problem.
.align.sv
.module RasCB2
.export _RasterCB2
.export _RasterCB2_size
.import _FloorDivMod
.import _MPEMDMACmdBuf
.import _MPEPolygonGradient
.import _MPEPolygonColorGradient
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEPolygonVertex
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPEPolygonLeftEdgeExtra
.import _MPEPolygonRightEdgeExtra
.import _MPEPolygonEdgeExtra
.import _MPEPolygonX
.import _MPEPolygonY
.import _MPEPolygonDMASize
.import _MPEPolygonDMASourcePointer
.import _MPEPolygonPixelPointer
.import _MPESDRAMPointer
.import _MPEDMAFlags
.import _MPEPolygonScanlineRemainder
.import _MPEPolygonScanlineRecipLUT
.import _MPEPolygonScanlineValues
.import _MPEPolygonScanlineColorValues
.import _MPEPolygonNextLeftVertexPointer
.import _MPEPolygonNextRightVertexPointer
.import _MPERecipLUT

	; Register equates
	X0 = v7				// Vertex 0 vector
	x0 = r28
	y0 = r29
	z0 = r30
	w0 = r31
	C0 = v2				// Vertex 0 color
	CY0 = v2[0]
	CC0 = v2[1]
	CB0 = v2[2]
	CA0 = v2[3]
	X1 = v6				// Vertex 1 vector
	x1 = r24
	y1 = r25
	z1 = r26
	w1 = r27
	C1 = v3				// Vertex 1 color
	CY1 = v3[0]
	CC1 = v3[1]
	CB1 = v3[2]
	CA1 = v3[3]
	X2 = v5				// Vertex 2 vector
	x2 = r20
	y2 = r21
	z2 = r22
	w2 = r23
	C2 = v4				// Vertex 2 color
	CY2 = v4[0]
	CC2 = v4[1]
	CB2 = v4[2]
	CA2 = v4[3]

_RasterCB2_size = _RasterCB2_end - _RasterCB2
_RasterCB2:
	mv_s	#_MPEPolygonVertexList, r0				; Initialize vertex list
	st_s	r0, (_MPEPolygonVertex)					; Kludge a 3 vertex polygon

	; Calculate Gradients from any 3 vertices (optimized for trivial accept)
	; Affects all registers

`PolygonLoop:
	ld_s	(_MPEPolygonVertex), r0
	nop

	; Stage 1, load data for triangle and calculate dV0 AND dV1
	{
	ld_v 	(r0), X2						; Load vertex 0 xyz1/w
	add		#24, r0							; Increment vertex pointer					
	}
	{
	ld_sv	(r0), C2						; Load vertex 0 C
	add		#8, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X0						; Load vertex 2 xyz1/w
	add		#24, r0							; Increment vertex pointer
	}
	{
	ld_sv 	(r0), C0						; Load vertex 2 C
	add		#8, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X1						; Load vertex 1 xyz1/w
	add		#24, r0							; Increment vertex pointer
	subm	x2, x0							; Calculate x0 - x2		
	}
	{
	ld_sv 	(r0), C1						; Load vertex 1 C
	sub		z2, z0							; Calculate z0 - z2
	subm	y2, y0							; Calculate y0 - y2
	}

	; Calculate dX, dY, dCY, dCC, dCB, and dZ
	{
	st_s	#GLXYZSCREENSHIFT, (acshift)		; Set acshift for dX and dY products
	sub		x2, x1								; Calculate x1 - x2
	subm	y2, y1								; Calculate y1 - y2
	}
	{
	sub_sv	C2, C0								; Calculate C0 - C2	
	mul		x1, y0, >>acshift, x2				; X2 now contains (x1 - x2) * (y0 - y2)
	}
	{
	sub_sv	C2, C1								; Calculate C1 - C2
	mul		x0, y1, >>acshift, y2				; Y2 now contains (x0 - x2) * (y1 - y2)
	}
	msb		z0, r6								; Calculate MSB of (z0 - z2)
	sub		y2, x2, r0							; R0 now contains dX or signed area
	{
	bra		le, `EndPolygon1
	abs		r0									; Insure denominator is positive
	subm	z2, z1								; Calculate z1 - z2
	}
	msb		z1, r7								; Calculate MSB of (z1 - z2)
	msb		r0, r1								; Calculate dX MSB
	sub		#08, r1, r2							; R2 holds index shift for 1/dX	
	{
	mv_s	#_MPERecipLUT-128, r4				; R4 holds reciprocal LUT pointer
	ls		r2, r0, r3							; Convert dX into index offset
	}
	{
	mv_s	#$40000000, r3						; R3 holds unsigned LUT value conversion mask
	cmp		r6, r7								; Compare dZ MSBs
	addm	r3, r4								; R4 holds pointer to reciprocal LUT value
	}
	{
	bra		ge, `z1msbgreater					; Branch if (z1 - z2) MSB is greater
	ld_b	(r4), r5							; Load 8 bit reciprocal LUT value
	}
	add		#(36-GLXYZSCREENSHIFT), r2			; Adjust 1/dX answer shift
	{
	mv_s	#$7fffffff, r4						; R4 holds 2.30 TWO	
	or		r5, >>#2, r3						; Convert 8 bit LUT value to 32 bit scalar
	}


	mv_s	r6, r7								; (z0 - z2) MSB greater
`z1msbgreater:
	{
	mv_s	x0, r1								; Copy (x0 - x2) into r1
	cmp		#20, r7								; Check MSB
	mul		r3, r0, >>r1, r0					; Calculate xy
	}	
	bra		le, `zmsblessthan20					; Branch if z MSB < 20
	{
	mv_s	#GLXYZSCREENSHIFT, r5				; R5 holds default preshift value for multiplication
	copy	y1, r4								; Copy (y1 - y2) into r4
	subm	r0, r4, r0							; Calculate 2 - xy
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r6				; R6 holds default postshift value for multiplication
	mul		r3, r0, >>r2, r0					; 1/dX complete
	}

	add		#GLXYZSCREENSHIFT-20, r7, r5		; R5 holds adjusted dz preshift
	sub		r7, #GLINVDXSCREENSHIFT+20, r6		; R6 holds adjusted dz postshift
`zmsblessthan20:
	{
	mv_s	y0, r2								; Copy (y0 - y2) into r2
	mul		z0, r4, >>r5, r4					; R4 holds (z0 - z2) * (y1 - y2)
	}
	{
	mv_s	x1, r3								; Copy (x1 - x2) into r3
	mul		z1, r2, >>r5, r2					; R2 holds (z1 - z2) * (y0 - y2)
	}
	{
	mul		z0, r3, >>r5, r3					; R3 holds (z0 - z2) * (x1 - x2)
	}
	{
	sub		r4, r2								; R2 holds (z0 - z2) * (y1 - y2) - (z1 - z2) * (y0 - y2)
	mul		z1, r1, >>r5, r1					; R1 holds (z1 - z2) * (x0 - x2)
	}
	mul		r0, r2, >>r6, r2					; dz/dX complete
	mul		r0, y0, >>#GLINVDXSCREENSHIFT-6, y0	; y0 holds (y0 - y2) / dX 
	{
	st_s	r2, (_MPEPolygonGradient)			; Store dz/dX
	sub		r1, r3								; R3 holds (z1 - z2) * (x0 - x2) - (z0 - z2) * (x1 - x2)

	mul		r0, y1, >>#GLINVDXSCREENSHIFT-6, y1	; y1 holds (y1 - y2) / dX
	}
	mul		r0, r3, >>r6, r3					; dz/dY complete
	mul		r0, x0, >>#GLINVDXSCREENSHIFT-6, x0	; x0 holds -(x0 - x2) / dY
	{
	st_s	r3, (_MPEPolygonGradient+16)		; Store dz/dY
	mul		r0, x1, >>#GLINVDXSCREENSHIFT-6, x1	; x1 holds -(x1 - x2) / dY
	}
	st_s	#16, (acshift)
	mul		y1, CY0, >>acshift, x2
	mul		y1, CC0, >>acshift, y2
	mul		y1, CB0, >>acshift, z2
	mul		y1, CA0, >>acshift, w2
	mul		y0, CY1, >>acshift, v1[0]
	mul		y0, CC1, >>acshift, v1[1]
	mul		y0, CB1, >>acshift, v1[2]
	mul		y0, CA1, >>acshift, v1[3]
	mul		x1, CY0, >>acshift, CY0
	mul		x1, CC0, >>acshift, CC0
	mul		x1, CB0, >>acshift, CB0
	mul		x1, CA0, >>acshift, CA0
	mul		x0, CY1, >>acshift, CY1
	mul		x0, CC1, >>acshift, CC1
	mul		x0, CB1, >>acshift, CB1	
	mul		x0, CA1, >>acshift, CA1	
	sub		x2, v1[0]
	sub		y2, v1[1]
	sub		z2, v1[2]
	sub		w2, v1[3]
	sub		CY1, CY0
	sub		CC1, CC0
	sub		CB1, CB0
	sub		CA1, CA0
	st_v	v1, (_MPEPolygonColorGradient)		; Save dc/dX
	st_v	C0, (_MPEPolygonColorGradient+16)		; Save dc/dY

	; Rasterization equates
	y = r30						; Current y
	leftVertex = r31			; Current left vertex
	rightVertex = r29			; Current right vertex

	; Find top vertex
	mv_s	#$7fffffff, y						; Set yTop to maximum
	ld_s	(_MPEPolygonVertex), r31			; Initial vertex pointer
	lsl		#01, y, r27							; Set R27 to yMin 
	{
	mv_s	#3, r28								; Load vertex count
	add		#04, r31							; Increment vertex pointer to y
	}
	mv_s	r31, r29							; Copy vertex pointer

`topsearch:
	ld_s	(r31), r0							; Load vertex y
	nop
	cmp		y, r0								; Check if new minimum y
	{
	bra		gt, `nonewminvertex, nop			; Jump if vertex is definitely not at top
	cmp		y, r27								; Check for new maximum y
	}

	; New minimum  y/vertex
	mv_s	r31, r29							; Copy current vertex into top vertex pointer
	mv_s	r0, y								; Copy current vertex y into minimum y pointer
`nonewminvertex:
	{
	bra		ge, `nonewmaxvertex, nop			; Jump if no new max y
	sub		#01, r28							; Decrement vertex count
	}

	mv_s	y, r27								; Set R27 to new yMax
`nonewmaxvertex:
	bra		ne, `topsearch						; Jump if more vertices to check
	add		#32, r31
	nop

	{
	mv_s	#32, r1								; Set increment input to left vertex
	sub		#04, r29							; Make vertex pointer point to vertex again
	}
	{
	mv_s	r29, r31							; Set current vertices to same vertex
	copy	r29, r0								; Set left vertex pointer for subroutine
	}

	; Prepare initial left edge
	push	v7, rz								; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge, nop
	ld_s	(pcexec), r2
	}

	; Prepare initial right edge
	{
	bra		`PrepareEdge
	mv_s	#-32, r1
	copy	r31, r0
	}
	ld_s	(pcexec), r2
	nop
	pop		v7, rz						; Restore edge pointers and subroutine return

	; Walk left and right edges and fire off scanlines
`WalkLoop:
	; Walk a scanline
	ld_v	(_MPEPolygonLeftEdge), v7			; Load left edge parameters
	ld_v	(_MPEPolygonLeftEdge+16), v5		; Load final batch of left edge stuff
	ld_v	(_MPEPolygonRightEdge), v4			; Load right edge parameters
	{
	st_s	v7[3], (_MPEPolygonX)				; Store initial polygon x
	asl		#16, v7[3], v7[2]					; Convert x to bilinear coordinate
	}
	{
	ld_v	(_MPEPolygonLeftEdge+48), v6		; Load additional left edge stuff
	abs		v5[0]
	subm	v3[1], v3[1]						; Set scanline remainder to 0
	mvr		v7[2], rx							; Set bilinear x
	}
	{
	ld_v	(_MPEPolygonColorGradient), v7		; Load dc/dX
	sub		v7[3], v4[3], v3[0]					; Calculate scanline width
	addm	v3[1], v5[0], v4[3]					; Copy z/w into v4[3]
	}

`CalculateDMASize:
	{
	ld_s	(_MPEPolygonGradient), v1[3]			; Load dz/dX
	bra		le, `StepLeftEdge						; Jump if zero width scanline
	cmp		#64, v3[0]								; Check for maximum DMA length
	}	
	{
	ld_v	(_MPEPolygonColorGradient), v2			; Read dc/dX 
	bra		le, `OneBigStep
	}
	ld_s	(_MPEPolygonDMASourcePointer), v5[3]	; Load current DMA destination pointer
	nop

	{
	mv_s	#64, v3[0]	
	sub		#64, v3[0], v3[1]					; Calculate scanline remainder
	}
`OneBigStep:
	st_s	v3[0], (_MPEPolygonDMASize)				; Store DMA size
	st_s	v3[0], (rc1)							; Store scanline size in DMA countdown
	st_s	v3[1], (_MPEPolygonScanlineRemainder)	; Store scanline remainder


	; v0[0] = scratch; destination Y; final Y
	; v0[1] = scratch; destination C; final C
	; v0[2] = scratch; destination B; final B
	; v0[3] = scratch; destination z
	; v1[0] = scratch
	; v1[1] = scratch
	; v1[2] = unused
	; v1[3] = dz/dx
	; v2[0] = intermediate Y
	; v2[1] = intermediate C
	; v2[2] = intermediate B
	; v2[3] = unused
	; v3[0] = scanline size in pixels
	; v3[1] = unused
	; v3[2] = unused
	; v3[3] = unused
	; v4[0] = unused
	; v4[1] = unused
	; v4[2] = unused
	; v4[3] = z
	; v5[0] = unused
	; v5[1] = unused
	; v5[2] = unused
	; v5[3] = DMA destination pointer
	; v6[0] = Y
	; v6[1] = C
	; v6[2] = B
	; v6[3] = A
	; v7[0] = dY/dx
	; v7[1] = dC/dx
	; v7[2] = dB/dx
	; v7[3] = dA/dx

	; rc1 = DMA/scanline countdown


`RasterPreLoop:

`DMAwait0:
	ld_s	(mdmactl), v1[0]
	ld_s	(_MPEDMAFlags), v0[0]
	{
	and		#$f, v1[0]
	ld_s	(_MPEPolygonY), v0[3]
	}
	{
	bra		ne, `DMAwait0
	ld_s	(_MPEPolygonX), v0[2]
	bset	#13, v0[0]
	}
	{
	ld_s	(_MPESDRAMPointer), v0[1]
	bset	#16, v0[3]	
	}
	or		v3[0], >>#-16, v0[2]
	st_v	v0, (_MPEMDMACmdBuf)
	st_s	v5[3], (_MPEMDMACmdBuf+16)
	st_s	#_MPEMDMACmdBuf, (mdmacptr)
`DMAwait1:
	ld_s	(mdmactl), v0[0]
	nop
	and		#$f, v0[0]
	bra		ne, `DMAwait1, nop

; TODO: optimize further
`RasterLoop:
	ld_p	(v5[3]), v0								; load existing color
	nop
	{
	mv_s	v4[3], v0[3]							; copy z
	sub_p	v0, v6, v2								; work on blend
	}
	mul_p	v6[3], v2, >>#30, v2					; work on blend
	nop
	{
	add_p	v2, v0									; blend complete
	dec		rc1										; decrement pixel/DMA countdown
	}
	{
	st_pz	v0, (v5[3])								; store blended color and destination z
	bra		c1ne, `RasterLoop
	add		#04, v5[3]								; increment DMA destination pointer
	addm	v7[0], v6[0]							; increment Y
	}
	{
	add		v7[1], v6[1]							; increment C
	addm	v7[2], v6[2]							; increment B
	}
	{
	add		v7[3], v6[3]							; increment A
	addm	v1[3], v4[3]							; increment z
	}

`RasterPostLoop:
	
	; Wait for DMA and then let things rip
`DMAwait:
	ld_s	(mdmactl), r0							; Read DMA control register
	ld_s	(_MPEPolygonScanlineRemainder), r7		; Load scanline remainder
	and		#$f, r0									; Check for DMA activity
	bra		ne, `DMAwait


`DoDMA:
	ld_s	(_MPEDMAFlags), r0
	ld_s	(_MPEPolygonX), r2
	{
	ld_s	(_MPEPolygonDMASize), r5
	and		#$fffffffb, r0				; change z test mode 3 to 1
	}
	ld_s	(_MPEPolygonY), r3
	{
	ld_s	(_MPEPolygonDMASourcePointer), r4
	lsl		#16, r5
	addm	r2, r5, r6					; Increment polygon X
	}
	{
	ld_s	(_MPESDRAMPointer), r1
	bset	#16, r3						; YPOS input complete
	}
	{
	st_s	r4, (_MPEMDMACmdBuf+16)
	or		r5, r2						; XPOS input complete
	}
	{
	st_v	v0, (_MPEMDMACmdBuf)
	eor		#DMA_CACHE_EOR, r4			; Flip DMA buffers
	}
	st_s	#_MPEMDMACmdBuf, (mdmacptr)

;---------------------------------------------------------------------

`CheckScanlineRemainder:
	{
	cmp		#00, r7										; Check if any pixels are left on scanline
	st_s	r6, (_MPEPolygonX)							; Store updated polygon x
	}
	{
	st_s	r4, (_MPEPolygonDMASourcePointer)			; Store updated polygon DMA pointer
	bra		gt, `CalculateDMASize						; Branch if not at end of scanline
	}
	sub		v3[1], v3[1]								; Zero scanline remainder
	copy	r7, v3[0]									; Set v3[0] to remaining scanline width

	; Increment left and right edges
`StepLeftEdge:
	ld_v	(_MPEPolygonLeftEdge), v7			; Load edge xStep numerator errorTerm x
	ld_v	(_MPEPolygonLeftEdge+16), v6		; Load edge	z zstep 1/w 1/wstep
	ld_v	(_MPEPolygonLeftEdge+48), v5		; Load edge color
	{
	ld_v	(_MPEPolygonLeftEdge+64), v4		; Load cStep
	add		v7[1], v7[2]						; Increment left errorTerm
	addm	v7[0], v7[3]						; Increment left x
	}
	{
	ld_s	(_MPEPolygonY), r0					; Load current polygon y
	addm	v6[1], v6[0]						; Increment z
	}
	{
	bra		le, `NoLeftOverflow					; Branch if errorTerm < 0
	add		v4[2], v5[2]						; Increment cB
	addm	v4[3], v5[3]						; Increment cA
	}
	{
	ld_v	(_MPEPolygonEdgeExtra), v4			; Load height/denominators for both edges
	add		v4[0], v5[0]						; Increment cY
	addm	v4[1], v5[1]						; Increment cC
	}
	ld_s	(_MPEPolygonGradient), r1			; Load dz/dX


`LeftOverFlow:
	{
	ld_v	(_MPEPolygonColorGradient), v2		; Load dc/dX
	add		#01, v7[3]							; Increment x
	subm	v4[1], v7[2]						; Reset error term
	}
	add		r1, v6[0]							; Increment z
	{
	add		v2[0], v5[0]						; Increment cY
	addm	v2[1], v5[1]						; Increment cC
	}
	{
	add		v2[2], v5[2]						; Increment cB
	addm	v2[3], v5[3]						; Increment cA
	}

`NoLeftOverflow:
	{
	st_v	v7, (_MPEPolygonLeftEdge)		; Store updated left edge info
	sub		#01, v4[0]						; Decrement height
	}
	{
	st_v	v6, (_MPEPolygonLeftEdge+16)	; Store updated left edge info
	}
	{
	bra		gt, `StepRightEdge
	st_v	v5, (_MPEPolygonLeftEdge+48)	; Store updated left edge info
	add		#01, r0							; Increment polygon y
	}
	{
	st_v	v4, (_MPEPolygonEdgeExtra)		; Store updated height/denominator
	asl		#16, r0, r1						; Convert y to 16.16 fp
	}
	{
	st_s	r0, (_MPEPolygonY)				; Store updated polygon y
	mvr		r1, ry
	}
	
	; Prepare next left edge
	push	v7, rz										; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge								; Jump to edge calculation routine
	mv_s	#32, r1										; Set vertex increment to positive
	}
	ld_s	(pcexec), r2								; Load return address
	ld_s	(_MPEPolygonNextLeftVertexPointer), r0		; Load next vertex pointer
	pop		v7, rz
	
`StepRightEdge:
	ld_v	(_MPEPolygonRightEdge), v7			; Load right edge data
	ld_v	(_MPEPolygonEdgeExtra), v6			; Load height/denominator
	{
	add		v7[1], v7[2]						; Increment right errorTerm
	addm	v7[0], v7[3]						; Increment right x
	}
	bra		le, `NoRightOverflow, nop			; Branch if errorTerm < 0
	{
	add		#01, v7[3]							; Increment x
	subm	v6[3], v7[2]						; Reset errorTerm
	}

`NoRightOverflow:
	{
	st_v	v7, (_MPEPolygonRightEdge)				; Store updated edge parameters
	sub		#01, v6[2]								; Decrement edge height
	}
	{
	bra		ne, `WalkLoop, nop						; Jump to main loop if more left
	st_v	v6, (_MPEPolygonEdgeExtra)				; Updated edge data complete
	add		#01, r0									; Increment polygon y
	}

	; Prepare next right edge
	push	v7, rz									; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge							; Jump to edge calculation routine
	mv_s	#-32, r1								; Set vertex increment to positive
	}
	ld_s	(pcexec), r2							; Load return address
	ld_s	(_MPEPolygonNextRightVertexPointer), r0	; Load next vertex pointer
	{
	bra		`WalkLoop, nop
	pop		v7, rz
	}

	; Subroutines

	; Prepares an edge, pass vertex pointer in R0
	; 32 for a right edge or -32 for a left edge in R1
	; and return address in R2
	; Next vertex pointer is returned in R0
	; Affects R0-R30!!!! (R31 must be unaffected SML 9/30/98)
`PrepareEdge:
	{
	st_s	#9, rc0								; Store maximum vertex count
	copy	r1, r7								; Wait on load and save increment
	}
	st_s	r2, (rz)							; Store return address
`PrepEdge:
	{
	bra		c0eq, `EndPolygon
	mv_s	#3, r27								; Read number of vertices
	}
	ld_s	(_MPEPolygonVertex), r28			; R28 points to MPE Polygon Vertex List
	{
	ld_v	(r0), v2							; Read x1, y1, z1, 1/w1
	add		#24, r0								; Increment vertex pointer to C 
	addm	r7, r0, r26 						; R26 now points to second vertex
	}
	{
	ld_sv	(r0), v3							; Read C
	cmp		r28, r26							; Check for vertex underflow
	mul		#16, r27, >>#-1, r27				; Calculate 32 * vertices 
	}
	{
	bra		ge, `nounderflow					; Jump if no underflow
	copy	r9, r25								; Copy fixed point y1 into r25
	}
	{
	mv_s	r8, r24								; Copy fixed point x1 into R24
	add		r27, r28, r29						; R29 points past end of active vertices
	dec		rc0									; Decrement vertex search counter
	}
	mv_s	#((1<<GLXYZSCREENSHIFT)-1), r30		; R30 contains ceiling rounder

	add		r27, r26							; Wrap vertex around to end of list
`nounderflow:
	cmp		r29, r26							; Check for vertex pointer overflow
	bra		ne, `nooverflow, nop				; Jump if no overflow

	sub		r27, r26							; Wrap vertex around to beginning of list

`nooverflow:
	{
	ld_v	(r26), v4							; Read x2, y2, z2, 1/w2
	add		r30, r8								; Round up x1
	addm	r30, r9								; Round up y1
	}
	{
	ld_v	(_MPEPolygonGradient), v5			; Read gradient x stuff
	asr		#GLXYZSCREENSHIFT, r9				; Integer y1 complete
	}
	{
	add		r30, r16							; Round up x2
	addm	r30, r17							; Round up y2
	}
	{
	asr		#GLXYZSCREENSHIFT, r17				; Integer y2 complete
	mul		#1, r8, >>#GLXYZSCREENSHIFT, r8		; Integer x1 complete
	}
	{
	sub		r9, r17, r30						; R30 contains height of edge
	mul		#1, r16, >>#GLXYZSCREENSHIFT, r16	; Integer x2 complete
	}

	bra		mi, `EndPolygon, nop				; Jump if polygon end reached
	bra		ne, `realedge, nop					; Jump if not a flat edge

	; Flat edge, jump to next vertex and try again
	{
	bra		`PrepEdge, nop
	mv_s	r26, r0					; Set current vertex to next vertex	
	}
	
	; Genuine edge, calculate Bresenham parameters 
`realedge:
	{
	push	v2, rz						; Save subroutine return address
	jsr		_FloorDivMod
	}
	{
	mv_s	r30, r1								; R1 = denominator = dY
	sub		r8, >>#(-GLXYZSCREENSHIFT), r24		; Calculate x prestep
	}
	{
	st_s	#00, (acshift)						; Set acshift to 0
	sub		r9, >>#(-GLXYZSCREENSHIFT), r25		; Calculate y prestep
	subm	r8, r16, r0							; R0 = numerator = dX
	}
	
	{
	mv_s	r30, r4								; Move edge height into R4
	copy	r8, r3								; Move initial x into R3
	addm	r1, r1								; Set numerator to 2X remainder
	}
	; Check for left/right edge
	{
	pop		v2, rz								; Restore subroutine return address
	cmp		#00, r7								; Check for left or right edge
	}

	{
	ld_s	(_MPEPolygonGradient), v5[0]		; Load x components of gradient
	add		r4, r4, r5							; Set denominator to 2X edge height
	bra		ge, `leftedge
	}
	{
	ld_v	(_MPEPolygonColorGradient), v4		; Load dc/dX
	neg		r24									; Make x prestep positive
	}
	neg		r25									; Make y prestep positive

`rightedge:
	st_s	r26, (_MPEPolygonNextRightVertexPointer)	; Store next right vertex
	{
	st_v	v0, (_MPEPolygonRightEdge)			; Store right edge Bresenham parameters
	rts
	}
	st_s	r4, (_MPEPolygonRightEdgeExtra)		; Store height
	st_s	r5, (_MPEPolygonRightEdgeExtra+4)	; Store denominator

	// Calculate all Bresenham parameters and prestep them to integer coordinates
	// If you don't do this, you get HORRIBLE texture swim
`leftedge:
	{
	st_s	v1[0], (_MPEPolygonLeftEdgeExtra)			; Store height
	copy	v2[2], v1[0]								; Copy z into v1[0]
	}
	{
	st_s	v1[1], (_MPEPolygonLeftEdgeExtra+4)			; Store denominator
	mul		r0, v5[0], >>acshift, v1[1]					; Calculate first component of zStep
	}
	{
	ld_s	(_MPEPolygonGradient+16), v5[1]				; Load dz/dY
	}
	st_s	#00, (acshift)
	{
	st_s	v2[1], (_MPEPolygonY)						; Store current polygon y coordinate
	mul		r0, v4[0], >>acshift, v2[0]					; Calculate first component of cYStep
	}
	{
	asl		#16, v2[1], v2[2]
	mul		r0, v4[1], >>acshift, v2[1]					; Calculate first component of cCStep
	}
	{
	mul		r0, v4[2], >>acshift, v2[2]					; Calculate first component of cBStep
	mvr		v2[2], ry
	}
	mul		r0, v4[3], >>acshift, v2[3]					; Calculate first component of cAStep
	{
	st_v	v0, (_MPEPolygonLeftEdge)					; Store left edge Bresenham parameters	
	add		v5[1], v1[1]								; zStep complete
	mul		r24, v5[0], >>#GLXYZSCREENSHIFT, v5[0]		; Calculate dz/dX * xPrestep
	}
	{
	ld_v	(_MPEPolygonColorGradient+16), v0			; Load dc/dY
	lsl		#(30-GLXYZSCREENSHIFT), r24					; Convert xPrestep to 2.30 fp number									
	}
	{
	st_s	r26, (_MPEPolygonNextLeftVertexPointer)		; Store next left vertex
	add		v5[0], v1[0]								; z1 = z + dz/dx * xPrestep
	mul		r25, v5[1], >>#GLXYZSCREENSHIFT, v5[1]		; Calculate dz/dY * yPrestep
	}
	lsl		#(30-GLXYZSCREENSHIFT), r25					; Convert yPrestep to 2.30 fp number
	{
	add		v5[1], v1[0]								; z1 complete
	mul_sv	r24, v4, >>#30, v4							; Calculate dc/dx * xPrestep
	}
	{
	st_v	v1, (_MPEPolygonLeftEdge+16)				; Store z    zStep
	add		v0[0], v2[0]								; cYStep complete
	}
	{
	add		v0[1], v2[1]								; cCStep complete
	addm	v0[3], v2[3]								; cAStep complete
	}
	{
	add		v0[2], v2[2]								; cBStep complete
	mul_sv	r25, v0, >>#30, v0							; Calculate dc/dy * yPrestep
	}
	{
	rts
	st_v	v2, (_MPEPolygonLeftEdge+64)				; Store cStep
//	add_sv	v4, v3										; c1 = c + dc/dx * xPrestep
	}
//	add_sv	v0, v3										; c1 = c + dc/dx * xPrestep + dx/dy * yPrestep
	nop
	st_v	v3, (_MPEPolygonLeftEdge+48)				; Store c
	
;---------------------------------------------------------------------------------------




	; Move onto next polygon or clean up if done
`EndPolygon:
	pop		v7, rz							; Restore subroutine return
`EndPolygon1:
	ld_s	(_MPEPolygonVertices), r0		; Load current vertex count
	ld_s	(_MPEPolygonVertex), r1			; Load current vertex pointer
	sub		#01, r0							; Decrement vertex count
	{
	ld_v	(r1), v1						; Load 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex counter
	}
	{
	ld_v	(r1), v2						; Load 1st vertex C
	add		#16, r1							; Increment 1st vertex counter
	}
	st_s	r1, (_MPEPolygonVertex)			; Store new 1st vertex pointer
	cmp		#3, r0							; Check for last triangle
	{
	bra		ge, `PolygonLoop				; Jump if more triangles to rasterize
	st_s	r0, (_MPEPolygonVertices)		; Store new vertex count
	}
	{
	st_v	v1, (r1)						; Store 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex pointer
	}
	st_v	v2, (r1)
	
	; Clean up and exit
`RasterDone:
	rts		nop

.align.sv
_RasterCB2_end:


.module RasST

	X0 = v7				// Vertex 0 vector
	x0 = r28
	y0 = r29
	z0 = r30
	w0 = r31
	X1 = v6				// Vertex 1 vector
	x1 = r24
	y1 = r25
	z1 = r26
	w1 = r27
	X2 = v5				// Vertex 2 vector
	x2 = r20
	y2 = r21
	z2 = r22
	w2 = r23
	S0 = v2
	s0 = r8
	t0 = r9
	a0 = r10
	b0 = r11
	S1 = v3
	s1 = r12
	t1 = r13
	a1 = r14
	b1 = r15
	S2 = v4
	s2 = r16
	t2 = r17
	a2 = r18
	b2 = r19
	C0 = v2
	C1 = v3
	C2 = v4


.export _RasterST_size
	_RasterST_size = rb1_end - rb1_start
.export _RasterST
.import _FloorDivMod
.import _MPEMDMACmdBuf
.import _MPEPolygonGradient
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEPolygonVertex
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPEPolygonLeftEdgeExtra
.import _MPEPolygonRightEdgeExtra
.import _MPEPolygonEdgeExtra
.import _MPEPolygonX
.import _MPEPolygonY
.import _MPEPolygonDMASize
.import _MPEPolygonDMASourcePointer
.import _MPEPolygonPixelPointer
.import _MPESDRAMPointer
.import _MPEDMAFlags
.import _MPETextureParameter
.import _MPEPolygonScanlineRemainder
.import _MPEPolygonScanlineRecipLUT
.import _MPEPolygonScanlineValues
;.import _MPEPolygonScanlineX
.import _MPEPolygonNextLeftVertexPointer
.import _MPEPolygonNextRightVertexPointer
.import _MPERecipLUT
.align.sv
rb1_start:
_RasterST:
	mv_s	#_MPEPolygonVertexList, r0				; Initialize vertex list
	st_s	r0, (_MPEPolygonVertex)					; Kludge a 3 vertex polygon

	; Calculate Gradients from any 3 vertices (optimized for trivial accept)
	; Affects all registers

`PolygonLoop:
	ld_s	(_MPEPolygonVertex), r0
	nop

	; Stage 1, load data for triangle and calculate dV0 AND dV1
	{
	ld_v 	(r0), X2						; Load vertex 0 xyz1/w
	add		#16, r0							; Increment vertex pointer					
	}
	{
	ld_v	(r0), S2						; Load vertex 0 uvC
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X0						; Load vertex 2 xyz1/w
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v 	(r0), S0						; Load vertex 2 uvC
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X1						; Load vertex 1 xyz1/w
	add		#16, r0							; Increment vertex pointer
	subm	x2, x0							; Calculate x0 - x2		
	}
	{
	ld_v 	(r0), S1					; Load vertex 1 uvC
	sub		y2, y0						; Calculate y0 - y2
	subm	w2, w0						; Calculate 1/w0 - 1/w2
	}
	

	; Calculate dX, dY d(s/w), d(t/w), d(1/w) and dZ
	{
	st_s	#GLXYZSCREENSHIFT, (acshift)	; Set acshift for dX products	
	sub		x2, x1							; Calculate x1 - x2
	subm	y2, y1							; Calculate y1 - y2
	}
	{
	msb		w0, r7							; R7 holds 1/w0 - 1/w2 MSB
	mul		x1, y0, >>acshift, x2			; X2 now contains (x1 - x2) * (y0 - y2)
	}

	{
	sub		w2, w1							; Calculate 1/w1 - 1/w2
	mul		x0, y1, >>acshift, y2			; Y2 now contains (x0 - x2) * (y1 - y2)
	}

	sub		z2, z1							; Calculate z1 - z2

	{
	sub		y2, x2, r0						; R1 now contains dX or signed area
	subm	z2, z0							; Calculate z0 - z2
	}

	{
	bra		le, `EndPolygon1				; If signed area < 0, skip polygon
	abs		r0								; Insure 1/dX denominator is positiive
	}

	{
	msb		r0, r1							; Calculate dX MSB
	subm	s2, s1							; Calculate s1/w1 - s2/w2
	}
	
	{
	sub		#08, r1, r2						; R2 holds index shift for 1/dX
	subm	s2, s0							; Calculate s0/w0 - s2/w2
	}

	{
	mv_s	#_MPERecipLUT-128, r4			; R4 holds Reciprocal LUT pointer	
	ls		r2, r0, r3						; Convert dX into index offset
	subm	t2, t1							; Calculate t1/w1 - t2/w2
	}

	{
	mv_s	#$40000000, r3					; R3 holds unsigned LUT value conversion mask
	msb		w1, a0							; R6 holds 1/w1 - 1/w2 MSB
	addm	r3, r4							; R4 holds pointer to reciprocal LUT value
	}

	{
	ld_b	(r4), r5						; Load 8 bit reciprocal LUT value
	msb		w0, b0							; R7 holds 1/w0 - 1/w2 MSB
	subm	t2, t0							; Calculate t0/w0 - t2/w2
	}

	cmp		a0, b0							; Check for greatest d(1/w) MSB

	{
	bra		ge, `b0greater					; Branch if latter MSB is greater
	or		r5, >>#2, r3					; Convert 8 bit LUT value to 32 bit scalar
	}
	
	{
	msb		z1, a1							; Calculate z1 - z2 MSB
	mul		r3, r0, >>r1, r0				; Calculate xy
	}

	{
	mv_s	#$7fffffff, r4					; R4 holds TWO
	msb		z0, b1							; Calculate z0 - z2 MSB
	}

	mv_s	a0, b0							; d(1/w) MSB complete
`b0greater:
	msb		s1, a2							; Calculate s1/w1 - s2/w2 MSB
	{
	add		#(36-GLXYZSCREENSHIFT), r2		; Adjust 1/dX answer shift
	subm	r0, r4, r0		
	}

	{
	cmp		a1, b1							; Check for greater d(1/z) MSBs
	mul		r3, r0, >>r2, r0				; 1/dX complete
	}

	{
	bra		ge, `b1greater, nop				; Branch if latter MSB is greater
	msb		s0, b2							; Calculate s0/w0 - s2/w2 MSB 	
	}

	mv_s	a1, b1							; dz MSB complete
`b1greater:
	cmp		#20, b0							; Check if MSB of d(1/w) > 20
	{
	bra		le, `nowoverflow				; Jump if no overflow
	neg		r0								; Remove if signed area > 0
	}
	{
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default preshift value for multiplication
	msb		t1, a0							; Calculate t1/w1 - t0/w0 MSB
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default postshift value for multiplication
	msb		t0, a1							; Calculate t0/w0 - t2/w2 MSB
	}

	add		#GLXYZSCREENSHIFT-20, b0, r1	; R1 holds adjusted d(1/w) preshift
	sub		b0, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted d(1/w) postshift
`nowoverflow:
	{
	cmp		a2, b2							; Check for greater of d(s/w) MSBs
	st_s	r1, (acshift)					; Set preshift
	}
	{
	bra		ge, `b2greater					; Branch if latter MSB greater
	mul		w1, y0, >>acshift, w2			; w2 holds (1/w1 - 1/w2) * (y0 - y2)
	}
	mul		w0, y1, >>acshift, r7			; R7 holds (1/w0 - 1/w2) * (y1 - y2)
	{
	cmp		a0, a1							; Check for greater of d(t/w) MSBs
	mul		w0, x1, >>acshift, r3			; R3 holds (1/w0 - 1/w2) * (x1 - x2)
	}
	
	mv_s	a2, b2							; d(s/w) MSB complete
`b2greater:
	{
	bra		ge, `a1greater					; Branch if latter MSB greater
	sub		w2, r7							; R7 holds (1/w0 - 1/w2) * (y1 - y2) - (1/w1 - 1/w2) * (y0 - y2)
	mul		x0, w1, >>acshift, w2			; W2 holds (1/w1 - 1/w2) * (x0 - x2)
	}
	mul		r0, r7, >>r2, r7				; d(1/w)/dX complete
	cmp		#20, b1							; Check if mSB of dZ > 20
 
	mv_s	a0, a1							; A1 holds d(t/z) MSB
`a1greater:
	{
	bra		le, `nozoverflow				; Jump if MSB <=20
	subm	r3, w2							; w2 holds (1/w1 - 1/w2) * (x0 - x2) - (1/w0 -1/w2) * (x1 - x2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default dZ preshift
	mul		r0, w2, >>r2, w2				; d(1/w)/dY complete
	}
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default postshift value for multiplication

	add		#GLXYZSCREENSHIFT-20, b1, r1	; R1 holds adjusted dZ preshift
	sub		b1, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted dZ postshift
`nozoverflow:
	{
	cmp		#20, b2							; Check d(s/z) MSB for overflow
	st_s	r1, (acshift)					; Set dz preshift
	}
	{
	bra		le, `nosoverflow				; Branch if MSB <= 20
	mul		z1, y0, >>acshift, x2			; x2 contains (z1 - z2) * (y0 - y2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, w0			; w0 holds default d(s/w) preshift
	mul		z0, y1, >>acshift, r4			; R4 contains (z0 - z2) * (y1 - y2)
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, w1			; w1 holds default d(s/w) postshift
	mul		z0, x1, >>acshift, r3			; R3 holds (z0 - z2) * (x1 - x2)
	}

	add		#GLXYZSCREENSHIFT-20, b2, w0	; w0 holds adjusted d(s/w) preshift
	sub		b2, #GLINVDXSCREENSHIFT+20, w1	; w1 holds adjusted d(s/w) postshift
`nosoverflow:
	{
	sub		x2, r4							; R4 holds (z0 - z2) * (y1 - y2) - (z1 - z2) * (y0 - y2)
	mul		z1, x0, >>acshift, x2 			; X2 holds (z1 - z2) * (x0 - x2)
	}
	{
	cmp		#20, a1							; Check d(t/w) MSB for overflow
	st_s	w0, (acshift)					; Set d(s/w) preshift
	mul		r0, r4, >>r2, r4				; R4 holds dz/dX
	}
	{
	bra		le, `notoverflow				; Branch if MSB <= 20
	sub		r3, x2							; X2 contains (z1 - z2) * (x0 - x2) - (z0 - x2) * (x1 - x2)
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default d(t/w) preshift
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default d(t/w) postshift
	mul		r0, x2, >>r2, x2				; x2 holds dz/dY
	}
	mul		s1, y0, >>acshift, y2			; Y2 contains (s1/w1 - s2/w2) * (y0 - y2)
	
	add		#GLXYZSCREENSHIFT-20, a1, r1	; R1 holds adjusted d(t/w) preshift
	sub		a1, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted d(t/w) postshift
`notoverflow:
	mul		s0, y1, >>acshift, r5			; R5 contains (s0/w0 - s2/w2) * (y1 - y2)
	mul		s0, x1, >>acshift, r3			; R3 contains (s0/w0 - s2/w2) * (x1 - x2)
	{
	st_s	r1, (acshift)					; Set d(t/w) preshift
	sub		y2, r5							; R5 holds (s0/w0 - s2/w2) * (y1 - y2) - (s1/w1 - s2/w2) * (y0 - y2)
	mul		s1, x0, >>acshift, y2			; Y2 contains (s1/w1 - s2/w2) * (x0 - x2)	
	}
	mul		r0, r5, >>w1, r5				; d(s/w)/dX complete
	{
	sub		r3, y2							; Y2 holds (s1/w1 - s2/w2) * (x0 - x2) - (s0/w0 - s2/w2) * (x1 - x2)
	mul		t1, y0, >>acshift, z2			; Z2 contains (t1/w1 - t2/w2) * (y0 - y2)	
	}
	mul		r0, y2, >>w1, y2				; d(s/w)/dY complete
	mul		t0, y1, >>acshift, r6			; R6 contains (t0/w0 - t2/w2) * (y1 - y2)
	mul		t0, x1, >>acshift, r3			; R3 contains (t0/w0 - t2/w2) * (x1 - x2)
	{
	sub		z2, r6							; R6 holds (t0/w0 - t2/w2) * (y1 - y2) - (t1/w1 - t2/w2) * (y0 - y2)
	mul		t1, x0, >>acshift, z2			; Z2 contains (t1/w1 - t2/w2) * (x0 - x2)
	}
	mul		r0, r6, >>r2, r6				; R6 contains d(t/w)/dX
	sub		r3, z2							; Z2 holds (t1/w1 - t2/w2) * (x0 - x2) - (t0/w0 - t2/w2) * (x1 - x2)
	{
	st_v	v1, (_MPEPolygonGradient)		; Store dX component of polygon gradient
	mul		r0, z2, >>r2, z2				; Z2 contains d(t/w)/dY
	}
	nop
	st_v	X2, (_MPEPolygonGradient+16)	; Store dY component of polygon gradient

	; Calculate color gradient (later SML 9/28/98)
	{
	ld_s	(_MPEPolygonVertex), r1	
	mul		r0, y0, >>#GLINVDXSCREENSHIFT, y0		; Calculate (y0 - y2) / ((x1 - x2) * (y0 - y2) - (x0 - x2) * (y1 - y2))
	}
	mul		r0, y1, >>#GLINVDXSCREENSHIFT, y1		; Calculate (y1 - y2) / ((x1 - x2) * (y0 - y2) - (x0 - x2) * (y1 - y2))
	add		#24, r1
	{
	ld_sv	(r1), C2
	add		#32, r1
	mul		r0, x0, >>#GLINVDXSCREENSHIFT, x0		; Calculate (x0 - x2) / ((x1 - x2) * (y0 - y2) - (x0 - x2) * (y1 - y2))
	}
	{
	ld_sv	(r1), C0
	add		#32, r1
	mul		r0, x1, >>#GLINVDXSCREENSHIFT, x1		; Calculate (x1 - x2) / ((x1 - x2) * (y0 - y2) - (x0 - x2) * (y1 - y2))
	}
	ld_sv	(r1), C1
	sub_sv	C2, C0
	{
	mv_v	C0, v5
	sub_sv	C2, C1
	mul_sv	y1, C0, >>#30, C0	
	}
	{
	mv_v	C1, C2
	mul_sv	y0, C1, >>#30, C1
	}
	mul_sv 	x1, v5, >>#30, v5
	mul_sv	x0, C2, >>#30, C2
	sub_sv	C1, C0
	{
	st_v	C0, (_MPEPolygonColorGradient)		; Store dC/dX
	sub_sv	v5, C2
	}
	st_v	C2, (_MPEPolygonColorGradient+16)	; Store dC/dY
	
	; All registers free
	
	; Calculate any additional reciprocal(s) (which only occur if clipping occurred
	; or somebody slipped us a polygon rather than a triangle)


	; Rasterization equates
	y = r30						; Current y
	leftVertex = r31			; Current left vertex
	rightVertex = r29			; Current right vertex
	
	; Find top vertex
	mv_s	#$7fffffff, y						; Set yTop to maximum
	ld_s	(_MPEPolygonVertex), r31			; Initial vertex pointer
	lsl		#01, y, r27							; Set R27 to yMin 
	{
	mv_s	#3, r28								; Load vertex count
	add		#04, r31							; Increment vertex pointer to y
	}
	mv_s	r31, r29							; Copy vertex pointer

`topsearch:
	ld_s	(r31), r0							; Load vertex y
	nop
	cmp		y, r0								; Check if new minimum y
	{
	bra		gt, `nonewminvertex, nop			; Jump if vertex is definitely not at top
	cmp		y, r27								; Check for new maximum y
	}

	; New minimum  y/vertex
	mv_s	r31, r29							; Copy current vertex into top vertex pointer
	mv_s	r0, y								; Copy current vertex y into minimum y pointer
`nonewminvertex:
	{
	bra		ge, `nonewmaxvertex, nop			; Jump if no new max y
	sub		#01, r28							; Decrement vertex count
	}

	mv_s	y, r27								; Set R27 to new yMax
`nonewmaxvertex:
	bra		ne, `topsearch						; Jump if more vertices to check
	add		#32, r31
	nop

	{
	mv_s	#32, r1								; Set increment input to left vertex
	sub		#04, r29							; Make vertex pointer point to vertex again
	}
	{
	mv_s	r29, r31							; Set current vertices to same vertex
	copy	r29, r0								; Set left vertex pointer for subroutine
	}

	; Prepare initial left edge
	push	v7, rz								; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge, nop
	ld_s	(pcexec), r2
	}

	; Prepare initial right edge
	{
	bra		`PrepareEdge
	mv_s	#-32, r1
	copy	r31, r0
	}
	ld_s	(pcexec), r2
	nop
	pop		v7, rz						; Restore edge pointers and subroutine return

	; Walk left and right edges and fire off scanlines
`WalkLoop:

	; Walk a scanline
	ld_s	(_MPEPolygonDMASourcePointer), r0	; R0 points to current DMA cache
	ld_v	(_MPEPolygonLeftEdge), v7			; Load left edge parameters
	st_s	r0, (_MPEPolygonPixelPointer)		; Store initial pixel destination pointer
	ld_v	(_MPEPolygonRightEdge), v4			; Load right edge parameters
	ld_v	(_MPEPolygonLeftEdge+32), v5		; Load additional left edge stuff
	{
	ld_v	(_MPEPolygonLeftEdge+16), v6		; Load final batch of left edge stuff
	sub		v7[3], v4[3], v3[0]					; Calculate scanline width
	subm	v3[1], v3[1]						; Set scanline remainder to 0
	}

`CalculateDMASize:
	{
	ld_v	(_MPEPolygonGradient), v4			; Read x components of gradient
	bra		le, `StepLeftEdge					; Jump if zero width scanline
	cmp		#64, v3[0]							; Check for maximum DMA length
	}	
	{
	bra		le, `CalculateStepSize
	st_s	v3[0], (rc1)						; Store scanline size in DMA countdown
	abs		v6[2]								; Insure 1/w is positive
	}
	{
	st_s	v7[3], (_MPEPolygonX)				; Store DMA starting x
	msb		v6[2], r1							; Calculate MSB of left 1/w
	}
	st_s	v3[0], (_MPEPolygonDMASize)			; Store likely DMA size

	mv_s	#64, r2
	st_s	r2, (rc1)							; Scanline bigger than 64 pixels
	st_s	r2, (_MPEPolygonDMASize)			; Store maximum DMA size

`CalculateStepSize:
	cmp		#GLMAXSUBDIVISION, v3[0]			; Check for subdivided affine steps
	{
	bra		le, `OneBigStep
	mv_s	#_MPERecipLUT-128, v3[2]			; V3[2] holds pointer to reciprocal lookup table
	sub		#08, r1, r2							; Calculate 1/w index shift
	}
	{
	mv_s	#$40000000, r4						; R4 holds reciprocal sign conversion mask
	}
	ls		r2, v6[2], r3						; Convert 1/w into index offset

	{
	mv_s	#GLMAXSUBDIVISION, v3[0]			; Set scanline segment to maximum
	sub		#GLMAXSUBDIVISION, v3[0], v3[1]		; Calculate scanline remainder
	}
`OneBigStep:
	; OK
	; Calculate 1/1/w
	{
	mv_s	#$7fffffff, r0							; R0 holds 2.30 2
	add		v3[2], r3								; R3 holds index into reciprocal look-up
	mul		v3[0], v4[3], >>#0, v4[3]				; Calculate d(1/w)
	}
	{
	ld_b	(r3), r3								; R3 holds LUT value
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, r2		; Adjust shift value
	mul		v3[0], v4[0], >>#0, v4[0]				; Calculate dz
	}
	{
	st_s	v3[1], (_MPEPolygonScanlineRemainder)	; Store scanline remainder
	add		v6[2], v4[3]							; V4[3] = ending 1/w
	mul		v3[0], v4[1], >>#0, v4[1]				; Calculate d(s/w)
	}
	{
	mv_s	r4, v3[1]								; Save reciprocal sign conversion mask
	or		r3, >>#2, r4							; Convert reciprocal to unsigned quantity
	mul		v3[0], v4[2], >>#0, v4[2]				; Calculate d(t/w)
	}												; Ending 1/w can be outside polygon!
	{
	mv_s	v4[3], r5								; Save unsigned ending 1/w
	add		v6[0], v4[0]							; v4[0] = ending z
	mul		r4, v6[2], >>r1, v6[2]					; Calculate xy
	}
	{
	ld_s	(_MPETextureParameter), v7[2]			; V7[2] holds t shift (and texture parameter)
	abs		r5										; Make ending 1/w positive
	}
	{
	msb		r5, r1									; Calculate MSB of ending 1/w
	subm	v6[2], r0, v6[2]						; V5[0] = 2-xy
	}
	{
	sub		#08, r1, v3[3]							; V3[3] holds index shift
	addm	v5[0], v4[1]							; V4[1] = ending s/w
	}
	lsr		#08, v7[2], v7[1]						; V7[1] holds s shift	
	{
	ls		v3[3], r5, r3							; R3 holds index offset
	mul		r4, v6[2], >>r2, v6[2]					; V6[2] holds starting w
	}
	add		r3, v3[2], r3							; R3 now holds index to LUT
	{
	ld_b	(r3), r3								; Load LUT value	
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, v3[3]		; Adjust index shift value
	mul		v6[2], v5[0], >>v7[1], v5[0]			; Calculate starting s
	}
	{
	add		v5[1], v4[2]							; V4[2] = ending t/w
	mul		v6[2], v5[1], >>v7[2], v5[1]			; Calculate starting t
	}
	{
	st_s	v5[0], (rx)								; Store starting s in rx
	or		r3, >>#2, v3[1]							; Convert LUT value to unsigned quantity
	}
	{
	st_s	v5[0], (ru)								; Store starting s in ru
	mul		v3[1], r5, >>r1, r5						; Calculate xy
	}
	{
	cmp		#00, v4[3]								; Check if ending 1/w is positive
	st_s	v5[1], (ry)								; Store starting t in ry
	}
	{
	bra		ge, `positiveendingw
	mv_s	#_MPEPolygonScanlineRecipLUT-2, v7[0]	; V7[0] points to scanline Recip LUT
	subm		r5, r0, r5							; Calculate 2-xy
	}
	{
	st_s	v5[1], (rv)								; Store starting t in rv
	add		v3[0], >>#-1, v7[0]						; V7[0] points to 16 bit reciprocal
	mul		v3[1], r5, >>v3[3], r5					; R5 contains ending w
	}
	ld_w	(v7[0]), v7[0]							; V3 contains 1/dX	
	
	neg		r5										; Sign flip ending w
`positiveendingw:
	{
	st_v	v4, (_MPEPolygonScanlineValues)			; Store raster end values
	sub		v6[0], v4[0], v1[3]						; V3[1] contains dz
	mul		r5, v4[1], >>v7[1], v4[1]				; Calculate ending s
	}
	{
	ld_s	(_MPEPolygonPixelPointer), v0[3]		; Load current DMA destination pointer
	lsr		#01, v7[0]								; Convert 1/dX to unsigned quantity
	mul		r5, v4[2], >>v7[2], v4[2]				; Calculate ending t
	}
	{
	st_s	v3[0], (rc0)							; Store pixel count in rc0
	sub		v5[0], v4[1], v2[3]						; V2[3] contains ds
	mul		v7[0], v1[3], >>#32, v1[3]				; v3[1] contains dz/dX
	}
	{
	mv_s	v6[0], v6[3]							; V6[3] contains starting z
	sub		v5[1], v4[2], v3[3]						; V3[3] contains dt
	mul		v7[0], v2[3], >>#32, v2[3]				; V2[3] contains ds/dX
	}
	mul		v7[0], v3[3], >>#32, v3[3]				; V3[3] contains dt/dX
	

	; Generic rasterization loop
	; Place pre loop stuff just after `RasterPreLoop, the loop just past 
	; `RasterLoop, and the post loop stuff just after `RasterPostLoop
	;
	; Register Equates
	; v0[3] = destination z
	; v1[3] = dz/dx
	; v2[3] = ds/dx
	; v3[3] = dt/dx
	; v6[3] = DMA destination pointer
	; rx/ru = starting texture s
	; ry/rv = starting texture t
	; rc0 = pixel countdown
	; rc1 = DMA countdown
	;
	; You may trash any registers except for v6[3] and rc1

	; Local equates
	p00 = v0
	p01 = v1
	p10 = v2
	p11 = v3
	p1 = v5
	p2 = v6
	c = v7

`RasterPreLoop:
	dec		rc0									; Predecrement pixel countdown

	; Basic bilerped t-mapping loop
`RasterLoop:
	{
	bra		c0ne, `RasterLoop					; 3 cycle loop
	ld_p	(xy), v6							; Load source pixel
	addr	v2[3], rx							; Increment texture s
	dec		rc1									; Decrement DMA countdown
	}
	{
	addr	v3[3], ry							; Increment texture t
	dec		rc0									; Decrement pixel countdown
	}
	{
	st_pz	v6, (v0[3])							; Store texel
	add		#04, v0[3]							; Increment DMA destination pointer
	addm	v1[3], v6[3]						; Increment pixel z
	}
	
`RasterPostLoop:

`DMACheck:
	{
	ld_v	(_MPEPolygonScanlineValues), v3		; Load current scanline stuff
	bra		c1eq, `DMAwait
	sub		r0, r0								; Set r0 to zero for addm copying
	}
	nop	
	{
	mv_s	v3[0], v6[0]							; Copy in current z
	copy	v3[1], v5[0]							; Copy in current s/w
	addm	r0, v3[2], v5[1]						; Copy in current t/w
	}
	{	
	bra		`CalculateStepSize
	ld_v	(_MPEPolygonGradient), v4			; Read x components of gradient
	abs		v3[3]								; Insure 1/w is positive
	subm	v3[1], v3[1]						; Zero scanline remainder
	}
	{
	ld_s	(_MPEPolygonScanlineRemainder), v3[0]	; Copy in remaining dX
	msb		v3[3], r1							; Calculate MSB of current 1/w
	addm	r0, v3[3], v6[2]					; Copy in current left 1/w
	}
	st_s	v0[3], (_MPEPolygonPixelPointer)		; Store updated DMA destination pointer

`DMAwait:
	ld_s	(mdmactl), r0							; Read DMA control register
	ld_s	(_MPEPolygonScanlineRemainder), r7		; Load scanline remainder
	and		#$f, r0									; Check for DMA activity
	bra		ne, `DMAwait

`DoDMA:
	ld_s	(_MPEPolygonDMASourcePointer), r4
	ld_s	(_MPEPolygonX), r2
	ld_s	(_MPEPolygonDMASize), r5
	ld_s	(_MPEPolygonY), r3
	{
	ld_s	(_MPEDMAFlags), r0
	lsl		#16, r5
	addm	r2, r5, r6					; Increment polygon X
	}
	{
	ld_s	(_MPESDRAMPointer), r1
	bset	#16, r3						; YPOS input complete
	}
	{
	st_s	r4, (_MPEMDMACmdBuf+16)
	or		r5, r2						; XPOS input complete
	}
	{
	st_v	v0, (_MPEMDMACmdBuf)
	eor		#DMA_CACHE_EOR, r4			; Flip DMA buffers
	}
	st_s	#_MPEMDMACmdBuf, (mdmacptr)

`CheckScanlineRemainder:
	{
	cmp		#00, r7										; Check if any pixels are left on scanline
	st_s	r6, (_MPEPolygonX)							; Store updated polygon x
	}
	{
	st_s	r4, (_MPEPolygonDMASourcePointer)			; Store updated polygon DMA pointer
	bra		eq, `StepLeftEdge							; Branch if at end of scanline
	}
	{
	bra		`CalculateDMASize
	mv_s	r6, v7[3]									; Copy left current x into v7[3]
	abs		v6[2]										; Insure 1/w is positive
	subm	v3[1], v3[1]								; Zero scanline remainder
	}
	{
	mv_s 	v3[3], v6[2]								; Copy in current left 1/w
	msb		v3[3], r1									; Calculate MSB of current 1/w
	}
	{
	st_s	r4, (_MPEPolygonPixelPointer)				; Reset pixel destination pointer
	copy	r7, v3[0]									; Copy remaining dX into v3[0]
	}

	; Increment left and right edges
`StepLeftEdge:
	ld_v	(_MPEPolygonLeftEdge), v7
	ld_v	(_MPEPolygonLeftEdge+16), v6
	{
	ld_v	(_MPEPolygonLeftEdge+32), v5	
	add		v7[1], v7[2]						; Increment left errorTerm
	addm	v7[0], v7[3]						; Increment left x
	}
	{
	ld_s	(_MPEPolygonY), r0					; Load current polygon y
	bra		le, `NoLeftOverflow					; Branch if errorTerm < 0
	}
	{
	ld_v	(_MPEPolygonEdgeExtra), v4			; Load height/denominators for both edges
	add		v6[1], v6[0]						; Increment z
	addm	v5[2], v5[0]						; Increment s/w
	}
	{
	ld_v	(_MPEPolygonGradient), v2			; Load x component of gradient
	add		v5[3], v5[1]						; Increment t/w
	addm	v6[3], v6[2]						; Increment 1/w
	}

`LeftOverFlow:
	{
	add		#01, v7[3]							; Increment x
	subm	v4[1], v7[2]						; Reset error term
	}

	{
	add		v2[0], v6[0]						; Increment z
	addm	v2[1], v5[0]						; Increment s/w
	}
	{
	add		v2[2], v5[1]						; Increment t/w
	addm	v2[3], v6[2]						; Increment 1/w
	}

`NoLeftOverflow:
	{
	st_v	v7, (_MPEPolygonLeftEdge)		; Store updated left edge info
	sub		#01, v4[0]						; Decrement height
	}
	{
	st_v	v6, (_MPEPolygonLeftEdge+16)	; Store updated left edge info
	}
	{
	bra		gt, `StepRightEdge
	st_v	v5, (_MPEPolygonLeftEdge+32)	; Store updated left edge info
	add		#01, r0							; Increment polygon y
	}
	st_v	v4, (_MPEPolygonEdgeExtra)		; Store updated height/denominator
	st_s	r0, (_MPEPolygonY)				; Store updated polygon y

	; Prepare next left edge
	push	v7, rz										; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge								; Jump to edge calculation routine
	mv_s	#32, r1										; Set vertex increment to positive
	}
	ld_s	(pcexec), r2								; Load return address
	ld_s	(_MPEPolygonNextLeftVertexPointer), r0		; Load next vertex pointer
	pop		v7, rz
	
`StepRightEdge:
	ld_v	(_MPEPolygonRightEdge), v7			; Load right edge data
	ld_v	(_MPEPolygonEdgeExtra), v6			; Load height/denominator
	{
	add		v7[1], v7[2]						; Increment right errorTerm
	addm	v7[0], v7[3]						; Increment right x
	}
	bra		le, `NoRightOverflow, nop			; Branch if errorTerm < 0
	{
	add		#01, v7[3]							; Increment x
	subm	v6[3], v7[2]						; Reset errorTerm
	}

`NoRightOverflow:
	{
	st_v	v7, (_MPEPolygonRightEdge)				; Store updated edge parameters
	sub		#01, v6[2]								; Decrement edge height
	}
	{
	bra		ne, `WalkLoop, nop						; Jump to main loop if more left
	st_v	v6, (_MPEPolygonEdgeExtra)				; Updated edge data complete
	add		#01, r0									; Increment polygon y
	}

	; Prepare next right edge
	push	v7, rz									; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge							; Jump to edge calculation routine
	mv_s	#-32, r1								; Set vertex increment to positive
	}
	ld_s	(pcexec), r2							; Load return address
	ld_s	(_MPEPolygonNextRightVertexPointer), r0	; Load next vertex pointer
	{
	bra		`WalkLoop, nop
	pop		v7, rz
	}

	; Subroutines

	; Prepares an edge, pass vertex pointer in R0
	; 32 for a right edge or -32 for a left edge in R1
	; and return address in R2
	; Next vertex pointer is returned in R0
	; Affects R0-R30!!!! (R31 must be unaffected SML 9/30/98)
`PrepareEdge:
	{
	st_s	#9, rc0								; Store maximum vertex count
	copy	r1, r7								; Wait on load and save increment
	}
	st_s	r2, (rz)								; Store return address
`PrepEdge:
	{
	bra		c0eq, `EndPolygon
	mv_s	#3, r27								; Read number of vertices
	}
	ld_s	(_MPEPolygonVertex), r28			; R28 points to MPE Polygon Vertex List
	{
	ld_v	(r0), v2							; Read x1, y1, z1, 1/w1
	add		#16, r0								; Increment vertex pointer to s1/z1, t1/z1 
	addm	r7, r0, r26 						; R26 now points to second vertex
	}
	{
	ld_v	(r0), v3							; Read s1/w1, t1/w1, C
	cmp		r28, r26							; Check for vertex underflow
	mul		#16, r27, >>#-1, r27				; Calculate 32 * vertices 
	}
	{
	bra		ge, `nounderflow					; Jump if no underflow
	copy	r9, r25								; Copy fixed point y1 into r25
	}
	{
	mv_s	r8, r24								; Copy fixed point x1 into R24
	add		r27, r28, r29						; R29 points past end of active vertices
	dec		rc0									; Decrement vertex search counter
	}
	mv_s	#((1<<GLXYZSCREENSHIFT)-1), r30		; R30 contains ceiling rounder

	add		r27, r26							; Wrap vertex around to end of list
`nounderflow:
	cmp		r29, r26							; Check for vertex pointer overflow
	bra		ne, `nooverflow, nop				; Jump if no overflow

	sub		r27, r26							; Wrap vertex around to beginning of list

`nooverflow:
	{
	ld_v	(r26), v4							; Read x2, y2, z2, 1/w2
	add		r30, r8								; Round up x1
	addm	r30, r9								; Round up y1
	}
	{
	ld_v	(_MPEPolygonGradient), v5			; Read gradient x stuff
	asr		#GLXYZSCREENSHIFT, r9				; Integer y1 complete
	}
	{
	add		r30, r16							; Round up x2
	addm	r30, r17							; Round up y2
	}
	{
	asr		#GLXYZSCREENSHIFT, r17				; Integer y2 complete
	mul		#1, r8, >>#GLXYZSCREENSHIFT, r8		; Integer x1 complete
	}
	{
	sub		r9, r17, r30						; R30 contains height of edge
	mul		#1, r16, >>#GLXYZSCREENSHIFT, r16	; Integer x2 complete
	}

	bra		mi, `EndPolygon, nop				; Jump if polygon end reached
	bra		ne, `realedge, nop					; Jump if not a flat edge

	; Flat edge, jump to next vertex and try again
	{
	bra		`PrepEdge, nop
	mv_s	r26, r0					; Set current vertex to next vertex	
	}
	
	; Genuine edge, calculate Bresenham parameters 
`realedge:
	{
	push	v2, rz						; Save subroutine return address
	jsr		_FloorDivMod
	}
	{
	mv_s	r30, r1								; R1 = denominator = dY
	sub		r8, >>#(-GLXYZSCREENSHIFT), r24		; Calculate x prestep
	}
	{
	st_s	#00, (acshift)						; Set acshift to 0
	sub		r9, >>#(-GLXYZSCREENSHIFT), r25		; Calculate y prestep
	subm	r8, r16, r0							; R0 = numerator = dX
	}

	{
	mv_s	r30, r4								; Move edge height into R4
	copy	r8, r3								; Move initial x into R3
	addm	r1, r1								; Set numerator to 2X remainder
	}
	; Check for left/right edge
	{
	pop		v2, rz								; Restore subroutine return address
	cmp		#00, r7								; Check for left or right edge
	}

	{
	ld_v	(_MPEPolygonGradient), v5			; Load x components of gradient
	add		r4, r4, r5							; Set denominator to 2X edge height
	bra		ge, `leftedge
	}
	neg		r24									; Make x prestep positive
	neg		r25									; Make y prestep positive

`rightedge:
	st_s	r26, (_MPEPolygonNextRightVertexPointer)	; Store next right vertex
	{
	st_v	v0, (_MPEPolygonRightEdge)			; Store right edge Bresenham parameters
	rts
	}
	st_s	r4, (_MPEPolygonRightEdgeExtra)		; Store height
	st_s	r5, (_MPEPolygonRightEdgeExtra+4)	; Store denominator

	// Calculate all Bresenham parameters and prestep them to integer coordinates
	// If you don't do this, you get HORRIBLE texture swim
`leftedge:
	{
	st_s	v1[0], (_MPEPolygonLeftEdgeExtra)			; Store height
	copy	v2[2], v1[0]								; Copy z into v1[0]
	mul		r0, v5[1], >>acshift, v2[2]					; Calculate first component of s/wStep
	}
	{
	st_s	v1[1], (_MPEPolygonLeftEdgeExtra+4)			; Store denominator
	copy	v3[0], v2[0]								; Copy s1/w1 into v2[0]
	mul		r0, v5[0], >>acshift, v1[1]					; Calculate first component of zStep
	}
	{
	ld_v	(_MPEPolygonGradient+16), v4				; Load y components of gradient
	copy	v2[3], v1[2]								; Copy 1/w1 into R20
	mul		r0, v5[2], >>acshift, v2[3]					; Calculate first component of t/wStep
	}
	{
	st_s	v2[1], (_MPEPolygonY)						; Store current polygon y coordinate
	copy	v3[1], v2[1]								; Copy t1/w1 into v2[1]
	mul		r0, v5[3], >>acshift, v1[3]					; Calculate first component of 1/wStep
	}
	{
	st_v	v0, (_MPEPolygonLeftEdge)					; Store left edge Bresenham parameters	
	add		v4[0], v1[1]								; zStep complete
	mul		r24, v5[0], >>#GLXYZSCREENSHIFT, v5[0]		; Calculate dz/dX * xPrestep
	}
	{
	st_s	r26, (_MPEPolygonNextLeftVertexPointer)		; Store next left vertex
	add		v4[1], v2[2]								; s/wStep complete
	mul		r24, v5[1], >>#GLXYZSCREENSHIFT, v5[1]		; Calculate d(s/w)/dX * xPrestep
	}
	{
	add		v4[2], v2[3]								; t/wStep complete
	mul		r24, v5[2], >>#GLXYZSCREENSHIFT, v5[2]		; Calculate d(t/w)/dX * xPrestep
	}
	{
	add		v4[3], v1[3]								; 1/wStep complete
	mul		r24, v5[3], >>#GLXYZSCREENSHIFT, v5[3]		; Calculate d(1/w)/dX * xPrestep
	}
	{
	add		v5[0], v1[0]								; z1 = z + dz/dx * xPrestep
	mul		r25, v4[0], >>#GLXYZSCREENSHIFT, v4[0]		; Calculate dz/dY * yPrestep
	}
	{
	add		v5[1], v2[0]								; s1/w1 = s1/w1 + d(s/w)/dX * xPrestep
	mul		r25, v4[1], >>#GLXYZSCREENSHIFT, v4[1]		; Calculate d(s/w)/dY * yPrestep
	}
	{
	add		v5[2], v2[1]								; t1/w1 = t1/w1 + d(t/w)/dX * xPrestep
	mul		r25, v4[2], >>#GLXYZSCREENSHIFT, v4[2]		; Calculate d(t/w)/dY * yPrestep
	}
	{
	add		v5[3], v1[2]								; 1/w1 = 1/w1 + d(1/w)/dX * xPrestep
	mul		r25, v4[3], >>#GLXYZSCREENSHIFT, v4[3]		; Calculate d(1/w)/dY * yPrestep
	}
	add		v4[0], v1[0]								; z1 complete
	{
	rts
	add		v4[3], v1[2]								; 1/w1 complete
	addm	v4[1], v2[0]								; s1/w1 complete
	}
	{
	st_v	v1, (_MPEPolygonLeftEdge+16)				; Store z    zStep 1/w     1/wStep
	add		v4[2], v2[1]								; t1/w1 complete
	}
	st_v	v2, (_MPEPolygonLeftEdge+32)				; Store s/w  t/w   s/wStep t/wStep


	; Move onto next polygon or clean up if done
`EndPolygon:
	pop		v7, rz							; Restore subroutine return
`EndPolygon1:
	ld_s	(_MPEPolygonVertices), r0		; Load current vertex count
	ld_s	(_MPEPolygonVertex), r1			; Load current vertex pointer
	sub		#01, r0							; Decrement vertex count
	{
	ld_v	(r1), v1						; Load 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex counter
	}
	{
	ld_v	(r1), v2						; Load 1st vertex uvC
	add		#16, r1							; Increment 1st vertex counter
	}
	st_s	r1, (_MPEPolygonVertex)			; Store new 1st vertex pointer
	cmp		#3, r0							; Check for last triangle
	{
	bra		ge, `PolygonLoop				; Jump if more triangles to rasterize
	st_s	r0, (_MPEPolygonVertices)		; Store new vertex count
	}
	{
	st_v	v1, (r1)						; Store 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex pointer
	}
	st_v	v2, (r1)
	
	; Clean up and exit
`RasterDone:
	rts		nop

.align.sv
rb1_end:


.module RasSTF


	X0 = v7				// Vertex 0 vector
	x0 = r28
	y0 = r29
	z0 = r30
	w0 = r31
	X1 = v6				// Vertex 1 vector
	x1 = r24
	y1 = r25
	z1 = r26
	w1 = r27
	X2 = v5				// Vertex 2 vector
	x2 = r20
	y2 = r21
	z2 = r22
	w2 = r23
	S0 = v2
	s0 = r8
	t0 = r9
	a0 = r10
	b0 = r11
	S1 = v3
	s1 = r12
	t1 = r13
	a1 = r14
	b1 = r15
	S2 = v4
	s2 = r16
	t2 = r17
	a2 = r18
	b2 = r19
	C0 = v2
	C1 = v3
	C2 = v4

.export _RasterSTF_size
	_RasterSTF_size = _RasterSTF_end - _RasterSTF
.export _RasterSTF
.import _FloorDivMod
.import _MPEMDMACmdBuf
.import _MPEPolygonGradient
.import _MPEPolygonScanlineValues
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEPolygonLeftEdge
.import _MPEPolygonRightEdge
.import _MPEPolygonX
.import _MPEPolygonY
.import _MPEPolygonDMASize
.import _MPEPolygonDMASourcePointer
.import _MPEPolygonPixelPointer
.import _MPESDRAMPointer
.import _MPEDMAFlags
.import _MPETextureParameter
.import _MPEPolygonScanlineRemainder
.import _MPEPolygonScanlineRecipLUT
.import _MPEPolygonNextLeftVertexPointer
.import _MPEPolygonNextRightVertexPointer
.import _MPERecipLUT
.align.s
_RasterSTF:
	mv_s	#_MPEPolygonVertexList, r0				; Initialize vertex list
	st_s	r0, (_MPEPolygonVertex)					; Kludge a 3 vertex polygon

	; Calculate Gradients from any 3 vertices (optimized for trivial accept)
	; Affects all registers
`PolygonLoop:
	ld_s	(_MPEPolygonVertex), r0
	nop

	; Stage 1, load data for triangle and calculate dV0 AND dV1
	{
	ld_v 	(r0), X2						; Load vertex 0 xyz1/w as X2
	add		#16, r0							; Increment vertex pointer					
	}
	{
	ld_v	(r0), S2						; Load vertex 0 uvC as S2
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X0						; Load vertex 1 xyz1/w as X0
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v 	(r0), S0						; Load vertex 1 uvC as S0
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X1						; Load vertex 2 xyz1/w as X1
	add		#16, r0							; Increment vertex pointer
	subm	x2, x0							; Calculate x0 - x2		
	}
	{
	ld_v 	(r0), S1					; Load vertex 2 uvC as S1
	sub		y2, y0						; Calculate y0 - y2
	subm	w2, w0						; Calculate 1/w0 - 1/w2
	}
	

	; Calculate dX, dY d(s/w), d(t/w), d(1/w) and dZ
	{
	st_s	#GLXYZSCREENSHIFT, (acshift)	; Set acshift for dX products	
	sub		x2, x1							; Calculate x1 - x2
	subm	y2, y1							; Calculate y1 - y2
	}
	{
	msb		w0, r7							; R7 holds 1/w0 - 1/w2 MSB
	mul		x1, y0, >>acshift, x2			; X2 now contains (x1 - x2) * (y0 - y2)
	}

	{
	sub		w2, w1							; Calculate 1/w1 - 1/w2
	mul		x0, y1, >>acshift, y2			; Y2 now contains (x0 - x2) * (y1 - y2)
	}

	sub		z2, z1							; Calculate z1 - z2

	{
	sub		y2, x2, r0						; R1 now contains dX or signed area
	subm	z2, z0							; Calculate z0 - z2
	}

	{
	bra		le, `EndPolygon1				; If signed area < 0, skip polygon
	abs		r0								; Insure 1/dX denominator is positiive
	}

	{
	msb		r0, r1							; Calculate dX MSB
	subm	s2, s1							; Calculate s1/w1 - s2/w2
	}
	
	{
	sub		#08, r1, r2						; R2 holds index shift for 1/dX
	subm	s2, s0							; Calculate s0/w0 - s2/w2
	}

	{
	mv_s	#_MPERecipLUT-128, r4			; R4 holds Reciprocal LUT pointer	
	ls		r2, r0, r3						; Convert dX into index offset
	subm	t2, t1							; Calculate t1/w1 - t2/w2
	}

	{
	mv_s	#$40000000, r3					; R3 holds unsigned LUT value conversion mask
	msb		w1, a0							; R6 holds 1/w1 - 1/w2 MSB
	addm	r3, r4							; R4 holds pointer to reciprocal LUT value
	}

	{
	ld_b	(r4), r5						; Load 8 bit reciprocal LUT value
	msb		w0, b0							; R7 holds 1/w0 - 1/w2 MSB
	subm	t2, t0							; Calculate t0/w0 - t2/w2
	}
	cmp		a0, b0							; Check for greatest d(1/w) MSB
	{
	bra		ge, `b0greater					; Branch if latter MSB is greater
	or		r5, >>#2, r3					; Convert 8 bit LUT value to 32 bit scalar
	}
	
	{
	msb		z1, a1							; Calculate z1 - z2 MSB
	mul		r3, r0, >>r1, r0				; Calculate xy
	}

	{
	mv_s	#$7fffffff, r4					; R4 holds TWO
	msb		z0, b1							; Calculate z0 - z2 MSB
	}

	mv_s	a0, b0							; d(1/w) MSB complete
`b0greater:
	msb		s1, a2							; Calculate s1/w1 - s2/w2 MSB
	{
	add		#(36-GLXYZSCREENSHIFT), r2		; Adjust 1/dX answer shift
	subm	r0, r4, r0		
	}

	{
	cmp		a1, b1							; Check for greater d(1/z) MSBs
	mul		r3, r0, >>r2, r0				; 1/dX complete
	}
	
	{
	bra		ge, `b1greater, nop				; Branch if latter MSB is greater
	msb		s0, b2							; Calculate s0/w0 - s2/w2 MSB 	
	}

	mv_s	a1, b1							; dz MSB complete
`b1greater:
	cmp		#20, b0							; Check if MSB of d(1/w) > 20
	{
	bra		le, `nowoverflow				; Jump if no overflow
	neg		r0								; Remove if signed area > 0
	}
	{
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default preshift value for multiplication
	msb		t1, a0							; Calculate t1/w1 - t0/w0 MSB
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default postshift value for multiplication
	msb		t0, a1							; Calculate t0/w0 - t2/w2 MSB
	}

	add		#GLXYZSCREENSHIFT-20, b0, r1	; R1 holds adjusted d(1/w) preshift
	sub		b0, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted d(1/w) postshift
`nowoverflow:
	{
	cmp		a2, b2							; Check for greater of d(s/w) MSBs
	st_s	r1, (acshift)					; Set preshift
	}
	{
	bra		ge, `b2greater					; Branch if latter MSB greater
	mul		w1, y0, >>acshift, w2			; w2 holds (1/w1 - 1/w2) * (y0 - y2)
	}
	mul		w0, y1, >>acshift, r7			; R7 holds (1/w0 - 1/w2) * (y1 - y2)
	{
	cmp		a0, a1							; Check for greater of d(t/w) MSBs
	mul		w0, x1, >>acshift, r3			; R3 holds (1/w0 - 1/w2) * (x1 - x2)
	}
	
	mv_s	a2, b2							; d(s/w) MSB complete
`b2greater:
	{
	bra		ge, `a1greater					; Branch if latter MSB greater
	sub		w2, r7							; R7 holds (1/w0 - 1/w2) * (y1 - y2) - (1/w1 - 1/w2) * (y0 - y2)
	mul		x0, w1, >>acshift, w2			; W2 holds (1/w1 - 1/w2) * (x0 - x2)
	}
	mul		r0, r7, >>r2, r7				; d(1/w)/dX complete
	cmp		#20, b1							; Check if mSB of dZ > 20
 
	mv_s	a0, a1							; A1 holds d(t/z) MSB

`a1greater:
	{
	bra		le, `nozoverflow				; Jump if MSB <=20
	subm	r3, w2							; w2 holds (1/w1 - 1/w2) * (x0 - x2) - (1/w0 -1/w2) * (x1 - x2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default dZ preshift
	mul		r0, w2, >>r2, w2				; d(1/w)/dY complete
	}
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default postshift value for multiplication

	add		#GLXYZSCREENSHIFT-20, b1, r1	; R1 holds adjusted dZ preshift
	sub		b1, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted dZ postshift
`nozoverflow:
	{
	cmp		#20, b2							; Check d(s/z) MSB for overflow
	st_s	r1, (acshift)					; Set dz preshift
	}
	{
	bra		le, `nosoverflow				; Branch if MSB <= 20
	mul		z1, y0, >>acshift, x2			; x2 contains (z1 - z2) * (y0 - y2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, w0			; w0 holds default d(s/w) preshift
	mul		z0, y1, >>acshift, r4			; R4 contains (z0 - z2) * (y1 - y2)
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, w1			; w1 holds default d(s/w) postshift
	mul		z0, x1, >>acshift, r3			; R3 holds (z0 - z2) * (x1 - x2)
	}

	add		#GLXYZSCREENSHIFT-20, b2, w0	; w0 holds adjusted d(s/w) preshift
	sub		b2, #GLINVDXSCREENSHIFT+20, w1	; w1 holds adjusted d(s/w) postshift
`nosoverflow:
	{
	sub		x2, r4							; R4 holds (z0 - z2) * (y1 - y2) - (z1 - z2) * (y0 - y2)
	mul		z1, x0, >>acshift, x2 			; X2 holds (z1 - z2) * (x0 - x2)
	}
	{
	cmp		#20, a1							; Check d(t/w) MSB for overflow
	st_s	w0, (acshift)					; Set d(s/w) preshift
	mul		r0, r4, >>r2, r4				; R4 holds dz/dX
	}
	{
	bra		le, `notoverflow				; Branch if MSB <= 20
	sub		r3, x2							; X2 contains (z1 - z2) * (x0 - x2) - (z0 - x2) * (x1 - x2)
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default d(t/w) preshift
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default d(t/w) postshift
	mul		r0, x2, >>r2, x2				; x2 holds dz/dY
	}
	mul		s1, y0, >>acshift, y2			; Y2 contains (s1/w1 - s2/w2) * (y0 - y2)
	
	add		#GLXYZSCREENSHIFT-20, a1, r1	; R1 holds adjusted d(t/w) preshift
	sub		a1, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted d(t/w) postshift
`notoverflow:
	mul		s0, y1, >>acshift, r5			; R5 contains (s0/w0 - s2/w2) * (y1 - y2)
	mul		s0, x1, >>acshift, r3			; R3 contains (s0/w0 - s2/w2) * (x1 - x2)
	{
	st_s	r1, (acshift)					; Set d(t/w) preshift
	sub		y2, r5							; R5 holds (s0/w0 - s2/w2) * (y1 - y2) - (s1/w1 - s2/w2) * (y0 - y2)
	mul		s1, x0, >>acshift, y2			; Y2 contains (s1/w1 - s2/w2) * (x0 - x2)	
	}
	mul		r0, r5, >>w1, r5				; d(s/w)/dX complete
	{
	sub		r3, y2							; Y2 holds (s1/w1 - s2/w2) * (x0 - x2) - (s0/w0 - s2/w2) * (x1 - x2)
	mul		t1, y0, >>acshift, z2			; Z2 contains (t1/w1 - t2/w2) * (y0 - y2)	
	}
	mul		r0, y2, >>w1, y2				; d(s/w)/dY complete
	mul		t0, y1, >>acshift, r6			; R6 contains (t0/w0 - t2/w2) * (y1 - y2)
	mul		t0, x1, >>acshift, r3			; R3 contains (t0/w0 - t2/w2) * (x1 - x2)
	{
	sub		z2, r6							; R6 holds (t0/w0 - t2/w2) * (y1 - y2) - (t1/w1 - t2/w2) * (y0 - y2)
	mul		t1, x0, >>acshift, z2			; Z2 contains (t1/w1 - t2/w2) * (x0 - x2)
	}
	mul		r0, r6, >>r2, r6				; R6 contains d(t/w)/dX
	sub		r3, z2							; Z2 holds (t1/w1 - t2/w2) * (x0 - x2) - (t0/w0 - t2/w2) * (x1 - x2)
	{
	st_v	v1, (_MPEPolygonGradient)		; Store dX component of polygon gradient
	mul		r0, z2, >>r2, z2				; Z2 contains d(t/w)/dY
	}
	nop
	st_v	X2, (_MPEPolygonGradient+16)	; Store dY component of polygon gradient

	; Calculate color gradient (later SML 9/28/98)

	; All registers free
	
	; Calculate any additional reciprocal(s) (which only occur if clipping occurred
	; or somebody slipped us a polygon rather than a triangle)


	; Rasterization equates
	y = r30						; Current y
	leftVertex = r31			; Current left vertex
	rightVertex = r29			; Current right vertex
	
	; Find top vertex
	mv_s	#$7fffffff, y						; Set yTop to maximum
	ld_s	(_MPEPolygonVertex), r31			; Initial vertex pointer
	lsl		#01, y, r27							; Set R27 to yMin 
	{
	mv_s	#3, r28								; Load vertex count
	add		#04, r31							; Increment vertex pointer to y
	}
	mv_s	r31, r29							; Copy vertex pointer

`topsearch:
	ld_s	(r31), r0							; Load vertex y
	nop
	cmp		y, r0								; Check if new minimum y
	{
	bra		gt, `nonewminvertex, nop			; Jump if vertex is definitely not at top
	cmp		y, r27								; Check for new maximum y
	}

	; New minimum  y/vertex
	mv_s	r31, r29							; Copy current vertex into top vertex pointer
	mv_s	r0, y								; Copy current vertex y into minimum y pointer
`nonewminvertex:
	{
	bra		ge, `nonewmaxvertex, nop			; Jump if no new max y
	sub		#01, r28							; Decrement vertex count
	}

	mv_s	y, r27								; Set R27 to new yMax
`nonewmaxvertex:
	bra		ne, `topsearch						; Jump if more vertices to check
	add		#32, r31
	nop

	{
	mv_s	#32, r1								; Set increment input to left vertex
	sub		#04, r29							; Make vertex pointer point to vertex again
	}
	{
	mv_s	r29, r31							; Set current vertices to same vertex
	copy	r29, r0								; Set left vertex pointer for subroutine
	}

	; Prepare initial left edge
	push	v7, rz								; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge, nop
	ld_s	(pcexec), r2
	}

	; Prepare initial right edge
	{
	bra		`PrepareEdge
	mv_s	#-32, r1
	copy	r31, r0
	}
	ld_s	(pcexec), r2
	nop
	pop		v7, rz						; Restore edge pointers and subroutine return

	; Walk left and right edges and fire off scanlines
`WalkLoop:

	; Walk a scanline
	ld_s	(_MPEPolygonDMASourcePointer), r0	; R0 points to current DMA cache
	ld_v	(_MPEPolygonLeftEdge), v7			; Load left edge parameters
	st_s	r0, (_MPEPolygonPixelPointer)		; Store initial pixel destination pointer
	ld_v	(_MPEPolygonRightEdge), v4			; Load right edge parameters
	ld_v	(_MPEPolygonLeftEdge+32), v5		; Load additional left edge stuff
	{
	ld_v	(_MPEPolygonLeftEdge+16), v6		; Load final batch of left edge stuff
	sub		v7[3], v4[3], v3[0]					; Calculate scanline width
	subm	v3[1], v3[1]						; Set scanline remainder to 0
	}

`CalculateDMASize:
	{
	ld_v	(_MPEPolygonGradient), v4			; Read x components of gradient
	bra		le, `StepLeftEdge					; Jump if zero width scanline
	cmp		#64, v3[0]							; Check for maximum DMA length
	}	
	{
	bra		le, `CalculateStepSize
	st_s	v3[0], (rc1)						; Store scanline size in DMA countdown
	abs		v6[2]								; Insure 1/w is positive
	}
	{
	st_s	v7[3], (_MPEPolygonX)				; Store DMA starting x
	msb		v6[2], r1							; Calculate MSB of left 1/w
	}
	st_s	v3[0], (_MPEPolygonDMASize)			; Store likely DMA size

	mv_s	#64, r2
	st_s	r2, (rc1)							; Scanline bigger than 64 pixels
	st_s	r2, (_MPEPolygonDMASize)			; Store maximum DMA size

`CalculateStepSize:
	cmp		#GLMAXSUBDIVISION, v3[0]			; Check for subdivided affine steps
	{
	bra		le, `OneBigStep
	mv_s	#_MPERecipLUT-128, v3[2]			; V3[2] holds pointer to reciprocal lookup table
	sub		#08, r1, r2							; Calculate 1/w index shift
	}
	{
	mv_s	#$40000000, r4						; R4 holds reciprocal sign conversion mask
	}
	ls		r2, v6[2], r3						; Convert 1/w into index offset

	{
	mv_s	#GLMAXSUBDIVISION, v3[0]			; Set scanline segment to maximum
	sub		#GLMAXSUBDIVISION, v3[0], v3[1]		; Calculate scanline remainder
	}
`OneBigStep:
	; OK
	; Calculate 1/1/w
	{
	mv_s	#$7fffffff, r0							; R0 holds 2.30 2
	add		v3[2], r3								; R3 holds index into reciprocal look-up
	mul		v3[0], v4[3], >>#0, v4[3]				; Calculate d(1/w)
	}
	{
	ld_b	(r3), r3								; R3 holds LUT value
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, r2		; Adjust shift value
	mul		v3[0], v4[0], >>#0, v4[0]				; Calculate d(z/w)
	}
	{
	st_s	v3[1], (_MPEPolygonScanlineRemainder)	; Store scanline remainder
	add		v6[2], v4[3]							; V4[3] = ending 1/w
	mul		v3[0], v4[1], >>#0, v4[1]				; Calculate d(s/w)
	}
	{
	mv_s	r4, v3[1]								; Save reciprocal sign conversion mask
	or		r3, >>#2, r4							; Convert reciprocal to unsigned quantity
	mul		v3[0], v4[2], >>#0, v4[2]				; Calculate d(t/w)
	}												; Ending 1/w can be outside polygon!
	{
	mv_s	v4[3], r5								; Save unsigned ending 1/w
	add		v6[0], v4[0]							; v4[0] = ending z
	mul		r4, v6[2], >>r1, v6[2]					; Calculate xy
	}
	{
	ld_s	(_MPETextureParameter), v7[2]			; V7[2] holds t shift (and texture parameter)
	abs		r5										; Make ending 1/w positive
	}
	{
	msb		r5, r1									; Calculate MSB of ending 1/w
	subm	v6[2], r0, v6[2]						; V5[0] = 2-xy
	}
	{
	sub		#08, r1, v3[3]							; V3[3] holds index shift
	addm	v5[0], v4[1]							; V4[1] = ending s/w
	}
	lsr		#08, v7[2], v7[1]						; V7[1] holds s shift	
	{
	ls		v3[3], r5, r3							; R3 holds index offset
	mul		r4, v6[2], >>r2, v6[2]					; V6[2] holds starting w
	}
	add		r3, v3[2], r3							; R3 now holds index to LUT
	{
	ld_b	(r3), r3								; Load LUT value	
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, v3[3]		; Adjust index shift value
	mul		v6[2], v5[0], >>v7[1], v5[0]			; Calculate starting s
	}
	{
	add		v5[1], v4[2]							; V4[2] = ending t/w
	mul		v6[2], v5[1], >>v7[2], v5[1]			; Calculate starting t
	}
	{
	st_s	v5[0], (rx)								; Store starting s in rx
	or		r3, >>#2, v3[1]							; Convert LUT value to unsigned quantity
	}
	{
	st_s	v5[0], (ru)								; Store starting s in ru
	mul		v3[1], r5, >>r1, r5						; Calculate xy
	}
	{
	cmp		#00, v4[3]								; Check if ending 1/w is positive
	st_s	v5[1], (ry)								; Store starting t in ry
	}
	{
	bra		ge, `positiveendingw
	mv_s	#_MPEPolygonScanlineRecipLUT-2, v7[0]	; V7[0] points to scanline Recip LUT
	subm	r5, r0, r5							; Calculate 2-xy
	}
	{
	st_s	v5[1], (rv)								; Store starting t in rv
	add		v3[0], >>#-1, v7[0]						; V7[0] points to 16 bit reciprocal
	mul		v3[1], r5, >>v3[3], r5					; R5 contains ending w
	}
	ld_w	(v7[0]), v7[0]							; V3 contains 1/dX	
	
	neg		r5										; Sign flip ending w
`positiveendingw:
	{
	st_v	v4, (_MPEPolygonScanlineValues)			; Store raster end values
	mul		r5, v4[1], >>v7[1], v4[1]				; Calculate ending s
	}
	{
	ld_s	(_MPEPolygonPixelPointer), v0[3]		; Load current DMA destination pointer
	lsr		#01, v7[0]								; Convert 1/dX to unsigned quantity
	mul		r5, v4[2], >>v7[2], v4[2]				; Calculate ending t
	}
	{
	st_s	v3[0], (rc0)							; Store pixel count in rc0
	sub		v5[0], v4[1], v2[3]						; V2[3] contains ds
	}
	{
	mv_s	v6[0], v6[3]							; V6[3] contains starting z
	sub		v5[1], v4[2], v3[3]						; V3[3] contains dt
	mul		v7[0], v2[3], >>#32, v2[3]				; V2[3] contains ds/dX
	}
	{
	ld_s	(_MPEPolygonGradient), v1[3]			; Load d(z/w)/dX
	abs		v6[3]									; Insure z is positive
	mul		v7[0], v3[3], >>#32, v3[3]				; V3[3] contains dt/dX
	}

	; Generic rasterization loop
	; Place pre loop stuff just after `RasterPreLoop, the loop just past 
	; `RasterLoop, and the post loop stuff just after `RasterPostLoop
	;
	; Register Equates
	; v0[3] = DMA destination pointer
	; v1[3] = dz/dx
	; v2[3] = ds/dx
	; v3[3] = dt/dx
	; v4[3] = -1<<16+ds/dx
	; v6[3] = destination z
	; rx/ru = starting texture s
	; ry/rv = starting texture t
	; rc0 = pixel countdown
	; rc1 = DMA countdown
	;
	; You may trash any registers except for v6[3] and rc1

	; Local equates
	p00 = v0
	p01 = v1
	p10 = v2
	p11 = v3
	p1 = v5
	p2 = v6
	p3 = v7

`RasterPreLoop:
	; 1a
	{
	ld_p	(xy), p00				; Load bilerp texel 00
	sub		#04, v0[3]				; Predecrement destination DMA pointer
	addr	#1<<16, ry				; Increment bilinear y
	}

	; 1b
	{
	ld_p	(xy), p01				; Load bilerp texel 01
	copy	v2[3], v4[3]			; Copy ds/dx into v4[3]
	subm	v1[3], v6[3]			; Predecrement z
	addr	#1<<16, rx				; Increment bilinear x
	}

	; 2b
	{
	ld_p	(xy), p11				; Load bilerp texel 11
	sub		#1, >>#-16, v4[3]		; V4[3] contains -1<<16 + ds/dx
	addr	#-1<<16, ry				; Increment bilinear y
	}

	; 3b
	{
	ld_p	(xy), p10				; Load bilerp texel 10
	sub_p	p00, p01				; Calculate left vertical difference
	addr	#-1<<16, rx				; Decrement and advance bilinear x
	}

	; 4b
	{
	mul_p	rv, p01, >>#30, p01		; Calculate filtered left vertical difference
	addr	v2[3], rx				; Advance bilinear x
	}
	
	; 5b
	{
	sub_p	p10, p11				; Calculate right vertical difference
	addr	v3[3], ry				; Advance bilinear y
	}

	; 6b
	{
	mul_p	rv, p11, >>#30, p11		; Calculate filtered right vertical difference
	addr	v3[3], rv				; Advance bilinear v
	}

	; 7b
	{
	ld_p	(xy), p00				; Load bilerp texel 00
	add_p	p00, p01, p1			; Left filtered texel complete
	addr	#1<<16, ry				; Increment bilinear y
	}

`RasterLoop:
	; 1
	{
	ld_p	(xy), p01				; Load bilerp texel 01
	 add_p	p10, p11, p2			; Right filtered texel complete
	 addm	v1[3], v6[3]			; Advance z
	addr	#1<<16, rx				; Increment bilinear x
	}

	; 2
	{
	ld_p	(xy), p11				; Load bilerp texel 11
	 sub_p	p1, p2					; Calculate horizontal difference
	addr	#-1<<16, ry				; Decrement bilinear y
	}

	; 3
	{
	ld_p	(xy), p10				; Load bilerp texel 10
	sub_p	p00, p01				; Calculate left vertical difference
	mul_p	ru, p2, >>#30, p2		; Calculate filtered horizontal difference
	addr	v4[3], rx				; Decrement and advance bilinear x
	 dec		rc1					; Decrement DMA countdown
	}

	; 4
	{
	 add		#04, v0[3]			; Advance DMA destination pointer
	mul_p	rv, p01, >>#30, p01		; Calculate filtered left vertical difference
	 addr	v2[3], ru				; Advance bilinear u
	 dec		rc0					; Decrement pixel countdown
	}

	; 5
	{
	bra		c0ne, `RasterLoop		; Branch if more pixels to process
	mv_v	p00, p3					; Copy bilerp texel 00 into p3
	sub_p	p10, p11				; Calculate right vertical difference
	addr	v3[3], ry				; Advance bilinear y
	}

	; 6
	{
	ld_p	(xy), p00				; Load bilerp texel 00
	 add_p	p1, p2					; Output pixel complete
	mul_p	rv, p11, >>#30, p11		; Calculate filtered right vertical difference
	addr	#1<<16, ry				; Increment bilinear y
	}

	; 7
	{
	 st_pz	p2, (v0[3])				; Store output pixel
	add_p	p3, p01, p1				; Left filtered vertical texel complete
	addr	v3[3], rv				; Advance bilinear v
	}
	

`RasterPostLoop:
	add		#04, v0[3]				; Advance DMA destination pointer

`DMACheck:
	{
	ld_v	(_MPEPolygonScanlineValues), v3		; Load current scanline stuff
	bra		c1eq, `DMAwait
	sub		r0, r0								; Set r0 to zero for addm copying
	}
	nop	
	{
	mv_s	v3[0], v6[0]							; Copy in current z/w
	copy	v3[1], v5[0]							; Copy in current s/w
	addm	r0, v3[2], v5[1]						; Copy in current t/w
	}
	{	
	bra		`CalculateStepSize
	ld_v	(_MPEPolygonGradient), v4			; Read x components of gradient
	abs		v3[3]								; Insure 1/w is positive
	subm	v3[1], v3[1]						; Zero scanline remainder
	}
	{
	ld_s	(_MPEPolygonScanlineRemainder), v3[0]	; Copy in remaining dX
	msb		v3[3], r1							; Calculate MSB of current 1/w
	addm	r0, v3[3], v6[2]					; Copy in current left 1/w
	}
	st_s	v0[3], (_MPEPolygonPixelPointer)		; Store updated DMA destination pointer

`DMAwait:
	ld_s	(mdmactl), r0							; Read DMA control register
	ld_s	(_MPEPolygonScanlineRemainder), r7		; Load scanline remainder
	and		#$f, r0									; Check for DMA activity
	bra		ne, `DMAwait
	
`DoDMA:
	ld_s	(_MPEPolygonDMASourcePointer), r4
	ld_s	(_MPEPolygonX), r2
	ld_s	(_MPEPolygonDMASize), r5
	ld_s	(_MPEPolygonY), r3
	{
	ld_s	(_MPEDMAFlags), r0
	lsl		#16, r5
	addm	r2, r5, r6					; Increment polygon X
	}
	{
	ld_s	(_MPESDRAMPointer), r1
	bset	#16, r3						; YPOS input complete
	}
	{
	st_s	r4, (_MPEMDMACmdBuf+16)
	or		r5, r2						; XPOS input complete
	}
	{
	st_v	v0, (_MPEMDMACmdBuf)
	eor		#DMA_CACHE_EOR, r4			; Flip DMA buffers
	}
	st_s	#_MPEMDMACmdBuf, (mdmacptr)

`CheckScanlineRemainder:
	{
	cmp		#00, r7										; Check if any pixels are left on scanline
	st_s	r6, (_MPEPolygonX)							; Store updated polygon x
	}
	{
	st_s	r4, (_MPEPolygonDMASourcePointer)			; Store updated polygon DMA pointer
	bra		eq, `StepLeftEdge							; Branch if at end of scanline
	}
	{
	bra		`CalculateDMASize
	mv_s	r6, v7[3]									; Copy left current x into v7[3]
	abs		v3[3]										; Insure 1/w is positive
	subm	v3[1], v3[1]								; Zero scanline remainder
	}
	{
	mv_s 	v3[3], v6[2]								; Copy in current left 1/w
	msb		v3[3], r1									; Calculate MSB of current 1/w
	}
	{
	st_s	r4, (_MPEPolygonPixelPointer)				; Reset pixel destination pointer
	copy	r7, v3[0]									; Copy remaining dX into v3[0]
	}

	; Increment left and right edges
`StepLeftEdge:
	ld_v	(_MPEPolygonLeftEdge), v7
	ld_v	(_MPEPolygonLeftEdge+16), v6
	{
	ld_v	(_MPEPolygonLeftEdge+32), v5	
	add		v7[1], v7[2]						; Increment left errorTerm
	addm	v7[0], v7[3]						; Increment left x
	}
	{
	ld_s	(_MPEPolygonY), r0					; Load current polygon y
	bra		le, `NoLeftOverflow					; Branch if errorTerm < 0
	}
	{
	ld_v	(_MPEPolygonEdgeExtra), v4			; Load height/denominators for both edges
	add		v6[1], v6[0]						; Increment z/w
	addm	v5[2], v5[0]						; Increment s/w
	}
	{
	ld_v	(_MPEPolygonGradient), v2			; Load x component of gradient
	add		v5[3], v5[1]						; Increment t/w
	addm	v6[3], v6[2]						; Increment 1/w
	}

`LeftOverFlow:
	{
	add		#01, v7[3]							; Increment x
	subm	v4[1], v7[2]						; Reset error term
	}

	{
	add		v2[0], v6[0]						; Increment z/w
	addm	v2[1], v5[0]						; Increment s/w
	}
	{
	add		v2[2], v5[1]						; Increment t/w
	addm	v2[3], v6[2]						; Increment 1/w
	}

`NoLeftOverflow:
	{
	st_v	v7, (_MPEPolygonLeftEdge)		; Store updated left edge info
	sub		#01, v4[0]						; Decrement height
	}
	{
	st_v	v6, (_MPEPolygonLeftEdge+16)	; Store updated left edge info
	}
	{
	bra		gt, `StepRightEdge
	st_v	v5, (_MPEPolygonLeftEdge+32)	; Store updated left edge info
	add		#01, r0							; Increment polygon y
	}
	st_v	v4, (_MPEPolygonEdgeExtra)		; Store updated height/denominator
	st_s	r0, (_MPEPolygonY)				; Store updated polygon y

	; Prepare next left edge
	push	v7, rz										; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge								; Jump to edge calculation routine
	mv_s	#32, r1										; Set vertex increment to positive
	}
	ld_s	(pcexec), r2								; Load return address
	ld_s	(_MPEPolygonNextLeftVertexPointer), r0		; Load next vertex pointer
	pop		v7, rz
	
`StepRightEdge:
	ld_v	(_MPEPolygonRightEdge), v7			; Load right edge data
	ld_v	(_MPEPolygonEdgeExtra), v6			; Load height/denominator
	{
	add		v7[1], v7[2]						; Increment right errorTerm
	addm	v7[0], v7[3]						; Increment right x
	}
	bra		le, `NoRightOverflow, nop			; Branch if errorTerm < 0
	{
	add		#01, v7[3]							; Increment x
	subm	v6[3], v7[2]						; Reset errorTerm
	}

`NoRightOverflow:
	{
	st_v	v7, (_MPEPolygonRightEdge)				; Store updated edge parameters
	sub		#01, v6[2]								; Decrement edge height
	}
	{
	bra		ne, `WalkLoop, nop						; Jump to main loop if more left
	st_v	v6, (_MPEPolygonEdgeExtra)				; Updated edge data complete
	add		#01, r0									; Increment polygon y
	}

	; Prepare next right edge
	push	v7, rz									; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge							; Jump to edge calculation routine
	mv_s	#-32, r1								; Set vertex increment to positive
	}
	ld_s	(pcexec), r2							; Load return address
	ld_s	(_MPEPolygonNextRightVertexPointer), r0	; Load next vertex pointer
	{
	bra		`WalkLoop, nop
	pop		v7, rz
	}

	; Subroutines

	; Prepares an edge, pass vertex pointer in R0
	; 32 for a right edge or -32 for a left edge in R1
	; and return address in R2
	; Next vertex pointer is returned in R0
	; Affects R0-R30!!!! (R31 must be unaffected SML 9/30/98)
`PrepareEdge:
	{
	st_s	#9, rc0								; Store maximum vertex count
	copy	r1, r7								; Wait on load and save increment
	}
	st_s	r2, (rz)								; Store return address
`PrepEdge:
	{
	bra		c0eq, `EndPolygon
	mv_s	#3, r27								; Read number of vertices
	}
	ld_s	(_MPEPolygonVertex), r28			; R28 points to MPE Polygon Vertex List
	{
	ld_v	(r0), v2							; Read x1, y1, z1, 1/w1
	add		#16, r0								; Increment vertex pointer to s1/z1, t1/z1 
	addm	r7, r0, r26 						; R26 now points to second vertex
	}
	{
	ld_v	(r0), v3							; Read s1/w1, t1/w1, C
	cmp		r28, r26							; Check for vertex underflow
	mul		#16, r27, >>#-1, r27				; Calculate 32 * vertices 
	}
	{
	bra		ge, `nounderflow					; Jump if no underflow
	copy	r9, r25								; Copy fixed point y1 into r25
	}
	{
	mv_s	r8, r24								; Copy fixed point x1 into R24
	add		r27, r28, r29						; R29 points past end of active vertices
	dec		rc0									; Decrement vertex search counter
	}
	mv_s	#((1<<GLXYZSCREENSHIFT)-1), r30		; R30 contains ceiling rounder

	add		r27, r26							; Wrap vertex around to end of list
`nounderflow:
	cmp		r29, r26							; Check for vertex pointer overflow
	bra		ne, `nooverflow, nop				; Jump if no overflow

	sub		r27, r26							; Wrap vertex around to beginning of list

`nooverflow:
	{
	ld_v	(r26), v4							; Read x2, y2, z2, 1/w2
	add		r30, r8								; Round up x1
	addm	r30, r9								; Round up y1
	}
	{
	ld_v	(_MPEPolygonGradient), v5			; Read gradient x stuff
	asr		#GLXYZSCREENSHIFT, r9				; Integer y1 complete
	}
	{
	add		r30, r16							; Round up x2
	addm	r30, r17							; Round up y2
	}
	{
	asr		#GLXYZSCREENSHIFT, r17				; Integer y2 complete
	mul		#1, r8, >>#GLXYZSCREENSHIFT, r8		; Integer x1 complete
	}
	{
	sub		r9, r17, r30						; R30 contains height of edge
	mul		#1, r16, >>#GLXYZSCREENSHIFT, r16	; Integer x2 complete
	}

	bra		mi, `EndPolygon, nop				; Jump if polygon end reached
	bra		ne, `realedge, nop					; Jump if not a flat edge

	; Flat edge, jump to next vertex and try again
	{
	bra		`PrepEdge, nop
	mv_s	r26, r0					; Set current vertex to next vertex	
	}
	
	; Genuine edge, calculate Bresenham parameters 
`realedge:
	{
	push	v2, rz						; Save subroutine return address
	jsr		_FloorDivMod
	}
	{
	mv_s	r30, r1								; R1 = denominator = dY
	sub		r8, >>#(-GLXYZSCREENSHIFT), r24		; Calculate x prestep
	}
	{
	st_s	#00, (acshift)						; Set acshift to 0
	sub		r9, >>#(-GLXYZSCREENSHIFT), r25		; Calculate y prestep
	subm	r8, r16, r0							; R0 = numerator = dX
	}

	{
	mv_s	r30, r4								; Move edge height into R4
	copy	r8, r3								; Move initial x into R3
	addm	r1, r1								; Set numerator to 2X remainder
	}
	; Check for left/right edge
	{
	pop		v2, rz								; Restore subroutine return address
	cmp		#00, r7								; Check for left or right edge
	}

	{
	ld_v	(_MPEPolygonGradient), v5			; Load x components of gradient
	add		r4, r4, r5							; Set denominator to 2X edge height
	bra		ge, `leftedge
	}
	neg		r24									; Make x prestep positive
	neg		r25									; Make y prestep positive

`rightedge:
	st_s	r26, (_MPEPolygonNextRightVertexPointer)	; Store next right vertex
	{
	st_v	v0, (_MPEPolygonRightEdge)			; Store right edge Bresenham parameters
	rts
	}
	st_s	r4, (_MPEPolygonRightEdgeExtra)		; Store height
	st_s	r5, (_MPEPolygonRightEdgeExtra+4)	; Store denominator

	// Calculate all Bresenham parameters and prestep them to integer coordinates
	// If you don't do this, you get HORRIBLE texture swim
`leftedge:
	{
	st_s	v1[0], (_MPEPolygonLeftEdgeExtra)			; Store height
	copy	v2[2], v1[0]								; Copy z/w into v1[0]
	mul		r0, v5[1], >>acshift, v2[2]					; Calculate first component of s/wStep
	}
	{
	st_s	v1[1], (_MPEPolygonLeftEdgeExtra+4)			; Store denominator
	copy	v3[0], v2[0]								; Copy s1/w1 into v2[0]
	mul		r0, v5[0], >>acshift, v1[1]					; Calculate first component of zStep
	}
	{
	ld_v	(_MPEPolygonGradient+16), v4				; Load y components of gradient
	copy	v2[3], v1[2]								; Copy 1/w1 into R20
	mul		r0, v5[2], >>acshift, v2[3]					; Calculate first component of t/wStep
	}
	{
	st_s	v2[1], (_MPEPolygonY)						; Store current polygon y coordinate
	copy	v3[1], v2[1]								; Copy t1/w1 into v2[1]
	mul		r0, v5[3], >>acshift, v1[3]					; Calculate first component of 1/wStep
	}
	{
	st_v	v0, (_MPEPolygonLeftEdge)					; Store left edge Bresenham parameters	
	add		v4[0], v1[1]								; z/wStep complete
	mul		r24, v5[0], >>#GLXYZSCREENSHIFT, v5[0]		; Calculate d(z/w)/dX * xPrestep
	}
	{
	st_s	r26, (_MPEPolygonNextLeftVertexPointer)		; Store next left vertex
	add		v4[1], v2[2]								; s/wStep complete
	mul		r24, v5[1], >>#GLXYZSCREENSHIFT, v5[1]		; Calculate d(s/w)/dX * xPrestep
	}
	{
	add		v4[2], v2[3]								; t/wStep complete
	mul		r24, v5[2], >>#GLXYZSCREENSHIFT, v5[2]		; Calculate d(t/w)/dX * xPrestep
	}
	{
	add		v4[3], v1[3]								; 1/wStep complete
	mul		r24, v5[3], >>#GLXYZSCREENSHIFT, v5[3]		; Calculate d(1/w)/dX * xPrestep
	}
	{
	add		v5[0], v1[0]								; z1/w1 = (z1/w1) + d(z/w)/dx * xPrestep
	mul		r25, v4[0], >>#GLXYZSCREENSHIFT, v4[0]		; Calculate dz/dY * yPrestep
	}
	{
	add		v5[1], v2[0]								; s1/w1 = s1/w1 + d(s/w)/dX * xPrestep
	mul		r25, v4[1], >>#GLXYZSCREENSHIFT, v4[1]		; Calculate d(s/w)/dY * yPrestep
	}
	{
	add		v5[2], v2[1]								; t1/w1 = t1/w1 + d(t/w)/dX * xPrestep
	mul		r25, v4[2], >>#GLXYZSCREENSHIFT, v4[2]		; Calculate d(t/w)/dY * yPrestep
	}
	{
	add		v5[3], v1[2]								; 1/w1 = 1/w1 + d(1/w)/dX * xPrestep
	mul		r25, v4[3], >>#GLXYZSCREENSHIFT, v4[3]		; Calculate d(1/w)/dY * yPrestep
	}
	add		v4[0], v1[0]								; z1/w1 complete
	{
	rts
	add		v4[3], v1[2]								; 1/w1 complete
	addm	v4[1], v2[0]								; s1/w1 complete
	}
	{
	st_v	v1, (_MPEPolygonLeftEdge+16)				; Store z/w    zStep 1/w     1/wStep
	add		v4[2], v2[1]								; t1/w1 complete
	}
	st_v	v2, (_MPEPolygonLeftEdge+32)				; Store s/w  t/w   s/wStep t/wStep

	; Move onto next polygon or clean up if done
`EndPolygon:
	pop		v7, rz							; Restore subroutine return
`EndPolygon1:
	ld_s	(_MPEPolygonVertices), r0		; Load current vertex count
	ld_s	(_MPEPolygonVertex), r1			; Load current vertex pointer
	sub		#01, r0							; Decrement vertex count
	{
	ld_v	(r1), v1						; Load 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex counter
	}
	{
	ld_v	(r1), v2						; Load 1st vertex uvC
	add		#16, r1							; Increment 1st vertex counter
	}
	st_s	r1, (_MPEPolygonVertex)			; Store new 1st vertex pointer
	cmp		#3, r0							; Check for last triangle
	{
	bra		ge, `PolygonLoop				; Jump if more triangles to rasterize
	st_s	r0, (_MPEPolygonVertices)		; Store new vertex count
	}
	{
	st_v	v1, (r1)						; Store 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex pointer
	}
	st_v	v2, (r1)
	
	; Clean up and exit
`RasterDone:
	rts		nop

.align.sv
_RasterSTF_end:


	; White lit texture rasterization
.module RasSTFI


	X0 = v7				// Vertex 0 vector
	x0 = r28
	y0 = r29
	z0 = r30
	w0 = r31
	X1 = v6				// Vertex 1 vector
	x1 = r24
	y1 = r25
	z1 = r26
	w1 = r27
	X2 = v5				// Vertex 2 vector
	x2 = r20
	y2 = r21
	z2 = r22
	w2 = r23
	S0 = v2
	s0 = r8
	t0 = r9
	I0 = r10
	a0 = r11
	S1 = v3
	s1 = r12
	t1 = r13
	I1 = r14
	a1 = r15
	S2 = v4
	s2 = r16
	t2 = r17
	I2 = r18
	a2 = r19
	C0 = v2
	C1 = v3
	C2 = v4

.export _RasterSTFI_size
	_RasterSTFI_size = _RasterSTFI_end - _RasterSTFI
.export _RasterSTFI
.import _FloorDivMod
.import _MPEMDMACmdBuf
.import _MPEPolygonGradient
.import _MPEPolygonScanlineValues
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEPolygonLeftEdge
.import _MPEPolygonLeftEdgeColor
.import _MPEPolygonRightEdge
.import _MPEPolygonX
.import _MPEPolygonY
.import _MPEPolygonDMASize
.import _MPEPolygonDMASourcePointer
.import _MPEPolygonPixelPointer
.import _MPESDRAMPointer
.import _MPEDMAFlags
.import _MPETextureParameter
.import _MPEPolygonScanlineRemainder
.import _MPEPolygonScanlineRecipLUT
.import _MPEPolygonNextLeftVertexPointer
.import _MPEPolygonNextRightVertexPointer
.import _MPERecipLUT
.align.s
_RasterSTFI:
	mv_s	#_MPEPolygonVertexList, r0				; Initialize vertex list
	st_s	r0, (_MPEPolygonVertex)					; Kludge a 3 vertex polygon

	; Calculate Gradients from any 3 vertices (optimized for trivial accept)
	; Affects all registers


`PolygonLoop:
	ld_s	(_MPEPolygonVertex), r0
	nop

	; Stage 1, load data for triangle and calculate dV0 AND dV1
	{
	ld_v 	(r0), X2						; Load vertex 0 xyz1/w as X2
	add		#16, r0							; Increment vertex pointer					
	}
	{
	ld_v	(r0), S2						; Load vertex 0 uvY as S2
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X0						; Load vertex 1 xyz1/w as X0
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v 	(r0), S0						; Load vertex 1 uvY as S0
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X1						; Load vertex 2 xyz1/w as X1
	add		#16, r0							; Increment vertex pointer
	subm	x2, x0							; Calculate x0 - x2		
	}
	{
	ld_v 	(r0), S1					; Load vertex 2 uvY as S1
	sub		y2, y0						; Calculate y0 - y2
	subm	w2, w0						; Calculate 1/w0 - 1/w2
	}
	

	; Calculate dX, dY d(s/w), d(t/w), d(I/w), d(1/w) and dZ
	{
	st_s	#GLXYZSCREENSHIFT, (acshift)	; Set acshift for dX products	
	sub		x2, x1							; Calculate x1 - x2
	subm	y2, y1							; Calculate y1 - y2
	}
	{
	msb		w0, r7							; R7 holds 1/w0 - 1/w2 MSB
	mul		x1, y0, >>acshift, x2			; X2 now contains (x1 - x2) * (y0 - y2)
	}

	{
	sub		w2, w1							; Calculate 1/w1 - 1/w2
	mul		x0, y1, >>acshift, y2			; Y2 now contains (x0 - x2) * (y1 - y2)
	}

	sub		z2, z1							; Calculate z1/w1 - z2/w2

	{
	sub		y2, x2, r0						; R1 now contains dX or signed area
	subm	z2, z0							; Calculate z0/w0 - z2/w2
	}

	{
	bra		le, `EndPolygon1				; If signed area < 0, skip polygon
	abs		r0								; Insure 1/dX denominator is positiive
	subm	I2, I1							; Calculate (I1/w1 - I2/w2) 
	}

	{
	msb		r0, r1							; Calculate dX MSB
	subm	s2, s1							; Calculate s1/w1 - s2/w2
	}
	
	{
	sub		#08, r1, r2						; R2 holds index shift for 1/dX
	subm	s2, s0							; Calculate s0/w0 - s2/w2
	}

	{
	mv_s	#_MPERecipLUT-128, r4			; R4 holds Reciprocal LUT pointer	
	ls		r2, r0, r3						; Convert dX into index offset
	subm	t2, t1							; Calculate t1/w1 - t2/w2
	}

	{
	mv_s	#$40000000, r3					; R3 holds unsigned LUT value conversion mask
	msb		w1, a0							; A0 holds 1/w1 - 1/w2 MSB
	addm	r3, r4							; R4 holds pointer to reciprocal LUT value
	}

	{
	ld_b	(r4), r5						; Load 8 bit reciprocal LUT value
	msb		w0, r6							; R6 holds 1/w0 - 1/w2 MSB
	subm	t2, t0							; Calculate t0/w0 - t2/w2
	}
	{
	cmp		r6, a0							; Check for greatest d(1/w) MSB
	subm	I2, I0							; Calculate (I0/w0 - I2/w2)
	}
	{
	bra		ge, `a0greater					; Branch if latter MSB is greater
	or		r5, >>#2, r3					; Convert 8 bit LUT value to 32 bit scalar
	}

	{
	msb		z1, a1							; A1 holds (z1 - z2) MSB
	mul		r3, r0, >>r1, r0				; Calculate xy
	}

	{
	mv_s	#$7fffffff, r4					; R4 holds TWO
	msb		z0, r7							; R7 holds (z0 - z2) MSB
	}

	mv_s	r6, a0							; d(1/w) MSB complete
`a0greater:
	msb		s1, s2							; Calculate s1/w1 - s2/w2 MSB
	{
	add		#(36-GLXYZSCREENSHIFT), r2		; Adjust 1/dX answer shift
	subm	r0, r4, r0		
	}

	{
	cmp		r7, a1							; Check for greater d(z/w) MSBs
	mul		r3, r0, >>r2, r0				; 1/dX complete
	}
	
	{
	bra		ge, `a1greater, nop	 			; Branch if latter MSB is greater
	msb		s0, r6							; R6 holds (s0/w0 - s2/w2) MSB 	
	}

	mv_s	r7, a1							; dz MSB complete
`a1greater:
	cmp		#20, a0							; Check if MSB of d(1/w) > 20
	{
	bra		le, `nowoverflow				; Jump if no overflow
	neg		r0								; Remove if signed area > 0
	}
	{
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default preshift value for multiplication
	msb		t1, t2							; T2 holds (t1/w1 - t0/w0) MSB
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default postshift value for multiplication
	msb		t0, a2							; A2 holds (t0/w0 - t2/w2) MSB
	}

	add		#GLXYZSCREENSHIFT-20, a0, r1	; R1 holds adjusted d(1/w) preshift
	sub		a0, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted d(1/w) postshift
`nowoverflow:
	{
	cmp		r6, s2							; Check for greater of d(s/w) MSBs
	st_s	r1, (acshift)					; Set preshift
	}
	{
	bra		ge, `s2greater					; Branch if latter MSB greater
	mul		w1, y0, >>acshift, w2			; w2 holds (1/w1 - 1/w2) * (y0 - y2)
	}
	mul		w0, y1, >>acshift, r7			; R7 holds (1/w0 - 1/w2) * (y1 - y2)
	{
	cmp		a2, t2							; Check for greater of d(t/w) MSBs
	mul		w0, x1, >>acshift, r3			; R3 holds (1/w0 - 1/w2) * (x1 - x2)
	}
	
	mv_s	r6, s2							; d(s/w) MSB complete
`s2greater:

	{
	bra		ge, `t2greater					; Branch if latter MSB greater
	sub		w2, r7							; R7 holds (1/w0 - 1/w2) * (y1 - y2) - (1/w1 - 1/w2) * (y0 - y2)
	mul		x0, w1, >>acshift, w2			; W2 holds (1/w1 - 1/w2) * (x0 - x2)
	}
	mul		r0, r7, >>r2, r7				; d(1/w)/dX complete
	cmp		#20, a1							; Check if mSB of dZ > 20
 
	mv_s	a2, t2							; A1 holds d(t/z) MSB
`t2greater:
	{
	bra		le, `nozoverflow				; Jump if MSB <=20
	msb		I0, a0							; A0 holds (I0/w0 - I2/w2) MSB
	subm	r3, w2							; w2 holds (1/w1 - 1/w2) * (x0 - x2) - (1/w0 - 1/w2) * (x1 - x2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default dZ preshift
	mul		r0, w2, >>r2, w2				; d(1/w)/dY complete
	}
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default postshift value for multiplication

	add		#GLXYZSCREENSHIFT-20, a1, r1	; R1 holds adjusted dZ preshift
	sub		a1, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted dZ postshift
`nozoverflow:
	{
	cmp		#20, s2							; Check d(s/z) MSB for overflow
	st_s	r1, (acshift)					; Set dz preshift
	}
	{
	bra		le, `nosoverflow				; Branch if MSB <= 20
	msb		I1, a1							; A1 holds (I1/w1 - I2/w2) MSB
	mul		z1, y0, >>acshift, x2			; x2 contains (z1 - z2) * (y0 - y2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, w0			; w0 holds default d(s/w) preshift
	mul		z0, y1, >>acshift, r4			; R4 contains (z0 - z2) * (y1 - y2)
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, w1			; w1 holds default d(s/w) postshift
	mul		z0, x1, >>acshift, r3			; R3 holds (z0 - z2) * (x1 - x2)
	}

	add		#GLXYZSCREENSHIFT-20, s2, w0	; w0 holds adjusted d(s/w) preshift
	sub		s2, #GLINVDXSCREENSHIFT+20, w1	; w1 holds adjusted d(s/w) postshift
`nosoverflow:
	{
	sub		x2, r4							; R4 holds (z0 - z2) * (y1 - y2) - (z1 - z2) * (y0 - y2)
	mul		z1, x0, >>acshift, x2 			; X2 holds (z1 - z2) * (x0 - x2)
	}
	{
	cmp		#20, t2							; Check d(t/w) MSB for overflow
	st_s	w0, (acshift)					; Set d(s/w) preshift
	mul		r0, r4, >>r2, r4				; R4 holds dz/dX
	}
	{
	bra		le, `notoverflow				; Branch if MSB <= 20
	sub		r3, x2							; X2 contains (z1 - z2) * (x0 - x2) - (z0 - x2) * (x1 - x2)
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default d(t/w) preshift
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default d(t/w) postshift
	mul		r0, x2, >>r2, x2				; x2 holds dz/dY
	}
	mul		s1, y0, >>acshift, y2			; Y2 contains (s1/w1 - s2/w2) * (y0 - y2)
	
	add		#GLXYZSCREENSHIFT-20, t2, r1	; R1 holds adjusted d(t/w) preshift
	sub		t2, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted d(t/w) postshift
`notoverflow:
	{
	cmp		a0, a1							; Compare d(I/w) MSBs
	mul		s0, y1, >>acshift, r5			; R5 contains (s0/w0 - s2/w2) * (y1 - y2)
	}
	{
	bra		ge, `a1greater1					; Branch if latter MSB is greater
	mul		s0, x1, >>acshift, r3			; R3 contains (s0/w0 - s2/w2) * (x1 - x2)
	}
	{
	st_s	r1, (acshift)					; Set d(t/w) preshift
	sub		y2, r5							; R5 holds (s0/w0 - s2/w2) * (y1 - y2) - (s1/w1 - s2/w2) * (y0 - y2)
	mul		s1, x0, >>acshift, y2			; Y2 contains (s1/w1 - s2/w2) * (x0 - x2)	
	}
	mul		r0, r5, >>w1, r5				; d(s/w)/dX complete

	mv_s	a0, a1							; d(I/w) MSB complete
`a1greater1:
	{
	sub		r3, y2							; Y2 holds (s1/w1 - s2/w2) * (x0 - x2) - (s0/w0 - s2/w2) * (x1 - x2)
	mul		t1, y0, >>acshift, z2			; Z2 contains (t1/w1 - t2/w2) * (y0 - y2)	
	}
	{
	cmp		#20, a1							; Check d(I/w) MSB for overflow
	mul		r0, y2, >>w1, y2				; d(s/w)/dY complete
	}
	{
	bra		le, `noioverflow				; Branch if MSB <= 20
	mul		t0, y1, >>acshift, r6			; R6 contains (t0/w0 - t2/w2) * (y1 - y2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, s2			; S2 holds default d(I/w) preshift
	mul		t0, x1, >>acshift, r3			; R3 contains (t0/w0 - t2/w2) * (x1 - x2)
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, t2			; T2 holds default d(t/w) postshift
	sub		z2, r6							; R6 holds (t0/w0 - t2/w2) * (y1 - y2) - (t1/w1 - t2/w2) * (y0 - y2)
	mul		t1, x0, >>acshift, z2			; Z2 contains (t1/w1 - t2/w2) * (x0 - x2)
	}

	add		#GLXYZSCREENSHIFT-20, a1, s2	; S2 holds adjusted d(I/w) preshift
	sub		a1, #GLINVDXSCREENSHIFT+20, t2	; T2 holds adjusted d(I/w) postshift
`noioverflow:
	st_s	s2, (acshift)					; Set up d(I/w) preshift
	mul		r0, r6, >>r2, r6				; R6 contains d(t/w)/dX
	{
	sub		r3, z2							; Z2 holds (t1/w1 - t2/w2) * (x0 - x2) - (t0/w0 - t2/w2) * (x1 - x2)
	mul		I0, y1							; Y1 holds (I0/w0 - I2/w2) * (y1 - y2)
	}
	{
	st_v	v1, (_MPEPolygonGradient)		; Store dX component of polygon gradient
	mul		r0, z2, >>r2, z2				; Z2 contains d(t/w)/dY
	}
	mul		I1, y0							; Y0 holds (I1/w1 - I2/w2) * (y0 - y2)
	{
	mul		I0, x1							; X1 holds (I0/w0 - I2/w2) * (x1 - x2)
	st_v	X2, (_MPEPolygonGradient+16)	; Store dY component of polygon gradient
	}
	{
	mul		I1, x0							; X0 holds (I1/w1 - I2/w2) * (x0 - x2)
	}
	{
	st_s	t2, (acshift)
	sub		y0, y1							; Y1 holds (I0/w0 - I2/w2) * (y1 - y2) - (I1/w1 - I2/w2) * (y0 - y2)
	}
	{
	mul		r0, y1, >>acshift, x1			; d(I/w)/dX complete
	sub		x1, x0, y1						; X1 holds (I1/w1 - I2/w2) * (x0 - x2) - (I0/w0 - I2/w2) * (x1 - x2)
	}
	mul		r0, y1							; d(I/w)/dY complete
	nop
	st_v	X1, (_MPEPolygonLeftEdgeColor)	; Store Intensity gradients

	; Calculate color gradient (later SML 9/28/98)

	; All registers free
	
	; Calculate any additional reciprocal(s) (which only occur if clipping occurred
	; or somebody slipped us a polygon rather than a triangle)


	; Rasterization equates
	y = r30						; Current y
	leftVertex = r31			; Current left vertex
	rightVertex = r29			; Current right vertex
	
	; Find top vertex
	mv_s	#$7fffffff, y						; Set yTop to maximum
	ld_s	(_MPEPolygonVertex), r31			; Initial vertex pointer
	lsl		#01, y, r27							; Set R27 to yMin 
	{
	mv_s	#3, r28								; Load vertex count
	add		#04, r31							; Increment vertex pointer to y
	}
	mv_s	r31, r29							; Copy vertex pointer

`topsearch:
	ld_s	(r31), r0							; Load vertex y
	nop
	cmp		y, r0								; Check if new minimum y
	{
	bra		gt, `nonewminvertex, nop			; Jump if vertex is definitely not at top
	cmp		y, r27								; Check for new maximum y
	}

	; New minimum  y/vertex
	mv_s	r31, r29							; Copy current vertex into top vertex pointer
	mv_s	r0, y								; Copy current vertex y into minimum y pointer
`nonewminvertex:
	{
	bra		ge, `nonewmaxvertex, nop			; Jump if no new max y
	sub		#01, r28							; Decrement vertex count
	}

	mv_s	y, r27								; Set R27 to new yMax
`nonewmaxvertex:
	bra		ne, `topsearch						; Jump if more vertices to check
	add		#32, r31
	nop

	{
	mv_s	#32, r1								; Set increment input to left vertex
	sub		#04, r29							; Make vertex pointer point to vertex again
	}
	{
	mv_s	r29, r31							; Set current vertices to same vertex
	copy	r29, r0								; Set left vertex pointer for subroutine
	}

	; Prepare initial left edge
	push	v7, rz								; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge, nop
	ld_s	(pcexec), r2
	}

	; Prepare initial right edge
	{
	bra		`PrepareEdge
	mv_s	#-32, r1
	copy	r31, r0
	}
	ld_s	(pcexec), r2
	nop
	pop		v7, rz						; Restore edge pointers and subroutine return

	; Walk left and right edges and fire off scanlines
`WalkLoop:

	; Walk a scanline
	ld_s	(_MPEPolygonDMASourcePointer), r0	; R0 points to current DMA cache
	ld_v	(_MPEPolygonLeftEdge), v7			; Load left edge parameters
	st_s	r0, (_MPEPolygonPixelPointer)		; Store initial pixel destination pointer
	ld_v	(_MPEPolygonRightEdge), v4			; Load right edge parameters
	ld_v	(_MPEPolygonLeftEdge+32), v5		; Load additional left edge stuff
	ld_v	(_MPEPolygonLeftEdge+48), v2		; Read Intensity data
	{
	ld_v	(_MPEPolygonLeftEdge+16), v6		; Load final batch of left edge stuff
	sub		v7[3], v4[3], v3[0]					; Calculate scanline width
	subm	v3[1], v3[1]						; Set scanline remainder to 0
	}

`CalculateDMASize:
	{
	ld_v	(_MPEPolygonGradient), v4			; Read x components of gradient
	bra		le, `StepLeftEdge					; Jump if zero width scanline
	cmp		#64, v3[0]							; Check for maximum DMA length
	}	
	{
	bra		le, `CalculateStepSize
	st_s	v3[0], (rc1)						; Store scanline size in DMA countdown
	abs		v6[2]								; Insure 1/w is positive
	}
	{
	st_s	v7[3], (_MPEPolygonX)				; Store DMA starting x
	msb		v6[2], r1							; Calculate MSB of left 1/w
	}
	st_s	v3[0], (_MPEPolygonDMASize)			; Store likely DMA size

	mv_s	#64, r2
	st_s	r2, (rc1)							; Scanline bigger than 64 pixels
	st_s	r2, (_MPEPolygonDMASize)			; Store maximum DMA size

`CalculateStepSize:
	cmp		#GLMAXSUBDIVISION, v3[0]			; Check for subdivided affine steps
	{
	bra		le, `OneBigStep
	mv_s	#_MPERecipLUT-128, v3[2]			; V3[2] holds pointer to reciprocal lookup table
	sub		#08, r1, r2							; Calculate 1/w index shift
	}
	{
	mv_s	#$40000000, r4						; R4 holds reciprocal sign conversion mask
	}
	{
	mv_s	v2[0], v2[3]						; Copy d(I/w)/dX into v2[3]
	ls		r2, v6[2], r3						; Convert 1/w into index offset
	}
	{
	mv_s	#GLMAXSUBDIVISION, v3[0]			; Set scanline segment to maximum
	sub		#GLMAXSUBDIVISION, v3[0], v3[1]		; Calculate scanline remainder
	}
`OneBigStep:
	; OK
	; Calculate 1/1/w
	{
	mv_s	#$7fffffff, r0							; R0 holds 2.30 2
	add		v3[2], r3								; R3 holds index into reciprocal look-up
	mul		v3[0], v4[3], >>#0, v4[3]				; Calculate d(1/w)
	}
	{
	ld_b	(r3), r3								; R3 holds LUT value
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, r2		; Adjust shift value
	mul		v3[0], v4[0], >>#0, v4[0]				; Calculate dz
	}
	{
	st_s	v3[1], (_MPEPolygonScanlineRemainder)	; Store scanline remainder
	add		v6[2], v4[3]							; V4[3] = ending 1/w
	mul		v3[0], v4[1], >>#0, v4[1]				; Calculate d(s/w)
	}
	{
	mv_s	r4, v3[1]								; Save reciprocal sign conversion mask
	or		r3, >>#2, r4							; Convert reciprocal to unsigned quantity
	mul		v3[0], v4[2], >>#0, v4[2]				; Calculate d(t/w)
	}												; Ending 1/w can be outside polygon!
	{
	mv_s	v4[3], r5								; Save unsigned ending 1/w
	add		v6[0], v4[0]							; v4[0] = ending z
	mul		r4, v6[2], >>r1, v6[2]					; Calculate xy
	}
	{
	ld_s	(_MPETextureParameter), v7[2]			; V7[2] holds t shift (and texture parameter)
	abs		r5										; Make ending 1/w positive
	}
	{
	msb		r5, r1									; Calculate MSB of ending 1/w
	subm	v6[2], r0, v6[2]						; V5[0] = 2-xy
	}
	{
	sub		#08, r1, v3[3]							; V3[3] holds index shift
	addm	v5[0], v4[1]							; V4[1] = ending s/w
	}
	{
	lsr		#08, v7[2], v7[1]						; V7[1] holds s shift	
	mul		v3[0], v2[3], >>#0, v2[3]				; Calculate d(I/w)
	}
	{
	ls		v3[3], r5, r3							; R3 holds index offset
	mul		r4, v6[2], >>r2, v6[2]					; V6[2] holds starting w
	}
	{
	add		r3, v3[2], r3							; R3 now holds index to LUT
	}
	{
	ld_b	(r3), r3								; Load LUT value	
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, v3[3]		; Adjust index shift value
	mul		v6[2], v5[0], >>v7[1], v5[0]			; Calculate starting s
	}
	{
	add		v5[1], v4[2]							; V4[2] = ending t/w
	mul		v6[2], v5[1], >>v7[2], v5[1]			; Calculate starting t
	}
	{
	st_s	v5[0], (rx)								; Store starting s in rx
	or		r3, >>#2, v3[1]							; Convert LUT value to unsigned quantity
	}
	{
	st_s	v5[0], (ru)								; Store starting s in ru
	mul		v3[1], r5, >>r1, r5						; Calculate xy
	}
	{
	st_v	v4, (_MPEPolygonScanlineValues)			; Store raster end values
	copy	v2[2], v4[3]						; Copy starting I/w into position
	}
	{
	cmp		#00, v4[3]								; Check if ending 1/w is positive
	st_s	v5[1], (ry)								; Store starting t in ry
	}
	{
	bra		ge, `positiveendingw
	mv_s	#_MPEPolygonScanlineRecipLUT-2, v7[0]	; V7[0] points to scanline Recip LUT
	subm	r5, r0, r5							; Calculate 2-xy
	}
	{
	add		v3[0], >>#-1, v7[0]						; V7[0] points to 16 bit reciprocal
	mul		v3[1], r5, >>v3[3], r5					; R5 contains ending w
	}
	{
	ld_w	(v7[0]), v7[0]							; V3 contains 1/dX	
	add		v2[3], v2[2]							; Calculate ending I/w
	mul		v6[2], v4[3], >>#45+GLXYZWCLIPSHIFT-GLMINZSHIFT-16+8, v4[3]	; Calculate starting I
	}
	
	neg		r5										; Sign flip ending w
`positiveendingw:
	{
	st_s	v5[1], (rv)								; Store starting t in rv
	sub		v6[0], v4[0], v1[3]						; V3[1] contains dz
	mul		r5, v4[1], >>v7[1], v4[1]				; Calculate ending s
	}
	{
	st_v	v2, (_MPEPolygonLeftEdge+64)			; Store scanline intensity values
	lsr		#01, v7[0]								; Convert 1/dX to unsigned quantity
	mul		r5, v4[2], >>v7[2], v4[2]				; Calculate ending t
	}
	{
	ld_s	(_MPEPolygonPixelPointer), v0[3]		; Load current DMA destination pointer
	sub		v5[0], v4[1], v2[3]						; V2[3] contains ds
	mul		r5, v2[2], >>#45+GLXYZWCLIPSHIFT-GLMINZSHIFT-16+8, v2[2]	; Calculate ending I
	}
	{
	st_s	v3[0], (rc0)							; Store pixel count in rc0
	sub		v5[1], v4[2], v3[3]						; V3[3] contains dt
	}
	{
	mv_s	v6[0], v6[3]							; V6[3] contains starting z
	sub		v4[3], v2[2], v5[3]						; v5[3] contains dI
	mul		v7[0], v2[3], >>#32, v2[3]				; V2[3] contains ds/dX
	}
	{
	ld_s	(_MPEPolygonGradient), v1[3]
	abs		v6[3]									; Insure z is positive
	mul		v7[0], v3[3], >>#32, v3[3]				; V3[3] contains dt/dX
	}
	mul		v7[0], v5[3], >>#32, v5[3]				; V5[3] contains dI/dX

	; Generic rasterization loop
	; Place pre loop stuff just after `RasterPreLoop, the loop just past 
	; `RasterLoop, and the post loop stuff just after `RasterPostLoop
	;
	; Register Equates
	; v0[3] = DMA destination pointer
	; v1[3] = dz/dx
	; v2[3] = ds/dx
	; v3[3] = dt/dx
	; v4[3] = destination I
	; v5[3] = dI/dX
	; v6[3] = destination z
	; rx/ru = starting texture s
	; ry/rv = starting texture t
	; rc0 = pixel countdown
	; rc1 = DMA countdown
	;
	; You may trash any registers except for v6[3] and rc1

	; Local equates
	p00 = v0
	p01 = v1
	p10 = v2
	p11 = v3
	p1 = v5
	p2 = v6


`RasterPreLoop:
	{
	mv_s	#01, v7[3]							; Set skip store flag
	sub		v1[3], >>#-1, v6[3]					; Pre-decrement z
	}
	sub		v5[3], >>#-1, v4[3]					; Pre-decrement I

`RasterLoop:
	; 1
	{
	ld_p	(xy), p00							; Load bilerp texel 00
	 add_p	p10, p11, p2						; Right filtered pixel complete
	 addm	v1[3], v6[3]						; Increment z
	addr	#1<<16, ry							; Increment bilinear y
	}

	; 2
	{
	ld_p	(xy), p01							; Load bilerp texel 01
	 sub_p	p1, p2								; Calculate horizontal difference
	 addm	v5[3], v4[3]						; Increment I
	addr	#1<<16, rx							; Increment bilinear x
	}

	; 3
	{
	ld_p	(xy), p11							; Load bilerp texel 11
	 cmp	#00, v7[3]							; Check skip store flag
	 mul_p	ru, p2, >>#30, p2					; Calculate filtered horizontal difference
	addr	#-1<<16, ry							; Decrement bilinear y
	}

	; 4
	{
	ld_p	(xy), p10							; Load bilerp texel 10
	sub_p	p00, p01							; Calculate left vertical difference
	addr	#-1<<16, rx							; decrement bilinear x
	}

	; 5
	{
	 bra	ne, `RasterLoop						; Skip store if first pass through loop
	 add_p	p1, p2								; Filtered texel complete
	mul_p	rv, p01, >>#30, p01						; Caclulate left vertical filtered difference
	addr	v2[3], rx							; Advance rx to next texel
	}

	; 6
	{
	bra		c0ne, `RasterLoop					; Branch if more pixels to process
	sub_p	p10, p11							; Calculate right vertical difference
	 mul_p	v4[3], p2, >>#30, p2				; Calculate lit pixel value
	addr	v3[3], ry							; Advance ry to next texel
	}
	 
	; 7
	{
	 mv_s	#00, v7[3]							; Deactive skip store flag
	add_p	p00, p01, p1						; Left vertical filtered pixel complete
	mul_p	rv, p11, >>#30, p11					; Calculate right vertical filtered difference
	addr	v3[3], rv							; Advance rv to next texel
	dec		rc0									; Decrement pixel counter
	}

	; 8
	{
	 st_pz	p2, (v0[3])							; Store filtered, lit pixel
	 add	#04, v0[3]							; Increment destination pixel pointer
	 addr	v2[3], ru							; Advance ru to next texel
	 dec	rc1									; Decrement DMA countdown
	}

`RasterPostLoop:



`DMACheck:
	ld_v	(_MPEPolygonLeftEdge+64), v2			; Load current Intensity data
	{
	ld_v	(_MPEPolygonScanlineValues), v3		; Load current scanline stuff
	bra		c1eq, `DMAwait
	sub		r0, r0								; Set r0 to zero for addm copying
	}
	nop	
	{
	mv_s	v3[0], v6[0]							; Copy in current z
	copy	v3[1], v5[0]							; Copy in current s/w
	addm	r0, v3[2], v5[1]						; Copy in current t/w
	}		
	{	
	bra		`CalculateStepSize
	ld_v	(_MPEPolygonGradient), v4			; Read x components of gradient
	abs		v3[3]								; Insure starting w is positive
	subm	v3[1], v3[1]						; Zero scanline remainder
	}
	{
	ld_s	(_MPEPolygonScanlineRemainder), v3[0]	; Copy in remaining dX
	msb		v3[3], r1							; Calculate MSB of current 1/w
	addm	r0, v3[3], v6[2]					; Copy in current left 1/w
	}
	st_s	v0[3], (_MPEPolygonPixelPointer)		; Store updated DMA destination pointer

`DMAwait:
	ld_s	(mdmactl), r0							; Read DMA control register
	ld_s	(_MPEPolygonScanlineRemainder), r7		; Load scanline remainder
	and		#$f, r0									; Check for DMA activity
	bra		ne, `DMAwait
	
`DoDMA:
	ld_s	(_MPEPolygonDMASourcePointer), r4
	ld_s	(_MPEPolygonX), r2
	ld_s	(_MPEPolygonDMASize), r5
	ld_s	(_MPEPolygonY), r3
	{
	ld_s	(_MPEDMAFlags), r0
	lsl		#16, r5
	addm	r2, r5, r6					; Increment polygon X
	}
	{
	ld_s	(_MPESDRAMPointer), r1
	bset	#16, r3						; YPOS input complete
	}
	{
	st_s	r4, (_MPEMDMACmdBuf+16)
	or		r5, r2						; XPOS input complete
	}
	{
	st_v	v0, (_MPEMDMACmdBuf)
	eor		#DMA_CACHE_EOR, r4			; Flip DMA buffers
	}
	st_s	#_MPEMDMACmdBuf, (mdmacptr)

`CheckScanlineRemainder:
	{
	cmp		#00, r7										; Check if any pixels are left on scanline
	st_s	r6, (_MPEPolygonX)							; Store updated polygon x
	}
	{
	st_s	r4, (_MPEPolygonDMASourcePointer)			; Store updated polygon DMA pointer
	bra		eq, `StepLeftEdge							; Branch if at end of scanline
	}
	{
	bra		`CalculateDMASize
	mv_s	r6, v7[3]									; Copy left current x into v7[3]
	abs		v3[3]										; Insure 1/w is positive
	subm	v3[1], v3[1]								; Zero scanline remainder
	}
	{
	mv_s 	v3[3], v6[2]								; Copy in current left 1/w
	msb		v3[3], r1									; Calculate MSB of current 1/w
	}
	{
	st_s	r4, (_MPEPolygonPixelPointer)				; Reset pixel destination pointer
	copy	r7, v3[0]									; Copy remaining dX into v3[0]
	}

	; Increment left and right edges
`StepLeftEdge:
	ld_v	(_MPEPolygonLeftEdge+48), v1		; Load intensity data
	ld_v	(_MPEPolygonLeftEdge), v7
	ld_v	(_MPEPolygonLeftEdge+16), v6
	{
	ld_v	(_MPEPolygonLeftEdge+32), v5	
	add		v7[1], v7[2]						; Increment left errorTerm
	addm	v7[0], v7[3]						; Increment left x
	}
	{
	ld_s	(_MPEPolygonY), r0					; Load current polygon y
	bra		le, `NoLeftOverflow					; Branch if errorTerm < 0
	add		v1[3], v1[2]						; Increment I/w
	}
	{
	ld_v	(_MPEPolygonEdgeExtra), v4			; Load height/denominators for both edges
	add		v6[1], v6[0]						; Increment z/w
	addm	v5[2], v5[0]						; Increment s/w
	}
	{
	ld_v	(_MPEPolygonGradient), v2			; Load x component of gradient
	add		v5[3], v5[1]						; Increment t/w
	addm	v6[3], v6[2]						; Increment 1/w
	}

`LeftOverFlow:
	add		v1[0], v1[2]						; Increment I/w
	{
	add		#01, v7[3]							; Increment x
	subm	v4[1], v7[2]						; Reset error term
	}

	{
	add		v2[0], v6[0]						; Increment z/w
	addm	v2[1], v5[0]						; Increment s/w
	}
	{
	add		v2[2], v5[1]						; Increment t/w
	addm	v2[3], v6[2]						; Increment 1/w
	}

`NoLeftOverflow:
	{
	st_v	v7, (_MPEPolygonLeftEdge)		; Store updated left edge info
	sub		#01, v4[0]						; Decrement height
	}
	{
	st_v	v6, (_MPEPolygonLeftEdge+16)	; Store updated left edge info
	}
	st_v	v1, (_MPEPolygonLeftEdge+48)	; Save edge intensity data
	{
	bra		gt, `StepRightEdge
	st_v	v5, (_MPEPolygonLeftEdge+32)	; Store updated left edge info
	add		#01, r0							; Increment polygon y
	}
	st_v	v4, (_MPEPolygonEdgeExtra)		; Store updated height/denominator
	st_s	r0, (_MPEPolygonY)				; Store updated polygon y

	; Prepare next left edge
	push	v7, rz										; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge								; Jump to edge calculation routine
	mv_s	#32, r1										; Set vertex increment to positive
	}
	ld_s	(pcexec), r2								; Load return address
	ld_s	(_MPEPolygonNextLeftVertexPointer), r0		; Load next vertex pointer
	pop		v7, rz
	
`StepRightEdge:
	ld_v	(_MPEPolygonRightEdge), v7			; Load right edge data
	ld_v	(_MPEPolygonEdgeExtra), v6			; Load height/denominator
	{
	add		v7[1], v7[2]						; Increment right errorTerm
	addm	v7[0], v7[3]						; Increment right x
	}
	bra		le, `NoRightOverflow, nop			; Branch if errorTerm < 0
	{
	add		#01, v7[3]							; Increment x
	subm	v6[3], v7[2]						; Reset errorTerm
	}

`NoRightOverflow:
	{
	st_v	v7, (_MPEPolygonRightEdge)				; Store updated edge parameters
	sub		#01, v6[2]								; Decrement edge height
	}
	{
	bra		ne, `WalkLoop, nop						; Jump to main loop if more left
	st_v	v6, (_MPEPolygonEdgeExtra)				; Updated edge data complete
	add		#01, r0									; Increment polygon y
	}

	; Prepare next right edge
	push	v7, rz									; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge							; Jump to edge calculation routine
	mv_s	#-32, r1								; Set vertex increment to positive
	}
	ld_s	(pcexec), r2							; Load return address
	ld_s	(_MPEPolygonNextRightVertexPointer), r0	; Load next vertex pointer
	{
	bra		`WalkLoop, nop
	pop		v7, rz
	}

	; Subroutines

	; Prepares an edge, pass vertex pointer in R0
	; 32 for a right edge or -32 for a left edge in R1
	; and return address in R2
	; Next vertex pointer is returned in R0
	; Affects R0-R30!!!! (R31 must be unaffected SML 9/30/98)
`PrepareEdge:
	{
	st_s	#9, rc0								; Store maximum vertex count
	copy	r1, r7								; Wait on load and save increment
	}
	st_s	r2, (rz)								; Store return address
`PrepEdge:
	{
	bra		c0eq, `EndPolygon
	mv_s	#3, r27								; Read number of vertices
	}
	ld_s	(_MPEPolygonVertex), r28			; R28 points to MPE Polygon Vertex List
	{
	ld_v	(r0), v2							; Read x1, y1, z1, 1/w1
	add		#16, r0								; Increment vertex pointer to s1/z1, t1/z1 
	addm	r7, r0, r26 						; R26 now points to second vertex
	}
	{
	ld_v	(r0), v3							; Read s1/w1, t1/w1, C
	cmp		r28, r26							; Check for vertex underflow
	mul		#16, r27, >>#-1, r27				; Calculate 32 * vertices 
	}
	{
	bra		ge, `nounderflow					; Jump if no underflow
	copy	r9, r25								; Copy fixed point y1 into r25
	}
	{
	mv_s	r8, r24								; Copy fixed point x1 into R24
	add		r27, r28, r29						; R29 points past end of active vertices
	dec		rc0									; Decrement vertex search counter
	}
	mv_s	#((1<<GLXYZSCREENSHIFT)-1), r30		; R30 contains ceiling rounder

	add		r27, r26							; Wrap vertex around to end of list
`nounderflow:
	cmp		r29, r26							; Check for vertex pointer overflow
	bra		ne, `nooverflow, nop				; Jump if no overflow

	sub		r27, r26							; Wrap vertex around to beginning of list

`nooverflow:
	{
	ld_v	(r26), v4							; Read x2, y2, z2, 1/w2
	add		r30, r8								; Round up x1
	addm	r30, r9								; Round up y1
	}
	{
	ld_v	(_MPEPolygonGradient), v5			; Read gradient x stuff
	asr		#GLXYZSCREENSHIFT, r9				; Integer y1 complete
	}
	{
	add		r30, r16							; Round up x2
	addm	r30, r17							; Round up y2
	}
	{
	asr		#GLXYZSCREENSHIFT, r17				; Integer y2 complete
	mul		#1, r8, >>#GLXYZSCREENSHIFT, r8		; Integer x1 complete
	}
	{
	sub		r9, r17, r30						; R30 contains height of edge
	mul		#1, r16, >>#GLXYZSCREENSHIFT, r16	; Integer x2 complete
	}

	bra		mi, `EndPolygon, nop				; Jump if polygon end reached
	bra		ne, `realedge, nop					; Jump if not a flat edge

	; Flat edge, jump to next vertex and try again
	{
	bra		`PrepEdge, nop
	mv_s	r26, r0					; Set current vertex to next vertex	
	}
	
	; Genuine edge, calculate Bresenham parameters 
`realedge:
	{
	push	v2, rz						; Save subroutine return address
	jsr		_FloorDivMod
	}
	{
	mv_s	r30, r1								; R1 = denominator = dY
	sub		r8, >>#(-GLXYZSCREENSHIFT), r24		; Calculate x prestep
	}
	{
	st_s	#00, (acshift)						; Set acshift to 0
	sub		r9, >>#(-GLXYZSCREENSHIFT), r25		; Calculate y prestep
	subm	r8, r16, r0							; R0 = numerator = dX
	}

	{
	mv_s	r30, r4								; Move edge height into R4
	copy	r8, r3								; Move initial x into R3
	addm	r1, r1								; Set numerator to 2X remainder
	}
	; Check for left/right edge
	{
	pop		v2, rz								; Restore subroutine return address
	cmp		#00, r7								; Check for left or right edge
	}

	{
	ld_v	(_MPEPolygonGradient), v5			; Load x components of gradient
	add		r4, r4, r5							; Set denominator to 2X edge height
	bra		ge, `leftedge
	}
	neg		r24									; Make x prestep positive
	neg		r25									; Make y prestep positive

`rightedge:
	st_s	r26, (_MPEPolygonNextRightVertexPointer)	; Store next right vertex
	{
	st_v	v0, (_MPEPolygonRightEdge)			; Store right edge Bresenham parameters
	rts
	}
	st_s	r4, (_MPEPolygonRightEdgeExtra)		; Store height
	st_s	r5, (_MPEPolygonRightEdgeExtra+4)	; Store denominator

	// Calculate all Bresenham parameters and prestep them to integer coordinates
	// If you don't do this, you get HORRIBLE texture swim
`leftedge:
	{
	st_s	v1[0], (_MPEPolygonLeftEdgeExtra)			; Store height
	copy	v2[2], v1[0]								; Copy z/w into v1[0]
	mul		r0, v5[1], >>acshift, v2[2]					; Calculate first component of s/wStep
	}
	{
	st_s	v1[1], (_MPEPolygonLeftEdgeExtra+4)			; Store denominator
	copy	v3[0], v2[0]								; Copy s1/w1 into v2[0]
	mul		r0, v5[0], >>acshift, v1[1]					; Calculate first component of zStep
	}
	{
	ld_v	(_MPEPolygonGradient+16), v4				; Load y components of gradient
	copy	v2[3], v1[2]								; Copy 1/w1 into R20
	mul		r0, v5[2], >>acshift, v2[3]					; Calculate first component of t/wStep
	}
	{
	st_s	v2[1], (_MPEPolygonY)						; Store current polygon y coordinate
	copy	v3[1], v2[1]								; Copy t1/w1 into v2[1]
	mul		r0, v5[3], >>acshift, v1[3]					; Calculate first component of 1/wStep
	}
	{
	st_v	v0, (_MPEPolygonLeftEdge)					; Store left edge Bresenham parameters	
	add		v4[0], v1[1]								; z/wStep complete
	mul		r24, v5[0], >>#GLXYZSCREENSHIFT, v5[0]		; Calculate d(z/w)/dX * xPrestep
	}
	{
	st_s	r26, (_MPEPolygonNextLeftVertexPointer)		; Store next left vertex
	add		v4[1], v2[2]								; s/wStep complete
	mul		r24, v5[1], >>#GLXYZSCREENSHIFT, v5[1]		; Calculate d(s/w)/dX * xPrestep
	}
	{
	mv_s	v3[2], r1									; Save I1/w1
	add		v4[2], v2[3]								; t/wStep complete
	mul		r24, v5[2], >>#GLXYZSCREENSHIFT, v5[2]		; Calculate d(t/w)/dX * xPrestep
	}
	{
	ld_v	(_MPEPolygonLeftEdge+48), v3				; Read intensity gradient
	add		v4[3], v1[3]								; 1/wStep complete
	mul		r24, v5[3], >>#GLXYZSCREENSHIFT, v5[3]		; Calculate d(1/w)/dX * xPrestep
	}
	{
	add		v5[0], v1[0]								; z1/w1 = (z1/w1) + d(z/w)/dx * xPrestep
	mul		r25, v4[0], >>#GLXYZSCREENSHIFT, v4[0]		; Calculate dz/dY * yPrestep
	}
	{
	mv_s	r1, v3[2]									; Restore I1/w1
	add		v5[1], v2[0]								; s1/w1 = s1/w1 + d(s/w)/dX * xPrestep
	mul		r25, v4[1], >>#GLXYZSCREENSHIFT, v4[1]		; Calculate d(s/w)/dY * yPrestep
	}
	{
	add		v5[2], v2[1]								; t1/w1 = t1/w1 + d(t/w)/dX * xPrestep
	mul		r25, v4[2], >>#GLXYZSCREENSHIFT, v4[2]		; Calculate d(t/w)/dY * yPrestep
	}
	{
	add		v5[3], v1[2]								; 1/w1 = 1/w1 + d(1/w)/dX * xPrestep
	mul		r25, v4[3], >>#GLXYZSCREENSHIFT, v4[3]		; Calculate d(1/w)/dY * yPrestep
	}
	{
	add		v4[0], v1[0]								; z1/w1 complete
	mul		r0, v3[0], >>acshift, v3[3]					; Calculate first component of I/wstep
	}
	{
	add		v4[3], v1[2]								; 1/w1 complete
	mul		v3[0], r24, >>#GLXYZSCREENSHIFT, r24		; Calculate d(I/w)/dX * xPrestep
	}
	{
	add		v4[1], v2[0]								; s1/w1 complete
	mul		v3[1], r25, >>#GLXYZSCREENSHIFT, r25		; Calculate d(I/w)/dY * yPrestep
	}
	add		v3[1], v3[3]								; I/wstep complete
	{
	rts
	st_v	v1, (_MPEPolygonLeftEdge+16)				; Store z/w    zStep 1/w     1/wStep
	add		v4[2], v2[1]								; t1/w1 complete
	addm	r24, v3[2]									; I1/w1 = I1/w1 + d(I/w)/dX * xPrestep
	}
	{
	st_v	v2, (_MPEPolygonLeftEdge+32)				; Store s/w  t/w   s/wStep t/wStep
	add		r25, v3[2]									; I1/w1 complete
	}
	st_v	v3, (_MPEPolygonLeftEdge+48)				; Save d(I/w)/dX  d(I/w)/dY  I1/w1   I/wstep

	; Move onto next polygon or clean up if done
`EndPolygon:
	pop		v7, rz							; Restore subroutine return
`EndPolygon1:
	ld_s	(_MPEPolygonVertices), r0		; Load current vertex count
	ld_s	(_MPEPolygonVertex), r1			; Load current vertex pointer
	sub		#01, r0							; Decrement vertex count
	{
	ld_v	(r1), v1						; Load 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex counter
	}
	{
	ld_v	(r1), v2						; Load 1st vertex uvC
	add		#16, r1							; Increment 1st vertex counter
	}
	st_s	r1, (_MPEPolygonVertex)			; Store new 1st vertex pointer
	cmp		#3, r0							; Check for last triangle
	{
	bra		ge, `PolygonLoop				; Jump if more triangles to rasterize
	st_s	r0, (_MPEPolygonVertices)		; Store new vertex count
	}
	{
	st_v	v1, (r1)						; Store 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex pointer
	}
	st_v	v2, (r1)
	
	; Clean up and exit
`RasterDone:
	rts		nop

.align.sv
_RasterSTFI_end:


	; White lit texture rasterization
.module RasSTI


	X0 = v7				// Vertex 0 vector
	x0 = r28
	y0 = r29
	z0 = r30
	w0 = r31
	X1 = v6				// Vertex 1 vector
	x1 = r24
	y1 = r25
	z1 = r26
	w1 = r27
	X2 = v5				// Vertex 2 vector
	x2 = r20
	y2 = r21
	z2 = r22
	w2 = r23
	S0 = v2
	s0 = r8
	t0 = r9
	I0 = r10
	a0 = r11
	S1 = v3
	s1 = r12
	t1 = r13
	I1 = r14
	a1 = r15
	S2 = v4
	s2 = r16
	t2 = r17
	I2 = r18
	a2 = r19
	C0 = v2
	C1 = v3
	C2 = v4

.export _RasterSTI_size
	_RasterSTI_size = _RasterSTI_end - _RasterSTI
.export _RasterSTI
.import _FloorDivMod
.import _MPEMDMACmdBuf
.import _MPEPolygonGradient
.import _MPEPolygonScanlineValues
.import _MPEPolygonVertexList
.import _MPEPolygonVertices
.import _MPEPolygonLeftEdge
.import _MPEPolygonLeftEdgeColor
.import _MPEPolygonRightEdge
.import _MPEPolygonX
.import _MPEPolygonY
.import _MPEPolygonDMASize
.import _MPEPolygonDMASourcePointer
.import _MPEPolygonPixelPointer
.import _MPESDRAMPointer
.import _MPEDMAFlags
.import _MPETextureParameter
.import _MPEPolygonScanlineRemainder
.import _MPEPolygonScanlineRecipLUT
.import _MPEPolygonNextLeftVertexPointer
.import _MPEPolygonNextRightVertexPointer
.import _MPERecipLUT
.align.s
_RasterSTI:
	mv_s	#_MPEPolygonVertexList, r0				; Initialize vertex list
	st_s	r0, (_MPEPolygonVertex)					; Kludge a 3 vertex polygon

	; Calculate Gradients from any 3 vertices (optimized for trivial accept)
	; Affects all registers


`PolygonLoop:
	ld_s	(_MPEPolygonVertex), r0
	nop

	; Stage 1, load data for triangle and calculate dV0 AND dV1
	{
	ld_v 	(r0), X2						; Load vertex 0 xyz1/w as X2
	add		#16, r0							; Increment vertex pointer					
	}
	{
	ld_v	(r0), S2						; Load vertex 0 uvY as S2
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X0						; Load vertex 1 xyz1/w as X0
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v 	(r0), S0						; Load vertex 1 uvY as S0
	add		#16, r0							; Increment vertex pointer
	}
	{
	ld_v	(r0), X1						; Load vertex 2 xyz1/w as X1
	add		#16, r0							; Increment vertex pointer
	subm	x2, x0							; Calculate x0 - x2		
	}
	{
	ld_v 	(r0), S1					; Load vertex 2 uvY as S1
	sub		y2, y0						; Calculate y0 - y2
	subm	w2, w0						; Calculate 1/w0 - 1/w2
	}
	

	; Calculate dX, dY d(s/w), d(t/w), d(I/w), d(1/w) and dZ
	{
	st_s	#GLXYZSCREENSHIFT, (acshift)	; Set acshift for dX products	
	sub		x2, x1							; Calculate x1 - x2
	subm	y2, y1							; Calculate y1 - y2
	}
	{
	msb		w0, r7							; R7 holds 1/w0 - 1/w2 MSB
	mul		x1, y0, >>acshift, x2			; X2 now contains (x1 - x2) * (y0 - y2)
	}

	{
	sub		w2, w1							; Calculate 1/w1 - 1/w2
	mul		x0, y1, >>acshift, y2			; Y2 now contains (x0 - x2) * (y1 - y2)
	}

	sub		z2, z1							; Calculate z1/w1 - z2/w2

	{
	sub		y2, x2, r0						; R1 now contains dX or signed area
	subm	z2, z0							; Calculate z0/w0 - z2/w2
	}

	{
	bra		le, `EndPolygon1				; If signed area < 0, skip polygon
	abs		r0								; Insure 1/dX denominator is positiive
	subm	I2, I1							; Calculate (I1/w1 - I2/w2) 
	}

	{
	msb		r0, r1							; Calculate dX MSB
	subm	s2, s1							; Calculate s1/w1 - s2/w2
	}
	
	{
	sub		#08, r1, r2						; R2 holds index shift for 1/dX
	subm	s2, s0							; Calculate s0/w0 - s2/w2
	}

	{
	mv_s	#_MPERecipLUT-128, r4			; R4 holds Reciprocal LUT pointer	
	ls		r2, r0, r3						; Convert dX into index offset
	subm	t2, t1							; Calculate t1/w1 - t2/w2
	}

	{
	mv_s	#$40000000, r3					; R3 holds unsigned LUT value conversion mask
	msb		w1, a0							; A0 holds 1/w1 - 1/w2 MSB
	addm	r3, r4							; R4 holds pointer to reciprocal LUT value
	}

	{
	ld_b	(r4), r5						; Load 8 bit reciprocal LUT value
	msb		w0, r6							; R6 holds 1/w0 - 1/w2 MSB
	subm	t2, t0							; Calculate t0/w0 - t2/w2
	}
	{
	cmp		r6, a0							; Check for greatest d(1/w) MSB
	subm	I2, I0							; Calculate (I0/w0 - I2/w2)
	}
	{
	bra		ge, `a0greater					; Branch if latter MSB is greater
	or		r5, >>#2, r3					; Convert 8 bit LUT value to 32 bit scalar
	}

	{
	msb		z1, a1							; A1 holds (z1 - z2) MSB
	mul		r3, r0, >>r1, r0				; Calculate xy
	}

	{
	mv_s	#$7fffffff, r4					; R4 holds TWO
	msb		z0, r7							; R7 holds (z0 - z2) MSB
	}

	mv_s	r6, a0							; d(1/w) MSB complete
`a0greater:
	msb		s1, s2							; Calculate s1/w1 - s2/w2 MSB
	{
	add		#(36-GLXYZSCREENSHIFT), r2		; Adjust 1/dX answer shift
	subm	r0, r4, r0		
	}

	{
	cmp		r7, a1							; Check for greater d(z/w) MSBs
	mul		r3, r0, >>r2, r0				; 1/dX complete
	}
	
	{
	bra		ge, `a1greater, nop	 			; Branch if latter MSB is greater
	msb		s0, r6							; R6 holds (s0/w0 - s2/w2) MSB 	
	}

	mv_s	r7, a1							; dz MSB complete
`a1greater:
	cmp		#20, a0							; Check if MSB of d(1/w) > 20
	{
	bra		le, `nowoverflow				; Jump if no overflow
	neg		r0								; Remove if signed area > 0
	}
	{
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default preshift value for multiplication
	msb		t1, t2							; T2 holds (t1/w1 - t0/w0) MSB
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default postshift value for multiplication
	msb		t0, a2							; A2 holds (t0/w0 - t2/w2) MSB
	}

	add		#GLXYZSCREENSHIFT-20, a0, r1	; R1 holds adjusted d(1/w) preshift
	sub		a0, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted d(1/w) postshift
`nowoverflow:
	{
	cmp		r6, s2							; Check for greater of d(s/w) MSBs
	st_s	r1, (acshift)					; Set preshift
	}
	{
	bra		ge, `s2greater					; Branch if latter MSB greater
	mul		w1, y0, >>acshift, w2			; w2 holds (1/w1 - 1/w2) * (y0 - y2)
	}
	mul		w0, y1, >>acshift, r7			; R7 holds (1/w0 - 1/w2) * (y1 - y2)
	{
	cmp		a2, t2							; Check for greater of d(t/w) MSBs
	mul		w0, x1, >>acshift, r3			; R3 holds (1/w0 - 1/w2) * (x1 - x2)
	}
	
	mv_s	r6, s2							; d(s/w) MSB complete
`s2greater:

	{
	bra		ge, `t2greater					; Branch if latter MSB greater
	sub		w2, r7							; R7 holds (1/w0 - 1/w2) * (y1 - y2) - (1/w1 - 1/w2) * (y0 - y2)
	mul		x0, w1, >>acshift, w2			; W2 holds (1/w1 - 1/w2) * (x0 - x2)
	}
	mul		r0, r7, >>r2, r7				; d(1/w)/dX complete
	cmp		#20, a1							; Check if mSB of dZ > 20
 
	mv_s	a2, t2							; A1 holds d(t/z) MSB
`t2greater:
	{
	bra		le, `nozoverflow				; Jump if MSB <=20
	msb		I0, a0							; A0 holds (I0/w0 - I2/w2) MSB
	subm	r3, w2							; w2 holds (1/w1 - 1/w2) * (x0 - x2) - (1/w0 - 1/w2) * (x1 - x2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default dZ preshift
	mul		r0, w2, >>r2, w2				; d(1/w)/dY complete
	}
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default postshift value for multiplication

	add		#GLXYZSCREENSHIFT-20, a1, r1	; R1 holds adjusted dZ preshift
	sub		a1, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted dZ postshift
`nozoverflow:
	{
	cmp		#20, s2							; Check d(s/z) MSB for overflow
	st_s	r1, (acshift)					; Set dz preshift
	}
	{
	bra		le, `nosoverflow				; Branch if MSB <= 20
	msb		I1, a1							; A1 holds (I1/w1 - I2/w2) MSB
	mul		z1, y0, >>acshift, x2			; x2 contains (z1 - z2) * (y0 - y2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, w0			; w0 holds default d(s/w) preshift
	mul		z0, y1, >>acshift, r4			; R4 contains (z0 - z2) * (y1 - y2)
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, w1			; w1 holds default d(s/w) postshift
	mul		z0, x1, >>acshift, r3			; R3 holds (z0 - z2) * (x1 - x2)
	}

	add		#GLXYZSCREENSHIFT-20, s2, w0	; w0 holds adjusted d(s/w) preshift
	sub		s2, #GLINVDXSCREENSHIFT+20, w1	; w1 holds adjusted d(s/w) postshift
`nosoverflow:
	{
	sub		x2, r4							; R4 holds (z0 - z2) * (y1 - y2) - (z1 - z2) * (y0 - y2)
	mul		z1, x0, >>acshift, x2 			; X2 holds (z1 - z2) * (x0 - x2)
	}
	{
	cmp		#20, t2							; Check d(t/w) MSB for overflow
	st_s	w0, (acshift)					; Set d(s/w) preshift
	mul		r0, r4, >>r2, r4				; R4 holds dz/dX
	}
	{
	bra		le, `notoverflow				; Branch if MSB <= 20
	sub		r3, x2							; X2 contains (z1 - z2) * (x0 - x2) - (z0 - x2) * (x1 - x2)
	mv_s	#GLXYZSCREENSHIFT, r1			; R1 holds default d(t/w) preshift
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, r2			; R2 holds default d(t/w) postshift
	mul		r0, x2, >>r2, x2				; x2 holds dz/dY
	}
	mul		s1, y0, >>acshift, y2			; Y2 contains (s1/w1 - s2/w2) * (y0 - y2)
	
	add		#GLXYZSCREENSHIFT-20, t2, r1	; R1 holds adjusted d(t/w) preshift
	sub		t2, #GLINVDXSCREENSHIFT+20, r2	; R2 holds adjusted d(t/w) postshift
`notoverflow:
	{
	cmp		a0, a1							; Compare d(I/w) MSBs
	mul		s0, y1, >>acshift, r5			; R5 contains (s0/w0 - s2/w2) * (y1 - y2)
	}
	{
	bra		ge, `a1greater1					; Branch if latter MSB is greater
	mul		s0, x1, >>acshift, r3			; R3 contains (s0/w0 - s2/w2) * (x1 - x2)
	}
	{
	st_s	r1, (acshift)					; Set d(t/w) preshift
	sub		y2, r5							; R5 holds (s0/w0 - s2/w2) * (y1 - y2) - (s1/w1 - s2/w2) * (y0 - y2)
	mul		s1, x0, >>acshift, y2			; Y2 contains (s1/w1 - s2/w2) * (x0 - x2)	
	}
	mul		r0, r5, >>w1, r5				; d(s/w)/dX complete

	mv_s	a0, a1							; d(I/w) MSB complete
`a1greater1:
	{
	sub		r3, y2							; Y2 holds (s1/w1 - s2/w2) * (x0 - x2) - (s0/w0 - s2/w2) * (x1 - x2)
	mul		t1, y0, >>acshift, z2			; Z2 contains (t1/w1 - t2/w2) * (y0 - y2)	
	}
	{
	cmp		#20, a1							; Check d(I/w) MSB for overflow
	mul		r0, y2, >>w1, y2				; d(s/w)/dY complete
	}
	{
	bra		le, `noioverflow				; Branch if MSB <= 20
	mul		t0, y1, >>acshift, r6			; R6 contains (t0/w0 - t2/w2) * (y1 - y2)
	}
	{
	mv_s	#GLXYZSCREENSHIFT, s2			; S2 holds default d(I/w) preshift
	mul		t0, x1, >>acshift, r3			; R3 contains (t0/w0 - t2/w2) * (x1 - x2)
	}
	{
	mv_s	#GLINVDXSCREENSHIFT, t2			; T2 holds default d(t/w) postshift
	sub		z2, r6							; R6 holds (t0/w0 - t2/w2) * (y1 - y2) - (t1/w1 - t2/w2) * (y0 - y2)
	mul		t1, x0, >>acshift, z2			; Z2 contains (t1/w1 - t2/w2) * (x0 - x2)
	}

	add		#GLXYZSCREENSHIFT-20, a1, s2	; S2 holds adjusted d(I/w) preshift
	sub		a1, #GLINVDXSCREENSHIFT+20, t2	; T2 holds adjusted d(I/w) postshift
`noioverflow:
	st_s	s2, (acshift)					; Set up d(I/w) preshift
	mul		r0, r6, >>r2, r6				; R6 contains d(t/w)/dX
	{
	sub		r3, z2							; Z2 holds (t1/w1 - t2/w2) * (x0 - x2) - (t0/w0 - t2/w2) * (x1 - x2)
	mul		I0, y1							; Y1 holds (I0/w0 - I2/w2) * (y1 - y2)
	}
	{
	st_v	v1, (_MPEPolygonGradient)		; Store dX component of polygon gradient
	mul		r0, z2, >>r2, z2				; Z2 contains d(t/w)/dY
	}
	mul		I1, y0							; Y0 holds (I1/w1 - I2/w2) * (y0 - y2)
	{
	mul		I0, x1							; X1 holds (I0/w0 - I2/w2) * (x1 - x2)
	st_v	X2, (_MPEPolygonGradient+16)	; Store dY component of polygon gradient
	}
	{
	mul		I1, x0							; X0 holds (I1/w1 - I2/w2) * (x0 - x2)
	}
	{
	st_s	t2, (acshift)
	sub		y0, y1							; Y1 holds (I0/w0 - I2/w2) * (y1 - y2) - (I1/w1 - I2/w2) * (y0 - y2)
	}
	{
	mul		r0, y1, >>acshift, x1			; d(I/w)/dX complete
	sub		x1, x0, y1						; X1 holds (I1/w1 - I2/w2) * (x0 - x2) - (I0/w0 - I2/w2) * (x1 - x2)
	}
	mul		r0, y1							; d(I/w)/dY complete
	nop
	st_v	X1, (_MPEPolygonLeftEdgeColor)	; Store Intensity gradients

	; Calculate color gradient (later SML 9/28/98)

	; All registers free
	
	; Calculate any additional reciprocal(s) (which only occur if clipping occurred
	; or somebody slipped us a polygon rather than a triangle)


	; Rasterization equates
	y = r30						; Current y
	leftVertex = r31			; Current left vertex
	rightVertex = r29			; Current right vertex
	
	; Find top vertex
	mv_s	#$7fffffff, y						; Set yTop to maximum
	ld_s	(_MPEPolygonVertex), r31			; Initial vertex pointer
	lsl		#01, y, r27							; Set R27 to yMin 
	{
	mv_s	#3, r28								; Load vertex count
	add		#04, r31							; Increment vertex pointer to y
	}
	mv_s	r31, r29							; Copy vertex pointer

`topsearch:
	ld_s	(r31), r0							; Load vertex y
	nop
	cmp		y, r0								; Check if new minimum y
	{
	bra		gt, `nonewminvertex, nop			; Jump if vertex is definitely not at top
	cmp		y, r27								; Check for new maximum y
	}

	; New minimum  y/vertex
	mv_s	r31, r29							; Copy current vertex into top vertex pointer
	mv_s	r0, y								; Copy current vertex y into minimum y pointer
`nonewminvertex:
	{
	bra		ge, `nonewmaxvertex, nop			; Jump if no new max y
	sub		#01, r28							; Decrement vertex count
	}

	mv_s	y, r27								; Set R27 to new yMax
`nonewmaxvertex:
	bra		ne, `topsearch						; Jump if more vertices to check
	add		#32, r31
	nop

	{
	mv_s	#32, r1								; Set increment input to left vertex
	sub		#04, r29							; Make vertex pointer point to vertex again
	}
	{
	mv_s	r29, r31							; Set current vertices to same vertex
	copy	r29, r0								; Set left vertex pointer for subroutine
	}

	; Prepare initial left edge
	push	v7, rz								; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge, nop
	ld_s	(pcexec), r2
	}

	; Prepare initial right edge
	{
	bra		`PrepareEdge
	mv_s	#-32, r1
	copy	r31, r0
	}
	ld_s	(pcexec), r2
	nop
	pop		v7, rz						; Restore edge pointers and subroutine return

	; Walk left and right edges and fire off scanlines
`WalkLoop:

	; Walk a scanline
	ld_s	(_MPEPolygonDMASourcePointer), r0	; R0 points to current DMA cache
	ld_v	(_MPEPolygonLeftEdge), v7			; Load left edge parameters
	st_s	r0, (_MPEPolygonPixelPointer)		; Store initial pixel destination pointer
	ld_v	(_MPEPolygonRightEdge), v4			; Load right edge parameters
	ld_v	(_MPEPolygonLeftEdge+32), v5		; Load additional left edge stuff
	ld_v	(_MPEPolygonLeftEdge+48), v2		; Read Intensity data
	{
	ld_v	(_MPEPolygonLeftEdge+16), v6		; Load final batch of left edge stuff
	sub		v7[3], v4[3], v3[0]					; Calculate scanline width
	subm	v3[1], v3[1]						; Set scanline remainder to 0
	}

`CalculateDMASize:
	{
	ld_v	(_MPEPolygonGradient), v4			; Read x components of gradient
	bra		le, `StepLeftEdge					; Jump if zero width scanline
	cmp		#64, v3[0]							; Check for maximum DMA length
	}	
	{
	bra		le, `CalculateStepSize
	st_s	v3[0], (rc1)						; Store scanline size in DMA countdown
	abs		v6[2]								; Insure 1/w is positive
	}
	{
	st_s	v7[3], (_MPEPolygonX)				; Store DMA starting x
	msb		v6[2], r1							; Calculate MSB of left 1/w
	}
	st_s	v3[0], (_MPEPolygonDMASize)			; Store likely DMA size

	mv_s	#64, r2
	st_s	r2, (rc1)							; Scanline bigger than 64 pixels
	st_s	r2, (_MPEPolygonDMASize)			; Store maximum DMA size

`CalculateStepSize:
	cmp		#GLMAXSUBDIVISION, v3[0]			; Check for subdivided affine steps
	{
	bra		le, `OneBigStep
	mv_s	#_MPERecipLUT-128, v3[2]			; V3[2] holds pointer to reciprocal lookup table
	sub		#08, r1, r2							; Calculate 1/w index shift
	}
	{
	mv_s	#$40000000, r4						; R4 holds reciprocal sign conversion mask
	}
	{
	mv_s	v2[0], v2[3]						; Copy d(I/w)/dX into v2[3]
	ls		r2, v6[2], r3						; Convert 1/w into index offset
	}
	{
	mv_s	#GLMAXSUBDIVISION, v3[0]			; Set scanline segment to maximum
	sub		#GLMAXSUBDIVISION, v3[0], v3[1]		; Calculate scanline remainder
	}
`OneBigStep:
	; OK
	; Calculate 1/1/w
	{
	mv_s	#$7fffffff, r0							; R0 holds 2.30 2
	add		v3[2], r3								; R3 holds index into reciprocal look-up
	mul		v3[0], v4[3], >>#0, v4[3]				; Calculate d(1/w)
	}
	{
	ld_b	(r3), r3								; R3 holds LUT value
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, r2		; Adjust shift value
	mul		v3[0], v4[0], >>#0, v4[0]				; Calculate dz
	}
	{
	st_s	v3[1], (_MPEPolygonScanlineRemainder)	; Store scanline remainder
	add		v6[2], v4[3]							; V4[3] = ending 1/w
	mul		v3[0], v4[1], >>#0, v4[1]				; Calculate d(s/w)
	}
	{
	mv_s	r4, v3[1]								; Save reciprocal sign conversion mask
	or		r3, >>#2, r4							; Convert reciprocal to unsigned quantity
	mul		v3[0], v4[2], >>#0, v4[2]				; Calculate d(t/w)
	}												; Ending 1/w can be outside polygon!
	{
	mv_s	v4[3], r5								; Save unsigned ending 1/w
	add		v6[0], v4[0]							; v4[0] = ending z
	mul		r4, v6[2], >>r1, v6[2]					; Calculate xy
	}
	{
	ld_s	(_MPETextureParameter), v7[2]			; V7[2] holds t shift (and texture parameter)
	abs		r5										; Make ending 1/w positive
	}
	{
	msb		r5, r1									; Calculate MSB of ending 1/w
	subm	v6[2], r0, v6[2]						; V5[0] = 2-xy
	}
	{
	sub		#08, r1, v3[3]							; V3[3] holds index shift
	addm	v5[0], v4[1]							; V4[1] = ending s/w
	}
	{
	lsr		#08, v7[2], v7[1]						; V7[1] holds s shift	
	mul		v3[0], v2[3], >>#0, v2[3]				; Calculate d(I/w)
	}
	{
	ls		v3[3], r5, r3							; R3 holds index offset
	mul		r4, v6[2], >>r2, v6[2]					; V6[2] holds starting w
	}
	{
	add		r3, v3[2], r3							; R3 now holds index to LUT
	}
	{
	ld_b	(r3), r3								; Load LUT value	
	add		#GLMINZSHIFT-GLXYZWCLIPSHIFT, v3[3]		; Adjust index shift value
	mul		v6[2], v5[0], >>v7[1], v5[0]			; Calculate starting s
	}
	{
	add		v5[1], v4[2]							; V4[2] = ending t/w
	mul		v6[2], v5[1], >>v7[2], v5[1]			; Calculate starting t
	}
	{
	st_s	v5[0], (rx)								; Store starting s in rx
	or		r3, >>#2, v3[1]							; Convert LUT value to unsigned quantity
	}
	{
	st_s	v5[0], (ru)								; Store starting s in ru
	mul		v3[1], r5, >>r1, r5						; Calculate xy
	}
	{
	st_v	v4, (_MPEPolygonScanlineValues)			; Store raster end values
	copy	v2[2], v4[3]						; Copy starting I/w into position
	}
	{
	cmp		#00, v4[3]								; Check if ending 1/w is positive
	st_s	v5[1], (ry)								; Store starting t in ry
	}
	{
	bra		ge, `positiveendingw
	mv_s	#_MPEPolygonScanlineRecipLUT-2, v7[0]	; V7[0] points to scanline Recip LUT
	subm	r5, r0, r5							; Calculate 2-xy
	}
	{
	add		v3[0], >>#-1, v7[0]						; V7[0] points to 16 bit reciprocal
	mul		v3[1], r5, >>v3[3], r5					; R5 contains ending w
	}
	{
	ld_w	(v7[0]), v7[0]							; V3 contains 1/dX	
	add		v2[3], v2[2]							; Calculate ending I/w
	mul		v6[2], v4[3], >>#45+GLXYZWCLIPSHIFT-GLMINZSHIFT-16+8, v4[3]	; Calculate starting I
	}
	
	neg		r5										; Sign flip ending w
`positiveendingw:
	{
	st_s	v5[1], (rv)								; Store starting t in rv
	sub		v6[0], v4[0], v1[3]						; V3[1] contains dz
	mul		r5, v4[1], >>v7[1], v4[1]				; Calculate ending s
	}
	{
	st_v	v2, (_MPEPolygonLeftEdge+64)			; Store scanline intensity values
	lsr		#01, v7[0]								; Convert 1/dX to unsigned quantity
	mul		r5, v4[2], >>v7[2], v4[2]				; Calculate ending t
	}
	{
	ld_s	(_MPEPolygonPixelPointer), v0[3]		; Load current DMA destination pointer
	sub		v5[0], v4[1], v2[3]						; V2[3] contains ds
	mul		r5, v2[2], >>#45+GLXYZWCLIPSHIFT-GLMINZSHIFT-16+8, v2[2]	; Calculate ending I
	}
	{
	st_s	v3[0], (rc0)							; Store pixel count in rc0
	sub		v5[1], v4[2], v3[3]						; V3[3] contains dt
	mul		v7[0], v1[3], >>#32, v1[3]				; v1[3] contains dz/dX
	}
	{
	mv_s	v6[0], v6[3]							; V6[3] contains starting z
	sub		v4[3], v2[2], v5[3]						; v5[3] contains dI
	mul		v7[0], v2[3], >>#32, v2[3]				; V2[3] contains ds/dX
	}
	{
	ld_s	(_MPEPolygonGradient), v1[3]
	abs		v6[3]									; Insure z is positive
	mul		v7[0], v3[3], >>#32, v3[3]				; V3[3] contains dt/dX
	}
	mul		v7[0], v5[3], >>#32, v5[3]				; V5[3] contains dI/dX

	; Generic rasterization loop
	; Place pre loop stuff just after `RasterPreLoop, the loop just past 
	; `RasterLoop, and the post loop stuff just after `RasterPostLoop
	;
	; Register Equates
	; v0[3] = DMA destination pointer
	; v1[3] = dz/dx
	; v2[3] = ds/dx
	; v3[3] = dt/dx
	; v4[3] = destination I
	; v5[3] = dI/dX
	; v6[3] = destination z
	; rx/ru = starting texture s
	; ry/rv = starting texture t
	; rc0 = pixel countdown
	; rc1 = DMA countdown
	;
	; You may trash any registers except for v6[3] and rc1

	; Local equates

	p1 = v5
	p2 = v6


`RasterPreLoop:
	{
	ld_p	(xy), p1					; Load pixel data
	addr	v2[3], rx					; Increment bilinear x
	}
	{
	addr	v3[3], ry					; Increment bilinear y
	dec		rc0							; Decrement loop countdown
	}

`RasterLoop:
	; 1
	{
	bra		c0ne, `RasterLoop
	ld_p	(xy), p1					; Load texel data
 	 add		v5[3], v4[3]			; Increment light
	 mul_p		v4[3], p1, >>#30, p2	; Light texel
	addr	v2[3], rx					; Increment bilinear x
	}

	; 2
	{
	addr	v3[3], ry					; Increment bilinear y
	dec		rc1							; Decrement DMA countdown
	dec		rc0							; Decrement loop countdown
	}

	; 3
	{
	 st_pz	p2, (v0[3])					; Store output texel
	 add	#04, v0[3]					; Increment destination pointer
	 addm	v1[3], v6[3]				; Increment desination z
	}
	

`RasterPostLoop:



`DMACheck:
	ld_v	(_MPEPolygonLeftEdge+64), v2			; Load current Intensity data
	{
	ld_v	(_MPEPolygonScanlineValues), v3		; Load current scanline stuff
	bra		c1eq, `DMAwait
	sub		r0, r0								; Set r0 to zero for addm copying
	}
	nop	
	{
	mv_s	v3[0], v6[0]							; Copy in current z
	copy	v3[1], v5[0]							; Copy in current s/w
	addm	r0, v3[2], v5[1]						; Copy in current t/w
	}		
	{	
	bra		`CalculateStepSize
	ld_v	(_MPEPolygonGradient), v4			; Read x components of gradient
	abs		v3[3]								; Insure 1/w is positive
	subm	v3[1], v3[1]						; Zero scanline remainder
	}
	{
	ld_s	(_MPEPolygonScanlineRemainder), v3[0]	; Copy in remaining dX
	msb		v3[3], r1							; Calculate MSB of current 1/w
	addm	r0, v3[3], v6[2]					; Copy in current left 1/w
	}
	st_s	v0[3], (_MPEPolygonPixelPointer)		; Store updated DMA destination pointer

`DMAwait:
	ld_s	(mdmactl), r0							; Read DMA control register
	ld_s	(_MPEPolygonScanlineRemainder), r7		; Load scanline remainder
	and		#$f, r0									; Check for DMA activity
	bra		ne, `DMAwait
	
`DoDMA:
	ld_s	(_MPEPolygonDMASourcePointer), r4
	ld_s	(_MPEPolygonX), r2
	ld_s	(_MPEPolygonDMASize), r5
	ld_s	(_MPEPolygonY), r3
	{
	ld_s	(_MPEDMAFlags), r0
	lsl		#16, r5
	addm	r2, r5, r6					; Increment polygon X
	}
	{
	ld_s	(_MPESDRAMPointer), r1
	bset	#16, r3						; YPOS input complete
	}
	{
	st_s	r4, (_MPEMDMACmdBuf+16)
	or		r5, r2						; XPOS input complete
	}
	{
	st_v	v0, (_MPEMDMACmdBuf)
	eor		#DMA_CACHE_EOR, r4			; Flip DMA buffers
	}
	st_s	#_MPEMDMACmdBuf, (mdmacptr)

`CheckScanlineRemainder:
	{
	cmp		#00, r7										; Check if any pixels are left on scanline
	st_s	r6, (_MPEPolygonX)							; Store updated polygon x
	}
	{
	st_s	r4, (_MPEPolygonDMASourcePointer)			; Store updated polygon DMA pointer
	bra		eq, `StepLeftEdge							; Branch if at end of scanline
	}
	{
	bra		`CalculateDMASize
	mv_s	r6, v7[3]									; Copy left current x into v7[3]
	abs		v3[3]										; Insure 1/w is positive
	subm	v3[1], v3[1]								; Zero scanline remainder
	}
	{
	mv_s 	v3[3], v6[2]								; Copy in current left 1/w
	msb		v3[3], r1									; Calculate MSB of current 1/w
	}
	{
	st_s	r4, (_MPEPolygonPixelPointer)				; Reset pixel destination pointer
	copy	r7, v3[0]									; Copy remaining dX into v3[0]
	}

	; Increment left and right edges
`StepLeftEdge:
	ld_v	(_MPEPolygonLeftEdge+48), v1		; Load intensity data
	ld_v	(_MPEPolygonLeftEdge), v7
	ld_v	(_MPEPolygonLeftEdge+16), v6
	{
	ld_v	(_MPEPolygonLeftEdge+32), v5	
	add		v7[1], v7[2]						; Increment left errorTerm
	addm	v7[0], v7[3]						; Increment left x
	}
	{
	ld_s	(_MPEPolygonY), r0					; Load current polygon y
	bra		le, `NoLeftOverflow					; Branch if errorTerm < 0
	add		v1[3], v1[2]						; Increment I/w
	}
	{
	ld_v	(_MPEPolygonEdgeExtra), v4			; Load height/denominators for both edges
	add		v6[1], v6[0]						; Increment z/w
	addm	v5[2], v5[0]						; Increment s/w
	}
	{
	ld_v	(_MPEPolygonGradient), v2			; Load x component of gradient
	add		v5[3], v5[1]						; Increment t/w
	addm	v6[3], v6[2]						; Increment 1/w
	}

`LeftOverFlow:
	add		v1[0], v1[2]						; Increment I/w
	{
	add		#01, v7[3]							; Increment x
	subm	v4[1], v7[2]						; Reset error term
	}

	{
	add		v2[0], v6[0]						; Increment z/w
	addm	v2[1], v5[0]						; Increment s/w
	}
	{
	add		v2[2], v5[1]						; Increment t/w
	addm	v2[3], v6[2]						; Increment 1/w
	}

`NoLeftOverflow:
	{
	st_v	v7, (_MPEPolygonLeftEdge)		; Store updated left edge info
	sub		#01, v4[0]						; Decrement height
	}
	{
	st_v	v6, (_MPEPolygonLeftEdge+16)	; Store updated left edge info
	}
	st_v	v1, (_MPEPolygonLeftEdge+48)	; Save edge intensity data
	{
	bra		gt, `StepRightEdge
	st_v	v5, (_MPEPolygonLeftEdge+32)	; Store updated left edge info
	add		#01, r0							; Increment polygon y
	}
	st_v	v4, (_MPEPolygonEdgeExtra)		; Store updated height/denominator
	st_s	r0, (_MPEPolygonY)				; Store updated polygon y

	; Prepare next left edge
	push	v7, rz										; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge								; Jump to edge calculation routine
	mv_s	#32, r1										; Set vertex increment to positive
	}
	ld_s	(pcexec), r2								; Load return address
	ld_s	(_MPEPolygonNextLeftVertexPointer), r0		; Load next vertex pointer
	pop		v7, rz
	
`StepRightEdge:
	ld_v	(_MPEPolygonRightEdge), v7			; Load right edge data
	ld_v	(_MPEPolygonEdgeExtra), v6			; Load height/denominator
	{
	add		v7[1], v7[2]						; Increment right errorTerm
	addm	v7[0], v7[3]						; Increment right x
	}
	bra		le, `NoRightOverflow, nop			; Branch if errorTerm < 0
	{
	add		#01, v7[3]							; Increment x
	subm	v6[3], v7[2]						; Reset errorTerm
	}

`NoRightOverflow:
	{
	st_v	v7, (_MPEPolygonRightEdge)				; Store updated edge parameters
	sub		#01, v6[2]								; Decrement edge height
	}
	{
	bra		ne, `WalkLoop, nop						; Jump to main loop if more left
	st_v	v6, (_MPEPolygonEdgeExtra)				; Updated edge data complete
	}

	; Prepare next right edge
	push	v7, rz									; Save edge pointers and subroutine return					
	{
	bra		`PrepareEdge							; Jump to edge calculation routine
	mv_s	#-32, r1								; Set vertex increment to positive
	}
	ld_s	(pcexec), r2							; Load return address
	ld_s	(_MPEPolygonNextRightVertexPointer), r0	; Load next vertex pointer
	{
	bra		`WalkLoop, nop
	pop		v7, rz
	}

	; Subroutines

	; Prepares an edge, pass vertex pointer in R0
	; 32 for a right edge or -32 for a left edge in R1
	; and return address in R2
	; Next vertex pointer is returned in R0
	; Affects R0-R30!!!! (R31 must be unaffected SML 9/30/98)
`PrepareEdge:
	{
	st_s	#9, rc0								; Store maximum vertex count
	copy	r1, r7								; Wait on load and save increment
	}
	st_s	r2, (rz)								; Store return address
`PrepEdge:
	{
	bra		c0eq, `EndPolygon
	mv_s	#3, r27								; Read number of vertices
	}
	ld_s	(_MPEPolygonVertex), r28			; R28 points to MPE Polygon Vertex List
	{
	ld_v	(r0), v2							; Read x1, y1, z1, 1/w1
	add		#16, r0								; Increment vertex pointer to s1/z1, t1/z1 
	addm	r7, r0, r26 						; R26 now points to second vertex
	}
	{
	ld_v	(r0), v3							; Read s1/w1, t1/w1, C
	cmp		r28, r26							; Check for vertex underflow
	mul		#16, r27, >>#-1, r27				; Calculate 32 * vertices 
	}
	{
	bra		ge, `nounderflow					; Jump if no underflow
	copy	r9, r25								; Copy fixed point y1 into r25
	}
	{
	mv_s	r8, r24								; Copy fixed point x1 into R24
	add		r27, r28, r29						; R29 points past end of active vertices
	dec		rc0									; Decrement vertex search counter
	}
	mv_s	#((1<<GLXYZSCREENSHIFT)-1), r30		; R30 contains ceiling rounder

	add		r27, r26							; Wrap vertex around to end of list
`nounderflow:
	cmp		r29, r26							; Check for vertex pointer overflow
	bra		ne, `nooverflow, nop				; Jump if no overflow

	sub		r27, r26							; Wrap vertex around to beginning of list

`nooverflow:
	{
	ld_v	(r26), v4							; Read x2, y2, z2, 1/w2
	add		r30, r8								; Round up x1
	addm	r30, r9								; Round up y1
	}
	{
	ld_v	(_MPEPolygonGradient), v5			; Read gradient x stuff
	asr		#GLXYZSCREENSHIFT, r9				; Integer y1 complete
	}
	{
	add		r30, r16							; Round up x2
	addm	r30, r17							; Round up y2
	}
	{
	asr		#GLXYZSCREENSHIFT, r17				; Integer y2 complete
	mul		#1, r8, >>#GLXYZSCREENSHIFT, r8		; Integer x1 complete
	}
	{
	sub		r9, r17, r30						; R30 contains height of edge
	mul		#1, r16, >>#GLXYZSCREENSHIFT, r16	; Integer x2 complete
	}

	bra		mi, `EndPolygon, nop				; Jump if polygon end reached
	bra		ne, `realedge, nop					; Jump if not a flat edge

	; Flat edge, jump to next vertex and try again
	{
	bra		`PrepEdge, nop
	mv_s	r26, r0					; Set current vertex to next vertex	
	}
	
	; Genuine edge, calculate Bresenham parameters 
`realedge:
	{
	push	v2, rz						; Save subroutine return address
	jsr		_FloorDivMod
	}
	{
	mv_s	r30, r1								; R1 = denominator = dY
	sub		r8, >>#(-GLXYZSCREENSHIFT), r24		; Calculate x prestep
	}
	{
	st_s	#00, (acshift)						; Set acshift to 0
	sub		r9, >>#(-GLXYZSCREENSHIFT), r25		; Calculate y prestep
	subm	r8, r16, r0							; R0 = numerator = dX
	}

	{
	mv_s	r30, r4								; Move edge height into R4
	copy	r8, r3								; Move initial x into R3
	addm	r1, r1								; Set numerator to 2X remainder
	}
	; Check for left/right edge
	{
	pop		v2, rz								; Restore subroutine return address
	cmp		#00, r7								; Check for left or right edge
	}

	{
	ld_v	(_MPEPolygonGradient), v5			; Load x components of gradient
	add		r4, r4, r5							; Set denominator to 2X edge height
	bra		ge, `leftedge
	}
	neg		r24									; Make x prestep positive
	neg		r25									; Make y prestep positive

`rightedge:
	st_s	r26, (_MPEPolygonNextRightVertexPointer)	; Store next right vertex
	{
	st_v	v0, (_MPEPolygonRightEdge)			; Store right edge Bresenham parameters
	rts
	}
	st_s	r4, (_MPEPolygonRightEdgeExtra)		; Store height
	st_s	r5, (_MPEPolygonRightEdgeExtra+4)	; Store denominator

	// Calculate all Bresenham parameters and prestep them to integer coordinates
	// If you don't do this, you get HORRIBLE texture swim
`leftedge:
	{
	st_s	v1[0], (_MPEPolygonLeftEdgeExtra)			; Store height
	copy	v2[2], v1[0]								; Copy z/w into v1[0]
	mul		r0, v5[1], >>acshift, v2[2]					; Calculate first component of s/wStep
	}
	{
	st_s	v1[1], (_MPEPolygonLeftEdgeExtra+4)			; Store denominator
	copy	v3[0], v2[0]								; Copy s1/w1 into v2[0]
	mul		r0, v5[0], >>acshift, v1[1]					; Calculate first component of zStep
	}
	{
	ld_v	(_MPEPolygonGradient+16), v4				; Load y components of gradient
	copy	v2[3], v1[2]								; Copy 1/w1 into R20
	mul		r0, v5[2], >>acshift, v2[3]					; Calculate first component of t/wStep
	}
	{
	st_s	v2[1], (_MPEPolygonY)						; Store current polygon y coordinate
	copy	v3[1], v2[1]								; Copy t1/w1 into v2[1]
	mul		r0, v5[3], >>acshift, v1[3]					; Calculate first component of 1/wStep
	}
	{
	st_v	v0, (_MPEPolygonLeftEdge)					; Store left edge Bresenham parameters	
	add		v4[0], v1[1]								; z/wStep complete
	mul		r24, v5[0], >>#GLXYZSCREENSHIFT, v5[0]		; Calculate d(z/w)/dX * xPrestep
	}
	{
	st_s	r26, (_MPEPolygonNextLeftVertexPointer)		; Store next left vertex
	add		v4[1], v2[2]								; s/wStep complete
	mul		r24, v5[1], >>#GLXYZSCREENSHIFT, v5[1]		; Calculate d(s/w)/dX * xPrestep
	}
	{
	mv_s	v3[2], r1									; Save I1/w1
	add		v4[2], v2[3]								; t/wStep complete
	mul		r24, v5[2], >>#GLXYZSCREENSHIFT, v5[2]		; Calculate d(t/w)/dX * xPrestep
	}
	{
	ld_v	(_MPEPolygonLeftEdge+48), v3				; Read intensity gradient
	add		v4[3], v1[3]								; 1/wStep complete
	mul		r24, v5[3], >>#GLXYZSCREENSHIFT, v5[3]		; Calculate d(1/w)/dX * xPrestep
	}
	{
	add		v5[0], v1[0]								; z1/w1 = (z1/w1) + d(z/w)/dx * xPrestep
	mul		r25, v4[0], >>#GLXYZSCREENSHIFT, v4[0]		; Calculate dz/dY * yPrestep
	}
	{
	mv_s	r1, v3[2]									; Restore I1/w1
	add		v5[1], v2[0]								; s1/w1 = s1/w1 + d(s/w)/dX * xPrestep
	mul		r25, v4[1], >>#GLXYZSCREENSHIFT, v4[1]		; Calculate d(s/w)/dY * yPrestep
	}
	{
	add		v5[2], v2[1]								; t1/w1 = t1/w1 + d(t/w)/dX * xPrestep
	mul		r25, v4[2], >>#GLXYZSCREENSHIFT, v4[2]		; Calculate d(t/w)/dY * yPrestep
	}
	{
	add		v5[3], v1[2]								; 1/w1 = 1/w1 + d(1/w)/dX * xPrestep
	mul		r25, v4[3], >>#GLXYZSCREENSHIFT, v4[3]		; Calculate d(1/w)/dY * yPrestep
	}
	{
	add		v4[0], v1[0]								; z1/w1 complete
	mul		r0, v3[0], >>acshift, v3[3]					; Calculate first component of I/wstep
	}
	{
	add		v4[3], v1[2]								; 1/w1 complete
	mul		v3[0], r24, >>#GLXYZSCREENSHIFT, r24		; Calculate d(I/w)/dX * xPrestep
	}
	{
	add		v4[1], v2[0]								; s1/w1 complete
	mul		v3[1], r25, >>#GLXYZSCREENSHIFT, r25		; Calculate d(I/w)/dY * yPrestep
	}
	add		v3[1], v3[3]								; I/wstep complete
	{
	rts
	st_v	v1, (_MPEPolygonLeftEdge+16)				; Store z/w    zStep 1/w     1/wStep
	add		v4[2], v2[1]								; t1/w1 complete
	addm	r24, v3[2]									; I1/w1 = I1/w1 + d(I/w)/dX * xPrestep
	}
	{
	st_v	v2, (_MPEPolygonLeftEdge+32)				; Store s/w  t/w   s/wStep t/wStep
	add		r25, v3[2]									; I1/w1 complete
	}
	st_v	v3, (_MPEPolygonLeftEdge+48)				; Save d(I/w)/dX  d(I/w)/dY  I1/w1   I/wstep

	; Move onto next polygon or clean up if done
`EndPolygon:
	pop		v7, rz							; Restore subroutine return
`EndPolygon1:
	ld_s	(_MPEPolygonVertices), r0		; Load current vertex count
	ld_s	(_MPEPolygonVertex), r1			; Load current vertex pointer
	sub		#01, r0							; Decrement vertex count
	{
	ld_v	(r1), v1						; Load 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex counter
	}
	{
	ld_v	(r1), v2						; Load 1st vertex uvC
	add		#16, r1							; Increment 1st vertex counter
	}
	st_s	r1, (_MPEPolygonVertex)			; Store new 1st vertex pointer
	cmp		#3, r0							; Check for last triangle
	{
	bra		ge, `PolygonLoop				; Jump if more triangles to rasterize
	st_s	r0, (_MPEPolygonVertices)		; Store new vertex count
	}
	{
	st_v	v1, (r1)						; Store 1st vertex xyzw
	add		#16, r1							; Increment 1st vertex pointer
	}
	st_v	v2, (r1)
	
	; Clean up and exit
`RasterDone:
	rts		nop
.align.sv
_RasterSTI_end:
