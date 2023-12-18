/*
 * Title	 	SCRCONV.S
 * Desciption		Execute Screen Conversion
 * Version		1.1
 * Start Date		10/20/1998
 * Last Update		03/22/1998
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  v1.1 - Bios Compatible
 * Known bugs:
*/


	.module SCRCONV

	.text

	.import	_MPR_mpeinfo
	.import	_RecipLUTData


	.include "M3DL/m3dl.i"


;* _mdDrawConv
	.export	_mdDrawConv
;* Input:
;* r0 mdDRAWCONTEXT *dstdrawcontext
;* r1 Depth Cue color
;* Stack Usage:

	.cache
	.nooptimize
_mdDrawConv:
	push	v3			;Backup v3
	ld_s	(_MPR_mpeinfo),v1[3]	;StartMPE & EndMPE
	copy	r1,v2[3]		;Insert Depth Cue Color
       {
	ld_w	(r0),r2			;Read ActBuf
	add	#8*4,r0,r3		;Ptr ScreenMap
       }
       {
	add	#4*4,r0			;Ptr flags & select
       }
       {
	ld_s	(r0),v2[0]		;Read flags & select
	sub	#2*4,r0			;Ptr rendx
       }
       {
	ld_s	(r0),v3[1]		;Read rendx rendy
	add	#4,r0			;Ptr rendw
       }
       {
	ld_s	(r0),v3[2]		;Read rendw rendh
	add	r2,>>#16-3,r3		;Ptr ScreenMap SDRAM
	subm	v3[0],v3[0]		;Clear XSrcOffs YSrcOffs
       }
       {
	lsr	#16,v2[0]		;Extract flags
       }
       {
	ld_s	(r3),v2[1]		;Read ScreenMap SDRAM Address
	add	#4,r3			;Ptr ScreenMap DMAF
       }
       {
	ld_s	(r3),v2[2]		;Read ScreenMap DMAFlags
	lsr	#16,v1[3],v1[2]		;StartMPE
       }
       {
	bits	#16-1,>>#0,v1[3]	;EndMPE
       }
       {
	sub	v1[2],v1[3]		;NumMPEs
	subm	r1,r1			;No Fracbits
       }
       {
	mv_s	v1[3],r0		;NumMPEs
	or	#SCDEF,v2[0] 		;Insert SC type
       }
	;-------------------------------;ReCip
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
;recip:
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
       {
	mv_s	v1[2],r4		;Start MPE
	and	#0xFFFF,v3[2],v1[1]	;Extract rendh
       }
       {
	bra	eq,`Done,nop		;Nothing to Convert
	sub	answer,#fix(2,iPrec),answer	; answer = 2 - answer
       }
       ;---------------------------------;bra eq,`Done,nop
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

;_reciplo_end:
	;-------------------------------;
	and	#0xFFFF0000,v3[2],r2	;rendw
       {
	mv_s	v1[1],v3[2]		;rendh
	mul	r0,v1[1],>>r1,v1[1]	;rendh / NumMPEs
       }
	sub	#1,v1[3],r3		;NumMPEs-1
       {
	cmp	#0,v1[1]		;Height other MPEs > 0 ?
	mul	v1[1],r3,>>#0,r3	;(NumMPEs-1)*(rendh / NumMPEs)
       }
       {
	bra	ne,`Hotherok
	ld_s	(rz),v3[3]		;Backup rz
       }
	sub	r3,v3[2]		;Height 1st MPE
	or	r2,v3[2]		;Insert rendw
       ;--------------------------------;bra ne,`Hotherok
	mv_s	#1,v1[3]		;Only 1 MPR needed
`Hotherok:

`SCVLoop:
	mv_s	#BIOSCSEND,r0 		;
	jsr	(r0)			;BIOS CommSend Function
	mv_v	v2,v0			;Packet to Send
	nop
       ;--------------------------------;jsr _bios__comm_send
	mv_s	#BIOSCSEND,r0 		;
	jsr	(r0)			;BIOS CommSend Function
	mv_v	v3,v0			;Packet to Send
	sub	v0[3],v0[3]		;Clear unused packet
       ;--------------------------------;jsr _bios__comm_send
       {
	mv_s	#1,r1			;r1 1
	sub	#1,v1[3]		;Next MPE
       }
       {
	bra	ne,`SCVLoop		;Loop
	st_s	v3[3],(rz)		;Restore rz
	and	#0xFFFF,v3[2],r0  	;Isolate rendh
	addm	r1,v1[0]		;Increase MPE#
       }
       {
	and	#0xFFFF0000,v3[2]	;Isolate rendw
	addm	r0,v3[1]		;Increase YDst
       }
`Done:
       {
	addm	r0,v3[0]		;Increase YSrcOffs
	or	v1[1],v3[2]		;Insert rendh
	rts				;Done
       }
       ;--------------------------------;bra ne,`SCVLoop
	pop	v3			;Restore v3
	sub	r0,r0			;Clear return value

