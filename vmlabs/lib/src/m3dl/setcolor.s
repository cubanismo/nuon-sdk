/*
 * Title	 	SETCOLOR.S
 * Desciption		Set Extra Color on MPRs
 * Version		1.1
 * Start Date		11/13/1998
 * Last Update		03/22/1998
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  v1.1 - Bios Compatible
 * Known bugs:
*/


	.module SETCOLOR

	.text

	.import	_MPR_mpeinfo


	.include "M3DL/m3dl.i"


;* _mdActiveBlendColor
	.export	_mdActiveBlendColor
;* Input:
;* r0 mdCOLOR *color
;* Stack Usage:

	.cache
	.nooptimize

_mdActiveBlendColor:
	ld_s	(rz),v2[3]		;Backup rz
       {
	ld_s	(_MPR_mpeinfo),v1[1]	;Read MPE info
	subm	v0[2],v0[2]		;Clear v0[2]
       }
       {
	ld_s	(r0),v0[1]		;Read Color
	subm	v0[3],v0[3]		;Clear v0[3]
       }
	lsr	#16,v1[1],v1[0]		;Start MPE#
       {
	mv_s	#ECDEF,v0[0]		;Extra Color Packet
	bits	#16-1,>>#0,v1[1]	;End MPE #
       }
       {
	mv_s	#BIOSCSEND,v2[1]	;Bios CommSend function
	sub	#1,v1[1],v2[2]		;Real End MPE #
       }

`SECLoop:
       {
	jsr	(v2[1]),nop		;Send Packet
	mv_s	#ECTP,r5		;Set CommInfo Type
       }
       ;--------------------------------;jsr _bios__comm_send
	cmp	v1[0],v2[2]		;End MPR Reached ?
	bra	ne,`SECLoop		;Nope, Loop
	jmp	(v2[3])			;Return
       {
	st_s	v2[3],(rz)		;Restore rz (just in case..)
	add	#1,v1[0]		;Next MPR
       }
       ;--------------------------------;bra ne,`SBBLoop
	sub	r0,r0			;Clear return value
       ;--------------------------------;rts


