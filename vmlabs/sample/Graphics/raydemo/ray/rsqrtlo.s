
; rsqrtlo -- compute reciprocal square root: (1 / sqrt(x))
	;;Copyright (c) 1997-2001 VM Labs, Inc.
	;; All rights reserved.
	;; Confidential and Proprietary Information of VM Labs, Inc.
	;; 
 	;; NOTICE: VM Labs permits you to use, modify, and distribute this file
 	;; in accordance with the terms of the VM Labs license agreement
 	;; accompanying it. If you have received this file from a source other
	;; than VM Labs, then your use, modification, or distribution of it
 	;; requires the prior written permission of VM Labs.
;
;
; Usage ==========================
;
;	r0 <- the fixed-point, positive argument
;	r1 <- number of fraction bits in the argument
;	call rsqrt
;	ac -> the answer
;	r1 -> number of fraction bits in the answer
;
; Example =========================
;
;	mv_s	rn,r0		; put arg value in input register
;	mv_s	#result_fracBits,r1 ; and pass input fracbits
;	jsr	rsqrtlo		; call rsqrtlo
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
	.module	rsqrtlo
	.export	rsqrtlo
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
; Working register declarations
;
shift1 = r2
shift2 = r3
shiftedX = r3
frac = r7
lut = r4
y = r4
temp = r6
threeHalves = r5
;
; Some symbolic constants
;
indexBits = 8
tableOffset = (1 << indexBits) / 4
iPrec = 29
sizeOfScalar = 4

;
; The "rsqrtlo" code.
;
	
rsqrtlo:
;
; Compute shift = (SigBits(x) - fracBits, rounded *up* to an even
; number).
;
	msb	x,shift1
{	subm	fracBits,shift1
        cmp     #0,x
}
{	add	#1,shift1
        bra     le,die1
}
	and	#~1,shift1
;
; Compute a shift amount for extracting a LUT index from the argument
; and get an initial approximation of the answer.
;
{	addm	fracBits,shift1,frac
	asr	#1,shift1
	mv_s	#RSqrtLUT - tableOffset * sizeOfScalar,lut
}
{	sub	#indexBits + 2,frac,shift2
}	
{	mv_s	#iPrec,ansFBits
	as	shift2,x,shiftedX
}
{	add	shiftedX,lut
}
	ld_s	(lut),y
	add	shift1,ansFBits
;
; Refine the answer using "y *= (3 / 2 - x * y * y / 2)".
;
	mul	y,x,>>frac,answer
	mv_s	#fix(1.5,iPrec),threeHalves
	;; NOTE: acshift has 30 in it, and iPrec == 29, so this is the same as
	;; mul y,answer,>>#iPrec + 1, answer
	mul	y,answer,>>acshift,answer
	rts
	sub	answer,threeHalves,answer
	mul	y,answer,>>#iPrec,answer

die1:
        rts
        mv_s    #0,r0
        mv_s    #28,r1
;
; Return to caller with mul in process -- "answer" won't be ready until
; 2nd packet following call.
;

;        1         2         3         4         5         6         7         8
;---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
;
; Revision history
; ----------------
; 96/06/24 - rja - updated for new "rts" form
; 96/04/18 - rja - update for latest instruction set
; 96/03/11 - rja & mh - adjust parameters and touch up algorithm for more
;	accurate result
; 96/03/05 - rja - created from rsqrt
