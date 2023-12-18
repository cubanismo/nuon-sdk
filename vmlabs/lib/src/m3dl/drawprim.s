/*
 * Title	 	DRAWPRIM.S
 * Desciption		Send Primitive to MPR
 * Version		1.1
 * Start Date		12/21/1998
 * Last Update		03/22/1998
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  v1.1 - Bios Compatible
 * Known bugs:
*/


	.module DRAWPRIM

	.text

	.import	_MPR_mpeinfo

	.include "M3DL/m3dl.i"

;* _mdDrawPrim
	.export	_mdDrawPrim
;* Input:
;* r0 Ptr Primitive Type

	.cache
	.nooptimize

_mdDrawPrim:
       {
	ld_s	(r0),r0  		;Fetch Code
	add	#4,r0,r1		;Skip Code field
       }
	add	#48,r1,r2		;addrof(RGBa)
	and	#0x7,r0,r10		;Type
	cmp	#2,r10			;Tile or Sprite ?
       {
	bra	eq,`DPTileSprite,nop	;Yap, its Tile/Sprite
	btst	#UVBIT+7,r0		;UV used ?
       }
       ;--------------------------------;bra eq,`DPTileSprite,nop
	bra	eq,_mdDrawPoly		;Nope, Render Polygon
	add	#16,r2,r3 		;addrof(Texture)
       {
	bra	_mdDrawPoly		;Render Polygon
	add	#4,r3,r4		;r4 UV Info
       }
       ;--------------------------------;bra eq,_mdDrawPoly
	ld_s	(r3),r3			;Fetch Texture Ptr
	nop				;Load Delay Slot
       ;--------------------------------;bra _mdDrawPoly

`DPTileSprite:
	bra	eq,_mdDrawTile		;Nope, Render Tile
	add	#16,r1,r2		;addrof(RGBa)
	add	#4,r2,r3		;addrof(Texture)
       ;--------------------------------;bra eq,_mdDrawTile
	bra	_mdDrawSprite		;Render Sprite
	ld_s	(r3),r3			;Fetch Texture Ptr
	add	#8,r2,r4		;r4 UV Info
       ;--------------------------------;bra _mdDrawSprite


	.export	_mdDrawImage
;* Input:
;* r0 Primitive Type
;* r1 Ptr Vertices
;* r2 Ptr RGBalpha
;* r3 Ptr Texture
;* r4 Ptr UV Information
;* Stack Usage:
;* 2 Vectors
_mdDrawImage:
	push	v4
       {
	push	v3			;Push v3
	copy	r4,v2[3]		;Ptr UV Information
       }
       {
	mv_v	v0,v3			;Ptrs etc
	sub	v2[0],v2[0]		;Clear v2[0]
       }
       {
	ld_sv	(_MPR_mpeinfo),v1	;Read MPR information
	add	#4,v2[0]                ;v2[0] 4
       }
       {
	ld_s	(v3[1]),v0[0]		;Read X
	add	v2[0],v3[1]		;Increase Ptr
       }
       {
	ld_s	(v3[1]),v0[2]		;Read Y
	addm	v2[0],v3[1]		;Increase Ptr
       }
       {
	ld_s	(v3[1]),v0[1]		;Read Z
	addm	v2[0],v3[1]		;Increase Ptr
	sat	#16,v0[0]		;Saturate X
       }
       {
	ld_s	(v3[1]),v0[3]		;Read W & H
	subm	v1[0],v1[1],v3[1]	;NumMPEs
	sat	#16,v0[2]		;Saturate Y
       }
       {
	mul	#1,v3[1],>>#16,v3[1]	;shift down
	bits	#16-1,>>#0,v0[2] 	;Isolate Y
       }
        or	v0[0],>>#-16,v0[2]	;Insert X | Y


SendImage:
	add	#1<<16,v1[2]		;Increase Active MPR
	cmp	v1[1],v1[2]		;Last MPR reached ?
       {
	bra     lt,`MPRstillok		;Nope, don't reset
	mv_s	#BIOSCSEND,v2[1]	;
       }
       {
	ld_s	(rz),v2[2]		;Backup rz
	and	#0xFFFF,v3[1],v0[0]	;Insert loopcnt/nummpes
       }
       {
	or	v3[0],>>#-16,v0[0]	;Insert Type
       }
       ;--------------------------------;bra lt,`MPRstillok
	mv_s	v1[0],v1[2]		;Reset Active MPR
`MPRstillok:
       {
	jsr	(v2[1])			;BIOS CommSend Function
	mv_v	v0,v4			;Backup 1st packet
       }
	st_sv	v1,(_MPR_mpeinfo)	;Store new Active MPR
       {
	mv_s	#SPTP,r5		;CommInfo Type
	lsr	#16,v1[2],r4		;MPE ID#
       }
       ;--------------------------------;jsr _bios__commsend
	btst	#UVBIT+7,v3[0]		;UV Bit Set ?
       {
	bra	eq,`NoUV,nop		;Nope, Don't read material info
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT Set ?
       }
       ;--------------------------------;Read Material & UVinfo
       {
	ld_s	(v2[3]),v0[2]		;UV
	copy	v3[3],v0[0]		;Insert Texture
	addm	v2[0],v2[3] 		;Increase ptr
       }
       {
	ld_s	(v2[3]),v0[3]		;(UV)offset
	subm	v2[0],v2[3]		;Decrease ptr
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT Set ?
       }
       ;--------------------------------;
`NoUV:	bra	eq,`NoRGBa,nop		;Nope, Don't read RGBa info
       ;--------------------------------;Read RGBa
	ld_s	(v3[2]),v0[1]		;RGBa
       ;--------------------------------;
`NoRGBa:
	jsr	(v2[1])			;BIOS CommSend Function
	add	#1<<8,v3[1]		;increment loopcnt
	nop
       ;--------------------------------;jsr _bios__commsend
	and	#0xFF,v3[1],r0		;nummpes
	cmp	v3[1],>>#8,r0		;done ?
       {
	bra	ne,SendImage		;Send Image to MPR
	mv_v	v4,v0			;Restore v0
       }
	ld_sv	(_MPR_mpeinfo),v1	;Restore MPEinfo
	st_s	v2[2],(rz)		;Restore rz
       ;--------------------------------;bra ne,SendImage
       {
	rts				;Done
	pop	v3			;Restore v3
       }
	pop	v4
	sub	r0,r0			;Delay Slot - clear return value
       ;--------------------------------;rts


;* _mdDrawTile
	.export	_mdDrawTile
;* Input:
;* r0 Primitive Type
;* r1 Ptr Vertices
;* r2 Ptr RGBalpha
;* Stack Usage:
;* 1 Vector
;* _mdDrawTile

	.export	_mdDrawSprite
;* Input:
;* r0 Primitive Type
;* r1 Ptr Vertices
;* r2 Ptr RGBalpha
;* r3 Ptr Texture
;* r4 Ptr UV Information
;* Stack Usage:
;* 1 Vector

	.cache
	.nooptimize

_mdDrawTile:
	bclr	#UVBIT,r0		;Clear UV (just to make sure...)
_mdDrawSprite:
       {
	push	v3			;Push v3
	copy	r4,v2[3]		;Ptr UV Information
       }
       {
	mv_v	v0,v3			;Ptrs etc
	sub	v2[0],v2[0]		;Clear v2[0]
       }
       {
	ld_sv	(_MPR_mpeinfo),v1	;Read MPR information
	add	#4,v2[0]                ;v2[0] 4
       }
       {
	ld_s	(v3[1]),v0[0]		;Read X
	add	v2[0],v3[1]		;Increase Ptr
       }
       {
	ld_s	(v3[1]),v0[2]		;Read Y
	addm	v2[0],v3[1]		;Increase Ptr
	add	#1<<16,v1[2]		;Increase Active MPR
       }
       {
	ld_s	(v3[1]),v0[1]		;Read Z
	addm	v2[0],v3[1]		;Increase Ptr
	sat	#16,v0[0]		;Saturate X
       }
       {
	ld_s	(v3[1]),v0[3]		;Read W & H
	addm	v2[0],v3[1]		;Increase Ptr
	sat	#16,v0[2]		;Saturate Y
       }
	cmp	v1[1],v1[2]		;Last MPR reached ?
       {
	mv_s	#BIOSCSEND,v2[1]	;
	bra     lt,`MPRstillok		;Nope, don't reset
	bits	#16-1,>>#0,v0[2] 	;Isolate Y
       }
       {
	ld_s	(rz),v2[2]		;Backup rz
        or	v0[0],>>#-16,v0[2]	;Insert X | Y
       }
       {
       	lsl	#16,v3[0],v0[0]		;Insert Type
       }
       ;--------------------------------;bra lt,`MPRstillok
	mv_s	v1[0],v1[2]		;Reset Active MPR
`MPRstillok:
	jsr	(v2[1])			;BIOS CommSend Function
	st_sv	v1,(_MPR_mpeinfo)	;Store new Active MPR
       {
	mv_s	#SPTP,r5		;CommInfo Type
	lsr	#16,v1[2],r4		;MPE ID#
       }
       ;--------------------------------;jsr _bios__commsend
	btst	#UVBIT+7,v3[0]		;UV Bit Set ?
       {
	bra	eq,`NoUV,nop		;Nope, Don't read material info
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT Set ?
       }
       ;--------------------------------;Read Material & UVinfo
       {
	ld_s	(v2[3]),v0[2]		;UV
	copy	v3[3],v0[0]		;Insert Texture
	addm	v2[0],v2[3] 		;Increase ptr
       }
       {
	ld_s	(v2[3]),v0[3]		;(UV)offset
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT Set ?
       }
       ;--------------------------------;
`NoUV:	bra	eq,`NoRGBa,nop		;Nope, Don't read RGBa info
       ;--------------------------------;Read RGBa
	ld_s	(v3[2]),v0[1]		;RGBa
       ;--------------------------------;
`NoRGBa:
	jsr	(v2[1]),nop		;BIOS CommSend Function
       ;--------------------------------;jsr _bios__commsend
       {
	jmp	(v2[2])			;Return
	st_s	v2[2],(rz)		;Restore rz
       }
	pop	v3			;Restore v3
	sub	r0,r0			;Delay Slot - clear return value
       ;--------------------------------;rts


;* _mdDrawPoly
	.export	_mdDrawPoly
;* Input:
;* r0 Primitive Type
;* r1 Ptr Vertices
;* r2 Ptr RGBalpha
;* r3 Ptr Texture
;* r4 Ptr UV Information
;* Stack Usage:
;* 1 Vector
	.cache
	.nooptimize

_mdDrawPoly:
       {
	push	v3			;Push v3
	copy	r4,v2[3]		;Ptr UV Information
       }
       {
	mv_v	v0,v3			;Ptrs etc
	sub	v2[0],v2[0]		;Clear v2[0]
       }
       {
	ld_s	(rz),v2[2]		;Backup rz
	add	#4,v2[0]                ;v2[0] 4
       }
       {
	ld_s	(v3[1]),v0[2]		;Read X
	addm	v2[0],v3[1]		;Increase Ptr
	btst	#UVBIT+7,v3[0]		;UV Bit Set ?
       }
       {
	bra	eq,`NoUV0		;Nope, Don't read material info
	ld_s	(v3[1]),v0[1]		;Read Y
	add	v2[0],v3[1]		;Increase Ptr
       }
       {
	ld_s	(v3[1]),v0[0]		;Read Z
	addm	v2[0],v3[1]		;Increase Ptr
	sat	#16,v0[2]		;Saturate X
       }
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT Set ?
       ;--------------------------------;Read Material & UV0
       {
	ld_s	(v2[3]),v0[3]		;Read UV0
	addm	v2[0],v2[3]		;Increase ptr
       }
       ;--------------------------------;
`NoUV0:
       {
	bra	eq,`NoRGBa0		;Nope, Don't read RGBa info
	sat	#16,v0[1]		;Saturate y
       }
	bits	#16-1,>>#0,v0[1] 	;Isolate y
	or	v0[2],>>#-16,v0[1]	;Insert X | Y
       ;--------------------------------;Read RGBa
       {
	ld_s	(v3[2]),v0[2]		;Read RGBa0
	add	v2[0],v3[2]		;Increase ptr
       }
       ;--------------------------------;
`NoRGBa0:
	msb	v0[0],v2[1]		;Most Significant Bit
       {
	sub	#15,v2[1]		;Normalisation Needed ?
	mv_s	#-1,v1[3]		;v1[3] -1
       }
       {
	bra	le,`NoNorm0		;Nope
	ls	v2[1],v0[0],v2[0] 	;Shift down
	mul	v1[3],v2[1],>>#-11,v2[1];Negate & shift 11 left
	ld_sv	(_MPR_mpeinfo),v1	;Read MPR information
       }
	bits	#10,>>#3,v2[0]		;Isolate
	bits	#15,>>#0,v2[1]		;Remove upper bits
       ;--------------------------------;bra le,`NoNorm0
	or	v2[1],v2[0],v0[0]	;Normalized Value
`NoNorm0:
	add	#1<<16,v1[2]		;Increase Active MPR
	cmp	v1[1],v1[2]		;Last MPR reached ?
	bra     lt,`MPRstillok		;Nope, don't reset
	or	v3[0],>>#-16,v0[0] 	;Insert Type
	mv_s	#BIOSCSEND,v2[1]	;
       ;--------------------------------;bra lt,`MPRstillok
	mv_s	v1[0],v1[2]		;Reset Active MPR
`MPRstillok:
       {
	mv_s	#4,v2[0]		;v2[0] 4
	jsr	(v2[1])			;BIOS CommSend Function
       }
	st_sv	v1,(_MPR_mpeinfo)	;Store new Active MPR
       {
	mv_s	#TRTP,r5		;CommInfo Type
	lsr	#16,v1[2],r4		;MPE ID#
       }
       ;--------------------------------;jsr _bios__commsend
NextPacket:
       {
	ld_s	(v3[1]),v0[2]		;Read X
	addm	v2[0],v3[1]		;Increase Ptr
	btst	#UVBIT+7,v3[0]		;UV Bit Set ?
       }
       {
	bra	eq,`NoUV0		;Nope, Don't read material info
	ld_s	(v3[1]),v0[1]		;Read Y
	add	v2[0],v3[1]		;Increase Ptr
       }
       {
	ld_s	(v3[1]),v0[0]		;Read Z
	addm	v2[0],v3[1]		;Increase Ptr
	sat	#16,v0[2]		;Saturate X
       }
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT Set ?
       ;--------------------------------;Read Material & UV0
       {
	ld_s	(v2[3]),v0[3]		;Read UV0
	addm	v2[0],v2[3]		;Increase ptr
       }
       ;--------------------------------;
`NoUV0:
       {
	bra	eq,`NoRGBa0		;Nope, Don't read RGBa info
	sat	#16,v0[1]		;Saturate y
       }
	bits	#16-1,>>#0,v0[1] 	;Isolate y
	or	v0[2],>>#-16,v0[1]	;Insert X | Y
       ;--------------------------------;Read RGBa
       {
	ld_s	(v3[2]),v0[2]		;Read RGBa0
	add	v2[0],v3[2]		;Increase ptr
       }
       ;--------------------------------;
`NoRGBa0:
	msb	v0[0],v2[1]		;Most Significant Bit
       {
	sub	#15,v2[1]		;Normalisation Needed ?
	mv_s	#-1,v1[3]		;v1[3] -1
       }
       {
	bra	le,`NoNorm0		;Nope
	ls	v2[1],v0[0],v2[0] 	;Shift down
	mul	v1[3],v2[1],>>#-11,v2[1];Negate & shift 11 left
       }
       {
	mv_s	#BIOSCSEND,v1[2]	;
	bits	#10,>>#3,v2[0]		;Isolate
       }
       {
	bits	#15,>>#0,v2[1]		;Remove upper bits
	addm	v1[3],v3[0]		;Subtract 1 Packet sent
       }
       ;--------------------------------;bra le,`NoNorm0
	or	v2[1],v2[0],v0[0]	;Normalized Value
`NoNorm0:
	jsr	(v1[2])			;BIOS CommSend Function
	or	v3[3],>>#-16,v0[0]  	;Insert Material
	mv_s	#4,v2[0]		;v2[0] 4
       ;--------------------------------;jsr _bios__commsend
       {
	st_s	v2[2],(rz)		;Restore rz
	ftst	#6,v3[0]		;More Packets to send ?
       }
	bra	ne,NextPacket		;Yap, Send next
	lsr	#16,v3[3]		;Shift down Material
	rts				;Done
       ;--------------------------------;bra ne,NextPacket,nop
	pop	v3			;Restore v3
	sub	r0,r0			;Delay Slot - clear return value
       ;--------------------------------;rts


