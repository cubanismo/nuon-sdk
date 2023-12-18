/*
 * Title	 	MPRTRIS.S
 * Desciption		MPR Triangle Code (Subtractive Alpha)
 * Version		1.0
 * Start Date		11/17/1998
 * Last Update		02/25/2000
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 * Known bugs:
*/

;*
;* Include
;*

	.include "M3DL/dma.i"
	.include "M3DL/pixel.i"
	.include "M3DL/m3dl.i"
	.include "M3DL/mpr.i"

;*
;* Constant Declarations
;*

;*
;* Register Declarations
;*
	.include "drregis.s"

;*
;* Code Overlay
;*
	.overlay	mprtris
	.origin 	mprmainbase

;*
;* Import
;*
	.import	MPR_NextCommand
	.import	MPR_FetchTexInfo
	.import	MPR_FetchBmInfo
	.import	MPR_FetchInnerCode
	.import	MPR_FetchMainCode
	.import	MPR_FetchBitmapandClut
	.import	MPR_Waitallbuses
	.import	MPR_Recip

	.import	MPR_sbFlags, MPR_sbDMAF, MPR_sbSDRAM, MPR_PIXtemp
	.import	MPR_MDMA1, MPR_MDMA2, MPR_MDMAeor
	.import	DMAFL1, SDRAM1, XPLEN1, XPLEN1, YPLEN1, MPEAD1
	.import	MPR_PixBuf1, MPR_PixBuf2, MPR_PixBufeor
	.import	MPR_Dump

	.import	MPR_DLGRBA, MPR_LGRBA, MPR_DGRBA
	.import	MPR_DLUVZ, MPR_DLUVZ, MPR_DUVZ
	.import	MPR_PMXWXTPBF, MPR_WXCLXHYCTY

	.import	MPR_P0, MPR_P1, MPR_P2, MPR_P3
	.import	MPR_U0, MPR_U1, MPR_U2, MPR_U3
	.import	MPR_V0, MPR_V1, MPR_V2, MPR_V3
	.import	MPR_iZ0, MPR_iZ1, MPR_iZ2, MPR_iZ3
	.import	MPR_Z0, MPR_Z1, MPR_Z2, MPR_Z3
	.import	MPR_G0, MPR_G1, MPR_G2, MPR_G3
	.import	MPR_R0, MPR_R1, MPR_R2, MPR_R3
	.import	MPR_B0, MPR_B1, MPR_B2, MPR_B3
	.import	MPR_A0, MPR_A1, MPR_A2, MPR_A3
	.import	MPR_X0, MPR_X1, MPR_X2, MPR_X3
	.import	MPR_Y0, MPR_Y1, MPR_Y2, MPR_Y3

	.import		MPR_DX_P
	.import		MPR_L1_P, MPR_L2_P
	.import		MPR_DL1_P, MPR_DL2_P
	.import		MPR_L1_LX, MPR_L1_RX
	.import		MPR_L2_LX, MPR_L2_RX
	.import		MPR_DL1_LX, MPR_DL1_RX
	.import		MPR_DL2_LX, MPR_DL2_RX
	.import		MPR_HGH1, MPR_HGH2
	.import		MPR_LongSide, MPR_QuadFlag, MPR_PolyType
	.import		MPR_YStart
	.import		MPR_Return
	.import		MPR_BackGroundAlpha

;*
;* Export
;*
	.export	_mprtris_start, _mprtris_size
	.export	MPR_TRIS

MPR_TRIS:
       {
	ld_v	(v7[0]),v2			;Fetch 1st Packet
	jsr	TR_DecodePacket			;Decode Packet #1
	sub	v3[0],v3[0]			;Clear v3[0]
       }
       {
	ld_sv	(MPR_sbWINxw),v5		;Read xw & yh
	add	#MPR_P0,v3[0]			;Destination P0
       }
       {
	lsr	#16,v2[0],v6[0]			;Polygon Type
       }
       ;----------------------------------------;jsr TR_DecodePacket
       {
	jsr	TR_DecodePacket			;Decode Packet #2
	ld_v	(v7[1]),v2			;Fetch 2nd Packet
	copy	v6[0],v6[1]			;v6[1]
       }
       {
	st_s	#0,(acshift)			;Set multiply shift register
	sub	r0,r0				;Clear r0
       }
       {
	st_s	r0,(MPR_QuadFlag)		;Clear Quadrangle
	lsr	#16,v2[0],v6[2]			;MTLow
       }
       ;----------------------------------------;jsr TR_DecodePacket
       {
	jsr	TR_DecodePacket			;Decode Packet #3
	ld_v	(v7[2]),v2			;Fetch 3rd Packet
       }
	bits	#3-1,>>#0,v6[1]			;#of vertices
	lsr	#16,v2[0],v6[3]			;MTHigh
       ;----------------------------------------;jsr TR_DecodePacket
       {
	cmp	#4,v6[1]			;Quadrangle ?
	mv_s	#1,r0				;r0 1
       }
       {
	bra	ne,TR_NoQuad			;Nope
	sub	v5[3],v5[3]			;Clear v5[3]
       }
       {
	jsr	TR_DecodePacket   		;Decode Packet #4
	ld_v	(v7[3]),v2			;Fetch 4th Packet
       }
       {
	or	v6[3],>>#-16,v6[2]		;Texture Address
	subm	v6[3],v6[3]			;Clear v6[3]
       }
       ;----------------------------------------;bra ne,TR_NoQuad
	st_s	r0,(MPR_QuadFlag)		;Set Quadrangle
       ;----------------------------------------;jsr TR_DecodePacket
       {
	jsr	TR_TriArea			;Calc XYarea tri123
	mv_s	#0x20,v0[1]			;Offset
       }
	mv_s	#MPR_X1,v4[0]
	mv_s	#MPR_Y1,v5[0]
       ;----------------------------------------;jsr TR_TriArea
       {
	jsr	TR_TriArea			;Calc UVarea tri012
	mv_s	#MPR_U1,v4[0]
       }
	copy	v0[0],v5[3]			;Start Polyarea
	mv_s	#MPR_V1,v5[0]
       ;----------------------------------------;jsr TR_TriArea
	copy	v0[0],v6[3]			;Start UVarea
TR_NoQuad:
       {
	ld_s	(MPR_sbFlags),v7[1]		;Read sbFlags
	btst	#UVBIT+7,v6[0]			;Texture used ?
       }
	bra	eq,TR_NoTexture			;Nope, Skip Texture

	jsr	MPR_FetchTexInfo		;Yap, Fetch TexInfo
	mv_s	v6[0],v7[0]			;Polygon type
       ;----------------------------------------;bra eq,TR_NoTexture
	mv_s	v6[2],r0			;TexInfo Address
       ;----------------------------------------;jsr MPR_FetchTexInfo
       {
	mv_s	#0x20,v0[1]			;Offset
	jsr	TR_TriArea			;Calc XYarea tri012
       }
	mv_s	#MPR_X0,v4[0]			;Destination X0
	mv_s	#MPR_Y0,v5[0]			;Destination Y0
       ;----------------------------------------;jsr TR_TriArea
	ld_s	(MPR_TexInfoC),v2[3] 		;v2[3] pixtype, miplevels, w & h
       {
	ld_s	(MPR_TexInfoC+4),v6[0] 		;BmInfo
	sub	v0[0],v5[3]			;Complete Poly Area
       }
       {
	jmp	eq,MPR_NextCommand,nop		;Area 0, nothing to render
	abs	v5[3]				;abs(Polygon Area)
       }
       ;----------------------------------------;jmp eq,MPR_NextCommand
	jsr	TR_TriArea			;Calc UVarea tri012
	mv_s	#MPR_U0,v4[0]			;Destination U0
	mv_s	#MPR_V0,v5[0]			;Destination V0
       ;----------------------------------------;jsr TR_TriArea
       {
       	mv_s	v2[3],v2[0]                     ;v2[3] pixtype, miplevels, w & h
	copy	v2[3],v2[1]			;v2[1] pixtype, miplevels, w & h
       }
       {
	mv_s	v2[3],v2[2]			;v2[2] pixtype, miplevels, w & h
	bits	#8-1,>>#8,v2[0]			;Width
       }
       {
	bits	#8-1,>>#0,v2[1]			;Height
	subm	v0[0],v6[3]			;Complete UVArea
       }
       {
	jsr	MPR_Recip			;Calculate 1/Polygon Area
	mul	v2[0],v2[1],>>acshift,v3[1]	;Texture Size
	abs	v6[3]				;abs(UVArea)
       }
       {
	mv_s	#3,r1	  			;#fracbits
;	mv_s	#4,r1	  			;#fracbits ORIGINAL!
	bits	#8-1,>>#24,v2[2]		;Pixtype
       }
       {
	mul	v3[1],v6[3],>>acshift,v6[3] 	;v6[3] UVarea*Width*Height
	mv_s	v5[3],r0			;XYarea
	bits	#8-1,>>#16,v2[3]		;Miplevels
       }
       ;----------------------------------------;jsr MPR_Recip
	or	v2[2],>>#-16,v7[0]	;Insert TexPixtype in Polygon Subtype
	mul	r0,v6[3],>>r1,v6[3]		;UVArea/Polygon Area
	nop
	add	#1,v6[3]			;Refine result
	msb	v6[3],v5[2]			;Get msb
	lsr	#1,v5[2]			;Mip Level
	cmp	v5[2],v2[3]			;Level Requested < Max Level ?
	bra	gt,`TRmipok
	lsl	#2+16,v2[0]			;Real width 16.16
	lsl	#2+16,v2[1]			;Real height 16.16
       ;----------------------------------------;bra gt,`TRmipok,nop
	sub	#1,v2[3],v5[2]			;Highest MipLevel
`TRmipok:
       {
	as	v5[2],v2[0]			;MipMapped Width
	jsr	MPR_FetchBmInfo			;Fetch Bitmap Info
       }
       {
	as	v5[2],v2[1]			;MipMapped Height
	mv_s	v6[0],r0			;ptr BmInfo
       }
	add	v5[2],>>#-3,r0			;BmInfo = BmInfo + (Level*8)
       ;----------------------------------------;jsr MPR_FetchBmInfo
	jsr	MPR_FetchBitmapandClut		;Fetch Bitmap & Clut

TR_NoTexture:
;* Calculate invZ for non-textured triangles as well - UV will be destroyed
       {
	st_s	v6[1],(rc0)			;#of vertices
	lsr	#16,v2[0],r0			;Width of Bitmap
       }
       {
	lsr	#16,v2[1],r1                    ;Height of Bitmap
	mv_s	#MPR_Z0,v3[0]			;Ptr MPR_Z0
       }
       ;----------------------------------------;jsr MPR_FetchBitmapandClut
       {
	st_s	v7[0],(MPR_PolyType)		;Set Polygon Type
	btst	#sbZFb,v7[1]			;ZFlip Needed ?
       }
       {
	bra	ne,TR_invZandUVmipmap,nop	;Yap, Zflip Ok
	mv_s	#-1,v7[3]			;ZFlip value
       }
       ;----------------------------------------;bra TR_invZandUVmipmap
	mv_s	#0,v7[3]			;Clear ZFlip value

TR_invZandUVmipmap:
       {
	ld_s	(v3[0]),r0			;Read Z
	sub	#4,v3[0]			;ptr iZ
	jsr	MPR_Recip			;Reciprocal
       }
       {
	sub	#8,v3[0],v1[2]			;ptr U
	dec	rc0				;Decrement Loop Counter
       }
       {
	mv_s	#precdepthz,r1			;Depth Z Precision
	add	#4,v1[2],v1[3]			;ptr V
       }
       ;----------------------------------------;jsr MPR_Recip
       {
	ld_s	(v1[2]),v1[0]			;Read U
       }
       {
	ld_s	(v1[3]),v1[1]			;Read V
	sub	#preciz,r1			;FracBits
       }
       {
	mul	v2[0],v1[0],>>#16,v1[0]		;U*MipMapped Width
	ls	r1,r0				;iZ
       }
       {
	mul	v2[1],v1[1],>>#16,v1[1]		;V*MipMapped Height
	st_s	r0,(v3[0])			;store iZ
	add	#4,v3[0]			;Next Point
       }
       {
	mv_s	#0x8000,r1			;0.5 in 16.16
	cmp	#0,v1[0]			;Zero U Coordinate ?
       }
       {
	bra	ne,`nouchange,nop		;Nope, Don't touch
	cmp	#0,v1[1]			;Zero V Coordinate ?
       }
       ;----------------------------------------;bra ne,`nouchange,nop
	mv_s	r1,v1[0]			;U is 0.5
`nouchange:
       {
	bra	ne,`novchange,nop		;Nope, Don't touch
	cmp	v2[0],v1[0]			;One U Coordinate ?
       }
       ;----------------------------------------;bra ne,`novchange,nop
	mv_s	r1,v1[1]			;V is 0.5
`novchange:
       {
	bra	ne,`nouchange2,nop		;Nope, Don't touch
	cmp	v2[1],v1[1]			;One U Coordinate ?
       }
       ;----------------------------------------;bra ne,`nouchange2,nop
	subm	r1,v1[0]			;Sub U-0.5
`nouchange2:
       {
	bra	ne,`novchange2,nop		;Nope, Don't touch
	btst	#PCBIT+7,v7[0]			;Perspective Correct ?
       }
       ;----------------------------------------;bra ne,`nouchange2,nop
	subm	r1,v1[1]			;Sub V-0.5
`novchange2:
	bra	eq,TRnopc,nop			;Nope,Quit
       ;----------------------------------------;bra eq,TRnopc,nop
	mul	r0,v1[0],>>#preciz+precuviz,v1[0]	;U*iZ
	mul	r0,v1[1],>>#preciz+precuviz,v1[1]	;V*iZ
TRnopc:
       {
	st_s	v1[0],(v1[2])			;Store U
	bra	c0ne,TR_invZandUVmipmap		;Loop
	btst	#UVBIT+7,v7[0]			;Texture used ?
       }
       {
	bra	ne,TR_DecDone			;Yap, Finished!
	st_s	v1[1],(v1[3])			;Store V
	eor	v7[3],r0			;ZFlip value
       }
       {
	st_s	r0,(v3[0])			;store ZFlipped Z
	add	#0x20,v3[0]			;Next Point
       }
       ;----------------------------------------;bra c0ne,TR_invZandUVmipmap
;TR_NoTexture:					;Removed for invZ calculation
	btst	#sbGRBb,v7[1] 			;ScreenMode GRB ?
       ;----------------------------------------;bra ne,TR_DecDone
	bra	ne,TR_DecDone			;Yap, no color conversion
	st_s	v6[1],(rc0)			;#of vertices
	mv_s	#MPR_G0,v3[0]			;Ptr Point
       ;----------------------------------------;bra ne,TR_ColorDone
TR_ColorYCC:
	ld_sv	(v3[0]),v4			;Read Color Vector
	ld_sv	(MPR_GRB32Ycc),v1		;GRB -> Y
       {
	copy	v4[3],v0[3]			;Copy Alpha
	subm	v4[3],v4[3]			;Clear v4[3]
       }
       {
	ld_sv	(MPR_GRB32Ycc+8),v2		;GRB -> Cr
	bset	#30,v4[3]			;v6[3] One in 2.30
       }
       {
	dotp	v1,v4,>>#30,v0[0]		;Y Component
	ld_sv	(MPR_GRB32Ycc+16),v1		;GRB -> Cb
       }
       {
	dotp	v2,v4,>>#30,v0[1]		;Cr Component
	dec	rc0				;Decrement Loop Counter
       }
       {
	bra	c0ne,TR_ColorYCC		;Loop
	dotp	v1,v4,>>#30,v0[2]		;Cb Component
       }
       {
	mv_s	v3[0],v3[1]			;Backup v3[0]
	add	#0x20,v3[0]			;Next Point
       }
	st_sv	v0,(v3[1])			;Store YCC vector
       ;----------------------------------------;bra c0ne,TR_ColorYCC

TR_DecDone:

TR_Setup:
       ;* Calculate Area of tri012
       {
	jsr	TR_TriArea			;Calc XYarea tri123
	mv_s	#0x20,v0[1]			;Offset
       }
	mv_s	#MPR_X0,v4[0]			;Ptr X0
	mv_s	#MPR_Y0,v5[0]                   ;Ptr Y0
       ;----------------------------------------;jsr TR_TriArea
       {
        ld_s	(MPR_sbDMAF),v7[2] 		;Read DMA Flags
	jsr	lt,TR_SwapV1andV2		;Swap Vertices if CW
       }
       {
	ld_s	(MPR_sbFlags),v7[1]		;Read sbFlags
	bra	eq,TR_AllDone,nop		;Degenerate Triangle
       }
	abs	v0[0]				;Swap area
       ;----------------------------------------;jsr TR_SwapV1andV2

       ;* Sort Vertices in y
       {
	mv_s	#MPR_Y0,v6[0]			;Ptr Y
	jsr	TR_SortVertices			;Sort Vertices
       }
	ld_sv	(MPR_sbWINxw),v4		;Clip Window Coordinates
	nop
       ;----------------------------------------;jsr TR_SortVertices
       ;* Skip if not Visible
       {
	cmp	v2[0],v4[3]			;TopY >= BotClip
	mv_s	v2[3],v4[3]			;YOrientation
       }
       {
	bra	le,TR_AllDone			;Yap, Clip it
	cmp	v2[2],v4[2]			;BotY <= TopClip
       }
       {
	bra	ge,TR_AllDone,nop		;Yap, Clip it
	mv_v	v6,v5				;Ordered List
       }

       ;* Sort Vertices in x
       {
	mv_s	#MPR_X0,v6[0]			;Ptr X
	jsr	TR_SortVertices,nop		;Sort Vertices
       }
       ;----------------------------------------;jsr TR_SortVertices
       ;* Skip if not Visible
       {
	cmp	v2[0],v4[1]			;LeftX >= RightClip
       }
       {
	bra	le,TR_AllDone			;Yap, Clip it
	cmp	v2[2],v4[0]			;RightX <= LeftClip
       }
       {
	bra	ge,TR_AllDone			;Yap, Clip it
	ld_s	(MPR_sbWINyh),v1[1]		;Clip Window Coordinates
       }
       ;----------------------------------------;jsr MPR_Recip
	ld_s	(MPR_sbWINxw),v1[0]		;Clip Window Coordinates
       {
	st_s	v1[1],(xyrange)			;Set XYrange (YH clip)
	copy	v0[0],v7[3]			;Backup v0[0]
       }
       ;----------------------------------------;bra ge,TR_AllDone
       {
	st_s	v1[0],(uvrange)			;Set UVrange (XW clip)
	btst	#0,v4[3]			;Even Polygon Orientation ?
       }
       {
	bra	eq,TR_Longsideisleft,nop	;Yap, Middle is right
	st_s	v4[3],(MPR_LongSide)		;Store Long Left/Right
       }
       ;----------------------------------------;bra eq,TR_Longsideisleft
TR_Longsideisright:
       {
	jsr	TR_CalcEdgeStepper		;Calculate Edge Steppers
	sub	v3[3],v3[3]			;Clear v3[3]
       }
       {
	copy	v5[0],v4[0]			;Start at 0
	mv_s	#MPR_L1_LX,v4[3]		;Ptr LX
       }
       {
	mv_s	#MPR_DL1_LX,v4[2]		;Ptr DLX
	copy	v5[1],v4[1]			;End at 1
       }
       ;----------------------------------------;TR_CalcEdgeStepper
       {
	st_s	v0[0],(MPR_HGH1)		;Set Height Section 1
	jsr	TR_CalcEdgeStepper		;Calculate Edge Steppers
	sub	v3[3],v3[3]			;Clear v3[3]
       }
       {
	copy	v5[1],v4[0]			;Start at 1
	mv_s	#MPR_DL2_LX,v4[2]		;Ptr DLX
       }
       {
	mv_s	#MPR_L2_LX,v4[3]		;Ptr LX
	copy	v5[2],v4[1]			;End at 2
       }
       ;----------------------------------------;TR_CalcEdgeStepper
	st_s	v0[0],(MPR_HGH2)		;Set Height Section 2
	mv_s	#1,v3[3]			;Set v3[3]
       {
	bra	TR_CalcEdgeStepper		;Calculate Edge Steppers
	st_s	#TR_sidesdone,(rz)		;Set Return Address
       }
       {
	copy	v5[0],v4[0]			;Start at 0
	mv_s	#MPR_DL1_RX,v4[2]		;Ptr DRX
       }
       {
	mv_s	#MPR_L1_RX,v4[3]		;Ptr RX
	copy	v5[2],v4[1]			;End at 2
       }
       ;----------------------------------------;TR_CalcEdgeStepper
TR_Longsideisleft:
       {
	jsr	TR_CalcEdgeStepper		;Calculate Edge Steppers
	mv_s	#1,v3[3]			;Set v3[3]
       }
       {
	copy	v5[0],v4[0]			;Start at 0
	mv_s	#MPR_DL1_RX,v4[2]		;Ptr DRX
       }
       {
	mv_s	#MPR_L1_RX,v4[3]		;Ptr RX
	copy	v5[1],v4[1]			;End at 1
       }
       ;----------------------------------------;TR_CalcEdgeStepper
	st_s	v0[0],(MPR_HGH1)		;Set Height Section 1
       {
	jsr	TR_CalcEdgeStepper		;Calculate Edge Steppers
	mv_s	#1,v3[3]			;Set v3[3]
       }
       {
	copy	v5[1],v4[0]			;Start at 1
	mv_s	#MPR_DL2_RX,v4[2]		;Ptr DRX
       }
       {
	mv_s	#MPR_L2_RX,v4[3]		;Ptr RX
	copy	v5[2],v4[1]			;End at 2
       }
       ;----------------------------------------;TR_CalcEdgeStepper
       {
	st_s	v0[0],(MPR_HGH2)		;Set Height Section 2
	jsr	TR_CalcEdgeStepper		;Calculate Edge Steppers
	sub	v3[3],v3[3]			;Clear v3[3]
       }
       {
	copy	v5[0],v4[0]			;Start at 0
	mv_s	#MPR_L1_LX,v4[3]		;Ptr LX
       }
       {
	mv_s	#MPR_DL1_LX,v4[2]		;Ptr DLX
	copy	v5[2],v4[1]			;End at 2
       }
       ;----------------------------------------;TR_CalcEdgeStepper
TR_sidesdone:
       ;* Calculate Gradients
	range	ry				;Check bottom y clip
	jsr	modlt,MPR_Recip			;Find 1/XYarea
       {
	bra	TR_AllDone			;Exit (YStart invalid)
	st_s	v0[0],(MPR_YStart)		;Set Discrete Start Y
	copy	v7[3],v0[0]			;Recip Argument
       }
	mv_s	#12+4,v0[1]			;#of FracBits
       ;----------------------------------------;jsr MPR_Recip
	jsr	TR_CalcGradient			;Calculate Gradients
       {
	copy	v0[1],v1[1]			;Shift value
	mv_s	#MPR_DX_P,v4[3]
       }
       {
	mv_s	#MPR_Y0,v5[0]			;Ptr Y
	copy	v0[0],v1[0]			;1/XYarea
       }
       ;----------------------------------------;jsr TR_CalcGradient
       ;* Calculate Inner Loop ID
       {
	ld_s	(MPR_TexInfoC),r4		;Read Texture Type
	lsr	#7-EXTRASHF,v7[0],r3
       }
	and	#0x77<<EXTRASHF,r3 	 	;Polygon Type without Zbit
	btst	#UVBIT+7,v7[0]			;Texture Used ?
       {
	bra	eq,TR_NoTexMode			;Nope, Do Not Set Texture
	mv_s	r4,r5				;Texture Type
	bits	#1-1,>>#(BMBTRBIT+24),r4	;Extract Black Transparent
       }
	bits	#2-1,>>#24-1,r5			;Extract Lower bit of pixtype
       {
	bset	#0,r5				;Set YCC Source Texture
	mv_s	v7[1],r2
       }
       ;----------------------------------------;bra eq,TR_NoTexMode
	or	r5,r3  				;Insert Clut/Direct
	or	r4,>>#-(BTRABIT+EXTRASHF),r3	;Insert Black Transparent

       ;Find #pixels in pixbuf & Fetch Inner Loop Code
TR_NoTexMode:
       {
	mv_s	#pixbuflen<<16,_PMAX		;v2[0]
	jsr	MPR_FetchInnerCode		;Fetch Inner Loop Code
	bits	#4-1,>>#4,r2			;From sbFlags
       }
       {
	mv_s	#MPR_INTable,r0			;ptr Inner Loop Table
	ls	r2,_PMAX			;#of pixels/pixbuf 16.16
       }
       {
	mv_s	#MPR_PixBuf1,_PBUF		;Set Pixel Buffer v2[2]
	add	r3,>>#-3,r0			;ptr Inner Loop Code
       }
       ;----------------------------------------;jsr MPR_FetchInnerCode
	jsr	MPR_Waitallbuses		;Wait for ALL DMA to go idle
	ld_s	(MPR_sbSDRAM),v1[3]		;Read Screen SDRAM address
	nop
       ;----------------------------------------;jsr MPR_Waitallbuses

       ;* Setup Main Bus Write Command &
       ;*Render Triangle
       ;* Enter Section #1
	ld_s	(MPR_HGH1),r0			;Fetch Height of This Section
       {
	st_s	v7[2],(MPR_MDMA1)		;Set DMA Flags
	or	#(1<<13)|NW_Z,v7[2]    		;Pixel Only Mode for Read
       }
	st_s	r0,(rc1)			;Set #of scanlines Counter
       {
	jsr	c1ne,TR_OuterStart		;Execute outer loop
	st_s	v1[3],(SDRAM1)			;Set SDRAM address
       }
       ;* Setup Main Bus Read Command
	st_s	v1[3],(SDRAM2)			;Set SDRAM address
	st_s	v7[2],(MPR_MDMA2)		;Set DMA Flags
       ;----------------------------------------;jsr c1ne,TR_OuterStart

       ;* Enter Section #2
	ld_s	(MPR_HGH2),r0			;Fetch Height of This Section
	ld_s	(MPR_LongSide),r1		;Fetch Side Flag
	st_s	r0,(rc1)			;Set #of scanlines Counter
	st_s	#TR_AllDone,(rz)		;Set Return Address
       {
	rts	c1eq,nop			;Quit if no scanlines
	ld_v	(MPR_L2_P),v4			;Fetch Left2a
	btst	#0,r1				;Even Polygon Orientation ?
       }
       ;----------------------------------------;rts c1eq,nop
       {
	bra	ne,TR_OutLongsideisright	;Nope, Middle is left
	ld_v	(MPR_L2_P+0x10),v5		;Fetch Left2b
       }
	ld_v	(MPR_DL2_P),v6			;Fetch  Delta Left 2a
	ld_v	(MPR_DL2_P+0x10),v7		;Fetch  Delta Left 2b
       ;----------------------------------------;bra eq,TR_OutLongsideisleft
TR_OutLongsideisleft:
	bra	TR_OuterStart			;Render Section #2
	st_s	v5[3],(MPR_L1_RX)		;Set new Right X
	st_s	v7[3],(MPR_DL1_RX)		;Set new Left Delta Right X
       ;----------------------------------------;bra TR_OuterStart
TR_OutLongsideisright:
	ld_s	(MPR_L1_RX),v5[3]		;Restore old RX
	ld_s	(MPR_DL1_RX),v7[3]		;Restore old DRX

	st_v	v4,(MPR_L1_P) 	  		;Set Left2a
	st_v	v5,(MPR_L1_P+0x10)		;Set Left2b
	st_v	v6,(MPR_DL1_P)			;Set Delta Left 2a
	st_v	v7,(MPR_DL1_P+0x10)		;Set Delta Left 2b

       ;* Outer Loop
TR_OuterStart:
	ld_v	(MPR_L1_P+0x10),v0  		;Fetch v0[2] LX v0[3] RX
	ld_v	(MPR_LUVZ),_LUVZ		;Fetch v7
	ld_s	(rz),v1[0]			;Fetch Return Address
	ld_sv	(MPR_LGRBA),_LGRBA		;Fetch v6
	st_s	v1[0],(MPR_Return)		;Set Return Address

TR_OuterLp:
       {
	st_s	#16,(acshift)			;Set Multiply Shift value
	add	#0xFFFF,v0[2],_LX		;Round up LX
       }
       {
	and	#0xFFFF0000,_LX			;Ceil(LX)
       }
       {
	mvr	_LX,ru 				;Set Left X for Clipping
	add	#0xFFFF,v0[3],_WIDXTOT		;Round up RX
       }
       {
	ld_v	(MPR_DUVZ),_DUVZ		;Fetch DUVZ
	and	#0xFFFF0000,_WIDXTOT		;Ceil(RX)
	range	ru				;Set Left Clip cc
       }
       {
	bra	modlt,TR_LeftClip,nop		;If Set, Left Clip Necessary
	mvr	_WIDXTOT,rv			;Set Right X for Clipping
	sub	v0[2],_LX,v0[0]			;Pre-Step value
       }
       ;----------------------------------------;bra modlt,TR_LeftClip,nop
TR_LeftClipDone:
       {
	mul	v0[0],_DU,>>acshift,v1[0]	;Step in u
	range	rv				;Set Right Clip cc
       }
       {
	bra	modge,TR_RightClip,nop		;If Set, Right Clip Necessary
	mul	v0[0],_DV,>>acshift,v1[1]	;Step in v
       }
       ;----------------------------------------;bra modge,TR_RightClip,nop
TR_RightClipDone:
       {
	mul	v0[0],_DiZ,>>acshift,v1[2]	;Step in iz
	sub	_LX,_WIDXTOT			;Discrete Width 16.16
	ld_sv	(MPR_DGRBA),_DGRBA		;Fetch DGRBA
       }
       {
	bra	le,TR_NextScan,nop		;Invalid Width, Next Scanline
	mul	v0[0],_DZ,>>acshift,v1[3]	;Step in z
	add	v1[0],_LU			;Pre-Step u
       }
       ;----------------------------------------;bra le,TR_NextScan,nop
       {
	mv_s	#1<<16,_HGHYCUR			;YLength 16.16
	mul	v0[0],_DG,>>acshift,v1[0]	;Step in g
	add	v1[1],_LV			;Pre-Step v
       }
       {
	ld_s	(ry),_TY			;Fetch YStart 16.16
	mul	v0[0],_DR,>>acshift,v1[1]	;Step in r
	add	v1[2],_LiZ			;Pre-Step iz
       }
       {
	mvr	_LU,ru				;Set ru
	mul	v0[0],_DB,>>acshift,v1[2]	;Step in b
	add	v1[3],_LZ			;Pre-Step z
       }
       {
	mvr	_LV,rv				;Set rv
	mul	v0[0],_DA,>>acshift,v1[3]	;Step in a
	add	v1[0],_LG			;Pre-Step g
       }
	add	v1[1],_LR			;Pre-Step r
       {
	add	v1[2],_LB			;Pre-Step b
	addm	v1[3],_LA			;Pre-Step a
       }
       {
	st_s	#0,(acshift)			;Set Multiply Shift value
	cmp	#0,_WIDXTOT			;Chech Width
       }

TRIScanLoop:
       {
	bra	le,TR_NextScan			;(Width <= 0)
	cmp	_WIDXTOT,_PMAX			;X Width TOT <= Pixels/Pixbuf
	ld_sv	(MPR_DGRBA),_DGRBA		;Fetch DGRBA
       }
       {
	bra	ge,TRICacheWidok 		;Yap, Render
	ld_s	(mdmactl),r0			;Read Main DMA Control
       }
	st_s	_PBUF,(xybase)			;Set XY Base
       {
	mv_s	_WIDXTOT,_WIDXCUR		;Set Current Width
	ftst	#0xE,r0				;0 or 1 DMA Active ?
       }
       ;----------------------------------------;bra ge,SPRDMALp
	mv_s	_PMAX,_WIDXCUR			;Set Current Width

TRICacheWidok:
TRIDMAa2:
       {
	bra	ne,TRIDMAa2			;Nope, Wait
	ld_s	(mdmactl),r0			;Read Main DMA Control
	mvr	#0,rx				;Clear rx
       }
       {
	jsr	(mprinnerbase)	       		;Pixel Generator
	st_v	_WXCLXHYCTY,(MPR_WXCLXHYCTY)	;Backup Data
	lsr	#16,_WIDXCUR,r1			;Discrete Length
       }
       {
	st_s	r1,(rc0)			;Set Inner Loop Counter
	ftst	#0xE,r0				;0 or 1 DMA Active ?
       }
       {
	st_v	_PMXWXTPBF,(MPR_PMXWXTPBF)	;Backup Data
       }
       ;----------------------------------------;jsr Pixel Generator


TRIWriteDMA:
;r0 #of Transparent Pixels returned by Pixel Generator in 16.16
;r1 Translucency Flag - ne for Translucency
;NOTE: if _WIDXCUR is 0, r1 should be cleared as well!!!
;      NO MV_S instructions in 1st packet here!!!
	ld_s	(mdmactl),r2			;Read Main DMA Control
       {
	ld_v	(MPR_WXCLXHYCTY),_WXCLXHYCTY	;Restore Data
	cmp	#0,r1				;Translucency On ?
       }
       {
	jsr	ne,SPRTranslucent		;Yap, Execute Translucency
	ld_v	(MPR_PMXWXTPBF),_PMXWXTPBF	;Restore Data
	btst	#4,r2				;DMA Pending ?
       }
       {
	bra	ne,TRIWriteDMA,nop		;Nope, Wait
	addm    _WIDXCUR,r0,r3			;r1 _WIDXCUR+Transparent Pixels
	cmp	#0,_WIDXCUR			;Anything to DMA away ?
       }
       ;----------------------------------------;bra ne,SPRWriteDMA
       {
	bra	eq,TRIScanLoop,nop 		;Loop X if nothing to DMA
	addm	r0,_LX				;Skip #of Transparent Pixels
	sub	r3,_WIDXTOT			;Subtract #pixels rendered
       }
       ;----------------------------------------;bra eq,SPRXLoop or jsr SPRTranslucent
       {
	bra	gt,TRIScanLoop			;Loop X
	st_sv	_WXCLXHYCTY,(XPLEN1)		;Set XY & XYLen
	addm	_WIDXCUR,_LX			;Increment _LX
       }
       {
	st_s	_PBUF,(MPEAD1)			;Set MPE Source Address
	eor	#MPR_PixBufeor,_PBUF		;Switch PixBuf
       }
       {
	st_s	#MPR_MDMA1,(mdmacptr)		;Launch DMA
	cmp	#0,_WIDXTOT 			;Set CC
       }
       ;----------------------------------------;TRIScanLoop
TR_NextScan:
       {
	ld_v	(MPR_LUVZ),_LUVZ		;Read _LUVZ
	addr    #1<<16,ry			;Next scanline
	dec	rc1				;Decrement #of scanlines
       }
       {
	ld_v	(MPR_DLUVZ),_DUVZ		;Read _DLUVZ
	range	ry				;
       }
       {
	bra	modge,TR_AllDone,nop		;Bottom Clip
	ld_sv	(MPR_LGRBA),_LGRBA		;Read _LGRBA
       }
       ;----------------------------------------;bra modge,TR_AllDone,nop
       {
	ld_v	(MPR_L1_P+0x10),v0  		;Fetch v0[2] LX v0[3] RX
	add	_DU,_LU				;Update U
	addm	_DV,_LV                         ;Update V
       }
       {
	ld_v	(MPR_DL1_P+0x10),v1		;Fetch v1[1] DLX v1[3] DRX
	add	_DiZ,_LiZ			;Update iZ
	addm	_DZ,_LZ                         ;Update Z
       }
       {
	ld_sv	(MPR_DLGRBA),_DGRBA		;Read _DLGRBA
       }
       {
	bra	c1ne,TR_OuterLp			;bra c1ne,TR_OuterLp
	st_v	_LUVZ,(MPR_LUVZ)		;Store _LUVZ
	add	v1[2],v0[2]			;Step LX
	addm	v1[3],v0[3]			;Step RX
       }
       {
	st_v	v0,(MPR_L1_P+0x10)  		;Store v0[2] LX v0[3] RX
	add_sv	_DGRBA,_LGRBA			;Update GRBA
       }
	st_sv	_LGRBA,(MPR_LGRBA)		;Store _LGRBA
       ;----------------------------------------;bra c1ne,TR_OuterLp
TR_Outerdone:
	ld_s	(MPR_Return),r0			;Fetch Return Address
	nop
	jmp	(r0),nop			;Return now
       ;----------------------------------------;jmp (r0),nop

TR_LeftClip:
	ld_s	(uvrange),_LX			;Fetch Left X
	bra	TR_LeftClipDone			;Done
	and	#0xFFFF0000,_LX			;Extract new LX
	sub	v0[2],_LX,v0[0]			;Pre-Step value
       ;----------------------------------------;TR_LeftClipDone
TR_RightClip:
       {
	bra	TR_RightClipDone		;Done
	ld_s	(uvrange),_WIDXTOT		;Fetch Right X
       }
	nop
	lsl	#16,_WIDXTOT			;Extract Right X
       ;----------------------------------------;TR_RightClipDone

       ;* Translucency Loop
;* Note:
;* Some Pixel Generators screw around with GRBA[3]
;* These should backup GRBA[3] properly!
;* DGRBA[3] is reloaded here since it is a constant

SPRTranslucent:
;* Setup	22 cycles
;* Per Pixel	3 cycles
;* Exit		7 cycles


	st_v	_WXCLXHYCTY,(MPR_WXCLXHYCTY)	;Backup Data
       {
	st_v	_PMXWXTPBF,(MPR_PMXWXTPBF)	;Backup Data
	eor	#MPR_PixBufeor,_PBUF		;Switch PixBuf
       }
	st_s	_PBUF,(MPEAD2)			;Set MPE Source Address
	st_sv	_WXCLXHYCTY,(XPLEN2)		;Set XY & XYLen

`WaitDMAP:
	ld_s	(mdmactl),r2			;Read Main DMA Control
	ld_s	(xyctl),r0			;Read xyctl
	btst	#4,r2				;DMA Pending ?
       {
	bra	ne,`WaitDMAP,nop		;Nope, Wait for Pending DMA
	lsr	#20,r0				;Shift down
       }
       {
	st_s	#MPR_MDMA2,(mdmacptr)		;Launch DMA
	and	#0xF,r0,r1			;Extract Pixel Type
       }
       {
	ld_s	(uvbase),_DB			;Backup uvbase
	cmp	#PIX_16B_WITHZ,r1		;16Bit+Z ?
       }
       {
	ld_s	(uvctl),_DG			;Backup uvctl
	bra	ne,`SPRno16bz			;Nope,
       }
	ld_s	(ru),_DR			;Backup ru
	cmp	#PIX_32B_WITHZ,r1		;32Bit+Z ?
       ;----------------------------------------;bra ne,`SPRno16b
	eor	#PIX_16B_WITHZ^PIX_16B,r0	;Set 16Bit No Z
`SPRno16bz:
       {
	bra	ne,`SPRno32bz			;Nope,
	st_s	_PBUF,(uvbase)			;Set New uvbase
	subm	r2,r2				;Clear r2
       }
       {
	lsr	#16,_WIDXCUR			;Discrete WIDXCUR
	mvr	r2,rx				;Clear rx
       }
       {
	st_s	_WIDXCUR,(rc0)			;Set Inner Loop Counter
	mvr	r2,ru				;Clear ru
       }
       ;----------------------------------------;bra ne,`SPRno16b
	eor	#PIX_32B_WITHZ^PIX_32B,r0	;Set 32Bit No Z
`SPRno32bz:
       {
	lsl	#20,r0                   	;Shift up
	mv_s	#1<<30,v0[3]			;One in 2.30
       }
       {
	ld_s	(MPR_BackGroundAlpha),v2[3]	;Fetch BackGround alpha
	sub	v0[3],_A			;Alpha = -(1-Alpha)
       }

`WaitDMAF:
	ld_s	(mdmactl),r2			;Read Main DMA Control
	ld_w	(MPR_DGRBA+(3*2)),_DA		;Fetch Delta Alpha
       {
	st_s	r0,(uvctl)			;Set new uvctl
	bits	#4,>>#0,r2			;DMA Finished ?
       }
       {
	bra	ne,`WaitDMAF,nop		;Nope, Wait for Pending DMA
       }
       ;----------------------------------------;bra ne,`WaitDMAF

	;Setup for Translucency Loop
	ld_p	(uv),v0				;Read BackGround
	addr	#1<<16,ru			;Next pixel
       {
	ld_pz	(xy),v1				;Read ForeGround
	addr	#1<<16,rx			;Next pixel
	mul_p	v2[3],v0,>>#30,v0  		;(BackGroundAlpha)*v0
       }
       {
	ld_p	(uv),v2				;Read BackGround
	addr	#1<<16,ru			;Next pixel
       }
       {
	mul_p	_A,v1,>>#30,v1 			;-(1-Alpha)*v1
	add	_DA,_A				;Update Alpha
	dec	rc0				;Decrement Inner Loop Counter
       }
       {
	ld_pz	(xy),v3				;Read ForeGround
	addr	#-1<<16,rx			;Next pixel
	mul_p	v2[3],v2,>>#30,v2   		;(BackGroundAlpha)*v2
       }

`Luceloop:
       {
	bra	c0eq,SPRTranslucencyDone	;Finished
	add_p	v0,v1				;Accumulate v0 & v1
	ld_p	(uv),v0				;Read BackGround
	addr	#1<<16,ru			;Next pixel
	dec	rc0				;Decrement Inner Loop Counter
       }
       {
	st_pz	v1,(xy)				;Store Destination Pixel
	addr	#2<<16,rx			;Next pixel
	mul_p	_A,v3,>>#30,v3	  		;-(1-Alpha)*v3
	add	_DA,_A				;Update Alpha
       }
       {
	ld_pz	(xy),v1				;Read ForeGround
	addr	#-1<<16,rx			;Next pixel
	mul_p	v2[3],v0,>>#30,v0     		;(BackGroundAlpha)*v0
       }
       {
	bra	c0ne,`Luceloop			;Loop
	add_p	v2,v3				;Accumulate v2 & v3
	ld_p	(uv),v2				;Read BackGround
	addr	#1<<16,ru			;Next pixel
	dec	rc0				;Decrement Inner Loop Counter
       }
       {
	st_pz	v3,(xy)				;Store Destination Pixel
	addr	#2<<16,rx			;Next pixel
	mul_p	_A,v1,>>#30,v1 			;-(1-Alpha)*v1
	add	_DA,_A				;Update Alpha
       }
       {
	ld_pz	(xy),v3				;Read ForeGround
	addr	#-1<<16,rx			;Next pixel
	mul_p	v2[3],v2,>>#30,v2 		;(BackGroundAlpha)*v2
       }

SPRTranslucencyDone:
       {
	add	v0[3],_A			;Restore Original Alpha
	st_s	_DB,(uvbase)			;Restore uvbase
       }
	st_s	_DG,(uvctl)			;Restore uvctl
	st_s	_DR,(ru)			;Restore ru
       {
	ld_v	(MPR_PMXWXTPBF),_PMXWXTPBF	;Restore Data
	rts					;Done
       }
	ld_v	(MPR_WXCLXHYCTY),_WXCLXHYCTY	;Restore Data
       {
	ld_sv	(MPR_DGRBA),_DGRBA		;Restore Data
	cmp	#0,_WIDXTOT			;Fix cc
       }



       ;* Triangle is rendered
TR_AllDone:
	ld_s	(MPR_QuadFlag),r0		;Fetch Quadrangle Flag
	st_s	#MPR_NextCommand,(rz)		;Set Return Address
       {
	ld_s	(MPR_PolyType),v7[0]		;Set Polygon Type
	sub	#1,r0				;Last Triangle ?
       }
       {
	rts	mi,nop				;Yap, Finished!
	st_s	r0,(MPR_QuadFlag)		;Set new Quadrangle Flag
       }
	ld_v	(MPR_P3),v0			;Fetch 1st Vector
       {
	bra	TR_Setup			;Next Triangle
	ld_v	(MPR_P3+0x10),v1		;Fetch 2nd Vector
       }
	st_v	v0,(MPR_P0)			;Set P0
	st_v	v1,(MPR_P0+0x10)  		;Set P0
       ;----------------------------------------;bra TR_Setup

;* TR_DecodePacket
;*  cycles: 13
;* Input:
;*  v2	  Packet to Decode
;*  v3[0] Destination Point address
;* Output:
;*
;* Scrambles:
;*  v0, v1, v2, v3[2], v3[3]

TR_DecodePacket:
       {
	mv_s	#0xFFFFF000,v3[2]		;v3[2] 0xFFFFF000
	asr	#16,v2[3],v0[3]    		;signed u 6.10
	mul	#1,v2[3],>>#-16,v2[3]		;v up
       }
       {
	st_s	v2[2],(MPR_PIXtemp)		;Store color field
	asr	#4,v2[1],v0[1]			;signed x 16.16
	mul	#1,v2[1],>>#-16,v2[1]		;y up
       }
       {
	lsr	#16,v3[2],v3[3]			;v3[3] 0xFFFF
	mul	#1,v2[3],>>#16,v2[3]		;signed v 6.10
       }
       {
	ld_s	(linpixctl),v0[2]		;Backup linpixctl
	lsl	#6,v0[3]			;Extract signed u 16.16
	mul	#1,v2[1],>>#4,v2[1]		;signed x 16.16
       }
       {
	st_s	v0[3],(v3[0])			;Store signed u 16.16
	add	#4,v3[0]			;ptr v
       }
       {
	mv_s	v2[0],v1[1]  		;Backup
	btst	#15,v2[0]		;DeNormalisation Needed ?
       }
       {
	bra	eq,`NoDeNorm		;Nope, Skip DeNormalisation
	and	#0x7FF,v2[0],v1[0]	;Extract
	mul	#1,v1[1],>>#-16,v1[1]	;Shift up
       }
       {
	st_s	#PIX_32B<<20,(linpixctl)	;Set 32Bit GRB
	bset	#11,v1[0]		;Set Bit #11
       }
       {
	mul	#1,v2[3],>>#-6,v2[3]	;Extract signed v 16.16
	asr	#27,v1[1]		;Extract Shift
       }
       ;--------------------------------;bra eq,`NoDeNorm
	sub	#3,v1[1]		;Correct Shift
 	ls	v1[1],v1[0],v2[0] 	;Denormalize
`NoDeNorm:
       {
	ld_pz	(MPR_PIXtemp),v1		;Read GRB Components
	and	v3[2],v0[1]			;Extract signed x 16.16
       }
       {
	st_s	v2[3],(v3[0])			;Store signed v 16.16
	add	#8,v3[0]			;ptr z
       }
       {
	st_s	v2[0],(v3[0])			;Store z
	add	#12,v3[0]			;ptr x
       }
       {
	lsr	#2,v1[3]			;Shift alpha as 2.30
	addm	v5[0],v0[1]			;Add Render X Offset
       }
       {
	st_s	v0[1],(v3[0])			;Store signed x 16.16
	sub	#8,v3[0]			;ptr GRBa
       }
       {
	rts					;Done
	and	v3[2],v2[1]			;Extract signed y 16.16
	st_sv	v1,(v3[0])			;Store RGB GRBa
       }
       {
	st_s	v0[2],(linpixctl)		;Restore linpixctl
	add	#12,v3[0]			;ptr y
	addm	v5[2],v2[1]			;Add Render Y Offset
       }
       {
	st_s	v2[1],(v3[0])			;Store signed y 16.16
	add	#4,v3[0]			;ptr Next Point
       }
       ;----------------------------------------;rts

;* TR_TriArea
;* Cycles: 11
;* Input:
;*  v0[1] Offset Next Point
;*  v4[0] Source X0
;*  v5[0] Source Y0
;* Output:
;*  v0[0] Area*2
;* Scrambles:
;*  v2, v3, v4, v5

TR_TriArea:
       {
	ld_s	(v4[0]),v2[0]			;read x0
	add	v0[1],v4[0],v4[1]		;Ptr x1
       }
       {
	ld_s	(v4[1]),v2[1]			;read x1
	addm	v0[1],v4[1],v4[2]		;Ptr x1
	add	#0x20,v5[0],v5[1]		;Ptr y1
       }
       {
	ld_s	(v4[2]),v2[2]			;read x2
	add	#0x20,v5[1],v5[2]		;Ptr y2
       }
       {
	ld_s	(v5[0]),v3[0]			;read y0
	sub	v2[0],v2[1]			;v2[1] x1 - x0
       }
       {
	ld_s	(v5[2]),v3[2]			;read y2
	sub	v2[0],v2[2]			;v2[2] x2 - x0
       }
       {
	ld_s	(v5[1]),v3[1]			;read y1
       }
TR_TrTriCalc:
	sub	v3[0],v3[2]			;v3[2] y2 - y0
       {
	sub	v3[0],v3[1]			;v3[1] y1 - y0
	mul	v3[2],v2[1],>>#32-4,v2[1]	;v2[1] (x1-x0)(y2-y0)
       }
       {
	mul	v3[1],v2[2],>>#32-4,v2[2]	;v2[2] (x2-x0)(y1-y0)
	rts					;Done
       }
	copy	v2[1],v0[0]			;
	sub	v2[2],v0[0]			;Result
       ;----------------------------------------;rts

;* TR_SortVertices
;* Cycles: 19
;* Input:
;*  v6[0] Vertex position Point 0
;* Output:
;*  v2[0] Top Vertex
;*  v2[1] Middle Vertex
;*  v2[2] Bottom Vertex
;*  v2[3] Polygon Orientation
;*  v6[0] Top Vertex Ptr
;*  v6[1] Middle Vertex Ptr
;*  v6[2] Bottom Vertex Ptr
;*  v6[3] Width/Height
;* Scrambles:
;*  v2

TR_SortVertices:
       {
	ld_s	(v6[0]),v2[0]			;Vertex 0
	add	#0x20,v6[0],v6[1]		;Ptr Vertex #2
       }
       {
	ld_s	(v6[1]),v2[1]			;Vertex 1
	add	#0x20,v6[1],v6[2]		;Ptr Vertex #3
       }
	ld_s	(v6[2]),v2[2]			;Vertex 2
	cmp	v2[0],v2[1]			;y0 <= y1
       {
	bra	ge,TRsortnoswap1
	sub	v2[3],v2[3]			;Clear v2[3]
       }
	sub	v6[3],v6[3]			;Clear v6[3]
	cmp	v2[0],v2[2]			;y0 <= y2
       ;----------------------------------------;bra ge,TRsortnoswap1
       {
	mv_s	v2[0],v2[1]
	addm	v2[1],v6[3],v2[0]
	eor	#1,v2[3]			;Swap Poly Orientation
       }
       {
	mv_s	v6[0],v6[1]
	addm	v6[1],v6[3],v6[0]
	cmp	v2[0],v2[2]
       }
TRsortnoswap1:
	bra	ge,TRsortnoswap2
	nop
	cmp	v2[1],v2[2]			;y1 <= y2
       ;----------------------------------------;bra ge,TRsortnoswap2
       {
	mv_s	v2[0],v2[2]
	addm	v2[2],v6[3],v2[0]
	eor	#1,v2[3]			;Swap Poly Orientation
       }
       {
	mv_s	v6[0],v6[2]
	addm	v6[2],v6[3],v6[0]
	cmp	v2[1],v2[2]
       }
TRsortnoswap2:
	rts	ge				;Done
	subm	v2[0],v2[2],v6[3]		;Height/Width
	rts                                     ;Done
       ;----------------------------------------;rts ge
       {
	mv_s	v2[1],v2[2]
	addm	v2[2],v6[3],v2[1]
	eor	#1,v2[3]			;Swap Poly Orientation
       }
       {
	mv_s	v6[1],v6[2]
	copy	v6[2],v6[1]
	subm	v2[0],v2[2],v6[3]		;Height/Width
       }

;* TR_SwapV1andV2
;* Cycles: 9
;* Input:
;*  None
;* Output:
;*  None
;* Scrambles:
;*  v0[2],v1,v2
TR_SwapV1andV2:
	mv_s	#MPR_P1,v0[2]			;Ptr P1:1st Vector
TR_SwapIt:
       {
	ld_v	(v0[2]),v1			;Read v1
	add	#0x20,v0[2]			;Ptr P2:1st Vector
       }
       {
	ld_v	(v0[2]),v2			;Read v2
       }
       {
	st_v	v1,(v0[2])			;Store v1
	sub	#0x20,v0[2]			;Ptr P1:1st Vector
       }
       {
	st_v	v2,(v0[2])			;Store v2
	add	#0x10,v0[2]			;Ptr P1:2nd Vector
       }
       {
	ld_v	(v0[2]),v1			;Read v1
	add	#0x20,v0[2]			;Ptr P2:2nd Vector
       }
       {
	rts					;Done
	ld_v	(v0[2]),v2			;Read v2
       }
       {
	st_v	v1,(v0[2])			;Store v1
	sub	#0x20,v0[2]			;Ptr P1:2nd Vector
       }
	st_v	v2,(v0[2])			;Store v2
       ;----------------------------------------;rts

;* TR_CalcGradient
;* Cycles:
;* Input:
;*  v1[0] Recip Value
;*  v1[1] Recip Shift
;*  v4[3] Gradient Ptr
;*  v4[0] Ptr U
;*  v5[0] Ptr X/Y
;* Output:
;*  None
;* Scrambles:
;*  v0[1],v1,v2
TR_CalcGradient:
	ld_s	(rz),v1[3]			;Backup Return Address
	st_s	#4,(rc0)			;#of Gradients
	mv_s	#MPR_U0,v4[0]			;Ptr U0
TR_GrCalcLp:
       {
	dec	rc0				;Decrement Loop Counter
	mv_s	#0x20,v0[1]			;Offset next
	jsr	TR_TriArea,nop			;Calc Area
       }
       ;----------------------------------------;jsr TR_triarea
       {
       	bra	c0ne,TR_GrCalcLp		;Loop
	mul	v1[0],v0[0],>>v1[1],v0[0]	;
       }
	add	#4,v4[0]			;Next Parameter
       {
	st_s	v0[0],(v4[3])			;Store Gradient
	add	#4,v4[3]			;Next Gradient ptr
       }
       ;----------------------------------------;bra c0ne,TR_GrCalcLp
       ;* Convert Words To Longs
       {
	mv_s	#MPR_Dump,v4[3]			;MPR_Dump Area
	copy	v4[3],v1[2]			;Backup Destination
       }
	mv_s	#0x10,v0[1]			;Offset next
	ld_sv	(MPR_G0),v2
       {
	ld_sv	(MPR_G1),v3
	copy	v4[3],v4[0]			;Set v4[0]
       }
       {
	st_v	v2,(v4[3])
	add	v0[1],v4[3]
       }
	ld_sv	(MPR_G2),v2
       {
	st_v	v3,(v4[3])
	add	v0[1],v4[3]
       }
       {
	st_v	v2,(v4[3])
	add	v0[1],v4[3]
       }
	st_s	#4,(rc0)			;#of Gradients
TR_GrCalcLp2:
       {
	dec	rc0				;Decrement Loop Counter
	jsr	TR_TriArea,nop			;Calc Area
       }
       ;----------------------------------------;jsr TR_triarea
       {
       	bra	c0ne,TR_GrCalcLp2		;Loop
	mul	v1[0],v0[0],>>v1[1],v0[0]	;
       }
       {
	st_s	v1[3],(rz)			;Set Return Address
	add	#4,v4[0]			;Next Parameter
       }
       {
	st_s	v0[0],(v4[3])			;Store Gradient
	add	#4,v4[3]			;Next Gradient ptr
       }
       ;----------------------------------------;bra c0ne,TR_GrCalcLp
       {
	ld_v	(MPR_Dump+3*16),v2
	rts
       }
	nop					;Delay slot
	st_sv	v2,(v1[2])			;Store Gradients
       ;----------------------------------------;rts

;* TR_CalcEdgeStepper
;* Cycles:
;* Input:
;*  v3[3] 0 for Left / Non 0 for Right
;*  v4[0] Ptr P0 Source Info X0/Y0
;*  v4[1] Ptr P1 Source Info X1/Y1
;*  v4[2] Ptr Destination Stepper 01
;*  v4[3] Ptr Destination Pre-Stepped 0 Values
;* Output:
;*  v0[0] Discrete Height - Zero for Invisible Edge
;*  ry    Discrete Ystart
;* Scrambles:
;*  v0,v1,v2,v3,v4,ry

TR_CalcEdgeStepper:
       {
	mv_s	#0xFFFF,v1[0]			;v1[0] 0xFFFF
	sub	v0[0],v0[0]			;Clear v0[0]
       }
       {
	ld_s	(v4[1]),v1[3]			;Read y1
	lsl	#16,v1[0],v1[1]			;v1[1] 0xFFFF0000
       }
       {
	ld_s	(xyrange),v3[0]			;Read TopClip
	eor	#4,v4[1]			;Switch x1
       }
       {
	ld_s	(v4[0]),v3[1]			;Read y0
	eor	#4,v4[0]			;Switch x0
       }
       {
	ld_s	(rz),v3[2]			;Backup Return Address
	and	v1[1],v3[0]			;Extract TopClip
       }
       {
	ld_s	(v4[0]),v2[2]			;Read x0
	cmp	v1[3],v3[0]			;y1 <= TopClip
       }
	rts	ge,nop				;Yap, Invisible Edge
       ;----------------------------------------;rts ge,nop
       {
	ld_s	(v4[1]),v2[3]			;Read x1
	addm	v1[0],v3[1],v1[2]		;v1[2] Rounded up y0
	sub	v3[1],v1[3],v0[0]		;Height
       }
       {
	rts	eq,nop				;Invisible Edge
	add	v1[0],v1[3]			;v1[3] Rounded up y1
       }
       ;----------------------------------------;rts eq,nop
       {
	jsr	MPR_Recip			;Calculate Reciprocal
	and	v1[1],v1[2]			;v1[2] Ceil y0
       }
       {
	and	v1[1],v1[3]			;v1[3] Ceil y1
       }
       {
	mv_s	#16,v0[1]			;#of Fractional Bits
	sub	v2[2],v2[3]			;x1-x0
       }
       ;----------------------------------------;jsr MPR_Recip
       {
	mv_s	#-1,v2[1]			;v2[1] 0xFFFFFFFF
	cmp	v3[0],v1[2]			;y0 <= TopClip
       }
       {
	bra	ge,TR_EStopok			;Yap, do NOT replace y0
	lsl	#5,v2[1]			;v2[1] 0xFFFFFFE0
	mul	v0[0],v2[3],>>v0[1],v2[3]	;v2[3] XStepper
	st_s	v3[2],(rz)			;Restore Return Address
       }
       {
	mv_s	v0[0],v0[2]			;Recip Value
	and	v2[1],v4[0]			;Ptr p0 info
       }
       {
	st_s	v2[3],(v4[2])			;Store Stepper x0-x1
	and	v2[1],v4[1]			;Ptr p1 info
       }
       ;----------------------------------------;bra ge,TR_EStopok
	copy	v3[0],v1[2]			;Replace y0
TR_EStopok:
       {
	subm	v3[1],v1[2],v0[3] 		;Pre-Step Value
	sub	v1[2],v1[3],v0[0]		;Discrete Height
	mvr	v1[2],ry			;Set ry as ystart
       }
       {
	rts	eq				;Invisible Edge
	mul	v0[3],v2[3],>>#16,v2[3]		;Pre-Step*Stepper
	lsr	#16,v0[0]			;Integer(Discrete Height)
	ld_v	(v4[0]),v1			;Read u0v0iz0z0
       }
       {
	ld_v	(v4[1]),v3			;Read u1v1iz1z1
	cmp	#0,v3[3]			;Right Stepper ?
       }
       {
	rts	ne				;Yap, Quit
	cmp	#0x1E,v0[1]			;Shift value big enough ?
       }
       {
	bra	ge,`sftok			;Yap, shift ok
	and	v2[1],v4[2]			;Ptr Stepper 01 start
	addm	v2[3],v2[2]			;Pre-Stepped X
       }
       ;----------------------------------------;rts eq
       {
	st_s	v2[2],(v4[3])			;Store Pre-Stepped x0
	and	v2[1],v4[3]			;Ptr Pre-Stepped 0 start
       }
       ;----------------------------------------;rts ne
       {
	subm	v1[0],v3[0]			;p1-p0
	st_s	#16,(acshift)			;Set acshift
       }
       ;----------------------------------------;bra ge,`sftok
       {
	st_s	#16-subres,(acshift)		;Set acshift
	add	#subres,v0[1]			;Shift it up
       }
`sftok:

       {
	mul	v0[2],v3[0],>>v0[1],v3[0]	;(p1-p0)/hgh
	sub	v1[1],v3[1]			;p1-p0
       }
       {
	mul	v0[2],v3[1],>>v0[1],v3[1]	;(p1-p0)/hgh
	sub	v1[2],v3[2]			;p1-p0
       }
       {
	mul	v0[2],v3[2],>>v0[1],v3[2]	;(p1-p0)/hgh
	sub	v1[3],v3[3]			;p1-p0
       }
       {
	mul	v0[2],v3[3],>>v0[1],v3[3]	;(p1-p0)/hgh
	add	#0x10,v4[0]			;Ptr Next 0
       }
	add	#0x10,v4[1]			;Ptr Next 1
       {
	st_v	v3,(v4[2])			;Store dudvdizdz
	add	#0x10,v4[2]			;Ptr Next
	mul	v0[3],v3[0],>>acshift,v3[0]		;Pre-Step*dlu
       }
	mul	v0[3],v3[1],>>acshift,v3[1]		;Pre-Step*dlv
       {
	mul	v0[3],v3[2],>>acshift,v3[2]		;Pre-Step*dliz
	add	v3[0],v1[0]			;Pre-Stepped u
       }
       {
	mul	v0[3],v3[3],>>acshift,v3[3]		;Pre-Step*dlz
	add	v3[1],v1[1]			;Pre-Stepped v
       }
       {
	add	v3[2],v1[2]			;Pre-Stepped iz
	ld_sv	(v4[0]),v2			;Read g0r0b0a0
       }
       {
	add	v3[3],v1[3]			;Pre-Stepped z
	ld_sv	(v4[1]),v3			;Read g1r1b1a1
       }
       {
	st_v	v1,(v4[3])			;Store Pre-Stepped Values
       }
       {
	sub	v2[0],v3[0]			;p1-p0
       }
       {
	mul	v0[2],v3[0],>>v0[1],v3[0]	;(p1-p0)/hgh
	sub	v2[1],v3[1]			;p1-p0
       }
       {
	mul	v0[2],v3[1],>>v0[1],v3[1]	;(p1-p0)/hgh
	sub	v2[2],v3[2]			;p1-p0
       }
       {
	mul	v0[2],v3[2],>>v0[1],v3[2]	;(p1-p0)/hgh
	sub	v2[3],v3[3]			;p1-p0
       }
       {
	mul	v0[2],v3[3],>>v0[1],v3[3]	;(p1-p0)/hgh
       }
	add	#0x10,v4[3]			;Ptr Next
       {
	st_sv	v3,(v4[2])			;Store dgdrdbda
	mul	v0[3],v3[0],>>acshift,v3[0]	;Pre-Step*dlg
       }
	mul	v0[3],v3[1],>>acshift,v3[1]		;Pre-Step*dlr
       {
	mul	v0[3],v3[2],>>acshift,v3[2]		;Pre-Step*dlb
	add	v3[0],v2[0]			;Pre-Stepped g
       }
       {
	mul	v0[3],v3[3],>>acshift,v3[3]		;Pre-Step*dla
	add	v3[1],v2[1]			;Pre-Stepped r
       }
       {
	rts					;Done
	add	v3[2],v2[2]			;Pre-Stepped b
       }
	add	v3[3],v2[3]			;Pre-Stepped a
	st_sv	v2,(v4[3])			;Store Pre-Stepped Values
       ;----------------------------------------;rts


