;
; rsqrt -- compute reciprocal square root: (1 / sqrt(x))
;
; Copyright 1996 VM Labs, Inc., all rights reserved
;
; Usage ==========================
;
;	r0 <- the fixed-point, positive argument
;	r1 <- number of fraction bits in the argument
;	call rsqrt
;	r0 -> the answer
;	r1 -> number of fraction bits in the answer
;
; Example =========================
;
;	mv_s	rn,r0		; put arg value in input register
;	mv_s	#result_fracBits,r1 ; and pass input fracbits
;	jsr	rsqrt		; call rsqrt
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
	.module	rsqrt
	.export	rsqrt
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
; The algorithm, expressed in a C-like language:
;
;    RSqrt(x,fracBits) {
;      RefineResult(y) {
;	 // returns: 3 / 2 - (x * y) * (y / 2)
;	 temp = (x * y) >> frac
;	 temp = (temp * y) >> (iPrec + 1)
;	 return ((threeHalves - temp) * y) >> iPrec
;      }
;      shift1 = (SigBits(x) - fracBits + 1) & ~1
;      ansFBits = iPrec + (shift1 / 2)
;      frac = fracBits + shift1
;      shift2 = frac - indexBits
;      y = lut[(x >> shift2) - tableOffset]
;      y = RefineResult(y)
;      y = RefineResult(y)
;      return FixNum(y,ansFBits)
;    }
;

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
tableOffset = (1 << indexBits) / 4 ; 64 ; this should be 2^(indexBits - 2)
iPrec = 29 ; was 28
sizeOfScalar = 4

;
; The "rsqrt" code.
;
	.segment instruction_ram
rsqrt:
;
; Compute shift = (SigBits(x) - fracBits, rounded *up* to an even
; number).
;
	msb	x,shift1
	sub	fracBits,shift1
	add	#1,shift1
	and	#~1,shift1
;
; Compute a shift amount for extracting a LUT index from the argument
; and get an initial approximation of the answer.
;
{	mv_s	x,temp
	addm	fracBits,shift1,frac
	asr	#1,shift1
}
{	mv_s	#RSqrtLUT - tableOffset * sizeOfScalar,lut
	sub	#indexBits + 2,frac,shift2
}	
{	mv_s	#fix(1.5,iPrec),threeHalves
	as	shift2,x,shiftedX
}
{	add	shiftedX,lut
}
{	ld_s	(lut),y
}
 
;;; just to make the test work...
;        nop
;        lsl     #1,y

;
; Refine the answer using "y *= (3 / 2 - x * y * y / 2)".
; Also, in the idle slots after mul instructions, compute fracBits of
; the answer.
;
	nop
	mul	y,temp,>>frac,temp
	mv_s	#iPrec,ansFBits
	mul	y,temp,>>#iPrec + 1,temp
	add	shift1,ansFBits
	sub	temp,threeHalves,temp
	mul	temp,y,>>#iPrec,y
	nop
;
; Refine the answer again, same formula.
;
	mul	y,x,>>frac,answer
	nop
	mul	y,answer,>>#iPrec + 1,answer
	rts
	sub	answer,threeHalves,answer
	mul	y,answer,>>#iPrec,answer
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
; 96/03/03 - rja - time for a complete rewrite -- accomodates new "mul"
;	definition and cleans up a bit
; 96/02/15 - rja - rewrite to new conventions
; <date unknown> - mh revised to avoid use of the (late lamented) MUL_AC
;	instruction...ought to be re-optimized!
; subroutine linkage, register optimization
; using Linkage conventions
