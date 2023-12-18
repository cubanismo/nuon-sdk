/*
 * Title	 	MPRSCRBF.S
 * Desciption		MPR Screen Buffer Main Code
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
	.overlay	mprscrbf
	.origin 	mprmainbase

;*
;* Import
;*
	.import	MPR_NextCommand

	.import	MPR_sbFlags, MPR_sbDMAF, MPR_sbSDRAM
	.import	MPR_CTags

	.import	MPR_MDMA1, MPR_MDMA2, MPR_MDMAeor
	.import	DMAFL1, SDRAM1, XPLEN1, YPLEN1, MPEAD1
	.import	DMAFL2, SDRAM2, XPLEN2, YPLEN2, MPEAD2

	.import	MPR_Dump

;*
;* Export
;*
	.export	_mprscrbf_start, _mprscrbf_size
	.export	MPR_SCRBF

MPR_SCRBF:
	ld_v	(v7[0]),v0		;Read ScreenBuf Packet
	nop
       {
	st_s	v0[1],(MPR_sbSDRAM)	;Store SDRAM Address
	and	#0xFF00,v0[0],v1[0] 	;Extract Flags
       }
       {
	mv_s	v0[2],v0[1]		;DMAFlags
	bits	#4-1,>>#4,v0[2]		;Isolate Transfer type
       }
       {
	st_s	#MPR_NextCommand,(rz)	;Set Return Address
	cmp	#TR_32B_WITHZ>>4,v0[2]	;32B+Z ?
       }
	;The upper 4bits of pixtype express
	; value 3 : 8 bytes/pixel
	; value 2 : 4 bytes/pixel
       {
	bra	eq,`SBpixdone,nop
	mv_s	#(3<<4)|PIX_32B_WITHZ,v1[1]	;32B+Z
	cmp	#TR_32B_NOZ>>4,v0[2]	;32B ?
       }
       {
	bra	eq,`SBpixdone,nop
	mv_s	#(2<<4)|PIX_32B,v1[1]		;32B
	cmp	#CV_32B_16B>>4,v0[2]	;32B ?
       }
       {
	bra	eq,`SBpixdone,nop
	cmp	#TR_16B_NOZ>>4,v0[2]	;16B ?
       }
       {
	bra	ne,`SBpixdone,nop
	mv_s	#(2<<4)|PIX_16B_WITHZ,v1[1]	;16B+Z
       }
	;We are in 16bit mode, st_p cannot do 2byte so change flags & pixtype
       {
	mv_s	#(2<<4)|PIX_32B,v1[1] 		;32B
	eor	#TR_16B_NOZ^CV_32B_16B,v0[1]	;CV_32B_16B
       }

`SBpixdone:
	btst	#sbGRBb,v1[0]		;GRB mode ?
       {
	bra	ne,`SBnogrbset		;Nope, no GRB mode
	or	v1[1],v1[0]		;Insert pixtype -> sbFlags
       }
	and	#0xF,v1[1]		;Extract Merlin pixtype
	lsl	#20,v1[1]		;Pixtype<<20
       ;--------------------------------;bra ne,`SBnogrbset
	bset	#28,v1[1]		;Set CHNORM (for YCrCb only)
`SBnogrbset:
       {
	st_s	v1[1],(xyctl)		;Set pixtype
	lsl	#16+2,v0[3],v1[3] 	;H * 4
       }
       {
	st_s	v1[0],(MPR_sbFlags)	;Store sbFlags
	lsl	#8+2,v0[3],v1[1]	;W * 4
       }
       {
	st_s	v0[1],(MPR_sbDMAF)	;Store DMAFlags
	lsr	#8-2,v0[3],v1[0] 	;X * 4
       }
       {
	mv_s	#0xFF<<(16+2),r1
	lsl	#2,v0[3],v1[2]		;Y
       }
	and	r1,v1[0]		;Extract X
	and	r1,v1[1]		;Extract W
       {
	and	r1,v1[2]		;Extract Y
	addm	v1[0],v1[1]		;X + W
       }
	and	r1,v1[3]		;Extract H
       {
	addm	v1[2],v1[3]		;Y + H
	rts				;Done
       }
       {
	st_sv	v1,(MPR_sbWINxw)	;Set View Window
	sub_sv	v2,v2			;Clear v2
       }
	st_v	v2,(MPR_CTags)		;Clear Cache Tags
       ;--------------------------------;Screen Buffer Packet Done

