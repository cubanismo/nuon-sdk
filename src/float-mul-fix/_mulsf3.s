; Replacment for the buggy mulsf3 soft single-precision multiply routine
; included in the VMLabs libgcc.a. Fixes handling of rounding overflow.
; Lines modified from original version are marked '[MODIFIED]'

.text

.export ___mulsf3

	a				= r0 ; input multiplicand A
	mantissaProd	= r0 ; intermediate product & result. NOTE: Aliases with a!
	b				= r1 ; input multiplicand B
	tmp				= r7 ; misc. temporary values
	tmp2			= r8 ; misc. temporary values
	mantissaA		= r3 ; input mantissa value extracted from multiplicand A
	mantissaB		= r4 ; input mantissa value extracted from multiplicand B
	expA			= r5 ; input exponent value extracted from multiplicand A
	expB			= r6 ; input exponent value extracted from multiplicand B
	resSign			= r9 ; sign of the final result
	expSum			= r10; intermediate & final result exponent value

	EXCESS			= 126
	EXP_MASK		= $000000ff
	EXP_SHIFT		= 23
	MANT_MASK		= $007fffff
	MANT_IMPL_BIT	= 23
	SIGNBIT			= 31
	SIGNMASK		= $80000000
	ZERO			= $00000000


; Incoming: r0 = a, r1 = b
; Return value will be in r0 = mantissaProd
___mulsf3:
; tmp = SIGNMASK
; tmp2 = SIGNMASK
; if (a == ZERO) {
;    return a;
; }
	{
	mv_s #SIGNMASK,tmp
	add #ZERO,a	; nop, set condition bits
	}
	{
	rts eq
	mv_s #SIGNMASK,tmp2
	add #ZERO,b	; nop, set condition bits
	}

; tmp = a & SIGNMASK;
; tmp2 = b & SIGNMASK
; expA = EXP_MASK;

; if (b != ZERO) {
;     goto AorBnotZero
; } ...
	bra ne,AorBnotZero
	and b,tmp2
	{
	mv_s #EXP_MASK,expA

; ... else {
;     return 0;
; }
	rts
	and a,tmp
	}
	mv_s #ZERO,mantissaProd

AorBnotZero:
; resSign = (a & SIGNMASK) ^ (b & SIGNMASK);
; tmp = EXP_SHIFT
	{
	eor tmp,tmp2,resSign
	mv_s #EXP_SHIFT,tmp
	}

; expA = (a >> EXP_SHIFT) & EXP_MASK;
; expB = EXP_MASK;
	{
	and a,>>tmp,expA
	mv_s #EXP_MASK,expB
	}

; expB = (b >> EXP_SHIFT) & EXP_MASK;
; tmp = MANT_MASK;
	{
	and b,>>tmp,expB
	mv_s #MANT_MASK,tmp
	}

; // Mask sign and exponent off of inputs:
; mantissaA = a & MANT_MASK;
; mantissaB = a & MANT_MASK;
	and tmp,a,mantissaA
	and tmp,b,mantissaB

; // Add the implicit one to the mantissa values:
; mantissaA |= 0x00800000
; mantissaB |= 0x00800000
; acshift = 0x10 (16)
	or #$00000001,<>#32-MANT_IMPL_BIT,mantissaA
	{
	or #$00000001,<>#32-MANT_IMPL_BIT,mantissaB
	st_s #$00000010,acshift
	}

; mantissaProd = (mantissaA * mantissaB) >> 16;
; expSum = EXCESS;
	{
	mul mantissaA,mantissaB,>>acshift,mantissaProd
	mv_s #EXCESS,expSum
	}

; Multiply result settles during this instruction
	mv_s #$00000040,tmp2 ; [MODIFIED] was: nop

; // Start rounding of mantissaProd for non-overflow case:
	add mantissaProd,tmp2; [MODIFIED] didn't exist before
	
; expSum = (expA - 126) + expB;
; acshift = 0;
; if ((mantissaProd + 0x40) & 0x80000000) {
;     mantissaProd += 0x80;
;     mantissaProd >>= 8;
; } else {
;     mantissaProd = (mantissaProd + 0x40) >> 7;
;     expSum -= 1;
; }
	btst #SIGNBIT,tmp2	; [MODIFIED] was: btst #SIGNBIT,mantissaProd
	{
	bra eq,round2
	sub expSum,expA,expSum
	st_s #$00000000,acshift
	}
	add expB,expSum
	bra roundDone
	add #$00000080,mantissaProd
	lsr #$00000008,mantissaProd
round2:
	; [MODIFIED] was: add #$00000040,mantissaProd
	lsr #$00000007,tmp2,mantissaProd ; [MODIFIED] was: lsr #$00000007,mantissaProd
	sub #$00000001,expSum

; mantissaProd &= ~0x00800000;
; expSum <<= 23;
; return mantissaProd | expSum | resSign;
roundDone:
	and #$fffffffe,<>#32-MANT_IMPL_BIT,mantissaProd
	{
	rts
	asl #23,expSum
	}
	or expSum,mantissaProd
	or resSign,mantissaProd
