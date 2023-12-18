/*
 * Title	 	MPRBRKDR.S
 * Desciption		MPR Break Draw Code
 * Version		1.0
 * Start Date		12/02/1998
 * Last Update		02/25/1999
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
	.overlay	mprbrkdr
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
	.export	_mprbrkdr_start, _mprbrkdr_size
	.export	MPR_BRKDR

MPR_BRKDR:
	jsr	MPR_Waitallbuses,nop	;Wait for all DMA to go idle
       ;--------------------------------;jsr Waitallbuses
	ld_s	(configa),r9		;Fetch MPE#
	ld_v	(v7[0]),v1		;Fetch Packet #1
	bits	#8-1,>>#8,r9		;MPE#
	cmp	v1[1],r9		;End MPR ?
	bra	ne,MPR_SendPacket	;Nope, Forward SyncDraw
	add	#1,r9,r0		;New Target MPE
	st_s	#MPR_WaitMDMAThenNextCommand,(rz)	;Set Return address

SDNotify:
       {
	mv_s	v1[3],r0		;Target MPE
	sub_sv	v1,v1			;Clear v1
       }
	mv_s	#0x53594e43,v1[0]	;SYNC


;* Send Packet to Another MPE
;* Input:
;* r0 Target MPE
;* v1 Packet to send

MPR_SendPacket:
`CommWait:
	ld_s	(commctl),r1		;Read Comm Control flags
	nop
	btst	#15,r1			;Transmit Buffer Full flag set?
	bra	ne,`CommWait,nop	;Yap, Wait
       ;--------------------------------;bra ne,`CommWait,nop

`resend:
	st_s	r0,(commctl)		;Set Target MPE
	st_v	v1,(commxmit)		;Send Packet to MPR

`waitxmit:
	ld_s	(commctl),r1		;Read Communication Control register
	nop
	ftst	#(1<<14)|(1<<5),r1	;bits 14 & 5 (5: interrupt fail bit)
       {
	bra	ne,`resend,nop		;Yap, retry send
	btst	#15,r1			;Transmit Buffer Empty ?
       }
       ;--------------------------------;bra ne,`resend
	bra	ne,`waitxmit,nop 	;Nope, wait for xmit
       ;--------------------------------;bra ne,`waitxmit
	halt				;Done!
	nop
	nop
	nop
       ;--------------------------------;Break Draw Packet Done


