/*
 * Title	 	MPRSCRCV.S
 * Desciption		MPR Screen Conversion Main Code
 * Version		1.0
 * Start Date		09/16/1998
 * Last Update		10/29/1998
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
	.overlay	mprscrcv
	.origin 	mprmainbase

;*
;* Import
;*
	.import	MPR_WaitMDMAThenNextCommand

	.import	MPR_sbFlags, MPR_sbDMAF, MPR_sbSDRAM

	.import	MPR_MDMA1, MPR_MDMA2, MPR_MDMAeor
	.import	DMAFL1, SDRAM1, XPLEN1, YPLEN1, MPEAD1
	.import	DMAFL2, SDRAM2, XPLEN2, YPLEN2, MPEAD2
	.import	MPR_BitmapCTag

	.import	MPR_Dump

;*
;* Export
;*
	.export	_mprscrcv_start, _mprscrcv_size
	.export	MPR_SCRCV

MPR_SCRCV:
       {
	ld_v	(v7[0]),v0		;Fetch Packet #1
	sub	v2[0],v2[0]		;Clear v2[0]
       }
	st_s	v2[0],(MPR_BitmapCTag)	;Clear CTag Bitmap
	ld_s	(MPR_sbDMAF),v2[0]	;Retrieve ScreenBuffer DMA Flags
	ld_s	(MPR_sbFlags),v2[3]	;sbFlags
	copy	v2[0],v2[1]		;sb DMA Flags
	bits	#4-1,>>#4,v2[1]		;Extract Transfer Mode
	cmp	#CV_32B_16B>>4,v2[1]	;Original TR_16B ?
       {
	mv_s	v0[2],v2[2]		;sc DMA Flags
	bra	ne,`SCDMAsrcok		;Nope, do not modify
	bits	#4-1,>>#0,v2[3]		;Extract Pixmode
       }
	bits	#4-1,>>#4,v2[2]		;sc DMA Flags
	or	#NW_Z,v0[2]		;Never Write Z on Destination
       {
	mv_s	#PIX_16B,v2[3]		;Original Pixel Mode
	eor	#CV_32B_16B^TR_16B_NOZ,v2[0]	;Original Mode
       }
`SCDMAsrcok:
	cmp	#TR_32B_NOZ>>4,v2[2]	;Transfer 32B ?
       {
	bra	eq,`SCTRdstok,nop	;Yap, done
	mv_s	#PIX_32B,v2[1]		;sc Pixel Mode 32B
	cmp	#TR_32B_WITHZ>>4,v2[2]	;Transfer 32B + Z ?
       }
       {
	bra	eq,`SCTRdstok,nop	;Yap, done
	cmp	#CV_32B_16B>>4,v2[2]	;Transfer 32B -> 16B ?
       }
       {
	bra	eq,`SCTRdstok,nop	;Yap, done
	cmp	#TR_16B_NOZ>>4,v2[2]	;Transfer 16B ?
       }
       {
	bra	ne,`SCTRdstok,nop	;Nope, done
	mv_s	#PIX_16B_WITHZ,v2[1]	;sc Pixel Mode 16B+Z
       }
	;We are in 16bit mode, st_p cannot do 2byte so change flags & pixtype
       {
	mv_s	#PIX_32B,v2[1] 		;32B
	eor	#TR_16B_NOZ^CV_32B_16B,v0[2]	;CV_32B_16B
       }
`SCTRdstok:
	;v2[1] dst pixmode
	;v2[3] src pixmode
       {
	btst	#scDPQb,v0[0]		;Depth Cue (Z!) Wanted ?
       }
       {
	bra	ne,`SCzused		;Yap, z used
	lsl	#20,v2[1]		;Pixtype<<20
       }
	bset	#28,v2[1]		;Set CHNORM
       {
	st_s	v2[1],(xyctl)		;Destination Pixmode
	and	#-15,v2[0] 		;Always read Z
       }
	;-------------------------------;
	or	#NW_Z,v2[0]		;Never read Z
	cmp	#PIX_16B_WITHZ,v2[3]	;< Pixel type 5 ?
	bra	lt,`SCzused,nop		;Yap, do not modify
       {
	bra	eq,`SCzused,nop		;Yap, modify into PIX_16B
	mv_s	#PIX_16B,v2[3]		;
       }
	mv_s	#PIX_32B,v2[3]		;Default 32B
`SCzused:
`SCWMDMA:
	ld_s	(mdmactl),v1[0]		;Read Main DMA Control Flags
	ld_s	(MPR_sbSDRAM),v1[1]	;Fetch SB SDRAM address
	bits	#4,>>#0,v1[0]		;MDMA Active or Pending ?
       {
	bra	ne,`SCWMDMA,nop		;Yap, Wait
	bset	#13,v2[0]		;Set READ bit
       }
	;-------------------------------;
	st_s	v2[0],(DMAFL1)		;Store Read DMAFlags
	st_s	v1[1],(SDRAM1)		;Store Read SDRAM
	st_s	v0[2],(DMAFL2)		;Store Write DMAFlags
       {
	st_s	v0[1],(SDRAM2)		;Store Write SDRAM
	lsl	#20,v2[3]		;Pixtype<<20
       }
	ld_sv	(MPR_sbWINxw),v4	;Read X W Y H
       {
	ld_sv	(v7[1]),v3		;Read XSrcOffs YSrcOffs XDst YDst
;	bset	#28,v2[3]		;Set CHNORM (GRB Read, no CHNORM)
       }
       {
	st_s	v2[3],(uvctl)		;Source Pixmode
	add	#8,v7[1]		;PTr WH
       }
       {
	ld_sv	(v7[1]),v5		;W H
	copy	v3[3],v4[3]		;ywact
	addm	v3[1],v4[2],v3[3]	;yract
       }
       {
	copy	v3[2],v2[1]		;xwrite
	addm	v3[0],v4[0],v2[0]	;xread
       }
       {
	copy	v5[0],v2[2]		;width
	mv_s	#(pixbuflen/4)<<16,v2[3];PIXINBUF
       }
       {
	mv_s	#MPR_PixBuf1,v4[2]	;wbuf
	subm	v5[0],v5[0]		;wrcomlen
       }
       {
	mv_s	#MPR_BmC1,v3[2]	;rbuf
	lsr	#16,v5[1]		;height as integer
       }
	st_s	v5[1],rc1		;Height (counter)
	mv_s	#SCVConvert,v5[2]	;Pixel Generator

SCVVerloop:
       {
	mv_s	v2[0],v3[1]		;xract = xread
	copy	v2[1],v4[1]		;xwact = xwrite
       }
       {
	mv_s	v2[2],v4[0]		;wact = width
	copy	v2[3],v3[0]		;actlen = pixinbuf
       }
SCVHorloop:
	cmp	v3[0],v4[0]		;actlen <= wact ?
	bra	ge,`SCVwidok,nop	;
	mv_s	v4[0],v3[0]		;actlen = wact
`SCVwidok:
	ld_s	(mdmactl),r0		;Read MDMA Control Flags
	copy	v3[2],r1		;Backup Destination
	btst	#4,r0			;DMA Pending ?
       {
	bra	ne,`SCVwidok,nop	;Yap, Wait
	mv_s	#MPR_MDMA1,r2		;DMA Command address
       }

	;* Read DMA
	mv_s	#1<<16,v3[2]		;ylen = one
	st_s	r1,(MPEAD1)		;Read Destination
       {
	st_sv	v3,(XPLEN1)		;actlen xract ylen yract
	copy	r1,v3[2]		;Restore read buffer
       }
	st_s	r2,(mdmacptr)		;Launch DMA

	;* Convert Read Buffer GRB to Write Buffer YCrCb
	lsr	#16,v5[0],r0		;wrcomlen
	cmp	#0,v5[0]		;wrcomlen > 0 ?
       {
	jsr	gt,(v5[2])		;Yap, Convert
	st_s	r0,rc0 			;Set Counter
	eor	#MPR_PixBufeor,v4[2]	;Swap Write Buffer
       }
       {
	st_s	v4[2],(xybase)		;Set Write Buffer
	eor	#MPR_BmCeor,v3[2]	;Swap Read Buffer
       }
       {
	st_s	v3[2],(uvbase)		;Set Read Buffer
	dec	rc0			;Pre-Decrement
       }

	;* DMA Wait
`SCVWMDMA:
	ld_s	(mdmactl),r0		;Read Main Dma Control Flags
	copy	v5[2],r1		;Backup PixelGen
	bits	#4,>>#0,r0		;DMA Active or Pending ?
       {
	bra	ne,`SCVWMDMA,nop	;Yap, Wait
	cmp	#0,v5[0]		;wrcomlen > 0 ?
       }

	;* Write DMA
       {
	bra	le,`SCVNowrite,nop   	;No Write needed
	mv_s	#MPR_MDMA2,r2		;DMA Command address
       }
       ;--------------------------------;bra le,`SCVNowrite

	mv_s	#1<<16,v5[2]		;ylen = one
	st_s	v4[2],(MPEAD2)		;Write Source
       {
	st_sv	v5,(XPLEN2)		;wrcomlen wrcomx ylen wrcomy
	copy	r1,v5[2]		;Restore PixelGen
       }
	st_s	r2,(mdmacptr)		;Launch DMA

	;* Update Steppers & Loop
`SCVNowrite:
	sub	v3[0],v4[0]		;wact -= actlen
       {
	bra	gt,SCVHorloop		;while (wact > 0)
	mv_s	v4[1],v5[1] 		;wrcomx = xwact
       }
       {
	mv_s	v4[3],v5[3]		;wrcomy = ywact
	add	v3[0],v3[1]		;xract += actlen
       }
       {
	mv_s	v3[0],v5[0] 		;wrcomlen = actlen
	add	v3[0],v4[1]		;xwact += actlen
       }

       {
	add	#1<<16,v3[3]		;yract++
	dec	rc1			;Decrease height
       }
       {
	bra	c1ne,SCVVerloop,nop	;while (height > 0)
	add	#1<<16,v4[3]		;ywact++
       }
       ;--------------------------------;bra c1ne,SCVVerloop

	;* Convert Read Buffer GRB to Write Buffer YCrCb
	cmp	#0,v5[0]		;wrcomlen > 0 ?
       {
	bra	le,SCVDone		;Nope, Finished
	lsr	#16,v5[0],r0		;wrcomlen
       }
       {
	jsr	(v5[2])			;Yap, Convert
	st_s	r0,rc0 			;Set Counter
	eor	#MPR_PixBufeor,v4[2]	;Swap Write Buffer
       }
       {
	st_s	v4[2],(xybase)		;Set Write Buffer
	eor	#MPR_BmCeor,v3[2]	;Swap Read Buffer
       }
       {
	st_s	v3[2],(uvbase)		;Set Read Buffer
	dec	rc0			;Pre-Decrement
       }

	;* DMA Wait
`SCVWMDMA2:
	ld_s	(mdmactl),r0		;Read Main Dma Control Flags
	copy	v5[2],r1		;Backup PixelGen
	bits	#4,>>#0,r0		;DMA Active or Pending ?
       {
	bra	ne,`SCVWMDMA2,nop	;Yap, Wait
	mv_s	#MPR_MDMA2,r2		;DMA Command address
       }

	;* Write DMA
	mv_s	#1<<16,v5[2]		;ylen = one
	st_s	v4[2],(MPEAD2)		;Write Source
	st_sv	v5,(XPLEN2)		;wrcomlen wrcomx ylen wrcomy
	st_s	r2,(mdmacptr)		;Launch DMA
SCVDone:
	nop
	st_s	#MPR_WaitMDMAThenNextCommand,(rz)	;Prepare to quit
	rts	nop			;Done

	;Fragment Conversion Loop
SCVConvert:
       {
	st_v	v2,(MPR_Dump)		;Backup v2
	sub	v0[3],v0[3]		;Clear v0[3]
       }
       {
	mvr	v0[3],ru 		;Clear ru
	st_v	v3,(MPR_Dump+(1*16))	;Backup v3
	sub	v1[3],v1[3]		;Clear v1[3]
       }
       {
	mvr	v0[3],rx 		;Clear rx
	st_v	v4,(MPR_Dump+(2*16))	;Backup v4
	bset	#30,v0[3]		;v0[3] One as 2.30 Value
       }
       {
	st_v	v5,(MPR_Dump+(3*16))	;Backup v5
	bset	#30,v1[3]		;v1[3] One as 2.30 Value
       }
	ld_sv	(MPR_GRB32Ycc),v5	;GRB -> Y
	ld_p	(uv),v3			;Read Pixel
       {
	ld_sv	(MPR_GRB32Ycc+8),v6	;GRB -> Cr
	addr	#1<<16,ru		;Increase ru
       }
       {
	dotp	v5,v3,>>#30,v1[0]	;Y Component
       }
       {
	ld_sv	(MPR_GRB32Ycc+16),v7	;GRB -> Cb
	dotp	v6,v3,>>#30,v1[1]	;Cr Component
       }
       {
	ld_p	(uv),v2			;Read GRB Pixel
	addr	#1<<16,ru		;Increase ru
       }
	dotp	v7,v3,>>#30,v1[2]	;Cb Component
`SCVPerPixel:
       {
	dotp	v5,v2,>>#30,v0[0]	;Y Component
	bra	c0eq,`SCVPixDone	;Finished
	ld_p	(uv),v3			;Read GRB Pixel
	addr	#1<<16,ru		;Next Pixel
       }
       {
	dotp	v6,v2,>>#30,v0[1]	;Cr Component
	st_p	v1,(xy)			;Store YCrCb Pixel
	addr	#1<<16,rx		;Next Pixel
	dec	rc0			;Decrement Loop Counter
       }
	dotp	v7,v2,>>#30,v0[2]	;Cb Component
       {
	bra	c0ne,`SCVPerPixel	;Loop
	dotp	v5,v3,>>#30,v1[0]	;Y Component
	ld_p	(uv),v2			;Read GRB Pixel
	addr	#1<<16,ru		;Next Pixel
       }
       {
	dotp	v6,v3,>>#30,v1[1]	;Cr Component
	st_p	v0,(xy)			;Store YCrCb Pixel
	addr	#1<<16,rx		;Next Pixel
	dec	rc0			;Decrement Loop Counter
       }
	dotp	v7,v3,>>#30,v1[2]	;Cb Component

`SCVPixDone:
	ld_v	(MPR_Dump),v2		;Restore v2
	ld_v	(MPR_Dump+(1*16)),v3	;Restore v3
       {
	rts
	ld_v	(MPR_Dump+(2*16)),v4	;Restore v4
       }
	ld_v	(MPR_Dump+(3*16)),v5	;Restore v5
	nop

