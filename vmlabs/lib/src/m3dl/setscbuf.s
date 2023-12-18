/*
 * Title	 	SETSCBUF.S
 * Desciption		Set Screen Buffer on MPRs
 * Version		1.1
 * Start Date		09/23/1998
 * Last Update		03/22/1999
 * By			Phil
 * Of			Miracle Designs
 * History:
 *  v1.0 - Initial Version
 *  v1.1 - Bios Compatible
 * Known bugs:
*/


	.module SETSCBUF

	.text

	.import	_MPR_mpeinfo


	.include "M3DL/m3dl.i"


;* _mdActiveDrawContext
	.export	_mdActiveDrawContext
;* Input:
;* r0 mdDRAWCONTEXT *drawcontext
;* Stack Usage:

	.cache
	.nooptimize
_mdActiveDrawContext:
       {
	ld_w	(r0),v2[1]		;Read ActBuf
	add	#8*4,r0,v1[2]		;Ptr ScreenMap
       }
       {
	add	#4*4,r0			;Ptr flags & select
       }
       {
	ld_s	(r0),v2[0]		;Read flags & select
	sub	#2*4,r0			;Ptr rendx
       }
       {
	add	v2[1],>>#16-3,v1[2]	;Ptr ScreenMap
       }
       {
	ld_s	(v1[2]),v0[1]		;Read ScreenMap SDRAM Address
	add	#4,v1[2]		;Ptr ScreenMap
       }
       {
	ld_s	(v1[2]),v0[2]		;Read ScreenMap DMAFlags
	and	#2,v2[0],v1[3]		;Isolate Z0/Z1 Select
       }
       {
	ld_s	(r0),v2[1]		;Read rendx rendy
	add	#4,r0			;Ptr rendw
	mul	#2,v1[3],>>#0,v1[3]	;Offset ZFlags (2*2 = 4 bytes)
       }
       {
	ld_s	(r0),v0[3]		;Read rendw rendh
	add	#2*4,r0			;
       }
       {
	addm	v1[3],r0		;Ptr ZFlags
	lsr	#16+2,v2[1],v2[2]	;Isolate rendx>>2
       }
       {
	ld_s	(r0),v1[3]		;Read ZFlags
	lsr	#16+2,v0[3],v1[2]	;Isolate rendw>>2
       }
       {
	bits	#8-1,>>#2,v2[1]		;Isolate rendy>>2
       }
       {
	ld_s	(_MPR_mpeinfo),v1[0]	;Read MPE Info
	or	v1[3],v0[2]		;Insert ZFlags
       }
       {
	mul	#1,v2[0],>>#16,v2[0]	;Shift down
	and	#3,v2[0],v2[3]		;Z0/Z1 Odd/Even
       }
       {
	mv_s	#1,v1[3]		;v1[3] 1
	bits	#8-1,>>#2,v0[3]		;Isolate rendh>>2
       }
       {
	mul	#1,v1[0],>>#16,v1[0]	;v1[0] STARTMPR#
	and	#0xFFFF,v1[0],v1[1]	;v1[1] ENDMPR#
       }
       {
	mv_s	#SBDEF,v0[0]
	or	v2[2],>>#-8,v2[1]	;rendx | rendy
       }
       {
	or	v2[3],>>#-14,v0[0]  	;Insert Z0/Z1 Odd/Even
	ld_s	(rz),v2[3]		;Backup rz
       }
       {
	addm	v2[0],v0[0]		;Set SB Type
	or	v1[2],>>#-8,v0[3]	;rendw | rendh
       }
       {
	or	v2[1],>>#-16,v0[3]	;rend x | rendy | rendw | rendh
	subm	v1[3],v1[1],v2[2]	;Real ENDMPE
	mv_s	#BIOSCSEND,v2[1]	;bios CommSend function
       }


`SBBLoop:
       {
	jsr	(v2[1]),nop		;Send Packet
	mv_s	#SBTP,r5		;Set CommInfo Type
       }
       ;--------------------------------;jsr _bios__comm_send
	cmp	v1[0],v2[2]		;End MPR Reached ?
	bra	ne,`SBBLoop		;Nope, Loop
	jmp	(v2[3])			;Return
       {
	st_s	v2[3],(rz)		;Restore rz (just in case..)
	add	#1,v1[0]		;Next MPR
       }
       ;--------------------------------;bra ne,`SBBLoop
	sub	r0,r0			;Clear return value
       ;--------------------------------;rts

