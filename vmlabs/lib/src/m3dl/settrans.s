/*
 * Title	 	SETTRANS.S
 * Desciption		Set Transparency Mode on MPRs
 * Version		1.1
 * Start Date		10/05/1999
 * Last Update		10/05/1999
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  v1.1 - Bios Compatible
 * Known bugs:
*/


	.module SETTRANS

	.text

	.import	_MPR_mpeinfo


	.include "M3DL/m3dl.i"


;* _mdSetTransparencyMode()
	.export	_mdSetTransparencyMode
;* Input:
;* r0 MODE
;* r1 Background Alpha
;* Stack Usage:

	.cache
	.nooptimize

_mdSetTransparencyMode:
       {
	ld_s	(rz),v2[3]		;Backup rz
       }
       {
	ld_s	(_MPR_mpeinfo),v1[1]	;Read MPE info
	copy	r1,v0[2]		;Set v0[2]
       }
       {
	copy	r0,v0[1]		;Set Argument
	subm	v0[3],v0[3]		;Clear v0[3]
       }
	lsr	#16,v1[1],v1[0]		;Start MPE#
       {
	mv_s	#TMDEF,v0[0]		;Transparency Mode Packet
	bits	#16-1,>>#0,v1[1]	;End MPE #
       }
       {
	mv_s	#BIOSCSEND,v2[1]	;Bios CommSend function
	sub	#1,v1[1],v2[2]		;Real End MPE #
       }

`STRLoop:
       {
	jsr	(v2[1]),nop		;Send Packet
	mv_s	#TMTP,r5		;Set CommInfo Type
       }
       ;--------------------------------;jsr _bios__comm_send
	cmp	v1[0],v2[2]		;End MPR Reached ?
	bra	ne,`STRLoop		;Nope, Loop
	jmp	(v2[3])			;Return
       {
	st_s	v2[3],(rz)		;Restore rz (just in case..)
	add	#1,v1[0]		;Next MPR
       }
       ;--------------------------------;bra ne,`STRLoop
	sub	r0,r0			;Clear return value
       ;--------------------------------;rts


