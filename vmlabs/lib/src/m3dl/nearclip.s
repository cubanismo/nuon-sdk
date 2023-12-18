/*
 * Title	 	NEARCLIP.S
 * Desciption		NearClip
 * Version		1.0
 * Start Date		12/22/1998
 * Last Update		12/22/1998
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/


	.module NEARCLIP

	.text

	.import	_MPT_NearZ
	.import	_RecipLUTData

	.include "M3DL/m3dl.i"

	csp	=	r31		;C Stack Pointer
	IndexBits	=	7	;#of Index Bits Recip Table MPE0
	iPrec		=	29	;
	sizeofScalar	=	2
	xyzsft	=	16		;XYZ Shift value (16.16)

;* _mdNearClip3
	.export	_mdNearClip3
;* Input:
;* r0 Primitive Type
;* r1 Ptr Vertices (input)
;* r2 Ptr RGBalpha (input)
;* r3 Ptr UV Information (input)
;* r4 Ptr Vertices (output)
;* r5 Ptr RGBalpha (output)
;* r6 Ptr UV Information (output)
;* Stack Usage:
;* 1 Vector
	.cache
	.nooptimize

_mdNearClip3:
       {
	and	#-0x10,csp,r7		;Vector Align
	mv_s	#3,v2[3]		;#of Vertices
	subm	v2[2],v2[2]		;Clear v2[2]
       }
       {
	ld_s	(linpixctl),v2[0]	;Backup linpixctl
	add	#4,v2[2]		;v2[2] 4
       }
       {
	ld_s	(rc0),v2[1]		;Backup rc0
	sub	#0x10,r7		;1 Vector
       }
       {
	st_v	v7,(r7)			;Backup v7
	sub	#0x10,r7		;1 Vector
       }
       {
	st_v	v6,(r7)			;Backup v6
	sub	#0x10,r7		;1 Vector
       }
       {
	st_v	v5,(r7)			;Backup v5
	sub	#0x10,r7		;1 Vector
       }
       {
	st_v	v4,(r7)			;Backup v4
	sub	#0x10,r7		;1 Vector
       }
       {
	st_v	v3,(r7)			;Backup v3
	sub	#0x10,r7		;1 Vector
       }
	st_v	v2,(r7)			;Backup v2
       {
	st_s	v2[3],(rc0)		;#of vertices
	sub	#1,v2[3]		;Last Vertex ID
       }
       {
	mv_s	#3*4,v7[1]		;Offset 1 Vertex XYZ
	lsl	#2,v2[3],v7[2]		;Offset Last Vertex GRBa
       }
       {
	mul	v2[3],v7[1],>>#0,v7[1]	;
	lsl	#2,v2[3],v7[3]          ;Offset Last Vertex UV
	st_s	#(1<<28)|(4<<20),(linpixctl)	;Pix32B with CHNORM
       }
       {
	ld_s	(_MPT_NearZ),v2[3]	;v2[3] NearZ
	add	r2,v7[2]		;Ptr Last Vertex GRBa
       }
       {
	add	r3,v7[3]                ;Ptr Last Vertex UV
	addm	r1,v7[1]		;Ptr Last Vertex XYZ
       }


	;Read Last Vertex
       {
	ld_s	(v7[1]),v4[0]		;Read X
	addm	v2[2],v7[1] 		;Increase Ptr
	ftst	#3,<>#-(RGBBIT+7),r0	;RGBBIT or ABIT Set ?
       }
       {
	bra	eq,`nogrba              ;Nope, Do not Fetch GRBa
	ld_s	(v7[1]),v4[1]		;Read Y
	addm	v2[2],v7[1] 		;Increase Ptr
       }
       {
	ld_s	(v7[1]),v2[0]		;Read Z
       }
       {
	btst	#UVBIT+7,r0		;UV used ?
	subm	v3[0],v3[0]		;Clear v3[0]
       }
       ;--------------------------------;bra eq,`nogrba
       {
	ld_pz	(v7[2]),v5 		;Read GRBa
       }
`nogrba:
       {
	bra	eq,`nouv		;Nope, Do not Fetch UV
	sub	v2[3],v2[0],v3[1]	;
       }
       {
	mv_s	#0,v3[3]		;#of Output Vertices
	abs	v3[1]			;Set C if NearClip
       }
	addwc	v3[0],v3[0]		;Insert ClipCode
       ;--------------------------------;bra eq,`nouv
       {
	ld_w	(v7[3]),v4[2]		;Read U
	add	#2,v7[3]		;Increase Ptr
       }
	ld_w	(v7[3]),v4[3]		;Read V
	add	#2,v7[3]		;Increase Ptr (Delay Slot Cache Bug)
`nouv:

VLoop:
	;Read Next Vertex
       {
	ld_s	(r1),v6[0]		;Read X
	addm	v2[2],r1 		;Increase Ptr
	ftst	#3,<>#-(RGBBIT+7),r0	;RGBBIT or ABIT Set ?
       }
       {
	bra	eq,`nogrba              ;Nope, Do not Fetch GRBa
	ld_s	(r1),v6[1]		;Read Y
	addm	v2[2],r1 		;Increase Ptr
       }
       {
	ld_s	(r1),v2[1]		;Read Z
	addm	v2[2],r1 		;Increase Ptr
       }
	btst	#UVBIT+7,r0		;UV used ?
       ;--------------------------------;bra eq,`nogrba
       {
	ld_pz	(r2),v7			;Read GRBa
	addm	v2[2],r2		;Increase Ptr
       }
`nogrba:
       {
	bra	eq,`nouv		;Nope, Do not Fetch UV
	sub	#0x10,r7		;1 Vector
       }
       {
	st_v	v7,(r7)			;Backup Color
	sub	#0x10,r7		;1 Vector
       }
	sub	v2[3],v2[1],v3[1]	;v3[1] NewZ-NearZ
       ;--------------------------------;bra eq,`nouv,nop
       {
	ld_w	(r3),v6[2]		;Read U
	add	#2,r3			;Increase Ptr
       }
       {
	ld_w	(r3),v6[3]		;Read V
	add	#2,r3			;Increase Ptr
       }
`nouv:
	abs	v3[1]			;Set C if NearClip
       {
	bra	eq,NCskip		;Z == NEARZ, Skip
	addwc	v3[0],v3[0]		;Insert ClipCode
       }
       {
	and	#0x3,v3[0],v3[1]     	;Extract Lower 2 bits
	st_v	v6,(r7)			;Backup XYUV
	subm	v2[2],r7		;1 Scalar
       }
       {
	cmp	#0x1,v3[1]		;1st Vertex Plus - 2nd Vertex Minus
	st_s	v2[1],(r7)		;Backup Z
       }
       ;--------------------------------;bra eq,NCskip
       {
	bra	eq,NCplusmin,nop	;Yap, intpol plusmin
	cmp	#0x2,v3[1]		;1st Vertex Minus - 2nd Vertex Plus
       }
       ;--------------------------------;bra eq,NCminplus
	bra	ne,NCskip,nop 		;Nope, no intpol needed
       ;--------------------------------;bra eq,NCminplus
NCminplus:
       {
	mv_v	v4,v6			;XYUV
	add	#4,r7,v3[1]
       }
	mv_v	v5,v7			;GRBa
       {
	copy	v2[0],v2[1]		;Z
	ld_s	(r7),v2[0]		;New Z
       }
       {
	ld_v	(v3[1]),v4 		;New XYUV
	add	#0x10,v3[1]		;1 Vector
       }
	ld_v	(v3[1]),v5		;New GRBa
NCplusmin:
       {
	sub	v2[1],v2[0],v2[1]	;Zplus - Zmin (Z Difference)
	subm	v2[3],v2[0],v2[3]	;ZPlus - NearZ
       }
       {
	msb	v2[1],v2[2]		;msb(Z)
	subm	v4[0],v6[0]		;X
       }
       {
	sub	#IndexBits+1+1,v2[2],v3[1]
	subm	v4[1],v6[1]             ;Y
       }
       {
	as	v3[1],v2[1],v3[1]	;IndexOffset
	subm	v4[2],v6[2]             ;U
       }
       {
	add	#_RecipLUTData-(128*sizeofScalar),v3[1];RecipLut ptr
	subm	v4[3],v6[3]             ;V
       }
       {
	ld_w	(v3[1]),v3[1]		;Fetch RecipLut value
	subm	v5[0],v7[0]             ;G
       }
	copy	v2[1],v3[2]		;Z
       {
	mul	v3[1],v3[2],>>v2[2],v3[2]
	add	#1,v3[3]		;Increase #of Output Vertices
       }
	sub	v5[1],v7[1]             ;R
	sub	v3[2],#fix(2,iPrec),v3[2]	;2-Z*RecipLut Value
	mul	v3[2],v3[1],>>#iPrec,v3[1]	;Z*(2-z*RecipLut Value)
	copy	v2[1],v3[2]
	mul	v3[1],v3[2],>>v2[2],v3[2]	;
	add	#iPrec-30,v2[2]		;Resulting Fracbits
	sub	v3[2],#fix(2,iPrec),v3[2]	;2-Z*RecipLut Value
	mul	v3[1],v3[2],>>#iPrec,v3[2]	;
	sub	v5[2],v7[2]             ;B
       {
	ld_s	(_MPT_NearZ),v2[3]	;Restore NearZ
	mul	v2[3],v3[2],>>v2[2],v3[2]	;(ZPlus-NearZ) / Zdifference
       }
	sub	v5[3],v7[3]             ;a
       {
	mv_s	#4,v2[2]		;v2[2] 4
	mul	v3[2],v6[0],>>#30,v6[0]	;t*Xdif
       }
	mul	v3[2],v6[1],>>#30,v6[1]	;t*Ydif
       {
	mul	v3[2],v2[1],>>#30,v2[1]	;t*ZDifference
	add	v6[0],v4[0]		;X+(t*Xdif)
       }
       {
	mul	v3[2],v6[2],>>#30,v6[2]	;t*Udif
	add	v6[1],v4[1]		;Y+(t*Ydif)
       }
       {
	mul	v3[2],v6[3],>>#30,v6[3]	;t*Vdif
	sub	v2[1],v2[0]		;Z-(t*(-Zdif))
       }
       {
	mul	v3[2],v7[0],>>#30,v7[0]	;t*Gdif
	add	v6[2],v4[2]		;U+(t*Udif)
       }
       {
	mul	v3[2],v7[1],>>#30,v7[1]	;t*Rdif
	add	v6[3],v4[3]		;V+(t*Vdif)
       }
       {
	mul	v3[2],v7[2],>>#30,v7[2]	;t*Bdif
	add	v7[0],v5[0]		;G+(t*Gdif)
       }
       {
	mul	v3[2],v7[3],>>#30,v7[3]	;t*adif
	add	v7[1],v5[1]		;R+(t*Rdif)
       }
	ftst	#3,<>#-(RGBBIT+7),r0	;RGBBIT or ABIT Set ?
       {
	bra	eq,`nogrbast            ;Nope, Do not Store GRBa
	st_s	v4[0],(r4)		;Store X
	addm	v2[2],r4		;Increase Ptr
       }
       {
	st_s	v4[1],(r4)		;Store Y
	addm	v2[2],r4		;Increase Ptr
	add	v7[2],v5[2]		;B+(t*Bdif)
       }
       {
	st_s	v2[0],(r4)		;Store Z
	addm	v7[3],v5[3]		;a+(t*adif)
	btst	#UVBIT+7,r0		;UV used ?
       }
       ;--------------------------------;bra eq,`nogrbast
       {
	st_pz	v5,(r5)			;Store GRBa
	addm	v2[2],r5		;Increase Ptr
       }
`nogrbast:
       {
	bra	eq,`nouvst		;Nope, Do not Store UV
	addm	v2[2],r4		;Increase Ptr
	and	#0xFFFF0000,v4[2]	;Zero Lower 16 bits
       }
	lsr	#16,v4[3],v3[1]		;Vdown
	or	v4[2],v3[1]		;UV
       ;--------------------------------;bra eq,`nouvst
       {
	st_s	v3[1],(r6)		;Store UV
	addm	v2[2],r6		;Increase Ptr
       }
`nouvst:

NCskip:
       {
	ld_s	(r7),v2[0]		;New Z
	addm	v2[2],r7		;1 Scalar
	btst	#0,v3[0]		;New Vertex Visible ?
       }
       {
	bra	ne,NCnextvertex		;Nope, Try Next vertex
	ld_v	(r7),v4			;new XYUV
	add	#0x10,r7		;1 Vector
       }
       {
	ld_v	(r7),v5			;new GRBa
	add	#0x10,r7		;1 Vector
       }
       {
	dec	rc0			;Decrement Loop Counter
	ftst	#3,<>#-(RGBBIT+7),r0	;RGBBIT or ABIT Set ?
       }
       ;--------------------------------;bra eq,NCnextvertex
       {
	bra	eq,`nogrbast            ;Nope, Do not Store GRBa
	st_s	v4[0],(r4)		;Store X
	add	v2[2],r4		;Increase Ptr
       }
       {
	st_s	v4[1],(r4)		;Store Y
	addm	v2[2],r4		;Increase Ptr
	add	#1,v3[3]		;Increase #of Output Vertices
       }
       {
	st_s	v2[0],(r4)		;Store Z
	addm	v2[2],r4		;Increase Ptr
	btst	#UVBIT+7,r0		;UV used ?
       }
       ;--------------------------------;bra eq,`nogrbast
       {
	st_pz	v5,(r5)			;Store GRBa
	addm	v2[2],r5		;Increase Ptr
       }
`nogrbast:
	bra	eq,`nouvst		;Nope, Do not Store UV
	lsr	#16,v4[3],v3[1]		;Vdown
	or	v4[2],v3[1]		;UV
       ;--------------------------------;bra eq,`nouvst
       {
	st_s	v3[1],(r6)		;Store UV
	addm	v2[2],r6		;Increase Ptr
       }
`nouvst:

NCnextvertex:
	bra 	c0ne,VLoop,nop		;Loop
       ;--------------------------------;bra c0ne,VLoop,nop
	cmp	#4,v3[3]		;4 Clipped Vertices ?
       {
	bra	ne,`noswap		;Nope, No need to swap
	sub	#3*4,r4			;Fourth Vertex XYZ
	subm	v2[2],r5 		;Fourth Vertex GRBa
       }
       {
	mv_s	r0,v2[3]		;v2[3] PCode
	sub	#3*4,r4,r1		;Third Vertex XYZ
	subm	v2[2],r6 		;Fourth Vertex UV
       }
       {
	mv_s	v3[3],r0		;#of Clipped Vertices
	sub	v2[2],r5,r2		;Third Vertex GRBa
	subm	v2[2],r6,r3		;Third Vertex UV
       }
       ;--------------------------------;bra ne,`noswap

       {
	ld_s	(r4),v2[0]		;Read X
	add	#4,r4			;Increase Ptr
       }
       {
	ld_s	(r4),v2[1]		;Read Y
	add	#4,r4			;Increase Ptr
       }
       {
	ld_s	(r4),v2[2]		;Read Z
	sub	#8,r4			;Reset Ptr
       }
       {
	ld_s	(r1),v3[0]		;Read X
	add	#4,r1			;Increase Ptr
       }
       {
	ld_s	(r1),v3[1]		;Read Y
	add	#4,r1			;Increase Ptr
       }
       {
	ld_s	(r1),v3[2]		;Read Z
	sub	#8,r1			;Reset Ptr
       }
       {
	st_s	v2[0],(r1)		;Store X
	add	#4,r1
       }
       {
	st_s	v2[1],(r1)		;Store Y
	add	#4,r1
       }
       {
	st_s	v2[2],(r1)		;Store Z
	ftst	#3,<>#-(RGBBIT+7),v2[3]	;RGBBIT or ABIT Set ?
       }
       {
	bra	eq,`nogrbasw            ;Nope, Do not Swap GRBa
	st_s	v3[0],(r4)		;Store X
	add	#4,r4
       }
       {
	st_s	v3[1],(r4)		;Store Y
	add	#4,r4
       }
       {
	st_s	v3[2],(r4)		;Store Z
	btst	#UVBIT+7,v2[3]		;UV used ?
       }
       ;--------------------------------;bra eq,`nogrbasw
	ld_s	(r5),v2[0]		;Read GRBa
	ld_s	(r2),v3[0]		;Read GRBa
	st_s	v2[0],(r2)		;Store GRBa
	st_s	v3[0],(r5)		;Store GRBa
`nogrbasw:
	bra	eq,`nouvsw,nop         	;Nope, Do not Swap UV
       ;--------------------------------;bra eq,`nouvsw,nop
	ld_s	(r6),v2[0]		;Read UV
	ld_s	(r3),v3[0]		;Read UV
	st_s	v2[0],(r3)		;Store UV
	st_s	v3[0],(r6)		;Store UV
`nouvsw:
`noswap:
       {
	ld_v	(r7),v2			;Restore v2
	add	#0x10,r7
       }
       {
	ld_v	(r7),v3			;Restore v3
	add	#0x10,r7
       }
       {
	ld_v	(r7),v4			;Restore v4
	add	#0x10,r7
       }
       {
	ld_v	(r7),v5			;Restore v5
	add	#0x10,r7
       }
       {
	ld_v	(r7),v6			;Restore v6
	add	#0x10,r7
       }
       {
	ld_v	(r7),v7			;Restore v7
       }
	rts				;Done
	st_s	v2[0],(linpixctl)	;Restore linpixctl
	st_s	v2[1],(rc0)		;Restore rc0
       ;--------------------------------;rts

