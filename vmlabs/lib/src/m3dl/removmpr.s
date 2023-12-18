/*
 * Title	 	REMOVMPR.S
 * Desciption		Wait for MPR chain to finish & disable it
 * Version		1.1
 * Start Date		12/30/1998
 * Last Update		03/22/1999
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  v1.1 - Bios Compatible
 * Known bugs:
*/


	.module REMOVMPR

	.text

	.import	_MPR_mpeinfo


	.include "M3DL/m3dl.i"


;* __mdRemoveMPRChain
	.export	__mdRemoveMPRChain
;* Input:
;* Stack Usage:

	.cache
	.nooptimize
__mdRemoveMPRChain:
	mv_s	#BIOSCSEND,v2[1]	;BIOS CommSend Function
       {
	ld_s	(_MPR_mpeinfo),v0[1]	;Read MPR info
	sub	v0[2],v0[2]		;Clear Notification Address
       }
	ld_s	(configa),v0[3]		;Fetch MPE#
       {
	ld_s	(rz),v2[3]		;Backup v2[3]
	lsr	#16,v0[1],r4		;Start MPE#
       }
	bits	#16-1,>>#0,v0[1]	;Extract End MPR
       {
	jsr	(v2[1])			;Send Packet
	sub	#1,v0[1]		;Real End MPR
	mv_s	#BDDEF,v0[0]		;SyncDraw Packet ID
       }
       {
	mv_s	#BDTP,r5		;CommInfo Type
	copy	v0[1],v2[2]		;Real End MPR
       }
       {
	bits	#8-1,>>#8,v0[3]		;Extract MPE# (to Notify)
	mv_s	#BIOSCRECV,v2[1]	;Bios CommRecv Function
       }
       ;--------------------------------;jsr _bios_comm_send


`wait4done:
	jsr	(v2[1]),nop		;Receive Packet
       ;--------------------------------;jsr __bios_comm_recv,nop
	cmp	r4,v2[2]		;Coming from last MPE ?
       {
	bra	ne,`wait4done,nop	;Nope, wait
	cmp	#0x53594E43,v0[0]	;SYNC ?
       }
       ;--------------------------------;bra ne,`wait4done,nop
	bra	ne,`wait4done		;Nope, wait
	jmp	(v2[3])			;return
	nop
       ;--------------------------------;bra ne,`wait4done
	nop
       ;--------------------------------;rts nop

