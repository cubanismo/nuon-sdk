/*
 * Copyright (C) 1995-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */

;**************
;* Subroutine: find the inverse of a 4x3 transformation matrix
;*
;* inputs:	r1 == pointer to input matrix
;*		r0 == pointer to output matrix
;***************
;
;
; STACK NEEDED: 12 long words
;
;* Algorithm: we know that the matrix is of the form
;* M = TR, where T is a pure translation and R is a pure
;* rotation. It's easy to find Minv(T) and Minv(R).
;*
;* registers used:
;* v2,v3,v4,v5 hold transpose of rotation part of matrix
;* v1 holds rows as they are built

	.module tminv_s
	.export _tminv, _tminv_end

	.align CODEALIGN
_tminv:

{	ld_v	(r1),v1
	add		#16,r1
}
	push	v5
	push	v4
	push	v3

{	mv_s	r4,r8		; set v2[0]
	copy	r5,r12	; set v3[0]
}
{	mv_s	r6,r16		; set v4[0]
	sub		r7,#0,r20	; set v5[0] to -r7
}
{	ld_v	(r1),v1
}
{	add		#16,r1		; let load complete
}
{	mv_s	r4,r9		; set v2[1]
	copy	r5,r13	; set v3[1]
}
{	mv_s	r6,r17		; set v4[1]
	sub		r7,#0,r21	; set v5[1] to -r7
}
{	ld_v	(r1),v1
}
{	add		#16,r1		; let load complete
}
{	mv_s	r4,r10		; set v2[2]
	copy	r5,r14	; set v3[2]
}
{	mv_s	r6,r18		; set v4[2]
	sub		r7,#0,r22	; set v5[2] to -r7
}
{	ld_v	(r1),v1
}
{	add		#16,r1		; let load complete
}
{	mv_s	r4,r11		; set v2[3]
	copy	r5,r15	; set v3[3]
}
{	mv_s	r6,r19		; set v4[3]
	copy	r7,r23	; set v5[3]	(it's always 1, but so is r7 now)
}

;* find Minv(R)*v5 (v5 is now the negative of the position vector in T)

	dotp	v2,v5,>>#30,r4
	dotp	v3,v5,>>#30,r5
	dotp	v4,v5,>>#30,r19		; set v4[3] directly!

;* copy the translated vector into the right place in the new matrix
{	mv_s	r4,r11		; sets v2[3]
	copy	r5,r15		; sets v3[3]
}

;* save the inverted matrix
{	st_v	v2,(r0)
	add		#16,r0
}
{	st_v	v3,(r0)
	add		#16,r0
}
	st_v	v4,(r0)
	pop		v3
{	pop		v4
	rts
}
	pop		v5
	nop

_tminv_end:
