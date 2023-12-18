/*
 * Title	 	MPRXTRCL.S
 * Desciption		MPR Extra Color Main Code
 * Version		1.0
 * Start Date		12/02/1998
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
	.overlay	mprxcol
	.origin 	mprmainbase

;*
;* Import
;*
	.import	MPR_Waitallbuses
	.import	MPR_NextCommand

	.import	MPR_sbSDRAM

	.import	MPR_MDMA1, MPR_MDMA2


;*
;* Export
;*
	.export	MPR_XCOLOR
	.export	_mprxcol_start, _mprxcol_size

MPR_XCOLOR:
	ld_v	(v7[0]),v0		;Fetch Packet #1
	nop
	st_s	#MPR_NextCommand,(rz)	;Store Return Address
	ld_s	(MPR_sbFlags),v7[1]	;Read sbFlags
	st_s	v0[1],(MPR_ExtraColor)	;Store GRB Color
       {
	ld_s	(linpixctl),v4[0]	;Backup linpixctl
	btst	#sbGRBb,v7[1] 		;ScreenMode GRB ?
       }
       {
	bra	ne,itsgrb		;its grb, so modify it
	st_s	#PIX_32B<<20,(linpixctl);Set 32Bit GRB
       }
	ld_pz	(MPR_ExtraColor),v6	;Read GRB Components
	st_s	#(1<<28)|(PIX_32B<<20),(linpixctl)	;Set 32Bit YCrCb
       ;--------------------------------;bra ne,itsgrb
       {
	ld_sv	(MPR_GRB32Ycc),v1	;GRB -> Y
	copy	v6[3],v3[3]		;Copy Alpha
	subm	v6[3],v6[3]		;Clear v6[3]
       }
       {
	ld_sv	(MPR_GRB32Ycc+8),v2	;GRB -> Cr
	bset	#30,v6[3]		;v6[3] One in 2.30
       }
       {
	dotp	v1,v6,>>#30,v3[0]	;Y Component
	ld_sv	(MPR_GRB32Ycc+16),v1	;GRB -> Cb
       }
	dotp	v2,v6,>>#30,v3[1]	;Cr Component
	dotp	v1,v6,>>#30,v3[2]	;Cb Component
	rts				;Yap, Done
	st_pz	v3,(MPR_ExtraColor)	;Set YCrCb Color
	st_s	v4[0],(linpixctl)	;Restore linpixctl
       ;--------------------------------;bra MPR_NextCommand
itsgrb:
	rts				;Done
	st_pz	v6,(MPR_ExtraColor)	;Set YCrCb Color
	st_s	v4[0],(linpixctl)	;Restore linpixctl

