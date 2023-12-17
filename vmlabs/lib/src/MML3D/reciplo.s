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
; reciplo -- compute reciprocal (low precision)
;
; Usage ==========================
;
;	r0 <- the fixed-point, positive argument
;	r1 <- number of fraction bits in the argument
;	call reciplo
;	r0 -> the reciprocal
;	r1 -> number of fraction bits in the reciprocal
;
; Example =========================
;
;	mv_s	rn,r0		; put arg value in input register
;	mv_s	#fracBits,r1	; and pass input fracbits
;	jsr	reciplo		; call reciplo
;;
;; The answer is now in r0 (at max precision), and the number of fraction bits
;; in the answer is in r1.
;;
;; To store the answer in rn with a desired number of fraction bits, do the
;; following.
;;
;	sub	#desired_fracBits,r1
;	ls	r1,r0,rn	; move & shift result into another register
;

;
; Interface ========================
;
	.module	reciplo
;
; Input parameters
;
x = r0				; the number to "recip"
fracBits = r1			; fracBits of X
;
; Results
;	
answer = r0			; the reciprocal
ansFBits = r1			; fracBits of the reciprocal


;
; Implementation ====================
;
; The algorithm, expressed in a pseudo-code (for a definition of the
; pseudo-code, see "The Icon Programming Language" :-)
;
;   procedure reciplo(x,fracBits)
;	sigBits := SigBits(x)
;	ansFBits := sigBits - fracBits + iPrec
;	index := ishift(x,-(sigBits - (index_bits + 1))) - 128 + 1
;	y := RecipLUT[index]
;	two := Fix(2,iPrec)
;	y := ishift(y * (two - ishift(x * y,-sigBits)),-iPrec)
;	return FixNum(y,ansFBits)
;   end
;
; Working register declarations
;
sigBits = r2				; fracBits in normalized argument
indexShift = r3
lut = r4				; used for divide-LUT lookup
y = r3					; used for iterative result
two = r5				; holds a constant 2 (3.29)
;
; Some symbolic constants
;
iPrec = 29				; intermediate working precision
indexBits = 7				; nbr of bits used for table lookup
sizeOfScalar = 2


;
; The "reciplo" code.
;
	.text
	.export _reciplo, _reciplo_end
	.import RecipLUT
	.align 32
_reciplo:
;
; Normalize the input X -- figure out how many bits to shift.
;
{	mv_s	#RecipLUT - 128 * sizeOfScalar,lut ; start computing LUT ptr
	msb	x,sigBits		; compute sig bits of input x
}
;
; Fetch the first approximation from look-up table (while concurrently
; calculating the fracBits of the result).
;
{	sub	#indexBits + 1 + 1,sigBits,indexShift
					; compute amount to shift index field
	subm	fracBits,sigBits,ansFBits ; begin computing result fracBits
}
{	mv_s	#fix(2,iPrec),two	; load constant 2 in internal precision
	as	indexShift,x,y
}
{	add	y,lut			; compute look-up table pointer
}
{	ld_w	(lut),y			; load first approximation value
}
{	add	#iPrec,ansFBits		; finish computing result fracBits
}
;
; Calculate: y *= 2 - x * y.
;
	mul	y,x,>>sigBits,answer	; answer = x * y
	rts				; return soon
	sub	answer,two,answer	; answer = 2 - answer
	mul	y,answer,>>#iPrec,answer ; answer *= y
					; return now, with mul result not yet
					;   ready

;        1         2         3         4         5         6         7         8
;---+----|----+----|----+----|----+----|----+----|----+----|----+----|----+----|
;
; Revision history
; ----------------
; 96/06/24 - rja - updated for new "rts" form
; 2/23/96	(rja) created from recip.a

_reciplo_end:

