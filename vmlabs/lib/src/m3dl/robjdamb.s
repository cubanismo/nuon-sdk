/*
 * Title	 	ROBJDAMB.S
 * Desciption		Render Object Data
 * Version		1.1
 * Start Date		03/23/1999
 * Last Update		07/26/1999
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  v1.1 - Bios Compatible CommSend & addwc Aries change supported
 * Comments:
 *  Note, this will only work on ARIES systems!
 *  3Kb Assembly Version of the old RenderObject()
 *  Remains Completely in I-Cache with significant speedup on larger objects
 * Known bugs:
*/

	.module ROBJ

	.text

	.include "M3DL/m3dl.i"
	.include "M3DL/mpr.i"

	IndexBits	=	7	;#of Index Bits Recip Table MPE0
	iPrec		=	29	;
	sizeofScalar	=	2

	xyzsft	=	16		;XYZ Shift value (16.16)
	tmsft	=	28		;Matrix Shift value (4.28)
	vecsft	=	16		;Vector Shift value (16.16)
	sclsft	=	20		;XScale & YScale Shift value (12.20)

	csp	=	r31		;C Stack Pointer

	backreg	=	v1
	backrc0	=	backreg[0]
	backrc1	=	backreg[1]
	backlpc	=	backreg[2]
	backrz	=	backreg[3]

	stsp	=	v2[3]
	usp	=	v5[3]

	mprcode	=	v6[0]		;MPRcode
	texid	=	v6[1]		;Texture ID
	nvers	=	v6[2]		;#of Vertices
	versize	=	v6[3]		;Sizeof (Vertices)

	argv	=	v7		;Argument Vector
	objptr	=	argv[0]		;Object Ptr
	texbase	=	argv[1]		;Texture Base
	npoly	=	argv[2]		;Number of polygons
	scratch = 	argv[3]		;Scratch Space


	SIZEOFmdTEXTURE	=	(8)	;#of Bytes of struct mdTEXTURE


	.import	_MPT_TransformMatrix
	.import	_MPT_FogNZ, _MPT_FogMulZ
	.import	_MPT_ScaleX, _MPT_ScaleY
	.import _MPT_OffX, _MPT_OffY
	.import	_MPT_NearZ, _MPT_FarZ, _MPT_Ambient
	.import	_MPR_mpeinfo
	.import	_RecipLUTData


	.cache
	.nooptimize

;* __mdRenderObjDataAmbient
	.export	__mdRenderObjDataAmbient
;* Input:
;* r0	Object Data
;* r1	Texture Base
;* r2 	Number of Polygons
;* r3   ScratchArea
__mdRenderObjDataAmbient:
       {
	ld_s	(rc1),backrc1		;rc1 Backup
	cmp	#0,r2			;#of Polygons > 0
       }
       {
	rts	le,nop			;Nope, Done
	and	#-0x10,csp,stsp	 	;stsp Vector align
       }
       ;--------------------------------;rts le,nop
	ld_s	(rz),backrz		;rz Backup
	ld_s	(linpixctl),backlpc	;linpixctl Backup
       {
	ld_s	(rc0),backrc0		;rc0 Backup
	sub	#0x10,stsp		;1 Vector
       }
       {
	st_v	v7,(stsp)		;Backup v7
	sub	#0x10,stsp		;1 Vector
       }
       {
	st_v	v6,(stsp)		;Backup v6
	sub	#0x10,stsp		;1 Vector
       }
       {
	st_v	v5,(stsp)		;Backup v5
	sub	#0x10,stsp		;1 Vector
       }
       {
	st_v	v4,(stsp)		;Backup v4
	sub	#0x10,stsp		;1 Vector
       }
       {
	st_v	v3,(stsp)		;Backup v3
	sub	#0x10,stsp,usp		;1 Vector
       }
	mv_v	v0,argv			;Argument Vector
	st_v	backreg,(usp)		;Backup Registers


EachPolygon:
       {
	ld_s	(objptr),mprcode	;Fetch MPRcode|TexID
       }
       {
	add	#4,objptr		;Increase Object Pointer
       }
       {
	mv_s	mprcode,texid		;Texture ID
	bits	#16-1,>>#16,mprcode	;MPRcode
       }
       {
	mv_s	mprcode,versize		;MPRcode
	bits	#16-1,>>#0,texid	;Isolate Texture ID
       }
       {
	mv_s	scratch,r1		;Output
	bits	#3-1,>>#0,versize	;#of Vertices
	mul	#SIZEOFmdTEXTURE,texid,>>#0,texid	;Texture offset
       }
       {
	copy	versize,nvers		;#of Vertices
	mul	#3*4,versize,>>#0,versize	;sizeof(Vertices)
	st_s	#(4<<20),(linpixctl)	;Pix32B without CHNORM
       }
       {
	st_s	nvers,(rc0)		;#of Vertices
	add	texbase,texid		;Texture Ptr
       }

       ;* RotTransClipN
       {
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
	copy	objptr,v1[3]			;Ptr
       }
       {
	ld_s	(v1[3]),v1[0]			;Read X
	add	#4,v1[3] 			;Increase Ptr
	subm	v4[0],v4[0]			;Clear v4[0]
       }
       {
	ld_s	(v1[3]),v1[1]			;Read Y
	add	#4,v1[3]			;Increase Ptr
	subm	v4[1],v4[1]			;Clear v4[1]
       }
       {
	ld_s	(v1[3]),v1[2]			;Read Z
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
	sub	#1,v4[1]			;v4[1] All 1s
       }

`RTCLoop:
       {
	add	v2[3],v2[0]			;Tx + r00*X
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r02*Z
	ld_v	(_MPT_TransformMatrix+0x10),v3	;Read r10 r11 r12 r13
       }
       {
	add	v2[1],v2[0]			;Tx + r00*X + r01*Y
       }
       {
	add	v2[2],v2[0],r2			;Tx + r00*X + r01*Y + r02*Z
	mul	v1[0],v3[0],>>#tmsft,v3[0]	;r10*X
       }
       {
	add	#4,v1[3]			;Increase Ptr
	mul	v1[1],v3[1],>>#tmsft,v3[1]	;r11*Y
	ld_v	(_MPT_TransformMatrix+0x20),v2	;Read r20 r21 r22 r23
       }
       {
	add	v3[3],v3[0]			;Ty + r10*X
	mul	v1[2],v3[2],>>#tmsft,v3[2]	;r12*Z
       }
       {
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r20*X
	ld_s	(v1[3]),v1[0]			;Read X
	add	#4,v1[3] 			;Increase Ptr
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r21*Y
	ld_s	(v1[3]),v1[1]			;Read Y
	add	#4,v1[3]			;Increase Ptr
       }
       {
	mul	v1[2],v2[2],>>#tmsft,v2[2]	;r22*Z
	ld_s	(v1[3]),v1[2]			;Read Z
	add	v3[1],v3[0]			;Ty + r10*X + r11*Y
       }
       {
	add	v3[2],v3[0]			;Ty + r10*X + r11*Y + r12*Z
	dec	rc0				;Decrement Counter
       }
       {
	add	v2[3],v2[0],v3[1]		;Tz + r20*X
	addm	v2[1],v2[2],v3[2]		;r21*Y + r22*Z
	ld_v	(_MPT_ScaleX),v2		;v2[0] ScaleX v2[1] ScaleY
       }                                        ;v2[2] ClipX   v2[3] ClipY
       {
	st_s	r2,(r1)				;Store x'
	add	#4,r1				;Increase Ptr
	addm	v3[2],v3[1]			;Tz + r20*X + r21*Y + r22*Z
       }
       {
	st_s	v3[0],(r1) 			;Store y'
	add	#4,r1				;Increase Ptr
	mul	r2,v2[0],>>#sclsft+xyzsft-subres,v2[0]	 ;v2[0] ScaleX*x'
       }
       {
	st_s	v3[1],(r1) 			;Store z'
	add	#4,r1				;Increase Ptr
	mul	v2[1],v3[0],>>#sclsft+xyzsft-subres,v3[0] ;v3[0] ScaleY*y'
       }
       {
	mul	v3[1],v2[2],>>#xyzsft,v2[2]	;XClip*z'
	ld_s	(_MPT_FarZ),v3[2]		;v3[2] FarZ
	sub	r2,r2				;Clear ClipCode
       }
       {
	mul	v3[1],v2[3],>>#xyzsft,v2[3]	;YClip*z'
	ld_s	(_MPT_NearZ),v3[3]		;v3[3] NearZ
	copy	v2[0],v2[1]			;v2[1] ScaleX*x'
       }
	add	v2[2],v2[1]			;v2[1] ScaleX*x' - (-XClip*z')
       {
	subm	v2[0],v2[2]			;v2[2] XClip*z' - ScaleX*x'
	abs	v2[1]				;Set C if Left XClip
       }
       {
	subm	v3[1],v3[2]			;FarZ - z'
	addwc	r2,r2				;Set Left XClip Bit
       }
       {
	subm	v3[3],v3[1]			;z' - NearZ
	abs	v2[2]				;Set C if Right XClip
       }
       {
	mv_s	v3[0],v3[3]			;v3[3] v3[0]
	addm	v2[3],v3[0]			;v3[0] ScaleY*y' - (-YClip*z')
	addwc	r2,r2				;Set Left XClip Bit
       }
       {
	subm	v3[3],v2[3]			;v2[3] YClip*z' - ScaleY*y'
	abs	v3[0]				;Set C if Top YClip
       }
	addwc	r2,r2				;Set Top YClip Bit
	abs	v2[3]				;Set C if Bottom YClip
       {
	addwc	r2,r2				;Set Top YClip Bit
       }
	abs	v3[2]				;Set C if FarClip
	addwc	r2,r2				;Set FarClip Bit
       {
	abs	v3[1]				;Set C if NearClip
	ld_v	(_MPT_TransformMatrix),v2	;Read r00 r01 r02 r03
       }
       {
	bra	c0ne,`RTCLoop			;Loop
	addwc	r2,r2				;Set NearClip Bit
       }
       {
	mul	v1[0],v2[0],>>#tmsft,v2[0]	;r00*X
	or	r2,v4[0]			;Logical Or
       }
       {
	mul	v1[1],v2[1],>>#tmsft,v2[1]	;r01*Y
	and	r2,v4[1]			;Logical And
       }
       ;----------------------------------------;bra c0ne,`RTCLoop
       {
	bra	ne,PolyDone,nop		;Nope, Skip it
	btst	#0,v4[0]		;Near Clip ?
       }
       ;--------------------------------;bra ne,PolyDone,nop
       {
	bra	ne,PolyNear,nop		;Yap, NearClip Needed
	add	#8,scratch,r0			;Ptr Input
       }
       ;--------------------------------;bra ne,PolyDone,nop

       ;* PersN
       {
	ld_s	(r0),v1[0]			;Read Z
	addm	versize,objptr,v4[0]		;RGBsource
	btst	#RGBBIT+7,mprcode		;RGB used ?
       }
       {
	bra	ne,`rgbused
	addm	versize,scratch,v4[1]		;DPQdestination
	copy	scratch,r1			;Ptr Output
       }
       {
	st_s	nvers,(rc0)			;Set rc0
	msb	v1[0],v1[1]			;sigbits of z
       }
       {
	st_s	#0,(rc1)			;Clear DPQ Additor
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       ;----------------------------------------;bra ne,`rgbused
	mv_s	v4[1],v4[0]			;RGBsource = DPQdestination
`rgbused:
       {
	mv_s	#8,r3				;Ct 8
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
	sub	r3,r0				;Ptr X
       }
       {
	ld_s	(_MPT_FogMulZ),v5[1]		;FogMulZ
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
	btst	#DBIT+7,mprcode			;Depth Cue Necessary ?
       }
       {
	ld_s	(_MPT_FogNZ),v5[2]		;FogNearZ
	bra	eq,NoDepthCue			;Nope, Skip to mdPersN
       }
       {
	ld_v	(_MPT_ScaleX),v3		;Fetch ScaleXY OffXY
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
	sub	v5[0],v5[0]			;Clear DPQ Additor
       }
       ;----------------------------------------;bra eq,NoDepthCue

DepthCue:
	mv_s	#iPrec-xyzsft,v2[1]		;result Fracbits
`PLoop:
       {
	ld_s	(v4[0]),v4[2]			;RGBa value
	add	#4,v4[0]			;Increase Ptr
	addm	v1[1],v2[1] 		  	;result Fracbits
       }
	sub	v5[2],v1[0],v4[3]		;Z - FogNearZ
       {
	bra	pl,`alphanotzero		;Positive
	ld_s	(r0),v2[2]			;Fetch X
	add	#4,r0				;Increase Ptr
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	ld_s	(r0),v2[3]			;Fetch Y
	add	#4+12,r0			;Increase Ptr Next Z
       }
       {
	sub	v1[0],#fix(2,iPrec),v2[0]	;refine
	ld_s	(r0),v1[0]			;Read Z
	subm	r3,r0				;Ptr X
       }
       ;----------------------------------------;bra le,`alphanotzero
	sub	v4[3],v4[3]			;Clear alpha
`alphanotzero:
       {
	mul	v1[2],v2[0],>>#iPrec,v2[0]	;result 1/Z
	and	#0xFFFFFF00,v4[2]		;Clear Alpha
       }
	msb	v1[0],v1[1]			;sigbits of z
       {
	mv_s	v2[0],r2			;Backup 1/Z
	mul	v3[0],v2[0],>>v2[1],v2[0]	;ScaleX/Z as 12.20
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	mv_s	r2,r3				;Backup 1/Z
	mul	v3[1],r2,>>v2[1],r2		;ScaleY/Z as 12.20
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip2,nop		;Error!
	mul	v2[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(X*ScaleX)/Z
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip2:
       {
	mul	r3,v4[3],>>v2[1],v4[3]		;(Z - NearZ)/Z
	add	v3[2],v2[2]			;((X*ScaleX)/Z) + OffsetX
       }
       {
	mul	r2,v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Y*ScaleY)/Z
	st_s	v2[2],(r1)			;Store Transformed x
	add	#4,r1				;Increase ptr
       }
       {
	mv_s	r1,r3				;Ptr Y
	add	#8,r1 				;Ptr Next X
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
       {
	mul	v5[1],v4[3],>>#vecsft*2,v4[3]	;DPQ value
	add	v3[3],v2[3]			;((Y*ScaleY)/Z) + OffsetY
       }
       {
	mv_s	#iPrec-xyzsft,v2[1]		;result Fracbits
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
	dec	rc0				;Decrement Loop Counter
       }
       {
	bra	c0ne,`PLoop			;Loop
	st_s	v2[3],(r3)			;Store Transformed y
	sat	#9,v4[3]			;Truncate
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	mv_s	#8,r3				;Ct 8
	or	v4[3],v4[2]			;Insert Alpha
       }
       {
	st_s	v4[2],(v4[1])			;Store new RGBa
	add	#4,v4[1]			;Next RGBa
	addm	v4[3],v5[0]			;DPQ Total
       }
       ;----------------------------------------;bra c0ne,PLoop (19 Cycles)
	cmp	#0,v5[0]			;DPQ Test
	bra	ne,CueDone,nop			;Done
       ;----------------------------------------;bra ne,CueDone
       {
	bra	CueDone,nop			;Done
	bclr	#DBIT+7,mprcode			;Clear DPQBit
       }
       ;----------------------------------------;bra CueDone

NoDepthCue:
`PLoop:
       {
	add	#iPrec-xyzsft,v1[1],v2[1]   	;result Fracbits
       }
       {
	ld_s	(r0),v2[2]			;Fetch X
	add	#4,r0				;Increase Ptr
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	ld_s	(r0),v2[3]			;Fetch Y
	add	#4+12,r0			;Increase Ptr Next Z
       }
       {
	sub	v1[0],#fix(2,iPrec),v2[0]	;refine
	ld_s	(r0),v1[0]			;Read Z
       }
       {
	sub	#8,r0				;Ptr X
	mul	v1[2],v2[0],>>#iPrec,v2[0]	;result 1/Z
       }
	msb	v1[0],v1[1]			;sigbits of z
       {
	mv_s	v2[0],r2			;Backup 1/Z
	mul	v3[0],v2[0],>>v2[1],v2[0]	;ScaleX/Z as 12.20
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	mul	v3[1],r2,>>v2[1],r2		;ScaleY/Z as 12.20
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	mul	v2[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(X*ScaleX)/Z
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
	mul	r2,v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Y*ScaleY)/Z
	add	v3[2],v2[2]			;((X*ScaleX)/Z) + OffsetX
	dec	rc0				;Decrement Loop Counter
       }
       {
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
       {
	bra	c0ne,`PLoop			;Loop
	st_s	v2[2],(r1)			;Store Transformed x
	add	#4,r1				;Increase ptr
       }
       {
	addm	v3[3],v2[3]			;((Y*ScaleY)/Z) + OffsetY
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	st_s	v2[3],(r1)			;Store Transformed y
	add	#8,r1 				;Ptr Next X
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       ;----------------------------------------;bra c0ne,PLoop
CueDone:

       {
	mv_s	#4,r1				;Constant
	copy	scratch,r0			;Input
       }
       {
	ld_s	(r0),v1[0]			;Read x0
	addm	r1,r0				;Increase Ptr
	cmp	#4,nvers			;Cull4 ?
       }
       {
	bra	eq,Cull4			;Yap, Execute Cull4
	ld_s	(r0),v2[0]			;Read y0
	add	#8,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[1]			;Read x1
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read y1
	add	#8,r0				;Increase Ptr
       }
       ;----------------------------------------;bra eq,Cull4
       ;* Cull3
       {
	ld_s	(r0),v1[2]			;Read x2
	add	#4,r0				;Increase Ptr
	subm	v1[0],v1[1]			;v1[1] x1 - x0
       }
       {
	ld_s	(r0),v2[2]			;Read y2
	sub	v2[0],v2[1]			;v2[1] y1 - y0
       }
	sub	v1[0],v1[2]			;v1[2] x2 - x0
       {
	mul	v2[1],v1[2],>>#subres,v1[2]	;v2[2] (x2-x0)(y1-y0)
	sub	v2[0],v2[2]			;v2[2] y2 - y0
       }
	mul	v2[2],v1[1],>>#subres,v1[1]	;v2[1] (x1-x0)(y2-y0)
	sub	r0,r0				;Clear r0
       {
	bra	CullDone			;Culling Finished
	sub	v1[1],v1[2]			;Calculate Signed Area
       }
	abs	v1[2]				;Set c if < (CW)
	addwc	r0,r0				;Set Bit if CW
       ;----------------------------------------;bra CullDone
       ;* Cull4
Cull4:
       {
	ld_s	(r0),v1[2]			;Read x2
	add	#4,r0				;Increase Ptr
	subm	v1[0],v1[1],v0[2]		;v0[2] x1 - x0
       }
       {
	ld_s	(r0),v2[2]			;Read y2
	add	#8,r0				;Increase Ptr
	subm	v2[0],v2[1],v0[3] 		;v0[3] y1 - y0
       }
       {
	ld_s	(r0),v1[3]			;Read x3
	add	#4,r0				;Increase Ptr
	subm	v1[2],v1[0]			;v1[0] x0 - x2
       }
       {
	ld_s	(r0),v2[3]			;Read y3
	mul	v0[3],v1[0],>>#subres,v1[0]	;v1[2] -(x2-x0)(y1-y0)
	sub	v2[2],v2[0]			;v2[0] y0 - y2
       }
       {
	mul	v0[2],v2[0],>>#subres,v2[0]	;v0[2] -(x1-x0)(y2-y0)
	sub	v1[1],v1[2]			;v1[2] x2 - x1
       }
       {
	mv_s	#0,r0				;Clear r0
	sub	v1[1],v1[3]			;v1[3] x3-x1
       }
       {
	sub	v2[1],v2[3]			;v1[3] y3-y1
	subm	v1[0],v2[0]			;Signed Area
       }
       {
	mul	v1[2],v2[3],>>#subres,v2[3]	;v2[1] (x2-x1)(y3-y1)
	sub	v2[1],v2[2]			;v1[2] y2 - y1
       }
       {
	mul	v1[3],v2[2],>>#subres,v2[2]	;v2[2] (x3-x1)(y2-y1)
	abs	v2[0]				;Set c if <
       }
	addwc	r0,r0				;Set bit if CW
	sub	v2[2],v2[3]			;Signed Area
	abs	v2[3]				;Set c if <
	addwc	r0,r0				;Set bit if CW
CullDone:
       {
	cmp	#0,r0			;Backfacing Polygon ?
      	mv_s	#_MPT_Ambient,v2[2]	;Ptr MPR_Ambient
       }
       {
	bra	eq,PolyDone,nop		;Yap, skip it
	mv_s	mprcode,v3[0]		;MPRcode
	ftst	#3,<>#-(RGBBIT+7),mprcode ;RGBBIT or ABIT Set ?
       }
       ;--------------------------------;bra ne,PolyDone,nop
       {
	bra	eq,`uvok
	addm	versize,objptr,v2[3]	;Ptr UVinfo
	mv_s	#4,v2[0]		;v2[0] 4
	copy	texid,v3[3]		;Set Texture
       }
       {
	mv_s	scratch,v3[1]		;Ptr Vertices
	lsl	#2,nvers,v3[2]		;v3[2] nvers*4
       }
       {
	st_s	nvers,(rc0)		;Set #of Vertices
	btst	#DBIT+7,mprcode		;Depth Cue Used ?
       }
       ;--------------------------------;bra eq,`uvok
	addm	v3[2],v2[3] 		;Ptr UVinfo
`uvok:
       {
	bra	ne,`DPQUsed,nop		;Depth Cue Used
	ld_p	(v2[2]),v5		;Read Ambient color
	addm	versize,scratch,v1[3]	;Ptr RGB/DPQ
       }
       ;--------------------------------;bra ne,`DPQUsed
	add	versize,objptr,v1[3]	;Ptr RGBa
`DPQUsed:

       ;Ambient color Multiply
       {
	mv_s	#1<<30,v2[2]		;Cte 1 in 2.30
	bset	#RGBBIT+7,v3[0]		;Set RGB used
	addm	versize,scratch,v3[2]	;Ptr RGB/DPQ
       }
       {
	subm	v2[0],v3[2],v2[1]  	;Ptr Destination
	btst	#RGBBIT+7,mprcode	;RGB used ?
       }
`ALoop:
       {
	bra	ne,`AMult		;Skip next 2 branches
	ld_pz	(v1[3]),v4		;Read RGBa
	mul_p	v2[2],v5,>>#30,v0	;v0 Ambient color
	dec	rc0			;Decrement #of Vertices
       }
       {
	bra	c0ne,`ALoop		;Loop
	add	v2[0],v1[3]		;Increase Ptr
       }
       {
	bra	`ADone			;Done
	copy	v4[3],v0[3]		;Insert A/DPQ
	addm	v2[0],v2[1]		;Increase Ptr
       }
`AMult:
       {
	bra	c0ne,`ALoop		;Loop
	st_pz	v0,(v2[1])		;Store without multiply
	mul_p	v4,v0,>>#30,v0		;Ambient Color Multiply
	btst	#RGBBIT+7,mprcode	;RGB used ?
       }
       ;--------------------------------;bra c0ne,`ALoop
	nop
       ;--------------------------------;bra `ADone
	st_pz	v0,(v2[1])		;Store new color
       ;--------------------------------;bra c0ne,`ALoop
`ADone:
       ;* DrawPoly
       {
	ld_s	(v3[1]),v0[2]		;Read X
	addm	v2[0],v3[1]		;Increase Ptr
	btst	#UVBIT+7,v3[0]		;UV Bit Set ?
       }
       {
	bra	eq,`NoUV0		;Nope, Don't read material info
	ld_s	(v3[1]),v0[1]		;Read Y
	addm	v2[0],v3[1]		;Increase Ptr
       }
       {
	ld_s	(v3[1]),v0[0]		;Read Z
	addm	v2[0],v3[1]		;Increase Ptr
	sat	#16,v0[2]		;Saturate X
       }
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT or DPQBIT Set ?
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
       {
	st_s	nvers,(rc0)		;Set #of Vertices
	bits	#16-1,>>#0,v0[1] 	;Isolate y
       }
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
	dec	rc0			;Vertex Sent
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
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT or DPQBIT Set ?
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
       {
	jsr	(v1[2])			;BIOS CommSend Function
	dec	rc0			;Vertex Sent
       }
	or	v3[3],>>#-16,v0[0]  	;Insert Material
	mv_s	#4,v2[0]		;v2[0] 4
       ;--------------------------------;jsr _bios__commsend
	bra	c0ne,NextPacket
	lsr	#16,v3[3]		;Shift down Material
	nop				;Delay Slot
       ;--------------------------------;bra c0ne,NextPacket

PolyDone:
	lsl	#2,nvers			;#of Vertices * 4
       {
	addm	versize,objptr			;Skip Vertices
	ftst	#3,<>#-(RGBBIT+7),mprcode	;RGBBIT or ABIT Set ?
       }
       {
	bra	eq,`noRGBa,nop
	btst	#UVBIT+7,mprcode		;UV Bit Set ?
       }
       ;----------------------------------------;bra eq,`noRGBa
	addm	nvers,objptr			;Skip RGBa
`noRGBa:
       {
	bra	eq,`noUV,nop
	sub	#1,npoly   			;Decrease #of Polygons
       }
       ;----------------------------------------;bra eq,`noUV
	addm	nvers,objptr			;Skip UV
`noUV:
	bra 	ne,EachPolygon			;Loop
	nop
	nop
       ;----------------------------------------;bra ne,EachPolygon


       {
	ld_v	(usp),backreg		;Restore backreg
	add	#0x10,usp,stsp
       }
       {
	ld_v	(stsp),v3		;Restore v3
	add	#0x10,stsp
       }
       {
	ld_v	(stsp),v4		;Restore v4
	add	#0x10,stsp
       }
       {
	ld_v	(stsp),v5		;Restore v5
	add	#0x10,stsp
       }
       {
	ld_v	(stsp),v6		;Restore v6
	add	#0x10,stsp
       }
       {
	ld_v	(stsp),v7		;Restore v7
       }
	sub	r0,r0			;Clear Return value
       {
	jmp	(backrz)		;Done
	st_s	backlpc,(linpixctl) 	;Restore linpixctl
       }
 	st_s	backrc0,(rc0)		;Restore rc0
	st_s	backrc1,(rc1)		;Restore rc1
       ;--------------------------------;rts


PolyNear:
       {
	sub	#3,nvers,v5[2]		;Quad Flag (One if Quad)
	subm	v5[1],v5[1]		;Offset
       }
TriLoop:
	sub	#0x10,usp,r7		;r7 usp
       {
	st_v	v6,(r7)			;Backup v6
	sub	#0x10,r7		;1 Vector
       }
       {
	st_v	v7,(r7)			;Backup v7
	sub	#0x10,r7		;1 Vector
       }
       {
	st_v	v5,(r7)			;Backup v5
	ftst	#3,<>#-(RGBBIT+7),mprcode	;RGBBIT or ABIT Set ?
       }
       {
	bra	eq,`NoRGBa		;Nope, do not skip colors
	mv_s	mprcode,r0		;PolyType
	add	versize,objptr,r2	;Ptr Colors
       }
       {
	mv_s	scratch,r1		;Ptr RotTrans Vertices
	addm	v5[1],r2		;Offset Vertices 2b Skipped
	add	#4*12,scratch,r4	;Destination Ptr Vertices
       }
       {
	mv_s	r2,r3			;Ptr UVinfo
	add	#4*12,r4,r5		;Destination Ptr Colors
       }
       ;--------------------------------;bra eq,`NoRGBa
	add	nvers,>>#-2,r3 		;Ptr UVinfo
`NoRGBa:
       {
	mv_s	#4,v2[2]		;Cst 4
	add	#4*4,r5,r6		;Destination Ptr UVinfo
	addm	v5[1],r1		;Offset Vertices 2b Skipped
       }
       {
	mv_s	#3,v2[3]		;#of Vertices
	add	v5[1],>>#-1,r1		;Offset Vertices 2b Skipped
       }
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
;	st_s	#(1<<28)|(4<<20),(linpixctl)	;Pix32B with CHNORM
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
	ld_v	(r7),v5			;Restore v5
	add	#0x10,r7		;1 Vector
       }
       {
	ld_v	(r7),v7			;Restore v7
	add	#0x10,r7		;1 Vector
       }
       {
	ld_v	(r7),v6			;Restore v6
	sub	#0x10,usp		;Decrement Stack Ptr
       }
       {
	cmp	#3,r0			;Triangle ?
       }
       {
	bra	eq,`ClipOk		;Yap, Render poly
	cmp	#4,r0			;Quadrangle ?
	mv_s	nvers,v5[0]		;Backup nvers
       }
       {
	bra	ne,TriDone		;Nope, Do not render poly
	st_v	v5,(usp)		;Backup v5
	add	#2*4*12,scratch,v4[0]  	;Ptr Input RGBa
       }
       {
	mv_s	r0,nvers		;#of Vertices
	add	#(4*12)+8,scratch,r0   	;Ptr Input Clipped Vertices Z
       }
       ;--------------------------------;bra eq,`ClipOk
	nop
       ;--------------------------------;bra ne,TriDone
`ClipOk:

       ;* PersN
       {
	ld_s	(r0),v1[0]			;Read Z
	copy	v4[0],v4[1]		;Ptr Output RGBa (from DPQ)
       }
       {
	sub	#8,r0,r1			;Ptr Output
       }
       {
	st_s	nvers,(rc0)			;Set rc0
	msb	v1[0],v1[1]			;sigbits of z
       }
       {
	st_s	#0,(rc1)			;Clear DPQ Additor
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	mv_s	#8,r3				;Ct 8
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
	sub	r3,r0				;Ptr X
       }
       {
	ld_s	(_MPT_FogMulZ),v5[1]		;FogMulZ
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
	btst	#DBIT+7,mprcode			;Depth Cue Necessary ?
       }
       {
	ld_s	(_MPT_FogNZ),v5[2]		;FogNearZ
	bra	eq,NoDepthCue2			;Nope, Skip to mdPersN
       }
       {
	ld_v	(_MPT_ScaleX),v3		;Fetch ScaleXY OffXY
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
	sub	v5[0],v5[0]			;Clear DPQ Additor
       }
       ;----------------------------------------;bra eq,NoDepthCue2

DepthCue2:
	mv_s	#iPrec-xyzsft,v2[1]		;result Fracbits
`PLoop:
       {
	ld_s	(v4[0]),v4[2]			;RGBa value
	add	#4,v4[0]			;Increase Ptr
	addm	v1[1],v2[1] 		  	;result Fracbits
       }
	sub	v5[2],v1[0],v4[3]		;Z - FogNearZ
       {
	bra	pl,`alphanotzero		;Positive
	ld_s	(r0),v2[2]			;Fetch X
	add	#4,r0				;Increase Ptr
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	ld_s	(r0),v2[3]			;Fetch Y
	add	#4+12,r0			;Increase Ptr Next Z
       }
       {
	sub	v1[0],#fix(2,iPrec),v2[0]	;refine
	ld_s	(r0),v1[0]			;Read Z
	subm	r3,r0				;Ptr X
       }
       ;----------------------------------------;bra le,`alphanotzero
	sub	v4[3],v4[3]			;Clear alpha
`alphanotzero:
       {
	mul	v1[2],v2[0],>>#iPrec,v2[0]	;result 1/Z
	and	#0xFFFFFF00,v4[2]		;Clear Alpha
       }
	msb	v1[0],v1[1]			;sigbits of z
       {
	mv_s	v2[0],r2			;Backup 1/Z
	mul	v3[0],v2[0],>>v2[1],v2[0]	;ScaleX/Z as 12.20
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	mv_s	r2,r3				;Backup 1/Z
	mul	v3[1],r2,>>v2[1],r2		;ScaleY/Z as 12.20
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip2,nop		;Error!
	mul	v2[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(X*ScaleX)/Z
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip2:
       {
	mul	r3,v4[3],>>v2[1],v4[3]		;(Z - NearZ)/Z
	add	v3[2],v2[2]			;((X*ScaleX)/Z) + OffsetX
       }
       {
	mul	r2,v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Y*ScaleY)/Z
	st_s	v2[2],(r1)			;Store Transformed x
	add	#4,r1				;Increase ptr
       }
       {
	mv_s	r1,r3				;Ptr Y
	add	#8,r1 				;Ptr Next X
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
       {
	mul	v5[1],v4[3],>>#vecsft*2,v4[3]	;DPQ value
	add	v3[3],v2[3]			;((Y*ScaleY)/Z) + OffsetY
       }
       {
	mv_s	#iPrec-xyzsft,v2[1]		;result Fracbits
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
	dec	rc0				;Decrement Loop Counter
       }
       {
	bra	c0ne,`PLoop			;Loop
	st_s	v2[3],(r3)			;Store Transformed y
	sat	#9,v4[3]			;Truncate
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       {
	mv_s	#8,r3				;Ct 8
	or	v4[3],v4[2]			;Insert Alpha
       }
       {
	st_s	v4[2],(v4[1])			;Store new RGBa
	add	#4,v4[1]			;Next RGBa
	addm	v4[3],v5[0]			;DPQ Total
       }
       ;----------------------------------------;bra c0ne,PLoop (19 Cycles)
	cmp	#0,v5[0]			;DPQ Test
	bra	ne,CueDone2,nop			;Done
       ;----------------------------------------;bra ne,CueDone2
       {
	bra	CueDone2,nop			;Done
	bclr	#DBIT+7,mprcode			;Clear DPQBit
       }
       ;----------------------------------------;bra CueDone2

NoDepthCue2:
`PLoop:
       {
	add	#iPrec-xyzsft,v1[1],v2[1]   	;result Fracbits
       }
       {
	ld_s	(r0),v2[2]			;Fetch X
	add	#4,r0				;Increase Ptr
	mul     v1[2],v1[0],>>v1[1],v1[0]	;
       }
       {
	ld_s	(r0),v2[3]			;Fetch Y
	add	#4+12,r0			;Increase Ptr Next Z
       }
       {
	sub	v1[0],#fix(2,iPrec),v2[0]	;refine
	ld_s	(r0),v1[0]			;Read Z
       }
       {
	sub	#8,r0				;Ptr X
	mul	v1[2],v2[0],>>#iPrec,v2[0]	;result 1/Z
       }
	msb	v1[0],v1[1]			;sigbits of z
       {
	mv_s	v2[0],r2			;Backup 1/Z
	mul	v3[0],v2[0],>>v2[1],v2[0]	;ScaleX/Z as 12.20
	sub	#IndexBits+1+1,v1[1],v1[2]	;IndexShift
       }
       {
	mul	v3[1],r2,>>v2[1],r2		;ScaleY/Z as 12.20
	as	v1[2],v1[0],v1[2]		;IndexOffset
       }
       {
	bra	le,`CannotRecip0,nop		;Error!
	mul	v2[0],v2[2],>>#sclsft+xyzsft-subres,v2[2]	;(X*ScaleX)/Z
	add	#_RecipLUTData-(128*sizeofScalar),v1[2]	;RecipLut ptr
	mv_s	v1[0],v1[3]			;Z
       }
       {
	ld_w	(v1[2]),v1[2]			;Fetch RecipLut value
       }
`CannotRecip0:
       {
	mul	r2,v2[3],>>#sclsft+xyzsft-subres,v2[3]	;(Y*ScaleY)/Z
	add	v3[2],v2[2]			;((X*ScaleX)/Z) + OffsetX
	dec	rc0				;Decrement Loop Counter
       }
       {
	mul	v1[2],v1[3],>>v1[1],v1[3]	;z*RecipLut value
       }
       {
	bra	c0ne,`PLoop			;Loop
	st_s	v2[2],(r1)			;Store Transformed x
	add	#4,r1				;Increase ptr
       }
       {
	addm	v3[3],v2[3]			;((Y*ScaleY)/Z) + OffsetY
	sub	v1[3],#fix(2,iPrec),v1[3]	;2 - z*RecipLut value
       }
       {
	st_s	v2[3],(r1)			;Store Transformed y
	add	#8,r1 				;Ptr Next X
	mul	v1[3],v1[2],>>#iPrec,v1[2]	;Z*(2-z*RecipLutvalue)
       }
       ;----------------------------------------;bra c0ne,PLoop
CueDone2:
       {
	ld_v	(usp),v5			;Restore v5
	add	#(4*12),scratch,r1	   	;Ptr Clipped Pers Vertices
       }
       {
	add	#4,r1,r0	   		;Ptr Clipped Pers Vertices+4
       }
       {
	ld_s	(r1),v1[0]			;Read x0
	cmp	#4,nvers			;Cull4 ?
       }
       {
	bra	eq,Cull42			;Yap, Execute Cull4
	ld_s	(r0),v2[0]			;Read y0
	add	#8,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v1[1]			;Read x1
	add	#4,r0				;Increase Ptr
       }
       {
	ld_s	(r0),v2[1]			;Read y1
	add	#8,r0				;Increase Ptr
       }
       ;----------------------------------------;bra eq,Cull42
       ;* Cull3
       {
	ld_s	(r0),v1[2]			;Read x2
	add	#4,r0				;Increase Ptr
	subm	v1[0],v1[1]			;v1[1] x1 - x0
       }
       {
	ld_s	(r0),v2[2]			;Read y2
	sub	v2[0],v2[1]			;v2[1] y1 - y0
       }
	sub	v1[0],v1[2]			;v1[2] x2 - x0
       {
	mul	v2[1],v1[2],>>#subres,v1[2]	;v2[2] (x2-x0)(y1-y0)
	sub	v2[0],v2[2]			;v2[2] y2 - y0
       }
	mul	v2[2],v1[1],>>#subres,v1[1]	;v2[1] (x1-x0)(y2-y0)
	cmp	#0,v5[2]			;2nd Triangle Quad ?
       {
	bra	pl,CullDone2			;Culling Finished
	sub	v1[1],v1[2]			;Calculate Signed Area
	subm	r0,r0				;Clear r0
       }
       {
	bra	CullDone2			;Culling Finished
	abs	v1[2]				;Set c if < (CW)
       }
	addwc	r0,r0				;Set Bit if CW
       ;----------------------------------------;bra pl,CullDone2
	eor	#1,r0				;Invert 2nd Triangle
       ;----------------------------------------;bra CullDone2
       ;* Cull4
Cull42:
       {
	ld_s	(r0),v1[2]			;Read x2
	add	#4,r0				;Increase Ptr
	subm	v1[0],v1[1],v0[2]		;v0[2] x1 - x0
       }
       {
	ld_s	(r0),v2[2]			;Read y2
	add	#8,r0				;Increase Ptr
	subm	v2[0],v2[1],v0[3] 		;v0[3] y1 - y0
       }
       {
	ld_s	(r0),v1[3]			;Read x3
	add	#4,r0				;Increase Ptr
	subm	v1[2],v1[0]			;v1[0] x0 - x2
       }
       {
	ld_s	(r0),v2[3]			;Read y3
	mul	v0[3],v1[0],>>#subres,v1[0]	;v1[2] -(x2-x0)(y1-y0)
	sub	v2[2],v2[0]			;v2[0] y0 - y2
       }
       {
	mul	v0[2],v2[0],>>#subres,v2[0]	;v0[2] -(x1-x0)(y2-y0)
	sub	v1[1],v1[2]			;v1[2] x2 - x1
       }
       {
	mv_s	#0,r0				;Clear r0
	sub	v1[1],v1[3]			;v1[3] x3-x1
       }
       {
	sub	v2[1],v2[3]			;v1[3] y3-y1
	subm	v1[0],v2[0]			;Signed Area
       }
       {
	mul	v1[2],v2[3],>>#subres,v2[3]	;v2[1] (x2-x1)(y3-y1)
	sub	v2[1],v2[2]			;v1[2] y2 - y1
       }
       {
	mul	v1[3],v2[2],>>#subres,v2[2]	;v2[2] (x3-x1)(y2-y1)
	abs	v2[0]				;Set c if <
       }
	addwc	r0,r0				;Set bit if CW
	cmp	#0,v5[2]			;2nd Triangle Quad ?
       {
	bra	pl,CullDone2			;Nope, Culling Finished
	sub	v2[2],v2[3]			;Signed Area
       }
	abs	v2[3]				;Set c if <
	addwc	r0,r0				;Set bit if CW
       ;----------------------------------------;bra pl,CullDone2
	eor	#3,r0				;Invert 2nd Triangle
CullDone2:
       {
	cmp	#0,r0			;Backfacing Polygon ?
      	mv_s	#_MPT_Ambient,v2[2]	;Ptr MPR_Ambient
       }
       {
	bra	eq,TriDone,nop		;Yap, Skip it
	and	#0xFFF8,mprcode,v3[0]	;MPRcode
	mv_s	#4,v2[0]		;v2[0] 4
       }
       ;--------------------------------;bra ne,TriDone,nop
       {
	add	#4*12,scratch,v3[1]	;Ptr Vertices
	addm	nvers,v3[0]		;Insert #of Vertices
	ld_p	(v2[2]),v5		;Read Ambient color
       }
       {
	add	#4*12,v3[1],v3[2]	;Ptr Color
       }
       {
	mv_s	texid,v3[3]		;Set Texture
	add	#4*4,v3[2],v2[3]	;Ptr UVinfo
       }

       ;Ambient color Multiply
	st_s	nvers,(rc0)		;Set #of Vertices
       {
	mv_s	#1<<30,v2[2]		;Cte 1 in 2.30
	bset	#RGBBIT+7,v3[0]		;Set RGB used
       }
       {
	mv_s	v3[2],v1[3]		;Ptr Color
	subm	v2[0],v3[2],v2[1]  	;Ptr Destination
	btst	#RGBBIT+7,mprcode	;RGB used ?
       }
`ALoop:
       {
	bra	ne,`AMult		;Skip next 2 branches
	ld_pz	(v1[3]),v4		;Read RGBa
	mul_p	v2[2],v5,>>#30,v0	;v0 Ambient color
	dec	rc0			;Decrement #of Vertices
       }
       {
	bra	c0ne,`ALoop		;Loop
	add	v2[0],v1[3]		;Increase Ptr
       }
       {
	bra	`ADone			;Done
	copy	v4[3],v0[3]		;Insert A/DPQ
	addm	v2[0],v2[1]		;Increase Ptr
       }
`AMult:
       {
	bra	c0ne,`ALoop		;Loop
	st_pz	v0,(v2[1])		;Store without multiply
	mul_p	v4,v0,>>#30,v0		;Ambient Color Multiply
	btst	#RGBBIT+7,mprcode	;RGB used ?
       }
       ;--------------------------------;bra c0ne,`ALoop
	nop
       ;--------------------------------;bra `ADone
	st_pz	v0,(v2[1])		;Store new color
       ;--------------------------------;bra c0ne,`ALoop
`ADone:

       ;* DrawPoly
       {
	ld_s	(v3[1]),v0[2]		;Read X
	addm	v2[0],v3[1]		;Increase Ptr
	btst	#UVBIT+7,v3[0]		;UV Bit Set ?
       }
       {
	bra	eq,`NoUV0		;Nope, Don't read material info
	ld_s	(v3[1]),v0[1]		;Read Y
	addm	v2[0],v3[1]		;Increase Ptr
       }
       {
	ld_s	(v3[1]),v0[0]		;Read Z
	addm	v2[0],v3[1]		;Increase Ptr
	sat	#16,v0[2]		;Saturate X
       }
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT or DPQBIT Set ?
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
       {
	st_s	nvers,(rc0)		;Set #of Vertices
	bits	#16-1,>>#0,v0[1] 	;Isolate y
       }
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
	dec	rc0			;Vertex Sent
       }
	st_sv	v1,(_MPR_mpeinfo)	;Store new Active MPR
       {
	mv_s	#TRTP,r5		;CommInfo Type
	lsr	#16,v1[2],r4		;MPE ID#
       }
       ;--------------------------------;jsr _bios__commsend
NextPacket2:
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
	ftst	#7,<>#-(RGBBIT+7),v3[0]	;RGBBIT or ABIT or DPQBIT Set ?
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
       {
	jsr	(v1[2])			;BIOS CommSend Function
	dec	rc0			;Vertex Sent
       }
	or	v3[3],>>#-16,v0[0]  	;Insert Material
	mv_s	#4,v2[0]		;v2[0] 4
       ;--------------------------------;jsr _bios__commsend
	bra	c0ne,NextPacket2
	lsr	#16,v3[3]		;Shift down Material
	nop				;Delay Slot
       ;--------------------------------;bra c0ne,NextPacket2

TriDone:
	ld_v	(usp),v5		;Restore v5
	nop
       {
	mv_s	v5[0],nvers		;Restore #of Vertices
	cmp	#1,v5[2]		;Quad Flag 1st Triangle Set ?
       }
       {
	bra	eq,TriLoop		;TriLoop
	add	#0x10,usp		;Increase Stack Ptr
       }
       {
	bra	PolyDone		;Done
	neg	v5[2]			;Negate Quad Flag
       }
	add	#4,v5[1]		;Skip 1 Vertex
       ;--------------------------------;bra ne,TriLoop
	nop
       ;--------------------------------;bra PolyDone
EndofRenderObjDataAmbient:
