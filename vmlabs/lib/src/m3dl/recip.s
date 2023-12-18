;
; reciplo -- compute reciprocal (low precision)
;
; Copyright (c) 1996-1997 VM Labs, Inc.
; All rights reserved.
; Confidential and Proprietary Information of
; VM Labs, Inc.
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

;
; Input parameters
;
x = v0[0]			; the number to "recip"
fracBits = v0[1]		; fracBits of X
;
; Results
;
answer = v0[0]			; the reciprocal
ansFBits = v0[1]		; fracBits of the reciprocal


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
sigBits = v0[2]				; fracBits in normalized argument
indexShift = v0[3]
lut = v1[0]				; used for divide-LUT lookup
y = v0[3]  				; used for iterative result
;
; Some symbolic constants
;
iPrec = 29				; intermediate working precision
indexBits = 7				; nbr of bits used for table lookup
sizeofScalar = 2


;
; The "reciplo" code.
;
recip:
;
; Normalize the input X -- figure out how many bits to shift.
;
{	mv_s	#_RecipLUTData-(128*sizeofScalar),lut ; start computing LUT ptr
	msb	x,sigBits		; compute sig bits of input x
}
;
; Fetch the first approximation from look-up table (while concurrently
; calculating the fracBits of the result).
;
{	sub	#indexBits+1+1,sigBits,indexShift
					; compute amount to shift index field
	subm	fracBits,sigBits,ansFBits ; begin computing result fracBits
}
{
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
	sub	answer,#fix(2,iPrec),answer	; answer = 2 - answer
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

