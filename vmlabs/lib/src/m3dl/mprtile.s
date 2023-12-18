/*
 * Title	 	MPRTILE.S
 * Desciption		MPR Sprite Direct Main Code
 * Version		1.0
 * Start Date		09/16/1998
 * Last Update		12/02/1998
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

;*
;* Code Overlay
;*
	.overlay	mprtile
	.origin 	mprmainbase

;*
;* Import
;*
	.import	MPR_NextCommand
	.import	MPR_sbFlags, MPR_sbDMAF, MPR_sbSDRAM, MPR_PIXtemp
	.import	MPR_MDMA1, MPR_MDMA2, MPR_MDMAeor

;*
;* Export
;*
	.export	_mprtile_start, _mprtile_size
	.export	MPR_TILE

	;v5 1st Sprite Packet
	;v6 2nd Sprite Packet
	;v3[1] Xstart before 2dclip
	;v3[0] Xend   before 2dclip
	;v3[3] Ystart before 2dclip
	;v3[2] Yend   before 2dclip
	;v4[] Clip window


MPR_TILE:
	ld_v	(v7[0]),v0		;Fetch 1st Sprite packet
	st_s	#MPR_NextCommand,(rz)	;Set Return Address

       ;Check if Sprite is visible
       {
	ld_v	(v7[1]),v1		;Read 2nd Sprite packet
	and	#0xFFFF0000,v0[2],v3[1]	;X
	mul	#1,v0[0],>>#subtype,v0[0];Isolate Sprite SubType
       }
       {
	mul	#1,v3[1],>>#subres,v3[1];Xstart 16.16 value
	and	#0xFFFF0000,v0[3],v3[0]	;W
       }
       {
	ld_sv	(MPR_sbWINxw),v4	;Read Clip Window Coordinates
	mul	#1,v3[0],>>#subres,v3[0];Xend 16.16 value
	lsl	#16,v0[2],v3[3]		;Y
       }
       {
	mul	#1,v3[3],>>#subres,v3[3];Ystart 16.16 value
	lsl	#16,v0[3],v3[2]		;H
       }
       {
	mv_s	v0[0],v7[0]		;SubType in v7[0]
	mul	#1,v3[2],>>#subres,v3[2];Yend 16.16 value
	cmp	v4[1],v3[1]		;xright <= xstart ?
       }
       {
	rts	ge,nop 			;Yap, sprite invisible
	add	v3[1],v3[0]		;Xend = Xstart + Width
       }
       {
	addm	v3[3],v3[2]		;Yend = Ystart + Height
	cmp	v4[3],v3[3]		;ybottom <= ystart ?
       }
       {
	rts	ge,nop 			;Yap, sprite invisible
	cmp	v3[0],v4[0]		;xend <= xleft ?
       }
       {
	rts	ge,nop 			;Yap, sprite invisible
	cmp	v3[2],v4[2]		;yend <= ytop ?
       }
       {
	rts	ge,nop 			;Yap, sprite invisible
       }
       ;--------------------------------;bra ge,MPR_NextCommand,nop

       ;Clip against view window
       {
	cmp	v3[1],v4[0]		;xstart < xleft ?
       }
       {
	bra	gt,`SPRclipxs,nop	;Yap, clip xstart
	cmp	v3[3],v4[2]		;ystart < ytop
       }
`SPRclipxsdone:
       {
	mv_s	#0xFFFF,v2[0]		;v2[0] FFFF
	bra	gt,`SPRclipys,nop	;Yap, clip ystart
	cmp	v4[1],v3[0]		;xright < xend
       }
`SPRclipysdone:
       {
	bra	gt,`SPRclipxe,nop	;Yap, clip xend
	cmp	v4[3],v3[2]		;ybottom < yend
       }
`SPRclipxedone:
       {
	bra	le,`SPRclipdone 	;Nope, Clipping finished
	mv_s	v1[1],v7[3]		;Color
	lsl	#16,v2[0],v2[1]		;v2[1] FFFF0000
	addm	v2[0],v3[0]		;Round up
       }
       {
	and	v2[1],v3[0]		;Round down
	addm	v2[0],v3[1]		;Round up
       }
       {
	and	v2[1],v3[1]		;Round down
	addm	v2[0],v3[3]		;Round up
       }

`SPRclipye:
       {
	bra	`SPRclipdone,nop	;Clipping finished
	mv_s	v4[3],v3[2]		;yend = ybottom
       }
`SPRclipxs:
       {
	bra	`SPRclipxsdone,nop	;
	mv_s	v4[0],v3[1]		;xstart = xleft
       }
`SPRclipys:
       {
	bra	`SPRclipysdone,nop	;
	mv_s	v4[2],v3[3]		;ystart = xtop
       }
`SPRclipxe:
       {
	bra	`SPRclipxedone,nop	;
	mv_s	v4[1],v3[0]		;xend = xright
       }

`SPRclipdone:

       ;Discretize Coordinates
       ;Note: The Ceil used works only on POSITIVE numbers, since the
       ;clip boundary is never a negative value, we get away with it!
       {
	and	v2[1],v3[3]		;Round down
	addm	v2[0],v3[2]		;Round up
       }
       {
	and	v2[1],v3[2]		;Round down
	subm	v3[1],v3[0]		;Width
       }
       {
	subm	v3[3],v3[2]		;Height

       ;Inverse Depth Z & Flip Z if necessary
	ld_s	(MPR_sbFlags),v7[1]	;Read sbFlags
	btst	#ZBIT,v7[0]		;Z Used ?
       }
       {
	bra	eq,`SPRNoZ		;Nope, Don't use Depth Z
	copy	v0[1],r0		;Z for Recip Argument 0
        ld_s	(MPR_sbDMAF),v7[2]	;Read DMA Flags
       }
	jsr	ne,MPR_Recip		;Find Inverse Z if Depth Z != 0
	or	#NW_Z,v7[2]		;Pixel Only Mode
	;-------------------------------;
	mv_s	#precdepthz,r1 		;Recip Argument #of fraction bits z
	;-------------------------------;
	btst	#sbZFb,v7[1]		;ZFlip Necessary ?
       {
	bra	eq,`SPRnozflip		;Nope, don't touch Inv Depth Z
	and	#-15,v7[2] 		;Inhibit Write: Never (Write Z)
       }
	sub	#preciz,r1		;Inverse as iz.preciz
	ls	r1,r0			;Inverse Depth Z
	;-------------------------------;
	eor	#-1,r0 			;Flip Z
`SPRnozflip:
	ftst	#(0x1FF^ZDEF),v7[0]	;Z Only Sprite ?
	bra	ne,`SPRNoZ,nop		;Nope, do not modify DMA Flags
	;-------------------------------;

	;Modify Transfer Flags into Zonly
       {
	mv_s	v7[2],r2  		;DMA Flags
	and	#0xFFFFFF0F,v7[2]	;Clear Transfer mode
       }
	bits	#4-1,>>#4,r2		;Extract Transfer mode
	cmp	#TR_16B_WITHZ>>4,r2	;16B+Z ?
       {
	bra	eq,`TILEDMAFlok,nop	;Yap, Done
	mv_s	#TR_16B_ZONLY>>4,r3	;16B Z
	cmp	#TR_32B_WITHZ>>4,r2	;32B+Z ?
       }
	;-------------------------------;
       {
	bra	eq,`TILEDMAFlok,nop	;Yap, Done
	mv_s	#TR_32B_ZONLY>>4,r3	;32B Z
	cmp	#TR_16B3C_WITHZ>>4,r2	;16B3C+Z ?
       }
	;-------------------------------;
       {
	bra	eq,`TILEDMAFlok,nop	;Yap, Done
	mv_s	#TR_16B3_ZONLY>>4,r3	;16B3 Z
	cmp	#TR_16B3B_WITHZ>>4,r2	;16B3B+Z ?
       }
	;-------------------------------;
       {
	bra	eq,`TILEDMAFlok,nop	;Yap, Done
	cmp	#TR_16B3A_WITHZ>>4,r2	;16B3A+Z ?
       }
	;-------------------------------;
       {
	bra	eq,`TILEDMAFlok,nop	;Yap, Done
	cmp	#TR_16B2B_WITHZ>>4,r2	;16B2B+Z ?
       }
	;-------------------------------;
       {
	bra	eq,`TILEDMAFlok,nop	;Yap, Done
	mv_s	#TR_16B2_ZONLY>>4,r3	;16B2 Z
	cmp	#TR_16B2A_WITHZ>>4,r2	;16B2A+Z ?
       }
	;-------------------------------;
	bra	eq,`TILEDMAFlok,nop	;Yap, Done
	;-------------------------------;
	mv_s	r2,r3			;Leave flags unchanged
`TILEDMAFlok:
	bra	TILEDirectZ		;Render now
	or	r3,>>#-4,v7[2]		;Insert ZOnly Mode
`SPRNoZ:

TILEDirect:
	;Color Mode Sprite, transform GRB color
       {
	mv_s	r0,v0[3]		;Inv Depth Z
	lsr	#2,v7[3],v0[0]		;Green as 2.30 Value
       }
       {
	lsl	#6,v7[3],v0[1]		;Red as 2.30 Value
       }
       {
	lsl	#14,v7[3],v0[2]		;Blue as 2.30 Value
	mv_s	v7[1],v7[3]		;sbFlags
       }
       {
	mv_s	#0x3FC00000,v2[0]	;Bit Mask
	btst	#sbGRBb,v7[1]		;GRB Mode Set ?
       }
       {
	bra	ne,`TILEDirectNoYcc	;Yap, Do not convert to YCC
	and	v2[0],v0[1]		;Extract Red
       }
       {
	and	v2[0],v0[2]		;Extract Blue
       }
       {
	and	v2[0],v0[0]		;Extract Green
       }
	;-------------------------------;
       {
	copy	v0[0],v6[0]		;Set G
	mv_s	#1<<30,v6[3]		;One as 2.30 Value
       }
       {
	copy	v0[1],v6[1]		;Set R
	ld_sv	(MPR_GRB32Ycc),v1	;GRB -> Y
       }
       {
	copy	v0[2],v6[2]		;Set B
	ld_sv	(MPR_GRB32Ycc+8),v2	;GRB -> Cr
       }
       {
	dotp	v1,v6,>>#30,v0[0]	;Y Component
	ld_sv	(MPR_GRB32Ycc+16),v1	;GRB -> Cb
       }
	dotp	v2,v6,>>#30,v0[1]	;Cr Component
	dotp	v1,v6,>>#30,v0[2]	;Cb Component

`TILEDirectNoYcc:
       {
	st_s	#MPR_PIXtemp,(xybase)	;xybase = ptr Temporary Pixel
	copy	v7[2],v1[0]		;sbDMAFlags
       }
       {
	ld_s	(xyctl),v1[1]		;Fetch pixeltype
	mvr	#0,rx 			;Clear rx
	bits	#4-1,>>#4,v1[0]		;DMA Transfer Type
       }
       {
	st_pz	v0,(xy)			;Store Temporary Pixel
	cmp	#CV_32B_16B>>4,v1[0]	;16bit mode ?
       }
       {
	bra	ne,`SPRpixok
	ld_s	(MPR_PIXtemp),v0[3]		;Direct Write Data
	and	#1<<28,v1[1],v1[2]	;Isolate CHNorm into v1[2]
       }
	or	#(PIX_16B_WITHZ<<20),v1[2]	;16B + Z
	btst	#ZBIT,v7[0]		;Z Used ?
	;-------------------------------;
	st_s	v1[2],(xyctl)		;16B + Z
	st_pz	v0,(xy)			;Store XY pixel
	ld_s	(MPR_PIXtemp),v0[3]		;Read 16bit color
	eor	#CV_32B_16B^TR_16B_NOZ,v7[2]
	lsr	#16,v0[3]		;Shift down
	or	v0[3],>>#-16,v0[3]	;Duplicate Pixel
	btst	#ZBIT,v7[0]		;Z Used ?
	st_s	v1[1],(xyctl)		;Restore pixeltype
`SPRpixok:
       {
	bra	eq,TILEDirend		;Nope, No Double Pass needed
	bits	#4-1,>>#0,v7[3]		;Pixtype
       }
	cmp	#(PIX_32B_WITHZ),v7[3]	;Pixtype > 4 bytes ?
	bra	ne,TILEDirend,nop	;Nope, Single Render needed
	;-------------------------------;
       {
	jsr	TILEDirectRender,nop	;Render Pixel Only
	or	#NW_Z,v7[2]		;DMAFlags - Pixel Only mode
       }
	;-------------------------------;
       {
	ld_s	(MPR_PIXtemp+4),v0[3]	;Read Z
	and	#0xFFFFFF01,v7[2]	;Clear ZComparison & DMA Flags
       }
	or	#TR_32B_ZONLY,v7[2]	;Insert ZOnly Flags

TILEDirectZ:
TILEDirend:
	st_s	#MPR_NextCommand,(rz)	;Store Return Address


TILEDirectRender:
;Data is written line by line, to allow for interlaced mode and
;to leave some room for other MPEs to grab the Main DMA bus if necessary.

	;v0[3]	direct write data
	;v3[0]	xlen
	;v3[1]  xstart
	;v3[2]	ylen
	;v3[3]  ystart
	;v7[1]	sbFlags
	;v7[2]  DMAFlags

	;Set yLen to loop counter
       {
	lsr	#16,v3[2],v1[0]		;Loop Length
       }
       {
	rts	eq,nop			;No lines to display
	mv_v	v3,v2			;Sprite Dimensions
       }

`SPRWmdma:
	;Wait for ALL MDMA to finish, previous textures, polys etc
       {
	ld_s	(mdmactl),r0		;Read MDMA Control Flags
	bset	#27,v7[2]		;Set Direct Mode flag
       }
       {
 	ld_s	(MPR_sbSDRAM),r2	;Read SDRAM addr
	copy	v2[3],r1		;Ystart
       }
	bits	#4,>>#0,r0		;All MDMA Finished ?
       {
	mv_s	#1<<16,v2[2]		;DMA Write Y Length
	bra	ne,`SPRWmdma,nop	;Nope, Wait
	btst	#sbILCb,v7[1]		;InterLaced ?
       }
       {
	bra	eq,`LineLoop		;Nope, Do not setup ILC
	mv_s	v7[1],r0		;r0 sbFlags
	bits	#1-1,>>#16,r1		;r1 lowest bit Ystart
       }
       {
	mv_s	#1,v1[1]		;Yadder (non-interlaced)
	bits	#1-1,>>#sbODDb,r0	;Isolate Even/Odd bit
       }
       {
	eor	r1,r0			;Wrong Starting Line
	mv_s	#MPR_MDMA1,r1		;MDMA address
       }

       ;Interlace Detected
       {
	bra	eq,`LineLoop,nop	;Nope, Interlace set up
	mv_s	#2,v1[1]		;Skip 1 line
       }
	sub	#1,v1[0]		;Decrease loop counter
       {
	rts	eq			;No more lines to process
	add	#1,>>#-16,v2[3]		;Increase Ystart
       }

`LineLoop:
       {
	mv_s	v3[1],v2[1]		;Reset XStart
	copy	v3[0],v1[3]		;#of Pixels to Write (XLen)
       }

`SPROneLine:
	;MDMA Pending Clear ?
	ld_s	(mdmactl),r0		;Read MDMA Control Flags
	nop
       {
	mv_s	#mbusmax<<16,v1[2] 	;busmax (as 16.16)
	btst	#4,r0			;MDMA pending ?
       }
	bra	ne,`SPROneLine		;Yap, Wait
       {
	mv_s	#4,r0			;Set r0 4
	cmp	v1[2],v1[3]		;busmax Ok ?
       }
	bra	ge,`nosmaller		;Yap, skip change
       ;--------------------------------;bra ne,`SPROneLine,nop
       {
	st_s	v7[2],(r1) 		;Store DMA Flags
	add	r0,r1			;Increase Ptr
       }
       {
	st_s	r2,(r1)			;Store SDRAM addr
	addm	r0,r1			;Increase Ptr
	copy	v1[2],v2[0]		;Max #of Pixels in 1 DMA Command
       }
       ;--------------------------------;bra ge,`nosmaller
	mv_s	v1[3],v2[0]		;Set #of Pixels left
`nosmaller:
       {
	st_sv	v2,(r1)			;Set XY window
	add	#2*4,r1			;Increase Ptr
       }
       {
	st_s	r3,(r1)			;Set Direct Data
	sub	#4*4,r1			;MDMA Command
       }
       {
	st_s	r1,(mdmacptr)		;Launch DMA
	sub	v2[0],v1[3]		;#of Pixels to Write
       }
	bra	gt,`SPROneLine		;Continue
	add	v2[0],v2[1]		;Increase XStart
	eor	#MPR_MDMAeor,r1		;Other MDMA Ptr
       ;--------------------------------;bra gt,`SPROneLine

	sub	v1[1],v1[0]		;Decrease Loop Counter
	bra	gt,`LineLoop		;Next Line
	rts	nop			;Finished
	add	v1[1],>>#-16,v2[3]	;Increase Ystart
       ;--------------------------------;MDMA Done

