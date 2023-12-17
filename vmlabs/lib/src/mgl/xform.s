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

; _TransformXYZW8: vertex format x, y, z, w, plus 4 arbitrary scalars

.module Xform1
	; Transformation matrix equates
	M11 = v2
	m11 = r8
	m12 = r9
	m13 = r10
	m14 = r11
	M21 = v3
	m21 = r12
	m22 = r13
	m23 = r14
	m24 = r15
	M31 = v2
	m31 = r8
	m32 = r9
	m33 = r10
	m34 = r11
	M41 = v3
	m41 = r12
	m42 = r13
	m43 = r14
	m44 = r15
	XS = v4
	xs = r16
	ys = r17
	zs = r18
	ws = r19
	X = v5
	x = r20
	y = r21
	z = r22
	w = r23
	XT = v6
	xt = r24
	yt = r25
	zt = r26
	wt = r27
	AXT = v7
	axt = r28
	ayt = r29
	azt = r30
	awt = r31
	ccode = r0
	svp = r1
	dvp = r2
	dcp = r3
	wsign = r4
	s = r5
	thirtytwo = r6

	; Imports
.import _MPEVertexCache
.import _MPEMatrix
.export _TransformXYZW8
.export _TransformXYZW8_size

_TransformXYZW8_size = _EndTransformXYZW8 - _TransformXYZW8	
.align.v

	; Expects rc0 preloaded with vertex count
_TransformXYZW8:
	; Do preliminaries
	{
	mv_s	#_MPEVertexCache, svp					; Initialize destination vertex pointer
	sub_sv	AXT, AXT								; Zero absolute transformed xyzw
	}
	{
	mv_s	#32, thirtytwo							; Thirty two constant
	sub		#16, svp, dcp							; Set destination clip code pointer
	mvr		svp, rx									; Copy source vertex pointer into rx
	}
	{
	st_s	#GLTRIGSHIFT, (acshift)					; Set up fixed point shift
	sub		#16, dcp, dvp							; Copy source vertex pointer into dvp
	mvr		dcp, ru									; Set first clip code pointer
	}
	
	; Vertex transformation main loop (19 cycles)
`morevertices:

	; 1
	{
	 mv_s	#-63, ccode								; Initialize clip code
	 add	xs, ayt									; Add x component of y'
 	mvr		dvp, ry									; Copy destination vertex pointer into ry
	}

	; 2
	{
	ld_v	(svp), X								; Load incoming xyzw
	 cmp	awt, axt								; Check for x clipping
	 addm	w, ayt									; Add w component of y'
	addr	thirtytwo, rx							; Increment source vertex pointer
	}

	; 3
	{
	 bra	le, `noxclip							; Branch if no x clipping needed
	ld_v	(_MPEMatrix), M11						; Load 1st row of transformation matrix
	 asr	#31, wt, wsign							; Calculate clip code sign conversion mask
	 addm	zs, ayt									; y' complete
	}

	; 4
	{
	ld_v	(_MPEMatrix+48), M41					; Load 4th row of transformation matrix
	 copy	ayt, yt									; Copy y' into final position (xywz' complete)
	 mul	wsign, ccode, >>#0, ccode				; Clipping code initialized
	}

	; 5
	{
	 st_v	XT, (dvp)								; Store transformed vertex
	 abs	ayt										; Calculate |y'|
	mul		m11, x, >>acshift, axt					; Calculate x component of x'
	 addr	thirtytwo, ry							; Increment destination vertex pointer
	}


	; Handle x clip code
	 asr	#31, xt									; Convert xt to -1 or 0
	 eor	wsign, xt								; Account for negative w
	 eor	#CLIP_XMAX_MASK, >>xt, ccode			; Or in appropriate clip code
`noxclip:
	; 6
	{
	 mv_s	zt, azt									; Copy z' into |z'|
	 cmp	awt, ayt								; Check for y clipping
	mul		m12, y, >>acshift, ys					; Calculate y component of x'
	}

	; 7
	{
	 bra	le, `noyclip							; Branch if no clipping needed
	ld_s	(rx), svp								; Load source vertex pointer
	 abs	azt										; Calculate |z'|
	mul		m13, z, >>acshift, zs					; Calculate z component of z'
	}

	; 8
	{
	 ld_s	(ru), dcp								; Load clipping code pointer
	add		ys, axt									; Add y component of x'
	mul		m14, w, >>acshift, ws					; Calculate w component of x'
	}

	; 9
	{
	ld_s	(ry), dvp								; Load destination vertex pointer
	add		zs, axt									; Add z component of x'
	mul		m41, x, >>acshift, xs					; Calculate x component of w'
	}

	; Handle y clip code
	 asr	#31, yt									; Convert yt to -1 or 0
	 eor	wsign, yt								; Account for negative w
	 eor	#CLIP_YMAX_MASK, >>yt, ccode			; Or in appropriate clip code
`noyclip:
	; 10
	{
	 ld_s	(dcp), s								; Load vertex parameter (texture s for now)
	 cmp	awt, azt								; Check for z clipping
	mul		m42, y, >>acshift, awt					; Calculate y component of w'
	}

	; 11
	{
	 bra	le, `nozclip							; Branch if no z clipping needed
	ld_v	(_MPEMatrix+32), M31					; Load third row of transformation matrix
	add		ws, axt									; x' complete
	mul		m43, z, >>acshift, zs					; Calculate z component of w'
	}

	; 12
	{
	ld_v	(_MPEMatrix+16), M21					; Load 2nd row of transformation matrix
	add		xs, awt									; Add x component of w'
	mul		m44, w, >>acshift, ws					; Calculate w component of w'
	}

	; 13
	{
	add		zs, awt									; Add z component of w'
	mul		m31, x, >>acshift, xs					; Calculate x component of z'
	}

	; Handle z clip code
	 asr	#31, zt									; Convert zt to -1 or 0
	 eor	wsign, zt								; Account for negative w
	 eor	#CLIP_ZMAX_MASK, >>zt, ccode			; Or in appropriate clip code
`nozclip:
	; 14
	{
	add		ws, awt									; w' complete
	mul		m32, y, >>acshift, zt					; Calculate y component of z'
	}

	; 15
	{
	mv_s	axt, xt									; Copy x' into final position
	abs		axt										; Calculate |x'|
	mul		m33, z, >>acshift, zs					; Calculate z component of z'
	}

	; 16
	{
	mv_s	awt, wt									; Copy w' into final position
	add		xs, zt									; Add x component of z'
	mul		m34, w, >>acshift, ws					; Calculate w component of z'
	}

	; 17
	{
	add		zs, zt									; Add z component of z'
	mul		m21, x, >>acshift, xs					; Calculate x component of y'
	}

	; 18
	{
	bra		c0ne, `morevertices						; Branch if more vertices to process
	add		ws, zt									; z' complete
	mul		m22, y, >>acshift, ayt					; Calculate y component of y'
	}

	; 19
	{
	 or		s, ccode								; Or vertex parameter with clip code (clip code complete)
	mul		m23, z, >>acshift, zs					; Calculate z component of y'
	addr	thirtytwo, ru							; Increment clip code pointer
	dec		rc0										; Decrement vertex counter
	}

	; 20
	{
	 st_s	ccode, (dcp)							; Store clip code
	abs		awt										; Calculate |w'|
	mul		m24, w									; Calculate w component of y'
	}

.align.sv
`endtransform:
_EndTransformXYZW8:


; _TransformXYZ4: vertex format x, y, z, plus 1 arbitrary scalar

.module Xform2
	; Transformation matrix equates
	M11 = v2
	m11 = r8
	m12 = r9
	m13 = r10
	m14 = r11
	M21 = v3
	m21 = r12
	m22 = r13
	m23 = r14
	m24 = r15
	M31 = v2
	m31 = r8
	m32 = r9
	m33 = r10
	m34 = r11
	M41 = v3
	m41 = r12
	m42 = r13
	m43 = r14
	m44 = r15
	XS = v4
	xs = r16
	ys = r17
	zs = r18
	ws = r19
	X = v5
	x = r20
	y = r21
	z = r22
	w = r23
	XT = v6
	xt = r24
	yt = r25
	zt = r26
	wt = r27
	AXT = v7
	axt = r28
	ayt = r29
	azt = r30
	awt = r31
	ccode = r0
	svp = r1
	dvp = r2
	dcp = r3
	wsign = r4
	thirtytwo = r5
	dpp = r6
	linpixsave = r7

	; Imports
.import _MPEVertexCache
.import _MPEMatrix
.export _TransformXYZ4
.export _TransformXYZ4_size


_TransformXYZ4_size = _EndTransformXYZ4 - _TransformXYZ4

.align.v

	; Expects rc0 preloaded with vertex count
_TransformXYZ4:
	mv_s	#_MPEVertexCache+96, svp		; Initialize source vertex pointer
	mv_s	#32, thirtytwo					; Useful number
	{
	ld_s	(linpixctl), linpixsave			; Save linpixctl
	sub		#128, svp, dvp					; Set destination vertexpointer
	}
	{
	st_s	#$400000, (linpixctl)			; Set linpixctl for inner loop
	add		#16, dvp, dcp					; Set destination clip code pointer
	}
	{
	st_s	#GLTRIGSHIFT, (acshift)			; Set up fixed point shift
	add		#08, dcp, dpp					; Set extracted color pointer
	}

	; 21 cycle loop
`morevertices:
	; 1
	{
	ld_v	(svp), X									; Load incoming xyzc
	 cmp	awt, axt									; Check for x-clip violation
	}
	; 2
	{
	 bra	le, `noxclip								; Branch if within bounds
	ld_v	(_MPEMatrix), M11							; Load first row of matrix
	add		#12, svp									; Increment source vertex pointer
	}
	; 3
	{
	 st_v	XT, (dvp)									; Store transformed vertex
	 abs	azt											; Get magnitude of transformed z
	 mul	wsign, ccode, >>#0, ccode					; Account for w sign in clipping code
	}
	; 4
	{
	 st_sv	M21, (dpp)									; Store decompressed vertex color
	 add	thirtytwo, dvp								; Increment destination vertex pointer
	mul		m11, x, >>acshift, axt						; Calculate x component of x'
	}

	; Handle x clip code
   	 asr		#31, xt									; Convert xt to -1 or 0
	 eor		wsign, xt								; Account for negative w
	 eor		#CLIP_XMAX_MASK, >>xt, ccode			; Or in appropriate clip code
`noxclip:	
	; 5
	{
	ld_v 	(_MPEMatrix+16), M21						; Load 2nd row of matrix
	 cmp	awt, ayt									; Test for y-clip code violation
	mul		m12, y, >>acshift, ys						; Calculate y component of x'
	}

	; 6
	{
	 bra	le, `noyclip								; Branch if no clip code violation
	ld_v	(_MPEMatrix+32), M31						; Load 3rd row of matrix
	add		m14, >>#(GLTRIGSHIFT-GLXYZWMODELSHIFT), axt ; Add w component of x'
	mul		m13, z, >>acshift, zs						; Calculate z component of x'
	}

	; 7
	{
	add		ys, axt										; Add y component of x'
	mul		m21, x, >>acshift, xs						; Calculate x component of y'
	}

	; 8
	{
	add		zs, axt										; Add z component of x'
	mul		m22, y, >>acshift, ayt						; Calculate y component of y'
	}

	; Handle y clip code
   	 asr		#31, yt									; Convert yt to -1 or 0
	 eor		wsign, yt								; Account for negative w
	 eor		#CLIP_YMAX_MASK, >>yt, ccode			; Or in appropriate clip code
`noyclip:
	; 9
	{
	cmp		awt, azt									; Test for z-clip code violation
	mul		m23, z, >>acshift, zs						; Calculate z component of y'
	}

	; 10
	{
	 bra	le, `nozclip								; Branch if no clip code violation
	add		xs, ayt										; Add x component of y'
	mul		m31, x, >>acshift, xs						; Calculate x component of z' 
	}

	; 11
	{
	ld_v 	(_MPEMatrix+48), M41						; Load row 4 of matrix
	add		m24, >>#(GLTRIGSHIFT-GLXYZWMODELSHIFT), ayt	; Add w component of y'
	mul		m33, z, >>acshift, azt						; Calculate z component of z'
	}

	; 12
	{
	add		zs, ayt										; Add z component of y'
	mul		m32, y, >>acshift, ys						; Calculate y component of z'
	}


	; Handle z clip code
   	 asr	#31, zt										; Convert zt to -1 or 0
	 eor	wsign, zt									; Account for negative w
	 eor	#CLIP_ZMAX_MASK, >>zt, ccode				; Or in appropriate clip code
`nozclip:
	; 13
	{
	st_s	ccode, (dcp)								; Store final clip code
	add		xs, azt										; Add x component of z'
	mul		m41, x, >>acshift, awt						; Calculate x component of w'
	}

	; 14
	{
	add		ys, azt										; Add y component of z'
	mul		m42, y, >>acshift, ys						; Calculate y component of w'
	}

	; 15
	{
	mv_s	axt, xt										; Copy x'
	add		m34, >>#(GLTRIGSHIFT-GLXYZWMODELSHIFT), azt	; Add w component of z'
	mul		m43, z, >>acshift, zs						; Calculate z component of w'
	}

	; 16
	{
	ld_pz	(svp), M21									; Read vertex color
	add		m44, >>#(GLTRIGSHIFT-GLXYZWMODELSHIFT), awt	; Add w component of w'
	}
	
	; 17
	{
	abs		axt											; Calculate magnitude of x'
	addm	ys, awt										; Add y component of w'
	}

	; 18
	{
	mv_s	ayt, yt										; Copy y'
	abs		ayt											; Calculate magnitude of y'
	addm	zs, awt										; Add z component of w'
	}

	; 18a
	lsr #2, M21[3]										; make alpha 2.30

	; 19
	{
	bra		c0ne, `morevertices
	mv_s	azt, zt										; Copy z'
	add		#04, svp									; Increment source vertex pointer
	}

	; 20
	{
	bra		`endtransform								; Branch to end of transform
	mv_s	awt, wt										; Copy w'
	abs		awt											; Calculate magnitude of w'
	addm	thirtytwo, dcp								; Increment clip code pointer
	dec		rc0											; Decrement vertex counter
	}

	; 21
	{
	mv_s	#-63, ccode									; Initialize clipping code
	asr		#31, wt, wsign								; Calculate w sign mask
	addm	thirtytwo, dpp								; Increment dest vertex color pointer
	}

	; Restore linpixctl
	st_s	linpixsave, (linpixctl)
	
.align.sv
`endtransform:
_EndTransformXYZ4:
