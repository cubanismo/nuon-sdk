/*
 * Copyright (C) 1996-2001 VM Labs, Inc.
 * 
 *  NOTICE: VM Labs permits you to use, modify, and distribute this file
 *  in accordance with the terms of the VM Labs license agreement
 *  accompanying it. If you have received this file from a source other
 *  than VM Labs, then your use, modification, or distribution of it
 *  requires the prior written permission of VM Labs.
 *
 * All rights reserved.
 */
;
; sqrt -- compute square root
;
;
;
; ENTRY POINTS:
;
; _FixSqrt: calculate square root of an n.n fixed point number
; Inputs:
;      r0 == fixed point (positive) argument
;      r1 == fracbits in argument
; Outputs:
;      r0 == result (with the same number of fracbits
;            as argument)
;
; _FixRSqrt: calculate reciprocal square root of an n.n fixed point number
; Inputs:
;      r0 == fixed point (positive) argument
;      r1 == fracbits in argument
;      r2 == fracbits in result
; Outputs:
;      r0 == result (with the same number of fracbits
;            specified for result)
;
; __fix_sqrt:  calculate sqrt of an n.n fixed point number
; Inputs:
;	r0 == the fixed-point, positive argument
;	r1 == number of fraction bits in the argument
; Outputs:
;	r0 == the answer
;	r1 == number of fraction bits in the answer
;
; __fix_rsqrt:  calculate reciprocal sqrt of an n.n fixed point number
; Inputs:
;	r0 == the fixed-point, positive argument
;	r1 == number of fraction bits in the argument
; Outputs:
;	r0 == the answer
;	r1 == number of fraction bits in the answer
;
; Example =========================
;
;	mv_s	rn,r0		; put arg value in input register
;	mv_s	#result_fracBits,r1 ; and pass input fracbits
;	jsr	__fix_sqrt	; call sqrt
;;
;; The answer is now in r0 (at max precision), and the number of
;; fraction bits in the answer is in r1.
;;
;; If you wish to store the answer in rN with a specified number of
;; fraction bits, do the following.
;;
;	sub	#desired_fracBits,r1
;	as	r1,r0,rN	; move & shift answer into a register
;

;
; Interface ========================
;
	.module	sqrt
	.export	__fix_sqrt, __fix_rsqrt
	.export _FixSqrt, _FixRSqrt
	
	.text
_FixSqrt:
	ld_s	rz,v2[1]
	jsr	__fix_sqrt
	mv_s	r1,v2[0]	; save fracbits for result (original fracbits)
	nop

	jmp	(v2[1])		; return
	sub	v2[0],r1	; set up for desired number of fracbits
	as	r1,r0		; and shift
	
_FixRSqrt:
	ld_s	rz,v2[1]
	jsr	__fix_rsqrt
	mv_s	r2,v2[0]	; save fracbits for result
	nop

	jmp	(v2[1])		; return
	sub	v2[0],r1	; set up for desired number of fracbits
	as	r1,r0		; and shift
	
;
; Input parameters
;
x		= r0		; input, > 0
fracBits	= r1		; number of fraction bits in x
;
; Results
;	
answer		= r0		; the answer: 1 / sqrt(x)
ansFBits	= r1		; number of fraction bits in the answer


;
; Implementation ====================
;

;
; Working register declarations
;
shift1 = r3
sigBits = r2
intBits = r4
shift2 = r7
shiftedX = r7
frac = r5
lut = r6
y = r6
temp = r3
threeHalves = r7
;
; Some symbolic constants
;
indexBits = 8
tableOffset = (1 << indexBits) / 4
iPrec = 29
sizeOfScalar = 4

;--------------------------------------------------------------------------
;
; The "sqrt" code.
;
	.data
	.include "rsqrtlut.i"
	
	.text
__fix_sqrt:
;
; First, compute 1 / sqrt(x) using the "rsqrt" algorithm.
;
; Compute shift = (SigBits(x) - fracBits, rounded *up* to an even
; number).
;
	msb	x,sigBits
	sub	fracBits,sigBits,intBits
	add	#1,intBits,shift1
	and	#~1,shift1
;
; Compute a shift amount for extracting a LUT index from the argument
; and get an initial approximation of the answer.
;
{	addm	fracBits,shift1,frac
	asr	#1,shift1
}
{	mv_s	#RSqrtLUT - tableOffset * sizeOfScalar,lut
	sub	#indexBits + 2,frac,shift2
}	
{	mv_s	#iPrec,ansFBits
	as	shift2,x,shiftedX
}
{	add	shiftedX,lut
}
{	ld_s	(lut),y
	add	shift1,ansFBits
}
;
; Refine the answer using "y *= (3 / 2 - x * y * y / 2)".
; Also, in the idle slots after mul instructions, compute fracBits of
; the answer.
;
	copy	x,temp
	mul	y,temp,>>frac,temp
	nop
	mul	y,temp,>>#iPrec + 1,temp
	mv_s	#fix(1.5,iPrec),threeHalves
	sub	temp,threeHalves,temp
	mul	temp,y,>>#iPrec,y
	copy	x,temp
;
; Refine the answer again, same formula.
;
	mul	y,x,>>frac,answer
	sub	intBits,ansFBits
	mul	y,answer,>>#iPrec + 1,answer
	nop
	sub	answer,threeHalves,answer
	mul	y,answer,>>#iPrec,answer
	rts
;
; Multiply the recip square root by x to get the square root.
;
	mul	temp,answer,>>sigBits,answer
	nop

;--------------------------------------------------------------------------
;
; The "rsqrt" code.
;

__fix_rsqrt:
;
; Compute 1 / sqrt(x) using the "rsqrt" algorithm.
;
; Compute shift = (SigBits(x) - fracBits, rounded *up* to an even
; number).
;
	msb	x,sigBits
	sub	fracBits,sigBits,intBits
	add	#1,intBits,shift1
	and	#~1,shift1
;
; Compute a shift amount for extracting a LUT index from the argument
; and get an initial approximation of the answer.
;
{	addm	fracBits,shift1,frac
	asr	#1,shift1
}
{	mv_s	#RSqrtLUT - tableOffset * sizeOfScalar,lut
	sub	#indexBits + 2,frac,shift2
}	
{	mv_s	#iPrec,ansFBits
	as	shift2,x,shiftedX
}
{	add	shiftedX,lut
}
{	ld_s	(lut),y
	add	shift1,ansFBits
}
;
; Refine the answer using "y *= (3 / 2 - x * y * y / 2)".
; Also, in the idle slots after mul instructions, compute fracBits of
; the answer.
;
	copy	x,temp
	mul	y,temp,>>frac,temp
	nop
	mul	y,temp,>>#iPrec + 1,temp
	mv_s	#fix(1.5,iPrec),threeHalves
	sub	temp,threeHalves,temp
	mul	temp,y,>>#iPrec,y
	copy	x,temp
;
; Refine the answer again, same formula.
;
	mul	y,x,>>frac,answer
	nop
	mul	y,answer,>>#iPrec + 1,answer
	nop
{	sub	answer,threeHalves,answer
	rts
}
	mul	y,answer,>>#iPrec,answer
	nop


;        1         2         3         4         5         6         7         8
;---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
;
; Revision history
;
; 98/06/10 - ers - made it C-callable
; 96/06/24 - rja - updated for new "rts" form
; 96/04/18 - rja - update for latest instruction set
; 96/03/11 - rja & mh - adjust parameters and touch up algorithm for more
;	accurate result
; 96/03/04 - rja - created from rsqrt.a
