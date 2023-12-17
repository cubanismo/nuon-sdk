
/*Copyright (C) 1996-2001 VM Labs, Inc. 

 NOTICE: VM Labs permits you to use, modify, and distribute this file
 in accordance with the terms of the VM Labs license agreement
 accompanying it. If you have received this file from a source other
 than VM Labs, then your use, modification, or distribution of it
 requires the prior written permission of VM Labs.

All rights reserved.
*/

; sqrt -- compute square root
;
; Copyright 1996 VM Labs, Inc., all rights reserved
;
; Usage ==========================
;
;	r0 <- the fixed-point, positive argument
;	r1 <- number of fraction bits in the argument
;	call sqrt
;	r0 -> the answer
;	r1 -> number of fraction bits in the answer
;
; Example =========================
;
;	mv_s	rn,r0		; put arg value in input register
;	mv_s	#input_fracBits,r1 ; and pass input fracbits
;	jsr	sqrt		; call sqrt
;
; The answer is now in r0 (at max precision), and the number of
; fraction bits in the answer is in r1.
;
; If you wish to store the answer in rN with a specified number of
; fraction bits, do the following.
;
;	sub	#desired_fracBits,r1  ; r1 -= desired_fracBits
;	as	r1,r0,rN	; rN = r0 >> r1
;

;
; Interface ========================
;
	.module	sqrt

	.export	sqrt

	.import	RSqrtLUT_32

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
sigBits = r2
intBits = r4
shift1 = r3
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

;
; The "sqrt" code.
;
;	.segment instruction_ram
	.segment text
sqrt:
;
; First, compute 1 / sqrt(x) using the "rsqrt" algorithm.
;
; Compute shift = (SigBits(x) - fracBits, rounded *up* to an even
; number).
;
	
	nop
    cmp #0,x
    rts eq

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
{	mv_s	#RSqrtLUT_32 - tableOffset * sizeOfScalar,lut
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
{	rts
	mul	y,answer,>>#iPrec,answer
}
	nop
;
; Multiply the recip square root by x to get the square root.
;
	mul	temp,answer,>>sigBits,answer
;
; Return to caller with mul in process -- "answer" won't be ready until
; 2nd packet following call.
;

;        1         2         3         4         5         6         7         8
;---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
;
; Revision history
;
; 97/05/97 - mh - fixed comments
; 96/06/24 - rja - updated for new "rts" form
; 96/04/18 - rja - update for latest instruction set
; 96/03/11 - rja & mh - adjust parameters and touch up algorithm for more
;	accurate result
; 96/03/04 - rja - created from rsqrt.a
