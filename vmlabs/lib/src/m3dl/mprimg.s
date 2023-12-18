/*
 * Title	 	MPRIMG.S
 * Desciption		MPR Draw image code
 * Version		1.0
 * Start Data		02/25/2000
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
	.overlay	mprimg
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
	.import	MPR_BmInfoCTag
	.import	MPR_ClutC,MPR_ClutCTag
	.import	MPR_DoDMAScramblev1

	.import	MPR_sbFlags, MPR_sbDMAF, MPR_sbSDRAM, MPR_PIXtemp
	.import	MPR_MDMA1, MPR_MDMA2, MPR_MDMAeor
	.import	DMAFL1, SDRAM1, XPLEN1, XPLEN1, YPLEN1, MPEAD1
	.import	MPR_PixBuf1, MPR_PixBuf2, MPR_PixBufeor
	.import	MPR_Dump

	.import	MPR_DLGRBA, MPR_LGRBA, MPR_DGRBA
	.import	MPR_DLUVZ, MPR_DLUVZ, MPR_DUVZ
	.import	MPR_PMXWXTPBF, MPR_WXCLXHYCTY
;*
;* Export
;*
	.export	_mprimg_start, _mprimg_size
	.export	MPR_IMG


MPR_IMG:
       ;Check if Sprite is visible
	ld_v	(v7[0]),v0		;Read 1st Sprite Packet
	ld_sv	(MPR_sbWINxw),v4	;Read Clip Window Coordinates
       {
	ld_v	(v7[1]),v1		;Read 2nd Sprite Packet
	and	#0xFFFF0000,v0[2],v3[1]	;X
	mul	#1,v0[0],>>#subtype,v0[0];Isolate Sprite SubType
       }
       {
	ld_s	(v7[0]),v7[1]		;Read Image MPRinfo
	mul	#1,v3[1],>>#subres,v3[1];Xstart 16.16 value
	and	#0xFFFF0000,v0[3],v3[0]	;W
       }
       {
	st_s	#MPR_NextCommand,(rz)	;Set Return Address
	mul	#1,v3[0],>>#subres,v3[0];Xend 16.16 value
	lsl	#16,v0[2],v3[3]		;Y
       }
       {
	mul	#1,v3[3],>>#subres,v3[3];Ystart 16.16 value
	lsl	#16,v0[3],v3[2]		;H
       }
	add	v4[0],v3[1]		;Add Render X Offset to Xstart
       {
	mv_s	v0[0],v7[0]		;SubType in v7[0]
	mul	#1,v3[2],>>#subres,v3[2];Yend 16.16 value
	cmp	v4[1],v3[1]		;xright <= xstart ?
       }
       {
	rts	ge,nop			;Yap, sprite invisible
	add	v4[2],v3[3]		;Add Render Y Offset to Ystart
       }
       {
	addm	v3[1],v3[0]		;Xend = Xstart + Width
	cmp	v4[3],v3[3]		;ybottom <= ystart ?
       }
       {
	rts	ge,nop			;Yap, sprite invisible
	addm	v3[3],v3[2]		;Yend = Ystart + Height
	cmp	v3[0],v4[0]		;xend <= xleft ?
       }
       {
	rts	ge,nop			;Yap, sprite invisible
	cmp	v3[2],v4[2]		;yend <= ytop ?
	mv_v	v0,v5			;Backup v0
       }
       {
	rts	ge,nop			;Yap, sprite invisible
	mv_v	v1,v6			;Backup v6
       }

	and	#0xFFFF,v5[3],v1[1]	;Height of Sprite
       {
	jsr	MPR_FetchTexInfo	;Fetch TexInfo if not Direct
	lsr	#16,v5[3],v0[3]		;Width of Sprite
       }
       {
	mul	v0[3],v1[1],>>#0,v1[1]	;Width * Height as 24.8
	bits	#16-1,>>#0,v7[1]     	;Extract Image MPR info
       }
	mv_s	v6[0],r0		;TexInfo Address
       ;--------------------------------;jsr MPR_FetchTexInfo

	;Calculate MipMap
	;v1[1] Sprite Area
       {
;	mv_s	#4,r1			;FracBits ORIGINAL
	mv_s	#3,r1			;FracBits
	copy	v1[1],r0		;Sprite Area
       }
       {
	jsr	ne,MPR_Recip		;Calculate 1/Sprite Area
	ld_s	(MPR_TexInfoC),v2[0] 	;pixtype, miplevels, w & h
       }
       {
	jmp	MPR_NextCommand		;Area is 0, Quit
	ld_s	(MPR_TexInfoC+4),v6[0] 	;BmInfo
	asr	#16,v6[3],v5[2]		;Uoffset (signed)
       }
       {
	lsl	#16,v6[3]		;Voffset up
       }
       ;--------------------------------;jsr ne,MPR_Recip
       {
	mul	#1,v6[3],>>#16,v6[3]	;Voffset (signed)
	mv_s	v2[0],v2[1]		;
	bits	#8-1,>>#8,v2[0]		;Width
       }
       {
	mv_s	v2[1],v2[2]		;
	bits	#8-1,>>#0,v2[1]		;Height
	mul	v2[0],v5[2],>>#-8,v5[2]	;v5[2] Uoffset * Width (signed) 14.16
       }
       {
	mv_s	v2[2],v2[3]		;
	bits	#8-1,>>#24,v2[2] 	;Pixtype
	mul	v2[1],v6[3],>>#-8,v6[3]	;v6[3] Voffset * Height (signed) 14.16
       }
       {
	mv_s	v5[2],v1[0]		;Uoffset*Width
       }
       {
	mul	v6[3],v1[0],>>#28,v1[0]	;UVarea 28.4
       }
	or	v2[2],>>#-16,v7[0]	;Insert Pixtype in Sprite Subtype
       {
	abs	v1[0]			;abs(UVarea)
       }
       {
	mul	r0,v1[0],>>r1,v1[0]	;UV Area / SP Area
	and	#0x3FF,v6[2],v5[3]      ;isolate V fraction bits
       }
       {
	mul	#1,v6[2],>>#16,v6[2]	;U as 6.10
	bits	#8-1,>>#16,v2[3] 	;MipLevels
       }
       {
	add	#1,v1[0]		;Refine result
       }
       {
	msb	v1[0],v1[1]		;Get msb
       }
       {
	mul	v2[0],v6[2],>>#-8,v6[2]	;v6[2] U*Width 6.16
	lsr	#1,v1[1]		;Mip level
       }
       {
	mul	v2[1],v5[3],>>#-8,v5[3]	;v5[3] V*Height 6.16
	cmp	v1[1],v2[3]		;Level Requested < Max Level ?
       }
       {
	bra	gt,`SPRMipok		;Yap, Dont correct
	mv_s	v6[0],r0		;BmInfo 1st level
       }
	lsl	#2,v2[0]		;real width
	lsl	#2,v2[1]		;real height
       ;--------------------------------;bra `SPRMipok
	sub	#1,v2[3],v1[1]		;Highest MipLevel
`SPRMipok:
       {
	as	v1[1],v2[0]		;mipmap width
	mul	#1,v2[1],>>v1[1],v2[1]	;mipmap height
       }
       {
	mul	#1,v6[2],>>v1[1],v6[2]	;v6[2] MipMap U*Width 6.16
	as	v1[1],v5[2]		;MipMap Uoffset
	jsr	MPR_FetchBmInfo		;Fetch BmInfo
       }
       {
	mul	#1,v5[3],>>v1[1],v5[3]	;v5[3] MipMap V*Height 6.16
	as	v1[1],v6[3]		;MipMap Voffset
       }
       {
	add	v1[1],>>#-3,r0		;BmInfo = BmInfo + (Level*8)
       }
       ;--------------------------------;jsr MPR_FetchBmInfo

	;
	;v2[0] uv width (mipmapped)
	;v2[1] uv height (mipmapped)
	;v2[3] miplevels
	;
	;v3[1] Xstart before 2dclip
	;v3[0] Xend   before 2dclip
	;v3[3] Ystart before 2dclip
	;v3[2] Yend   before 2dclip
	;
	;v4[] Clip window
	;
	;v5[0] sprite subtype
	;v5[1] sprite z
	;v5[2] Uoffset 14.8
	;v5[3] V 16.16
	;
	;v6[0] bmnfo (1st miplevel)
	;v6[1] sprite rgba
	;v6[2] U 16.16
	;v6[3] Voffset 14.8
	;
	;v7[0] pixtype : subtype

	;Fetch Clut (if there is any)
	ld_s	(MPR_TexInfoC),r2	;Read Texture Information
	ld_s	(MPR_BmInfoC+4),v1[0]	;Read Clut Info
       {
	ld_s	(MPR_ClutCTag),v1[3]	;Clut Cache Tag
	bits	#4-1,>>#24,r2		;Extract Pixel type (and Ycc bit)
       }
       {
	st_v	v0,(MPR_Dump+1*16)	;Backup v0
	and	#0xC1FFFFF8,v1[0],r1	;Clut Source address
       }
       {
	bra	eq,FBCnoclut,nop	;Null Ptr, No Clut!
	mv_s	v1[0],v1[1]		;Clut Info
	cmp	v1[0],v1[3]		;Clut already in Cache ?
       }
       {
	bra	eq,FBCclutcached	;Yap, don't re-read
	st_s	v1[0],(MPR_ClutCTag)	;Set new Clut CTag
	and	#0x7,v1[0],r0  		;Extract low 3bits #colors
       }
       {
	mv_s	#MPR_ClutC,r2		;Destination
	bits	#4-1,>>#25,v1[1]	;Extract high 4 bits #colors
       }
       {
	jsr	MPR_DoDMAScramblev1	;Read
	mv_s	#0x10,r3		;DMA Wait (pending only)
	lsl	#1,r2,v1[2]		;(MPR_ClutC<<1)
       }
       {
	or	v1[1],>>#-3,r0		;Insert high 4 bits #colors
	st_s	v1[2],(clutbase)	;Set clutbase
       }
       {
	lsl	#3,r0			;1 Word/Clut Color
       }

FBCclutcached:
FBCnoclut:
	;Setup Bitmap uvctl
       {
	mv_s	v2[0],r3		;width
	msb	v2[0],r0		;msb(width)
       }
       {
	ld_s	(MPR_Dump+1*16+2*4),r2	;Restore r2
	neg	r3			;-width
       }
       {
	st_s	#PIX_16B<<20,(linpixctl);Delay slot 2nd jsr
	and	v2[0],r3		;lowest binary bit set in width
       }
       {
	cmp	v2[0],r3		;is width a pow 2 ?
	mv_s	v5[0],r1		;subtype
       }
       {
	bra	eq,`wpow2		;bra eq,`wpow2
	mv_s	#2048/2,v1[0]		;#of bytes
	bits	#1-1,>>#1,r1		;extract bilinear bit
       }
       {
	st_s	v2[1],(uvrange)		;Height of texture in pixels (vrange)
	mul	r1,v1[0],>>#0,v1[0]	;#of bytes/2 if bilinear else zero
       }
       {
	st_s	#MPR_BitmapC,(uvbase)	;Set uvbase
       }
       ;--------------------------------;bra eq,`wpow2
	add	#1,r0			;increase width
`wpow2:
       {
	mv_s	r2,v1[1]		;textype
	bits	#3-1,>>#0,r2		;extract pixtype
       }
	cmp	#PIX_8B,r2		;8bits/pixel mode ?
       {
	bra	eq,`shiftset,nop	;yap, done
	mv_s	#0,r3			;pixel to byte conversion sft
	mul	#1,r2,>>#-20,r2		;Prepare for uvctl
	cmp	#PIX_4B,r2		;4bits/pixel mode ?
       }
       ;--------------------------------;bra eq,`shiftset,nop
       {
	bra	eq,`shiftset,nop	;yap, done
	mv_s	#1,r3			;pixel to byte conversion sft
	;normally we should lsl #1,v1[0] here but uvwidth is maximum 11bits
	;(2023) so we leave it at 1024, up to the cache fetch to deal with it
       }
       ;--------------------------------;bra eq,`shiftset,nop
       {
	mv_s	#-1,r3			;pixel to byte conversion sft (16bit)
	lsr	#1,v1[0]		;max 2048/4 in bilinear mode
       }
`shiftset:
       {
	mv_s	#17,v7[3]
       }
       {
	ld_s	(MPR_BmInfoC),v1[2]	;Read Bitmap Info
	addm	r2,v1[0]		;insert pixtype in uvctl
	ls	r3,v2[0],r3		;#of bytes/scanline
       }
       {
	st_s	r3,(MPR_BmInfoCTag)	;Insert #of bytes/scanline
	btst	#BMYCCBIT,v1[1]		;YCC bitmap ?
       }
       {
	bra	eq,`nochnorm
	and	#0xDFFFFFFF,v1[2]	;Remove linear bit
	subm	r0,v7[3],r0		;utile
       }
       {
	mv_s	#0xFFFF,v7[2]		;v7[2] FFFF
	or	r0,>>#-16,v1[0]		;insert utile in uvctl
       }
       {
	st_s	v1[2],(MPR_BitmapCTag)	;Set Bitmap address
	or	#15<<12,v1[0]           ;insert vtile in uvctl
       }
       ;--------------------------------;bra eq,`nochnorm
       {
	st_s	#(1<<28)|(PIX_16B<<20),(linpixctl)	;Set Clut 16B + CHNORM
	bset	#28,v1[0]		;Set chnorm
       }
`nochnorm:
       {
	st_s	v1[0],(uvctl)		;store uvctl
	lsl	#16,v7[2],v7[3]		;v7[3] FFFF0000
       }

	;Udelta = Uoffset/Width(sprite)
       {
	jsr	MPR_Recip
	sub	v3[1],v3[0],r0		;Recip Argument = Width(Sprite)
	addm	v7[2],v3[0]		;Round up xend
       }
	and	v7[3],v3[0]		;Floor xend
	mv_s	#16,r1			;16 Fractional bits
       ;--------------------------------;jsr MPR_Recip
       {
	jsr	MPR_Recip
	sub	v3[3],v3[2],r2		;Recip Argument = Height(Sprite)
       }
       {
	mul	r0,v5[2],>>r1,v5[2]	;Uoffset/Width
	mv_s	#16,r1			;16 Fractional bits
       }
       {
	mv_s	r2,r0                   ;Recip Argument = Height(Sprite)
       }
       ;--------------------------------;jsr MPR_Recip
       {
	cmp	#0,v5[2]		;Uoffset positive ?
       }
       {
	bra	lt,`norefine		;Nope, dont 'refine'
       }
       {
	mul	r0,v6[3],>>r1,v6[3]	;Voffset/Height
	cmp	#0,v6[3]		;Voffset negative ?
       }
       {
	mv_s	#1,r1			;r1 1
       }
       ;--------------------------------;bra `norefine
	addm	r1,v5[2]		;Refine Uoffset
`norefine:
       {
	bra	lt,`norefine2,nop	;Nope, dont 'refine'
       }
       ;--------------------------------;bra lt,`norefine2,nop
	addm	r1,v6[3]		;Refine Voffset
`norefine2:
       ;Split Image depending on #of MPRs active
       {
	jsr	MPR_Recip,nop		;Recip
	and	#0xFF,v7[1],r0		;NumMPEs
	mv_s	#0,r1			;No Fraction used
       }
       ;--------------------------------;jsr MPR_Recip,nop
       {
	st_s	#MPR_NextCommand,(rz)	;Set Return Address
	sub	v3[3],v3[2],r2		;Image height
       }
       {
	mul	r2,r0,>>r1,r0		;Height/NumMPEs
	and	#0xFF,v7[1],r3		;NumMPEs
       }
	sub	#1,r3			;(for equal compare)
	lsr	#8,v7[1],r1		;Offset
       {
	cmp	r1,r3 			;Last MPR ?
	mul	r0,r1,>>#0,r1		;Offset*Height/NumMPEs (in pixels)
       }
       {
	bra	eq,`lastmpr		;Yes, leave yend unchanged
	add	v7[2],v3[1],r2		;Round up new xstart
       }
       {
	add	r1,v3[3]		;Increment ystart
	mul	v6[3],r1,>>#16,r1	;Offset*Voffset
       }
	and	v7[3],r2		;Floor new xstart
       ;--------------------------------;bra eq,`lastmpr
	add	r0,v3[3],v3[2]		;yend = ystart + (Height/numMPEs)
`lastmpr:
       {
	cmp	v4[3],v3[3]		;ybottom <= ystart ?
	addm	v7[2],v3[3],r3		;Round up new ystart
       }
       {
	rts	ge,nop			;Yap, sprite invisible
	cmp	v3[2],v4[2]		;yend <= ytop ?
	addm	v7[2],v3[2]		;Round up yend
       }
       ;--------------------------------;rts ge,nop
       {
	rts	ge,nop			;Yap, sprite invisible
	and	v7[3],r3		;new Floor ystart
	addm	r1,v5[3]		;V += Offset*Voffset
       }
       ;--------------------------------;rts ge,nop

       {
	and	v7[3],v3[2]		;Floor yend
       }

       ;r2 new xstart  r3 new ystart
       ;Clip against view window
       ;Note: the ceil used works only on positive numbers, however, since
       ;clipping boundaries are always positive we don't care about it.
	cmp	v4[1],v3[0]		;xright < xend
       {
	bra	gt,`SPRclipxe,nop	;Yap, clip xend
	cmp	v4[3],v3[2]		;ybottom < yend
       }
`SPRclipxedone:
       {
	bra	gt,`SPRclipye,nop 	;Yap, clip yend
	cmp	r2,v4[0]		;xstart < xleft ?
       }
`SPRclipyedone:
       {
	bra	gt,`SPRclipxs,nop	;Yap, clip xstart
	cmp	r3,v4[2]		;ystart < ytop
       }
`SPRclipxsdone:
       {
	bra	le,`SPRclipdone		;Nope, clip done
	mv_s	r2,v3[1]		;set new xstart
	sub	v3[1],r2		;xprestep value
       }
       {
	sub	v3[1],v3[0]		;v3[0] xwidth 16.16
	mul	v5[2],r2,>>#16,r2	;Uprestep
       }
	nop

`SPRclipys:
       {
	bra	`SPRclipdone,nop	;Clipping finished
	mv_s	v4[2],r3		;ystart = ytop
       }
`SPRclipxe:
       {
	bra	`SPRclipxedone,nop	;
	mv_s	v4[1],v3[0]		;xend = xright
       }
`SPRclipye:
       {
	bra	`SPRclipyedone,nop	;
	mv_s	v4[3],v3[2]		;yend = ybottom
       }
`SPRclipxs:
       {
	bra	`SPRclipxsdone,nop	;
	mv_s	v4[0],r2		;xstart = xleft
       }

`SPRclipdone:
	;Preset UV
       {
	mv_s	r3,v3[3]		;set new ystart
	sub	v3[3],r3		;yprestep value
       }
       {
	sub	v3[3],v3[2]		;v3[2] ywidth 16.16
	mul	v6[3],r3,>>#16,r3	;Vprestep
       }
	add	r2,v6[2]		;Prestep U
       {
	addm	r3,v5[3]		;Prestep V

       ;Inverse Depth Z & Flip Z if necessary
	ld_s	(MPR_sbFlags),v7[1]	;Read sbFlags
	btst	#ZBIT,v7[0]		;Z Used ?
       }
       {
	bra	eq,`SPRNoZ		;Nope, Don't use Depth Z
        ld_s	(MPR_sbDMAF),v7[2]	;Read DMA Flags
	copy	v5[1],r0		;Z for Recip Argument 0
       }
	jsr	ne,MPR_Recip		;Find Inverse Z if Depth Z != 0
	or	#NW_Z,v7[2]		;Pixel Only Mode
       ;--------------------------------;bra `SPRNoZ
	mv_s	#precdepthz,r1 		;Recip Argument #of fraction bits z
       ;--------------------------------;jsr MPR_Recip
       {
        ld_s	(MPR_sbDMAF),v7[2]	;Read DMA Flags
	btst	#sbZFb,v7[1]		;ZFlip Necessary ?
       }
	bra	eq,`SPRnozflip		;Nope, don't touch Inv Depth Z
	sub	#preciz,r1		;Inverse as iz.preciz
	ls	r1,r0,_Z		;Inverse Depth Z
       ;--------------------------------;bra `SPRnozflip
	eor	#-1,_Z 			;Flip Z
`SPRNoZ:
`SPRnozflip:
	;Setup GRB and Alpha
       {
	mul	#1,v5[0],>>#-EXTRASHF,v5[0]	;sprite subtype
	mv_s	v7[0],r3		;
       }
       {
	ld_s	(linpixctl),r0		;Backup linpixctl
	bits	#1-1,>>#16,r3		;Isolate Lower bit of pixtype
       }
       {
	st_s	#PIX_32B<<20,(linpixctl);32Bit
	lsr	#(BMBTRBIT+16),v7[0],r1	;Extract Black Transparent bit
	addm	r3,r3			;Shift up 1 bit
       }
       {
	st_s	v6[1],(MPR_PIXtemp)	;Store GRBA
	addm	v5[0],r3		;Insert sprite subtype
       }
       {
	mv_v	_GRBA,v2		;Backup v6
	copy	v7[1],r2		;sbFlags
       }
       {
	ld_pz	(MPR_PIXtemp),_GRBA	;Read GRBA
	bset	#0,r3			;Set YCC Texture
       }
       {
	st_s	r0,(linpixctl)		;Restore linpixctl
       }
       {
	mv_v	v3,v4			;Set Xwidth Xstart Yheight Ystart
	subm	_DV,_DV			;Clear Delta V
	add_p	_GRBA,_GRBA		;Set GRB as 2.30 values
       }
       {
	mv_s	v5[2],_DU 		;Set Delta U
	bclr	#BTRABIT+EXTRASHF,r3	;Clear Black Transparent
	subm	_DLZ,_DLZ  		;Clear Delta Left Z
       }
       {
	mv_s	v2[3],_DLV		;Set Left Delta V
	subm	_DLU,_DLU		;Clear Left Delta U
	or	r1,>>#-(BTRABIT+EXTRASHF),r3	;Insert Black Transparent
       }
       {
	copy	v5[3],_V		;Set V
	mv_s	v2[2],_U		;Set U
	subm	_DZ,_DZ			;Clear Delta Z
       }
	lsr	#2,_GRBA[3]		;Fix Alpha as 2.30 value

       ;r3 - Inner Loop Mode
       ;Bit#	ON		OFF
       ;0	YCC Texture	GRB Texture
       ;1	CLUT		DIRECT
       ;2	GRB Screen	YCC Screen
       ;3	Persp Correct	Affine
       ;4	Bilinear	Point Sampled
       ;5	Texture On	Texture Off
       ;6	Black Trans	Black Opaque
       ;7	Color On	Color Off
       ;8	Translucent	Opaque (=no Alpha)

       ;Find #pixels in pixbuf & Fetch Inner Loop Code
       {
	jsr	MPR_FetchInnerCode	;Fetch Inner Loop Code
	mv_s	#pixbuflen<<16,_PMAX
	bits	#4-1,>>#4,r2		;From sbFlags
       }
       {
	mv_s	#MPR_INTable,r0		;ptr Inner Loop Table
	ls	r2,_PMAX		;#of pixels/pixbuf 16.16
       }
	add	r3,>>#-3,r0		;ptr Inner Loop Code

       ;Setup for Render
       {
	st_s	#0,(acshift)		;Set multiply shift register
	jsr	MPR_Waitallbuses	;Wait for ALL DMA to go idle
       }
	mv_s	#1,v1[2]		;Round down if negative
	ld_s	(MPR_sbSDRAM),v1[3]	;Read Screen SDRAM address

       ;Setup Main Bus Write Command
       {
	st_s	v7[2],(MPR_MDMA1)	;Set DMA Flags
	copy	_DU,v1[0]		;Delta U
       }
       {
	st_s	v1[3],(SDRAM1)		;Set SDRAM address
	or	#NW_Z,v7[2]		;Pixel Only Mode for Read
       }
       ;Setup Main Bus Read Command
       {
	st_s	v1[3],(SDRAM2)		;Set SDRAM address
	bset	#13,v7[2]		;Read Flag
       }
       {
	st_s	v7[2],(MPR_MDMA2)	;Set DMA Flags
	copy	_DLV,v1[1]		;Delta V
       }

       ;Enter Outer Loop
       {
	st_sv	_LGRBA,(MPR_LGRBA)	;Store Left GRBA
	sub_sv	v0,v0			;Clear v0
       }
       {
	st_sv	v0,(MPR_DLGRBA)		;Store Delta Left GRBA
	abs	v1[0]			;Set carry if Delta U negative
       }
       {
	subwc	#0,_LU			;Round down for negative delta
	st_sv	v0,(MPR_DGRBA)		;Store Delta GRBA
       }
       {
	st_v	_DLUVZ,(MPR_DLUVZ)	;Store Delta Left UVZ
	abs	v1[1]			;Set carry if Delta V negative
       }
       {
	subwc	#0,_LV			;Round down for negative delta
	st_v	_DUVZ,(MPR_DUVZ)	;Store Delta UVZ
       }
       {
	st_v	_LUVZ,(MPR_LUVZ)	;Store Left UVZ
	lsr	#16,v4[2],r0		;Discrete Height
       }

       ;Outer Loop
       {
	st_s	r0,(rc1)		;Outer loop counter
	sub	r0,r0			;Clear r0
       }

       ;Set pixel buffer
       {
	mv_s	#MPR_PixBuf1,_PBUF	;Set Pixel Buffer
	sub	#1,r0			;r0 -1
       }

       ;Clear scanline tags
	st_s	r0,(MPR_BmInfoC)	;Clear even tag
	st_s	r0,(MPR_BmInfoC+4)      ;Clear odd tag


SPRYLoop:
       {
	sub	#1<<15,_LV		;for BILINEAR adjust
	ld_s	(uvctl),v1[1]		;Fetch uvctl
       }
       {
	st_v	v4,(MPR_Dump+1*16) 	;Backup v4
	and	#1<<16,_LV,r2		;even/odd scanline
	mvr	_LV,rv			;set rv
       }
       {
	modulo	rv			;Modulo (from EDGE stepper)
	mv_s	v1[1],v1[2]		;uvctl
	bits	#11-1,>>#0,v1[1]	;Check bilinear on/off
       }
       {
	bra	ne,`bilinear		;its on
	mv_s	#MPR_BmInfoC,r1		;ptr Scanline tags
	bits	#4-1,>>#20,v1[2]	;Pixel type
	modulo	rv			;just to be sure...
       }
       {
	ld_s	(rv),r3			;modulo'ed LV
	add	r2,>>#16-2,r1		;ptr Scanline tag
       }
       {
	ld_s	(MPR_BmInfoCTag),r0	;#of bytes/scanline
	addr	#0x8000,rv		;Remove BILINEAR adjust
	cmp	#PIX_4B,v1[2]		;4Bit ?
       }
       ;--------------------------------;bra eq,`nobilinear,nop
	modulo	rv			;remove BILINEAR adjust
       {
	ld_s	(rv),r3			;Unadjust rv for non bilinear stuff
	sub	r2,>>#16-2,r1		;return to 1st Scanline tag & set ne
	subm	r2,r2			;0 scanline offset
       }
`bilinear:
       {
	bra	ne,`nopix4bit		;Not 4Bit/Pixel in bilinear
	ld_s	(r1),v1[0]		;Scanline tag
	modulo	rv			;remove BILINEAR adjust
	lsr	#16-10,r2		;r2 2048/2 for odd line with bilinear
       }
       {
	ld_s	(rv),_LV		;Restore original _LV
	lsr	#16,r3			;Scanline#
       }
       {
	st_s	r3,(r1)			;Set new scanline tag
	addr	#0x8000,rv		;next rv (for bilinear filtering)
	cmp	r3,v1[0]		;Scanline already in cache ?
       }
       ;--------------------------------;bra ne,`nopix4bit
	mul	#1,r2,>>#1,r2		;fix 4BIT odd bilinear cache addr
`nopix4bit:
       {
	jsr	ne,MPR_DoDMAScramblev1	;Nope, Fetch Scanline
	ld_s	(MPR_BitmapCTag),r1	;Bitmap address
	mul	r0,r3,>>#0,r3		;Scanline offset
       }
       {
	add	#MPR_BitmapC,r2		;Destination Address
       }
       {
	addm	r3,r1			;Scanline address
	mv_s	#0x1F,r3		;Wait DMA
       }
       ;--------------------------------;jsr DoDMAScramblev1

       //Fetch 2nd scanline for bilinear filtering (if necessary)
       {
	ld_s	(uvctl),v1[1]		;Fetch uvctl
	modulo	rv			;modulo (for bilinear filtering)
	sub	r2,r2			;clear r2
       }
       {
	ld_s	(uvctl),v1[2]		;Fetch uvctl
	bset	#16,r2			;set 1<<16
       }
       {
	ld_s	(rv),r3			;modulo'ed rv
	bits	#11-1,>>#0,v1[1]	;Check bilinear on/off
       }
       {
	bra	eq,`nobilinear		;its off
	bits	#4-1,>>#20,v1[2]	;Extract pixel type
       }
       {
	mv_s	#MPR_BmInfoC,r1		;ptr Scanline tags
	and	r3,r2 			;even/odd
       }
       {
	add	r2,>>#16-2,r1		;ptr Scanline tag
       }
       ;--------------------------------;bra eq,`nobilinear
       {
	ld_s	(MPR_BmInfoCTag),r0	;#of bytes/scanline
	cmp	#PIX_4B,v1[2]		;4bit/pixel mode ?
       }
       {
	bra	ne,`not4bit		;nope, do not modify cache addr
	ld_s	(r1),v1[0]		;Scanline tag
	lsr	#16,r3			;scanline #
       }
	lsr	#16-10,r2		;0 even 2048/2 odd
       {
	st_s	r3,(r1)			;Set new scanline tag
	cmp	r3,v1[0]		;Scanline already in cache ?
       }
       ;--------------------------------;bra ne,`not4bit
	mul	#1,r2,>>#1,r2		;fix 4BIT odd bilinear cache addr
`not4bit:
       {
	jsr	ne,MPR_DoDMAScramblev1	;Nope, Fetch Scanline
	ld_s	(MPR_BitmapCTag),r1	;Bitmap address
	mul	r0,r3,>>#0,r3		;Scanline offset
       }
       {
	add	#MPR_BitmapC,r2		;Destination Address
       }
       {
	addm	r3,r1			;Scanline address
	mv_s	#0x1F,r3		;Wait DMA
       }
       ;--------------------------------;jsr DoDMAScramblev1
`nobilinear:
       ;do NOT use mv_s in 1st packet here!
       ;Setup Main Bus Write Command
       {
        ld_s	(MPR_sbDMAF),r0		;Read DMA Flags
	copy	v4[3],_TY		;Ystart 16.16
	subm	_HGHYCUR,_HGHYCUR  	;clear HGHYCUR
	mvr	_LU,ru				;Set ru
       }
       {
	ld_s	(MPR_sbSDRAM),r1	;Read Screen SDRAM address
	bset	#16,_HGHYCUR            ;Ylength 16.16
	mvr	_LV,rv				;Set rv
       }
       {
	copy	v4[1],_LX		;Left X
	st_s	r0,(MPR_MDMA1)		;Set DMA Flags
       }
       {
	st_s	r1,(SDRAM1)		;Set SDRAM address
	copy	v4[0],_WIDXTOT		;Width in X direction
       }


/*
DEBUG STUFF
	ld_p	(uv),v0
	addr	#1<<16,rv
	ld_p	(uv),v1
	addr	#-1<<16,rv
	lsr	#16,_LV,r0
	cmp	#2,r0
	bra	ne,SPRXLoop,nop
*/

SPRXLoop:
       {
	bra	le,SPRNextY			;Next Y (Width <= 0)
	cmp	_WIDXTOT,_PMAX			;X Width TOT <= Pixels/Pixbuf
       }
       {
	bra	ge,SPRCacheWidok 		;Yap, Render
	ld_s	(mdmactl),r0			;Read Main DMA Control
	sub_sv	_DGRBA,_DGRBA			;Clear _DGRBA
       }
	st_s	_PBUF,(xybase)			;Set XY Base
       {
	mv_s	_WIDXTOT,_WIDXCUR		;Set Current Width
	ftst	#0xE,r0				;0 or 1 DMA Active ?
       }
       ;----------------------------------------;bra ge,SPRDMALp
	mv_s	_PMAX,_WIDXCUR			;Set Current Width

SPRCacheWidok:
SPRDMAa2:
       {
	bra	ne,SPRDMAa2			;Nope, Wait
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

SPRWriteDMA:
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
	bra	ne,SPRWriteDMA,nop		;Nope, Wait
	addm    _WIDXCUR,r0,r3			;r1 _WIDXCUR+Transparent Pixels
	cmp	#0,_WIDXCUR			;Anything to DMA away ?
       }
       ;----------------------------------------;bra ne,SPRWriteDMA
       {
	bra	eq,SPRXLoop,nop			;Loop X if nothing to DMA
	addm	r0,_LX				;Skip #of Transparent Pixels
	sub	r3,_WIDXTOT			;Subtract #pixels rendered
       }
       ;----------------------------------------;bra eq,SPRXLoop or jsr SPRTranslucent
       {
	bra	gt,SPRXLoop			;Loop X
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
       ;----------------------------------------;SPRXLoop
SPRNextY:
       {
	ld_v	(MPR_LUVZ),_LUVZ	;Read _LUVZ
       }
       {
	ld_v	(MPR_DLUVZ),_DLUVZ	;Delta Left UVZ
	dec	rc1			;Decrease Y Counter
       }
       {
	bra	c1ne,SPRYLoop
	ld_v	(MPR_Dump+1*16),v4 	;Backup v4
       }
       {
	add	_DLU,_LU		;Step _LU
	addm	_DLV,_LV		;Step _LV
       }
       {
	st_v	_LUVZ,(MPR_LUVZ)	;Store new _LU & _LV
	add	#1<<16,v4[3]		;Increase Ystart
       }
       ;--------------------------------;bra c1ne,SPRYLoop
;	st_s	#MPR_NextCommand,(rz)	;Set return address
;	rts
       {
	jmp	MPR_NextCommand		;Done
	sub	r0,r0			;Clear r0
       }
	st_s	r0,(MPR_BmInfoCTag)	;Clear CTag BmInfo
	st_s	r0,(MPR_BitmapCTag)	;Clear CTag Bitmap
       ;--------------------------------;rts

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

`WaitDMAP:
	ld_s	(mdmactl),r2			;Read Main DMA Control
	ld_s	(xyctl),r0			;Read xyctl
	btst	#4,r2				;DMA Pending ?
       {
	bra	ne,`WaitDMAP,nop		;Nope, Wait for Pending DMA
	lsr	#20,r0				;Shift down
       }
       ;----------------------------------------;bra ne,`WaitDMAP

	st_s	_PBUF,(MPEAD2)			;Set MPE Source Address
	st_sv	_WXCLXHYCTY,(XPLEN2)		;Set XY & XYLen

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
	lsl	#20,r0                   	;Shift up


`WaitDMAF:
	ld_s	(mdmactl),r2			;Read Main DMA Control
	ld_w	(MPR_DGRBA+(3*2)),_DA		;Fetch Delta Alpha
       {
	st_s	r0,(uvctl)			;Set new uvctl
	bits	#4,>>#0,r2			;DMA Finished ?
       }
       {
	bra	ne,`WaitDMAF,nop		;Nope, Wait for Pending DMA
	mv_s	#1<<30,v0[3]			;One in 2.30
       }


	;Setup for Translucency Loop
       {
	ld_p	(uv),v0				;Read BackGround
	addr	#1<<16,ru			;Next pixel
       }
	sub	_A,v0[3],v2[3]			;v2[3] (1-Alpha)
       {
	ld_pz	(xy),v1				;Read ForeGround
	addr	#1<<16,rx			;Next pixel
	mul_p	_A,v0,>>#30,v0 			;(Alpha)*v0
       }
       {
	ld_p	(uv),v2				;Read BackGround
	addr	#1<<16,ru			;Next pixel
       }
       {
	mul_p	v2[3],v1,>>#30,v1		;(1-Alpha)*v1
	add	_DA,_A				;Update Alpha
	dec	rc0				;Decrement Inner Loop Counter
       }
       {
	ld_pz	(xy),v3				;Read ForeGround
	addr	#-1<<16,rx			;Next pixel
	mul_p	_A,v2,>>#30,v2 			;(Alpha)*v2
	sub	_A,v0[3],v2[3]			;v2[3] (1-Alpha)
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
	mul_p	v2[3],v3,>>#30,v3		;(1-Alpha)*v3
	add	_DA,_A				;Update Alpha
       }
       {
	ld_pz	(xy),v1				;Read ForeGround
	addr	#-1<<16,rx			;Next pixel
	mul_p	_A,v0,>>#30,v0 			;(Alpha)*v0
	sub	_A,v0[3],v2[3]			;v2[3] (1-Alpha)
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
	mul_p	v2[3],v1,>>#30,v1		;(1-Alpha)*v1
	add	_DA,_A				;Update Alpha
       }
       {
	ld_pz	(xy),v3				;Read ForeGround
	addr	#-1<<16,rx			;Next pixel
	mul_p	_A,v2,>>#30,v2 			;(Alpha)*v2
	sub	_A,v0[3],v2[3]			;v2[3] (1-Alpha)
       }

SPRTranslucencyDone:
	st_s	_DB,(uvbase)			;Restore uvbase
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
       ;----------------------------------------;rts
